import request from '@/utils/request'

/** 注销当前登录账号 */
export function cancelAccount() {
  return request({
    url: '/interview/mine/cancel',
    method: 'delete'
  })
}
