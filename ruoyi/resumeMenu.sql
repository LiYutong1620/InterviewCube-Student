-- 菜单 SQL —— 学生端 · 学生简历
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
values('学生简历', @studentDirId, '1', 'resume', 'interview/resume/index', 1, 0, 'C', '0', '0', 'interview:resume:list', '#', 'admin', sysdate(), '', null, '学生简历菜单');

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