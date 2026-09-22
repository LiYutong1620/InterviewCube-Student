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

// 手工填分：只传 sessionId + 五个维度 + 总结 / 薄弱点 / 改进建议，总分由后端按五维平均算
// 阶段一的演示入口，阶段三由 AI 自动评分替换
export function fillReport(data) {
  return request({
    url: '/interview/report/fill',
    method: 'post',
    data: data
  })
}
