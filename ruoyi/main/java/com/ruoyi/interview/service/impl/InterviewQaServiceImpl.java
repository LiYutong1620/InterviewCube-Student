package com.ruoyi.interview.service.impl;

import java.util.Date;
import java.util.List;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.DateUtils;
import com.ruoyi.common.utils.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ruoyi.interview.domain.InterviewQa;
import com.ruoyi.interview.domain.InterviewQuestion;
import com.ruoyi.interview.domain.InterviewSession;
import com.ruoyi.interview.mapper.InterviewQaMapper;
import com.ruoyi.interview.mapper.InterviewQuestionMapper;
import com.ruoyi.interview.mapper.InterviewSessionMapper;
import com.ruoyi.interview.service.IInterviewQaService;
import com.ruoyi.interview.service.IInterviewSessionService;
import com.ruoyi.interview.utils.StudentDataScopeUtils;

/**
 * 面试问答Service业务层处理
 * 
 * @author tong
 * @date 2026-09-21
 */
@Service
public class InterviewQaServiceImpl implements IInterviewQaService 
{
    /** 场次状态：进行中 */
    private static final String SESSION_STATUS_ONGOING = "1";

    /** 作答方式：文字（阶段一只开放这一种） */
    private static final String ANSWER_TYPE_TEXT = "1";

    /** 是否追问：否 */
    private static final String FOLLOW_UP_NO = "0";

    /** 单题作答内容长度上限（answer_content 是 TEXT，这里收一个更友好的口子） */
    private static final int MAX_ANSWER_LENGTH = 5000;

    @Autowired
    private InterviewQaMapper interviewQaMapper;

    @Autowired
    private InterviewSessionMapper interviewSessionMapper;

    @Autowired
    private InterviewQuestionMapper interviewQuestionMapper;

    @Autowired
    private IInterviewSessionService interviewSessionService;

    /**
     * 查询面试问答
     * 
     * @param id 面试问答主键
     * @return 面试问答
     */
    @Override
    public InterviewQa selectInterviewQaById(Long id)
    {
        return interviewQaMapper.selectInterviewQaById(id);
    }

    /**
     * 查询面试问答列表
     * 
     * @param interviewQa 面试问答
     * @return 面试问答
     */
    @Override
    public List<InterviewQa> selectInterviewQaList(InterviewQa interviewQa)
    {
        return interviewQaMapper.selectInterviewQaList(interviewQa);
    }

    /**
     * 新增面试问答
     * 
     * @param interviewQa 面试问答
     * @return 结果
     */
    @Override
    public int insertInterviewQa(InterviewQa interviewQa)
    {
        StudentDataScopeUtils.requireManage("面试问答");
        interviewQa.setCreateTime(DateUtils.getNowDate());
        return interviewQaMapper.insertInterviewQa(interviewQa);
    }

    /**
     * 修改面试问答
     * 
     * @param interviewQa 面试问答
     * @return 结果
     */
    @Override
    public int updateInterviewQa(InterviewQa interviewQa)
    {
        StudentDataScopeUtils.requireManage("面试问答");
        interviewQa.setUpdateTime(DateUtils.getNowDate());
        return interviewQaMapper.updateInterviewQa(interviewQa);
    }

    /**
     * 提交一道题的作答（作答页唯一写入口）
     * 
     * 白名单写入：只认 answerContent / answerType / duration；
     * user_id 取自场次归属、question_content 取自题目、status 固定正常，其余字段一律不采信前端。
     * 同一场次同一题的「主作答」已存在则覆盖，否则新增；
     * 落库后交给 InterviewSessionServiceImpl.refreshSessionProgress 回写进度（答完即置「已完成」并建报告壳）。
     * 
     * @param interviewQa 作答提交体（sessionId + questionId + 作答内容）
     * @return 落库后的作答记录
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public InterviewQa submitAnswer(InterviewQa interviewQa)
    {
        // 1. 定位目标：场次 + 题目 都必填
        if (interviewQa.getSessionId() == null || interviewQa.getQuestionId() == null)
        {
            throw new ServiceException("请指定要作答的场次与题目");
        }

        // 2. 场次必须存在且属于当前学生
        InterviewSession session = StudentDataScopeUtils.checkOwner(
                interviewSessionMapper.selectInterviewSessionById(interviewQa.getSessionId()), "模拟面试场次");

        // 3. 只有「进行中」的场次允许写入 —— 已完成 / 已中断 / 未开始 一律拒绝（防前端绕过）
        if (!SESSION_STATUS_ONGOING.equals(session.getStatus()))
        {
            throw new ServiceException("本场面试已结束，无法继续作答");
        }

        // 4. 题目必须真实存在，且属于本场（防止拿别场的 questionId 交叉写入）
        InterviewQuestion question = interviewQuestionMapper.selectInterviewQuestionById(interviewQa.getQuestionId());
        if (question == null || !session.getId().equals(question.getSessionId()))
        {
            throw new ServiceException("题目不存在或不属于本场面试");
        }

        // 5. 作答内容：只收文本，阶段一不开放语音 / 视频
        String answerContent = StringUtils.trim(interviewQa.getAnswerContent());
        if (StringUtils.isEmpty(answerContent))
        {
            throw new ServiceException("作答内容不能为空");
        }
        if (answerContent.length() > MAX_ANSWER_LENGTH)
        {
            throw new ServiceException("作答内容过长，请控制在 " + MAX_ANSWER_LENGTH + " 字以内");
        }
        String answerType = StringUtils.isEmpty(interviewQa.getAnswerType())
                ? ANSWER_TYPE_TEXT : interviewQa.getAnswerType();
        if (!ANSWER_TYPE_TEXT.equals(answerType))
        {
            throw new ServiceException("当前仅支持文字作答");
        }

        // 作答时间以服务端为准，不采信前端传值；耗时允许为空
        Date now = DateUtils.getNowDate();
        int duration = interviewQa.getDuration() == null || interviewQa.getDuration() < 0
                ? 0 : interviewQa.getDuration();

        // 6. 同一题的主作答已存在则覆盖，否则新增
        InterviewQa exist = selectMainAnswer(session.getId(), question.getId());
        InterviewQa saved;
        if (exist != null)
        {
            InterviewQa update = new InterviewQa();
            update.setId(exist.getId());
            update.setAnswerContent(answerContent);
            update.setAnswerType(answerType);
            update.setAnswerTime(now);
            update.setDuration(duration);
            update.setUpdateTime(now);
            interviewQaMapper.updateInterviewQa(update);
            saved = interviewQaMapper.selectInterviewQaById(exist.getId());
        }
        else
        {
            InterviewQa insert = new InterviewQa();
            insert.setSessionId(session.getId());
            insert.setQuestionId(question.getId());
            // 归属跟着场次走而不是当前登录用户：后台账号代看时也不会把记录记到自己名下
            insert.setUserId(session.getUserId());
            insert.setQuestionContent(question.getQuestionContent());
            insert.setAnswerContent(answerContent);
            insert.setAnswerType(answerType);
            insert.setAnswerTime(now);
            insert.setDuration(duration);
            insert.setIsFollowUp(FOLLOW_UP_NO);
            insert.setStatus(StudentDataScopeUtils.STATUS_NORMAL);
            insert.setCreateTime(now);
            interviewQaMapper.insertInterviewQa(insert);
            saved = insert;
        }

        // 7. 回写场次进度：全部题目答完 → 置「已完成」+ 写结束时间与面试时长 + 建复盘报告壳
        interviewSessionService.refreshSessionProgress(session.getId());

        return saved;
    }

    /**
     * 取某场次某题的「主作答」（is_follow_up = 0），没有则返回 null
     * 
     * @param sessionId 面试场次主键
     * @param questionId 面试题目主键
     * @return 主作答记录
     */
    private InterviewQa selectMainAnswer(Long sessionId, Long questionId)
    {
        InterviewQa query = new InterviewQa();
        query.setSessionId(sessionId);
        query.setQuestionId(questionId);
        query.setIsFollowUp(FOLLOW_UP_NO);
        List<InterviewQa> list = interviewQaMapper.selectInterviewQaList(query);
        return list.isEmpty() ? null : list.get(0);
    }

    /**
     * 批量删除面试问答
     * 
     * @param ids 需要删除的面试问答主键
     * @return 结果
     */
    @Override
    public int deleteInterviewQaByIds(Long[] ids)
    {
        StudentDataScopeUtils.requireManage("面试问答");
        return interviewQaMapper.deleteInterviewQaByIds(ids);
    }

    /**
     * 删除面试问答信息
     * 
     * @param id 面试问答主键
     * @return 结果
     */
    @Override
    public int deleteInterviewQaById(Long id)
    {
        StudentDataScopeUtils.requireManage("面试问答");
        return interviewQaMapper.deleteInterviewQaById(id);
    }
}
