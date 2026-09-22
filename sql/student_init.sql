-- ============================================================
-- 学生端 · 一键重建脚本（student_init.sql）
-- ------------------------------------------------------------
-- 【作用】把「从零重建学生端」要跑的 5 个脚本合并成一个文件，跑完就有：
--   ① 8 张业务表（DROP + CREATE）
--   ② 学生端菜单（1 目录 + 9 模块菜单 + 42 按钮）+ interview:data:all 权限点
--   ③ 「学生」角色 + student01 / student02 账号 + 角色菜单绑定
--   ④ 13 个业务字典类型 + 45 条字典数据
--   ⑤ 26 道题库演示题（可选，不需要就把第 5 节整段注释掉）
--
-- 【前置】必须先跑 RuoYi-Vue/sql/ry_20260417.sql + RuoYi-Vue/sql/quartz.sql
--         （若依基础库，建 sys_* / gen_* / qrtz_*）
--
-- ⚠️ 【危险】第 1 节是 DROP TABLE + CREATE —— 会**清空这 8 张业务表**！
--    只想在已有数据的库上补东西，不要跑本文件；用 sql/student_patch.sql。
--
-- 【幂等】第 2 ~ 5 节幂等，可重复执行；第 1 节不是（会重建表）。
-- 【顺序】文件内已排好：建表 → 菜单 → 角色账号 → 字典 → 演示数据。
--         各节自带校验查询；文件末尾另有一份「总校验」。
-- 【原始文件】sql/ 下 5 个源文件保留未删，各自头部有 banner 指向本文件。
-- 【旧库补丁】已建过库的、只想同步列注释或清理重复角色 → sql/student_patch.sql
-- 维护人：tong　最后更新：2026-09-22
-- ============================================================


-- ##########################################################################
-- ## 第 1 节 / 共 5 节　建表：8 张业务表
-- ## 来源：原 sql/student.sql（已并入本文件，原文件保留留档）
-- ## ⚠️ 本节含 DROP TABLE IF EXISTS —— 会清空这 8 张表！只用于从零重建。
-- ## 非幂等；前置：RuoYi-Vue/sql/ry_20260417.sql
-- ##########################################################################

-- ============================================================
-- 【学生端 · 建表脚本】 可执行 / 权威
-- ------------------------------------------------------------
-- 内容：8 张业务表的 DROP + CREATE
--       student_profile / student_resume / student_job_profile
--       interview_session / interview_question / interview_qa
--       interview_report / question_bank
-- 不含：若依自身的 sys_* 表、菜单数据、角色与账号数据
-- 幂等：否 —— 带 DROP TABLE IF EXISTS，执行会清空这 8 张表
-- 用法：在已建好的 ry-vue 库上执行
-- 详见：sql/README.md
-- ============================================================

-- ----------------------------
-- 数据库: MySQL 8.0+ / utf8mb4
-- ----------------------------

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- 1. 学生档案表
-- ----------------------------
DROP TABLE IF EXISTS `student_profile`;
CREATE TABLE `student_profile` (
  `id`              BIGINT(20)   NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id`         BIGINT(20)   NOT NULL                COMMENT '关联若依用户ID(sys_user.user_id)',
  `nickname`        VARCHAR(50)  DEFAULT ''              COMMENT '昵称',
  `avatar`          VARCHAR(255) DEFAULT ''              COMMENT '头像地址',
  `real_name`       VARCHAR(50)  DEFAULT ''              COMMENT '真实姓名',
  `gender`          CHAR(1)      DEFAULT '2'             COMMENT '性别(0男 1女 2未知)',
  `phone`           VARCHAR(20)  DEFAULT ''              COMMENT '手机号',
  `email`           VARCHAR(100) DEFAULT ''              COMMENT '邮箱',
  `school`          VARCHAR(100) DEFAULT ''              COMMENT '学校',
  `major`           VARCHAR(100) DEFAULT ''              COMMENT '专业',
  `education`       VARCHAR(20)  DEFAULT ''              COMMENT '学历(1专科 2本科 3硕士 4博士)',
  `graduation_year` VARCHAR(10)  DEFAULT ''              COMMENT '毕业年份',
  `guide_status`    CHAR(1)      DEFAULT '0'             COMMENT '引导状态(0未完成 1已完成)',
  `current_level`   VARCHAR(20)  DEFAULT '小白'          COMMENT '当前等级',
  `current_points`  INT(11)      DEFAULT 0               COMMENT '当前积分',
  `status`          CHAR(1)      DEFAULT '0'             COMMENT '状态(0正常 1停用)',
  `del_flag`        CHAR(1)      DEFAULT '0'             COMMENT '删除标志(0存在 2删除)',
  `create_by`       VARCHAR(64)  DEFAULT ''              COMMENT '创建者',
  `create_time`     DATETIME     DEFAULT NULL            COMMENT '创建时间',
  `update_by`       VARCHAR(64)  DEFAULT ''              COMMENT '更新者',
  `update_time`     DATETIME     DEFAULT NULL            COMMENT '更新时间',
  `remark`          VARCHAR(500) DEFAULT NULL            COMMENT '备注',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='学生档案表';

-- ----------------------------
-- 2. 学生简历表
-- ----------------------------
DROP TABLE IF EXISTS `student_resume`;
CREATE TABLE `student_resume` (
  `id`            BIGINT(20)   NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id`       BIGINT(20)   NOT NULL                COMMENT '所属学生用户ID',
  `resume_name`   VARCHAR(100) DEFAULT ''              COMMENT '简历名称',
  `file_url`      VARCHAR(500) DEFAULT ''              COMMENT '简历文件地址',
  `file_type`     VARCHAR(20)  DEFAULT ''              COMMENT '文件类型(pdf/doc/docx/jpg/png)',
  `file_size`     BIGINT(20)   DEFAULT 0               COMMENT '文件大小(字节)',
  `source_type`   CHAR(1)      DEFAULT '1'             COMMENT '来源(1本地上传 2拍照导入)',
  `is_default`    CHAR(1)      DEFAULT '0'             COMMENT '是否默认(0否 1是)',
  `parse_status`  CHAR(1)      DEFAULT '0'             COMMENT '解析状态(0未解析 1解析中 2解析成功 3解析失败)',
  `parse_result`  LONGTEXT     DEFAULT NULL            COMMENT 'AI解析结果(JSON)',
  `parse_time`    DATETIME     DEFAULT NULL            COMMENT '解析完成时间',
  `status`        CHAR(1)      DEFAULT '0'             COMMENT '状态(0正常 1停用)',
  `del_flag`      CHAR(1)      DEFAULT '0'             COMMENT '删除标志(0存在 2删除)',
  `create_by`     VARCHAR(64)  DEFAULT ''              COMMENT '创建者',
  `create_time`   DATETIME     DEFAULT NULL            COMMENT '创建时间',
  `update_by`     VARCHAR(64)  DEFAULT ''              COMMENT '更新者',
  `update_time`   DATETIME     DEFAULT NULL            COMMENT '更新时间',
  `remark`        VARCHAR(500) DEFAULT NULL            COMMENT '备注',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_parse_status` (`parse_status`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='学生简历表';

-- ----------------------------
-- 3. 学生岗位画像表
-- ----------------------------
DROP TABLE IF EXISTS `student_job_profile`;
CREATE TABLE `student_job_profile` (
  `id`           BIGINT(20)   NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id`      BIGINT(20)   NOT NULL                COMMENT '所属学生用户ID',
  `industry`     VARCHAR(50)  DEFAULT ''              COMMENT '行业(1技术 2产品 3运营 4财务 5教师)',
  `job_name`     VARCHAR(100) DEFAULT ''              COMMENT '岗位名称(如Java开发、产品经理)',
  `difficulty`   CHAR(1)      DEFAULT '1'             COMMENT '难度(1初级 2中级 3高级)',
  `company_type` VARCHAR(50)  DEFAULT ''              COMMENT '目标企业类型(1BAT 2央企 3外企 4其他)',
  `is_default`   CHAR(1)      DEFAULT '0'             COMMENT '是否默认(0否 1是)',
  `status`       CHAR(1)      DEFAULT '0'             COMMENT '状态(0正常 1停用)',
  `del_flag`     CHAR(1)      DEFAULT '0'             COMMENT '删除标志(0存在 2删除)',
  `create_by`    VARCHAR(64)  DEFAULT ''              COMMENT '创建者',
  `create_time`  DATETIME     DEFAULT NULL            COMMENT '创建时间',
  `update_by`    VARCHAR(64)  DEFAULT ''              COMMENT '更新者',
  `update_time`  DATETIME     DEFAULT NULL            COMMENT '更新时间',
  `remark`       VARCHAR(500) DEFAULT NULL            COMMENT '备注',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='学生岗位画像表';

-- ----------------------------
-- 4. 模拟面试表(面试场次)
-- ----------------------------
DROP TABLE IF EXISTS `interview_session`;
CREATE TABLE `interview_session` (
  `id`              BIGINT(20)   NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `session_no`      VARCHAR(50)  DEFAULT ''              COMMENT '面试场次编号',
  `user_id`         BIGINT(20)   NOT NULL                COMMENT '所属学生用户ID',
  `job_profile_id`  BIGINT(20)   DEFAULT NULL            COMMENT '关联岗位画像ID',
  `industry`        VARCHAR(50)  DEFAULT ''              COMMENT '行业(1技术 2产品 3运营 4财务 5教师)',
  `job_name`        VARCHAR(100) DEFAULT ''              COMMENT '岗位名称',
  `difficulty`      CHAR(1)      DEFAULT '1'             COMMENT '难度(1初级 2中级 3高级)',
  `question_type`   VARCHAR(50)  DEFAULT ''              COMMENT '题型(1行为面 2技术面 3HR面 4case面)',
  `total_count`     INT(11)      DEFAULT 0               COMMENT '题目总数',
  `answered_count`  INT(11)      DEFAULT 0               COMMENT '已答题数',
  `status`          CHAR(1)      DEFAULT '0'             COMMENT '状态(0未开始 1进行中 2已完成 3已中断)',
  `score`           DECIMAL(5,2) DEFAULT NULL            COMMENT '本场总分',
  `start_time`      DATETIME     DEFAULT NULL            COMMENT '开始时间',
  `end_time`        DATETIME     DEFAULT NULL            COMMENT '结束时间',
  `duration`        INT(11)      DEFAULT 0               COMMENT '面试时长(秒)',
  `report_id`       BIGINT(20)   DEFAULT NULL            COMMENT '关联复盘报告ID',
  `del_flag`        CHAR(1)      DEFAULT '0'             COMMENT '删除标志(0存在 2删除)',
  `create_by`       VARCHAR(64)  DEFAULT ''              COMMENT '创建者',
  `create_time`     DATETIME     DEFAULT NULL            COMMENT '创建时间',
  `update_by`       VARCHAR(64)  DEFAULT ''              COMMENT '更新者',
  `update_time`     DATETIME     DEFAULT NULL            COMMENT '更新时间',
  `remark`          VARCHAR(500) DEFAULT NULL            COMMENT '备注',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_session_no` (`session_no`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='模拟面试场次表';

-- ----------------------------
-- 5. 面试题目表(场次内题目实例)
-- ----------------------------
DROP TABLE IF EXISTS `interview_question`;
CREATE TABLE `interview_question` (
  `id`                BIGINT(20)   NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `session_id`        BIGINT(20)   NOT NULL                COMMENT '所属面试场次ID',
  `user_id`           BIGINT(20)   NOT NULL                COMMENT '所属学生用户ID',
  `bank_question_id`  BIGINT(20)   DEFAULT NULL            COMMENT '关联题库题目ID(可为空)',
  `question_no`       INT(11)      DEFAULT 1               COMMENT '题号(第几题)',
  `question_type`     VARCHAR(50)  DEFAULT ''              COMMENT '题型(1行为面 2技术面 3HR面 4case面)',
  `question_content`  TEXT         DEFAULT NULL            COMMENT '题干内容',
  `reference_answer`  TEXT         DEFAULT NULL            COMMENT '参考答案',
  `key_points`        TEXT         DEFAULT NULL            COMMENT '关键要点(JSON数组)',
  `is_follow_up`      CHAR(1)      DEFAULT '0'             COMMENT '是否追问(0否 1是)',
  `parent_question_id` BIGINT(20)  DEFAULT NULL            COMMENT '父题目ID(追问时使用)',
  `source`            CHAR(1)      DEFAULT '1'             COMMENT '来源(1AI生成 2题库抽取 3简历解析)',
  `status`            CHAR(1)      DEFAULT '0'             COMMENT '状态(0正常 1停用)',
  `del_flag`          CHAR(1)      DEFAULT '0'             COMMENT '删除标志(0存在 2删除)',
  `create_by`         VARCHAR(64)  DEFAULT ''              COMMENT '创建者',
  `create_time`       DATETIME     DEFAULT NULL            COMMENT '创建时间',
  `update_by`         VARCHAR(64)  DEFAULT ''              COMMENT '更新者',
  `update_time`       DATETIME     DEFAULT NULL            COMMENT '更新时间',
  `remark`            VARCHAR(500) DEFAULT NULL            COMMENT '备注',
  PRIMARY KEY (`id`),
  KEY `idx_session_id` (`session_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='面试题目表';

-- ----------------------------
-- 6. 面试问答表
-- ----------------------------
DROP TABLE IF EXISTS `interview_qa`;
CREATE TABLE `interview_qa` (
  `id`               BIGINT(20)   NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `session_id`       BIGINT(20)   NOT NULL                COMMENT '所属面试场次ID',
  `question_id`      BIGINT(20)   NOT NULL                COMMENT '关联面试题目ID',
  `user_id`          BIGINT(20)   NOT NULL                COMMENT '所属学生用户ID',
  `question_content` TEXT         DEFAULT NULL            COMMENT '题干内容(冗余,便于查询)',
  `answer_content`   TEXT         DEFAULT NULL            COMMENT '作答内容(文字)',
  `answer_type`      CHAR(1)      DEFAULT '1'             COMMENT '作答方式(1文字 2语音 3视频)',
  `audio_url`        VARCHAR(500) DEFAULT ''              COMMENT '语音文件地址',
  `video_url`        VARCHAR(500) DEFAULT ''              COMMENT '视频文件地址',
  `is_follow_up`     CHAR(1)      DEFAULT '0'             COMMENT '是否追问(0否 1是)',
  `parent_id`        BIGINT(20)   DEFAULT NULL            COMMENT '父问答ID(追问时使用)',
  `answer_time`      DATETIME     DEFAULT NULL            COMMENT '作答时间',
  `duration`         INT(11)      DEFAULT 0               COMMENT '作答耗时(秒)',
  `score`            DECIMAL(5,2) DEFAULT NULL            COMMENT '本题得分',
  `ai_comment`       TEXT         DEFAULT NULL            COMMENT 'AI点评',
  `status`           CHAR(1)      DEFAULT '0'             COMMENT '状态(0正常 1停用)',
  `del_flag`         CHAR(1)      DEFAULT '0'             COMMENT '删除标志(0存在 2删除)',
  `create_by`        VARCHAR(64)  DEFAULT ''              COMMENT '创建者',
  `create_time`      DATETIME     DEFAULT NULL            COMMENT '创建时间',
  `update_by`        VARCHAR(64)  DEFAULT ''              COMMENT '更新者',
  `update_time`      DATETIME     DEFAULT NULL            COMMENT '更新时间',
  `remark`           VARCHAR(500) DEFAULT NULL            COMMENT '备注',
  PRIMARY KEY (`id`),
  KEY `idx_session_id` (`session_id`),
  KEY `idx_question_id` (`question_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='面试问答表';

-- ----------------------------
-- 7. 复盘报告表
-- ----------------------------
DROP TABLE IF EXISTS `interview_report`;
CREATE TABLE `interview_report` (
  `id`                  BIGINT(20)   NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `report_no`           VARCHAR(50)  DEFAULT ''              COMMENT '报告编号',
  `session_id`          BIGINT(20)   NOT NULL                COMMENT '关联面试场次ID',
  `user_id`             BIGINT(20)   NOT NULL                COMMENT '所属学生用户ID',
  `total_score`         DECIMAL(5,2) DEFAULT NULL            COMMENT '总分',
  `score_completeness`  DECIMAL(5,2) DEFAULT NULL            COMMENT '完整性得分',
  `score_logic`         DECIMAL(5,2) DEFAULT NULL            COMMENT '逻辑性得分',
  `score_fluency`       DECIMAL(5,2) DEFAULT NULL            COMMENT '流畅度得分',
  `score_depth`         DECIMAL(5,2) DEFAULT NULL            COMMENT '深度得分',
  `score_confidence`    DECIMAL(5,2) DEFAULT NULL            COMMENT '自信度得分',
  `radar_data`          TEXT         DEFAULT NULL            COMMENT '雷达图数据(JSON)',
  `summary`             TEXT         DEFAULT NULL            COMMENT '报告总结',
  `weak_points`         TEXT         DEFAULT NULL            COMMENT '薄弱点(JSON数组)',
  `suggest`             TEXT         DEFAULT NULL            COMMENT '改进建议',
  `pdf_url`             VARCHAR(500) DEFAULT ''              COMMENT 'PDF报告地址',
  `generate_status`     CHAR(1)      DEFAULT '0'             COMMENT '生成状态(0待生成 1生成中 2成功 3失败)',
  `generate_time`       DATETIME     DEFAULT NULL            COMMENT '生成完成时间',
  `status`              CHAR(1)      DEFAULT '0'             COMMENT '状态(0正常 1停用)',
  `del_flag`            CHAR(1)      DEFAULT '0'             COMMENT '删除标志(0存在 2删除)',
  `create_by`           VARCHAR(64)  DEFAULT ''              COMMENT '创建者',
  `create_time`         DATETIME     DEFAULT NULL            COMMENT '创建时间',
  `update_by`           VARCHAR(64)  DEFAULT ''              COMMENT '更新者',
  `update_time`         DATETIME     DEFAULT NULL            COMMENT '更新时间',
  `remark`              VARCHAR(500) DEFAULT NULL            COMMENT '备注',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_report_no` (`report_no`),
  KEY `idx_session_id` (`session_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='面试复盘报告表';

-- ----------------------------
-- 8. 题库题目表
-- ----------------------------
DROP TABLE IF EXISTS `question_bank`;
CREATE TABLE `question_bank` (
  `id`                BIGINT(20)   NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `question_content`  TEXT         NOT NULL                COMMENT '题干内容',
  `question_type`     VARCHAR(50)  DEFAULT ''              COMMENT '题型(1行为面 2技术面 3HR面 4case面)',
  `industry`          VARCHAR(50)  DEFAULT ''              COMMENT '行业(1技术 2产品 3运营 4财务 5教师)',
  `job_name`          VARCHAR(100) DEFAULT ''              COMMENT '岗位名称',
  `difficulty`        CHAR(1)      DEFAULT '1'             COMMENT '难度(1初级 2中级 3高级)',
  `company_type`      VARCHAR(50)  DEFAULT ''              COMMENT '企业类型(1BAT 2央企 3外企 4其他)',
  `reference_answer`  TEXT         DEFAULT NULL            COMMENT '参考答案',
  `key_points`        TEXT         DEFAULT NULL            COMMENT '关键要点(JSON数组)',
  `tags`              VARCHAR(255) DEFAULT ''              COMMENT '标签(逗号分隔)',
  `source`            VARCHAR(50)  DEFAULT ''              COMMENT '来源(1真题 2模拟 3AI生成)',
  `use_count`         INT(11)      DEFAULT 0               COMMENT '被使用次数',
  `status`            CHAR(1)      DEFAULT '0'             COMMENT '状态(0正常 1停用)',
  `del_flag`          CHAR(1)      DEFAULT '0'             COMMENT '删除标志(0存在 2删除)',
  `create_by`         VARCHAR(64)  DEFAULT ''              COMMENT '创建者',
  `create_time`       DATETIME     DEFAULT NULL            COMMENT '创建时间',
  `update_by`         VARCHAR(64)  DEFAULT ''              COMMENT '更新者',
  `update_time`       DATETIME     DEFAULT NULL            COMMENT '更新时间',
  `remark`            VARCHAR(500) DEFAULT NULL            COMMENT '备注',
  PRIMARY KEY (`id`),
  KEY `idx_type_industry` (`question_type`, `industry`),
  KEY `idx_difficulty` (`difficulty`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='题库题目表';

SET FOREIGN_KEY_CHECKS = 1;


-- ##########################################################################
-- ## 第 2 节 / 共 5 节　菜单：50 条（8 个模块 + 数据权限点）
-- ## 来源：原 sql/student_menu.sql（已并入本文件，原文件保留留档）
-- ## 幂等：是；前置：若依基础库的 sys_menu（不依赖第 1 节）
-- ##########################################################################

-- ============================================================
-- 菜单 SQL —— 学生端 · 全量菜单（8 个模块 + 数据权限点）
-- ------------------------------------------------------------
-- 【这是什么】把 ruoyi/ 下 9 个菜单脚本合并成的一个文件：
--   profileMenu / resumeMenu / jobprofileMenu / sessionMenu /
--   questionMenu / qaMenu / reportMenu / bankMenu / dataScopePermiMenu
--   合并后共 53 条：1 个「学生端」目录（M）+ 9 个模块菜单（C）+ 42 个按钮（F）
--                  + 1 条 interview:data:all 权限点（不给「学生」角色）
-- 【为什么合并】三端合并时只需收集 / 重放这一个文件，不必逐个找 9 个。
-- 【幂等】是 —— 每条 insert 都带 where not exists 守卫，可重复执行；
--   模块菜单与按钮的父子关系按 perms 反查，不依赖 LAST_INSERT_ID()。
-- 【前置】RuoYi-Vue/sql/ry_20260417.sql（基础库，建 sys_menu）
-- 【后置】sql/student_role_user.sql（学生角色绑定，依赖本文件建好的菜单）
-- 【校验】文件末尾自带查询：student_menu_cnt 应为 52，data_all_cnt 应为 1
-- 【原始文件】ruoyi/*Menu.sql 保留未删（代码生成器产出留档），文件头有 banner 指向本文件。
-- 【顺序】8 个模块之间先后无所谓；每个模块前都重新 set @parentId，
--   保证按钮挂在各自的模块菜单下。
-- 维护人：tong　最后更新：2026-09-22
-- ============================================================

-- ============================================================
-- 0. 「学生端」目录（M 型）—— 只建一次，下面 8 个模块都挂在它下面
-- ============================================================

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '学生端', 0, 1, 'student', null, 1, 0, 'M', '0', '0', null, 'user', 'admin', sysdate(), '', null, '学生端目录'
from dual
where not exists (select 1 from sys_menu where path = 'student' and menu_type = 'M' and parent_id = 0);

set @studentDirId = (select menu_id from sys_menu where path = 'student' and menu_type = 'M' and parent_id = 0 limit 1);

-- ============================================================
-- 0.1 / 个人中心　interview:mine:*（资料展示 / 昵称头像 / 账号设置 / 协议 / 注销）
-- ============================================================

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '个人中心', @studentDirId, '0', 'mine', 'interview/mine/index', 1, 0, 'C', '0', '0', 'interview:mine:list', 'user', 'admin', sysdate(), '', null, '学生端个人中心'
from dual
where @studentDirId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:mine:list');

set @mineParentId = (select menu_id from sys_menu where perms = 'interview:mine:list' limit 1);

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '个人中心查询', @mineParentId, '1', '#', '', 1, 0, 'F', '0', '0', 'interview:mine:query', '#', 'admin', sysdate(), '', null, ''
from dual
where @mineParentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:mine:query');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '账号注销', @mineParentId, '2', '#', '', 1, 0, 'F', '0', '0', 'interview:mine:remove', '#', 'admin', sysdate(), '', null, ''
from dual
where @mineParentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:mine:remove');

-- ============================================================
-- 1 / 8　学生档案　interview:profile:*
-- ============================================================

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '学生档案', @studentDirId, '1', 'profile', 'interview/profile/index', 1, 0, 'C', '0', '0', 'interview:profile:list', '#', 'admin', sysdate(), '', null, '学生档案菜单'
from dual
where @studentDirId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:profile:list');

-- 取本模块菜单 ID —— 按权限标识反查（不用 LAST_INSERT_ID()，菜单已存在时同样取得到）
set @parentId = (select menu_id from sys_menu where perms = 'interview:profile:list' limit 1);

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '学生档案查询', @parentId, '1', '#', '', 1, 0, 'F', '0', '0', 'interview:profile:query', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:profile:query');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '学生档案新增', @parentId, '2', '#', '', 1, 0, 'F', '0', '0', 'interview:profile:add', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:profile:add');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '学生档案修改', @parentId, '3', '#', '', 1, 0, 'F', '0', '0', 'interview:profile:edit', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:profile:edit');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '学生档案删除', @parentId, '4', '#', '', 1, 0, 'F', '0', '0', 'interview:profile:remove', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:profile:remove');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '学生档案导出', @parentId, '5', '#', '', 1, 0, 'F', '0', '0', 'interview:profile:export', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:profile:export');

-- ============================================================
-- 2 / 8　学生简历　interview:resume:*
-- ============================================================

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '学生简历', @studentDirId, '1', 'resume', 'interview/resume/index', 1, 0, 'C', '0', '0', 'interview:resume:list', '#', 'admin', sysdate(), '', null, '学生简历菜单'
from dual
where @studentDirId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:resume:list');

-- 取本模块菜单 ID —— 按权限标识反查（不用 LAST_INSERT_ID()，菜单已存在时同样取得到）
set @parentId = (select menu_id from sys_menu where perms = 'interview:resume:list' limit 1);

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '学生简历查询', @parentId, '1', '#', '', 1, 0, 'F', '0', '0', 'interview:resume:query', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:resume:query');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '学生简历新增', @parentId, '2', '#', '', 1, 0, 'F', '0', '0', 'interview:resume:add', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:resume:add');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '学生简历修改', @parentId, '3', '#', '', 1, 0, 'F', '0', '0', 'interview:resume:edit', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:resume:edit');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '学生简历删除', @parentId, '4', '#', '', 1, 0, 'F', '0', '0', 'interview:resume:remove', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:resume:remove');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '学生简历导出', @parentId, '5', '#', '', 1, 0, 'F', '0', '0', 'interview:resume:export', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:resume:export');

-- ============================================================
-- 3 / 8　学生岗位画像　interview:jobprofile:*
-- ============================================================

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '学生岗位画像', @studentDirId, '1', 'jobprofile', 'interview/jobprofile/index', 1, 0, 'C', '0', '0', 'interview:jobprofile:list', '#', 'admin', sysdate(), '', null, '学生岗位画像菜单'
from dual
where @studentDirId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:jobprofile:list');

-- 取本模块菜单 ID —— 按权限标识反查（不用 LAST_INSERT_ID()，菜单已存在时同样取得到）
set @parentId = (select menu_id from sys_menu where perms = 'interview:jobprofile:list' limit 1);

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '学生岗位画像查询', @parentId, '1', '#', '', 1, 0, 'F', '0', '0', 'interview:jobprofile:query', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:jobprofile:query');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '学生岗位画像新增', @parentId, '2', '#', '', 1, 0, 'F', '0', '0', 'interview:jobprofile:add', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:jobprofile:add');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '学生岗位画像修改', @parentId, '3', '#', '', 1, 0, 'F', '0', '0', 'interview:jobprofile:edit', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:jobprofile:edit');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '学生岗位画像删除', @parentId, '4', '#', '', 1, 0, 'F', '0', '0', 'interview:jobprofile:remove', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:jobprofile:remove');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '学生岗位画像导出', @parentId, '5', '#', '', 1, 0, 'F', '0', '0', 'interview:jobprofile:export', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:jobprofile:export');

-- ============================================================
-- 4 / 8　模拟面试场次　interview:session:*
-- ============================================================

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '模拟面试场次', @studentDirId, '1', 'session', 'interview/session/index', 1, 0, 'C', '0', '0', 'interview:session:list', '#', 'admin', sysdate(), '', null, '模拟面试场次菜单'
from dual
where @studentDirId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:session:list');

-- 取本模块菜单 ID —— 按权限标识反查（不用 LAST_INSERT_ID()，菜单已存在时同样取得到）
set @parentId = (select menu_id from sys_menu where perms = 'interview:session:list' limit 1);

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

-- ============================================================
-- 5 / 8　面试题目　interview:question:*
-- ============================================================

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '面试题目', @studentDirId, '1', 'question', 'interview/question/index', 1, 0, 'C', '0', '0', 'interview:question:list', '#', 'admin', sysdate(), '', null, '面试题目菜单'
from dual
where @studentDirId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:question:list');

-- 取本模块菜单 ID —— 按权限标识反查（不用 LAST_INSERT_ID()，菜单已存在时同样取得到）
set @parentId = (select menu_id from sys_menu where perms = 'interview:question:list' limit 1);

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '面试题目查询', @parentId, '1', '#', '', 1, 0, 'F', '0', '0', 'interview:question:query', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:question:query');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '面试题目新增', @parentId, '2', '#', '', 1, 0, 'F', '0', '0', 'interview:question:add', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:question:add');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '面试题目修改', @parentId, '3', '#', '', 1, 0, 'F', '0', '0', 'interview:question:edit', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:question:edit');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '面试题目删除', @parentId, '4', '#', '', 1, 0, 'F', '0', '0', 'interview:question:remove', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:question:remove');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '面试题目导出', @parentId, '5', '#', '', 1, 0, 'F', '0', '0', 'interview:question:export', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:question:export');

-- ============================================================
-- 6 / 8　面试问答　interview:qa:*
-- ============================================================

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '面试问答', @studentDirId, '1', 'qa', 'interview/qa/index', 1, 0, 'C', '0', '0', 'interview:qa:list', '#', 'admin', sysdate(), '', null, '面试问答菜单'
from dual
where @studentDirId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:qa:list');

-- 取本模块菜单 ID —— 按权限标识反查（不用 LAST_INSERT_ID()，菜单已存在时同样取得到）
set @parentId = (select menu_id from sys_menu where perms = 'interview:qa:list' limit 1);

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '面试问答查询', @parentId, '1', '#', '', 1, 0, 'F', '0', '0', 'interview:qa:query', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:qa:query');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '面试问答新增', @parentId, '2', '#', '', 1, 0, 'F', '0', '0', 'interview:qa:add', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:qa:add');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '面试问答修改', @parentId, '3', '#', '', 1, 0, 'F', '0', '0', 'interview:qa:edit', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:qa:edit');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '面试问答删除', @parentId, '4', '#', '', 1, 0, 'F', '0', '0', 'interview:qa:remove', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:qa:remove');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '面试问答导出', @parentId, '5', '#', '', 1, 0, 'F', '0', '0', 'interview:qa:export', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:qa:export');

-- ============================================================
-- 7 / 8　面试复盘报告　interview:report:*
-- ============================================================

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '面试复盘报告', @studentDirId, '1', 'report', 'interview/report/index', 1, 0, 'C', '0', '0', 'interview:report:list', '#', 'admin', sysdate(), '', null, '面试复盘报告菜单'
from dual
where @studentDirId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:report:list');

-- 取本模块菜单 ID —— 按权限标识反查（不用 LAST_INSERT_ID()，菜单已存在时同样取得到）
set @parentId = (select menu_id from sys_menu where perms = 'interview:report:list' limit 1);

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '面试复盘报告查询', @parentId, '1', '#', '', 1, 0, 'F', '0', '0', 'interview:report:query', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:report:query');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '面试复盘报告新增', @parentId, '2', '#', '', 1, 0, 'F', '0', '0', 'interview:report:add', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:report:add');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '面试复盘报告修改', @parentId, '3', '#', '', 1, 0, 'F', '0', '0', 'interview:report:edit', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:report:edit');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '面试复盘报告删除', @parentId, '4', '#', '', 1, 0, 'F', '0', '0', 'interview:report:remove', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:report:remove');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '面试复盘报告导出', @parentId, '5', '#', '', 1, 0, 'F', '0', '0', 'interview:report:export', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:report:export');

-- ============================================================
-- 8 / 8　题库题目　interview:bank:*
-- ============================================================

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '题库题目', @studentDirId, '1', 'bank', 'interview/bank/index', 1, 0, 'C', '0', '0', 'interview:bank:list', '#', 'admin', sysdate(), '', null, '题库题目菜单'
from dual
where @studentDirId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:bank:list');

-- 取本模块菜单 ID —— 按权限标识反查（不用 LAST_INSERT_ID()，菜单已存在时同样取得到）
set @parentId = (select menu_id from sys_menu where perms = 'interview:bank:list' limit 1);

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '题库题目查询', @parentId, '1', '#', '', 1, 0, 'F', '0', '0', 'interview:bank:query', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:bank:query');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '题库题目新增', @parentId, '2', '#', '', 1, 0, 'F', '0', '0', 'interview:bank:add', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:bank:add');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '题库题目修改', @parentId, '3', '#', '', 1, 0, 'F', '0', '0', 'interview:bank:edit', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:bank:edit');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '题库题目删除', @parentId, '4', '#', '', 1, 0, 'F', '0', '0', 'interview:bank:remove', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:bank:remove');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '题库题目导出', @parentId, '5', '#', '', 1, 0, 'F', '0', '0', 'interview:bank:export', '#', 'admin', sysdate(), '', null, ''
from dual
where @parentId is not null
  and not exists (select 1 from sys_menu where perms = 'interview:bank:export');

-- ============================================================
-- 9 / 9　数据隔离权限点　interview:data:all
-- ------------------------------------------------------------
-- 用途：注册为可分配的权限按钮，供后台端在「角色管理」里授予非超管角色。
-- ⚠️ 不要分配给「学生」角色 —— 否则学生能看到全部学生的数据。
-- 超级管理员无需分配（若依自动授予 *:*:*，天然通过）。
-- ⚠️ 挂载位置：本语句把它挂在「学生端」目录（@studentDirId）下。
--    但有的库（含本仓库开发库）里它已被手工挂到根节点（parent_id = 0）——
--    两种位置都不影响功能：sql/student_role_user.sql 的绑定按「学生端目录 → 其下两层」取，
--    根节点下的它自然取不到；若它确实挂在目录下，绑定语句里还有一句
--    `and (perms is null or perms <> 'interview:data:all')` 把它排除掉。
--    由于本条有 perms 存在判据，重放既不会新增、也不会迁移已有记录。
-- ============================================================

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
select '查看全部学生数据', @studentDirId, 9, '#', '', 1, 0, 'F', '0', '0', 'interview:data:all', '#', 'admin', sysdate(), '', null, '拥有此权限可查看与操作全部学生数据，勿分配给「学生」角色'
from dual
where not exists (select 1 from sys_menu where perms = 'interview:data:all');

-- ============================================================
-- 校验
-- ============================================================

-- 校验 1：学生端菜单树（目录 + 9 模块菜单 + 42 按钮），预期 52
--   注意：按钮是模块菜单的子节点（孙节点），所以要查三层。
--   data:all 被排除 —— 它不属于学生端菜单树（无论挂在目录下还是根节点）。
select count(*) as student_menu_cnt
from sys_menu
where (menu_id = @studentDirId
    or parent_id = @studentDirId
    or parent_id in (select menu_id from sys_menu where parent_id = @studentDirId))
  and (perms is null or perms <> 'interview:data:all');

-- 校验 2：数据隔离权限点，预期 1
select count(*) as data_all_cnt
from sys_menu
where perms = 'interview:data:all';

-- 校验 3：逐条列出学生端菜单树，便于肉眼核对（预期 52 行）
select menu_id, menu_name, menu_type, parent_id, order_num, perms
from sys_menu
where (menu_id = @studentDirId
    or parent_id = @studentDirId
    or parent_id in (select menu_id from sys_menu where parent_id = @studentDirId))
  and (perms is null or perms <> 'interview:data:all')
order by menu_type desc, parent_id, order_num, menu_id;


-- ##########################################################################
-- ## 第 3 节 / 共 5 节　角色与账号：「学生」角色 + student01 / student02 + 菜单绑定
-- ## 来源：原 sql/student_role_user.sql（已并入本文件，原文件保留留档）
-- ## 幂等：是；⚠️ 必须在第 2 节之后 —— 它依赖菜单已经建好
-- ##########################################################################

-- ============================================================
-- 【学生端 · 角色与账号】 可执行 / 幂等
-- ------------------------------------------------------------
-- 作用：补上「干净库重建」的第 4 块拼图 ——
--       「学生」角色 + student01 / student02 账号 + 角色菜单绑定
-- 前置：1) RuoYi-Vue/sql/ry_20260417.sql   （若依基础库）
--       2) RuoYi-Vue/sql/quartz.sql        （定时任务表，可跳过）
--       3) ruoyi/*Menu.sql                 （8 个，建学生端菜单）
--       4) ruoyi/dataScopePermiMenu.sql    （注册 interview:data:all）
-- 幂等：是 —— 可重复执行；已存在的角色 / 账号 / 绑定不会被重复创建
-- 账号：student01 / student02
--       初始密码 admin123（复用若依基础库自带的种子密文）
--       仅限开发与演示，上线前必须在后台改掉
-- 详见：sql/README.md
-- ============================================================

set names utf8mb4;

-- ------------------------------------------------------------
-- 1. 「学生」角色
--    不写死 role_id：若依 sys_role 自增从 100 起，写死会与别人冲突
--    data_scope 用若依新建角色的默认值 '1'；学生端的数据隔离不依赖它，
--    而是 StudentDataScopeUtils 按 user_id 做的，与本字段无关
-- ------------------------------------------------------------
insert into sys_role (role_name, role_key, role_sort, data_scope, menu_check_strictly, dept_check_strictly, status, del_flag, create_by, create_time, remark)
select '学生', 'student', 3, '1', 1, 1, '0', '0', 'admin', sysdate(), '学生端角色，只能访问学生端菜单'
from dual
where not exists (select 1 from sys_role where role_key = 'student' and del_flag = '0');

set @studentRoleId = (select role_id from sys_role where role_key = 'student' and del_flag = '0' order by role_id limit 1);

-- ------------------------------------------------------------
-- 2. 学生账号 student01 / student02
--    dept_id 留空（与现有 student01 一致）
--    password = 若依基础库自带的种子密文，明文即 admin123
-- ------------------------------------------------------------
insert into sys_user (dept_id, user_name, nick_name, user_type, email, phonenumber, sex, avatar, password, status, del_flag, login_ip, login_date, pwd_update_date, create_by, create_time, update_by, update_time, remark)
select null, 'student01', 'student01', '00', '', '', '2', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '', null, sysdate(), 'admin', sysdate(), '', null, '学生端测试账号'
from dual
where not exists (select 1 from sys_user where user_name = 'student01' and del_flag = '0');

insert into sys_user (dept_id, user_name, nick_name, user_type, email, phonenumber, sex, avatar, password, status, del_flag, login_ip, login_date, pwd_update_date, create_by, create_time, update_by, update_time, remark)
select null, 'student02', 'student02', '00', '', '', '2', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '', null, sysdate(), 'admin', sysdate(), '', null, '学生端测试账号（数据隔离验证用）'
from dual
where not exists (select 1 from sys_user where user_name = 'student02' and del_flag = '0');

set @student01Id = (select user_id from sys_user where user_name = 'student01' and del_flag = '0' order by user_id limit 1);
set @student02Id = (select user_id from sys_user where user_name = 'student02' and del_flag = '0' order by user_id limit 1);

-- ------------------------------------------------------------
-- 3. 账号 <-> 角色 绑定
--    insert ignore：主键是 (user_id, role_id)，已绑定则自动跳过
-- ------------------------------------------------------------
insert ignore into sys_user_role (user_id, role_id)
select @student01Id, @studentRoleId from dual where @student01Id is not null and @studentRoleId is not null;

insert ignore into sys_user_role (user_id, role_id)
select @student02Id, @studentRoleId from dual where @student02Id is not null and @studentRoleId is not null;

-- ------------------------------------------------------------
-- 4. 角色 <-> 菜单 绑定：按「学生端目录 -> 其下全部菜单」动态绑定
--    不写死 menu_id —— 三端合并后菜单 id 会整体重排
--
--    菜单树形状（合计 49 条）：
--      学生端目录                       1 条   path='student', menu_type='M'
--        +-- 8 个模块菜单               8 条   每个模块的 interview:xxx:list 挂在这里
--              +-- 每个模块 5 个按钮   40 条   query / add / edit / remove / export
--
--    注意：必须排除 interview:data:all —— 它同样挂在「学生端」目录下，
--    但那是给后台端的「全量数据权限」，学生拿到就能看所有学生的数据
-- ------------------------------------------------------------
set @studentDirId = (select menu_id from sys_menu where path = 'student' and menu_type = 'M' order by menu_id limit 1);

-- 4.1 目录本身
insert ignore into sys_role_menu (role_id, menu_id)
select @studentRoleId, @studentDirId from dual where @studentRoleId is not null and @studentDirId is not null;

-- 4.2 目录下的一级菜单（8 个模块，含各自的 interview:xxx:list 权限）
insert ignore into sys_role_menu (role_id, menu_id)
select @studentRoleId, menu_id from sys_menu
where parent_id = @studentDirId
  and @studentRoleId is not null
  and (perms is null or perms <> 'interview:data:all');

-- 4.3 再下一级（每个模块的 5 个按钮）
--     若以后菜单层级加深，这里需要再加一段；跑完第 5 步的校验能立刻发现
insert ignore into sys_role_menu (role_id, menu_id)
select @studentRoleId, menu_id from sys_menu
where parent_id in (select menu_id from sys_menu where parent_id = @studentDirId)
  and @studentRoleId is not null;

-- ------------------------------------------------------------
-- 5. 校验
--    预期：menu_cnt = 49，user_cnt = 2，data_all_bound = 0
-- ------------------------------------------------------------
select r.role_id,
       r.role_key,
       r.role_name,
       (select count(*) from sys_user_role ur where ur.role_id = r.role_id) as user_cnt,
       (select count(*) from sys_role_menu rm where rm.role_id = r.role_id) as menu_cnt
from sys_role r
where r.role_key = 'student' and r.del_flag = '0';

select count(*) as data_all_bound
from sys_role r
join sys_role_menu rm on rm.role_id = r.role_id
join sys_menu m on m.menu_id = rm.menu_id
where r.role_key = 'student' and m.perms = 'interview:data:all';


-- ##########################################################################
-- ## 第 4 节 / 共 5 节　业务字典：13 个类型 + 45 条数据
-- ## 来源：原 sql/student_dict.sql（已并入本文件，原文件保留留档）
-- ## 幂等：是；只依赖若依基础库的 sys_dict_type / sys_dict_data
-- ##########################################################################

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


-- ##########################################################################
-- ## 第 4.5 节　学生端协议参数（个人中心用户协议 / 隐私政策）
-- ##########################################################################

insert into sys_config (config_name, config_key, config_value, config_type, create_by, create_time, remark)
select '学生端-用户协议', 'student.agreement.user',
       '欢迎使用面立方学生端。使用本产品即表示你同意遵守平台规则，合理使用模拟面试功能，不得利用本服务从事违法违规活动。平台有权在必要时更新本协议内容。',
       'Y', 'admin', sysdate(), '学生端个人中心-用户协议正文'
from dual
where not exists (select 1 from sys_config where config_key = 'student.agreement.user');

insert into sys_config (config_name, config_key, config_value, config_type, create_by, create_time, remark)
select '学生端-隐私政策', 'student.agreement.privacy',
       '我们仅收集完成模拟面试所必需的账号与业务数据（如档案、简历、面试记录与复盘报告），用于提供服务与改进体验。未经你的同意，不会向第三方出售个人信息。你可在个人中心申请注销账号。',
       'Y', 'admin', sysdate(), '学生端个人中心-隐私政策正文'
from dual
where not exists (select 1 from sys_config where config_key = 'student.agreement.privacy');


-- ##########################################################################
-- ## 第 5 节 / 共 5 节　题库演示数据：26 道样例题（可选）
-- ## 来源：原 sql/student_question_bank_seed.sql（已并入本文件，原文件保留留档）
-- ## 幂等：是；依赖第 1 节的 question_bank 表。
-- ## 不是重建必需步骤 —— 真实题库由后台端维护；跑它只是为了本地能验证列表 / 筛选 / 详情 / 导出。
-- ##########################################################################

-- ----------------------------------------------------------------------------
-- 面立方 · 学生端 · 题库演示数据（question_bank）
--
-- 用途：本地开发 / 演示用。库里没有题库题目时，列表、筛选、查看详情、导出都没法验证，
--       跑一遍这个脚本就能得到 26 道覆盖全部字典值域的样例题。
--
-- 定位：**不是**重建干净库的必需步骤，属于「可选执行」的开发数据。
--       三端合并时**不要**把它当成业务数据合并 —— 真实题库由后台端维护。
--
-- 幂等：每行都带 `where not exists` 守卫（按题干判重），可重复执行，不会产生重复行。
--       已存在同题干的记录时跳过该行，不会覆盖你手工改过的内容。
--
-- 覆盖情况（便于逐项验证筛选与导出）：
--   题型：行为面 6 / 技术面 11 / HR面 5 / case面 4          → 共 24 道「正常」+ 2 道「停用」
--   行业：技术 14 / 产品 5 / 运营 3 / 财务 1 / 教师 3
--   难度：初级 9 / 中级 13 / 高级 4
--   企业类型：BAT 9 / 央企 5 / 外企 4 / 其他 8
--   来源：真题 11 / 模拟 9 / AI生成 6
--   ⚠️ 特意留了 2 道 status='1'（停用，均为技术面），用来验证「停用题目对学生隐藏」是否生效：
--      学生登录后列表应只看到 24 道，导出也应是 24 道；admin 登录应能看到全部 26 道。
--      两道题的题干里都写了「【停用示例】」字样，方便在库里一眼认出验证数据；
--      admin 登录后页面上的「状态」列会显示「停用」（该列仅对有 interview:data:all 权限的账号渲染）。
--
-- 执行位置：sql/README.md 重建顺序之后（任意位置均可，只依赖第 2 步建表）
-- ----------------------------------------------------------------------------

-- ============================ 行为面（question_type = 1） ============================

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select '请做一个自我介绍，重点说明你与这个岗位的匹配点。', '1', '1', 'Java开发工程师', '1', '1',
       '按「我是谁 → 我做过什么 → 我为什么适合这个岗位」三段式组织，控制在 1 分钟内。避免复述简历流水账，把最相关的 1~2 个项目讲透，并落到岗位要求的关键词上。',
       '["三段式结构清晰","突出与岗位相关的经历","有量化结果","控制在1分钟内"]', '自我介绍,开场', '1', 156, '0', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = '请做一个自我介绍，重点说明你与这个岗位的匹配点。');

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select '讲一次你和团队成员产生分歧的经历，你是怎么处理的？', '1', '1', 'Java开发工程师', '2', '1',
       '用 STAR 结构回答。重点不在「谁对谁错」，而在你如何把分歧从「立场之争」拉回「目标与事实」：先对齐目标，再摆数据，必要时做小范围验证。结尾补一句事后如何避免同类分歧。',
       '["STAR结构","先对齐目标再讨论方案","用事实和数据说服","有事后复盘"]', '团队协作,沟通', '1', 98, '0', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = '讲一次你和团队成员产生分歧的经历，你是怎么处理的？');

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select '说一件你主动推动、但最终没有做成的事，你从中得到什么？', '1', '2', '产品经理', '2', '3',
       '诚实讲失败，但重点放在归因和收获。好的回答会区分「可控因素」和「不可控因素」，并说明如果重来一次你会改变哪个决策点。切忌把失败包装成成功。',
       '["坦诚面对失败","区分可控与不可控因素","有明确的复盘结论","不甩锅"]', '抗压,复盘', '2', 61, '0', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = '说一件你主动推动、但最终没有做成的事，你从中得到什么？');

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select '你最有成就感的一段经历是什么？为什么？', '1', '3', '运营专员', '1', '4',
       '选一件能体现你能力特长、且与岗位相关的事。回答结构：背景 → 你具体做了什么 → 结果 → 为什么这件事对你重要。把「成就感」落到具体的成长上，而不是空泛的「学到了很多」。',
       '["与岗位能力相关","有具体行动和结果","说清为什么重要"]', '自我认知,动机', '1', 74, '0', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = '你最有成就感的一段经历是什么？为什么？');

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select '描述一次你在时间紧张的情况下完成多任务的经历。', '1', '1', '后端开发工程师', '2', '2',
       '展示你的优先级判断方法：按「重要且紧急」排序、主动同步风险、必要时求助或砍范围。要点是让面试官看到你不是靠熬夜硬扛，而是靠方法。',
       '["有明确的优先级判断依据","主动沟通风险","合理取舍范围","结果可验证"]', '时间管理,多任务', '2', 52, '0', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = '描述一次你在时间紧张的情况下完成多任务的经历。');

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select '你遇到过最难相处的合作对象是什么样的？你怎么应对？', '1', '5', '课程讲师', '2', '4',
       '避免情绪化评价他人。好的回答聚焦「行为差异」而非「人品判断」，并说明你如何调整沟通方式去达成共同目标。',
       '["不评价他人人品","聚焦行为与目标差异","主动调整沟通方式"]', '沟通,冲突处理', '2', 33, '0', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = '你遇到过最难相处的合作对象是什么样的？你怎么应对？');

-- ============================ 技术面（question_type = 2） ============================

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select '谈谈 JVM 的内存结构，以及各区域可能出现的异常。', '2', '1', 'Java开发工程师', '2', '1',
       '线程私有：程序计数器、虚拟机栈、本地方法栈；线程共享：堆、方法区（元空间）。程序计数器不会 OOM；虚拟机栈会 StackOverflowError（递归过深）；堆和方法区会 OutOfMemoryError。补充 JDK8 之后方法区由元空间实现、使用本地内存。',
       '["线程私有与线程共享分区正确","程序计数器不OOM","栈溢出与堆溢出的区别","JDK8元空间变化"]', 'JVM,内存模型,八股', '1', 233, '0', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = '谈谈 JVM 的内存结构，以及各区域可能出现的异常。');

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select 'MySQL 的索引为什么用 B+ 树而不是 B 树或哈希表？', '2', '1', 'Java开发工程师', '2', '1',
       '哈希索引不支持范围查询和排序，且哈希冲突时退化。B 树非叶子节点也存数据，单节点能容纳的键更少，树更高、IO 次数更多。B+ 树非叶子节点只存键，扇出大、树更矮；叶子节点用链表相连，天然支持范围扫描和排序，所以更适合磁盘存储。',
       '["哈希不支持范围查询","B树非叶子节点存数据导致扇出小","B+树叶子链表支持范围查询","从磁盘IO角度解释"]', 'MySQL,索引,B+树', '1', 198, '0', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = 'MySQL 的索引为什么用 B+ 树而不是 B 树或哈希表？');

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select '说说你对 HTTP 与 HTTPS 区别的理解，HTTPS 的握手过程是怎样的？', '2', '1', '后端开发工程师', '2', '3',
       'HTTPS = HTTP + TLS。核心差异是加密、完整性校验与身份认证。握手大致过程：客户端发 ClientHello（支持的加密套件、随机数）→ 服务端回 ServerHello + 证书 → 客户端校验证书并生成预主密钥、用公钥加密后发送 → 双方用三个随机数推导会话密钥 → 之后用对称加密通信。',
       '["HTTPS是HTTP加TLS","能说清证书校验的作用","握手三步有顺序","最终使用对称加密"]', 'HTTP,HTTPS,TLS', '1', 167, '0', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = '说说你对 HTTP 与 HTTPS 区别的理解，HTTPS 的握手过程是怎样的？');

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select '什么是幂等？接口设计中如何保证幂等？', '2', '1', '后端开发工程师', '2', '2',
       '幂等指同一请求执行多次，对系统状态的影响与执行一次相同。常见方案：唯一索引/去重表兜底、业务唯一单号、Token 机制（先取 token 再提交）、状态机约束（只允许从指定状态流转）、分布式锁。要说明选型依据：写库场景优先唯一索引，跨服务场景用单号或 token。',
       '["给出幂等的准确定义","至少说出三种方案","说明选型依据","提到唯一索引兜底"]', '接口设计,幂等,分布式', '1', 145, '0', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = '什么是幂等？接口设计中如何保证幂等？');

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select '解释一下缓存穿透、缓存击穿、缓存雪崩，以及各自的应对方案。', '2', '1', '高级Java工程师', '3', '1',
       '穿透：查不存在的数据，缓存和数据库都没有，请求全打到库上 —— 用空值缓存、布隆过滤器、参数校验。击穿：某个热点 key 过期瞬间大量请求打到库上 —— 用互斥锁重建、热点 key 永不过期。雪崩：大量 key 同时过期或缓存宕机 —— 过期时间加随机值、多级缓存、缓存集群高可用、限流降级。',
       '["三者定义不混淆","穿透用布隆过滤器或空值缓存","击穿用互斥锁重建","雪崩用随机过期时间与高可用"]', '缓存,Redis,高并发', '1', 189, '0', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = '解释一下缓存穿透、缓存击穿、缓存雪崩，以及各自的应对方案。');

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select '一个慢 SQL 你会怎么排查和优化？', '2', '1', '后端开发工程师', '2', '4',
       '先定位：慢查询日志、explain 看 type/key/rows/Extra。再看索引：是否走索引、是否索引失效（函数、隐式类型转换、前导模糊、不符合最左前缀）。优化手段：补合适索引、避免 select *、减少回表、拆分大事务、分页深翻页用游标、必要时引入缓存或归档。',
       '["先用慢日志与explain定位","能说出索引失效的常见原因","优化手段具体","提到深分页问题"]', 'MySQL,慢SQL,优化', '2', 121, '0', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = '一个慢 SQL 你会怎么排查和优化？');

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select '说说 TCP 三次握手和四次挥手，为什么需要三次握手？', '2', '1', '后端开发工程师', '1', '3',
       '三次握手：SYN → SYN+ACK → ACK。需要三次是因为要让双方都确认「自己的发送和接收能力正常」以及「对方的发送和接收能力正常」，同时防止已失效的历史连接请求突然到达服务端造成资源浪费。四次挥手：FIN → ACK → FIN → ACK，因为 TCP 是全双工，一方关闭后另一方可能还有数据要发，所以 ACK 与 FIN 不能合并。',
       '["握手挥手步骤正确","能解释为什么不是两次","提到历史连接问题","挥手四次与全双工有关"]', 'TCP,网络,八股', '1', 210, '0', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = '说说 TCP 三次握手和四次挥手，为什么需要三次握手？');

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select '你了解哪些设计模式？在项目里实际用过哪一个？', '2', '1', 'Java开发工程师', '1', '4',
       '列举常见模式（单例、工厂、策略、模板方法、责任链、观察者等），然后挑一个真正用过的展开：业务场景是什么、不用它之前代码长什么样、用了之后解决了什么问题。面试官想听的是落地经验，不是背定义。',
       '["能列举常见模式","选一个真实用过的展开","说清解决了什么问题","避免只背定义"]', '设计模式,项目经验', '2', 88, '0', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = '你了解哪些设计模式？在项目里实际用过哪一个？');

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select '分布式锁有哪些实现方式？各自有什么优缺点？', '2', '1', '高级Java工程师', '3', '1',
       '基于 Redis（SET NX EX 或 Redisson）：性能好、实现简单，但要注意锁续期、误删、集群下的一致性问题。基于 ZooKeeper：临时顺序节点，天然支持等待队列、可靠性高，但性能不如 Redis。基于数据库唯一索引或 select for update：实现最简单，但并发能力弱、不适合高并发。选型要看一致性要求与并发量。',
       '["至少三种实现方式","Redis方案的坑能说清","说明选型依据","提到锁续期与误删"]', '分布式锁,Redis,ZooKeeper', '3', 76, '0', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = '分布式锁有哪些实现方式？各自有什么优缺点？');

-- ============================ HR面（question_type = 3） ============================

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select '你为什么选择我们公司？', '3', '3', '运营专员', '1', '2',
       '回答要体现你做过功课：公司业务方向、产品特点、你关注到的近期动作，再落到「你的能力能在这里发挥什么」。避免只说「平台大、稳定、离家近」这类放之四海皆准的理由。',
       '["体现做过功课","结合公司业务特点","落到自身能力匹配","不空泛"]', '动机,公司了解', '1', 134, '0', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = '你为什么选择我们公司？');

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select '你的职业规划是什么？未来三年希望达到什么状态？', '3', '2', '产品经理', '2', '2',
       '规划要「可落地且与岗位相关」：第一年熟悉业务与流程、独立负责模块；第二到三年能主导一条业务线、带小团队或形成方法论。切忌说「三年后创业」或「三年当总监」这种与当前岗位脱节的目标。',
       '["规划分阶段且具体","与应聘岗位一致","体现成长意愿","不脱离实际"]', '职业规划,稳定性', '2', 102, '0', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = '你的职业规划是什么？未来三年希望达到什么状态？');

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select '你期望的薪资是多少？依据是什么？', '3', '3', '运营专员', '1', '4',
       '先给一个区间而不是单点，并说明依据：目标城市同岗位市场水平、自己的实习与项目经历、以及该岗位的职责范围。态度上保持可谈，把话题引回「更看重成长空间」。不要在初面阶段把数字咬死。',
       '["给区间不给单点","依据是市场水平与自身能力","态度可谈","不把数字咬死"]', '薪资,谈判', '2', 118, '0', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = '你期望的薪资是多少？依据是什么？');

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select '你能接受加班吗？你怎么看待工作与生活的平衡？', '3', '5', '课程讲师', '1', '4',
       '先表明态度：项目关键期愿意投入，这是团队责任。再说方法：靠提升效率而不是无意义地耗时间，同时说明自己会关注长期可持续。避免两个极端 —— 既不硬顶，也不无条件迎合。',
       '["态度积极但不谄媚","强调提升效率","表达长期可持续","不极端"]', '加班,价值观', '3', 95, '0', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = '你能接受加班吗？你怎么看待工作与生活的平衡？');

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select '除了我们公司，你还在看哪些机会？如果都拿到 offer 你怎么选？', '3', '2', '产品经理', '2', '3',
       '不必回避在看其他机会，但不要细数别家名字。把重点放在你的选择标准上：业务方向、成长空间、团队氛围、与自身规划的匹配度。最后表明这家公司在你标准里的排序理由。',
       '["不回避也不细数别家","给出清晰的选择标准","说明本公司的排序理由","诚实"]', 'offer选择,动机', '3', 67, '0', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = '除了我们公司，你还在看哪些机会？如果都拿到 offer 你怎么选？');

-- ============================ case面（question_type = 4） ============================

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select '如果某个功能上线后日活下降了 10%，你会怎么分析？', '4', '2', '产品经理', '2', '1',
       '先确认数据本身是否可信（口径变化、埋点问题、统计延迟），再分层拆解：是整体下降还是特定端/地区/人群；再定位是「入口流量少了」还是「转化变差了」；最后结合上线时间点判断是否与本次改版相关，必要时做 A/B 验证。',
       '["先验证数据口径","按维度拆解定位范围","区分流量问题与转化问题","用A/B验证因果"]', '数据分析,case,日活', '1', 143, '0', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = '如果某个功能上线后日活下降了 10%，你会怎么分析？');

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select '让你从 0 到 1 设计一个面向大学生的求职工具，你会怎么做？', '4', '2', '产品经理', '3', '1',
       '按「目标用户与场景 → 核心痛点 → 方案与功能优先级 → 指标与验证」展开。求职场景的核心痛点是信息不对称、准备过程无反馈、投递效率低。第一版应聚焦一个点（例如模拟面试或简历诊断），用最小成本验证需求，再考虑扩展。',
       '["先定义用户与场景","痛点具体不空泛","有MVP意识","给出衡量指标"]', '产品设计,case,0到1', '3', 81, '0', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = '让你从 0 到 1 设计一个面向大学生的求职工具，你会怎么做？');

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select '公司要求把某个业务的成本降低 20%，你会从哪些方面入手？', '4', '4', '财务分析岗', '3', '2',
       '先做成本结构拆解，找出占比最大的项；再区分固定成本与可变成本、可控与不可控；然后按「影响大小 × 落地难度」排优先级，从可控的大项入手（如供应商议价、流程自动化、减少返工）。要给出量化目标和跟踪机制。',
       '["先拆解成本结构","区分固定与可变成本","按影响与难度排优先级","有量化目标"]', '成本控制,case,财务', '2', 58, '0', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = '公司要求把某个业务的成本降低 20%，你会从哪些方面入手？');

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select '你负责的课程完课率只有 30%，如何提升？', '4', '5', '课程讲师', '2', '4',
       '先定位流失环节：看每一节的跳出率，找出流失最集中的位置；再判断原因（内容太难、时长过长、缺乏反馈、缺少提醒）。对应措施：拆分小节降低单次门槛、增加练习与即时反馈、设置进度提醒与激励机制，最后用小范围实验验证效果。',
       '["用数据定位流失环节","分析原因而非直接给方案","措施对应原因","有验证方式"]', '完课率,case,教学', '3', 42, '0', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = '你负责的课程完课率只有 30%，如何提升？');

-- ============================ 停用示例（status = 1，用于验证「对学生隐藏」） ============================

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select '【停用示例】这道题已停用，学生端列表和导出都不应出现，admin 登录才看得到。', '2', '1', '后端开发工程师', '1', '4',
       '这是一条用于验证「停用题目对学生隐藏」的样例数据。学生登录后：列表应查不到、直接按 id 访问详情应返回「数据不存在或已删除」、导出里也不应有它。',
       '["仅用于验证status过滤","学生端不可见","admin可见"]', '停用示例,验证数据', '2', 0, '1', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = '【停用示例】这道题已停用，学生端列表和导出都不应出现，admin 登录才看得到。');

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select '【停用示例】内部草稿：题目描述待补充，暂不对外。', '2', '1', 'Java开发工程师', '1', '1',
       '这是第二条停用样例，用于确认多条停用记录都会被过滤掉。',
       '["仅用于验证status过滤","学生端不可见"]', '停用示例,验证数据', '3', 0, '1', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = '【停用示例】内部草稿：题目描述待补充，暂不对外。');

-- ============================ 校验 ============================
-- 预期：total_cnt = 26，normal_cnt = 24，disabled_cnt = 2
-- 学生账号登录后列表应只有 24 条；admin 登录应能看到 26 条。
select
    (select count(*) from question_bank)                        as total_cnt,
    (select count(*) from question_bank where status = '0')     as normal_cnt,
    (select count(*) from question_bank where status = '1')     as disabled_cnt;


-- ##########################################################################
-- ## 总校验 —— 跑完本文件后执行，核对是否都到位
-- ##########################################################################

-- ① 8 张业务表都存在（预期 8）
select count(*) as table_cnt
from information_schema.tables
where table_schema = database()
  and table_name in ('student_profile','student_resume','student_job_profile',
                     'interview_session','interview_question','interview_qa',
                     'interview_report','question_bank');

-- ② 学生端菜单树（1 目录 + 9 模块菜单 + 42 按钮，不含 data:all）（预期 52）
select count(*) as menu_cnt
from sys_menu
where (menu_id = @studentDirId
    or parent_id = @studentDirId
    or parent_id in (select menu_id from sys_menu where parent_id = @studentDirId))
  and (perms is null or perms <> 'interview:data:all');

-- ③ 学生账号（预期 2）
select count(*) as user_cnt from sys_user
where user_name in ('student01','student02') and del_flag = '0';

-- ④ 学生角色的菜单绑定数（预期 52）
select count(*) as role_menu_cnt
from sys_role_menu rm
join sys_role r on r.role_id = rm.role_id
where r.role_key = 'student' and r.del_flag = '0';

-- ⑤ interview:data:all 没有被误绑给「学生」角色（预期 0）
select count(*) as data_all_bound
from sys_role_menu rm
join sys_role r on r.role_id = rm.role_id
join sys_menu m on m.menu_id = rm.menu_id
where r.role_key = 'student' and r.del_flag = '0' and m.perms = 'interview:data:all';

-- ⑥ 业务字典（预期 13 个类型 / 45 条数据）
select count(*) as dict_type_cnt
from sys_dict_type
where dict_type in ('student_education','student_industry','student_difficulty','student_company_type',
                    'interview_question_type','interview_session_status','interview_answer_type',
                    'student_resume_source','student_parse_status','interview_question_source',
                    'question_bank_source','student_guide_status','interview_report_status');

select count(*) as dict_data_cnt
from sys_dict_data
where dict_type in ('student_education','student_industry','student_difficulty','student_company_type',
                    'interview_question_type','interview_session_status','interview_answer_type',
                    'student_resume_source','student_parse_status','interview_question_source',
                    'question_bank_source','student_guide_status','interview_report_status');

-- ⑦ 题库演示题（第 5 节没跑的话是 0，不影响功能）
select count(*) as bank_cnt from question_bank;
