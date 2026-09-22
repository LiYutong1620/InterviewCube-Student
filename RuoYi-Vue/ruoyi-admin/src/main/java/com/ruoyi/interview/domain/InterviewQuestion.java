package com.ruoyi.interview.domain;

import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.ruoyi.common.annotation.Excel;
import com.ruoyi.common.core.domain.BaseEntity;

/**
 * 面试题目对象 interview_question
 * 
 * @author tong
 * @date 2026-09-21
 */
public class InterviewQuestion extends BaseEntity implements UserOwned
{
    private static final long serialVersionUID = 1L;

    /** 主键ID */
    private Long id;

    /** 所属面试场次ID */
    private Long sessionId;

    /** 所属学生用户ID */
    private Long userId;

    /** 关联题库题目ID(可为空) */
    private Long bankQuestionId;

    /** 题号(第几题) */
    @Excel(name = "题号")
    private Integer questionNo;

    /** 题型(行为面/技术面/HR面/case面) */
    @Excel(name = "题型", readConverterExp = "1=行为面,2=技术面,3=HR面,4=case面")
    private String questionType;

    /** 题干内容 */
    @Excel(name = "题干内容")
    private String questionContent;

    /** 参考答案 */
    private String referenceAnswer;

    /** 关键要点(JSON数组) */
    private String keyPoints;

    /** 是否追问(0否 1是) */
    @Excel(name = "是否追问", readConverterExp = "0=否,1=是")
    private String isFollowUp;

    /** 父题目ID(追问时使用) */
    private Long parentQuestionId;

    /** 来源(1AI生成 2题库抽取 3简历解析) */
    @Excel(name = "来源", readConverterExp = "1=AI生成,2=题库抽取,3=简历解析")
    private String source;

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

    public void setSessionId(Long sessionId) 
    {
        this.sessionId = sessionId;
    }

    public Long getSessionId() 
    {
        return sessionId;
    }

    public void setUserId(Long userId) 
    {
        this.userId = userId;
    }

    public Long getUserId() 
    {
        return userId;
    }

    public void setBankQuestionId(Long bankQuestionId) 
    {
        this.bankQuestionId = bankQuestionId;
    }

    public Long getBankQuestionId() 
    {
        return bankQuestionId;
    }

    public void setQuestionNo(Integer questionNo) 
    {
        this.questionNo = questionNo;
    }

    public Integer getQuestionNo() 
    {
        return questionNo;
    }

    public void setQuestionType(String questionType) 
    {
        this.questionType = questionType;
    }

    public String getQuestionType() 
    {
        return questionType;
    }

    public void setQuestionContent(String questionContent) 
    {
        this.questionContent = questionContent;
    }

    public String getQuestionContent() 
    {
        return questionContent;
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

    public void setIsFollowUp(String isFollowUp) 
    {
        this.isFollowUp = isFollowUp;
    }

    public String getIsFollowUp() 
    {
        return isFollowUp;
    }

    public void setParentQuestionId(Long parentQuestionId) 
    {
        this.parentQuestionId = parentQuestionId;
    }

    public Long getParentQuestionId() 
    {
        return parentQuestionId;
    }

    public void setSource(String source) 
    {
        this.source = source;
    }

    public String getSource() 
    {
        return source;
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
            .append("sessionId", getSessionId())
            .append("userId", getUserId())
            .append("bankQuestionId", getBankQuestionId())
            .append("questionNo", getQuestionNo())
            .append("questionType", getQuestionType())
            .append("questionContent", getQuestionContent())
            .append("referenceAnswer", getReferenceAnswer())
            .append("keyPoints", getKeyPoints())
            .append("isFollowUp", getIsFollowUp())
            .append("parentQuestionId", getParentQuestionId())
            .append("source", getSource())
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
