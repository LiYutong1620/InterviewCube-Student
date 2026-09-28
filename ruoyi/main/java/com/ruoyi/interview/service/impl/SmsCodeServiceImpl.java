package com.ruoyi.interview.service.impl;

import java.security.SecureRandom;
import java.util.concurrent.TimeUnit;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.common.core.redis.RedisCache;
import com.ruoyi.interview.constant.AuthCodeConstants;
import com.ruoyi.interview.enums.SmsScene;
import com.ruoyi.interview.service.ISmsCodeService;
import com.ruoyi.interview.service.ISmsSender;

/**
 * 短信验证码服务实现
 *
 * <p>Redis key 全部带场景，三个场景（登录 / 注册 / 重置密码）的验证码互不通用。
 *
 * @author tong
 * @date 2026-09-28
 */
@Service
public class SmsCodeServiceImpl implements ISmsCodeService
{
    /**
     * 用 SecureRandom 而不是 Random：验证码只有 6 位数字（10^6 种），
     * 可预测的伪随机序列会让「猜验证码」变得可行。
     */
    private static final SecureRandom RANDOM = new SecureRandom();

    @Autowired
    private RedisCache redisCache;

    @Autowired
    private ISmsSender smsSender;

    @Override
    public String sendCode(String phoneNumber, SmsScene scene)
    {
        String phone = normalizePhone(phoneNumber);

        // 1. 发送间隔频控（同手机号 + 同场景 60 秒一次）
        String limitKey = AuthCodeConstants.SMS_LIMIT_KEY + scene.getCode() + ":" + phone;
        if (Boolean.TRUE.equals(redisCache.hasKey(limitKey)))
        {
            long remain = redisCache.getExpire(limitKey);
            throw new ServiceException("验证码发送过于频繁，请 " + Math.max(remain, 1) + " 秒后再试");
        }

        // 2. 当日发送上限（防「短信轰炸」）
        String dayKey = AuthCodeConstants.SMS_DAY_CNT_KEY + scene.getCode() + ":" + phone;
        Long sentToday = redisCache.redisTemplate.opsForValue().increment(dayKey);
        if (sentToday != null && sentToday == 1L)
        {
            // 首次计数时才设过期，避免每发一次就把过期时间往后推
            redisCache.expire(dayKey, 1, TimeUnit.DAYS);
        }
        if (sentToday != null && sentToday > AuthCodeConstants.SMS_DAILY_SEND_LIMIT)
        {
            throw new ServiceException("该手机号今日验证码发送次数已达上限（"
                    + AuthCodeConstants.SMS_DAILY_SEND_LIMIT + " 次），请明天再试");
        }

        // 3. 生成验证码
        String code = randomCode();

        // 4. 先发后存：发送失败（真实通道抛异常）时不留半截状态，
        //    用户可以直接重试，不会被自己刚设的 60 秒频控挡住
        smsSender.send(phone, code, scene.getLabel());

        // 5. 落 Redis
        redisCache.setCacheObject(codeKey(phone, scene), code,
                AuthCodeConstants.SMS_CODE_EXPIRE_MINUTES, TimeUnit.MINUTES);

        // 6. 打上频控标记
        redisCache.setCacheObject(limitKey, 1,
                AuthCodeConstants.SMS_SEND_INTERVAL_SECONDS, TimeUnit.SECONDS);

        return code;
    }

    @Override
    public void verifyCode(String phoneNumber, SmsScene scene, String code)
    {
        String phone = normalizePhone(phoneNumber);
        if (StringUtils.isEmpty(code))
        {
            throw new ServiceException("请输入验证码");
        }

        String key = codeKey(phone, scene);
        String cached = redisCache.getCacheObject(key);
        if (StringUtils.isEmpty(cached))
        {
            throw new ServiceException("验证码已过期或尚未发送，请重新获取");
        }

        String errKey = AuthCodeConstants.SMS_ERR_CNT_KEY + scene.getCode() + ":" + phone;
        if (!cached.equals(code.trim()))
        {
            Long errCount = redisCache.redisTemplate.opsForValue().increment(errKey);
            if (errCount != null && errCount == 1L)
            {
                // 错误计数与验证码同寿命：验证码过期后计数自动消失
                redisCache.expire(errKey, AuthCodeConstants.SMS_CODE_EXPIRE_MINUTES, TimeUnit.MINUTES);
            }
            if (errCount != null && errCount >= AuthCodeConstants.SMS_MAX_VERIFY_ATTEMPTS)
            {
                // 错太多次直接作废，防止把 6 位数字穷举出来
                redisCache.deleteObject(key);
                redisCache.deleteObject(errKey);
                throw new ServiceException("验证码错误次数过多，请重新获取");
            }
            throw new ServiceException("验证码错误");
        }

        // 校验通过 —— 一次性作废，同一个验证码不能用第二次
        redisCache.deleteObject(key);
        redisCache.deleteObject(errKey);
    }

    /**
     * 验证码 Redis key：前缀 + 场景 + 手机号
     */
    private String codeKey(String phone, SmsScene scene)
    {
        return AuthCodeConstants.SMS_CODE_KEY + scene.getCode() + ":" + phone;
    }

    /**
     * 生成 6 位数字验证码（允许前导 0，所以用字符串拼接而不是取模）
     */
    private String randomCode()
    {
        StringBuilder sb = new StringBuilder(AuthCodeConstants.SMS_CODE_LENGTH);
        for (int i = 0; i < AuthCodeConstants.SMS_CODE_LENGTH; i++)
        {
            sb.append(RANDOM.nextInt(10));
        }
        return sb.toString();
    }

    /**
     * 手机号规范化 + 格式校验
     */
    private String normalizePhone(String phoneNumber)
    {
        String phone = phoneNumber == null ? null : phoneNumber.trim();
        if (StringUtils.isEmpty(phone) || !phone.matches(AuthCodeConstants.PHONE_PATTERN))
        {
            throw new ServiceException("请输入正确的手机号");
        }
        return phone;
    }
}
