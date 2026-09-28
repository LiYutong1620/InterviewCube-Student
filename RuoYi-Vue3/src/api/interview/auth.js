import request from '@/utils/request'

/**
 * 学生端认证扩展接口
 * 对应后端 com.ruoyi.interview.controller.StudentAuthController（/interview/auth/**）
 *
 * 说明：
 *  - 这几个接口都是**未登录**调用的，所以 headers 里带 isToken:false；
 *    又因为验证码按钮可能被连点，带 repeatSubmit:false 关掉防重提交拦截
 *    （真正的频控在后端：同手机号同场景 60 秒一次、每日 10 次）。
 *  - 后端错误信息由 utils/request.js 统一弹窗，调用方 catch 里通常不用再提示。
 */

/**
 * 发送短信验证码
 * @param {{phone: string, scene: 'login'|'register'|'resetPwd'}} data
 * @returns 开发期 Mock 通道会额外返回 { mock: true, mockCode: '123456' }
 */
export function sendSmsCode(data) {
  return request({
    url: '/interview/auth/sms/send',
    headers: {
      isToken: false,
      repeatSubmit: false
    },
    method: 'post',
    data: data
  })
}

/**
 * 手机号 + 验证码登录
 * @param {{phone: string, code: string}} data
 * @returns {{ token: string }}
 */
export function smsLogin(data) {
  return request({
    url: '/interview/auth/login/sms',
    headers: {
      isToken: false,
      repeatSubmit: false
    },
    method: 'post',
    data: data
  })
}

/**
 * 手机号 + 验证码注册
 * @param {{phone: string, code: string, password: string, agreed: boolean}} data
 */
export function registerByPhone(data) {
  return request({
    url: '/interview/auth/register/phone',
    headers: {
      isToken: false,
      repeatSubmit: false
    },
    method: 'post',
    data: data
  })
}

/**
 * 手机号 + 验证码重置密码
 * @param {{phone: string, code: string, password: string}} data
 */
export function resetPwdByPhone(data) {
  return request({
    url: '/interview/auth/resetPwd/phone',
    headers: {
      isToken: false,
      repeatSubmit: false
    },
    method: 'post',
    data: data
  })
}
