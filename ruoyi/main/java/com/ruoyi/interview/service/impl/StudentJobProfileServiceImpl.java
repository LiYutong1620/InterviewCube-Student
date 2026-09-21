package com.ruoyi.interview.service.impl;

import java.util.List;
import com.ruoyi.common.utils.DateUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
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
    public int insertStudentJobProfile(StudentJobProfile studentJobProfile)
    {
        studentJobProfile.setCreateTime(DateUtils.getNowDate());
        return studentJobProfileMapper.insertStudentJobProfile(studentJobProfile);
    }

    /**
     * 修改学生岗位画像
     * 
     * @param studentJobProfile 学生岗位画像
     * @return 结果
     */
    @Override
    public int updateStudentJobProfile(StudentJobProfile studentJobProfile)
    {
        studentJobProfile.setUpdateTime(DateUtils.getNowDate());
        return studentJobProfileMapper.updateStudentJobProfile(studentJobProfile);
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
