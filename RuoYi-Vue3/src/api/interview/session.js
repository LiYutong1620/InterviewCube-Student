import request from '@/utils/request'

// 查询模拟面试场次列表
export function listSession(query) {
  return request({
    url: '/interview/session/list',
    method: 'get',
    params: query
  })
}

// 查询模拟面试场次详细
export function getSession(id) {
  return request({
    url: '/interview/session/' + id,
    method: 'get'
  })
}

// 新增模拟面试场次
export function addSession(data) {
  return request({
    url: '/interview/session',
    method: 'post',
    data: data
  })
}

// 修改模拟面试场次
export function updateSession(data) {
  return request({
    url: '/interview/session',
    method: 'put',
    data: data
  })
}

// 删除模拟面试场次
export function delSession(id) {
  return request({
    url: '/interview/session/' + id,
    method: 'delete'
  })
}
