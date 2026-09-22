package com.ruoyi.interview.domain;

import java.math.BigDecimal;
import java.util.Date;
import com.fasterxml.jackson.annotation.JsonFormat;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.ruoyi.common.annotation.Excel;
import com.ruoyi.common.core.domain.BaseEntity;

/**
 * 模拟面试场次对象 interview_session
 * 
 * @author tong
 * @date 2026-09-21
 */
public class InterviewSession extends BaseEntity implements UserOwned
{
    private static final long serialVersionUID = 1L;

    /** 主键ID */
    private Long id;

    /** 面试场次编号 */
    @Excel(name = "面试场次编号")
    private String sessionNo;

    /** 所属学生用户ID */
    private Long userId;

    /** 关联岗位画像ID */
    private Long jobProfileId;

    /** 行业 */
    @Excel(name = "行业")
    private String industry;

    /** 岗位名称 */
    @Excel(name = "岗位名称")
    private String jobName;

    /** 难度(1初级 2中级 3高级) */
    @Excel(name = "难度", readConverterExp = "1=初级,2=中级,3=高级")
    private String difficulty;

    /** 题型(1行为面 2技术面 3HR面 4case面)，多选时以英文逗号拼接 */
    @Excel(name = "题型")
    private String questionType;

    /** 题目总数 */
    @Excel(name = "题目总数")
    private Integer totalCount;

    /** 已答题数 */
    @Excel(name = "已答题数")
    private Integer answeredCount;

    /** 状态(0未开始 1进行中 2已完成 3已中断) */
    private String status;

    /** 本场总分 */
    @Excel(name = "本场总分")
    private BigDecimal score;

    /** 开始时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @Excel(name = "开始时间", width = 30, dateFormat = "yyyy-MM-dd HH:mm:ss")
    private Date startTime;

    /** 结束时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @Excel(name = "结束时间", width = 30, dateFormat = "yyyy-MM-dd HH:mm:ss")
    private Date endTime;

    /** 面试时长(秒) */
    @Excel(name = "面试时长(秒)")
    private Integer duration;

    /** 关联复盘报告ID */
    private Long reportId;

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

    public void setSessionNo(String sessionNo) 
    {
        this.sessionNo = sessionNo;
    }

    public String getSessionNo() 
    {
        return sessionNo;
    }

    public void setUserId(Long userId) 
    {
        this.userId = userId;
    }

    public Long getUserId() 
    {
        return userId;
    }

    public void setJobProfileId(Long jobProfileId) 
    {
        this.jobProfileId = jobProfileId;
    }

    public Long getJobProfileId() 
    {
        return jobProfileId;
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

    public void setQuestionType(String questionType) 
    {
        this.questionType = questionType;
    }

    public String getQuestionType() 
    {
        return questionType;
    }

    public void setTotalCount(Integer totalCount) 
    {
        this.totalCount = totalCount;
    }

    public Integer getTotalCount() 
    {
        return totalCount;
    }

    public void setAnsweredCount(Integer answeredCount) 
    {
        this.answeredCount = answeredCount;
    }

    public Integer getAnsweredCount() 
    {
        return answeredCount;
    }

    public void setStatus(String status) 
    {
        this.status = status;
    }

    public String getStatus() 
    {
        return status;
    }

    public void setScore(BigDecimal score) 
    {
        this.score = score;
    }

    public BigDecimal getScore() 
    {
        return score;
    }

    public void setStartTime(Date startTime) 
    {
        this.startTime = startTime;
    }

    public Date getStartTime() 
    {
        return startTime;
    }

    public void setEndTime(Date endTime) 
    {
        this.endTime = endTime;
    }

    public Date getEndTime() 
    {
        return endTime;
    }

    public void setDuration(Integer duration) 
    {
        this.duration = duration;
    }

    public Integer getDuration() 
    {
        return duration;
    }

    public void setReportId(Long reportId) 
    {
        this.reportId = reportId;
    }

    public Long getReportId() 
    {
        return reportId;
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
            .append("sessionNo", getSessionNo())
            .append("userId", getUserId())
            .append("jobProfileId", getJobProfileId())
            .append("industry", getIndustry())
            .append("jobName", getJobName())
            .append("difficulty", getDifficulty())
            .append("questionType", getQuestionType())
            .append("totalCount", getTotalCount())
            .append("answeredCount", getAnsweredCount())
            .append("status", getStatus())
            .append("score", getScore())
            .append("startTime", getStartTime())
            .append("endTime", getEndTime())
            .append("duration", getDuration())
            .append("reportId", getReportId())
            .append("delFlag", getDelFlag())
            .append("createBy", getCreateBy())
            .append("createTime", getCreateTime())
            .append("updateBy", getUpdateBy())
            .append("updateTime", getUpdateTime())
            .append("remark", getRemark())
            .toString();
    }
}
