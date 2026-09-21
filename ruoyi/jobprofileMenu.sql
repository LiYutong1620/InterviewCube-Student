-- 菜单 SQL
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('学生岗位画像', '0', '1', 'jobprofile', 'interview/jobprofile/index', 1, 0, 'C', '0', '0', 'interview:jobprofile:list', '#', 'admin', sysdate(), '', null, '学生岗位画像菜单');

-- 按钮父菜单ID
SELECT @parentId := LAST_INSERT_ID();

-- 按钮 SQL
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('学生岗位画像查询', @parentId, '1',  '#', '', 1, 0, 'F', '0', '0', 'interview:jobprofile:query',        '#', 'admin', sysdate(), '', null, '');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('学生岗位画像新增', @parentId, '2',  '#', '', 1, 0, 'F', '0', '0', 'interview:jobprofile:add',          '#', 'admin', sysdate(), '', null, '');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('学生岗位画像修改', @parentId, '3',  '#', '', 1, 0, 'F', '0', '0', 'interview:jobprofile:edit',         '#', 'admin', sysdate(), '', null, '');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('学生岗位画像删除', @parentId, '4',  '#', '', 1, 0, 'F', '0', '0', 'interview:jobprofile:remove',       '#', 'admin', sysdate(), '', null, '');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('学生岗位画像导出', @parentId, '5',  '#', '', 1, 0, 'F', '0', '0', 'interview:jobprofile:export',       '#', 'admin', sysdate(), '', null, '');