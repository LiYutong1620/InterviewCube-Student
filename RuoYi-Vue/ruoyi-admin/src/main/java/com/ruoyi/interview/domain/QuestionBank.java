package com.ruoyi.interview.domain;

import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.ruoyi.common.annotation.Excel;
import com.ruoyi.common.core.domain.BaseEntity;

/**
 * 题库题目对象 question_bank
 * 
 * @author tong
 * @date 2026-09-21
 */
public class QuestionBank extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** 主键ID */
    private Long id;

    /** 题干内容 */
    @Excel(name = "题干内容")
    private String questionContent;

    /** 题型(1行为面 2技术面 3HR面 4case面) */
    @Excel(name = "题型", readConverterExp = "1=行为面,2=技术面,3=HR面,4=case面")
    private String questionType;

    /** 行业(1技术 2产品 3运营 4财务 5教师) */
    @Excel(name = "行业", readConverterExp = "1=技术,2=产品,3=运营,4=财务,5=教师")
    private String industry;

    /** 岗位名称 */
    @Excel(name = "岗位名称")
    private String jobName;

    /** 难度(1初级 2中级 3高级) */
    @Excel(name = "难度", readConverterExp = "1=初级,2=中级,3=高级")
    private String difficulty;

    /** 企业类型(1BAT 2央企 3外企 4其他) */
    @Excel(name = "企业类型", readConverterExp = "1=BAT,2=央企,3=外企,4=其他")
    private String companyType;

    /** 参考答案 */
    private String referenceAnswer;

    /** 关键要点(JSON数组) */
    private String keyPoints;

    /** 标签(逗号分隔) */
    @Excel(name = "标签")
    private String tags;

    /** 来源(1真题 2模拟 3AI生成) */
    @Excel(name = "来源", readConverterExp = "1=真题,2=模拟,3=AI生成")
    private String source;

    /** 被使用次数 */
    @Excel(name = "被使用次数")
    private Integer useCount;

    /** 状态(0正常 1停用) */
    private String status;

    /** 删除标志(0存在 2删除) */
    private String delFlag;

    public void setId(Long id) 
    {
        this.id = id;
    }

    public Long getId() 
    {
        return id;
    }

    public void setQuestionContent(String questionContent) 
    {
        this.questionContent = questionContent;
    }

    public String getQuestionContent() 
    {
        return questionContent;
    }

    public void setQuestionType(String questionType) 
    {
        this.questionType = questionType;
    }

    public String getQuestionType() 
    {
        return questionType;
    }

    public void setIndustry(String industry) 
    {
        this.industry = industry;
    }

    public String getIndustry() 
    {
        return industry;
    }

    public void setJobName(String jobName) 
    {
        this.jobName = jobName;
    }

    public String getJobName() 
    {
        return jobName;
    }

    public void setDifficulty(String difficulty) 
    {
        this.difficulty = difficulty;
    }

    public String getDifficulty() 
    {
        return difficulty;
    }

    public void setCompanyType(String companyType) 
    {
        this.companyType = companyType;
    }

    public String getCompanyType() 
    {
        return companyType;
    }

    public void setReferenceAnswer(String referenceAnswer) 
    {
        this.referenceAnswer = referenceAnswer;
    }

    public String getReferenceAnswer() 
    {
        return referenceAnswer;
    }

    public void setKeyPoints(String keyPoints) 
    {
        this.keyPoints = keyPoints;
    }

    public String getKeyPoints() 
    {
        return keyPoints;
    }

    public void setTags(String tags) 
    {
        this.tags = tags;
    }

    public String getTags() 
    {
        return tags;
    }

    public void setSource(String source) 
    {
        this.source = source;
    }

    public String getSource() 
    {
        return source;
    }

    public void setUseCount(Integer useCount) 
    {
        this.useCount = useCount;
    }

    public Integer getUseCount() 
    {
        return useCount;
    }

    public void setStatus(String status) 
    {
        this.status = status;
    }

    public String getStatus() 
    {
        return status;
    }

    public void setDelFlag(String delFlag) 
    {
        this.delFlag = delFlag;
    }

    public String getDelFlag() 
    {
        return delFlag;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this,ToStringStyle.MULTI_LINE_STYLE)
            .append("id", getId())
            .append("questionContent", getQuestionContent())
            .append("questionType", getQuestionType())
            .append("industry", getIndustry())
            .append("jobName", getJobName())
            .append("difficulty", getDifficulty())
            .append("companyType", getCompanyType())
            .append("referenceAnswer", getReferenceAnswer())
            .append("keyPoints", getKeyPoints())
            .append("tags", getTags())
            .append("source", getSource())
            .append("useCount", getUseCount())
            .append("status", getStatus())
            .append("delFlag", getDelFlag())
            .append("createBy", getCreateBy())
            .append("createTime", getCreateTime())
            .append("updateBy", getUpdateBy())
            .append("updateTime", getUpdateTime())
            .append("remark", getRemark())
            .toString();
    }
}
