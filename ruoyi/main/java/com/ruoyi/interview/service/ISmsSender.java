package com.ruoyi.interview.service;

/**
 * 短信通道
 *
 * <p><b>当前可用实现只有一个：开发期 Mock（{@code DevMockSmsSender}）。</b>
 * 接入真实短信服务时：新增一个 {@code @Component} 实现本接口，
 * 并把配置 {@code interview.sms.channel} 改成对应值即可，
 * 业务代码（{@code SmsCodeServiceImpl} / 控制器）**不需要改**。
 *
 * <p>验证码本身由 {@code SmsCodeServiceImpl} 负责写 Redis；
 * 本接口只负责「把验证码送到用户手机上」这一件事。
 *
 * @author tong
 * @date 2026-09-28
 */
public interface ISmsSender
{
    /**
     * 通道标识（mock / aliyun / ...），用于日志与自检
     */
    String channel();

    /**
     * 是否允许把验证码回显在接口响应里
     *
     * <p>只有开发期 Mock 通道会返回 true。真实通道必须返回 false ——
     * 否则等于把验证码直接送给调用方，验证码就完全失去意义。
     */
    boolean exposeCode();

    /**
     * 发送验证码
     *
     * @param phoneNumber 手机号
     * @param code        验证码
     * @param sceneLabel  场景中文名（用于短信文案，如「登录」）
     */
    void send(String phoneNumber, String code, String sceneLabel);
}
