package com.ruoyi.interview.mapper;

import java.util.List;
import com.ruoyi.interview.domain.QuestionBank;

/**
 * 题库题目Mapper接口
 * 
 * @author tong
 * @date 2026-09-21
 */
public interface QuestionBankMapper 
{
    /**
     * 查询题库题目
     * 
     * @param id 题库题目主键
     * @return 题库题目
     */
    public QuestionBank selectQuestionBankById(Long id);

    /**
     * 查询题库题目列表
     * 
     * @param questionBank 题库题目
     * @return 题库题目集合
     */
    public List<QuestionBank> selectQuestionBankList(QuestionBank questionBank);

    /**
     * 新增题库题目
     * 
     * @param questionBank 题库题目
     * @return 结果
     */
    public int insertQuestionBank(QuestionBank questionBank);

    /**
     * 修改题库题目
     * 
     * @param questionBank 题库题目
     * @return 结果
     */
    public int updateQuestionBank(QuestionBank questionBank);

    /**
     * 删除题库题目
     * 
     * @param id 题库题目主键
     * @return 结果
     */
    public int deleteQuestionBankById(Long id);

    /**
     * 批量删除题库题目
     * 
     * @param ids 需要删除的数据主键集合
     * @return 结果
     */
    public int deleteQuestionBankByIds(Long[] ids);
}
