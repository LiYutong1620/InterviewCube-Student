package com.ruoyi.interview.enums;

import com.ruoyi.common.exception.ServiceException;

/**
 * 短信验证码使用场景
 *
 * <p><b>为什么要分场景：</b>验证码在 Redis 里的 key 带场景名，
 * 三个场景的验证码互不通用 —— 否则「登录用」的验证码可以直接拿去重置密码，
 * 等于把改密码的门槛降到了「能收到短信」。
 *
 * @author tong
 * @date 2026-09-28
 */
public enum SmsScene
{
    /** 手机号 + 验证码登录 */
    LOGIN("login", "登录"),

    /** 手机号验证码注册 */
    REGISTER("register", "注册"),

    /** 手机号验证码重置密码 */
    RESET_PWD("resetPwd", "重置密码");

    /** 前端传的场景码，也是 Redis key 里的一段 */
    private final String code;

    /** 场景中文名，用于短信文案与日志 */
    private final String label;

    SmsScene(String code, String label)
    {
        this.code = code;
        this.label = label;
    }

    public String getCode()
    {
        return code;
    }

    public String getLabel()
    {
        return label;
    }

    /**
     * 按场景码解析枚举
     *
     * <p>识别不了就抛异常，**不要**回落到某个默认场景 ——
     * 前端传错场景名时静默当成登录，会掩盖真实问题。
     *
     * @param code 场景码
     * @return 场景枚举
     */
    public static SmsScene of(String code)
    {
        for (SmsScene scene : values())
        {
            if (scene.code.equals(code))
            {
                return scene;
            }
        }
        throw new ServiceException("不支持的验证码场景：" + code);
    }
}
