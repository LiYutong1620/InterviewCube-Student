package com.ruoyi.interview.mapper;

import java.util.List;
import com.ruoyi.interview.domain.InterviewSession;

/**
 * 模拟面试场次Mapper接口
 * 
 * @author tong
 * @date 2026-09-21
 */
public interface InterviewSessionMapper 
{
    /**
     * 查询模拟面试场次
     * 
     * @param id 模拟面试场次主键
     * @return 模拟面试场次
     */
    public InterviewSession selectInterviewSessionById(Long id);

    /**
     * 查询模拟面试场次列表
     * 
     * @param interviewSession 模拟面试场次
     * @return 模拟面试场次集合
     */
    public List<InterviewSession> selectInterviewSessionList(InterviewSession interviewSession);

    /**
     * 新增模拟面试场次
     * 
     * @param interviewSession 模拟面试场次
     * @return 结果
     */
    public int insertInterviewSession(InterviewSession interviewSession);

    /**
     * 修改模拟面试场次
     * 
     * @param interviewSession 模拟面试场次
     * @return 结果
     */
    public int updateInterviewSession(InterviewSession interviewSession);

    /**
     * 删除模拟面试场次
     * 
     * @param id 模拟面试场次主键
     * @return 结果
     */
    public int deleteInterviewSessionById(Long id);

    /**
     * 批量删除模拟面试场次
     * 
     * @param ids 需要删除的数据主键集合
     * @return 结果
     */
    public int deleteInterviewSessionByIds(Long[] ids);
}
