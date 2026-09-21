-- 菜单 SQL
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('学生档案', '0', '1', 'profile', 'interview/profile/index', 1, 0, 'C', '0', '0', 'interview:profile:list', '#', 'admin', sysdate(), '', null, '学生档案菜单');

-- 按钮父菜单ID
SELECT @parentId := LAST_INSERT_ID();

-- 按钮 SQL
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('学生档案查询', @parentId, '1',  '#', '', 1, 0, 'F', '0', '0', 'interview:profile:query',        '#', 'admin', sysdate(), '', null, '');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('学生档案新增', @parentId, '2',  '#', '', 1, 0, 'F', '0', '0', 'interview:profile:add',          '#', 'admin', sysdate(), '', null, '');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('学生档案修改', @parentId, '3',  '#', '', 1, 0, 'F', '0', '0', 'interview:profile:edit',         '#', 'admin', sysdate(), '', null, '');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('学生档案删除', @parentId, '4',  '#', '', 1, 0, 'F', '0', '0', 'interview:profile:remove',       '#', 'admin', sysdate(), '', null, '');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('学生档案导出', @parentId, '5',  '#', '', 1, 0, 'F', '0', '0', 'interview:profile:export',       '#', 'admin', sysdate(), '', null, '');