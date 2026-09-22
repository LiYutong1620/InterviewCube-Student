package com.ruoyi.interview.service;

import java.util.List;
import com.ruoyi.interview.domain.StudentJobProfile;

/**
 * 学生岗位画像Service接口
 * 
 * @author tong
 * @date 2026-09-21
 */
public interface IStudentJobProfileService 
{
    /**
     * 查询学生岗位画像
     * 
     * @param id 学生岗位画像主键
     * @return 学生岗位画像
     */
    public StudentJobProfile selectStudentJobProfileById(Long id);

    /**
     * 查询学生岗位画像列表
     * 
     * @param studentJobProfile 学生岗位画像
     * @return 学生岗位画像集合
     */
    public List<StudentJobProfile> selectStudentJobProfileList(StudentJobProfile studentJobProfile);

    /**
     * 新增学生岗位画像
     * 
     * @param studentJobProfile 学生岗位画像
     * @return 结果
     */
    public int insertStudentJobProfile(StudentJobProfile studentJobProfile);

    /**
     * 修改学生岗位画像
     * 
     * @param studentJobProfile 学生岗位画像
     * @return 结果
     */
    public int updateStudentJobProfile(StudentJobProfile studentJobProfile);

    /**
     * 批量删除学生岗位画像
     * 
     * @param ids 需要删除的学生岗位画像主键集合
     * @return 结果
     */
    public int deleteStudentJobProfileByIds(Long[] ids);

    /**
     * 删除学生岗位画像信息
     * 
     * @param id 学生岗位画像主键
     * @return 结果
     */
    public int deleteStudentJobProfileById(Long id);
}
