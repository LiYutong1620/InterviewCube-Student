-- ⚠️ 已并入 sql/student_init.sql 的第 3 节（角色与账号）（权威可执行版）。本文件保留留档，内容与合并版逐字一致。
--    从零重建 / 旧库补丁请直接跑对应的合并文件，不必逐个跑本目录的脚本。
-- ============================================================
-- 【学生端 · 角色与账号】 可执行 / 幂等
-- ------------------------------------------------------------
-- 作用：补上「干净库重建」的第 4 块拼图 ——
--       「学生」角色 + student01 / student02 账号 + 角色菜单绑定
-- 前置：1) RuoYi-Vue/sql/ry_20260417.sql   （若依基础库）
--       2) RuoYi-Vue/sql/quartz.sql        （定时任务表，可跳过）
--       3) ruoyi/*Menu.sql                 （8 个，建学生端菜单）
--       4) ruoyi/dataScopePermiMenu.sql    （注册 interview:data:all）
-- 幂等：是 —— 可重复执行；已存在的角色 / 账号 / 绑定不会被重复创建
-- 账号：student01 / student02
--       初始密码 admin123（复用若依基础库自带的种子密文）
--       仅限开发与演示，上线前必须在后台改掉
-- 详见：sql/README.md
-- ============================================================

set names utf8mb4;

-- ------------------------------------------------------------
-- 1. 「学生」角色
--    不写死 role_id：若依 sys_role 自增从 100 起，写死会与别人冲突
--    data_scope 用若依新建角色的默认值 '1'；学生端的数据隔离不依赖它，
--    而是 StudentDataScopeUtils 按 user_id 做的，与本字段无关
-- ------------------------------------------------------------
insert into sys_role (role_name, role_key, role_sort, data_scope, menu_check_strictly, dept_check_strictly, status, del_flag, create_by, create_time, remark)
select '学生', 'student', 3, '1', 1, 1, '0', '0', 'admin', sysdate(), '学生端角色，只能访问学生端菜单'
from dual
where not exists (select 1 from sys_role where role_key = 'student' and del_flag = '0');

set @studentRoleId = (select role_id from sys_role where role_key = 'student' and del_flag = '0' order by role_id limit 1);

-- ------------------------------------------------------------
-- 2. 学生账号 student01 / student02
--    dept_id 留空（与现有 student01 一致）
--    password = 若依基础库自带的种子密文，明文即 admin123
-- ------------------------------------------------------------
insert into sys_user (dept_id, user_name, nick_name, user_type, email, phonenumber, sex, avatar, password, status, del_flag, login_ip, login_date, pwd_update_date, create_by, create_time, update_by, update_time, remark)
select null, 'student01', 'student01', '00', '', '', '2', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '', null, sysdate(), 'admin', sysdate(), '', null, '学生端测试账号'
from dual
where not exists (select 1 from sys_user where user_name = 'student01' and del_flag = '0');

insert into sys_user (dept_id, user_name, nick_name, user_type, email, phonenumber, sex, avatar, password, status, del_flag, login_ip, login_date, pwd_update_date, create_by, create_time, update_by, update_time, remark)
select null, 'student02', 'student02', '00', '', '', '2', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '', null, sysdate(), 'admin', sysdate(), '', null, '学生端测试账号（数据隔离验证用）'
from dual
where not exists (select 1 from sys_user where user_name = 'student02' and del_flag = '0');

set @student01Id = (select user_id from sys_user where user_name = 'student01' and del_flag = '0' order by user_id limit 1);
set @student02Id = (select user_id from sys_user where user_name = 'student02' and del_flag = '0' order by user_id limit 1);

-- ------------------------------------------------------------
-- 3. 账号 <-> 角色 绑定
--    insert ignore：主键是 (user_id, role_id)，已绑定则自动跳过
-- ------------------------------------------------------------
insert ignore into sys_user_role (user_id, role_id)
select @student01Id, @studentRoleId from dual where @student01Id is not null and @studentRoleId is not null;

insert ignore into sys_user_role (user_id, role_id)
select @student02Id, @studentRoleId from dual where @student02Id is not null and @studentRoleId is not null;

-- ------------------------------------------------------------
-- 4. 角色 <-> 菜单 绑定：按「学生端目录 -> 其下全部菜单」动态绑定
--    不写死 menu_id —— 三端合并后菜单 id 会整体重排
--
--    菜单树形状（合计 49 条）：
--      学生端目录                       1 条   path='student', menu_type='M'
--        +-- 8 个模块菜单               8 条   每个模块的 interview:xxx:list 挂在这里
--              +-- 每个模块 5 个按钮   40 条   query / add / edit / remove / export
--
--    注意：必须排除 interview:data:all —— 它同样挂在「学生端」目录下，
--    但那是给后台端的「全量数据权限」，学生拿到就能看所有学生的数据
-- ------------------------------------------------------------
set @studentDirId = (select menu_id from sys_menu where path = 'student' and menu_type = 'M' order by menu_id limit 1);

-- 4.1 目录本身
insert ignore into sys_role_menu (role_id, menu_id)
select @studentRoleId, @studentDirId from dual where @studentRoleId is not null and @studentDirId is not null;

-- 4.2 目录下的一级菜单（8 个模块，含各自的 interview:xxx:list 权限）
insert ignore into sys_role_menu (role_id, menu_id)
select @studentRoleId, menu_id from sys_menu
where parent_id = @studentDirId
  and @studentRoleId is not null
  and (perms is null or perms <> 'interview:data:all');

-- 4.3 再下一级（每个模块的 5 个按钮）
--     若以后菜单层级加深，这里需要再加一段；跑完第 5 步的校验能立刻发现
insert ignore into sys_role_menu (role_id, menu_id)
select @studentRoleId, menu_id from sys_menu
where parent_id in (select menu_id from sys_menu where parent_id = @studentDirId)
  and @studentRoleId is not null;

-- ------------------------------------------------------------
-- 5. 校验
--    预期：menu_cnt = 49，user_cnt = 2，data_all_bound = 0
-- ------------------------------------------------------------
select r.role_id,
       r.role_key,
       r.role_name,
       (select count(*) from sys_user_role ur where ur.role_id = r.role_id) as user_cnt,
       (select count(*) from sys_role_menu rm where rm.role_id = r.role_id) as menu_cnt
from sys_role r
where r.role_key = 'student' and r.del_flag = '0';

select count(*) as data_all_bound
from sys_role r
join sys_role_menu rm on rm.role_id = r.role_id
join sys_menu m on m.menu_id = rm.menu_id
where r.role_key = 'student' and m.perms = 'interview:data:all';
