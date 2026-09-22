package com.ruoyi.interview.service.impl;

import java.util.List;
import com.ruoyi.common.utils.DateUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.ruoyi.interview.mapper.StudentProfileMapper;
import com.ruoyi.interview.domain.StudentProfile;
import com.ruoyi.interview.service.IStudentProfileService;

/**
 * 学生档案Service业务层处理
 * 
 * @author tong
 * @date 2026-09-21
 */
@Service
public class StudentProfileServiceImpl implements IStudentProfileService 
{
    @Autowired
    private StudentProfileMapper studentProfileMapper;

    /**
     * 查询学生档案
     * 
     * @param id 学生档案主键
     * @return 学生档案
     */
    @Override
    public StudentProfile selectStudentProfileById(Long id)
    {
        return studentProfileMapper.selectStudentProfileById(id);
    }

    /**
     * 查询学生档案列表
     * 
     * @param studentProfile 学生档案
     * @return 学生档案
     */
    @Override
    public List<StudentProfile> selectStudentProfileList(StudentProfile studentProfile)
    {
        return studentProfileMapper.selectStudentProfileList(studentProfile);
    }

    /**
     * 新增学生档案
     * 
     * @param studentProfile 学生档案
     * @return 结果
     */
    @Override
    public int insertStudentProfile(StudentProfile studentProfile)
    {
        studentProfile.setCreateTime(DateUtils.getNowDate());
        return studentProfileMapper.insertStudentProfile(studentProfile);
    }

    /**
     * 修改学生档案
     * 
     * @param studentProfile 学生档案
     * @return 结果
     */
    @Override
    public int updateStudentProfile(StudentProfile studentProfile)
    {
        studentProfile.setUpdateTime(DateUtils.getNowDate());
        return studentProfileMapper.updateStudentProfile(studentProfile);
    }

    /**
     * 批量删除学生档案
     * 
     * @param ids 需要删除的学生档案主键
     * @return 结果
     */
    @Override
    public int deleteStudentProfileByIds(Long[] ids)
    {
        return studentProfileMapper.deleteStudentProfileByIds(ids);
    }

    /**
     * 删除学生档案信息
     * 
     * @param id 学生档案主键
     * @return 结果
     */
    @Override
    public int deleteStudentProfileById(Long id)
    {
        return studentProfileMapper.deleteStudentProfileById(id);
    }
}
