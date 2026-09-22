package com.ruoyi.interview.mapper;

import java.util.List;
import com.ruoyi.interview.domain.InterviewReport;

/**
 * 面试复盘报告Mapper接口
 * 
 * @author tong
 * @date 2026-09-21
 */
public interface InterviewReportMapper 
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
     * 删除面试复盘报告
     * 
     * @param id 面试复盘报告主键
     * @return 结果
     */
    public int deleteInterviewReportById(Long id);

    /**
     * 批量删除面试复盘报告
     * 
     * @param ids 需要删除的数据主键集合
     * @return 结果
     */
    public int deleteInterviewReportByIds(Long[] ids);

    /**
     * 按所属面试场次批量删除面试复盘报告（删除场次时级联清理）
     * 
     * @param sessionIds 面试场次主键集合
     * @return 结果
     */
    public int deleteInterviewReportBySessionIds(Long[] sessionIds);
}
