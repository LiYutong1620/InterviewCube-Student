package com.ruoyi.interview.domain;

/**
 * 学生数据归属标记接口
 * 实现该接口的实体表示数据归属于某个学生用户，是学生端数据隔离的统一契约
 *
 * @author tong
 * @date 2026-09-22
 */
public interface UserOwned
{
    /**
     * 获取所属学生用户ID
     *
     * @return 所属学生用户ID
     */
    public Long getUserId();

    /**
     * 设置所属学生用户ID
     *
     * @param userId 所属学生用户ID
     */
    public void setUserId(Long userId);
}
