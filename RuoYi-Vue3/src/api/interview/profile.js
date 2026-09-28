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

// 标记新手引导已完成（学生档案 guide_status 置为 1）
// 注意：引导状态属于「系统维护字段」，学生档案表单的白名单里不含它，
// 只有引导流程结束时由这里写入。日后后端若提供专用接口，改这一处即可。
export function finishGuide(id) {
  return request({
    url: '/interview/profile',
    method: 'put',
    data: {
      id: id,
      guideStatus: '1'
    }
  })
}
