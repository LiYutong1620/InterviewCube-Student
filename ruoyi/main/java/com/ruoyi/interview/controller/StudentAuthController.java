package com.ruoyi.interview.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.annotation.Anonymous;
import com.ruoyi.common.constant.Constants;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.interview.domain.dto.PhoneRegisterBody;
import com.ruoyi.interview.domain.dto.ResetPwdByPhoneBody;
import com.ruoyi.interview.domain.dto.SmsLoginBody;
import com.ruoyi.interview.domain.dto.SmsSendBody;
import com.ruoyi.interview.enums.SmsScene;
import com.ruoyi.interview.service.ISmsCodeService;
import com.ruoyi.interview.service.ISmsSender;
import com.ruoyi.interview.service.IStudentAuthService;

/**
 * 学生端认证扩展 —— 手机号 + 验证码 登录 / 注册 / 重置密码
 *
 * <p>四个接口都是未登录状态调用的，所以整个类打 {@link Anonymous}。
 * 若依的 {@code PermitAllUrlProperties} 会在启动时扫描 {@code @Anonymous}，
 * 把路径交给 {@code SecurityConfig} 放行 —— <b>不需要改 ruoyi-framework</b>，
 * 也就不会给三端合并添新的冲突点。
 *
 * <p>接口路径统一挂在 {@code /interview/auth} 下，和其它学生端业务模块同前缀。
 *
 * @author tong
 * @date 2026-09-28
 */
@Anonymous
@RestController
@RequestMapping("/interview/auth")
public class StudentAuthController extends BaseController
{
    private static final Logger log = LoggerFactory.getLogger(StudentAuthController.class);

    @Autowired
    private ISmsCodeService smsCodeService;

    @Autowired
    private ISmsSender smsSender;

    @Autowired
    private IStudentAuthService studentAuthService;

    /**
     * 发送短信验证码
     *
     * @param body phone + scene（login / register / resetPwd）
     */
    @PostMapping("/sms/send")
    public AjaxResult sendSmsCode(@RequestBody SmsSendBody body)
    {
        SmsScene scene = SmsScene.of(body.getScene());
        String code = smsCodeService.sendCode(body.getPhone(), scene);
        AjaxResult ajax = AjaxResult.success("验证码已发送");
        if (smsSender.exposeCode())
        {
            // ⚠️ 只有开发期 Mock 通道会走到这里（interview.sms.mock-expose-code=true）。
            // 真实通道 exposeCode() 恒为 false，验证码不会出现在响应里。
            ajax.put("mock", true);
            ajax.put("mockCode", code);
            log.warn("开发期 Mock 通道已把验证码回显给前端（当前通道={}）。上线前请把 "
                    + "interview.sms.mock-expose-code 置为 false 并切到真实短信通道。", smsSender.channel());
        }
        return ajax;
    }

    /**
     * 手机号 + 验证码登录
     *
     * @param body phone + code
     */
    @PostMapping("/login/sms")
    public AjaxResult loginByPhone(@RequestBody SmsLoginBody body)
    {
        String token = studentAuthService.loginByPhone(body.getPhone(), body.getCode());
        AjaxResult ajax = AjaxResult.success();
        ajax.put(Constants.TOKEN, token);
        return ajax;
    }

    /**
     * 手机号 + 验证码注册
     *
     * @param body phone + code + password + agreed
     */
    @PostMapping("/register/phone")
    public AjaxResult registerByPhone(@RequestBody PhoneRegisterBody body)
    {
        studentAuthService.registerByPhone(body.getPhone(), body.getCode(), body.getPassword(), body.getAgreed());
        return success("注册成功，请用手机号和密码登录");
    }

    /**
     * 手机号 + 验证码重置密码
     *
     * @param body phone + code + password（新密码）
     */
    @PostMapping("/resetPwd/phone")
    public AjaxResult resetPwdByPhone(@RequestBody ResetPwdByPhoneBody body)
    {
        studentAuthService.resetPwdByPhone(body.getPhone(), body.getCode(), body.getPassword());
        return success("密码已重置，请用新密码登录");
    }
}
