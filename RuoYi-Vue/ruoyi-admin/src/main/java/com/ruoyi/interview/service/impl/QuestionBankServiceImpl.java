package com.ruoyi.interview.service.impl;

import java.util.List;
import com.ruoyi.common.utils.DateUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.ruoyi.interview.mapper.QuestionBankMapper;
import com.ruoyi.interview.domain.QuestionBank;
import com.ruoyi.interview.service.IQuestionBankService;

/**
 * 题库题目Service业务层处理
 * 
 * @author tong
 * @date 2026-09-21
 */
@Service
public class QuestionBankServiceImpl implements IQuestionBankService 
{
    @Autowired
    private QuestionBankMapper questionBankMapper;

    /**
     * 查询题库题目
     * 
     * @param id 题库题目主键
     * @return 题库题目
     */
    @Override
    public QuestionBank selectQuestionBankById(Long id)
    {
        return questionBankMapper.selectQuestionBankById(id);
    }

    /**
     * 查询题库题目列表
     * 
     * @param questionBank 题库题目
     * @return 题库题目
     */
    @Override
    public List<QuestionBank> selectQuestionBankList(QuestionBank questionBank)
    {
        return questionBankMapper.selectQuestionBankList(questionBank);
    }

    /**
     * 新增题库题目
     * 
     * @param questionBank 题库题目
     * @return 结果
     */
    @Override
    public int insertQuestionBank(QuestionBank questionBank)
    {
        questionBank.setCreateTime(DateUtils.getNowDate());
        return questionBankMapper.insertQuestionBank(questionBank);
    }

    /**
     * 修改题库题目
     * 
     * @param questionBank 题库题目
     * @return 结果
     */
    @Override
    public int updateQuestionBank(QuestionBank questionBank)
    {
        questionBank.setUpdateTime(DateUtils.getNowDate());
        return questionBankMapper.updateQuestionBank(questionBank);
    }

    /**
     * 批量删除题库题目
     * 
     * @param ids 需要删除的题库题目主键
     * @return 结果
     */
    @Override
    public int deleteQuestionBankByIds(Long[] ids)
    {
        return questionBankMapper.deleteQuestionBankByIds(ids);
    }

    /**
     * 删除题库题目信息
     * 
     * @param id 题库题目主键
     * @return 结果
     */
    @Override
    public int deleteQuestionBankById(Long id)
    {
        return questionBankMapper.deleteQuestionBankById(id);
    }
}
