package com.ruoyi.interview.mapper;

import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.ruoyi.interview.domain.StudentJobProfile;

/**
 * 学生岗位画像Mapper接口
 * 
 * @author tong
 * @date 2026-09-21
 */
public interface StudentJobProfileMapper 
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
     * 删除学生岗位画像
     * 
     * @param id 学生岗位画像主键
     * @return 结果
     */
    public int deleteStudentJobProfileById(Long id);

    /**
     * 批量删除学生岗位画像
     * 
     * @param ids 需要删除的数据主键集合
     * @return 结果
     */
    public int deleteStudentJobProfileByIds(Long[] ids);

    /**
     * 唯一默认：把该学生名下除 keepId 外的其他岗位画像取消默认
     *
     * @param userId 学生用户ID
     * @param keepId 需要保留默认的画像主键（新增时传 null）
     * @return 结果
     */
    public int clearDefaultByUserId(@Param("userId") Long userId, @Param("keepId") Long keepId);
}
