-- ⚠️ 已合并进 sql/student_menu.sql，再并入 sql/student_init.sql（一键重建的权威入口）。
--    三端合并 / 从零重建请直接用 sql/student_init.sql，不必逐个找本目录的 9 个菜单脚本。
-- ============================================================
-- 菜单 SQL —— 学生端 · 面试问答（已并入「面试环节」）
-- ------------------------------------------------------------
-- 【2026-09-28 变更】「面试问答」不再单独出侧边栏菜单：
--   前端 views/interview/qa/index.vue 已并入 views/interview/session/index.vue
--   （/student/qa 路由消失，作答界面挂在 /student/session?sessionId=x 下）。
--   所以本文件现在插入 **6 个 F 型按钮**，全部挂在「模拟面试场次」模块菜单下。
--
--   ⚠️ 为什么是 6 个而不是 5 个 —— 这是 2026-09-28 的一次回归修复：
--     每个模块的 6 个权限点里，`:list` 平时是挂在 **C 型模块菜单**上的；
--     删掉 qa 的 C 型菜单时，`interview:qa:list` 会被一并删掉。
--     但后端 InterviewQaController.list() 的 @PreAuthorize 正是 'interview:qa:list'，
--     作答页加载时要调 GET /interview/qa/list → 学生立刻 403。
--     所以这里把 :list **降级成一条 F 型按钮**，与另外 5 个并列。
--     权限点总数因此守恒：8 模块 × 6 = 48 个，一个不多一个不少。
--
--   为什么按钮必须留着：后端 InterviewQaController 的 6 个接口都有
--   @PreAuthorize('interview:qa:xxx')，合并后的作答页仍要调 listQa / submitQa，
--   删掉这些权限点学生就会 403。按钮是 F 型（visible=0），不会出现在侧边栏，
--   挂到哪个模块菜单下对用户不可见，只影响「角色管理」里的权限勾选树。
--
--   已建库的迁移（把已有按钮改挂过去 + 删掉旧的 C 型菜单 + 补回 :list）见：
--   sql/student_qa_merge_menu.sql
--   本文件本身对**新库**就够了（插入时父菜单就是「面试环节」）。
--
-- 作用：插入「面试问答」的 6 个按钮（F），挂在「模拟面试场次」模块菜单下
-- 前置：「学生端」目录（M）与「模拟面试场次」模块菜单（C）—— 本文件会确保目录存在；
--       模块菜单必须先由 ruoyi/sessionMenu.sql 建好（否则 @parentId 取不到，按钮不插入）
-- 幂等：是 —— 所有插入均带 where not exists 守卫，可重复执行
-- 权限：interview:qa:list / query / add / edit / remove / export
-- 校验：文件末尾自带查询，应返回 6 行（全部是 F 型按钮，parent 指向「模拟面试场次」）
-- 详见：sql/README.md
-- ============================================================

-- 1. 确保「学生端」目录存在（M 型）
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '学生端', 0, 1, 'student', null, 1, 0, 'M', '0', '0', null, 'user', 'admin', sysdate(), '', null, '学生端目录'
from dual
where not exists (select 1 from sys_menu where path = 'student' and menu_type = 'M' and parent_id = 0);

-- 2. 取「学生端」目录 ID（供本文件后续语句使用）
set @studentDirId = (select menu_id from sys_menu where path = 'student' and menu_type = 'M' and parent_id = 0 limit 1);

-- 3. 取「模拟面试场次」模块菜单 ID —— 按钮挂到它下面（不再是自己的模块菜单）
--    同样用反查而非 LAST_INSERT_ID()，菜单已存在时也取得到
set @parentId = (select menu_id from sys_menu where perms = 'interview:session:list' limit 1);

-- 4. 按钮（F 型）—— 每个以自身权限标识为存在判据
--    order_num 从 6 起，避免与「模拟面试场次」自己的 5 个按钮（1~5）重号。
--    :list 排最后（11）—— 它本来挂在 C 型模块菜单上，是"降级"过来的；
--    不重排序号是为了让「新库直接建」与「旧库跑迁移」两条路径得到完全相同的形状。
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

-- ⚠️ 这一条是 2026-09-28 补的：`:list` 原本挂在 qa 的 C 型模块菜单上，
--    删菜单时被一并删掉 → GET /interview/qa/list 对学生 403。
--    降级成 F 型按钮后权限点总数守恒（8 模块 × 6 = 48）。
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '面试问答列表', @parentId, '11', '#', '', 1, 0, 'F', '0', '0', 'interview:qa:list', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:qa:list');

-- 5. 校验：应恰好 6 行，全部 F 型，parent_id 指向「模拟面试场次」
select m.menu_id, m.menu_name, m.menu_type, m.parent_id, m.order_num, m.perms
from sys_menu m
where m.perms like 'interview:qa:%'
order by m.menu_id;
