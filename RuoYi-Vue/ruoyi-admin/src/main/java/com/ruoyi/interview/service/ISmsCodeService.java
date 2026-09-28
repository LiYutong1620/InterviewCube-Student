package com.ruoyi.interview.service;

import com.ruoyi.interview.enums.SmsScene;

/**
 * 短信验证码服务
 *
 * <p>负责验证码的生成、存储、频控与校验；验证码存在 Redis 里，5 分钟有效、一次性使用。
 *
 * @author tong
 * @date 2026-09-28
 */
public interface ISmsCodeService
{
    /**
     * 发送验证码（含发送间隔频控 + 当日发送上限）
     *
     * @param phoneNumber 手机号
     * @param scene       使用场景（验证码按场景隔离，见 {@link SmsScene}）
     * @return 本次生成的验证码。
     *         ⚠️ <b>只有开发期 Mock 通道才允许把它回显给前端</b>；
     *         真实短信通道的调用方<b>必须忽略</b>返回值。
     */
    String sendCode(String phoneNumber, SmsScene scene);

    /**
     * 校验验证码
     *
     * <p>校验通过后验证码<b>立即作废</b>（一次性使用）；
     * 连续错 {@code SMS_MAX_VERIFY_ATTEMPTS} 次则验证码作废，需重新获取。
     *
     * @param phoneNumber 手机号
     * @param scene       使用场景
     * @param code        用户填的验证码
     */
    void verifyCode(String phoneNumber, SmsScene scene, String code);
}
