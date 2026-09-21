-- 菜单 SQL
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('题库题目', '0', '1', 'bank', 'interview/bank/index', 1, 0, 'C', '0', '0', 'interview:bank:list', '#', 'admin', sysdate(), '', null, '题库题目菜单');

-- 按钮父菜单ID
SELECT @parentId := LAST_INSERT_ID();

-- 按钮 SQL
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('题库题目查询', @parentId, '1',  '#', '', 1, 0, 'F', '0', '0', 'interview:bank:query',        '#', 'admin', sysdate(), '', null, '');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('题库题目新增', @parentId, '2',  '#', '', 1, 0, 'F', '0', '0', 'interview:bank:add',          '#', 'admin', sysdate(), '', null, '');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('题库题目修改', @parentId, '3',  '#', '', 1, 0, 'F', '0', '0', 'interview:bank:edit',         '#', 'admin', sysdate(), '', null, '');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('题库题目删除', @parentId, '4',  '#', '', 1, 0, 'F', '0', '0', 'interview:bank:remove',       '#', 'admin', sysdate(), '', null, '');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('题库题目导出', @parentId, '5',  '#', '', 1, 0, 'F', '0', '0', 'interview:bank:export',       '#', 'admin', sysdate(), '', null, '');