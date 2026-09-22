package com.ruoyi.interview.service.impl;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Date;
import java.util.List;
import java.util.Random;
import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.JSONArray;
import com.ruoyi.common.config.RuoYiConfig;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.DateUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.common.utils.file.FileUploadUtils;
import com.ruoyi.common.utils.file.FileUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ruoyi.interview.domain.InterviewReport;
import com.ruoyi.interview.domain.InterviewSession;
import com.ruoyi.interview.mapper.InterviewReportMapper;
import com.ruoyi.interview.mapper.InterviewSessionMapper;
import com.ruoyi.interview.service.IInterviewReportService;
import com.ruoyi.interview.utils.ReportPdfUtils;
import com.ruoyi.interview.utils.StudentDataScopeUtils;

/**
 * 面试复盘报告Service业务层处理
 * 
 * @author tong
 * @date 2026-09-21
 */
@Service
public class InterviewReportServiceImpl implements IInterviewReportService 
{
    /** 报告生成状态：待生成 */
    private static final String GENERATE_PENDING = "0";

    /** 报告生成状态：生成成功 */
    private static final String GENERATE_SUCCESS = "2";

    /** 场次状态：已完成（只有完成的场次才有复盘报告） */
    private static final String SESSION_STATUS_FINISHED = "2";

    /** 单个维度得分下限 */
    private static final BigDecimal SCORE_MIN = BigDecimal.ZERO;

    /** 单个维度得分上限 */
    private static final BigDecimal SCORE_MAX = new BigDecimal("100");

    /** 总结 / 改进建议的单段长度上限 */
    private static final int MAX_TEXT_LENGTH = 2000;

    @Autowired
    private InterviewReportMapper interviewReportMapper;

    @Autowired
    private InterviewSessionMapper interviewSessionMapper;

    /**
     * 查询面试复盘报告
     * 
     * @param id 面试复盘报告主键
     * @return 面试复盘报告
     */
    @Override
    public InterviewReport selectInterviewReportById(Long id)
    {
        return interviewReportMapper.selectInterviewReportById(id);
    }

    /**
     * 查询面试复盘报告列表
     * 
     * @param interviewReport 面试复盘报告
     * @return 面试复盘报告
     */
    @Override
    public List<InterviewReport> selectInterviewReportList(InterviewReport interviewReport)
    {
        return interviewReportMapper.selectInterviewReportList(interviewReport);
    }

    /**
     * 新增面试复盘报告
     * 
     * @param interviewReport 面试复盘报告
     * @return 结果
     */
    @Override
    public int insertInterviewReport(InterviewReport interviewReport)
    {
        StudentDataScopeUtils.requireManage("面试复盘报告");
        interviewReport.setCreateTime(DateUtils.getNowDate());
        return interviewReportMapper.insertInterviewReport(interviewReport);
    }

    /**
     * 修改面试复盘报告
     * 
     * @param interviewReport 面试复盘报告
     * @return 结果
     */
    @Override
    public int updateInterviewReport(InterviewReport interviewReport)
    {
        StudentDataScopeUtils.requireManage("面试复盘报告");
        interviewReport.setUpdateTime(DateUtils.getNowDate());
        return interviewReportMapper.updateInterviewReport(interviewReport);
    }

    /**
     * 建复盘报告壳（幂等），并回写 session.report_id 冗余指针
     * 
     * 这是「报告诞生」的唯一入口，两条路都会走到这里：
     *   ① 场次答完置「已完成」时由 InterviewSessionServiceImpl 调用；
     *   ② 手工填分时由 fillReport 补建（兼容 S4 之前就已完成的场次）。
     * 按 session_id 查一次，已存在就复用，不存在才建一条 generate_status='0'（待生成）的壳。
     * 报告以 interview_report.session_id 为权威关联，user_id 取自场次归属；
     * 写完壳再回写 session.report_id（值相同则不写）—— 指针只有后端写，前端不参与。
     * 
     * @param session 已完成的面试场次
     * @return 该场次的报告记录（已存在则返回旧的）
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public InterviewReport ensureReportShell(InterviewSession session)
    {
        if (session == null || session.getId() == null)
        {
            return null;
        }
        InterviewReport report = selectBySessionId(session.getId());
        if (report == null)
        {
            InterviewReport shell = new InterviewReport();
            shell.setReportNo(generateReportNo());
            shell.setSessionId(session.getId());
            shell.setUserId(session.getUserId());
            shell.setGenerateStatus(GENERATE_PENDING);
            shell.setStatus(StudentDataScopeUtils.STATUS_NORMAL);
            shell.setCreateTime(DateUtils.getNowDate());
            interviewReportMapper.insertInterviewReport(shell);
            report = shell;
        }
        // 双向引用：report.session_id 是权威关联，session.report_id 只是后端写的冗余指针，两边都要写。
        // 放在这里是因为它同时覆盖「答完自动建壳」与「手工填分补建壳」；
        // 也顺带修掉「壳已存在但指针是空的」（S4 之前完成的场次）。
        if (report.getId() != null && !report.getId().equals(session.getReportId()))
        {
            InterviewSession pointer = new InterviewSession();
            pointer.setId(session.getId());
            pointer.setReportId(report.getId());
            pointer.setUpdateTime(DateUtils.getNowDate());
            interviewSessionMapper.updateInterviewSession(pointer);
        }
        return report;
    }

    /**
     * 手工填分（阶段一的演示入口，阶段三换成 AI 自动生成）
     * 
     * 只接受 sessionId + 五个维度 + 总结 / 薄弱点 / 改进建议；
     * 总分由后端按五维平均算出，report_no / user_id / generate_status / generate_time 也由后端写。
     * 该场次还没有报告壳时先补建，兼容 S4 之前就已完成的场次。
     * 
     * @param interviewReport 填分提交体
     * @return 落库后的报告
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public InterviewReport fillReport(InterviewReport interviewReport)
    {
        // 1. 场次必填、属于当前学生、且已经完成
        if (interviewReport.getSessionId() == null)
        {
            throw new ServiceException("请指定要填分的面试场次");
        }
        InterviewSession session = StudentDataScopeUtils.checkOwner(
                interviewSessionMapper.selectInterviewSessionById(interviewReport.getSessionId()), "模拟面试场次");
        if (!SESSION_STATUS_FINISHED.equals(session.getStatus()))
        {
            throw new ServiceException("本场面试还没完成，完成后才会生成复盘报告");
        }

        // 2. 五个维度都要在 0 ~ 100 之间
        BigDecimal[] dimensions = new BigDecimal[] {
                interviewReport.getScoreCompleteness(), interviewReport.getScoreLogic(),
                interviewReport.getScoreFluency(), interviewReport.getScoreDepth(),
                interviewReport.getScoreConfidence() };
        BigDecimal sum = BigDecimal.ZERO;
        for (BigDecimal dimension : dimensions)
        {
            if (dimension == null)
            {
                throw new ServiceException("请填写完整的五个维度得分");
            }
            if (dimension.compareTo(SCORE_MIN) < 0 || dimension.compareTo(SCORE_MAX) > 0)
            {
                throw new ServiceException("每个维度得分需在 0 ~ 100 之间");
            }
            sum = sum.add(dimension);
        }

        // 3. 没有壳就先建壳（S4 之前完成的场次没有壳）
        InterviewReport report = ensureReportShell(session);
        Date now = DateUtils.getNowDate();

        // 4. 白名单写入：总分由后端算（五维平均，保留两位），不采信前端传值
        InterviewReport update = new InterviewReport();
        update.setId(report.getId());
        update.setScoreCompleteness(dimensions[0]);
        update.setScoreLogic(dimensions[1]);
        update.setScoreFluency(dimensions[2]);
        update.setScoreDepth(dimensions[3]);
        update.setScoreConfidence(dimensions[4]);
        update.setTotalScore(sum.divide(BigDecimal.valueOf(dimensions.length), 2, RoundingMode.HALF_UP));
        update.setSummary(truncate(interviewReport.getSummary()));
        update.setWeakPoints(normalizeWeakPoints(interviewReport.getWeakPoints()));
        update.setSuggest(truncate(interviewReport.getSuggest()));
        update.setGenerateStatus(GENERATE_SUCCESS);
        update.setGenerateTime(now);
        update.setUpdateTime(now);
        interviewReportMapper.updateInterviewReport(update);

        return interviewReportMapper.selectInterviewReportById(report.getId());
    }

    /**
     * 生成复盘报告 PDF：仅允许已生成成功的报告；落盘后回写 pdf_url
     *
     * @param id 报告主键
     * @return 落库后的报告
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public InterviewReport exportPdf(Long id)
    {
        InterviewReport report = StudentDataScopeUtils.checkOwner(
                interviewReportMapper.selectInterviewReportById(id), "面试复盘报告");
        if (!GENERATE_SUCCESS.equals(report.getGenerateStatus()))
        {
            throw new ServiceException("报告尚未生成成功，无法导出 PDF");
        }

        byte[] pdfBytes = ReportPdfUtils.build(report);
        try
        {
            // 覆盖旧 PDF：先写新文件，再删旧文件，避免写失败时丢链接
            // 不走 FileUtils.writeBytes —— 它按图片魔数猜扩展名，PDF 会被误存成 .jpg
            String uploadDir = RuoYiConfig.getUploadPath() + java.io.File.separator + "report";
            String relativeName = DateUtils.datePath() + "/" + report.getReportNo() + ".pdf";
            java.io.File file = FileUploadUtils.getAbsoluteFile(uploadDir, relativeName);
            java.io.File parent = file.getParentFile();
            if (parent != null && !parent.exists() && !parent.mkdirs())
            {
                throw new ServiceException("无法创建 PDF 目录：" + parent.getAbsolutePath()
                        + "，请检查 ruoyi.profile 配置的磁盘是否存在");
            }
            try (java.io.FileOutputStream fos = new java.io.FileOutputStream(file))
            {
                fos.write(pdfBytes);
            }
            String pdfUrl = FileUploadUtils.getPathFileName(uploadDir, relativeName);

            InterviewReport update = new InterviewReport();
            update.setId(report.getId());
            update.setPdfUrl(pdfUrl);
            update.setUpdateTime(DateUtils.getNowDate());
            interviewReportMapper.updateInterviewReport(update);

            if (StringUtils.isNotEmpty(report.getPdfUrl()) && !pdfUrl.equals(report.getPdfUrl()))
            {
                FileUtils.deleteFile(RuoYiConfig.getProfile() + FileUtils.stripPrefix(report.getPdfUrl()));
            }
            return interviewReportMapper.selectInterviewReportById(report.getId());
        }
        catch (ServiceException e)
        {
            throw e;
        }
        catch (Exception e)
        {
            throw new ServiceException("导出 PDF 失败：" + e.getMessage());
        }
    }

    /**
     * 批量删除面试复盘报告
     * 
     * @param ids 需要删除的面试复盘报告主键
     * @return 结果
     */
    @Override
    public int deleteInterviewReportByIds(Long[] ids)
    {
        StudentDataScopeUtils.requireManage("面试复盘报告");
        return interviewReportMapper.deleteInterviewReportByIds(ids);
    }

    /**
     * 删除面试复盘报告信息
     * 
     * @param id 面试复盘报告主键
     * @return 结果
     */
    @Override
    public int deleteInterviewReportById(Long id)
    {
        StudentDataScopeUtils.requireManage("面试复盘报告");
        return interviewReportMapper.deleteInterviewReportById(id);
    }

    /**
     * 按场次取报告，没有则返回 null
     * 
     * @param sessionId 面试场次主键
     * @return 报告记录
     */
    private InterviewReport selectBySessionId(Long sessionId)
    {
        InterviewReport query = new InterviewReport();
        query.setSessionId(sessionId);
        List<InterviewReport> list = interviewReportMapper.selectInterviewReportList(query);
        return list.isEmpty() ? null : list.get(0);
    }

    /**
     * 生成报告编号：R + yyyyMMddHHmmss + 3 位随机数
     * 
     * report_no 上有唯一索引，极小概率撞号时重新生成，最多重试 5 次。
     * 
     * @return 报告编号
     */
    private String generateReportNo()
    {
        Random random = new Random();
        for (int i = 0; i < 5; i++)
        {
            String reportNo = "R" + DateUtils.dateTimeNow(DateUtils.YYYYMMDDHHMMSS)
                    + String.format("%03d", random.nextInt(1000));
            InterviewReport probe = new InterviewReport();
            probe.setReportNo(reportNo);
            if (interviewReportMapper.selectInterviewReportList(probe).isEmpty())
            {
                return reportNo;
            }
        }
        throw new ServiceException("报告编号生成失败，请稍后重试");
    }

    /**
     * 长文本：去空格、空串转 null、超长报错
     * 
     * @param text 原始文本
     * @return 规范化后的文本
     */
    private String truncate(String text)
    {
        String value = StringUtils.trim(text);
        if (StringUtils.isEmpty(value))
        {
            return null;
        }
        if (value.length() > MAX_TEXT_LENGTH)
        {
            throw new ServiceException("文本过长，请控制在 " + MAX_TEXT_LENGTH + " 字以内");
        }
        return value;
    }

    /**
     * 薄弱点：空值转 null，非空必须是合法 JSON 数组（统一成规范化 JSON 字符串入库）
     * 
     * @param raw 原始文本
     * @return 规范化后的 JSON 数组字符串
     */
    private String normalizeWeakPoints(String raw)
    {
        String text = StringUtils.trim(raw);
        if (StringUtils.isEmpty(text))
        {
            return null;
        }
        try
        {
            JSONArray array = JSON.parseArray(text);
            if (array == null || array.isEmpty())
            {
                return null;
            }
            return array.toJSONString();
        }
        catch (Exception e)
        {
            throw new ServiceException("薄弱点格式不正确，应为 JSON 数组");
        }
    }
}
