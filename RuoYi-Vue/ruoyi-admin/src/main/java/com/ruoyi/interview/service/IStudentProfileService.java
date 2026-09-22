package com.ruoyi.interview.service;

import java.util.List;
import com.ruoyi.interview.domain.StudentProfile;

/**
 * 学生档案Service接口
 * 
 * @author tong
 * @date 2026-09-21
 */
public interface IStudentProfileService 
{
    /**
     * 查询学生档案
     * 
     * @param id 学生档案主键
     * @return 学生档案
     */
    public StudentProfile selectStudentProfileById(Long id);

    /**
     * 查询学生档案列表
     * 
     * @param studentProfile 学生档案
     * @return 学生档案集合
     */
    public List<StudentProfile> selectStudentProfileList(StudentProfile studentProfile);

    /**
     * 新增学生档案
     * 
     * @param studentProfile 学生档案
     * @return 结果
     */
    public int insertStudentProfile(StudentProfile studentProfile);

    /**
     * 修改学生档案
     * 
     * @param studentProfile 学生档案
     * @return 结果
     */
    public int updateStudentProfile(StudentProfile studentProfile);

    /**
     * 批量删除学生档案
     * 
     * @param ids 需要删除的学生档案主键集合
     * @return 结果
     */
    public int deleteStudentProfileByIds(Long[] ids);

    /**
     * 删除学生档案信息
     * 
     * @param id 学生档案主键
     * @return 结果
     */
    public int deleteStudentProfileById(Long id);
}
