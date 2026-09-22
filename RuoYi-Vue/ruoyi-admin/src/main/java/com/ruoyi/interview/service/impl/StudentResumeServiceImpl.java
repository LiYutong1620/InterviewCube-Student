package com.ruoyi.interview.service.impl;

import java.util.List;
import com.ruoyi.common.utils.DateUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ruoyi.interview.mapper.StudentResumeMapper;
import com.ruoyi.interview.domain.StudentResume;
import com.ruoyi.interview.service.IStudentResumeService;

/**
 * 学生简历Service业务层处理
 * 
 * @author tong
 * @date 2026-09-21
 */
@Service
public class StudentResumeServiceImpl implements IStudentResumeService 
{
    /** 是否默认：1 是 */
    private static final String IS_DEFAULT_YES = "1";

    @Autowired
    private StudentResumeMapper studentResumeMapper;

    /**
     * 查询学生简历
     * 
     * @param id 学生简历主键
     * @return 学生简历
     */
    @Override
    public StudentResume selectStudentResumeById(Long id)
    {
        return studentResumeMapper.selectStudentResumeById(id);
    }

    /**
     * 查询学生简历列表
     * 
     * @param studentResume 学生简历
     * @return 学生简历
     */
    @Override
    public List<StudentResume> selectStudentResumeList(StudentResume studentResume)
    {
        return studentResumeMapper.selectStudentResumeList(studentResume);
    }

    /**
     * 新增学生简历
     * 
     * @param studentResume 学生简历
     * @return 结果
     */
    @Override
    public int insertStudentResume(StudentResume studentResume)
    {
        studentResume.setCreateTime(DateUtils.getNowDate());
        // 唯一默认：新增为默认时，先取消该学生名下已有的默认
        if (IS_DEFAULT_YES.equals(studentResume.getIsDefault()))
        {
            studentResumeMapper.clearDefaultByUserId(studentResume.getUserId(), null);
        }
        return studentResumeMapper.insertStudentResume(studentResume);
    }

    /**
     * 修改学生简历
     * 
     * @param studentResume 学生简历
     * @return 结果
     */
    @Override
    public int updateStudentResume(StudentResume studentResume)
    {
        studentResume.setUpdateTime(DateUtils.getNowDate());
        // 唯一默认：改为默认时，先取消该学生名下其他默认
        if (IS_DEFAULT_YES.equals(studentResume.getIsDefault()))
        {
            studentResumeMapper.clearDefaultByUserId(resolveOwnerId(studentResume), studentResume.getId());
        }
        return studentResumeMapper.updateStudentResume(studentResume);
    }

    /**
     * 取归属学生ID：修改接口不接收前端传来的 user_id，需要回查数据库
     *
     * @param studentResume 学生简历
     * @return 归属学生用户ID，查不到返回 null
     */
    private Long resolveOwnerId(StudentResume studentResume)
    {
        if (studentResume.getUserId() != null)
        {
            return studentResume.getUserId();
        }
        StudentResume existing = studentResumeMapper.selectStudentResumeById(studentResume.getId());
        return existing == null ? null : existing.getUserId();
    }

    /**
     * 批量删除学生简历
     * 
     * @param ids 需要删除的学生简历主键
     * @return 结果
     */
    @Override
    public int deleteStudentResumeByIds(Long[] ids)
    {
        return studentResumeMapper.deleteStudentResumeByIds(ids);
    }

    /**
     * 删除学生简历信息
     * 
     * @param id 学生简历主键
     * @return 结果
     */
    @Override
    public int deleteStudentResumeById(Long id)
    {
        return studentResumeMapper.deleteStudentResumeById(id);
    }
}
