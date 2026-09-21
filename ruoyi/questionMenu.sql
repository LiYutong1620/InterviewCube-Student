-- 菜单 SQL
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('面试题目', '0', '1', 'question', 'interview/question/index', 1, 0, 'C', '0', '0', 'interview:question:list', '#', 'admin', sysdate(), '', null, '面试题目菜单');

-- 按钮父菜单ID
SELECT @parentId := LAST_INSERT_ID();

-- 按钮 SQL
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('面试题目查询', @parentId, '1',  '#', '', 1, 0, 'F', '0', '0', 'interview:question:query',        '#', 'admin', sysdate(), '', null, '');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('面试题目新增', @parentId, '2',  '#', '', 1, 0, 'F', '0', '0', 'interview:question:add',          '#', 'admin', sysdate(), '', null, '');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('面试题目修改', @parentId, '3',  '#', '', 1, 0, 'F', '0', '0', 'interview:question:edit',         '#', 'admin', sysdate(), '', null, '');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('面试题目删除', @parentId, '4',  '#', '', 1, 0, 'F', '0', '0', 'interview:question:remove',       '#', 'admin', sysdate(), '', null, '');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('面试题目导出', @parentId, '5',  '#', '', 1, 0, 'F', '0', '0', 'interview:question:export',       '#', 'admin', sysdate(), '', null, '');