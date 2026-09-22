# 面立方 · 学生端开发计划（PLAN.md）

> **定位**：基于若依（RuoYi-Vue，Spring Boot 3 + Vue3）开发的 Web 版 AI 模拟面试系统，面向学生 / 应届生。原产品规划功能清单保持不变，载体由 APP 改为网页端。
> **本仓库范围**：只做**纯学生端**。后台端 / 企业端由组员各自独立开发，**后期才合并**。
> **最后更新**：2026-09-22　|　**本文件已加入 `.gitignore`**，只在本地维护，不随仓库分发
> **配套文档**：`doc/学生端对外契约.md`（三端合并契约）· `doc/CRUD字段清单.md`（8 模块字段取舍）· `doc/面试流程四件套形态方案.md`（⑤ 四个流程模块的页面形态，方案 A 已拍板，**S1~S5 全部落地**）· `sql/README.md`（14 步重建顺序）

---

## 0. 进度总览

| 阶段 | 内容 | 状态 |
| :--- | :--- | :--- |
| **一** | 只做 CRUD（生成 → 学生端角色 / 菜单 → 数据隔离） | ✅ **完成**，仅剩 2 项运行时验证（见 §5.2） |
| **二** | CRUD 语义收紧 + 前端页面改造（AI 押后） | ✅ **完成**（8 / 8 模块；⑤ 流程四件套 S1~S5 全部落地，`@Excel` 清理与文档回填已收口） |
| **三** | AI 面试闭环 | ⏸ **押后**，等阶段二定稿 |
| **—** | 多端合并准备（冻结契约 + 清地雷） | ✅ 交付物已产出（见 §4） |

### 8 个模块改造进度（阶段二核心）

| # | 模块 | 表 | 形态 | CRUD 语义 | 前端页面 |
| :- | :--- | :--- | :--- | :--- | :--- |
| 1 | 学生档案 | `student_profile` | 1:1 | ✅ 09-22 | ✅ 09-22 |
| 2 | 学生岗位画像 | `student_job_profile` | 1:N | ✅ 09-22 | ✅ 09-22 |
| 3 | 学生简历 | `student_resume` | 1:N | ✅ 09-22 | ✅ 09-22 |
| 4 | 题库题目 | `question_bank` | 共享 · 只读 | ✅ 09-22 | ✅ 09-22 |
| 5 | 模拟面试场次 | `interview_session` | 1:N · 流程 | ✅ 09-22 | ✅ 09-22 |
| 6 | 面试题目 | `interview_question` | 1:N · 流程 | ✅ 09-22 | ✅ 09-22 |
| 7 | 面试问答 | `interview_qa` | 1:N · 流程 | ✅ 09-22 | ✅ 09-22 |
| 8 | 面试复盘报告 | `interview_report` | 1:1 · 流程 | ✅ 09-22 | ✅ 09-22 |

> 逐模块字段取舍见 `doc/CRUD字段清单.md` 第二节；`@Excel` 与中文枚举文案的清理进度见该文档 4.1 —— **8 个模块已全部改完（2026-09-22，S5）**。

---

## 1. 阶段一：只做 CRUD ✅

**目标**：让学生登录后只能看自己的数据，而不是后台管理员视角。

### 1.1 三步走

| 步骤 | 内容 | 产出 | 状态 |
| :--- | :--- | :--- | :--- |
| 1 | 把三级功能清单落成「阶段一 CRUD 范围 + 数据表」 | `doc/一阶段三级功能清单.xlsx`、`sql/student.sql`（已并入 `sql/student_init.sql` 第 1 节）、`doc/菜单权限标识清单.xlsx` | ✅ |
| 2 | 用若依代码生成器生成前后端 CRUD | — | ✅（用户自己执行） |
| 3 | 改造成学生端角色、菜单与数据隔离 | 见 §1.2 / §1.3 | 🚧 仅剩 2 项验证 |

> 第 1 步的建表字段模板（物理类型 / Java 类型 / 显示类型 / 字典类型等逐列约定）折叠到文末 **§7 附录**。

### 1.2 学生端角色与菜单

- [x] 新建「学生」角色，权限字符 `student`
- [x] 新建测试账号 `student01`、`student02`，绑定「学生」角色
- [x] 新建「学生端」目录，把 8 个生成菜单挂到该目录下
- [x] 角色菜单权限：学生角色只勾「学生端」目录及其下菜单，不勾系统管理 / 监控 / 工具
- [x] 修复 `student01` 登录失败（原因：误用 admin 的 BCrypt 密文覆盖，实际明文不是 `123456`）
  - **结论**：BCrypt 每次密文都不同，改密码一律走后台「重置密码」，不要手工改库
- [x] 登录后首页：保留 `/index`，把 `src/views/index.vue` 替换为学生端首页
  - [x] 方案已定：直接覆盖 `index.vue`（阶段一 admin 首页暂不区分）
  - [ ] **待验证**：学生登录后首页正常显示，快捷入口跳转可达

### 1.3 数据隔离方案

- [x] 后端：7 张表的 `list` / `add` / `edit` / `remove` / `getInfo` 全部强制使用 `SecurityUtils.getUserId()`

| 操作 | 落地方式 |
| :--- | :--- |
| 列表 / 导出 | Controller 中 `StudentDataScopeUtils.scopeToCurrentUser(...)`；Mapper XML 已补 `user_id` 过滤条件 |
| 新增 | 后端强制写入 `user_id`，不信任前端传参（`bindOwner`） |
| 修改 / 删除 / 详情 | 先查 DB 比对 `user_id`，不一致返回「无权操作 / 查看」（`checkOwner`） |

- [x] 收尾：抽取公共工具，减少重复代码
  - `UserOwned` 接口（7 个领域类实现）+ `StudentDataScopeUtils`（`currentUserId` / `scopeUserId` / `bindOwner` / `scopeToCurrentUser` / `checkOwner`）
- **判定方式：由「判断身份」改为「判断权限」** —— 用 `SecurityUtils.hasPermi("interview:data:all")` 取代 `SecurityUtils.isAdmin()`
  - 超管由若依自动授予 `*:*:*`（`SysPermissionService.getMenuPermission`），天然通过
  - 学生天然不通过；后台端日后给非超管角色开全量，只需分配权限，**不用改学生端代码**
  - 权限点注册脚本：`sql/student_init.sql` 第 2 节（含 `interview:data:all`；原始出处 `ruoyi/dataScopePermiMenu.sql`）
- **例外说明**
  - `question_bank` 无 `user_id`，属共享题库，阶段一不做学生隔离（`question_content` 已改为无条件必填列）
  - 超级管理员（`user_id = 1`）不做数据隔离，可查看与操作全部数据；学生仍严格隔离

---

## 2. 阶段二：CRUD 语义收紧 + 前端页面改造 🚧

> **2026-09-22 决定**：AI 面试闭环**暂不启动**。
> **理由**：CRUD 是地基，页面是学生实际看到的东西。AI 接入会改变接口形态（后端要生成 `session_id` / `question_id`），页面形态没定之前接 AI 容易白做。

### 2.1 要解决的问题

现在的页面是**若依代码生成器的裸产物** —— 功能能跑，但语义不对。以「学生档案」为例（其余模块问题同源）：

| 问题 | 现状 | 应改为 |
| :--- | :--- | :--- |
| 内部字段暴露给学生 | 列表显示 `主键ID`、`关联若依用户ID`、`创建者`、`更新者`、`删除标志` | 不显示这些字段 |
| 查询条件过多 | 8 个条件（昵称 / 真实姓名 / 性别 / 手机号 / 邮箱 / 学校 / 专业 / 状态） | 学生只有自己那几条数据，搜索区大幅精简甚至去掉 |
| 控件类型不对 | `学历`、`毕业年份` 都是文本框 | 学历 → 下拉字典；毕业年份 → 年份选择器 |
| 学生能改系统字段 | `当前等级`、`当前积分`、`引导状态`、`状态` 都可编辑 | 改为只读或不放进表单，由系统 / 后台维护 |
| 校验缺失 | 只有 `昵称` 必填 | 补手机号、邮箱格式校验 |

### 2.2 准备工作 ✅

- [x] 逐个模块列出「该显示 / 该隐藏 / 该只读 / 该补校验」四张清单 → **`doc/CRUD字段清单.md`**（2026-09-22 产出）
- [x] **拍板 3 个业务决策**（2026-09-22，详见该文档第三节）

  | # | 问题 | 结论 |
  | :- | :--- | :--- |
  | 1 | `interview_question` 的参考答案，作答前能不能看？ | **A：作答前隐藏，提交后可见**（按 `session.status = 2` 或该题已有 `qa` 记录判断） |
  | 2 | 题库 `question_bank` 学生能不能写？ | **A：学生端只读**（新增 / 修改 / 删除从学生端去掉，留给后台端） |
  | 3 | 三个流程模块要不要保留 CRUD 表单？ | **B：暂时保留**，等前端改造时再收敛成流程页 |

- [x] 建字典 **`sql/student_dict.sql`**（13 个类型 + 45 条数据，幂等）—— 已并入 `sql/student_init.sql` 第 4 节
- [x] **字典 `dict_value` 一律用码**（2026-09-22 决定）
  - 理由：业务表里存的**就是** `dict_value`。用码 → **改文案只改 `dict_label`，业务数据零迁移**；用中文 → 每改一次文案都要 `UPDATE` 历史行，且容易留下新旧值并存（不报错，只是筛选时悄悄少数据）
  - 13 个字典的值域表已写入 `doc/学生端对外契约.md` **第四节**（含变更记录）—— 这是「字典留存记录」的落点
  - `sql/student_init.sql` 第 1 节里 10 个列的 `COMMENT` 已改成「码=含义」（如 `学历(1专科 2本科 3硕士 4博士)`）
  - 已建库同步脚本：`sql/student_patch.sql` 第 1 节（幂等、可重跑，**不必 DROP 重建表**；先跑第 0 步检查有没有残留中文值）

### 2.3 改码的连带影响：清「中文枚举」文案 🚧

`dict_value` 改成码之后，还有一批地方写着中文枚举，会和实际数据对不上：

| 位置 | 现状 | 怎么改 |
| :--- | :--- | :--- |
| Domain 类 `@Excel` | `@Excel(name = "学历(专科/本科/硕士/博士)")`，但数据是 `2` | 配 `readConverterExp` 让导出翻译成中文 |
| 前端列头 / 标签 | `label="学历(专科/本科/硕士/博士)"` | 改成 `label="学历"`，值交给 `dict-tag` 渲染 |
| 表注释 | ✅ 已改完 | `sql/student_init.sql` 第 1 节已是「码=含义」 |

**`@Excel` 方案改判（2026-09-22）**：原建议「学生端摘掉导出按钮」，**改判为配 `readConverterExp`**。
理由：8 个模块的菜单脚本都已生成 `interview:xxx:export` 按钮，单独摘掉某个模块会造成「菜单树有、页面没有」的不一致；`readConverterExp` 一行注解就能把「导出中文、库里存码」做对。

**进度**：`StudentProfile` ✅ 2026-09-22、`StudentJobProfile` ✅ 2026-09-22、`StudentResume` ✅ 2026-09-22、`QuestionBank` ✅ 2026-09-22、`InterviewSession` ✅ 2026-09-22；`InterviewQuestion` / `InterviewQa` / `InterviewReport` 3 个 ⬜ **待 S5 统一收**（S2 / S3 都只改页面，没动 `@Excel`）—— 逐模块明细见 `doc/CRUD字段清单.md` 4.1。

> ⚠️ **`RuoYi-Vue/` 与 `ruoyi/` 两棵树都要改**（`ruoyi/` 是生成器产出暂存区，两份必须同步）
> 排查命令：`git grep -n "专科/本科\|技术/产品\|BAT/央企\|行为面/技术面\|真题/模拟"`

### 2.4 改造顺序与逐模块进度

建议顺序（由简到繁）：**学生档案 → 岗位画像 → 简历 → 题库 → 三个流程模块**

- [x] **① 学生档案**（1:1，最简单，已作为样板）→ 见 §2.5
- [x] **② 学生岗位画像**（1:N，三个下拉接字典；已作为 1:N 样板）→ 见 §2.6
- [x] **③ 学生简历**（文件上传 + 链接预览；已作为「含文件上传」样板）→ 见 §2.7
- [x] **④ 题库题目**（共享题库 · 学生端只读；已作为「只读浏览」样板）→ 见 §2.8
- [ ] **⑤ 模拟面试场次 / 面试题目 / 面试问答 / 面试复盘报告** —— 四个模块是**同一条面试流程的 4 个环节**，形态必须一起定
  - ✅ **方案已拍板**：**方案 A —— 以「场次」为主干、靠路由参数 `?sessionId=x` 下钻、不动 `sys_menu`** → 详见 `doc/面试流程四件套形态方案.md`
  - 施工顺序：**S1 ✅ → S2 ✅ → S3 ✅ → S4 ✅ → S5 ✅**（阶段二收尾）
  - [x] **S1** `interview_session`：场次列表改造 + 「开始面试」对话框 + 后端生成 `session_no`/行业/岗位/难度/`status`/`start_time` + 从题库抽题落 `interview_question` + 删场次级联 —— 见 `doc/面试流程四件套形态方案.md` §九
  - [x] **S2** `interview_question`：`/student/question?sessionId=x` 只读回顾页 + 参考答案门控（决策 1）—— 见 `doc/面试流程四件套形态方案.md` §十
  - [x] **S3** `interview_qa`：`/student/qa?sessionId=x` 逐题作答页 + 提交 + 全部答完置 `已完成` + 「提前结束」置 `已中断` —— 见 `doc/面试流程四件套形态方案.md` §十一
  - [x] **S4** `interview_report`：`/student/report` 列表（只读 + 手工填分）+ `echarts` 五维雷达图 + 空态 + 场次置完成时幂等建报告壳 —— 见 `doc/面试流程四件套形态方案.md` §十二
  - [x] **S5** 其余 3 个 Domain（`InterviewQuestion` / `InterviewQa` / `InterviewReport`）的 `@Excel` 清理 + 4 个外键列的 insert 写法结论（**改为无条件列**）+ 文档回填 —— 见 `doc/面试流程四件套形态方案.md` §十三
    - 4 个 `view.vue` 抽屉**已在 S1~S4 逐个完成**（session ✅ S1、question ✅ S2、qa ✅ S3 已删除、report ✅ S4）

### 2.5 样板：学生档案模块 ✅（2026-09-22 完成）

**形态**：`student_profile` 与用户是 **1:1**（`uk_user_id`），由「列表 + 分页 + 多选删除」改成**一页式表单**。

| 文件 | 改动 |
| :--- | :--- |
| `RuoYi-Vue3/src/views/interview/profile/index.vue`（两棵树） | **重写**为「我的档案」一页式表单（445 → 252 行） |
| `RuoYi-Vue3/src/views/interview/profile/view.vue`（两棵树） | **已删除**（一页式表单后，详情抽屉成为死代码） |
| `StudentProfile.java`（两棵树） | 摘掉 `id` / `userId` / `guideStatus` / `status` 的 `@Excel`；`gender`、`education` 补 `readConverterExp` |

**前端细节**

- 删掉：查询区（8 个条件）、表格、分页、多选框、「新增 / 修改 / 删除 / 导出」按钮
- 打开即 `listProfile({pageNum:1, pageSize:1})` 取第一条回填；没有记录时保存自动走 `addProfile`
- `学历` → `el-select`（`student_education` 字典）；`毕业年份` → 年份选择器（`value-format="YYYY"`）
- `当前等级 / 当前积分 / 引导状态 / 账号状态` 移到「成长信息（由系统维护，不可编辑）」分隔线下，纯展示
- **提交用白名单 `EDITABLE_FIELDS` 拼 payload** —— 系统字段永不进请求体，学生改不了
- 补校验：`昵称` 必填、`手机号` 中国大陆正则、`邮箱` email 类型、`毕业年份` 四位年份

**后端已验证**：`updateStudentProfile` 里**没有** `user_id`，系统字段不会被前端覆盖。

> ⚠️ **连带影响**：学生档案现在**没有列表和「修改」按钮**了。§5.2 的越权测试步骤请改用**还有列表的模块** —— 「学生岗位画像」已经改好且保留列表，可直接拿它做。

### 2.6 样板：学生岗位画像模块 ✅（2026-09-22 完成）

**形态**：1:N（一个学生可建多个目标岗位）→ **保留「列表 + 分页 + 多选删除 + 增删改查」**，与 §2.5 的 1:1 一页式表单形成对照。做完这两个，1:1 与 1:N 两种样板就齐了。

| 文件 | 改动 |
| :--- | :--- |
| `RuoYi-Vue3/src/views/interview/jobprofile/index.vue`（两棵树） | 改造为面向学生的列表 + 弹窗（360 行） |
| `RuoYi-Vue3/src/views/interview/jobprofile/view.vue`（两棵树） | **已删除**（6 个字段的弹窗已覆盖全部内容，抽屉是死代码） |
| `StudentJobProfile.java`（两棵树） | 去掉 `id` / `userId` / `status` 的 `@Excel`；5 个字段列名去枚举 + 补 `readConverterExp` |
| `StudentJobProfileMapper.java` / `.xml`（两棵树） | **新增** `clearDefaultByUserId(userId, keepId)` |
| `StudentJobProfileServiceImpl.java`（两棵树） | `insert` / `update` 加 `@Transactional` + 唯一默认保障 + `resolveOwnerId()` |

**前端细节**

- 查询区从 3 个条件砍到 2 个：**行业 + 难度**（去掉「岗位名称」「是否默认」「状态」）
- 列表去掉：主键ID / 所属学生用户ID / 状态 / 创建者 / 更新者 / 更新时间
- 三个文本框 → `el-select`：`student_industry` / `student_difficulty` / `student_company_type`
- `is_default` → `el-switch`（1 / 0），列表用 `el-tag` 显示「默认」
- `remark` → 「备注」多行文本框（学生自己的备注，见 `doc/CRUD字段清单.md` §1.1 的拍板 B）
- 提交用白名单 `EDITABLE_FIELDS`，`status` 永不进 payload
- 校验：`jobName` / `industry` / `difficulty` 必填

**后端补的「唯一默认」保障**（原清单只写了「补校验」，并没有实现）

- `clearDefaultByUserId`：`update ... set is_default = '0' where user_id = ? and is_default = '1' and del_flag = '0' [and id != ?]`
- 新增时传 `keepId = null`（新行还没入库）；修改时传自身 id
- 修改接口前端不传 `user_id`，用 `resolveOwnerId()` 回查数据库拿归属
- 加 `@Transactional`：清默认与写主记录要么都成、要么都不成

> ⚠️ **顺带修掉一个生成器埋的 bug**：原页面用 `sys_yes_no` 渲染 `is_default`，但 `sys_yes_no` 的值域是 **`Y`=是 / `N`=否**，而 `is_default` 是 `CHAR(1) DEFAULT '0'`（注释「0否 1是」）。选「是」会把 `'Y'` 写进语义为 `0/1` 的列，列表回显也会因为匹配不上字典而原样显示。
>
> **处理**：`is_default` 不接任何字典 —— 前端 `el-switch`（0/1）+ 导出 `@Excel(readConverterExp = "0=否,1=是")`。
> **不新增「是/否」字典**：避免再造一个与 `sys_yes_no` 名字近义、值域不同的字典，扩大三端合并的混淆面。
>
> **数据卫生**：若之前用旧页面存过，库里可能已有 `'Y'` / `'N'` 残留 —— 清理 SQL 见 `doc/CRUD字段清单.md` 2.3。
> **同一个坑**：`student_resume.is_default`，已在 §2.7 用同样方式处理。

### 2.7 样板：学生简历模块 ✅（2026-09-22 完成）

**形态**：1:N（一个学生可传多份简历）→ 与岗位画像同构，**保留「列表 + 分页 + 多选删除 + 增删改查」**；新增的看点是**文件上传**，所以单独列一节记录。

| 文件 | 改动 |
| :--- | :--- |
| `RuoYi-Vue3/src/views/interview/resume/index.vue`（两棵树） | 改造为面向学生的列表 + 弹窗（385 → 370 行） |
| `RuoYi-Vue3/src/views/interview/resume/view.vue`（两棵树） | **已删除**（抽屉是死代码） |
| `StudentResume.java`（两棵树） | 去掉 `id` / `userId` / `parseStatus` / `parseTime` / `status` 的 `@Excel`（9 → 4）；`sourceType` / `isDefault` 补 `readConverterExp`，`fileType` 列名去说明 |
| `StudentResumeMapper.java` / `.xml`（两棵树） | **新增** `clearDefaultByUserId(userId, keepId)` |
| `StudentResumeServiceImpl.java`（两棵树） | `insert` / `update` 加 `@Transactional` + 唯一默认保障 + `resolveOwnerId()` |

**前端细节**

- 查询区从 4 个条件砍到 1 个：**只留「简历名称」**（去掉「文件类型」「是否默认」「状态」）
- 列表列：简历名称 / 文件（可点击链接）/ 类型 / 来源（`dict-tag`）/ 默认（`el-tag`）/ 创建时间 / 操作
- 文件用若依现成的 `<file-upload>`：`:limit="1"`、`:fileSize="10"`、`:fileType="['pdf','doc','docx']"`
- `sourceType` → `el-select`（`student_resume_source` 字典），新增时默认 `"1"`（本地上传）
  - ⚠️ **生成器原本把 `source_type` 整个漏了**，表单里根本没有这个字段 —— 本次补回
- `isDefault` → `el-switch`（1 / 0），**不接 `sys_yes_no`**（同岗位画像的坑）
- `remark` → 「备注」多行文本框；提交用白名单 `EDITABLE_FIELDS`
- 校验：`resumeName` / `fileUrl` 必填

**两处与清单的偏差（有意为之）**

| 字段 | 偏差 | 原因 |
| :--- | :--- | :--- |
| `file_type` | 改为**前端从 URL 后缀推导**，不是用户手填 | 若依的 `/common/upload` 只回 `{fileName, newFileName, originalFilename, url}`，**不回文件类型**；而该接口在 `ruoyi-common`，是三端共用的公共代码，为学生端一个字段去改它不划算。改为提交前 `resolveFileType(fileUrl)` 取后缀（`pdf` / `docx`…），取不到就留空 |
| `file_size` | **阶段一不做** | 同上，`/common/upload` 不回大小。清单里已标注「等公共上传接口返回大小后再补」 |

> **唯一默认保障与岗位画像完全同构**：`clearDefaultByUserId` 的 SQL 是
> `update student_resume set is_default = '0' where user_id = ? and is_default = '1' and del_flag = '0' [and id != ?]`，
> 新增时 `keepId = null`、修改时传自身 id；`insert` / `update` 都带 `@Transactional`，前端不传 `user_id`（用 `resolveOwnerId()` 回查）。
>
> 📌 **关于 `del_flag`**：`student_resume` 表**有** `del_flag` 列（`CHAR(1) DEFAULT '0'`，注释「0存在 2删除」），
> 但生成器产出的删除语句是**物理 `delete from`**，所以 `del_flag` 实际恒为 `'0'`（8 张表都一样，这是生成器配置没开逻辑删除的结果）。
> `clearDefaultByUserId` 里的 `del_flag = '0'` 目前是**恒真条件**，留着是为了语义明确 + 将来真改成逻辑删除时不用回头改。

> ⚠️ 这两处偏差都指向同一个根因：**若依公共上传接口信息不全**。若后续确需 `file_size`，正确做法是在**三端共同约定后**统一扩展 `/common/upload` 的返回体，而不是学生端单独绕开。

### 2.8 样板：题库题目模块 ✅（2026-09-22 完成）

**形态**：`question_bank` 是**全库共享**资源（**无 `user_id`**），按决策 2 **学生端只读** → 页面是「**列表 + 筛选 + 查看详情**」，没有新增 / 修改 / 删除。这是前三个模块之外的新形态（前三个都有写操作）。

| 文件 | 改动 |
| :--- | :--- |
| `RuoYi-Vue3/src/views/interview/bank/index.vue`（两棵树） | 改造为只读浏览页（367 → 247 行） |
| `RuoYi-Vue3/src/views/interview/bank/view.vue`（两棵树） | 详情抽屉**重写**（163 → 202 行） |
| `QuestionBank.java`（两棵树） | `@Excel` 11 → 9：摘 `id` / `status`；5 个枚举字段补 `readConverterExp` |
| `StudentDataScopeUtils.java`（两棵树） | 新增 `STATUS_NORMAL` 常量 + `canViewStatus()` |
| `QuestionBankController.java`（两棵树） | `list` / `export` / `getInfo` 三处加 `status` 可见性过滤 |
| `Service` / `Mapper`（两棵树） | **未动**（复用已有的 `<if test="status != null">` 条件列） |

**前端细节**

- **删掉的东西**：新增 / 修改 / 删除按钮、`type="selection"` 多选列、整个新增/修改弹窗，以及它带来的一串死代码（`handleAdd` / `handleUpdate` / `submitForm` / `handleDelete` / `handleSelectionChange` / `reset` / `cancel` / `form` / `rules` / `ids` / `single` / `multiple` / `open` / `title`）
- 查询区 4 → 3，且全部换成字典下拉：**题型 + 行业 + 难度**（原「岗位名称」「标签」「来源」是文本框，「状态」是内部字段）
- 列表列：题干 / 题型 / 行业 / 难度 / 企业类型 / 岗位名称 / 标签 / 来源 / 参考答案 / 关键要点 / 被使用次数 / 操作
  - 长文本列一律 `:show-overflow-tooltip="true"`，不撑破表格
  - 操作列只有「查看」，`fixed="right"`
- **`key_points` 是 JSON 数组**：列表里用 `formatKeyPoints()` 解析后拼成「、」分隔的纯文本；抽屉里渲染成 `<ul>` 列表；解析失败就原样兜底
- **详情抽屉补上了「参考答案」「关键要点」** —— 生成器原来根本没渲染这两项，而它们恰恰是题库最核心的内容
- 抽屉里的枚举字段全部换成 `<dict-tag>`（原来直接显示裸码，如题型显示 `1`）

**🔒 只读是「权限层面」保证的，不是靠前端隐藏按钮**

`QuestionBankController` 的 `add` / `edit` / `remove` 都带 `@PreAuthorize("@ss.hasPermi('interview:bank:add')")` 这类权限校验，
而「学生」角色**没有**这三个权限 —— 学生端就算知道接口也调不通。

> 这也正是决策 2 里「按钮保留在 `sys_menu` 里（后台端要用），学生端靠 `v-hasPermi` 自然隐藏」的落地方式：
> 菜单数据不动，页面不渲染，接口调不通 —— 三件事各司其职。
> **同理，`status` 过滤也做在后端**：前端过滤能被直接调接口绕过。

**✅ 两个待定项已拍板（2026-09-22）**

| # | 问题 | 结论 | 落地 |
| :- | :--- | :--- | :--- |
| 1 | 导出按钮留不留？ | **保留** | 与 §2.3「8 个模块统一保留导出」一致，不动 |
| 2 | `status` 要不要过滤？ | **要，对学生隐藏停用题目** | 后端权限驱动，`list` / `export` / `getInfo` 三处 |

**`status` 过滤怎么做的**

- `StudentDataScopeUtils` 新增 `STATUS_NORMAL = "0"` 与 `canViewStatus(status)` → `canViewAll() || STATUS_NORMAL.equals(status)`
- `list()` / `export()`：无 `interview:data:all` 权限时强制 `status = '0'`（**导出也受限，否则导出就是绕过隐藏的后门**）
- `getInfo()`：记录不存在**或**状态不可见 → 抛「数据不存在或已删除」，防止用猜 id 绕过列表过滤
- 有 `interview:data:all` 的角色（后台端 / 超管）不受影响

**配套的界面处理（2026-09-22 补）** —— 只过滤不显示有个副作用：**管理员看到 26 条却认不出哪 2 条是停用的**。所以「状态」按权限门控展示：

| 位置 | 学生 | 管理员 / 超管 |
| :--- | :--- | :--- |
| 查询区「状态」下拉 | 不渲染 | 渲染 |
| 列表「状态」列 | 不渲染 | 渲染（`dict-tag`，停用显 danger） |
| 详情抽屉「状态」 | 不渲染 | 渲染 |

- 前端 `checkPermi(['interview:data:all'])`（`@/utils/permission`）包成 **`computed`**，模板 `v-if="canViewAll"`
  - 用 `computed` 而非常量：`permissions` 是 Pinia 状态，`GetInfo` 返回后会自动重算
  - **不用 `v-hasPermi` 指令**：它靠移除 DOM 实现，用在 `el-table-column` 这类**配置型组件**上不可靠
- 门控判据与后端**同一个权限点**，不会出现「后端给看、前端不给看」的错位

> 💡 **为什么只有题库加 `status` 过滤**：其余 7 张表是**学生自己的数据**（`user_id` 隔离），行内 `status` 是后台的标记，学生看自己的记录无所谓；
> `question_bank` 是**共享内容**，`status` 的语义就是「这道题还要不要给学生看」—— 必须过滤。

**🧪 本地测试数据**：`sql/student_init.sql` 第 5 节（原 `sql/student_question_bank_seed.sql`，可选、幂等）—— 26 道样例题，覆盖全部字典值域，含 **2 道停用题**专门验证过滤。
预期：学生看到 **24** 道 / 导出 **24** 行；`admin` 看到 **26** 道。

### 2.9 每个模块的收尾清单（SOP，可直接复用）

改完一个模块，逐条过一遍：

- [ ] **后端**：`update` 语句里没有 `user_id`；系统字段（`status` / `guide_status` 等）不允许被前端覆盖
- [ ] **后端**：内部字段摘掉 `@Excel`；枚举字段配 `readConverterExp`
- [ ] **后端**：布尔列（`is_default` 这类 `CHAR(1)` 存 `0/1`）**不要错接 `sys_yes_no`（`Y`/`N`）** —— 字典值域必须与列注释一致
- [ ] **只读模块**（题库这类）：写操作接口（`add` / `edit` / `remove`）必须都带 `@PreAuthorize` 权限校验 —— **只读靠权限保证，不能只靠前端不渲染按钮**；菜单数据保持不动（后台端要用）
- [ ] **共享资源**（无 `user_id` 的表）：若行内有 `status`，要判断「学生该不该看到停用记录」，并在**后端**（含导出）过滤，不能只在前端过滤
- [ ] **共享资源**：过滤之后还要给**管理员留一个可见入口**（列表列 / 查询条件），否则管理员看得到记录却认不出哪条被停用 —— 门控判据与后端用同一个权限点
- [ ] **前端**：列表列 / 查询区 / 表单控件类型 / 校验规则，逐项对照 `doc/CRUD字段清单.md`
- [ ] **前端**：中文枚举文案清干净（列头、标签、`placeholder`）
- [ ] **同步**：`RuoYi-Vue/` ↔ `ruoyi/`、`RuoYi-Vue3/` ↔ `ruoyi/vue/`，`diff -rq` 必须无差异
- [ ] **换行符**：全部保持 CRLF（用 Python 统计 `\r\n`，不要用 `grep -q` 判断）
- [ ] **结构自检**：Vue 模板标签配对；`<script setup>` 抽出来过 `node --check`；Mapper XML 用 `xml.etree` 验良构
- [ ] **文档**：更新 `doc/CRUD字段清单.md` 对应小节 + 本文档 §0 进度表

---

## 3. 阶段三：AI 面试闭环 ⏸ 押后

CRUD 与页面形态定稿后再评估。届时顺带解决 `session_id` / `question_id` 4 个外键列，见 §5.1。

---

## 4. 多端合并准备 ✅（冻结契约 + 清地雷）

> 背景：学生端 / 后台端 / 企业端由不同组员**各自独立**基于若依改造，**后期才合并**。
> 冲突全部出在共享面：`sys_menu` 菜单 id、`sys_role` 角色 key、`ruoyi-common` / `ruoyi-framework` 公共代码。

### 4.1 已确认的决策

- **角色去重**：保留 `role_id = 102`（唯一有 `sys_role_menu` 绑定、且被 `user_id = 103` 绑定的「学生」角色）；物理删除残留的 `role_id = 100`、`101`
  - 补充：100 / 101 的 `del_flag` 已经是 `'2'`（若依逻辑删除），本来就**不会**出现在角色管理里，清理属于**数据卫生**，不影响功能
  - 执行脚本：`sql/student_patch.sql` 第 2 节（原 `sql/cleanup_student_role_dup.sql`）
- **用户去重**：保留 `user_id = 103`（`student01`）。用户侧无重复（库里只有 1 / 2 / 103）
- **不重命名 / 不归档 SQL 文件**（2026-09-22 决定）：保持 `sql/`、`ruoyi/` 现有路径不动，只靠 `sql/README.md` + 各文件头 banner 说明用途，避免改动散落在多处文档里的路径引用
- **移除 `sql/ry-vue.sql`**（2026-09-22 决定）：整库 dump 含运行时日志、是早于角色去重与 `interview:data:all` 的旧快照，且三端合并明令禁止合并。移除前已逐表核对，内容被「基础库 + quartz + 我方脚本」完全覆盖，无独有业务内容
- **数据隔离判定方式**：由「判断身份」改为「判断权限」（详见 §1.3）

### 4.2 当前库的真实状态（2026-09-22 核查记录）

| 项 | 现状 |
| :--- | :--- |
| `sys_user` | 1（admin）、2（ry）、103（student01） |
| `sys_user_role` | (1,1)、(2,2)、(103,102) |
| `sys_role` | 1 admin、2 common，以及 **100 / 101 / 102 三条 `role_key` 都是 `student`**（100 / 101 的 `del_flag = '2'`，已被逻辑删除） |
| `sys_role_menu` | role 2 → 85 条；role 102 → 49 条；**role 100 / 101 → 0 条**（可安全物理删除） |
| `sys_menu` | 若依原生 1~1999；学生端占用 2000~2048，其中 2048 = 「学生端」目录 |
| `student02` | ⚠️ 曾被主动删除（操作日志有 `DELETE /system/user/104`），**2026-09-22 已由用户重新加回** |

### 4.3 任务清单

- [x] **①-1** 数据隔离判定改为权限驱动（`StudentDataScopeUtils`：新增 `PERMI_DATA_ALL` / `canViewAll()`，移除 `isAdmin()`）
- [x] **①-2** 修正 `ruoyi/*Menu.sql`：补「学生端」目录的幂等创建语句，`parent_id` 由 `'0'` 改为 `@studentDirId`，8 个文件均可独立运行
- [x] **①-3** 输出 `sql/cleanup_student_role_dup.sql`（保留 102，先核查再删除）—— 现为 `sql/student_patch.sql` 第 2 节
- [x] **①-4** 输出 `doc/学生端对外契约.md`
- [x] **①-5** 8 个 `ruoyi/*Menu.sql` 全部改造为**幂等**（2026-09-22）
  - 每个文件的 7 条 `insert`（1 目录 + 1 模块菜单 + 5 按钮）全部加 `where not exists` 守卫
  - 按钮父菜单 ID 由 `LAST_INSERT_ID()` 改为**按权限标识反查**：`set @parentId = (select menu_id from sys_menu where perms = '...')`，菜单已存在时同样取得到
  - 存在判据统一用 `perms`（模块菜单用 `interview:xxx:list`，按钮用各自 `interview:xxx:query/add/edit/remove/export`）
  - 每个文件末尾加校验查询，应返回 **6 行**（1 模块菜单 + 5 按钮）
  - 效果：第 4 ~ 11 步可**反复重放**，第 13 步绑定数恒为 **49** → 合并演练可以跑第二遍、第三遍
  - 不覆盖的情形：菜单**已存在但 `parent_id` 挂错**时不会自动纠正（干净库重建不会出现；真遇到手工改一行即可）

### 4.4 交付物

| 文件 | 内容 |
| :--- | :--- |
| `doc/学生端对外契约.md` | **核心交付物**：冻结学生端对外边界，三端合并以此为准 |
| `doc/CRUD字段清单.md` | 8 个模块的字段取舍（显示 / 隐藏 / 只读 / 校验）+ 3 个业务决策 + 字典值域 |
| `sql/README.md` | SQL 文件分类说明：哪些能执行、从零重建的 **3 步**顺序、内置账号 |
| **`sql/student_init.sql`** | **一键重建**：8 张表 + 50 条菜单 + 角色账号绑定 + 13 个字典类型 + 26 道演示题（5 节）。**学生端只跑这一个** |
| `sql/student_patch.sql` | 旧库补丁：改列注释 + 角色去重（已建库、不想重建时用） |
| **`sql/student_init.sql`** | **一键重建**：8 张业务表 + 50 条菜单 + 角色账号绑定 + 13 个字典类型 + 26 道演示题（5 节）。**三端合并只收集这一个** |
| `sql/student_patch.sql` | 旧库补丁：改列注释 + 角色去重（已建过库、不想重建时用） |
| `sql/` 下其余 7 个 + `ruoyi/` 下 9 个 | 已被上面两个吸收的**源文件**，留档用，不要单独跑 |

### 4.5 干净库重建的「五块拼图」

| 块 | 内容 | 文件 |
| :-- | :--- | :--- |
| ① | 若依基础库（`sys_*` / `gen_*` / `qrtz_*`） | `RuoYi-Vue/sql/ry_20260417.sql`、`RuoYi-Vue/sql/quartz.sql` |
| ②~⑤ | 学生端 8 张业务表 / 菜单+权限点 / 角色账号绑定 / 业务字典 | **`sql/student_init.sql`** 的第 1~4 节（合并成一个文件） |
| （附） | 题库演示数据（可选） | `sql/student_init.sql` 第 5 节 |

### 4.6 学生角色与账号（`student_init.sql` 第 3 节）的设计要点

- **幂等**，可重复执行（`where not exists` 守卫 + `insert ignore`）
- **不写死 `menu_id`**：绑定关系按「学生端目录 → 其下全部菜单」动态 `INSERT ... SELECT` 算出来，三端合并后菜单 id 整体重排也不受影响
- **不写死 `role_id` / `user_id`**：若依的 `sys_role` / `sys_user` 自增都从 100 起，写死会与别人撞车，改为按 `role_key` / `user_name` 查
- **显式排除 `interview:data:all`** —— 它同样挂在「学生端」目录下，但那是给后台端的全量数据权限，绑给「学生」就等于把隔离关掉
- 建 `student01` + `student02`（后者用于隔离验证），初始密码 `admin123`（复用若依基础库自带的种子密文），**仅供开发演示，上线前必改**
- 末尾自带校验查询，预期 `menu_cnt = 49`、`user_cnt = 2`、`data_all_bound = 0`

---

## 5. 遗留待办（勿忘）

### 5.1 4 个业务外键列 —— 已复核，结论是「现在不用改」

涉及列：`interview_question.session_id`、`interview_qa.session_id`、`interview_qa.question_id`、`interview_report.session_id`，均 `NOT NULL` 且无 `DEFAULT`，Mapper XML 里仍是 `<if test="xxx != null">` 条件列。

**2026-09-22 复核结论（推翻了原判断）：**

- ❌ **原判断有误。** 原文写「手动点『新增』就会报 `Field 'session_id' doesn't have a default value`」—— 不成立。已核查 `views/interview/question|qa|report/index.vue`，三个页面的表单都把 `sessionId` / `questionId` 设成了**必填**（`rules` 中 `required: true`），前端会拦住空提交。阶段一走 UI **不会**触发这个报错。（**S4 更新**：这三个页面的编辑弹窗已全部删除，手填外键框不复存在，本条已无对象。）
- ❌ **原建议也不成立。** 「把 insert 中这 4 列改成无条件列」解决不了问题：无条件列 + 空值 = `Column 'session_id' cannot be null`（错误码 1048），一样是 500。两种写法都会报错，只是错误码不同。
- ✅ **真正的问题不是报错，而是「跨学生引用」。** 表单是手填 `el-input`，学生 A 可以填学生 B 的 `session_id` / `question_id`，造出跨学生的引用关系。行自身的 `user_id` 仍被强制为 A，所以隔离校验不会被绕过，但**引用是脏的**。

**当时的决定是「先不动这 4 列」**（2026-09-22 复核时）。S1~S5 落地后已收口，见本节末尾的 `[x]` 项 ——

- [x] 后端按业务生成 `session_id` / `question_id`，不再由前端传 —— **S1 已落地**：`interview_question.session_id` 由 `InterviewSessionServiceImpl.insertInterviewSession` 生成；`interview_session.job_profile_id` 写入前用 `StudentDataScopeUtils.checkOwner` 校验归属
- [x] 写入前校验被引用记录存在且**归属当前用户** —— **S1 已落地**（岗位画像走 `checkOwner`；场次归属由 `bindOwner` + `scopeToCurrentUser` 保证）
- [x] 前端表单去掉这几个手填输入框 —— `session/index.vue` ✅ S1、`question/index.vue` ✅ S2、`qa/index.vue` ✅ S3、`report/index.vue` ✅ S4。**四个页面的编辑弹窗 / 手填外键框已全部消失**
- [x] **S5 结论：改。** 4 列在 `insert` 里已改为无条件列（漏传即 1048，fail-fast）。`insert` 是独立语句、不与 `update` 共用列片段，且 4 个外键在全部 insert 路径上都有赋值 —— 改动安全。详见 `doc/面试流程四件套形态方案.md` §13.2

### 5.2 数据隔离的运行时验证（5 项中 3 项已通过）

- [x] `student01` 新增数据后，库里 `user_id` 是 student01 的（2026-09-22 自测通过）
- [x] `student02` 登录后列表看不到 student01 的数据（2026-09-22 自测通过）
- [x] `admin` 登录后能看到全部学生的数据（2026-09-22 自测通过）
- [ ] 越权访问接口（拿别人的 id 调详情 / 修改 / 删除）返回「无权操作或查看该xxx数据」
- [ ] 未登录访问接口返回 401

> `student02` 曾在测试中被误删，2026-09-22 已由用户重新加回。

#### 字段级写权限已堵死（路线 2，2026-09-22）

记录级隔离（`scopeToCurrentUser` / `checkOwner` / `bindOwner`）解决的是「能不能碰这条记录」，
但**学生持有 `interview:*:add|edit|remove` 权限点**，直接调通用 `POST/PUT/DELETE /interview/xxx`
仍能绕过业务入口改系统字段（`status` / `score` / `ai_comment` / `total_score`）—— 这是**设计缺陷，不是安全漏洞**
（改的是自己的数据）。若依的权限点粒度做不到「同一权限点、不同字段」，所以闸门放在 Service 层。

- 新增 `StudentDataScopeUtils.requireManage(label)`：`!canViewAll()` 时抛 `ServiceException`。
- 加闸门：4 个流程模块的通用写方法共 **13 处**（session 的 `update`；question / qa / report 的 `insert`/`update`/`deleteByIds`/`deleteById`）。
- 不加闸门：业务入口（开始面试 / 删场次·级联 / 作答提交 / 提前结束 / 建壳 / 手工填分）。
- 判据 `interview:data:all`：后台侧角色需持有该权限点才不被误伤（`user_id=1` 超管天然通过）。

#### 为什么第一次「F12 → Network 里什么都没有」

根因：**`student02` 是全新账号，8 个模块里一条数据都没有 → 列表是空的 → 没有「修改」按钮可点 → 自然没有请求发出。** 这其实是**隔离在正常工作**，不是故障。

另外三个容易踩的坑：

1. **F12 要先打开再操作。** Network 面板在页面导航 / 刷新时会清空，事后才打开就什么都看不到。
2. **勾上 `Preserve log`（保留日志）**，否则跳转 / 刷新会清掉之前的请求。
3. **过滤器选 `All` 或 `Fetch/XHR`，并清空筛选框**，否则请求会被过滤掉。

#### 越权测试的正确步骤（2026-09-22 修订）

> ⚠️ **用哪个模块做这个测试**：学生档案已改成一页式表单，**没有列表、也没有「修改」按钮**了。
> 请改用**还有列表的模块** —— **「学生岗位画像」已经改好且保留列表，直接拿它做最省事**（把下文的 `/interview/xxx` 换成 `/interview/jobprofile`）。

**准备**：用 `admin` 登录 → 目标模块 → 列表里能看到 `student01` 与 `student02` 的记录 → 记下 `student01` 那条的「主键ID」。
（若 `student01` 还没有记录，先登录 `student01` 新增一条。）

**测试**：

1. 打开 F12 → Network → 勾 `Preserve log` → 过滤器选 `All` / `Fetch/XHR`
2. 保持 F12 打开，登录 `student02`
3. 进入目标模块 —— 列表应为**空**（隔离生效）
4. 点「新增」→ 填必填项 → 确定 → Network 里应出现 `POST /interview/xxx`
5. 列表出现一行 → 点该行「修改」→ Network 里应出现 `GET /interview/xxx/{自己的id}`
6. 右键那条 `GET` → **Copy → Copy as fetch**
7. 贴进 Console，把 id 改成 `student01` 的记录 id → 回车
8. 预期返回 `{"code":500,"msg":"无权操作或查看该学生档案数据"}`

**附加一项（更省事，不需要第二个账号的 id）**：把 id 改成不存在的值（如 `999999`）→ 预期 `{"code":500,"msg":"数据不存在或已删除"}`。
两条消息不同，可用来区分「越权」与「记录不存在」两种分支（`checkOwner` 见 `StudentDataScopeUtils.java:91-102`）。

**未登录 401**：退出登录后直接请求任意 `/interview/xxx/list`，应返回 401。

---

## 6. 工作约定与踩坑

### 6.1 工作方式

- **编译 / 构建由用户自己执行**，不要代为运行 `mvn` / `npm run build`
- 用户对改动范围要求严格，说「先只…」时不要顺手扩大范围；做完要清楚列出**改了什么、没改什么**
- **不做文件重命名 / 归档**（用户明确决定）
- 输出格式：**简略工作总结 → 我需要手动做的事（没有可省略）→ 下一步建议**
- ⚠️ **同一条消息里不要并行改同一个文件** —— 同一文件的并发编辑是「读-改-写」，会互相覆盖（两个都报成功、实际只落一个）。同一文件多处改动**串行**提交，改完立刻 `grep` / `sed` 复核。不同文件可并行。

### 6.2 两棵树必须同步

| 后端 | 前端 |
| :--- | :--- |
| `RuoYi-Vue/ruoyi-admin/.../interview/**` ↔ `ruoyi/main/java/com/ruoyi/interview/**` | `RuoYi-Vue3/src/views/interview/**` ↔ `ruoyi/vue/views/interview/**` |

`ruoyi/` 是生成器产出暂存区，**两份必须字节一致**。收尾用 `diff -rq` 校验。

### 6.3 换行符

- **仓库里没有 `.gitattributes`**，且 `core.autocrlf=true`
- 所有源文件 / SQL / 文档都是 **CRLF**
- ⚠️ **不要用 `grep -q $'\r'` 判断换行符** —— 本机 Git Bash 下会误报成 LF。可靠做法：用 Python 统计 `b"\r\n"` 出现次数
- 脚本批量改写时必须 `open(..., newline="")` 并按文件实际换行拼接，否则会写入裸 LF 造成混合行尾

### 6.4 环境（仅备查，默认不主动使用）

- JDK 21：`D:\Java\jdk-21.0.12.1+1`
- Maven 3.9.16：`C:\Users\81383\.m2\wrapper\dists\apache-maven-3.9.16\<hash>\bin\mvn.cmd`
- 本地仓库：`C:\Users\81383\.m2\repository`，可离线 `-o` 编译

---

## 7. 附录：阶段一第 1 步的建表字段模板

设计表字段时统一带若依习惯字段，逐列填写：

| 序号 | 字段列名 | 字段描述 | 物理类型 | Java 类型 | java 属性 | 插入 | 编辑 | 列表 | 查询 | 查询方式 | 必填 | 显示类型 | 字典类型 |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |

**取值说明**

- **Java 类型**：`Long` / `String` / `Integer` / `Double` / `BigDecimal` / `Date` / `Boolean`
- **查询方式**：`=` / `!=` / `>` / `>=` / `<` / `<=` / `LIKE` / `BETWEEN`
- **显示类型**：文本框 / 文本域 / 下拉框 / 单选框 / 复选框 / 日期控件 / 图片上传 / 文件上传 / 富文本控件
- **字典类型**：`sys_user_sex`（用户性别）/ `sys_show_hide`（菜单状态）/ `sys_normal_disable`（系统开关）/ `sys_job_status`（任务状态）/ `sys_job_group`（任务分组）/ `sys_yes_no`（系统是否）/ `sys_notice_type`（通知类型）/ `sys_notice_status`（通知状态）/ `sys_oper_type`（操作类型）/ `sys_common_status`（系统状态）

**产出**：`doc/一阶段三级功能清单.xlsx`（一级 / 二级 / 三级菜单 → 实体 → 表名 → CRUD 类型 → 权限标识）
