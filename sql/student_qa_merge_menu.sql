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
