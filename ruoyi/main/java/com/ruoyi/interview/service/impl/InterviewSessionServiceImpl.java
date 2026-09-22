package com.ruoyi.interview.service.impl;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Random;
import java.util.Set;
import java.util.stream.Collectors;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.DateUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.interview.domain.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ruoyi.interview.mapper.InterviewQaMapper;
import com.ruoyi.interview.mapper.InterviewQuestionMapper;
import com.ruoyi.interview.mapper.InterviewReportMapper;
import com.ruoyi.interview.mapper.InterviewSessionMapper;
import com.ruoyi.interview.mapper.QuestionBankMapper;
import com.ruoyi.interview.mapper.StudentJobProfileMapper;
import com.ruoyi.interview.service.IInterviewReportService;
import com.ruoyi.interview.service.IInterviewSessionService;
import com.ruoyi.interview.utils.StudentDataScopeUtils;

/**
 * 模拟面试场次Service业务层处理
 * 
 * @author tong
 * @date 2026-09-21
 */
@Service
public class InterviewSessionServiceImpl implements IInterviewSessionService 
{
    /** 默认抽题数量 */
    private static final int DEFAULT_QUESTION_COUNT = 5;

    /** 单场抽题数量下限 */
    private static final int MIN_QUESTION_COUNT = 1;

    /** 单场抽题数量上限 */
    private static final int MAX_QUESTION_COUNT = 20;

    /** 场次状态：进行中 */
    private static final String STATUS_ONGOING = "1";

    /** 场次状态：已完成 */
    private static final String STATUS_FINISHED = "2";

    /** 场次状态：已中断 */
    private static final String STATUS_INTERRUPTED = "3";

    /** 题目来源：题库抽取 */
    private static final String SOURCE_BANK = "2";

    /** 子表状态：正常 */
    private static final String STATUS_NORMAL = "0";

    @Autowired
    private InterviewSessionMapper interviewSessionMapper;

    @Autowired
    private InterviewQuestionMapper interviewQuestionMapper;

    @Autowired
    private InterviewQaMapper interviewQaMapper;

    @Autowired
    private InterviewReportMapper interviewReportMapper;

    @Autowired
    private StudentJobProfileMapper studentJobProfileMapper;

    @Autowired
    private QuestionBankMapper questionBankMapper;

    @Autowired
    private IInterviewReportService interviewReportService;

    /**
     * 查询模拟面试场次
     * 
     * @param id 模拟面试场次主键
     * @return 模拟面试场次
     */
    @Override
    public InterviewSession selectInterviewSessionById(Long id)
    {
        return interviewSessionMapper.selectInterviewSessionById(id);
    }

    /**
     * 查询模拟面试场次列表
     * 
     * @param interviewSession 模拟面试场次
     * @return 模拟面试场次
     */
    @Override
    public List<InterviewSession> selectInterviewSessionList(InterviewSession interviewSession)
    {
        return interviewSessionMapper.selectInterviewSessionList(interviewSession);
    }

    /**
     * 新增模拟面试场次（=「开始面试」）
     * 
     * 前端只传「目标岗位画像 + 题型 + 题目数」，其余字段一律由后端生成，
     * 避免前端伪造 user_id / status / session_no 等内部字段：
     * 场次编号、归属用户、行业 / 岗位名 / 难度（取自岗位画像）、状态（进行中）、开始时间；
     * 同时从题库随机抽题写入 interview_question，题目与场次同事务落库。
     * 
     * @param interviewSession 模拟面试场次
     * @return 结果
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public int insertInterviewSession(InterviewSession interviewSession)
    {
        // 1. 目标岗位画像必须存在、属于当前学生、且未停用
        if (interviewSession.getJobProfileId() == null)
        {
            throw new ServiceException("请先选择目标岗位");
        }
        StudentJobProfile jobProfile = StudentDataScopeUtils.checkOwner(
                studentJobProfileMapper.selectStudentJobProfileById(interviewSession.getJobProfileId()), "学生岗位画像");
        if (!STATUS_NORMAL.equals(jobProfile.getStatus()))
        {
            throw new ServiceException("该岗位画像已停用，请更换后再开始面试");
        }

        // 2. 题目数量（前端不传时取默认值）
        int totalCount = interviewSession.getTotalCount() == null
                ? DEFAULT_QUESTION_COUNT : interviewSession.getTotalCount();
        if (totalCount < MIN_QUESTION_COUNT || totalCount > MAX_QUESTION_COUNT)
        {
            throw new ServiceException("题目数量需在 " + MIN_QUESTION_COUNT + " ~ " + MAX_QUESTION_COUNT + " 之间");
        }

        // 3. 题型：前端多选后以英文逗号拼接，为空表示不限题型
        List<String> questionTypes = splitQuestionTypes(interviewSession.getQuestionType());

        // 4. 从题库抽题（先精确匹配，命中不足时逐级放宽）
        List<QuestionBank> picked = drawQuestions(jobProfile, questionTypes, totalCount);

        // 5. 组装场次：内部字段全部覆盖，不信任前端传参
        interviewSession.setSessionNo(generateSessionNo());
        interviewSession.setUserId(StudentDataScopeUtils.currentUserId());
        interviewSession.setIndustry(jobProfile.getIndustry());
        interviewSession.setJobName(jobProfile.getJobName());
        interviewSession.setDifficulty(jobProfile.getDifficulty());
        interviewSession.setQuestionType(questionTypes.isEmpty() ? null : String.join(",", questionTypes));
        interviewSession.setTotalCount(picked.size());
        interviewSession.setAnsweredCount(0);
        interviewSession.setStatus(STATUS_ONGOING);
        interviewSession.setStartTime(DateUtils.getNowDate());
        interviewSession.setEndTime(null);
        interviewSession.setDuration(0);
        interviewSession.setScore(null);
        interviewSession.setReportId(null);
        interviewSession.setCreateTime(DateUtils.getNowDate());
        int rows = interviewSessionMapper.insertInterviewSession(interviewSession);

        // 6. 抽中的题目落库到场次题目表（question_no 从 1 开始）
        int questionNo = 1;
        for (QuestionBank bank : picked)
        {
            InterviewQuestion question = new InterviewQuestion();
            question.setSessionId(interviewSession.getId());
            question.setUserId(interviewSession.getUserId());
            question.setBankQuestionId(bank.getId());
            question.setQuestionNo(questionNo++);
            question.setQuestionType(bank.getQuestionType());
            question.setQuestionContent(bank.getQuestionContent());
            question.setReferenceAnswer(bank.getReferenceAnswer());
            question.setKeyPoints(bank.getKeyPoints());
            question.setIsFollowUp("0");
            question.setSource(SOURCE_BANK);
            question.setStatus(STATUS_NORMAL);
            question.setCreateTime(DateUtils.getNowDate());
            interviewQuestionMapper.insertInterviewQuestion(question);
        }

        // 7. 题库被使用次数 +1
        questionBankMapper.increaseUseCount(picked.stream().map(QuestionBank::getId).toArray(Long[]::new));

        return rows;
    }

    /**
     * 修改模拟面试场次
     * 
     * @param interviewSession 模拟面试场次
     * @return 结果
     */
    @Override
    public int updateInterviewSession(InterviewSession interviewSession)
    {
        StudentDataScopeUtils.requireManage("模拟面试场次");
        interviewSession.setUpdateTime(DateUtils.getNowDate());
        return interviewSessionMapper.updateInterviewSession(interviewSession);
    }

    /**
     * 作答后回写场次进度（作答提交内部调用）
     * 
     * 已答题数按「有作答记录的题目数」去重统计；全部答完时把场次置为「已完成」，
     * 补上结束时间与面试时长，并建好复盘报告壳、回写 session.report_id 冗余指针。
     * 调用方（InterviewQaServiceImpl.submitAnswer）已校验过场次归属与 status='1'。
     * 
     * @param sessionId 面试场次主键
     * @return 变更后的场次
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public InterviewSession refreshSessionProgress(Long sessionId)
    {
        InterviewSession session = interviewSessionMapper.selectInterviewSessionById(sessionId);
        if (session == null)
        {
            throw new ServiceException("数据不存在或已删除");
        }
        Date now = DateUtils.getNowDate();

        // 题目数 = 本场题目条数；已答题数 = 本场有作答记录的题目数（去重，追问不重复计数）
        InterviewQuestion questionQuery = new InterviewQuestion();
        questionQuery.setSessionId(sessionId);
        int questionCount = interviewQuestionMapper.selectInterviewQuestionList(questionQuery).size();

        InterviewQa qaQuery = new InterviewQa();
        qaQuery.setSessionId(sessionId);
        Set<Long> answeredQuestionIds = new HashSet<>();
        for (InterviewQa qa : interviewQaMapper.selectInterviewQaList(qaQuery))
        {
            answeredQuestionIds.add(qa.getQuestionId());
        }

        InterviewSession update = new InterviewSession();
        update.setId(sessionId);
        update.setAnsweredCount(answeredQuestionIds.size());
        boolean finished = questionCount > 0 && answeredQuestionIds.size() >= questionCount
                && !STATUS_FINISHED.equals(session.getStatus());
        if (finished)
        {
            update.setStatus(STATUS_FINISHED);
            update.setEndTime(now);
            update.setDuration(elapsedSeconds(session.getStartTime(), now));
        }
        update.setUpdateTime(now);
        interviewSessionMapper.updateInterviewSession(update);

        if (finished)
        {
            session.setStatus(STATUS_FINISHED);
            session.setEndTime(now);
            session.setAnsweredCount(answeredQuestionIds.size());
            // 建报告壳；session.report_id 冗余指针由 ensureReportShell 一并回写，这里不用再写一次
            interviewReportService.ensureReportShell(session);
        }
        return interviewSessionMapper.selectInterviewSessionById(sessionId);
    }

    /**
     * 提前结束一场面试（进行中 → 已中断）
     * 
     * 作答页的「提前结束」入口。已答的题目与作答记录都保留，
     * 只是本场不能再继续写；同时补上结束时间与面试时长。
     * 已完成 / 已中断的场次不允许再改，防止把历史结论覆盖掉。
     * 
     * @param id 模拟面试场次主键
     * @return 变更后的场次
     */
    @Override
    public InterviewSession abortInterviewSession(Long id)
    {
        InterviewSession session = StudentDataScopeUtils.checkOwner(
                interviewSessionMapper.selectInterviewSessionById(id), "模拟面试场次");
        if (!STATUS_ONGOING.equals(session.getStatus()))
        {
            throw new ServiceException("只有进行中的面试才能提前结束");
        }
        Date now = DateUtils.getNowDate();
        InterviewSession update = new InterviewSession();
        update.setId(session.getId());
        update.setStatus(STATUS_INTERRUPTED);
        update.setEndTime(now);
        update.setDuration(elapsedSeconds(session.getStartTime(), now));
        update.setUpdateTime(now);
        interviewSessionMapper.updateInterviewSession(update);
        return interviewSessionMapper.selectInterviewSessionById(session.getId());
    }

    /**
     * 计算从开始到结束的秒数，开始时间为空或时钟异常时返回 0
     * 
     * @param startTime 开始时间
     * @param endTime 结束时间
     * @return 秒数
     */
    private int elapsedSeconds(Date startTime, Date endTime)
    {
        if (startTime == null || endTime == null)
        {
            return 0;
        }
        long seconds = (endTime.getTime() - startTime.getTime()) / 1000L;
        if (seconds < 0)
        {
            return 0;
        }
        return (int) Math.min(seconds, Integer.MAX_VALUE);
    }

    /**
     * 批量删除模拟面试场次（级联清理该场的题目 / 问答 / 报告）
     * 
     * 报告以 interview_report.session_id 为权威关联，一并删除，避免留下孤儿数据。
     * 
     * @param ids 需要删除的模拟面试场次主键
     * @return 结果
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public int deleteInterviewSessionByIds(Long[] ids)
    {
        interviewQuestionMapper.deleteInterviewQuestionBySessionIds(ids);
        interviewQaMapper.deleteInterviewQaBySessionIds(ids);
        interviewReportMapper.deleteInterviewReportBySessionIds(ids);
        return interviewSessionMapper.deleteInterviewSessionByIds(ids);
    }

    /**
     * 删除模拟面试场次信息
     * 
     * @param id 模拟面试场次主键
     * @return 结果
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public int deleteInterviewSessionById(Long id)
    {
        return deleteInterviewSessionByIds(new Long[] { id });
    }

    /**
     * 从题库抽题（逐级放宽 + 累积补抽）
     * 
     * 按「行业 + 难度 + 题型」→「行业 + 题型」→「仅题型」三层依次抽，
     * 每层只补抽还差的条数，并把已抽中的题目排除掉，直到凑够 totalCount 或三层抽完。
     * 题型是学生显式选择的，不做放宽；三层合计一道都没有才报错。
     * 题库中符合所选题型的题不足 totalCount 时，按实际抽到的数量建场，不报错。
     * 
     * @param jobProfile 目标岗位画像（提供行业与难度）
     * @param questionTypes 题型集合，空集合表示不限题型
     * @param totalCount 期望抽题数量
     * @return 抽中的题库题目集合
     */
    private List<QuestionBank> drawQuestions(StudentJobProfile jobProfile, List<String> questionTypes, int totalCount)
    {
        List<QuestionBank> picked = new ArrayList<>();
        Set<Long> pickedIds = new HashSet<>();

        // ① 行业 + 难度 + 题型：最精确，优先抽
        collect(picked, pickedIds, questionBankMapper.selectRandomQuestions(
                jobProfile.getIndustry(), jobProfile.getDifficulty(), questionTypes, pickedIds, totalCount));

        // ② 行业 + 题型：把难度不匹配的题补进来
        if (picked.size() < totalCount)
        {
            collect(picked, pickedIds, questionBankMapper.selectRandomQuestions(
                    jobProfile.getIndustry(), null, questionTypes, pickedIds, totalCount - picked.size()));
        }

        // ③ 仅题型：行业也不匹配的题兜底
        if (picked.size() < totalCount)
        {
            collect(picked, pickedIds, questionBankMapper.selectRandomQuestions(
                    null, null, questionTypes, pickedIds, totalCount - picked.size()));
        }

        if (picked.isEmpty())
        {
            throw new ServiceException("题库中没有符合所选题型的题目，请更换题型后重试");
        }
        return picked;
    }

    /**
     * 把本层候选题目按主键去重后并入结果集
     * 
     * @param picked 结果集
     * @param pickedIds 已抽中的主键集合，同时作为下一层的排除条件
     * @param candidates 本层候选题目
     */
    private void collect(List<QuestionBank> picked, Set<Long> pickedIds, List<QuestionBank> candidates)
    {
        for (QuestionBank candidate : candidates)
        {
            if (pickedIds.add(candidate.getId()))
            {
                picked.add(candidate);
            }
        }
    }

    /**
     * 拆分前端传来的多选题型（英文逗号拼接），去空、去重
     * 
     * @param questionType 逗号拼接的题型字符串，可为空
     * @return 题型集合，永不为 null
     */
    private List<String> splitQuestionTypes(String questionType)
    {
        if (StringUtils.isEmpty(questionType))
        {
            return new ArrayList<>();
        }
        return Arrays.stream(questionType.split(","))
                .map(String::trim)
                .filter(StringUtils::isNotEmpty)
                .distinct()
                .collect(Collectors.toList());
    }

    /**
     * 生成场次编号：S + yyyyMMddHHmmss + 3 位随机数
     * 
     * session_no 上有唯一索引，极小概率撞号时重新生成，最多重试 5 次。
     * 
     * @return 场次编号
     */
    private String generateSessionNo()
    {
        Random random = new Random();
        for (int i = 0; i < 5; i++)
        {
            String sessionNo = "S" + DateUtils.dateTimeNow(DateUtils.YYYYMMDDHHMMSS)
                    + String.format("%03d", random.nextInt(1000));
            InterviewSession probe = new InterviewSession();
            probe.setSessionNo(sessionNo);
            if (interviewSessionMapper.selectInterviewSessionList(probe).isEmpty())
            {
                return sessionNo;
            }
        }
        throw new ServiceException("场次编号生成失败，请稍后重试");
    }
}
