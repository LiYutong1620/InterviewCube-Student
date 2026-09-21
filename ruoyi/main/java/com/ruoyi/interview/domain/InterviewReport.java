package com.ruoyi.interview.domain;

import java.math.BigDecimal;
import java.util.Date;
import com.fasterxml.jackson.annotation.JsonFormat;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.ruoyi.common.annotation.Excel;
import com.ruoyi.common.core.domain.BaseEntity;

/**
 * 面试复盘报告对象 interview_report
 * 
 * @author tong
 * @date 2026-09-21
 */
public class InterviewReport extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** 主键ID */
    @Excel(name = "主键ID")
    private Long id;

    /** 报告编号 */
    @Excel(name = "报告编号")
    private String reportNo;

    /** 关联面试场次ID */
    @Excel(name = "关联面试场次ID")
    private Long sessionId;

    /** 所属学生用户ID */
    @Excel(name = "所属学生用户ID")
    private Long userId;

    /** 总分 */
    @Excel(name = "总分")
    private BigDecimal totalScore;

    /** 完整性得分 */
    @Excel(name = "完整性得分")
    private BigDecimal scoreCompleteness;

    /** 逻辑性得分 */
    @Excel(name = "逻辑性得分")
    private BigDecimal scoreLogic;

    /** 流畅度得分 */
    @Excel(name = "流畅度得分")
    private BigDecimal scoreFluency;

    /** 深度得分 */
    @Excel(name = "深度得分")
    private BigDecimal scoreDepth;

    /** 自信度得分 */
    @Excel(name = "自信度得分")
    private BigDecimal scoreConfidence;

    /** 雷达图数据(JSON) */
    private String radarData;

    /** 报告总结 */
    private String summary;

    /** 薄弱点(JSON数组) */
    private String weakPoints;

    /** 改进建议 */
    private String suggest;

    /** PDF报告地址 */
    private String pdfUrl;

    /** 生成状态(0待生成 1生成中 2成功 3失败) */
    @Excel(name = "生成状态(0待生成 1生成中 2成功 3失败)")
    private String generateStatus;

    /** 生成完成时间 */
    @JsonFormat(pattern = "yyyy-MM-dd")
    @Excel(name = "生成完成时间", width = 30, dateFormat = "yyyy-MM-dd")
    private Date generateTime;

    /** 状态(0正常 1停用) */
    @Excel(name = "状态(0正常 1停用)")
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

    public void setReportNo(String reportNo) 
    {
        this.reportNo = reportNo;
    }

    public String getReportNo() 
    {
        return reportNo;
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

    public void setTotalScore(BigDecimal totalScore) 
    {
        this.totalScore = totalScore;
    }

    public BigDecimal getTotalScore() 
    {
        return totalScore;
    }

    public void setScoreCompleteness(BigDecimal scoreCompleteness) 
    {
        this.scoreCompleteness = scoreCompleteness;
    }

    public BigDecimal getScoreCompleteness() 
    {
        return scoreCompleteness;
    }

    public void setScoreLogic(BigDecimal scoreLogic) 
    {
        this.scoreLogic = scoreLogic;
    }

    public BigDecimal getScoreLogic() 
    {
        return scoreLogic;
    }

    public void setScoreFluency(BigDecimal scoreFluency) 
    {
        this.scoreFluency = scoreFluency;
    }

    public BigDecimal getScoreFluency() 
    {
        return scoreFluency;
    }

    public void setScoreDepth(BigDecimal scoreDepth) 
    {
        this.scoreDepth = scoreDepth;
    }

    public BigDecimal getScoreDepth() 
    {
        return scoreDepth;
    }

    public void setScoreConfidence(BigDecimal scoreConfidence) 
    {
        this.scoreConfidence = scoreConfidence;
    }

    public BigDecimal getScoreConfidence() 
    {
        return scoreConfidence;
    }

    public void setRadarData(String radarData) 
    {
        this.radarData = radarData;
    }

    public String getRadarData() 
    {
        return radarData;
    }

    public void setSummary(String summary) 
    {
        this.summary = summary;
    }

    public String getSummary() 
    {
        return summary;
    }

    public void setWeakPoints(String weakPoints) 
    {
        this.weakPoints = weakPoints;
    }

    public String getWeakPoints() 
    {
        return weakPoints;
    }

    public void setSuggest(String suggest) 
    {
        this.suggest = suggest;
    }

    public String getSuggest() 
    {
        return suggest;
    }

    public void setPdfUrl(String pdfUrl) 
    {
        this.pdfUrl = pdfUrl;
    }

    public String getPdfUrl() 
    {
        return pdfUrl;
    }

    public void setGenerateStatus(String generateStatus) 
    {
        this.generateStatus = generateStatus;
    }

    public String getGenerateStatus() 
    {
        return generateStatus;
    }

    public void setGenerateTime(Date generateTime) 
    {
        this.generateTime = generateTime;
    }

    public Date getGenerateTime() 
    {
        return generateTime;
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
            .append("reportNo", getReportNo())
            .append("sessionId", getSessionId())
            .append("userId", getUserId())
            .append("totalScore", getTotalScore())
            .append("scoreCompleteness", getScoreCompleteness())
            .append("scoreLogic", getScoreLogic())
            .append("scoreFluency", getScoreFluency())
            .append("scoreDepth", getScoreDepth())
            .append("scoreConfidence", getScoreConfidence())
            .append("radarData", getRadarData())
            .append("summary", getSummary())
            .append("weakPoints", getWeakPoints())
            .append("suggest", getSuggest())
            .append("pdfUrl", getPdfUrl())
            .append("generateStatus", getGenerateStatus())
            .append("generateTime", getGenerateTime())
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
