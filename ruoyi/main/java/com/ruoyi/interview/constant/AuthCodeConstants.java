package com.ruoyi.interview.constant;

/**
 * 学生端认证扩展 —— 短信验证码相关常量
 *
 * <p>Redis key 前缀统一用 {@code interview:sms:} 开头，与若依自带的
 * {@code captcha_codes:} / {@code pwd_err_cnt:} 分开，便于运维按前缀清理。
 *
 * @author tong
 * @date 2026-09-28
 */
public class AuthCodeConstants
{
    /**
     * 短信验证码 redis key 前缀。
     * 完整 key = 前缀 + 场景 + ":" + 手机号，**按场景隔离** ——
     * 否则「登录用」的验证码可以被拿去重置密码。
     */
    public static final String SMS_CODE_KEY = "interview:sms:code:";

    /**
     * 发送频控 key 前缀（同手机号 + 同场景，{@link #SMS_SEND_INTERVAL_SECONDS} 秒内只允许发一次）
     */
    public static final String SMS_LIMIT_KEY = "interview:sms:limit:";

    /**
     * 当日发送计数 key 前缀（同手机号 + 同场景，每日上限 {@link #SMS_DAILY_SEND_LIMIT} 次）
     */
    public static final String SMS_DAY_CNT_KEY = "interview:sms:day:";

    /**
     * 校验错误次数 key 前缀（同手机号 + 同场景，超过 {@link #SMS_MAX_VERIFY_ATTEMPTS} 次验证码作废）
     */
    public static final String SMS_ERR_CNT_KEY = "interview:sms:err:";

    /**
     * 验证码有效期（分钟）
     */
    public static final int SMS_CODE_EXPIRE_MINUTES = 5;

    /**
     * 同一手机号 + 同一场景的发送间隔（秒）
     */
    public static final int SMS_SEND_INTERVAL_SECONDS = 60;

    /**
     * 同一手机号 + 同一场景的每日发送上限（次）
     */
    public static final int SMS_DAILY_SEND_LIMIT = 10;

    /**
     * 同一手机号 + 同一场景的验证码最多校验错误次数，超过则验证码作废、需重新获取
     */
    public static final int SMS_MAX_VERIFY_ATTEMPTS = 5;

    /**
     * 验证码位数
     */
    public static final int SMS_CODE_LENGTH = 6;

    /**
     * 手机号正则（中国大陆）
     */
    public static final String PHONE_PATTERN = "^1[3-9]\\d{9}$";
}
