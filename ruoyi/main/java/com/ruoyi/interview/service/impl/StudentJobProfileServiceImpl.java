package com.ruoyi.interview.service.impl;

import java.util.List;
import com.ruoyi.common.utils.DateUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ruoyi.interview.mapper.StudentJobProfileMapper;
import com.ruoyi.interview.domain.StudentJobProfile;
import com.ruoyi.interview.service.IStudentJobProfileService;

/**
 * 学生岗位画像Service业务层处理
 * 
 * @author tong
 * @date 2026-09-21
 */
@Service
public class StudentJobProfileServiceImpl implements IStudentJobProfileService 
{
    /** 是否默认：1 是 */
    private static final String IS_DEFAULT_YES = "1";

    @Autowired
    private StudentJobProfileMapper studentJobProfileMapper;

    /**
     * 查询学生岗位画像
     * 
     * @param id 学生岗位画像主键
     * @return 学生岗位画像
     */
    @Override
    public StudentJobProfile selectStudentJobProfileById(Long id)
    {
        return studentJobProfileMapper.selectStudentJobProfileById(id);
    }

    /**
     * 查询学生岗位画像列表
     * 
     * @param studentJobProfile 学生岗位画像
     * @return 学生岗位画像
     */
    @Override
    public List<StudentJobProfile> selectStudentJobProfileList(StudentJobProfile studentJobProfile)
    {
        return studentJobProfileMapper.selectStudentJobProfileList(studentJobProfile);
    }

    /**
     * 新增学生岗位画像
     * 
     * @param studentJobProfile 学生岗位画像
     * @return 结果
     */
    @Override
    @Transactional
    public int insertStudentJobProfile(StudentJobProfile studentJobProfile)
    {
        studentJobProfile.setCreateTime(DateUtils.getNowDate());
        // 唯一默认：新增为默认时，先取消该学生名下已有的默认
        if (IS_DEFAULT_YES.equals(studentJobProfile.getIsDefault()))
        {
            studentJobProfileMapper.clearDefaultByUserId(studentJobProfile.getUserId(), null);
        }
        return studentJobProfileMapper.insertStudentJobProfile(studentJobProfile);
    }

    /**
     * 修改学生岗位画像
     * 
     * @param studentJobProfile 学生岗位画像
     * @return 结果
     */
    @Override
    @Transactional
    public int updateStudentJobProfile(StudentJobProfile studentJobProfile)
    {
        studentJobProfile.setUpdateTime(DateUtils.getNowDate());
        // 唯一默认：改为默认时，先取消该学生名下其他默认
        if (IS_DEFAULT_YES.equals(studentJobProfile.getIsDefault()))
        {
            studentJobProfileMapper.clearDefaultByUserId(resolveOwnerId(studentJobProfile), studentJobProfile.getId());
        }
        return studentJobProfileMapper.updateStudentJobProfile(studentJobProfile);
    }

    /**
     * 取归属学生ID：修改接口不接收前端传来的 user_id，需要回查数据库
     *
     * @param studentJobProfile 学生岗位画像
     * @return 归属学生用户ID，查不到返回 null
     */
    private Long resolveOwnerId(StudentJobProfile studentJobProfile)
    {
        if (studentJobProfile.getUserId() != null)
        {
            return studentJobProfile.getUserId();
        }
        StudentJobProfile existing = studentJobProfileMapper.selectStudentJobProfileById(studentJobProfile.getId());
        return existing == null ? null : existing.getUserId();
    }

    /**
     * 批量删除学生岗位画像
     * 
     * @param ids 需要删除的学生岗位画像主键
     * @return 结果
     */
    @Override
    public int deleteStudentJobProfileByIds(Long[] ids)
    {
        return studentJobProfileMapper.deleteStudentJobProfileByIds(ids);
    }

    /**
     * 删除学生岗位画像信息
     * 
     * @param id 学生岗位画像主键
     * @return 结果
     */
    @Override
    public int deleteStudentJobProfileById(Long id)
    {
        return studentJobProfileMapper.deleteStudentJobProfileById(id);
    }
}
