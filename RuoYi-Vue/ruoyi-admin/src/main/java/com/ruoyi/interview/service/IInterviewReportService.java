package com.ruoyi.interview.service;

import java.util.List;
import com.ruoyi.interview.domain.InterviewReport;
import com.ruoyi.interview.domain.InterviewSession;

/**
 * 面试复盘报告Service接口
 * 
 * @author tong
 * @date 2026-09-21
 */
public interface IInterviewReportService 
{
    /**
     * 查询面试复盘报告
     * 
     * @param id 面试复盘报告主键
     * @return 面试复盘报告
     */
    public InterviewReport selectInterviewReportById(Long id);

    /**
     * 查询面试复盘报告列表
     * 
     * @param interviewReport 面试复盘报告
     * @return 面试复盘报告集合
     */
    public List<InterviewReport> selectInterviewReportList(InterviewReport interviewReport);

    /**
     * 新增面试复盘报告
     * 
     * @param interviewReport 面试复盘报告
     * @return 结果
     */
    public int insertInterviewReport(InterviewReport interviewReport);

    /**
     * 修改面试复盘报告
     * 
     * @param interviewReport 面试复盘报告
     * @return 结果
     */
    public int updateInterviewReport(InterviewReport interviewReport);

    /**
     * 建复盘报告壳（幂等），并回写 session.report_id 冗余指针
     * 
     * 「报告诞生」的唯一入口，两条路都会走到：① 场次答完置「已完成」时；② 手工填分补建时。
     * 按 session_id 查一次，已存在就复用，不存在才建一条 generate_status='0'（待生成）的壳。
     * 报告以 interview_report.session_id 为权威关联，user_id 取自场次归属；
     * 写完壳再回写 session.report_id（值相同则不写）。
     * 
     * @param session 已完成的面试场次
     * @return 该场次的报告记录（已存在则返回旧的）
     */
    public InterviewReport ensureReportShell(InterviewSession session);

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
    public InterviewReport fillReport(InterviewReport interviewReport);

    /**
     * 生成复盘报告 PDF，写入本地上传目录并回写 pdf_url
     *
     * @param id 报告主键
     * @return 落库后的报告（含 pdfUrl）
     */
    public InterviewReport exportPdf(Long id);

    /**
     * 批量删除面试复盘报告
     * 
     * @param ids 需要删除的面试复盘报告主键集合
     * @return 结果
     */
    public int deleteInterviewReportByIds(Long[] ids);

    /**
     * 删除面试复盘报告信息
     * 
     * @param id 面试复盘报告主键
     * @return 结果
     */
    public int deleteInterviewReportById(Long id);
}
