package com.ruoyi.interview.domain;

import java.math.BigDecimal;
import java.util.Date;
import com.fasterxml.jackson.annotation.JsonFormat;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.ruoyi.common.annotation.Excel;
import com.ruoyi.common.core.domain.BaseEntity;

/**
 * 面试问答对象 interview_qa
 * 
 * @author tong
 * @date 2026-09-21
 */
public class InterviewQa extends BaseEntity implements UserOwned
{
    private static final long serialVersionUID = 1L;

    /** 主键ID */
    private Long id;

    /** 所属面试场次ID */
    private Long sessionId;

    /** 关联面试题目ID */
    private Long questionId;

    /** 所属学生用户ID */
    private Long userId;

    /** 题干内容(冗余,便于查询) */
    @Excel(name = "题干内容")
    private String questionContent;

    /** 作答内容(文字) */
    @Excel(name = "作答内容")
    private String answerContent;

    /** 作答方式(1文字 2语音 3视频) */
    @Excel(name = "作答方式", readConverterExp = "1=文字,2=语音,3=视频")
    private String answerType;

    /** 语音文件地址 */
    private String audioUrl;

    /** 视频文件地址 */
    private String videoUrl;

    /** 是否追问(0否 1是) */
    @Excel(name = "是否追问", readConverterExp = "0=否,1=是")
    private String isFollowUp;

    /** 上级问答ID(追问时使用) */
    private Long parentId;

    /** 作答时间 */
    @JsonFormat(pattern = "yyyy-MM-dd")
    @Excel(name = "作答时间", width = 30, dateFormat = "yyyy-MM-dd HH:mm:ss")
    private Date answerTime;

    /** 作答耗时(秒) */
    @Excel(name = "作答耗时(秒)")
    private Integer duration;

    /** 本题得分 */
    @Excel(name = "本题得分")
    private BigDecimal score;

    /** AI点评 */
    private String aiComment;

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

    public void setQuestionId(Long questionId) 
    {
        this.questionId = questionId;
    }

    public Long getQuestionId() 
    {
        return questionId;
    }

    public void setUserId(Long userId) 
    {
        this.userId = userId;
    }

    public Long getUserId() 
    {
        return userId;
    }

    public void setQuestionContent(String questionContent) 
    {
        this.questionContent = questionContent;
    }

    public String getQuestionContent() 
    {
        return questionContent;
    }

    public void setAnswerContent(String answerContent) 
    {
        this.answerContent = answerContent;
    }

    public String getAnswerContent() 
    {
        return answerContent;
    }

    public void setAnswerType(String answerType) 
    {
        this.answerType = answerType;
    }

    public String getAnswerType() 
    {
        return answerType;
    }

    public void setAudioUrl(String audioUrl) 
    {
        this.audioUrl = audioUrl;
    }

    public String getAudioUrl() 
    {
        return audioUrl;
    }

    public void setVideoUrl(String videoUrl) 
    {
        this.videoUrl = videoUrl;
    }

    public String getVideoUrl() 
    {
        return videoUrl;
    }

    public void setIsFollowUp(String isFollowUp) 
    {
        this.isFollowUp = isFollowUp;
    }

    public String getIsFollowUp() 
    {
        return isFollowUp;
    }

    public void setParentId(Long parentId) 
    {
        this.parentId = parentId;
    }

    public Long getParentId() 
    {
        return parentId;
    }

    public void setAnswerTime(Date answerTime) 
    {
        this.answerTime = answerTime;
    }

    public Date getAnswerTime() 
    {
        return answerTime;
    }

    public void setDuration(Integer duration) 
    {
        this.duration = duration;
    }

    public Integer getDuration() 
    {
        return duration;
    }

    public void setScore(BigDecimal score) 
    {
        this.score = score;
    }

    public BigDecimal getScore() 
    {
        return score;
    }

    public void setAiComment(String aiComment) 
    {
        this.aiComment = aiComment;
    }

    public String getAiComment() 
    {
        return aiComment;
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
            .append("questionId", getQuestionId())
            .append("userId", getUserId())
            .append("questionContent", getQuestionContent())
            .append("answerContent", getAnswerContent())
            .append("answerType", getAnswerType())
            .append("audioUrl", getAudioUrl())
            .append("videoUrl", getVideoUrl())
            .append("isFollowUp", getIsFollowUp())
            .append("parentId", getParentId())
            .append("answerTime", getAnswerTime())
            .append("duration", getDuration())
            .append("score", getScore())
            .append("aiComment", getAiComment())
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
