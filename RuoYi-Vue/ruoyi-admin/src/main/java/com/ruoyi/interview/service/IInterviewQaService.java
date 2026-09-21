package com.ruoyi.interview.service;

import java.util.List;
import com.ruoyi.interview.domain.InterviewQa;

/**
 * 面试问答Service接口
 * 
 * @author tong
 * @date 2026-09-21
 */
public interface IInterviewQaService 
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
     * 批量删除面试问答
     * 
     * @param ids 需要删除的面试问答主键集合
     * @return 结果
     */
    public int deleteInterviewQaByIds(Long[] ids);

    /**
     * 删除面试问答信息
     * 
     * @param id 面试问答主键
     * @return 结果
     */
    public int deleteInterviewQaById(Long id);
}
