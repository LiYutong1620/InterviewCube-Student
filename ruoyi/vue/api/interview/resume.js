import request from '@/utils/request'

// 查询学生简历列表
export function listResume(query) {
  return request({
    url: '/interview/resume/list',
    method: 'get',
    params: query
  })
}

// 查询学生简历详细
export function getResume(id) {
  return request({
    url: '/interview/resume/' + id,
    method: 'get'
  })
}

// 新增学生简历
export function addResume(data) {
  return request({
    url: '/interview/resume',
    method: 'post',
    data: data
  })
}

// 修改学生简历
export function updateResume(data) {
  return request({
    url: '/interview/resume',
    method: 'put',
    data: data
  })
}

// 删除学生简历
export function delResume(id) {
  return request({
    url: '/interview/resume/' + id,
    method: 'delete'
  })
}
