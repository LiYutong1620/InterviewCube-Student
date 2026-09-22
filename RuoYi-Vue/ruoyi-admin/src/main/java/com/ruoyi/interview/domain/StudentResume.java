package com.ruoyi.interview.domain;

import java.util.Date;
import com.fasterxml.jackson.annotation.JsonFormat;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.ruoyi.common.annotation.Excel;
import com.ruoyi.common.core.domain.BaseEntity;

/**
 * 学生简历对象 student_resume
 * 
 * @author tong
 * @date 2026-09-21
 */
public class StudentResume extends BaseEntity implements UserOwned
{
    private static final long serialVersionUID = 1L;

    /** 主键ID */
    private Long id;

    /** 所属学生用户ID */
    private Long userId;

    /** 简历名称 */
    @Excel(name = "简历名称")
    private String resumeName;

    /** 简历文件地址 */
    private String fileUrl;

    /** 文件类型(pdf/doc/docx/jpg/png) */
    @Excel(name = "文件类型")
    private String fileType;

    /** 文件大小(字节) */
    private Long fileSize;

    /** 来源(1本地上传 2拍照导入) */
    @Excel(name = "来源", readConverterExp = "1=本地上传,2=拍照导入")
    private String sourceType;

    /** 是否默认(0否 1是) */
    @Excel(name = "是否默认", readConverterExp = "0=否,1=是")
    private String isDefault;

    /** 解析状态(0未解析 1解析中 2解析成功 3解析失败) */
    private String parseStatus;

    /** AI解析结果(JSON) */
    private String parseResult;

    /** 解析完成时间 */
    @JsonFormat(pattern = "yyyy-MM-dd")
    private Date parseTime;

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

    public void setUserId(Long userId) 
    {
        this.userId = userId;
    }

    public Long getUserId() 
    {
        return userId;
    }

    public void setResumeName(String resumeName) 
    {
        this.resumeName = resumeName;
    }

    public String getResumeName() 
    {
        return resumeName;
    }

    public void setFileUrl(String fileUrl) 
    {
        this.fileUrl = fileUrl;
    }

    public String getFileUrl() 
    {
        return fileUrl;
    }

    public void setFileType(String fileType) 
    {
        this.fileType = fileType;
    }

    public String getFileType() 
    {
        return fileType;
    }

    public void setFileSize(Long fileSize) 
    {
        this.fileSize = fileSize;
    }

    public Long getFileSize() 
    {
        return fileSize;
    }

    public void setSourceType(String sourceType) 
    {
        this.sourceType = sourceType;
    }

    public String getSourceType() 
    {
        return sourceType;
    }

    public void setIsDefault(String isDefault) 
    {
        this.isDefault = isDefault;
    }

    public String getIsDefault() 
    {
        return isDefault;
    }

    public void setParseStatus(String parseStatus) 
    {
        this.parseStatus = parseStatus;
    }

    public String getParseStatus() 
    {
        return parseStatus;
    }

    public void setParseResult(String parseResult) 
    {
        this.parseResult = parseResult;
    }

    public String getParseResult() 
    {
        return parseResult;
    }

    public void setParseTime(Date parseTime) 
    {
        this.parseTime = parseTime;
    }

    public Date getParseTime() 
    {
        return parseTime;
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
            .append("resumeName", getResumeName())
            .append("fileUrl", getFileUrl())
            .append("fileType", getFileType())
            .append("fileSize", getFileSize())
            .append("sourceType", getSourceType())
            .append("isDefault", getIsDefault())
            .append("parseStatus", getParseStatus())
            .append("parseResult", getParseResult())
            .append("parseTime", getParseTime())
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
