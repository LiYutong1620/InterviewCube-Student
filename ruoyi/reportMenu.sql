-- 菜单 SQL
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('面试复盘报告', '0', '1', 'report', 'interview/report/index', 1, 0, 'C', '0', '0', 'interview:report:list', '#', 'admin', sysdate(), '', null, '面试复盘报告菜单');

-- 按钮父菜单ID
SELECT @parentId := LAST_INSERT_ID();

-- 按钮 SQL
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('面试复盘报告查询', @parentId, '1',  '#', '', 1, 0, 'F', '0', '0', 'interview:report:query',        '#', 'admin', sysdate(), '', null, '');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('面试复盘报告新增', @parentId, '2',  '#', '', 1, 0, 'F', '0', '0', 'interview:report:add',          '#', 'admin', sysdate(), '', null, '');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('面试复盘报告修改', @parentId, '3',  '#', '', 1, 0, 'F', '0', '0', 'interview:report:edit',         '#', 'admin', sysdate(), '', null, '');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('面试复盘报告删除', @parentId, '4',  '#', '', 1, 0, 'F', '0', '0', 'interview:report:remove',       '#', 'admin', sysdate(), '', null, '');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('面试复盘报告导出', @parentId, '5',  '#', '', 1, 0, 'F', '0', '0', 'interview:report:export',       '#', 'admin', sysdate(), '', null, '');