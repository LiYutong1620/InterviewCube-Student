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
