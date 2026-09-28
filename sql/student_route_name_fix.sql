-- ⚠️ 已并入 sql/student_patch.sql（第 3 节），不要单独跑本文件
--    从零重建 / 旧库补丁请用 sql/student_init.sql / sql/student_patch.sql
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
