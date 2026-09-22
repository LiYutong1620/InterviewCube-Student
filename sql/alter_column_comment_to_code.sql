-- ⚠️ 已并入 sql/student_patch.sql 的第 1 节（改列注释）（权威可执行版）。本文件保留留档，内容与合并版逐字一致。
--    从零重建 / 旧库补丁请直接跑对应的合并文件，不必逐个跑本目录的脚本。
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
