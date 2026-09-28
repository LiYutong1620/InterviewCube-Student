-- ============================================================
-- 菜单 SQL —— 学生端 · 全量菜单（模块菜单 + 按钮 + 数据权限点）
-- ------------------------------------------------------------
-- 【这是什么】把 ruoyi/ 下的菜单脚本合并成的一个文件：
--   profileMenu / resumeMenu / jobprofileMenu / sessionMenu /
--   questionMenu / qaMenu / reportMenu / bankMenu / dataScopePermiMenu
--   合并后共 50 条：1 个「学生端」目录（M）+ 7 个模块菜单（C）+ 41 个按钮（F）
--                  + 1 条 interview:data:all 权限点（不给「学生」角色）
-- 【2026-09-28】「面试问答」并入「面试环节」：不再有独立的 qa 模块菜单（8 → 7），
--   它的 6 个 interview:qa:* 按钮全部改挂到「模拟面试场次」模块菜单下。
--   ⚠️ 是 6 个不是 5 个：:list 本来挂在 C 型模块菜单上，删菜单会连它一起删 → 后端 403，
--      所以把它降级成 F 型按钮。权限点总数守恒（8 模块 × 6 = 48 个）。
--   原因：后端 InterviewQaController 六个接口都带 @PreAuthorize，权限点不能删；
--   按钮是 F 型不进侧边栏，挂哪儿对用户不可见，只影响「角色管理」的权限勾选树。
-- 【为什么合并】三端合并时只需收集 / 重放这一个文件，不必逐个找 9 个。
-- 【幂等】是 —— 每条 insert 都带 where not exists 守卫，可重复执行；
--   模块菜单与按钮的父子关系按 perms 反查，不依赖 LAST_INSERT_ID()。
--   末尾「迁移」节会顺手清掉旧库遗留的 C 型「面试问答」菜单、并补回 :list，所以重放也能收敛。
-- 【前置】RuoYi-Vue/sql/ry_20260417.sql（基础库，建 sys_menu）
-- 【后置】sql/student_role_user.sql（学生角色绑定，依赖本文件建好的菜单）
-- 【校验】文件末尾自带查询：student_menu_cnt 应为 49，data_all_cnt 应为 1，
--   legacy_qa_menu_cnt 应为 0，qa_permi_cnt 应为 6
-- 【原始文件】ruoyi/*Menu.sql 保留未删（代码生成器产出留档），文件头有 banner 指向本文件。
-- 【顺序】模块之间先后无所谓；每个模块前都重新 set @parentId，
--   保证按钮挂在各自的模块菜单下。⚠️ 迁移节必须在 session 模块之后。
-- 维护人：tong　最后更新：2026-09-28
-- ============================================================

-- ============================================================
-- 0. 「学生端」目录（M 型）—— 只建一次，下面各模块都挂在它下面
-- ============================================================

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '学生端', 0, 1, 'student', null, 1, 0, 'M', '0', '0', null, 'user', 'admin', sysdate(), '', null, '学生端目录'
from dual
where not exists (select 1 from sys_menu where path = 'student' and menu_type = 'M' and parent_id = 0);

set @studentDirId = (select menu_id from sys_menu where path = 'student' and menu_type = 'M' and parent_id = 0 limit 1);

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
-- 6 / 8　面试问答（并入面试环节）　interview:qa:*
-- ============================================================

-- ⚠️ 本模块没有自己的模块菜单（已并入「面试环节」），下面 6 个按钮
--    直接挂在「模拟面试场次」的模块菜单下；权限点一个不少（含 :list）。
--    取挂靠父菜单 ID —— 同样按权限标识反查。
set @parentId = (select menu_id from sys_menu where perms = 'interview:session:list' limit 1);

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '面试问答查询', @parentId, '6', '#', '', 1, 0, 'F', '0', '0', 'interview:qa:query', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:qa:query');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '面试问答新增', @parentId, '7', '#', '', 1, 0, 'F', '0', '0', 'interview:qa:add', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:qa:add');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '面试问答修改', @parentId, '8', '#', '', 1, 0, 'F', '0', '0', 'interview:qa:edit', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:qa:edit');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '面试问答删除', @parentId, '9', '#', '', 1, 0, 'F', '0', '0', 'interview:qa:remove', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:qa:remove');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '面试问答导出', @parentId, '10', '#', '', 1, 0, 'F', '0', '0', 'interview:qa:export', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:qa:export');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '面试问答列表', @parentId, '11', '#', '', 1, 0, 'F', '0', '0', 'interview:qa:list', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:qa:list');

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
-- 迁移：清掉旧库遗留的 C 型「面试问答」菜单 + 补回 interview:qa:list（2026-09-28）
-- ------------------------------------------------------------
-- 新库不会走到这里（上面 qaMenu 那段已经不插 C 菜单，且直接插了 6 个按钮）；
-- 已建过的库重放本文件时，靠这一段收敛到「7 个模块菜单 + 6 个 qa 按钮」。
-- ⚠️ 其中「重建 :list 并补绑角色」是 2026-09-28 回归修复的关键，别删。
-- 来源：sql/student_qa_merge_menu.sql（同一个文件也是 sql/student_patch.sql 的一节）
-- ============================================================

-- ============================================================
-- 【学生端 · 迁移】「面试问答」并入「面试环节」（2026-09-28）
-- ------------------------------------------------------------
-- 【背景】前端 views/interview/qa/index.vue 已并入 views/interview/session/index.vue：
--   · /student/qa 路由消失（菜单没了 → 动态路由不再生成）
--   · 作答 / 回顾界面改挂在 /student/session?sessionId=x 下
--   · 所以「面试问答」不再需要自己的侧边栏菜单
--
-- 【但 6 个权限点必须一个不少】后端 InterviewQaController 的
--   list / query / add / edit / remove / export 六个接口都带 @PreAuthorize('interview:qa:xxx')，
--   合并后的作答页仍要调 listQa / submitQa —— 删掉权限点，学生立刻 403。
--
--   ⚠️ 2026-09-28 的一次回归（本文件已修）：每个模块的 6 个权限点里，`:list` 平时挂在
--     **C 型模块菜单**上，另外 5 个挂在 F 型按钮上。第一版迁移只搬了 5 个按钮、
--     然后删掉 C 菜单 —— 于是 `interview:qa:list` 跟着没了，student01 一进
--     /student/session?sessionId=x 就弹「当前操作没有权限」（GET /interview/qa/list 403）。
--     修法：第 5 步把 :list **降级成一条 F 型按钮**，与另外 5 个并列挂到
--     「模拟面试场次」下，并补回角色绑定。权限点总数因此守恒（8 模块 × 6 = 48）。
--
-- 【新库不需要本文件】ruoyi/qaMenu.sql 已经直接把这 6 个按钮插到「面试环节」下了。
--   本文件只服务于「已建过库、不想重建」的场景。
--
-- 【前置】ruoyi/sessionMenu.sql（或 sql/student_init.sql 第 2 节）已跑过
-- 【幂等】是 —— 可重复执行；第 3 步带 order_num <= 5 守卫，重跑不会反复加 5；
--        第 5 步带 not exists 判据 + insert ignore，重跑不会重复插/重复绑
-- 【校验】文件末尾自带查询：应返回 6 行 F 型按钮，且 0 行 C 型「面试问答」菜单
-- 【详见】sql/README.md
-- ============================================================

set names utf8mb4;

-- ------------------------------------------------------------
-- 1. 取「模拟面试场次」模块菜单 ID
-- ------------------------------------------------------------
set @sessionMenuId = (select menu_id from sys_menu where perms = 'interview:session:list' limit 1);

-- ------------------------------------------------------------
-- 2. 把「面试问答」的按钮改挂到「模拟面试场次」下
--    ⚠️ 用会话变量而不是子查询 —— MySQL 不允许 update 的目标表出现在子查询里（错误 1093）
--    ⚠️ 只搬 F 型：旧库里 :list 是 C 型（第 4 步要删掉它）；重跑时它已是 F 型，照样能取到
-- ------------------------------------------------------------
update sys_menu
set parent_id = @sessionMenuId
where perms like 'interview:qa:%'
  and menu_type = 'F'
  and @sessionMenuId is not null;

-- ------------------------------------------------------------
-- 3. 按钮序号从 6 起，避免与「模拟面试场次」自己的 5 个按钮（1~5）重号
--    order_num <= 5 是幂等守卫：第一次把 1~5 抬成 6~10，重跑时已全部 > 5，不再动
-- ------------------------------------------------------------
update sys_menu
set order_num = order_num + 5
where perms like 'interview:qa:%'
  and menu_type = 'F'
  and order_num <= 5;

-- ------------------------------------------------------------
-- 4. 解绑角色 → 菜单的关系，再删掉「面试问答」那条 C 型模块菜单
--    ⚠️ 必须限定 menu_type = 'C'：否则第 5 步补的 F 型 :list 会被这条一起删掉
--       （第一版就是漏了这个限定，才把权限点删没的；重跑时更危险）
--    5 个按钮本身不动（menu_id 不变，角色绑定继续有效）
-- ------------------------------------------------------------
delete from sys_role_menu
where menu_id in (select menu_id from sys_menu where perms = 'interview:qa:list' and menu_type = 'C');

delete from sys_menu where perms = 'interview:qa:list' and menu_type = 'C';

-- ------------------------------------------------------------
-- 5. ⚠️ 关键一步（2026-09-28 回归修复）：把 interview:qa:list 补回来
--    · 降级成 F 型按钮，挂在「模拟面试场次」下（和另外 5 个并列）
--    · order_num = 11（6 ~ 10 已被另外 5 个按钮占用）
--    · 同步补回「学生」角色的绑定 —— 第 4 步把旧绑定删掉了，
--      而 student_role_user.sql 不会自动重跑，所以这里必须自己绑
-- ------------------------------------------------------------
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '面试问答列表', @sessionMenuId, '11', '#', '', 1, 0, 'F', '0', '0', 'interview:qa:list', '#', 'admin', sysdate(), '', null, '2026-09-28 由 C 型模块菜单降级为按钮（权限点守恒）'
from dual
where @sessionMenuId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:qa:list');

-- 绑给「学生」角色（可能有多条同 role_key 的记录，cross join 一次绑全；insert ignore 保证幂等）
insert ignore into sys_role_menu (role_id, menu_id)
select r.role_id, m.menu_id
from sys_role r
cross join sys_menu m
where r.role_key = 'student'
  and r.del_flag = '0'
  and m.perms = 'interview:qa:list';

-- ------------------------------------------------------------
-- 6. 校验：应 6 行，全部 F 型，parent_id 指向「模拟面试场次」
-- ------------------------------------------------------------
select m.menu_id, m.menu_name, m.menu_type, m.parent_id, m.order_num, m.perms
from sys_menu m
where m.perms like 'interview:qa:%'
order by m.order_num, m.menu_id;

-- ------------------------------------------------------------
-- 7. 校验：应 0 行（旧的 C 型「面试问答」菜单已删干净）
-- ------------------------------------------------------------
select menu_id, menu_name, menu_type, perms
from sys_menu
where perms = 'interview:qa:list' and menu_type = 'C';

-- ------------------------------------------------------------
-- 8. 校验：学生角色手上的 interview:qa:* 权限应 6 个（含 list）
-- ------------------------------------------------------------
select m.perms
from sys_role r
join sys_role_menu rm on rm.role_id = r.role_id
join sys_menu m on m.menu_id = rm.menu_id
where r.role_key = 'student' and r.del_flag = '0'
  and m.perms like 'interview:qa:%'
order by m.perms;


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

-- 校验 1：学生端菜单树（目录 + 7 模块菜单 + 41 按钮），预期 49
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

-- 校验 3：确认已无 C 型「面试问答」模块菜单，预期 0
--   ⚠️ 必须带 menu_type = 'C' —— 修复后 :list 本身是一条 F 型按钮，不带限定会数成 1。
select count(*) as legacy_qa_menu_cnt
from sys_menu
where perms = 'interview:qa:list'
  and menu_type = 'C';

-- 校验 4：interview:qa:* 权限点一个不少，预期 6（全部 F 型，挂在「模拟面试场次」下，含 :list）
select count(*) as qa_permi_cnt
from sys_menu
where perms like 'interview:qa:%%';

-- 校验 5：逐条列出学生端菜单树，便于肉眼核对（预期 49 行）
select menu_id, menu_name, menu_type, parent_id, order_num, perms
from sys_menu
where (menu_id = @studentDirId
    or parent_id = @studentDirId
    or parent_id in (select menu_id from sys_menu where parent_id = @studentDirId))
  and (perms is null or perms <> 'interview:data:all')
order by menu_type desc, parent_id, order_num, menu_id;
