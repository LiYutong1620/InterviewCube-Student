import request from '@/utils/request'

// 查询面试复盘报告列表
export function listReport(query) {
  return request({
    url: '/interview/report/list',
    method: 'get',
    params: query
  })
}

// 查询面试复盘报告详细
export function getReport(id) {
  return request({
    url: '/interview/report/' + id,
    method: 'get'
  })
}

// 新增面试复盘报告
export function addReport(data) {
  return request({
    url: '/interview/report',
    method: 'post',
    data: data
  })
}

// 修改面试复盘报告
export function updateReport(data) {
  return request({
    url: '/interview/report',
    method: 'put',
    data: data
  })
}

// 删除面试复盘报告
export function delReport(id) {
  return request({
    url: '/interview/report/' + id,
    method: 'delete'
  })
}
