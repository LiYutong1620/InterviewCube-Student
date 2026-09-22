package com.ruoyi.interview.mapper;

import java.util.List;
import com.ruoyi.interview.domain.InterviewQa;

/**
 * 面试问答Mapper接口
 * 
 * @author tong
 * @date 2026-09-21
 */
public interface InterviewQaMapper 
{
    /**
     * 查询面试问答
     * 
     * @param id 面试问答主键
     * @return 面试问答
     */
    public InterviewQa selectInterviewQaById(Long id);

    /**
     * 查询面试问答列表
     * 
     * @param interviewQa 面试问答
     * @return 面试问答集合
     */
    public List<InterviewQa> selectInterviewQaList(InterviewQa interviewQa);

    /**
     * 新增面试问答
     * 
     * @param interviewQa 面试问答
     * @return 结果
     */
    public int insertInterviewQa(InterviewQa interviewQa);

    /**
     * 修改面试问答
     * 
     * @param interviewQa 面试问答
     * @return 结果
     */
    public int updateInterviewQa(InterviewQa interviewQa);

    /**
     * 删除面试问答
     * 
     * @param id 面试问答主键
     * @return 结果
     */
    public int deleteInterviewQaById(Long id);

    /**
     * 批量删除面试问答
     * 
     * @param ids 需要删除的数据主键集合
     * @return 结果
     */
    public int deleteInterviewQaByIds(Long[] ids);

    /**
     * 按所属面试场次批量删除面试问答（删除场次时级联清理）
     * 
     * @param sessionIds 面试场次主键集合
     * @return 结果
     */
    public int deleteInterviewQaBySessionIds(Long[] sessionIds);
}
