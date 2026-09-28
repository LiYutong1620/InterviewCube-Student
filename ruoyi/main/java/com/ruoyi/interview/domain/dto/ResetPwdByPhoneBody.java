package com.ruoyi.interview.domain.dto;

/**
 * 手机号验证码重置密码请求体
 *
 * @author tong
 * @date 2026-09-28
 */
public class ResetPwdByPhoneBody
{
    /** 手机号 */
    private String phone;

    /** 短信验证码 */
    private String code;

    /** 新密码（明文，服务端负责加密存储） */
    private String password;

    public String getPhone()
    {
        return phone;
    }

    public void setPhone(String phone)
    {
        this.phone = phone;
    }

    public String getCode()
    {
        return code;
    }

    public void setCode(String code)
    {
        this.code = code;
    }

    public String getPassword()
    {
        return password;
    }

    public void setPassword(String password)
    {
        this.password = password;
    }
}
