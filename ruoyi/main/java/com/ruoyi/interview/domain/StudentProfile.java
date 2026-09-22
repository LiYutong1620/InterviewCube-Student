package com.ruoyi.interview.domain;

import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.ruoyi.common.annotation.Excel;
import com.ruoyi.common.core.domain.BaseEntity;

/**
 * 学生档案对象 student_profile
 * 
 * @author tong
 * @date 2026-09-21
 */
public class StudentProfile extends BaseEntity implements UserOwned
{
    private static final long serialVersionUID = 1L;

    /** 主键ID */
    private Long id;

    /** 关联若依用户ID(sys_user.user_id) */
    private Long userId;

    /** 昵称 */
    @Excel(name = "昵称")
    private String nickname;

    /** 头像地址 */
    @Excel(name = "头像地址")
    private String avatar;

    /** 真实姓名 */
    @Excel(name = "真实姓名")
    private String realName;

    /** 性别(0男 1女 2未知) */
    @Excel(name = "性别", readConverterExp = "0=男,1=女,2=未知")
    private String gender;

    /** 手机号 */
    @Excel(name = "手机号")
    private String phone;

    /** 邮箱 */
    @Excel(name = "邮箱")
    private String email;

    /** 学校 */
    @Excel(name = "学校")
    private String school;

    /** 专业 */
    @Excel(name = "专业")
    private String major;

    /** 学历(1专科 2本科 3硕士 4博士) */
    @Excel(name = "学历", readConverterExp = "1=专科,2=本科,3=硕士,4=博士")
    private String education;

    /** 毕业年份 */
    @Excel(name = "毕业年份")
    private String graduationYear;

    /** 引导状态(0未完成 1已完成) */
    private String guideStatus;

    /** 当前等级 */
    @Excel(name = "当前等级")
    private String currentLevel;

    /** 当前积分 */
    @Excel(name = "当前积分")
    private Integer currentPoints;

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

    public void setNickname(String nickname) 
    {
        this.nickname = nickname;
    }

    public String getNickname() 
    {
        return nickname;
    }

    public void setAvatar(String avatar) 
    {
        this.avatar = avatar;
    }

    public String getAvatar() 
    {
        return avatar;
    }

    public void setRealName(String realName) 
    {
        this.realName = realName;
    }

    public String getRealName() 
    {
        return realName;
    }

    public void setGender(String gender) 
    {
        this.gender = gender;
    }

    public String getGender() 
    {
        return gender;
    }

    public void setPhone(String phone) 
    {
        this.phone = phone;
    }

    public String getPhone() 
    {
        return phone;
    }

    public void setEmail(String email) 
    {
        this.email = email;
    }

    public String getEmail() 
    {
        return email;
    }

    public void setSchool(String school) 
    {
        this.school = school;
    }

    public String getSchool() 
    {
        return school;
    }

    public void setMajor(String major) 
    {
        this.major = major;
    }

    public String getMajor() 
    {
        return major;
    }

    public void setEducation(String education) 
    {
        this.education = education;
    }

    public String getEducation() 
    {
        return education;
    }

    public void setGraduationYear(String graduationYear) 
    {
        this.graduationYear = graduationYear;
    }

    public String getGraduationYear() 
    {
        return graduationYear;
    }

    public void setGuideStatus(String guideStatus) 
    {
        this.guideStatus = guideStatus;
    }

    public String getGuideStatus() 
    {
        return guideStatus;
    }

    public void setCurrentLevel(String currentLevel) 
    {
        this.currentLevel = currentLevel;
    }

    public String getCurrentLevel() 
    {
        return currentLevel;
    }

    public void setCurrentPoints(Integer currentPoints) 
    {
        this.currentPoints = currentPoints;
    }

    public Integer getCurrentPoints() 
    {
        return currentPoints;
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
            .append("nickname", getNickname())
            .append("avatar", getAvatar())
            .append("realName", getRealName())
            .append("gender", getGender())
            .append("phone", getPhone())
            .append("email", getEmail())
            .append("school", getSchool())
            .append("major", getMajor())
            .append("education", getEducation())
            .append("graduationYear", getGraduationYear())
            .append("guideStatus", getGuideStatus())
            .append("currentLevel", getCurrentLevel())
            .append("currentPoints", getCurrentPoints())
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
