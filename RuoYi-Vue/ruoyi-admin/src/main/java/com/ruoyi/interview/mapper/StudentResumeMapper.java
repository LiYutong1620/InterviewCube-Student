package com.ruoyi.interview.mapper;

import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.ruoyi.interview.domain.StudentResume;

/**
 * 学生简历Mapper接口
 * 
 * @author tong
 * @date 2026-09-21
 */
public interface StudentResumeMapper 
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
     * 删除学生简历
     * 
     * @param id 学生简历主键
     * @return 结果
     */
    public int deleteStudentResumeById(Long id);

    /**
     * 批量删除学生简历
     * 
     * @param ids 需要删除的数据主键集合
     * @return 结果
     */
    public int deleteStudentResumeByIds(Long[] ids);

    /**
     * 唯一默认：把该学生名下除 keepId 外的其他简历取消默认
     *
     * @param userId 学生用户ID
     * @param keepId 需要保留默认的简历主键（新增时传 null）
     * @return 结果
     */
    public int clearDefaultByUserId(@Param("userId") Long userId, @Param("keepId") Long keepId);
}
