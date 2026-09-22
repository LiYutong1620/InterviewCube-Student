package com.ruoyi.interview.service;

import java.util.List;
import com.ruoyi.interview.domain.StudentResume;

/**
 * 学生简历Service接口
 * 
 * @author tong
 * @date 2026-09-21
 */
public interface IStudentResumeService 
{
    /**
     * 查询学生简历
     * 
     * @param id 学生简历主键
     * @return 学生简历
     */
    public StudentResume selectStudentResumeById(Long id);

    /**
     * 查询学生简历列表
     * 
     * @param studentResume 学生简历
     * @return 学生简历集合
     */
    public List<StudentResume> selectStudentResumeList(StudentResume studentResume);

    /**
     * 新增学生简历
     * 
     * @param studentResume 学生简历
     * @return 结果
     */
    public int insertStudentResume(StudentResume studentResume);

    /**
     * 修改学生简历
     * 
     * @param studentResume 学生简历
     * @return 结果
     */
    public int updateStudentResume(StudentResume studentResume);

    /**
     * 批量删除学生简历
     * 
     * @param ids 需要删除的学生简历主键集合
     * @return 结果
     */
    public int deleteStudentResumeByIds(Long[] ids);

    /**
     * 删除学生简历信息
     * 
     * @param id 学生简历主键
     * @return 结果
     */
    public int deleteStudentResumeById(Long id);
}
