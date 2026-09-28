package com.ruoyi.interview.service.impl;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.interview.service.ISmsSender;

/**
 * 阿里云短信通道 —— <b>占位实现，尚未接入</b>
 *
 * <p>激活条件：{@code interview.sms.channel = aliyun}
 *
 * <p><b>接入步骤（TODO）：</b>
 * <ol>
 *   <li>{@code ruoyi-admin/pom.xml} 加依赖：{@code com.aliyun:dysmsapi20170525}</li>
 *   <li>配置 {@code access-key-id / access-key-secret / sign-name / template-code}
 *       （建议走环境变量或配置中心，<b>不要</b>把明文密钥提交进仓库）</li>
 *   <li>实现下面的 {@link #send}：调用 SendSms，把验证码按模板参数传进去</li>
 *   <li>发送失败要抛 {@link ServiceException}，让接口层把失败原因原样返回给前端</li>
 * </ol>
 *
 * <p>⚠️ 现在调用会**故意抛异常** —— 避免通道配错了却静默成功，
 * 让人以为短信发出去了，实际用户永远收不到验证码。
 *
 * @author tong
 * @date 2026-09-28
 */
@Component
@ConditionalOnProperty(name = "interview.sms.channel", havingValue = "aliyun")
public class AliyunSmsSender implements ISmsSender
{
    @Value("${interview.sms.aliyun.access-key-id:}")
    private String accessKeyId;

    @Value("${interview.sms.aliyun.access-key-secret:}")
    private String accessKeySecret;

    @Value("${interview.sms.aliyun.sign-name:}")
    private String signName;

    @Value("${interview.sms.aliyun.template-code:}")
    private String templateCode;

    @Override
    public String channel()
    {
        return "aliyun";
    }

    /**
     * 真实通道永远不回显验证码
     */
    @Override
    public boolean exposeCode()
    {
        return false;
    }

    @Override
    public void send(String phoneNumber, String code, String sceneLabel)
    {
        // TODO 接入阿里云 SendSms：
        //   SendSmsRequest request = new SendSmsRequest()
        //       .setPhoneNumbers(phoneNumber)
        //       .setSignName(signName)
        //       .setTemplateCode(templateCode)
        //       .setTemplateParam("{\"code\":\"" + code + "\"}");
        //   SendSmsResponse response = client.sendSms(request);
        //   响应码非 OK 时抛 ServiceException(response.getMessage())
        throw new ServiceException("阿里云短信通道尚未接入（interview.sms.channel=aliyun）："
                + "请先完成 AliyunSmsSender.send() 的实现，或把通道改回 mock");
    }
}
