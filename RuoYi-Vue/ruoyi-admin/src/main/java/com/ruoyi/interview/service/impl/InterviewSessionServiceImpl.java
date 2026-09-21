package com.ruoyi.interview.service.impl;

import java.util.List;
import com.ruoyi.common.utils.DateUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.ruoyi.interview.mapper.InterviewSessionMapper;
import com.ruoyi.interview.domain.InterviewSession;
import com.ruoyi.interview.service.IInterviewSessionService;

/**
 * 模拟面试场次Service业务层处理
 * 
 * @author tong
 * @date 2026-09-21
 */
@Service
public class InterviewSessionServiceImpl implements IInterviewSessionService 
{
    @Autowired
    private InterviewSessionMapper interviewSessionMapper;

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
     * 新增模拟面试场次
     * 
     * @param interviewSession 模拟面试场次
     * @return 结果
     */
    @Override
    public int insertInterviewSession(InterviewSession interviewSession)
    {
        interviewSession.setCreateTime(DateUtils.getNowDate());
        return interviewSessionMapper.insertInterviewSession(interviewSession);
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
        interviewSession.setUpdateTime(DateUtils.getNowDate());
        return interviewSessionMapper.updateInterviewSession(interviewSession);
    }

    /**
     * 批量删除模拟面试场次
     * 
     * @param ids 需要删除的模拟面试场次主键
     * @return 结果
     */
    @Override
    public int deleteInterviewSessionByIds(Long[] ids)
    {
        return interviewSessionMapper.deleteInterviewSessionByIds(ids);
    }

    /**
     * 删除模拟面试场次信息
     * 
     * @param id 模拟面试场次主键
     * @return 结果
     */
    @Override
    public int deleteInterviewSessionById(Long id)
    {
        return interviewSessionMapper.deleteInterviewSessionById(id);
    }
}
