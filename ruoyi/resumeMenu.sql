-- 菜单 SQL
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('学生简历', '0', '1', 'resume', 'interview/resume/index', 1, 0, 'C', '0', '0', 'interview:resume:list', '#', 'admin', sysdate(), '', null, '学生简历菜单');

-- 按钮父菜单ID
SELECT @parentId := LAST_INSERT_ID();

-- 按钮 SQL
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('学生简历查询', @parentId, '1',  '#', '', 1, 0, 'F', '0', '0', 'interview:resume:query',        '#', 'admin', sysdate(), '', null, '');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('学生简历新增', @parentId, '2',  '#', '', 1, 0, 'F', '0', '0', 'interview:resume:add',          '#', 'admin', sysdate(), '', null, '');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('学生简历修改', @parentId, '3',  '#', '', 1, 0, 'F', '0', '0', 'interview:resume:edit',         '#', 'admin', sysdate(), '', null, '');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('学生简历删除', @parentId, '4',  '#', '', 1, 0, 'F', '0', '0', 'interview:resume:remove',       '#', 'admin', sysdate(), '', null, '');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('学生简历导出', @parentId, '5',  '#', '', 1, 0, 'F', '0', '0', 'interview:resume:export',       '#', 'admin', sysdate(), '', null, '');