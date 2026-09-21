package com.ruoyi.interview.domain;

import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.ruoyi.common.annotation.Excel;
import com.ruoyi.common.core.domain.BaseEntity;

/**
 * 学生岗位画像对象 student_job_profile
 * 
 * @author tong
 * @date 2026-09-21
 */
public class StudentJobProfile extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** 主键ID */
    @Excel(name = "主键ID")
    private Long id;

    /** 所属学生用户ID */
    @Excel(name = "所属学生用户ID")
    private Long userId;

    /** 行业(技术/产品/运营/财务/教师) */
    @Excel(name = "行业(技术/产品/运营/财务/教师)")
    private String industry;

    /** 岗位名称(如Java开发、产品经理) */
    @Excel(name = "岗位名称(如Java开发、产品经理)")
    private String jobName;

    /** 难度(1初级 2中级 3高级) */
    @Excel(name = "难度(1初级 2中级 3高级)")
    private String difficulty;

    /** 目标企业类型(BAT/央企/外企/其他) */
    @Excel(name = "目标企业类型(BAT/央企/外企/其他)")
    private String companyType;

    /** 是否默认(0否 1是) */
    @Excel(name = "是否默认(0否 1是)")
    private String isDefault;

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

    public void setUserId(Long userId) 
    {
        this.userId = userId;
    }

    public Long getUserId() 
    {
        return userId;
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

    public void setIsDefault(String isDefault) 
    {
        this.isDefault = isDefault;
    }

    public String getIsDefault() 
    {
        return isDefault;
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
            .append("userId", getUserId())
            .append("industry", getIndustry())
            .append("jobName", getJobName())
            .append("difficulty", getDifficulty())
            .append("companyType", getCompanyType())
            .append("isDefault", getIsDefault())
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
