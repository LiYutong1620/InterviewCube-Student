package com.ruoyi.interview.mapper;

import java.util.List;
import com.ruoyi.interview.domain.InterviewQuestion;

/**
 * 面试题目Mapper接口
 * 
 * @author tong
 * @date 2026-09-21
 */
public interface InterviewQuestionMapper 
{
    /**
     * 查询面试题目
     * 
     * @param id 面试题目主键
     * @return 面试题目
     */
    public InterviewQuestion selectInterviewQuestionById(Long id);

    /**
     * 查询面试题目列表
     * 
     * @param interviewQuestion 面试题目
     * @return 面试题目集合
     */
    public List<InterviewQuestion> selectInterviewQuestionList(InterviewQuestion interviewQuestion);

    /**
     * 新增面试题目
     * 
     * @param interviewQuestion 面试题目
     * @return 结果
     */
    public int insertInterviewQuestion(InterviewQuestion interviewQuestion);

    /**
     * 修改面试题目
     * 
     * @param interviewQuestion 面试题目
     * @return 结果
     */
    public int updateInterviewQuestion(InterviewQuestion interviewQuestion);

    /**
     * 删除面试题目
     * 
     * @param id 面试题目主键
     * @return 结果
     */
    public int deleteInterviewQuestionById(Long id);

    /**
     * 批量删除面试题目
     * 
     * @param ids 需要删除的数据主键集合
     * @return 结果
     */
    public int deleteInterviewQuestionByIds(Long[] ids);

    /**
     * 按所属面试场次批量删除面试题目（删除场次时级联清理）
     * 
     * @param sessionIds 面试场次主键集合
     * @return 结果
     */
    public int deleteInterviewQuestionBySessionIds(Long[] sessionIds);
}
