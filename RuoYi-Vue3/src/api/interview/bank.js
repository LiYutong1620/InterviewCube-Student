import request from '@/utils/request'

// 查询题库题目列表
export function listBank(query) {
  return request({
    url: '/interview/bank/list',
    method: 'get',
    params: query
  })
}

// 查询题库题目详细
export function getBank(id) {
  return request({
    url: '/interview/bank/' + id,
    method: 'get'
  })
}

// 新增题库题目
export function addBank(data) {
  return request({
    url: '/interview/bank',
    method: 'post',
    data: data
  })
}

// 修改题库题目
export function updateBank(data) {
  return request({
    url: '/interview/bank',
    method: 'put',
    data: data
  })
}

// 删除题库题目
export function delBank(id) {
  return request({
    url: '/interview/bank/' + id,
    method: 'delete'
  })
}
