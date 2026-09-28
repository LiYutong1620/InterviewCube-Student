package com.ruoyi.interview.domain.dto;

/**
 * 手机号验证码注册请求体
 *
 * @author tong
 * @date 2026-09-28
 */
public class PhoneRegisterBody
{
    /** 手机号（同时作为登录账号） */
    private String phone;

    /** 短信验证码 */
    private String code;

    /** 登录密码（明文，服务端负责加密存储） */
    private String password;

    /**
     * 是否已勾选同意《用户协议》与《隐私政策》
     *
     * <p>注册是「新建一段法律关系」的动作，所以这里由服务端强制校验，
     * 不能只靠前端把按钮置灰。
     */
    private Boolean agreed;

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

    public Boolean getAgreed()
    {
        return agreed;
    }

    public void setAgreed(Boolean agreed)
    {
        this.agreed = agreed;
    }
}
