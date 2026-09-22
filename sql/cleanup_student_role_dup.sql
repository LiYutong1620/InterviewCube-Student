-- ⚠️ 已并入 sql/student_patch.sql 的第 2 节（角色去重）（权威可执行版）。本文件保留留档，内容与合并版逐字一致。
--    从零重建 / 旧库补丁请直接跑对应的合并文件，不必逐个跑本目录的脚本。
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
