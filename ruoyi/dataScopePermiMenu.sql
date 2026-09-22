-- 菜单 SQL —— 学生端 · 数据隔离权限点
-- 用途：把 interview:data:all 注册为可分配的权限按钮，供后台端在「角色管理」里授予非超管角色。
-- 说明：超级管理员无需分配（若依自动授予 *:*:*，天然通过）；
--       「学生」角色不要勾选此项，否则会看到全部学生的数据。
-- 注意：用于干净库；本脚本自身是幂等的。

-- 1. 确保「学生端」目录存在
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '学生端', 0, 1, 'student', null, 1, 0, 'M', '0', '0', null, 'user', 'admin', sysdate(), '', null, '学生端目录'
from dual
where not exists (select 1 from sys_menu where path = 'student' and menu_type = 'M' and parent_id = 0);

-- 2. 取「学生端」目录ID
set @studentDirId = (select menu_id from sys_menu where path = 'student' and menu_type = 'M' and parent_id = 0 limit 1);

-- 3. 注册权限按钮（幂等）
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '查看全部学生数据', @studentDirId, 9, '#', '', 1, 0, 'F', '0', '0', 'interview:data:all', '#', 'admin', sysdate(), '', null, '拥有此权限可查看与操作全部学生数据，勿分配给「学生」角色'
from dual
where not exists (select 1 from sys_menu where perms = 'interview:data:all');
