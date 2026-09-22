-- ============================================================
-- 补丁：个人中心菜单 + 协议参数配置
-- 幂等：可重复执行
-- 适用：已有学生端环境的增量升级；干净库重建也可并入 student_init
-- ============================================================

-- 1. 个人中心菜单（挂在「学生端」目录下）
set @studentDirId = (select menu_id from sys_menu where path = 'student' and menu_type = 'M' and parent_id = 0 limit 1);

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '个人中心', @studentDirId, '0', 'mine', 'interview/mine/index', 1, 0, 'C', '0', '0', 'interview:mine:list', 'user', 'admin', sysdate(), '', null, '学生端个人中心：资料展示/昵称头像/账号设置/协议/注销'
from dual
where @studentDirId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:mine:list');

set @mineMenuId = (select menu_id from sys_menu where perms = 'interview:mine:list' limit 1);

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '个人中心查询', @mineMenuId, '1', '#', '', 1, 0, 'F', '0', '0', 'interview:mine:query', '#', 'admin', sysdate(), '', null, ''
from dual
where @mineMenuId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:mine:query');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '账号注销', @mineMenuId, '2', '#', '', 1, 0, 'F', '0', '0', 'interview:mine:remove', '#', 'admin', sysdate(), '', null, ''
from dual
where @mineMenuId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:mine:remove');

-- 2. 把个人中心菜单绑到「学生」角色
set @studentRoleId = (select role_id from sys_role where role_key = 'student' and del_flag = '0' order by role_id limit 1);

insert ignore into sys_role_menu (role_id, menu_id)
select @studentRoleId, menu_id from sys_menu
where perms in ('interview:mine:list', 'interview:mine:query', 'interview:mine:remove')
  and @studentRoleId is not null;

-- 3. 用户协议 / 隐私政策参数（存 sys_config，学生端按键名读取，无需 system:config 管理权限）
insert into sys_config (config_name, config_key, config_value, config_type, create_by, create_time, remark)
select '学生端-用户协议', 'student.agreement.user',
       '欢迎使用面立方学生端。使用本产品即表示你同意遵守平台规则，合理使用模拟面试功能，不得利用本服务从事违法违规活动。平台有权在必要时更新本协议内容。',
       'Y', 'admin', sysdate(), '学生端个人中心-用户协议正文'
from dual
where not exists (select 1 from sys_config where config_key = 'student.agreement.user');

insert into sys_config (config_name, config_key, config_value, config_type, create_by, create_time, remark)
select '学生端-隐私政策', 'student.agreement.privacy',
       '我们仅收集完成模拟面试所必需的账号与业务数据（如档案、简历、面试记录与复盘报告），用于提供服务与改进体验。未经你的同意，不会向第三方出售个人信息。你可在个人中心申请注销账号。',
       'Y', 'admin', sysdate(), '学生端个人中心-隐私政策正文'
from dual
where not exists (select 1 from sys_config where config_key = 'student.agreement.privacy');

-- 校验
select menu_id, menu_name, perms from sys_menu where perms like 'interview:mine:%' order by menu_id;
select config_id, config_key, left(config_value, 40) as config_value_preview from sys_config where config_key like 'student.agreement.%';
