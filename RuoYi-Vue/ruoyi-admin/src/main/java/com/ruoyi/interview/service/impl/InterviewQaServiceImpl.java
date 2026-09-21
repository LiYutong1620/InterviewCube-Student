package com.ruoyi.interview.service.impl;

import java.util.List;
import com.ruoyi.common.utils.DateUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.ruoyi.interview.mapper.InterviewQaMapper;
import com.ruoyi.interview.domain.InterviewQa;
import com.ruoyi.interview.service.IInterviewQaService;

/**
 * 面试问答Service业务层处理
 * 
 * @author tong
 * @date 2026-09-21
 */
@Service
public class InterviewQaServiceImpl implements IInterviewQaService 
{
    @Autowired
    private InterviewQaMapper interviewQaMapper;

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
        interviewQa.setUpdateTime(DateUtils.getNowDate());
        return interviewQaMapper.updateInterviewQa(interviewQa);
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
        return interviewQaMapper.deleteInterviewQaById(id);
    }
}
