-- 菜单 SQL
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('模拟面试场次', '0', '1', 'session', 'interview/session/index', 1, 0, 'C', '0', '0', 'interview:session:list', '#', 'admin', sysdate(), '', null, '模拟面试场次菜单');

-- 按钮父菜单ID
SELECT @parentId := LAST_INSERT_ID();

-- 按钮 SQL
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('模拟面试场次查询', @parentId, '1',  '#', '', 1, 0, 'F', '0', '0', 'interview:session:query',        '#', 'admin', sysdate(), '', null, '');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('模拟面试场次新增', @parentId, '2',  '#', '', 1, 0, 'F', '0', '0', 'interview:session:add',          '#', 'admin', sysdate(), '', null, '');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('模拟面试场次修改', @parentId, '3',  '#', '', 1, 0, 'F', '0', '0', 'interview:session:edit',         '#', 'admin', sysdate(), '', null, '');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('模拟面试场次删除', @parentId, '4',  '#', '', 1, 0, 'F', '0', '0', 'interview:session:remove',       '#', 'admin', sysdate(), '', null, '');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('模拟面试场次导出', @parentId, '5',  '#', '', 1, 0, 'F', '0', '0', 'interview:session:export',       '#', 'admin', sysdate(), '', null, '');