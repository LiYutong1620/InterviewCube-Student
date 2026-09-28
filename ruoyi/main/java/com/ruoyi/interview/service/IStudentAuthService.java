package com.ruoyi.interview.service;

/**
 * 学生端认证扩展服务 —— 手机号 + 验证码 登录 / 注册 / 重置密码
 *
 * <p>三个动作都复用若依自带的认证组件（{@code TokenService} / {@code SysLoginService} /
 * {@code ISysUserService}），不重复实现 token 生成、密码加密、登录信息记录等逻辑。
 *
 * @author tong
 * @date 2026-09-28
 */
public interface IStudentAuthService
{
    /**
     * 手机号 + 验证码登录
     *
     * @param phone 手机号
     * @param code  短信验证码
     * @return 登录令牌（token）
     */
    String loginByPhone(String phone, String code);

    /**
     * 手机号 + 验证码注册
     *
     * <p>注册出来的账号：{@code user_name} = 手机号、{@code phonenumber} = 手机号，
     * 并自动绑定配置里的学生角色（默认 {@code role_key = student}）——
     * 否则新用户登录后看不到任何菜单。
     *
     * @param phone    手机号
     * @param code     短信验证码
     * @param password 登录密码（明文）
     * @param agreed   是否已勾选同意《用户协议》与《隐私政策》
     */
    void registerByPhone(String phone, String code, String password, Boolean agreed);

    /**
     * 手机号 + 验证码重置密码
     *
     * @param phone       手机号
     * @param code        短信验证码
     * @param newPassword 新密码（明文）
     */
    void resetPwdByPhone(String phone, String code, String newPassword);
}
