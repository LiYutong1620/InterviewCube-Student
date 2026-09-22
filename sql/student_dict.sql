-- ⚠️ 已并入 sql/student_init.sql 的第 4 节（业务字典）（权威可执行版）。本文件保留留档，内容与合并版逐字一致。
--    从零重建 / 旧库补丁请直接跑对应的合并文件，不必逐个跑本目录的脚本。
-- ============================================================
-- 字典 SQL —— 学生端业务字典
-- ------------------------------------------------------------
-- 作用：注册 13 个字典类型 + 45 条字典数据
-- 前置：若依基础库（sys_dict_type / sys_dict_data 建好）
-- 幂等：是 —— 所有 insert 均带 where not exists 守卫，可重复执行
-- 说明：不写死 dict_id / dict_code，由自增分配（若依两表自增都从 100 起）
-- 校验：文件末尾自带查询，应返回 13 / 45
-- 详见：sql/README.md、doc/CRUD字段清单.md 第四节、doc/学生端对外契约.md
-- ============================================================

-- ============================================================
-- 值域速查（dict_value 一律用码，不用中文原文）
-- ------------------------------------------------------------
-- 约定：业务表里存的是 dict_value；dict_label 只是给人看的。
--       所以改文案只改本文件的 dict_label，业务数据零迁移。
-- ============================================================
--   student_education          1=专科 2=本科 3=硕士 4=博士
--   student_industry           1=技术 2=产品 3=运营 4=财务 5=教师
--   student_difficulty         1=初级 2=中级 3=高级
--   student_company_type       1=BAT 2=央企 3=外企 4=其他
--   interview_question_type    1=行为面 2=技术面 3=HR面 4=case面
--   interview_session_status   0=未开始 1=进行中 2=已完成 3=已中断
--   interview_answer_type      1=文字 2=语音 3=视频
--   student_resume_source      1=本地上传 2=拍照导入
--   student_parse_status       0=未解析 1=解析中 2=解析成功 3=解析失败
--   interview_question_source  1=AI生成 2=题库抽取 3=简历解析
--   question_bank_source       1=真题 2=模拟 3=AI生成
--   student_guide_status       0=未完成 1=已完成
--   interview_report_status    0=待生成 1=生成中 2=生成成功 3=生成失败
--
-- 对应业务列：
--   student_education          student_profile.education
--   student_industry           student_job_profile.industry / interview_session.industry / question_bank.industry
--   student_difficulty         student_job_profile.difficulty / interview_session.difficulty / question_bank.difficulty
--   student_company_type       student_job_profile.company_type / question_bank.company_type
--   interview_question_type    interview_session.question_type / interview_question.question_type / question_bank.question_type
--   interview_session_status   interview_session.status
--   interview_answer_type      interview_qa.answer_type
--   student_resume_source      student_resume.source_type
--   student_parse_status       student_resume.parse_status
--   interview_question_source  interview_question.source
--   question_bank_source       question_bank.source
--   student_guide_status       student_profile.guide_status
--   interview_report_status    interview_report.generate_status
-- ============================================================

-- ------------------------------------------------------------
-- 一、字典类型
-- ------------------------------------------------------------
insert into sys_dict_type (dict_name, dict_type, status, create_by, create_time, update_by, update_time, remark)
select '学生学历', 'student_education', '0', 'admin', sysdate(), '', null, '学生档案·学历'
from dual
where not exists (select 1 from sys_dict_type where dict_type = 'student_education');

insert into sys_dict_type (dict_name, dict_type, status, create_by, create_time, update_by, update_time, remark)
select '学生行业', 'student_industry', '0', 'admin', sysdate(), '', null, '岗位画像/面试场次/题库·行业'
from dual
where not exists (select 1 from sys_dict_type where dict_type = 'student_industry');

insert into sys_dict_type (dict_name, dict_type, status, create_by, create_time, update_by, update_time, remark)
select '面试难度', 'student_difficulty', '0', 'admin', sysdate(), '', null, '岗位画像/面试场次/题库·难度'
from dual
where not exists (select 1 from sys_dict_type where dict_type = 'student_difficulty');

insert into sys_dict_type (dict_name, dict_type, status, create_by, create_time, update_by, update_time, remark)
select '目标企业类型', 'student_company_type', '0', 'admin', sysdate(), '', null, '岗位画像/题库·企业类型'
from dual
where not exists (select 1 from sys_dict_type where dict_type = 'student_company_type');

insert into sys_dict_type (dict_name, dict_type, status, create_by, create_time, update_by, update_time, remark)
select '面试题型', 'interview_question_type', '0', 'admin', sysdate(), '', null, '面试场次/面试题目/题库·题型'
from dual
where not exists (select 1 from sys_dict_type where dict_type = 'interview_question_type');

insert into sys_dict_type (dict_name, dict_type, status, create_by, create_time, update_by, update_time, remark)
select '面试场次状态', 'interview_session_status', '0', 'admin', sysdate(), '', null, '模拟面试场次·状态'
from dual
where not exists (select 1 from sys_dict_type where dict_type = 'interview_session_status');

insert into sys_dict_type (dict_name, dict_type, status, create_by, create_time, update_by, update_time, remark)
select '作答方式', 'interview_answer_type', '0', 'admin', sysdate(), '', null, '面试问答·作答方式（阶段一仅文字）'
from dual
where not exists (select 1 from sys_dict_type where dict_type = 'interview_answer_type');

insert into sys_dict_type (dict_name, dict_type, status, create_by, create_time, update_by, update_time, remark)
select '简历来源', 'student_resume_source', '0', 'admin', sysdate(), '', null, '学生简历·来源'
from dual
where not exists (select 1 from sys_dict_type where dict_type = 'student_resume_source');

insert into sys_dict_type (dict_name, dict_type, status, create_by, create_time, update_by, update_time, remark)
select '简历解析状态', 'student_parse_status', '0', 'admin', sysdate(), '', null, '学生简历·AI解析状态（阶段一不启用）'
from dual
where not exists (select 1 from sys_dict_type where dict_type = 'student_parse_status');

insert into sys_dict_type (dict_name, dict_type, status, create_by, create_time, update_by, update_time, remark)
select '面试题目来源', 'interview_question_source', '0', 'admin', sysdate(), '', null, '面试题目·来源（注意与题库来源值域不同）'
from dual
where not exists (select 1 from sys_dict_type where dict_type = 'interview_question_source');

insert into sys_dict_type (dict_name, dict_type, status, create_by, create_time, update_by, update_time, remark)
select '题库题目来源', 'question_bank_source', '0', 'admin', sysdate(), '', null, '题库题目·来源（注意与题目来源值域不同）'
from dual
where not exists (select 1 from sys_dict_type where dict_type = 'question_bank_source');

insert into sys_dict_type (dict_name, dict_type, status, create_by, create_time, update_by, update_time, remark)
select '引导完成状态', 'student_guide_status', '0', 'admin', sysdate(), '', null, '学生档案·引导流程是否走完'
from dual
where not exists (select 1 from sys_dict_type where dict_type = 'student_guide_status');

insert into sys_dict_type (dict_name, dict_type, status, create_by, create_time, update_by, update_time, remark)
select '复盘报告生成状态', 'interview_report_status', '0', 'admin', sysdate(), '', null, '面试复盘报告·生成状态'
from dual
where not exists (select 1 from sys_dict_type where dict_type = 'interview_report_status');

-- ------------------------------------------------------------
-- 二、字典数据
-- 存在判据：(dict_type, dict_value) 组合
-- ------------------------------------------------------------
-- student_education（学生学历）
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark)
select 1, '专科', '1', 'student_education', '', '', 'Y', '0', 'admin', sysdate(), '', null, ''
from dual
where not exists (select 1 from sys_dict_data where dict_type = 'student_education' and dict_value = '1');
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark)
select 2, '本科', '2', 'student_education', '', 'primary', 'N', '0', 'admin', sysdate(), '', null, ''
from dual
where not exists (select 1 from sys_dict_data where dict_type = 'student_education' and dict_value = '2');
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark)
select 3, '硕士', '3', 'student_education', '', 'success', 'N', '0', 'admin', sysdate(), '', null, ''
from dual
where not exists (select 1 from sys_dict_data where dict_type = 'student_education' and dict_value = '3');
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark)
select 4, '博士', '4', 'student_education', '', 'warning', 'N', '0', 'admin', sysdate(), '', null, ''
from dual
where not exists (select 1 from sys_dict_data where dict_type = 'student_education' and dict_value = '4');

-- student_industry（学生行业）
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark)
select 1, '技术', '1', 'student_industry', '', '', 'Y', '0', 'admin', sysdate(), '', null, ''
from dual
where not exists (select 1 from sys_dict_data where dict_type = 'student_industry' and dict_value = '1');
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark)
select 2, '产品', '2', 'student_industry', '', '', 'N', '0', 'admin', sysdate(), '', null, ''
from dual
where not exists (select 1 from sys_dict_data where dict_type = 'student_industry' and dict_value = '2');
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark)
select 3, '运营', '3', 'student_industry', '', '', 'N', '0', 'admin', sysdate(), '', null, ''
from dual
where not exists (select 1 from sys_dict_data where dict_type = 'student_industry' and dict_value = '3');
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark)
select 4, '财务', '4', 'student_industry', '', '', 'N', '0', 'admin', sysdate(), '', null, ''
from dual
where not exists (select 1 from sys_dict_data where dict_type = 'student_industry' and dict_value = '4');
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark)
select 5, '教师', '5', 'student_industry', '', '', 'N', '0', 'admin', sysdate(), '', null, ''
from dual
where not exists (select 1 from sys_dict_data where dict_type = 'student_industry' and dict_value = '5');

-- student_difficulty（面试难度）
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark)
select 1, '初级', '1', 'student_difficulty', '', 'success', 'Y', '0', 'admin', sysdate(), '', null, ''
from dual
where not exists (select 1 from sys_dict_data where dict_type = 'student_difficulty' and dict_value = '1');
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark)
select 2, '中级', '2', 'student_difficulty', '', 'warning', 'N', '0', 'admin', sysdate(), '', null, ''
from dual
where not exists (select 1 from sys_dict_data where dict_type = 'student_difficulty' and dict_value = '2');
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark)
select 3, '高级', '3', 'student_difficulty', '', 'danger', 'N', '0', 'admin', sysdate(), '', null, ''
from dual
where not exists (select 1 from sys_dict_data where dict_type = 'student_difficulty' and dict_value = '3');

-- student_company_type（目标企业类型）
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark)
select 1, 'BAT', '1', 'student_company_type', '', '', 'Y', '0', 'admin', sysdate(), '', null, ''
from dual
where not exists (select 1 from sys_dict_data where dict_type = 'student_company_type' and dict_value = '1');
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark)
select 2, '央企', '2', 'student_company_type', '', '', 'N', '0', 'admin', sysdate(), '', null, ''
from dual
where not exists (select 1 from sys_dict_data where dict_type = 'student_company_type' and dict_value = '2');
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark)
select 3, '外企', '3', 'student_company_type', '', '', 'N', '0', 'admin', sysdate(), '', null, ''
from dual
where not exists (select 1 from sys_dict_data where dict_type = 'student_company_type' and dict_value = '3');
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark)
select 4, '其他', '4', 'student_company_type', '', '', 'N', '0', 'admin', sysdate(), '', null, ''
from dual
where not exists (select 1 from sys_dict_data where dict_type = 'student_company_type' and dict_value = '4');

-- interview_question_type（面试题型）
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark)
select 1, '行为面', '1', 'interview_question_type', '', '', 'Y', '0', 'admin', sysdate(), '', null, ''
from dual
where not exists (select 1 from sys_dict_data where dict_type = 'interview_question_type' and dict_value = '1');
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark)
select 2, '技术面', '2', 'interview_question_type', '', '', 'N', '0', 'admin', sysdate(), '', null, ''
from dual
where not exists (select 1 from sys_dict_data where dict_type = 'interview_question_type' and dict_value = '2');
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark)
select 3, 'HR面', '3', 'interview_question_type', '', '', 'N', '0', 'admin', sysdate(), '', null, ''
from dual
where not exists (select 1 from sys_dict_data where dict_type = 'interview_question_type' and dict_value = '3');
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark)
select 4, 'case面', '4', 'interview_question_type', '', '', 'N', '0', 'admin', sysdate(), '', null, ''
from dual
where not exists (select 1 from sys_dict_data where dict_type = 'interview_question_type' and dict_value = '4');

-- interview_session_status（面试场次状态）
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark)
select 1, '未开始', '0', 'interview_session_status', '', 'info', 'Y', '0', 'admin', sysdate(), '', null, ''
from dual
where not exists (select 1 from sys_dict_data where dict_type = 'interview_session_status' and dict_value = '0');
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark)
select 2, '进行中', '1', 'interview_session_status', '', 'primary', 'N', '0', 'admin', sysdate(), '', null, ''
from dual
where not exists (select 1 from sys_dict_data where dict_type = 'interview_session_status' and dict_value = '1');
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark)
select 3, '已完成', '2', 'interview_session_status', '', 'success', 'N', '0', 'admin', sysdate(), '', null, ''
from dual
where not exists (select 1 from sys_dict_data where dict_type = 'interview_session_status' and dict_value = '2');
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark)
select 4, '已中断', '3', 'interview_session_status', '', 'danger', 'N', '0', 'admin', sysdate(), '', null, ''
from dual
where not exists (select 1 from sys_dict_data where dict_type = 'interview_session_status' and dict_value = '3');

-- interview_answer_type（作答方式）
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark)
select 1, '文字', '1', 'interview_answer_type', '', '', 'Y', '0', 'admin', sysdate(), '', null, ''
from dual
where not exists (select 1 from sys_dict_data where dict_type = 'interview_answer_type' and dict_value = '1');
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark)
select 2, '语音', '2', 'interview_answer_type', '', '', 'N', '0', 'admin', sysdate(), '', null, ''
from dual
where not exists (select 1 from sys_dict_data where dict_type = 'interview_answer_type' and dict_value = '2');
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark)
select 3, '视频', '3', 'interview_answer_type', '', '', 'N', '0', 'admin', sysdate(), '', null, ''
from dual
where not exists (select 1 from sys_dict_data where dict_type = 'interview_answer_type' and dict_value = '3');

-- student_resume_source（简历来源）
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark)
select 1, '本地上传', '1', 'student_resume_source', '', '', 'Y', '0', 'admin', sysdate(), '', null, ''
from dual
where not exists (select 1 from sys_dict_data where dict_type = 'student_resume_source' and dict_value = '1');
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark)
select 2, '拍照导入', '2', 'student_resume_source', '', '', 'N', '0', 'admin', sysdate(), '', null, ''
from dual
where not exists (select 1 from sys_dict_data where dict_type = 'student_resume_source' and dict_value = '2');

-- student_parse_status（简历解析状态）
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark)
select 1, '未解析', '0', 'student_parse_status', '', 'info', 'Y', '0', 'admin', sysdate(), '', null, ''
from dual
where not exists (select 1 from sys_dict_data where dict_type = 'student_parse_status' and dict_value = '0');
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark)
select 2, '解析中', '1', 'student_parse_status', '', 'primary', 'N', '0', 'admin', sysdate(), '', null, ''
from dual
where not exists (select 1 from sys_dict_data where dict_type = 'student_parse_status' and dict_value = '1');
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark)
select 3, '解析成功', '2', 'student_parse_status', '', 'success', 'N', '0', 'admin', sysdate(), '', null, ''
from dual
where not exists (select 1 from sys_dict_data where dict_type = 'student_parse_status' and dict_value = '2');
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark)
select 4, '解析失败', '3', 'student_parse_status', '', 'danger', 'N', '0', 'admin', sysdate(), '', null, ''
from dual
where not exists (select 1 from sys_dict_data where dict_type = 'student_parse_status' and dict_value = '3');

-- interview_question_source（面试题目来源）
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark)
select 1, 'AI生成', '1', 'interview_question_source', '', '', 'Y', '0', 'admin', sysdate(), '', null, ''
from dual
where not exists (select 1 from sys_dict_data where dict_type = 'interview_question_source' and dict_value = '1');
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark)
select 2, '题库抽取', '2', 'interview_question_source', '', '', 'N', '0', 'admin', sysdate(), '', null, ''
from dual
where not exists (select 1 from sys_dict_data where dict_type = 'interview_question_source' and dict_value = '2');
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark)
select 3, '简历解析', '3', 'interview_question_source', '', '', 'N', '0', 'admin', sysdate(), '', null, ''
from dual
where not exists (select 1 from sys_dict_data where dict_type = 'interview_question_source' and dict_value = '3');

-- question_bank_source（题库题目来源）
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark)
select 1, '真题', '1', 'question_bank_source', '', '', 'Y', '0', 'admin', sysdate(), '', null, ''
from dual
where not exists (select 1 from sys_dict_data where dict_type = 'question_bank_source' and dict_value = '1');
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark)
select 2, '模拟', '2', 'question_bank_source', '', '', 'N', '0', 'admin', sysdate(), '', null, ''
from dual
where not exists (select 1 from sys_dict_data where dict_type = 'question_bank_source' and dict_value = '2');
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark)
select 3, 'AI生成', '3', 'question_bank_source', '', '', 'N', '0', 'admin', sysdate(), '', null, ''
from dual
where not exists (select 1 from sys_dict_data where dict_type = 'question_bank_source' and dict_value = '3');

-- student_guide_status（引导完成状态）
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark)
select 1, '未完成', '0', 'student_guide_status', '', 'info', 'Y', '0', 'admin', sysdate(), '', null, ''
from dual
where not exists (select 1 from sys_dict_data where dict_type = 'student_guide_status' and dict_value = '0');
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark)
select 2, '已完成', '1', 'student_guide_status', '', 'success', 'N', '0', 'admin', sysdate(), '', null, ''
from dual
where not exists (select 1 from sys_dict_data where dict_type = 'student_guide_status' and dict_value = '1');

-- interview_report_status（复盘报告生成状态）
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark)
select 1, '待生成', '0', 'interview_report_status', '', 'info', 'Y', '0', 'admin', sysdate(), '', null, ''
from dual
where not exists (select 1 from sys_dict_data where dict_type = 'interview_report_status' and dict_value = '0');
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark)
select 2, '生成中', '1', 'interview_report_status', '', 'primary', 'N', '0', 'admin', sysdate(), '', null, ''
from dual
where not exists (select 1 from sys_dict_data where dict_type = 'interview_report_status' and dict_value = '1');
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark)
select 3, '生成成功', '2', 'interview_report_status', '', 'success', 'N', '0', 'admin', sysdate(), '', null, ''
from dual
where not exists (select 1 from sys_dict_data where dict_type = 'interview_report_status' and dict_value = '2');
insert into sys_dict_data (dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, update_by, update_time, remark)
select 4, '生成失败', '3', 'interview_report_status', '', 'danger', 'N', '0', 'admin', sysdate(), '', null, ''
from dual
where not exists (select 1 from sys_dict_data where dict_type = 'interview_report_status' and dict_value = '3');

-- ------------------------------------------------------------
-- 三、校验
-- 预期：字典类型 = 13，字典数据 = 45
-- ------------------------------------------------------------
select '字典类型' as 项, count(*) as 数量
from sys_dict_type
where dict_type in ('student_education', 'student_industry', 'student_difficulty', 'student_company_type', 'interview_question_type', 'interview_session_status', 'interview_answer_type', 'student_resume_source', 'student_parse_status', 'interview_question_source', 'question_bank_source', 'student_guide_status', 'interview_report_status')
union all
select '字典数据', count(*)
from sys_dict_data
where dict_type in ('student_education', 'student_industry', 'student_difficulty', 'student_company_type', 'interview_question_type', 'interview_session_status', 'interview_answer_type', 'student_resume_source', 'student_parse_status', 'interview_question_source', 'question_bank_source', 'student_guide_status', 'interview_report_status');
