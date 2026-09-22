package com.ruoyi.interview.service.impl;

import java.util.List;
import com.ruoyi.common.utils.DateUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.ruoyi.interview.mapper.InterviewQuestionMapper;
import com.ruoyi.interview.domain.InterviewQuestion;
import com.ruoyi.interview.service.IInterviewQuestionService;
import com.ruoyi.interview.utils.StudentDataScopeUtils;

/**
 * 面试题目Service业务层处理
 * 
 * @author tong
 * @date 2026-09-21
 */
@Service
public class InterviewQuestionServiceImpl implements IInterviewQuestionService 
{
    @Autowired
    private InterviewQuestionMapper interviewQuestionMapper;

    /**
     * 查询面试题目
     * 
     * @param id 面试题目主键
     * @return 面试题目
     */
    @Override
    public InterviewQuestion selectInterviewQuestionById(Long id)
    {
        return interviewQuestionMapper.selectInterviewQuestionById(id);
    }

    /**
     * 查询面试题目列表
     * 
     * @param interviewQuestion 面试题目
     * @return 面试题目
     */
    @Override
    public List<InterviewQuestion> selectInterviewQuestionList(InterviewQuestion interviewQuestion)
    {
        return interviewQuestionMapper.selectInterviewQuestionList(interviewQuestion);
    }

    /**
     * 新增面试题目
     * 
     * @param interviewQuestion 面试题目
     * @return 结果
     */
    @Override
    public int insertInterviewQuestion(InterviewQuestion interviewQuestion)
    {
        StudentDataScopeUtils.requireManage("面试题目");
        interviewQuestion.setCreateTime(DateUtils.getNowDate());
        return interviewQuestionMapper.insertInterviewQuestion(interviewQuestion);
    }

    /**
     * 修改面试题目
     * 
     * @param interviewQuestion 面试题目
     * @return 结果
     */
    @Override
    public int updateInterviewQuestion(InterviewQuestion interviewQuestion)
    {
        StudentDataScopeUtils.requireManage("面试题目");
        interviewQuestion.setUpdateTime(DateUtils.getNowDate());
        return interviewQuestionMapper.updateInterviewQuestion(interviewQuestion);
    }

    /**
     * 批量删除面试题目
     * 
     * @param ids 需要删除的面试题目主键
     * @return 结果
     */
    @Override
    public int deleteInterviewQuestionByIds(Long[] ids)
    {
        StudentDataScopeUtils.requireManage("面试题目");
        return interviewQuestionMapper.deleteInterviewQuestionByIds(ids);
    }

    /**
     * 删除面试题目信息
     * 
     * @param id 面试题目主键
     * @return 结果
     */
    @Override
    public int deleteInterviewQuestionById(Long id)
    {
        StudentDataScopeUtils.requireManage("面试题目");
        return interviewQuestionMapper.deleteInterviewQuestionById(id);
    }
}
