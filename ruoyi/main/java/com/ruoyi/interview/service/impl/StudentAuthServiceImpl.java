package com.ruoyi.interview.service.impl;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ruoyi.common.constant.Constants;
import com.ruoyi.common.constant.UserConstants;
import com.ruoyi.common.core.domain.entity.SysUser;
import com.ruoyi.common.core.domain.model.LoginUser;
import com.ruoyi.common.enums.UserStatus;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.DateUtils;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.framework.manager.AsyncManager;
import com.ruoyi.framework.manager.factory.AsyncFactory;
import com.ruoyi.framework.web.service.SysLoginService;
import com.ruoyi.framework.web.service.SysPasswordService;
import com.ruoyi.framework.web.service.TokenService;
import com.ruoyi.framework.web.service.UserDetailsServiceImpl;
import com.ruoyi.interview.enums.SmsScene;
import com.ruoyi.interview.mapper.StudentAuthMapper;
import com.ruoyi.interview.service.ISmsCodeService;
import com.ruoyi.interview.service.IStudentAuthService;
import com.ruoyi.system.mapper.SysUserMapper;
import com.ruoyi.system.service.ISysConfigService;
import com.ruoyi.system.service.ISysUserService;

/**
 * 学生端认证扩展服务实现
 *
 * <p><b>设计要点：全部复用若依自带组件，不重复造 token / 加密 / 日志。</b>
 * 本类只负责「验证码 → 用户 → 令牌」这条链路，以及注册时的角色绑定。
 *
 * <p>⚠️ <b>为什么短信登录不调用 {@code UserDetailsServiceImpl.loadUserByUsername}：</b>
 * 那个方法内部会调 {@code SysPasswordService.validate()}，而它要从
 * {@code AuthenticationContextHolder} 里取「本次登录用的密码」来比对 ——
 * 短信登录压根没有密码，会直接 NPE。所以这里改用
 * {@code createLoginUser(SysUser)}（public，只装配权限，不做密码校验），
 * 并把「账号是否停用」的检查自己补上。
 *
 * @author tong
 * @date 2026-09-28
 */
@Service
public class StudentAuthServiceImpl implements IStudentAuthService
{
    private static final Logger log = LoggerFactory.getLogger(StudentAuthServiceImpl.class);

    /**
     * 密码里不允许出现的字符（与前端 utils/passwordRule.js 的 chrtype=0 规则保持一致）
     */
    private static final String ILLEGAL_PASSWORD_CHARS = "<>\"'|\\";

    @Autowired
    private ISmsCodeService smsCodeService;

    @Autowired
    private SysUserMapper sysUserMapper;

    @Autowired
    private StudentAuthMapper studentAuthMapper;

    @Autowired
    private ISysUserService userService;

    @Autowired
    private ISysConfigService configService;

    @Autowired
    private UserDetailsServiceImpl userDetailsService;

    @Autowired
    private TokenService tokenService;

    @Autowired
    private SysLoginService loginService;

    @Autowired
    private SysPasswordService passwordService;

    /**
     * 注册时自动绑定的角色标识（role_key）。
     * 默认 student，可在 application.yml 的 interview.auth.register-role-key 覆盖。
     */
    @Value("${interview.auth.register-role-key:student}")
    private String registerRoleKey;

    @Override
    public String loginByPhone(String phone, String code)
    {
        smsCodeService.verifyCode(phone, SmsScene.LOGIN, code);
        SysUser user = getUserByPhone(phone);
        if (UserStatus.DISABLE.getCode().equals(user.getStatus()))
        {
            throw new ServiceException("该账号已被停用，请联系管理员");
        }
        LoginUser loginUser = (LoginUser) userDetailsService.createLoginUser(user);
        loginService.recordLoginInfo(loginUser.getUserId());
        AsyncManager.me().execute(AsyncFactory.recordLogininfor(user.getUserName(),
                Constants.LOGIN_SUCCESS, "手机号验证码登录成功"));
        return tokenService.createToken(loginUser);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void registerByPhone(String phone, String code, String password, Boolean agreed)
    {
        // 注册是「新建一段法律关系」的动作，协议勾选由服务端强制校验，不能只靠前端把按钮置灰
        if (!Boolean.TRUE.equals(agreed))
        {
            throw new ServiceException("请先阅读并同意《用户协议》与《隐私政策》");
        }
        if (!"true".equals(configService.selectConfigByKey("sys.account.registerUser")))
        {
            throw new ServiceException("当前系统没有开启注册功能");
        }
        smsCodeService.verifyCode(phone, SmsScene.REGISTER, code);
        validatePassword(password);

        String mobile = phone.trim();
        if (sysUserMapper.checkPhoneUnique(mobile) != null)
        {
            throw new ServiceException("该手机号已注册，请直接登录或找回密码");
        }

        // 账号名就用手机号 —— 这样「账号 + 密码登录」用手机号也能进，用户不用记两套东西
        SysUser sysUser = new SysUser();
        sysUser.setUserName(mobile);
        if (!userService.checkUserNameUnique(sysUser))
        {
            throw new ServiceException("该手机号已注册，请直接登录或找回密码");
        }

        Long roleId = studentAuthMapper.selectRoleIdByKey(registerRoleKey);
        if (roleId == null)
        {
            // 故意不静默放过：注册成功但没有任何角色 = 登录后一片空白，
            // 那种问题比「注册直接报错」难查得多
            throw new ServiceException("注册失败：系统未配置角色 " + registerRoleKey + "，请联系管理员");
        }

        sysUser.setNickName("学员" + mobile.substring(mobile.length() - 4));
        sysUser.setPhonenumber(mobile);
        sysUser.setPassword(SecurityUtils.encryptPassword(password));
        sysUser.setPwdUpdateDate(DateUtils.getNowDate());
        sysUser.setStatus(UserConstants.NORMAL);
        sysUser.setCreateBy("register");
        // 走 insertUser 而不是 registerUser：insertUser 会在同一个事务里把
        // sys_user_role 一起写上（见 SysUserServiceImpl.insertUser → insertUserRole）
        sysUser.setRoleIds(new Long[] { roleId });
        userService.insertUser(sysUser);

        log.info("手机号注册成功：userId={} phone={} roleKey={}", sysUser.getUserId(), mobile, registerRoleKey);
        AsyncManager.me().execute(AsyncFactory.recordLogininfor(mobile, Constants.REGISTER, "手机号注册成功"));
    }

    @Override
    public void resetPwdByPhone(String phone, String code, String newPassword)
    {
        smsCodeService.verifyCode(phone, SmsScene.RESET_PWD, code);
        validatePassword(newPassword);
        SysUser user = getUserByPhone(phone);
        userService.resetUserPwd(user.getUserId(), SecurityUtils.encryptPassword(newPassword));
        // 顺手清掉登录失败计数：否则用户刚改完密码，还要等原来那 10 分钟锁定自然过期
        passwordService.clearLoginRecordCache(user.getUserName());
        log.info("手机号重置密码成功：userId={} phone={}", user.getUserId(), phone);
        AsyncManager.me().execute(AsyncFactory.recordLogininfor(user.getUserName(),
                Constants.LOGIN_SUCCESS, "手机号重置密码成功"));
    }

    /**
     * 按手机号取用户（手机号必须已注册）
     *
     * <p>{@code checkPhoneUnique} 只返回 user_id + phonenumber，所以再按 id 取完整用户
     * （需要其中的 user_name / status / roles，后面装配权限要用）。
     */
    private SysUser getUserByPhone(String phoneNumber)
    {
        String phone = phoneNumber == null ? null : phoneNumber.trim();
        if (StringUtils.isEmpty(phone))
        {
            throw new ServiceException("请输入手机号");
        }
        SysUser probe = sysUserMapper.checkPhoneUnique(phone);
        if (probe == null)
        {
            throw new ServiceException("该手机号尚未注册，请先注册");
        }
        SysUser user = userService.selectUserById(probe.getUserId());
        if (user == null)
        {
            throw new ServiceException("该手机号尚未注册，请先注册");
        }
        return user;
    }

    /**
     * 密码强度校验（长度 + 非法字符）
     *
     * <p>长度用的是若依自带的 {@code UserConstants.PASSWORD_MIN/MAX_LENGTH}，
     * 前端另有 chrtype 规则做更细的约束，服务端只兜住「不能为空 / 不能太短 / 不能有危险字符」。
     */
    private void validatePassword(String password)
    {
        if (StringUtils.isEmpty(password))
        {
            throw new ServiceException("密码不能为空");
        }
        if (password.length() < UserConstants.PASSWORD_MIN_LENGTH
                || password.length() > UserConstants.PASSWORD_MAX_LENGTH)
        {
            throw new ServiceException("密码长度必须在 " + UserConstants.PASSWORD_MIN_LENGTH
                    + " 到 " + UserConstants.PASSWORD_MAX_LENGTH + " 个字符之间");
        }
        for (char illegal : ILLEGAL_PASSWORD_CHARS.toCharArray())
        {
            if (password.indexOf(illegal) >= 0)
            {
                throw new ServiceException("密码不能包含非法字符：< > \" ' | \\");
            }
        }
    }
}
