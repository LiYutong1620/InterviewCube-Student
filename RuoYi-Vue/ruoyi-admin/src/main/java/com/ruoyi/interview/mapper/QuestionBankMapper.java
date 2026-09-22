package com.ruoyi.interview.mapper;

import java.util.Collection;
import java.util.List;
import org.apache.ibatis.annotations.Param;
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

    /**
     * 随机抽取题目（供「开始面试」抽题使用）
     * 只取状态正常的数据；行业 / 难度 / 题型传空时该条件不参与过滤
     * 
     * @param industry 行业，可为空
     * @param difficulty 难度，可为空
     * @param questionTypes 题型集合，可为空
     * @param excludeIds 需要排除的题目主键集合（逐级补抽时用），可为空
     * @param limit 抽取条数
     * @return 题库题目集合
     */
    public List<QuestionBank> selectRandomQuestions(@Param("industry") String industry,
                                                    @Param("difficulty") String difficulty,
                                                    @Param("questionTypes") List<String> questionTypes,
                                                    @Param("excludeIds") Collection<Long> excludeIds,
                                                    @Param("limit") int limit);

    /**
     * 批量累加题目的被使用次数
     * 
     * @param ids 题库题目主键集合
     * @return 结果
     */
    public int increaseUseCount(@Param("ids") Long[] ids);
}
