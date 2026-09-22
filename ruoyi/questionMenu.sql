-- 菜单 SQL —— 学生端 · 面试题目
-- 说明：本脚本可独立运行；「学生端」目录不存在时会自动创建。
-- 注意：用于干净库；重复执行会产生重复菜单记录。

-- 1. 确保「学生端」目录存在
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '学生端', 0, 1, 'student', null, 1, 0, 'M', '0', '0', null, 'user', 'admin', sysdate(), '', null, '学生端目录'
from dual
where not exists (select 1 from sys_menu where path = 'student' and menu_type = 'M' and parent_id = 0);

-- 2. 取「学生端」目录ID（供本文件后续语句使用）
set @studentDirId = (select menu_id from sys_menu where path = 'student' and menu_type = 'M' and parent_id = 0 limit 1);

-- 3. 菜单 SQL
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('面试题目', @studentDirId, '1', 'question', 'interview/question/index', 1, 0, 'C', '0', '0', 'interview:question:list', '#', 'admin', sysdate(), '', null, '面试题目菜单');

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