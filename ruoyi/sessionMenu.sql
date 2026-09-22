-- ⚠️ 已合并进 sql/student_menu.sql，再并入 sql/student_init.sql（一键重建的权威入口）。
--    三端合并 / 从零重建请直接用 sql/student_init.sql，不必逐个找本目录的 9 个菜单脚本。
-- ============================================================
-- 菜单 SQL —— 学生端 · 模拟面试场次
-- ------------------------------------------------------------
-- 作用：插入「模拟面试场次」模块菜单（C）及其 5 个按钮（F）
-- 前置：「学生端」目录（M）—— 本文件会自动创建
-- 幂等：是 —— 所有插入均带 where not exists 守卫，可重复执行
-- 权限：interview:session:list / query / add / edit / remove / export
-- 校验：文件末尾自带查询，应返回 6 行（1 个模块菜单 + 5 个按钮）
-- 详见：sql/README.md
-- ============================================================

-- 1. 确保「学生端」目录存在（M 型）
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '学生端', 0, 1, 'student', null, 1, 0, 'M', '0', '0', null, 'user', 'admin', sysdate(), '', null, '学生端目录'
from dual
where not exists (select 1 from sys_menu where path = 'student' and menu_type = 'M' and parent_id = 0);

-- 2. 取「学生端」目录 ID（供本文件后续语句使用）
set @studentDirId = (select menu_id from sys_menu where path = 'student' and menu_type = 'M' and parent_id = 0 limit 1);

-- 3. 模块菜单（C 型）—— 以权限标识 interview:session:list 为存在判据
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '模拟面试场次', @studentDirId, '1', 'session', 'interview/session/index', 1, 0, 'C', '0', '0', 'interview:session:list', '#', 'admin', sysdate(), '', null, '模拟面试场次菜单'
from dual
where @studentDirId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:session:list');

-- 4. 取模块菜单 ID —— 用反查而非 LAST_INSERT_ID()，菜单已存在时同样取得到
set @parentId = (select menu_id from sys_menu where perms = 'interview:session:list' limit 1);

-- 5. 按钮（F 型）—— 每个以自身权限标识为存在判据
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

-- 6. 校验：本模块应恰好 6 行（1 个模块菜单 + 5 个按钮）
select menu_id, menu_name, menu_type, parent_id, perms
from sys_menu
where perms like 'interview:session:%'
order by menu_id;
