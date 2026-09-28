package com.ruoyi.interview.mapper;

import org.apache.ibatis.annotations.Param;

/**
 * 学生端认证扩展 —— 直查若依基础表的最小 SQL
 *
 * <p><b>为什么不用 {@code ISysRoleService}：</b>学生端是三个端（学生端 / 后台端 / 企业端）
 * 之一，公共层（{@code ruoyi-common} / {@code ruoyi-framework} / {@code ruoyi-system}）
 * 的任何改动都会变成三端合并时的冲突点。这里只读不写，放在学生端自己的包里最干净。
 *
 * <p>（用户查询没有另开 SQL：直接复用若依自带的
 * {@code SysUserMapper.checkPhoneUnique} + {@code ISysUserService.selectUserById}。）
 *
 * @author tong
 * @date 2026-09-28
 */
public interface StudentAuthMapper
{
    /**
     * 按角色标识查角色 ID（注册时用来把新用户绑到学生角色上）
     *
     * @param roleKey 角色标识，如 {@code student}
     * @return 角色 ID；不存在返回 {@code null}
     */
    public Long selectRoleIdByKey(@Param("roleKey") String roleKey);
}
