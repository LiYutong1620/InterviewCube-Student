import request from '@/utils/request'

// 查询学生岗位画像列表
export function listJobprofile(query) {
  return request({
    url: '/interview/jobprofile/list',
    method: 'get',
    params: query
  })
}

// 查询学生岗位画像详细
export function getJobprofile(id) {
  return request({
    url: '/interview/jobprofile/' + id,
    method: 'get'
  })
}

// 新增学生岗位画像
export function addJobprofile(data) {
  return request({
    url: '/interview/jobprofile',
    method: 'post',
    data: data
  })
}

// 修改学生岗位画像
export function updateJobprofile(data) {
  return request({
    url: '/interview/jobprofile',
    method: 'put',
    data: data
  })
}

// 删除学生岗位画像
export function delJobprofile(id) {
  return request({
    url: '/interview/jobprofile/' + id,
    method: 'delete'
  })
}
