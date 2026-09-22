-- ⚠️ 已并入 sql/student_init.sql 的第 2 节（菜单）（权威可执行版）。本文件保留留档，内容与合并版逐字一致。
--    从零重建 / 旧库补丁请直接跑对应的合并文件，不必逐个跑本目录的脚本。
-- ============================================================
-- 菜单 SQL —— 学生端 · 全量菜单（9 个模块 + 数据权限点）
-- ------------------------------------------------------------
-- 【这是什么】把 ruoyi/ 下 9 个菜单脚本合并成的一个文件：
--   profileMenu / resumeMenu / jobprofileMenu / sessionMenu /
--   questionMenu / qaMenu / reportMenu / bankMenu / dataScopePermiMenu
--   + 个人中心 mine
--   合并后共 53 条：1 个「学生端」目录（M）+ 9 个模块菜单（C）+ 42 个按钮（F）
--                  + 1 条 interview:data:all 权限点（不给「学生」角色）
-- 【为什么合并】三端合并时只需收集 / 重放这一个文件，不必逐个找 9 个。
-- 【幂等】是 —— 每条 insert 都带 where not exists 守卫，可重复执行；
--   模块菜单与按钮的父子关系按 perms 反查，不依赖 LAST_INSERT_ID()。
-- 【前置】RuoYi-Vue/sql/ry_20260417.sql（基础库，建 sys_menu）
-- 【后置】sql/student_role_user.sql（学生角色绑定，依赖本文件建好的菜单）
-- 【校验】文件末尾自带查询：student_menu_cnt 应为 52，data_all_cnt 应为 1
-- 【原始文件】ruoyi/*Menu.sql 保留未删（代码生成器产出留档），文件头有 banner 指向本文件。
-- 【顺序】8 个模块之间先后无所谓；每个模块前都重新 set @parentId，
--   保证按钮挂在各自的模块菜单下。
-- 维护人：tong　最后更新：2026-09-22
-- ============================================================

-- ============================================================
-- 0. 「学生端」目录（M 型）—— 只建一次，下面 8 个模块都挂在它下面
-- ============================================================

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '学生端', 0, 1, 'student', null, 1, 0, 'M', '0', '0', null, 'user', 'admin', sysdate(), '', null, '学生端目录'
from dual
where not exists (select 1 from sys_menu where path = 'student' and menu_type = 'M' and parent_id = 0);

set @studentDirId = (select menu_id from sys_menu where path = 'student' and menu_type = 'M' and parent_id = 0 limit 1);

-- ============================================================
-- 0.1 / 个人中心　interview:mine:*（资料展示 / 昵称头像 / 账号设置 / 协议 / 注销）
-- ============================================================

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '个人中心', @studentDirId, '0', 'mine', 'interview/mine/index', 1, 0, 'C', '0', '0', 'interview:mine:list', 'user', 'admin', sysdate(), '', null, '学生端个人中心'
from dual
where @studentDirId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:mine:list');

set @mineParentId = (select menu_id from sys_menu where perms = 'interview:mine:list' limit 1);

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '个人中心查询', @mineParentId, '1', '#', '', 1, 0, 'F', '0', '0', 'interview:mine:query', '#', 'admin', sysdate(), '', null, ''
from dual
where @mineParentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:mine:query');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '账号注销', @mineParentId, '2', '#', '', 1, 0, 'F', '0', '0', 'interview:mine:remove', '#', 'admin', sysdate(), '', null, ''
from dual
where @mineParentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:mine:remove');

-- ============================================================
-- 1 / 8　学生档案　interview:profile:*
-- ============================================================

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '学生档案', @studentDirId, '1', 'profile', 'interview/profile/index', 1, 0, 'C', '0', '0', 'interview:profile:list', '#', 'admin', sysdate(), '', null, '学生档案菜单'
from dual
where @studentDirId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:profile:list');

-- 取本模块菜单 ID —— 按权限标识反查（不用 LAST_INSERT_ID()，菜单已存在时同样取得到）
set @parentId = (select menu_id from sys_menu where perms = 'interview:profile:list' limit 1);

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '学生档案查询', @parentId, '1', '#', '', 1, 0, 'F', '0', '0', 'interview:profile:query', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:profile:query');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '学生档案新增', @parentId, '2', '#', '', 1, 0, 'F', '0', '0', 'interview:profile:add', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:profile:add');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '学生档案修改', @parentId, '3', '#', '', 1, 0, 'F', '0', '0', 'interview:profile:edit', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:profile:edit');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '学生档案删除', @parentId, '4', '#', '', 1, 0, 'F', '0', '0', 'interview:profile:remove', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:profile:remove');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '学生档案导出', @parentId, '5', '#', '', 1, 0, 'F', '0', '0', 'interview:profile:export', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:profile:export');

-- ============================================================
-- 2 / 8　学生简历　interview:resume:*
-- ============================================================

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '学生简历', @studentDirId, '1', 'resume', 'interview/resume/index', 1, 0, 'C', '0', '0', 'interview:resume:list', '#', 'admin', sysdate(), '', null, '学生简历菜单'
from dual
where @studentDirId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:resume:list');

-- 取本模块菜单 ID —— 按权限标识反查（不用 LAST_INSERT_ID()，菜单已存在时同样取得到）
set @parentId = (select menu_id from sys_menu where perms = 'interview:resume:list' limit 1);

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '学生简历查询', @parentId, '1', '#', '', 1, 0, 'F', '0', '0', 'interview:resume:query', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:resume:query');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '学生简历新增', @parentId, '2', '#', '', 1, 0, 'F', '0', '0', 'interview:resume:add', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:resume:add');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '学生简历修改', @parentId, '3', '#', '', 1, 0, 'F', '0', '0', 'interview:resume:edit', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:resume:edit');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '学生简历删除', @parentId, '4', '#', '', 1, 0, 'F', '0', '0', 'interview:resume:remove', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:resume:remove');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '学生简历导出', @parentId, '5', '#', '', 1, 0, 'F', '0', '0', 'interview:resume:export', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:resume:export');

-- ============================================================
-- 3 / 8　学生岗位画像　interview:jobprofile:*
-- ============================================================

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '学生岗位画像', @studentDirId, '1', 'jobprofile', 'interview/jobprofile/index', 1, 0, 'C', '0', '0', 'interview:jobprofile:list', '#', 'admin', sysdate(), '', null, '学生岗位画像菜单'
from dual
where @studentDirId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:jobprofile:list');

-- 取本模块菜单 ID —— 按权限标识反查（不用 LAST_INSERT_ID()，菜单已存在时同样取得到）
set @parentId = (select menu_id from sys_menu where perms = 'interview:jobprofile:list' limit 1);

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '学生岗位画像查询', @parentId, '1', '#', '', 1, 0, 'F', '0', '0', 'interview:jobprofile:query', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:jobprofile:query');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '学生岗位画像新增', @parentId, '2', '#', '', 1, 0, 'F', '0', '0', 'interview:jobprofile:add', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:jobprofile:add');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '学生岗位画像修改', @parentId, '3', '#', '', 1, 0, 'F', '0', '0', 'interview:jobprofile:edit', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:jobprofile:edit');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '学生岗位画像删除', @parentId, '4', '#', '', 1, 0, 'F', '0', '0', 'interview:jobprofile:remove', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:jobprofile:remove');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '学生岗位画像导出', @parentId, '5', '#', '', 1, 0, 'F', '0', '0', 'interview:jobprofile:export', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:jobprofile:export');

-- ============================================================
-- 4 / 8　模拟面试场次　interview:session:*
-- ============================================================

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '模拟面试场次', @studentDirId, '1', 'session', 'interview/session/index', 1, 0, 'C', '0', '0', 'interview:session:list', '#', 'admin', sysdate(), '', null, '模拟面试场次菜单'
from dual
where @studentDirId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:session:list');

-- 取本模块菜单 ID —— 按权限标识反查（不用 LAST_INSERT_ID()，菜单已存在时同样取得到）
set @parentId = (select menu_id from sys_menu where perms = 'interview:session:list' limit 1);

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '模拟面试场次查询', @parentId, '1', '#', '', 1, 0, 'F', '0', '0', 'interview:session:query', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:session:query');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '模拟面试场次新增', @parentId, '2', '#', '', 1, 0, 'F', '0', '0', 'interview:session:add', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:session:add');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '模拟面试场次修改', @parentId, '3', '#', '', 1, 0, 'F', '0', '0', 'interview:session:edit', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:session:edit');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '模拟面试场次删除', @parentId, '4', '#', '', 1, 0, 'F', '0', '0', 'interview:session:remove', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:session:remove');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '模拟面试场次导出', @parentId, '5', '#', '', 1, 0, 'F', '0', '0', 'interview:session:export', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:session:export');

-- ============================================================
-- 5 / 8　面试题目　interview:question:*
-- ============================================================

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '面试题目', @studentDirId, '1', 'question', 'interview/question/index', 1, 0, 'C', '0', '0', 'interview:question:list', '#', 'admin', sysdate(), '', null, '面试题目菜单'
from dual
where @studentDirId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:question:list');

-- 取本模块菜单 ID —— 按权限标识反查（不用 LAST_INSERT_ID()，菜单已存在时同样取得到）
set @parentId = (select menu_id from sys_menu where perms = 'interview:question:list' limit 1);

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '面试题目查询', @parentId, '1', '#', '', 1, 0, 'F', '0', '0', 'interview:question:query', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:question:query');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '面试题目新增', @parentId, '2', '#', '', 1, 0, 'F', '0', '0', 'interview:question:add', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:question:add');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '面试题目修改', @parentId, '3', '#', '', 1, 0, 'F', '0', '0', 'interview:question:edit', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:question:edit');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '面试题目删除', @parentId, '4', '#', '', 1, 0, 'F', '0', '0', 'interview:question:remove', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:question:remove');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '面试题目导出', @parentId, '5', '#', '', 1, 0, 'F', '0', '0', 'interview:question:export', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:question:export');

-- ============================================================
-- 6 / 8　面试问答　interview:qa:*
-- ============================================================

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '面试问答', @studentDirId, '1', 'qa', 'interview/qa/index', 1, 0, 'C', '0', '0', 'interview:qa:list', '#', 'admin', sysdate(), '', null, '面试问答菜单'
from dual
where @studentDirId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:qa:list');

-- 取本模块菜单 ID —— 按权限标识反查（不用 LAST_INSERT_ID()，菜单已存在时同样取得到）
set @parentId = (select menu_id from sys_menu where perms = 'interview:qa:list' limit 1);

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '面试问答查询', @parentId, '1', '#', '', 1, 0, 'F', '0', '0', 'interview:qa:query', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:qa:query');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '面试问答新增', @parentId, '2', '#', '', 1, 0, 'F', '0', '0', 'interview:qa:add', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:qa:add');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '面试问答修改', @parentId, '3', '#', '', 1, 0, 'F', '0', '0', 'interview:qa:edit', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:qa:edit');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '面试问答删除', @parentId, '4', '#', '', 1, 0, 'F', '0', '0', 'interview:qa:remove', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:qa:remove');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '面试问答导出', @parentId, '5', '#', '', 1, 0, 'F', '0', '0', 'interview:qa:export', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:qa:export');

-- ============================================================
-- 7 / 8　面试复盘报告　interview:report:*
-- ============================================================

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '面试复盘报告', @studentDirId, '1', 'report', 'interview/report/index', 1, 0, 'C', '0', '0', 'interview:report:list', '#', 'admin', sysdate(), '', null, '面试复盘报告菜单'
from dual
where @studentDirId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:report:list');

-- 取本模块菜单 ID —— 按权限标识反查（不用 LAST_INSERT_ID()，菜单已存在时同样取得到）
set @parentId = (select menu_id from sys_menu where perms = 'interview:report:list' limit 1);

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '面试复盘报告查询', @parentId, '1', '#', '', 1, 0, 'F', '0', '0', 'interview:report:query', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:report:query');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '面试复盘报告新增', @parentId, '2', '#', '', 1, 0, 'F', '0', '0', 'interview:report:add', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:report:add');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '面试复盘报告修改', @parentId, '3', '#', '', 1, 0, 'F', '0', '0', 'interview:report:edit', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:report:edit');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '面试复盘报告删除', @parentId, '4', '#', '', 1, 0, 'F', '0', '0', 'interview:report:remove', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:report:remove');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '面试复盘报告导出', @parentId, '5', '#', '', 1, 0, 'F', '0', '0', 'interview:report:export', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:report:export');

-- ============================================================
-- 8 / 8　题库题目　interview:bank:*
-- ============================================================

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '题库题目', @studentDirId, '1', 'bank', 'interview/bank/index', 1, 0, 'C', '0', '0', 'interview:bank:list', '#', 'admin', sysdate(), '', null, '题库题目菜单'
from dual
where @studentDirId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:bank:list');

-- 取本模块菜单 ID —— 按权限标识反查（不用 LAST_INSERT_ID()，菜单已存在时同样取得到）
set @parentId = (select menu_id from sys_menu where perms = 'interview:bank:list' limit 1);

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '题库题目查询', @parentId, '1', '#', '', 1, 0, 'F', '0', '0', 'interview:bank:query', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:bank:query');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '题库题目新增', @parentId, '2', '#', '', 1, 0, 'F', '0', '0', 'interview:bank:add', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:bank:add');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '题库题目修改', @parentId, '3', '#', '', 1, 0, 'F', '0', '0', 'interview:bank:edit', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:bank:edit');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '题库题目删除', @parentId, '4', '#', '', 1, 0, 'F', '0', '0', 'interview:bank:remove', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:bank:remove');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '题库题目导出', @parentId, '5', '#', '', 1, 0, 'F', '0', '0', 'interview:bank:export', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:bank:export');

-- ============================================================
-- 9 / 9　数据隔离权限点　interview:data:all
-- ------------------------------------------------------------
-- 用途：注册为可分配的权限按钮，供后台端在「角色管理」里授予非超管角色。
-- ⚠️ 不要分配给「学生」角色 —— 否则学生能看到全部学生的数据。
-- 超级管理员无需分配（若依自动授予 *:*:*，天然通过）。
-- ⚠️ 挂载位置：本语句把它挂在「学生端」目录（@studentDirId）下。
--    但有的库（含本仓库开发库）里它已被手工挂到根节点（parent_id = 0）——
--    两种位置都不影响功能：sql/student_role_user.sql 的绑定按「学生端目录 → 其下两层」取，
--    根节点下的它自然取不到；若它确实挂在目录下，绑定语句里还有一句
--    `and (perms is null or perms <> 'interview:data:all')` 把它排除掉。
--    由于本条有 perms 存在判据，重放既不会新增、也不会迁移已有记录。
-- ============================================================

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '查看全部学生数据', @studentDirId, 9, '#', '', 1, 0, 'F', '0', '0', 'interview:data:all', '#', 'admin', sysdate(), '', null, '拥有此权限可查看与操作全部学生数据，勿分配给「学生」角色'
from dual
where not exists (select 1 from sys_menu where perms = 'interview:data:all');

-- ============================================================
-- 校验
-- ============================================================

-- 校验 1：学生端菜单树（目录 + 9 模块菜单 + 42 按钮），预期 52
--   注意：按钮是模块菜单的子节点（孙节点），所以要查三层。
--   data:all 被排除 —— 它不属于学生端菜单树（无论挂在目录下还是根节点）。
select count(*) as student_menu_cnt
from sys_menu
where (menu_id = @studentDirId
    or parent_id = @studentDirId
    or parent_id in (select menu_id from sys_menu where parent_id = @studentDirId))
  and (perms is null or perms <> 'interview:data:all');

-- 校验 2：数据隔离权限点，预期 1
select count(*) as data_all_cnt
from sys_menu
where perms = 'interview:data:all';

-- 校验 3：逐条列出学生端菜单树，便于肉眼核对（预期 52 行）
select menu_id, menu_name, menu_type, parent_id, order_num, perms
from sys_menu
where (menu_id = @studentDirId
    or parent_id = @studentDirId
    or parent_id in (select menu_id from sys_menu where parent_id = @studentDirId))
  and (perms is null or perms <> 'interview:data:all')
order by menu_type desc, parent_id, order_num, menu_id;
