-- ============================================================
-- 学生端 · 旧库补丁（student_patch.sql）
-- ------------------------------------------------------------
-- 【什么时候用】只在**已经建过库、库里有数据、不想重建**的情况下用。
--   从零重建请用 sql/student_init.sql，**不要**跑本文件。
--
-- 【两节各自独立】可以只跑其中一节：
--   第 1 节 改列注释 —— 把 5 个字典对应列的 COMMENT 改成「码=含义」写法。
--            表结构（类型 / 默认值 / 可空性）完全不变，只改注释。幂等，可重跑。
--   第 2 节 角色去重 —— 删掉重复的「学生」角色 role_id 100 / 101（保留 102）。
--            ⚠️ 2026-09-22 已在开发库执行完毕。干净库里 role 100/101 不存在，
--            跑它是 no-op；但如果你的库里恰好有这两个 id 的**别的**角色，会误删。
--            跑之前先执行本节第 1 步的「核查」查询确认。
--
-- 【原始文件】sql/ 下 2 个源文件保留未删，各自头部有 banner 指向本文件。
-- 维护人：tong　最后更新：2026-09-22
-- ============================================================


-- ##########################################################################
-- ## 第 1 节 / 共 2 节　改列注释：把 5 个字典对应列的 COMMENT 改成「码=含义」
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
-- ## 第 2 节 / 共 2 节　角色去重：删掉重复的「学生」角色 role_id 100 / 101（保留 102）
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

