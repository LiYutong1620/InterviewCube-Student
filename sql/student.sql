-- ⚠️ 已并入 sql/student_init.sql 的第 1 节（建表）（权威可执行版）。本文件保留留档，内容与合并版逐字一致。
--    从零重建 / 旧库补丁请直接跑对应的合并文件，不必逐个跑本目录的脚本。
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