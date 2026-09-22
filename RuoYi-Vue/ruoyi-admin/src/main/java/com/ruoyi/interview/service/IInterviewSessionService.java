package com.ruoyi.interview.service;

import java.util.List;
import com.ruoyi.interview.domain.InterviewSession;

/**
 * 模拟面试场次Service接口
 * 
 * @author tong
 * @date 2026-09-21
 */
public interface IInterviewSessionService 
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
     * 作答后回写场次进度（作答提交内部调用）
     * 
     * 已答题数按「有作答记录的题目数」去重统计；全部答完时把场次置为「已完成」，
     * 补上结束时间与面试时长，并建好复盘报告壳、回写 session.report_id 冗余指针。
     * 调用方（InterviewQaServiceImpl.submitAnswer）已校验过场次归属与 status='1'。
     * 
     * @param sessionId 面试场次主键
     * @return 变更后的场次
     */
    public InterviewSession refreshSessionProgress(Long sessionId);

    /**
     * 提前结束一场面试（进行中 → 已中断）
     * 
     * 已答的题目与作答记录都保留，只是本场不能再继续写；写结束时间与面试时长。
     * 
     * @param id 模拟面试场次主键
     * @return 变更后的场次
     */
    public InterviewSession abortInterviewSession(Long id);

    /**
     * 批量删除模拟面试场次
     * 
     * @param ids 需要删除的模拟面试场次主键集合
     * @return 结果
     */
    public int deleteInterviewSessionByIds(Long[] ids);

    /**
     * 删除模拟面试场次信息
     * 
     * @param id 模拟面试场次主键
     * @return 结果
     */
    public int deleteInterviewSessionById(Long id);
}
