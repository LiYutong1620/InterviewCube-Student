package com.ruoyi.interview.service.impl;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;
import com.ruoyi.interview.service.ISmsSender;

/**
 * 开发期 Mock 短信通道
 *
 * <p><b>不真正发短信。</b>验证码已经由 {@code SmsCodeServiceImpl} 写进 Redis，
 * 这里只做一件事：把验证码打到后端日志，联调时从控制台取。
 *
 * <p>激活条件：{@code interview.sms.channel = mock}（不配置时默认就是 mock）。
 *
 * <p>⚠️ 另外支持 {@code interview.sms.mock-expose-code=true} 把验证码**回显在接口响应里**，
 * 前端可以直接展示「开发模式验证码：123456」，省掉翻日志的麻烦。
 * 这个开关**上线前必须改成 false**，详见 {@code application.yml} 里的注释。
 *
 * @author tong
 * @date 2026-09-28
 */
@Component
@ConditionalOnProperty(name = "interview.sms.channel", havingValue = "mock", matchIfMissing = true)
public class DevMockSmsSender implements ISmsSender
{
    private static final Logger log = LoggerFactory.getLogger(DevMockSmsSender.class);

    /**
     * ⚠️ 仅开发期：是否把验证码回显在接口响应里。上线前必须为 false。
     */
    @Value("${interview.sms.mock-expose-code:false}")
    private boolean mockExposeCode;

    @Override
    public String channel()
    {
        return "mock";
    }

    @Override
    public boolean exposeCode()
    {
        return mockExposeCode;
    }

    @Override
    public void send(String phoneNumber, String code, String sceneLabel)
    {
        // 故意用 warn 级别：开发期需要在控制台一眼看到，不需要翻 debug 日志
        log.warn("【开发期 Mock 短信】{}验证码 phone={} code={} —— 未真实发送，仅写 Redis + 打日志",
                sceneLabel, phoneNumber, code);
    }
}
