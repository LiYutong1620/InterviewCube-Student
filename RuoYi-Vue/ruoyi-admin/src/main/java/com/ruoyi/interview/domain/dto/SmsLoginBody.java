package com.ruoyi.interview.domain.dto;

/**
 * 手机号 + 验证码登录请求体
 *
 * @author tong
 * @date 2026-09-28
 */
public class SmsLoginBody
{
    /** 手机号 */
    private String phone;

    /** 短信验证码 */
    private String code;

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
}
