package com.ruoyi.interview.domain.dto;

/**
 * 发送短信验证码请求体
 *
 * @author tong
 * @date 2026-09-28
 */
public class SmsSendBody
{
    /** 手机号 */
    private String phone;

    /** 场景：login（登录）/ register（注册）/ resetPwd（重置密码） */
    private String scene;

    public String getPhone()
    {
        return phone;
    }

    public void setPhone(String phone)
    {
        this.phone = phone;
    }

    public String getScene()
    {
        return scene;
    }

    public void setScene(String scene)
    {
        this.scene = scene;
    }
}
