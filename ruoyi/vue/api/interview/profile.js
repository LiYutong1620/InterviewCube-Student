import request from '@/utils/request'

// 查询学生档案列表
export function listProfile(query) {
  return request({
    url: '/interview/profile/list',
    method: 'get',
    params: query
  })
}

// 查询学生档案详细
export function getProfile(id) {
  return request({
    url: '/interview/profile/' + id,
    method: 'get'
  })
}

// 新增学生档案
export function addProfile(data) {
  return request({
    url: '/interview/profile',
    method: 'post',
    data: data
  })
}

// 修改学生档案
export function updateProfile(data) {
  return request({
    url: '/interview/profile',
    method: 'put',
    data: data
  })
}

// 删除学生档案
export function delProfile(id) {
  return request({
    url: '/interview/profile/' + id,
    method: 'delete'
  })
}
