-- ============================================================
-- 学生端 · 旧库补丁（student_patch.sql）
-- ------------------------------------------------------------
-- 【什么时候用】只在**已经建过库、库里有数据、不想重建**的情况下用。
--   从零重建请用 sql/student_init.sql，**不要**跑本文件。
--
-- 【五节各自独立】可以只跑其中一节：
--   第 1 节 改列注释 —— 把 5 个字典对应列的 COMMENT 改成「码=含义」写法。
--            表结构（类型 / 默认值 / 可空性）完全不变，只改注释。幂等，可重跑。
--   第 2 节 角色去重 —— 删掉重复的「学生」角色 role_id 100 / 101（保留 102）。
--            ⚠️ 2026-09-22 已在开发库执行完毕。干净库里 role 100/101 不存在，
--            跑它是 no-op；但如果你的库里恰好有这两个 id 的**别的**角色，会误删。
--            跑之前先执行本节第 1 步的「核查」查询确认。
--   第 3 节 路由名修正 —— 把「学生档案」菜单的 route_name 设为 StudentProfile。
--            ⚠️ 2026-09-28 已在开发库执行完毕。
--            不修的话：点右上角头像「个人中心」会 404。幂等，可重跑。
--   第 4 节 运行时配置 —— 打开 sys.account.registerUser（手机号验证码注册要用）。
--            ⚠️ 直接改库不会刷新 Redis 参数缓存，应用正在运行时需重启或点「刷新缓存」。
--   第 5 节 「面试问答」菜单并入「面试环节」—— 把 6 个 interview:qa:* 按钮改挂到
--            「模拟面试场次」下，再删掉那条 C 型「面试问答」菜单（/student/qa 路由随之消失），
--            并把 :list 降级成 F 型按钮补回来 + 补绑「学生」角色。
--            ⚠️ 第 ③ 步必须做 —— :list 原本挂在 C 型菜单上，删菜单会连它一起删 → 学生 403。
--            权限点一个不少，后端 InterviewQaController 的 @PreAuthorize 照常放行。
--            ⚠️ 2026-09-28 已在开发库执行完毕（含回归修复）。幂等，可重跑。
--            新库不需要跑本节 —— student_init.sql 第 2 节直接建成新形状。
--
-- 【原始文件】sql/ 下 5 个源文件保留未删，各自头部有 banner 指向本文件。
-- 维护人：tong　最后更新：2026-09-28
-- ============================================================


-- ##########################################################################
-- ## 第 1 节 / 共 5 节　改列注释：把 5 个字典对应列的 COMMENT 改成「码=含义」
-- ## 来源：原 sql/alter_column_comment_to_code.sql（已并入本文件，原文件保留留档）
-- ## 幂等：是，可重跑；干净库跑完 student_init.sql 后注释已经是「码=含义」，跑本节是 no-op
-- ##########################################################################

-- ============================================================
-- 一次性脚本 —— 把 5 个字典对应列的 COMMENT 改成「码=含义」写法
-- ------------------------------------------------------------
-- 背景：2026-09-22 决定 dict_value 一律用码（不再存中文原文）。
--       表结构（类型 / 默认值 / 可空性）**完全不变**，只改列注释。
-- 用途：已经建过表的库用它同步注释；干净库直接跑 sql/student.sql 即可。
-- 幂等：是 —— MODIFY COLUMN 重复执行结果一致，可安全重跑
-- 前提：先跑完第 0 步的检查，确认这些列里没有残留的中文值
-- 详见：sql/student_dict.sql 头部的值域速查、doc/学生端对外契约.md
-- ============================================================

-- ------------------------------------------------------------
-- 0. 先检查：这 10 个列里有没有已经存了中文的历史数据
--    空结果 = 没有要迁移的数据，直接往下走
--    有结果 = 需要先手工把中文值映射成码，再改注释
-- ------------------------------------------------------------
select 'student_profile.education' as 列, education as 值
from student_profile where education is not null and education <> ''
union all
select 'student_job_profile.industry', industry
from student_job_profile where industry is not null and industry <> ''
union all
select 'student_job_profile.company_type', company_type
from student_job_profile where company_type is not null and company_type <> ''
union all
select 'interview_session.industry', industry
from interview_session where industry is not null and industry <> ''
union all
select 'interview_session.question_type', question_type
from interview_session where question_type is not null and question_type <> ''
union all
select 'interview_question.question_type', question_type
from interview_question where question_type is not null and question_type <> ''
union all
select 'question_bank.question_type', question_type
from question_bank where question_type is not null and question_type <> ''
union all
select 'question_bank.industry', industry
from question_bank where industry is not null and industry <> ''
union all
select 'question_bank.company_type', company_type
from question_bank where company_type is not null and company_type <> ''
union all
select 'question_bank.source', source
from question_bank where source is not null and source <> '';

-- ------------------------------------------------------------
-- 1. 学生档案 —— education
-- ------------------------------------------------------------
alter table student_profile
  modify column `education` VARCHAR(20) DEFAULT '' COMMENT '学历(1专科 2本科 3硕士 4博士)';

-- ------------------------------------------------------------
-- 2. 学生岗位画像 —— industry / company_type
-- ------------------------------------------------------------
alter table student_job_profile
  modify column `industry`     VARCHAR(50) DEFAULT '' COMMENT '行业(1技术 2产品 3运营 4财务 5教师)',
  modify column `company_type` VARCHAR(50) DEFAULT '' COMMENT '目标企业类型(1BAT 2央企 3外企 4其他)';

-- ------------------------------------------------------------
-- 3. 模拟面试场次 —— industry / question_type
-- ------------------------------------------------------------
alter table interview_session
  modify column `industry`      VARCHAR(50) DEFAULT '' COMMENT '行业(1技术 2产品 3运营 4财务 5教师)',
  modify column `question_type` VARCHAR(50) DEFAULT '' COMMENT '题型(1行为面 2技术面 3HR面 4case面)';

-- ------------------------------------------------------------
-- 4. 面试题目 —— question_type
-- ------------------------------------------------------------
alter table interview_question
  modify column `question_type` VARCHAR(50) DEFAULT '' COMMENT '题型(1行为面 2技术面 3HR面 4case面)';

-- ------------------------------------------------------------
-- 5. 题库题目 —— question_type / industry / company_type / source
-- ------------------------------------------------------------
alter table question_bank
  modify column `question_type` VARCHAR(50) DEFAULT '' COMMENT '题型(1行为面 2技术面 3HR面 4case面)',
  modify column `industry`      VARCHAR(50) DEFAULT '' COMMENT '行业(1技术 2产品 3运营 4财务 5教师)',
  modify column `company_type` VARCHAR(50) DEFAULT '' COMMENT '企业类型(1BAT 2央企 3外企 4其他)',
  modify column `source`        VARCHAR(50) DEFAULT '' COMMENT '来源(1真题 2模拟 3AI生成)';

-- ------------------------------------------------------------
-- 6. 复核：应返回 10 行，且 column_comment 里都带「码=含义」
-- ------------------------------------------------------------
select table_name as 表, column_name as 列, column_type as 类型, column_comment as 注释
from information_schema.columns
where table_schema = database()
  and (
        (table_name = 'student_profile'     and column_name = 'education')
     or (table_name = 'student_job_profile' and column_name in ('industry', 'company_type'))
     or (table_name = 'interview_session'   and column_name in ('industry', 'question_type'))
     or (table_name = 'interview_question'  and column_name = 'question_type')
     or (table_name = 'question_bank'       and column_name in ('question_type', 'industry', 'company_type', 'source'))
      )
order by table_name, ordinal_position;


-- ##########################################################################
-- ## 第 2 节 / 共 5 节　角色去重：删掉重复的「学生」角色 role_id 100 / 101（保留 102）
-- ## 来源：原 sql/cleanup_student_role_dup.sql（已并入本文件，原文件保留留档）
-- ## ⚠️ 一次性脚本，2026-09-22 已在开发库执行完毕。
-- ## 跑之前务必先执行本节内的「第 1 步：核查」查询，确认 100/101 确实是重复的学生角色。
-- ##########################################################################

-- ============================================================================
-- 清理重复的「学生」角色（保留 role_id = 102）
-- 作者：tong    日期：2026-09-22
-- ----------------------------------------------------------------------------
-- 背景：
--   sys_role 中 role_id 100 / 101 / 102 的 role_key 都是 'student'，是同一角色被重复创建。
--   其中 100 / 101 的 del_flag = '2'（已被若依逻辑删除），属于残留数据；
--   102 是唯一在用的（有 49 条 sys_role_menu 绑定，且被 user_id = 103 绑定）。
-- 结论：
--   100 / 101 既无 sys_user_role 绑定，也无 sys_role_menu 绑定，可安全物理删除。
-- 执行方式：
--   第 1 步单独执行并核对结果，确认 user_cnt / menu_cnt 均为 0 后，再执行第 2 步。
-- ============================================================================

-- ---------- 第 1 步：核查现状（先执行这一段，确认两个计数都是 0） ----------
select r.role_id,
       r.role_name,
       r.role_key,
       r.del_flag,
       (select count(*) from sys_user_role ur where ur.role_id = r.role_id) as user_cnt,
       (select count(*) from sys_role_menu rm where rm.role_id = r.role_id) as menu_cnt
from sys_role r
where r.role_key = 'student'
order by r.role_id;

-- 用户侧核查：应只有 1(admin) / 2(ry) / 103(student01)
select user_id, user_name, nick_name, del_flag from sys_user order by user_id;

-- ---------- 第 2 步：删除残留角色（保留 102） ----------
delete from sys_user_role where role_id in (100, 101);
delete from sys_role_menu where role_id in (100, 101);
delete from sys_role      where role_id in (100, 101);

-- ---------- 第 3 步：复核 ----------
select role_id, role_name, role_key, del_flag from sys_role where role_key = 'student';
select user_id, role_id from sys_user_role where role_id = 102;


-- ##########################################################################
-- ## 第 3 节 / 共 5 节　修正「学生档案」菜单的路由名称（route_name）
-- ## 来源：原 sql/student_route_name_fix.sql（已并入本文件，原文件保留留档）
-- ## ⚠️ 一次性脚本，2026-09-28 已在开发库执行完毕。幂等，可重跑。
-- ## 不修的话：点右上角头像「个人中心」跳到 /user/profile 显示 404。
-- ##########################################################################

-- 【现象】登录后点右上角头像 →「个人中心」，跳到 /user/profile 显示 404。
--
-- 【原因】若依后端 SysMenuServiceImpl.getRouteName() 在菜单 route_name 为空时
--         取 path 并首字母大写作为前端路由名。学生端「学生档案」菜单的
--         path = 'profile' → 生成路由名 'Profile'，而前端 constantRoutes 里
--         个人中心 /user/profile 的路由名**也是** 'Profile'。
--         前端 store/modules/permission.js 用 router.addRoute() 注册动态路由，
--         vue-router 4 遇到同名路由会**先移除旧路由**，于是个人中心被顶掉，
--         /user/profile 落入 /:pathMatch(.*)* 兜底 → 404。
--         顺带还会让「首次登录强制改密码」的 router.push({name:'Profile'}) 跳到学生档案。
--
-- 【修法】给该菜单显式配置 route_name = 'StudentProfile'，路由名不再撞车。
--         URL 仍是 /student/profile，路径与权限标识都不变。
--         前端 views/interview/profile/index.vue 的 <script setup name> 同步改为
--         StudentProfile（keep-alive 按组件名匹配，需与路由名一致）。
--
-- 【通用规则】凡是新增菜单，若其 path 首字母大写后与前端内置路由名相同
--         （Index / Profile / AuthRole / AuthUser / Data / JobLog / GenEdit），
--         必须显式设置 route_name 区分。见 doc/学生端对外契约.md。

-- ---------- 第 1 步：核查现状 ----------
-- 期望：恰好 1 行。route_name 为空 → 还没修；已是 StudentProfile → 已修好。
select menu_id, menu_name, path, route_name, perms
from sys_menu
where perms = 'interview:profile:list' and menu_type = 'C';

-- ---------- 第 2 步：修正 ----------
update sys_menu set route_name = 'StudentProfile'
 where perms = 'interview:profile:list' and menu_type = 'C'
   and (route_name is null or route_name = '');

-- ---------- 第 3 步：复核 ----------
-- 期望：恰好 1 行，route_name = 'StudentProfile'
select menu_id, menu_name, path, route_name, perms
from sys_menu
where perms = 'interview:profile:list' and menu_type = 'C';


-- ##########################################################################
-- ## 第 4 节 / 共 5 节　运行时配置：打开注册开关（sys_config）
-- ## 来源：原 sql/student_auth_config.sql（已并入本文件，原文件保留留档）
-- ## 幂等：是，可重跑；只改 sys_config 里 sys.account.registerUser 这一行的值。
-- ## ⚠️ 应用**正在运行**时跑本节，改了不生效 —— 必须重启后端，
-- ##    或去「系统管理 → 参数设置」点一次「刷新缓存」（Redis 参数缓存无过期时间）。
-- ##########################################################################

-- ============================================================
-- 学生端 · 运行时配置（sys_config）
-- ------------------------------------------------------------
-- 【作用】把学生端功能依赖的 sys_config 开关设成「开箱可用」的值。
--
-- 【背景】sys_config 的数据来自若依官方脚本 RuoYi-Vue/sql/ry_20260417.sql，
--         官方默认 sys.account.registerUser = false（不开放注册）。
--         学生端要做「手机号验证码注册」，所以必须打开。
--         关着的话：前端登录页不显示「立即注册」入口，
--         且 /interview/auth/register/phone 会直接返回「当前系统没有开启注册功能」。
--
-- 【幂等】是 —— UPDATE 重复执行结果一致，可安全重跑。
-- 【不改表结构】只动一行数据的值，不写死 config_id（sys_config 主键自增）。
--
-- ⚠️ 【重要】直接跑 SQL 改 sys_config，**不会**自动刷新 Redis 里的参数缓存
--    （若依缓存 key = sys_config:<config_key>，且**没有过期时间**）。
--    所以：
--      · 从零重建 / 重启过应用 → 无需额外操作
--      · 应用**正在运行**时跑本文件 → 必须二选一：
--          ① 重启后端；或
--          ② 在「系统管理 → 参数设置」点一次「刷新缓存」
--             （等价于 DELETE /system/config/refreshCache）
--        否则改了也不生效，会以为脚本没起作用。
--
-- 详见：doc/学生端对外契约.md「认证扩展接口」一节
-- 维护人：tong　创建日期：2026-09-28
-- ============================================================


-- ------------------------------------------------------------
-- 1. 核查现状
-- ------------------------------------------------------------
select config_id, config_name, config_key, config_value, update_time
from sys_config
where config_key = 'sys.account.registerUser';


-- ------------------------------------------------------------
-- 2. 打开注册开关
-- ------------------------------------------------------------
update sys_config
   set config_value = 'true',
       update_by    = 'system',
       update_time  = sysdate()
 where config_key = 'sys.account.registerUser';


-- ------------------------------------------------------------
-- 3. 复核：期望恰好 1 行，config_value = 'true'
-- ------------------------------------------------------------
select config_id, config_name, config_key, config_value, update_time
from sys_config
where config_key = 'sys.account.registerUser';


-- ##########################################################################
-- ## 第 5 节 / 共 5 节　「面试问答」菜单并入「面试环节」（含 :list 权限点回归修复）
-- ## 来源：原 sql/student_qa_merge_menu.sql（已并入本文件，原文件保留留档）
-- ## ⚠️ 一次性脚本，2026-09-28 已在开发库执行完毕（含回归修复）。幂等，可重跑。
-- ## 做三件事：① 把 interview:qa:* 按钮改挂到「模拟面试场次」下；
-- ## ② 删掉 C 型「面试问答」模块菜单（顺带解绑角色 → 菜单关系），/student/qa 路由随之消失；
-- ## ③ 把 interview:qa:list 降级成 F 型按钮补回来，并补绑「学生」角色。
-- ## ⚠️ 第 ③ 步是关键：:list 平时挂在 C 型菜单上，删菜单会连它一起删 → GET /interview/qa/list 403。
-- ## 权限点一个不少 —— 后端 InterviewQaController 六个接口都带 @PreAuthorize，删了就 403。
-- ## 新库不需要跑本节，student_init.sql 第 2 节直接建成新形状。
-- ##########################################################################

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

