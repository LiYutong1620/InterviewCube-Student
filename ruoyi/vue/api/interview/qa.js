import request from '@/utils/request'

// 查询面试问答列表
export function listQa(query) {
  return request({
    url: '/interview/qa/list',
    method: 'get',
    params: query
  })
}

// 查询面试问答详细
export function getQa(id) {
  return request({
    url: '/interview/qa/' + id,
    method: 'get'
  })
}

// 新增面试问答
export function addQa(data) {
  return request({
    url: '/interview/qa',
    method: 'post',
    data: data
  })
}

// 修改面试问答
export function updateQa(data) {
  return request({
    url: '/interview/qa',
    method: 'put',
    data: data
  })
}

// 删除面试问答
export function delQa(id) {
  return request({
    url: '/interview/qa/' + id,
    method: 'delete'
  })
}

// 提交一道题的作答（作答页唯一写入口）
export function submitQa(data) {
  return request({
    url: '/interview/qa/submit',
    method: 'post',
    data: data
  })
}
