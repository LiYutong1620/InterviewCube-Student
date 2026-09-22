# 学生端 · 8 个模块字段清单（CRUD 语义收紧）

> 目的：把若依代码生成器产出的「后台管理式」CRUD，收紧成「学生端」该有的样子。
> 维护人：tong　最后更新：2026-09-22
> 配套：`sql/student_init.sql` 第 1 节（表结构）、`PLAN.md`「阶段二」

**列表**列：`显示` / `不显示`
**表单**列：`可编辑` / `只读` / `不显示` / `隐藏提交`（以 hidden 存在）/ `后端写入`（前端不传）

---

## 一、通用规则（8 个模块统一适用）

### 1.1 一律不显示的字段

| 字段 | 列表 | 表单 | 理由 |
| :--- | :--- | :--- | :--- |
| `id` | 不显示 | 隐藏提交 | 主键，学生不需要看；表单里保留为隐藏字段供提交 |
| `user_id` | 不显示 | 后端写入 | 数据归属，由 `StudentDataScopeUtils.bindOwner` 强制写入，前端不接受传参 |
| `del_flag` | 不显示 | 不显示 | 逻辑删除标记 |
| `create_by` / `update_by` | 不显示 | 不显示 | 操作人；学生端只有自己，没有信息量 |
| `status` | 不显示 | 不显示 | 后台「停用」标记，学生看到会困惑，也不该自己改 |
| `remark` | 不显示 | **可编辑** | **「备注」= 学生自己的备注**（2026-09-22 拍板 **B：保留**）。列表不放（列表空间宝贵），只在表单里给一个多行文本框；列名统一叫「备注」 |

> **2026-09-22 拍板记录**：`remark` 最初按「内部备注」定为不显示，后改为 **B —— 保留为学生自己的备注**。
> 各模块表单统一加一个 `el-input type="textarea"`（`:rows="3"` / `maxlength="500"` / `show-word-limit`），并放进提交白名单 `EDITABLE_FIELDS`。
> ⚠️ 若将来后台端要往 `remark` 写内部备注，会与学生写的内容互相覆盖 —— 那时需要拆成两个列。

### 1.2 列表显示、表单不出现

| 字段 | 说明 |
| :--- | :--- |
| `create_time` / `update_time` | 列表可显示「创建时间」，表单里不出现（后端自动维护） |

### 1.3 查询区要精简

学生只有自己那几条数据，**不需要现在这种 8 个条件的搜索区**：

- **1:1 模块**（学生档案）→ 去掉整个查询区　✅ 已完成
- **1:N 模块** → 最多保留 1~2 个有筛选意义的条件（见各模块表）

### 1.4 统一要补的校验

| 字段 | 规则 |
| :--- | :--- |
| `phone` | `/^1[3-9]\d{9}$/`（11 位手机号） |
| `email` | `/^[\w.-]+@[\w-]+(\.[\w-]+)+$/` |
| `graduation_year` | 年份选择器，范围 1980 ~ 当前年 + 6 |

---

## 二、逐模块清单

### 2.1 学生档案 `student_profile` —— 1:1（`uk_user_id`）　✅ **已完成 2026-09-22**

**形态**：与用户是 **1:1**（`uk_user_id`）→ 已改成**一页式表单**：打开即编辑，无列表、无分页、无删除按钮。
（生成器原产的「列表 + 分页 + 多选删除」形态已废弃）

> **落地结果**（两棵树同步）：
> - `RuoYi-Vue3/src/views/interview/profile/index.vue` → 重写为「我的档案」一页式表单（252 行）
>   - 去掉查询区 / 列表 / 分页 / 多选 / 删除 / 导出按钮
>   - 打开即 `listProfile({pageNum:1,pageSize:1})` 取第一条回填；无记录则提交时走 `addProfile`
>   - `education` 改 `el-select`（`student_education`）、`graduation_year` 改 `el-date-picker type="year" value-format="YYYY"`
>   - `current_level` / `current_points` / `guide_status` / `status` 移到「成长信息」分隔线下方，纯展示，**且不进提交载荷**
>   - 提交时用白名单 `EDITABLE_FIELDS` 拼 payload，系统字段永远不会被前端覆盖
>   - 校验：`nickname` 必填、`phone` `/^1[3-9]\d{9}$/`、`email` `type:"email"`、`graduation_year` `/^(19|20)\d{2}$/`
> - `RuoYi-Vue3/src/views/interview/profile/view.vue` → **已删除**（一页式表单后抽屉成为死代码）
> - `StudentProfile.java` → 去掉 `id` / `userId` / `guideStatus` / `status` 上的 `@Excel`；`gender` / `education` 补 `readConverterExp`（见 4.1）

> ⚠️ 下表「呈现」列描述的是**改造后的实际形态**。学生档案已无列表，全部字段只出现在一页式表单里。

| 字段 | 含义 | 呈现 | 控件 / 校验 |
| :--- | :--- | :--- | :--- |
| `id` | 主键 | 不出现 | 仅随 payload 提交，用于区分 `add` / `update` |
| `user_id` | 归属 | 不出现 | 后端 `bindOwner` 强制写入 |
| `nickname` | 昵称 | **可编辑** | `el-input`，**必填**，`maxlength="50"` |
| `avatar` | 头像 | **可编辑** | `image-upload`，`:limit="1"` `:fileSize="2"` |
| `real_name` | 真实姓名 | **可编辑** | `el-input`，`maxlength="50"` |
| `gender` | 性别 | **可编辑** | `el-select`，字典 `sys_user_sex`，可清空 |
| `phone` | 手机号 | **可编辑** | `el-input`，`maxlength="11"`，正则 `/^1[3-9]\d{9}$/` |
| `email` | 邮箱 | **可编辑** | `el-input`，`maxlength="100"`，`type: "email"` |
| `school` | 学校 | **可编辑** | `el-input`，`maxlength="100"` |
| `major` | 专业 | **可编辑** | `el-input`，`maxlength="100"` |
| `education` | 学历 | **可编辑** | `el-select`，字典 `student_education`（1 专科 / 2 本科 / 3 硕士 / 4 博士） |
| `graduation_year` | 毕业年份 | **可编辑** | `el-date-picker type="year"`，`value-format="YYYY"`，正则 `/^(19\|20)\d{2}$/` |
| `remark` | 备注 | **可编辑** | `el-input type="textarea"`，`:rows="3"`，`maxlength="500"` |
| `current_level` | 当前等级 | 只读展示 | 「成长信息」区，空值显示 `-` |
| `current_points` | 当前积分 | 只读展示 | 同上（用 `display()` 判空，避免 `0` 被当成空） |
| `guide_status` | 引导状态 | 只读展示 | `<dict-tag>` 字典 `student_guide_status` |
| `status` | 账号状态 | 只读展示 | `<dict-tag>` 字典 `sys_normal_disable` |
| `create_time` / `update_time` | 时间 | 只读展示 | `parseTime(..., '{y}-{m}-{d} {h}:{i}')` |
| `del_flag` / `create_by` / `update_by` | — | 不出现 | 见通用规则 |

**查询区**：✅ 整个去掉。
**列表 / 分页 / 多选 / 删除 / 导出**：✅ 全部去掉（1:1 模块，一个学生只有一行）。
**删除**：不允许学生删除自己的档案。

---

### 2.2 学生简历 `student_resume` —— 1:N（可多份）　✅ **已完成 2026-09-22**

> **落地结果**（两棵树同步）：
> - `RuoYi-Vue3/src/views/interview/resume/index.vue` → **列表 + 弹窗**形态，370 行
>   - 查询区从 4 个条件砍到 1 个：**只留「简历名称」**（去掉「文件类型」「是否默认」「状态」）
>   - 列表去掉：主键ID / 所属学生用户ID / 解析状态 / 解析完成时间 / 状态 / 创建者 / 更新者 / 更新时间
>   - 列表保留：简历名称 / 文件（查看链接）/ 类型 / 来源(dict-tag) / 默认(tag) / 创建时间 / 操作
>   - `source_type` → `el-select`（`student_resume_source`），默认「本地上传」——**生成器原来漏了这个字段，表单里根本没有它**
>   - `is_default` → `el-switch`（1 / 0），列表用 `el-tag` 显示「默认」（原页面错接 `sys_yes_no`，见下）
>   - `remark` → 「备注」多行文本框
>   - `file_url` → `file-upload`，`:limit="1"` / `:fileSize="10"` / `:fileType="['pdf','doc','docx']"`
>   - 提交用白名单 `EDITABLE_FIELDS`，`status` / `parse_*` 永不进 payload
> - `RuoYi-Vue3/src/views/interview/resume/view.vue` → **已删除**（弹窗已覆盖全部内容，抽屉是死代码）
> - `StudentResume.java` → `@Excel` 9 → 4：去掉 `id` / `userId` / `parseStatus` / `parseTime` / `status`；`sourceType` / `isDefault` 补 `readConverterExp`，`fileType` 列名去掉括号说明
> - **后端补上「唯一默认」保障**（与岗位画像同一套）：
>   - `StudentResumeMapper` 新增 `clearDefaultByUserId(userId, keepId)`
>   - `StudentResumeServiceImpl` 的 `insert` / `update` 加 `@Transactional`；设为默认时先清掉该学生名下其他默认
>   - `update` 时前端不传 `user_id`，用 `resolveOwnerId()` 回查数据库拿归属

> ⚠️ **`file_type` / `file_size` 的处理与清单原计划不同，原因如下**：
> 若依的上传接口 `/common/upload` 只返回 `{fileName, newFileName, originalFilename, url}`，**不含文件类型与大小**。
> 而 `/common/upload` 在 `ruoyi-common` 里，属于**三端共享面**，不适合为学生端单独改。
> - `file_type`：**前端从文件地址后缀推导**（`resolveFileType()`），学生不手填 —— 列表里能正常显示 `pdf` / `docx`
> - `file_size`：**阶段一不做**（不显示、不提交，库里的 `DEFAULT 0` 保持不变）。将来要做，得先给上传接口加返回字段

> ⚠️ **`is_default` 的 `sys_yes_no` 坑**（与岗位画像同源）：原页面用 `sys_yes_no` 渲染，但它的值域是 `Y`/`N`，而列是 `CHAR(1) DEFAULT '0'`（0否 1是）。
> **处理**：不接字典，前端 `el-switch` + 导出 `readConverterExp`。清理 SQL 见 2.3 节。

| 字段 | 含义 | 呈现 | 控件 / 校验 |
| :--- | :--- | :--- | :--- |
| `id` | 主键 | 列表不显示 | 仅随 payload 提交，用于区分 `add` / `update` |
| `user_id` | 归属 | 列表不显示 | 后端 `bindOwner` 强制写入 |
| `resume_name` | 简历名称 | 列表显示 · 可编辑 | `el-input`，**必填**，`maxlength="100"` |
| `file_url` | 文件地址 | 列表「查看」链接 · 可编辑 | `file-upload`，**必填**，`:limit="1"`，限 pdf / doc / docx，≤10MB |
| `file_type` | 文件类型 | 列表显示 | **前端从 URL 后缀推导**，不进表单、不由学生填 |
| `file_size` | 文件大小 | 不显示 | **阶段一不做**（上传接口不返回大小） |
| `source_type` | 来源 | 列表 dict-tag · 可编辑 | `el-select` 字典 `student_resume_source`，默认 `1` 本地上传 |
| `is_default` | 是否默认 | 列表 tag · 可编辑 | `el-switch`（1 / 0）；**后端保证同一学生只有一份默认** |
| `parse_status` / `parse_result` / `parse_time` | 解析相关 | 不显示 | AI 解析阶段一不做，恒为「未解析」 |
| `status` / `del_flag` / `create_by` / `update_by` | — | 不显示 | 见通用规则 |
| `remark` | 备注 | **可编辑** | `el-input type="textarea"`，`:rows="3"`，`maxlength="500"` |
| `create_time` | 创建时间 | 列表显示 | `parseTime(..., '{y}-{m}-{d}')` |
| `update_time` | 更新时间 | 不显示 | 学生端无信息量 |

**查询区**：只留「简历名称」（模糊匹配）。
**形态**：1:N 保留「列表 + 分页 + 多选删除 + 新增 / 修改 / 删除 / 导出」。

---

### 2.3 学生岗位画像 `student_job_profile` —— 1:N（可多个目标岗位）　✅ **已完成 2026-09-22**

> **落地结果**（两棵树同步）：
> - `RuoYi-Vue3/src/views/interview/jobprofile/index.vue` → **列表 + 弹窗**形态（1:N 保留列表），360 行
>   - 查询区从 3 个条件砍到 2 个：**行业 + 难度**（去掉「岗位名称」「是否默认」「状态」）
>   - 列表去掉：主键ID / 所属学生用户ID / 状态 / 创建者 / 更新者 / 更新时间
>   - 列表保留：岗位名称 / 行业(dict-tag) / 难度(dict-tag) / 目标企业类型(dict-tag) / 默认(tag) / 创建时间 / 操作
>   - `industry` / `difficulty` / `company_type` 三个文本框 → `el-select`，分别绑 `student_industry` / `student_difficulty` / `student_company_type`
>   - `is_default` → `el-switch`（`active-value="1"` / `inactive-value="0"`），列表用 `el-tag` 显示「默认」
>   - `remark` → 「备注」多行文本框（`el-input type="textarea"`，`:rows="3"` / `maxlength="500"`），学生自己的备注
>   - 提交用白名单 `EDITABLE_FIELDS`，`status` 永不进 payload
> - `RuoYi-Vue3/src/views/interview/jobprofile/view.vue` → **已删除**（6 个字段的弹窗已覆盖全部内容，抽屉是死代码）
> - `StudentJobProfile.java` → 去掉 `id` / `userId` / `status` 的 `@Excel`；其余 5 个字段列名去掉括号枚举并补 `readConverterExp`
> - **后端补上「唯一默认」保障**（原来只有一句前端约定，没有真正落地）：
>   - `StudentJobProfileMapper` 新增 `clearDefaultByUserId(userId, keepId)`
>   - `StudentJobProfileServiceImpl` 的 `insert` / `update` 加 `@Transactional`；设为默认时先清掉该学生名下其他默认
>   - `update` 时前端不传 `user_id`，用 `resolveOwnerId()` 回查数据库拿归属

> ⚠️ **顺带修掉一个生成器埋的 bug**：原页面用 `sys_yes_no` 字典渲染 `is_default`，但 `sys_yes_no` 的值域是 **`Y`=是 / `N`=否**，而 `is_default` 是 `CHAR(1) DEFAULT '0'`、注释为「0否 1是」。
> 后果：下拉选「是」会把 `'Y'` 写进一个语义为 `0/1` 的列，列表回显也会因为 `Y` 匹配不上字典而原样显示。
> **处理**：`is_default` 不接任何字典 —— 前端用 `el-switch`（0/1），导出用 `@Excel(readConverterExp = "0=否,1=是")`。
> **不新增「是/否」字典**：避免再造一个与 `sys_yes_no` 名字近义、值域不同的字典，扩大三端合并的混淆面。
> **数据卫生**：若之前用旧页面存过，库里可能已有 `'Y'` / `'N'` 残留，建议清一次：
> ```sql
> update student_job_profile set is_default = '1' where is_default = 'Y';
> update student_job_profile set is_default = '0' where is_default in ('N', '');
> ```
> `student_resume.is_default` 是同一个坑，**已在 2.2 用同样方式处理**（清理 SQL 同样适用于 `student_resume`，把表名换掉即可）。

| 字段 | 含义 | 呈现 | 控件 / 校验 |
| :--- | :--- | :--- | :--- |
| `id` | 主键 | 列表不显示 | 仅随 payload 提交，用于区分 `add` / `update` |
| `user_id` | 归属 | 列表不显示 | 后端 `bindOwner` 强制写入 |
| `job_name` | 岗位名称 | 列表显示 · 可编辑 | `el-input`，**必填**，`maxlength="100"` |
| `industry` | 行业 | 列表 dict-tag · 可编辑 | `el-select` 字典 `student_industry`，**必填** |
| `difficulty` | 难度 | 列表 dict-tag · 可编辑 | `el-select` 字典 `student_difficulty`，**必填** |
| `company_type` | 目标企业类型 | 列表 dict-tag · 可编辑 | `el-select` 字典 `student_company_type`，可清空 |
| `is_default` | 是否默认 | 列表 tag · 可编辑 | `el-switch`（1 / 0）；**后端保证同一学生只有一个默认** |
| `status` / `del_flag` / `create_by` / `update_by` | — | 不显示 | 见通用规则 |
| `remark` | 备注 | **可编辑** | `el-input type="textarea"`，`:rows="3"`，`maxlength="500"` |
| `create_time` | 创建时间 | 列表显示 | `parseTime(..., '{y}-{m}-{d}')` |
| `update_time` | 更新时间 | 不显示 | 学生端无信息量 |

**查询区**：行业 + 难度（原「岗位名称」「是否默认」「状态」已去掉）。
**形态**：1:N 保留「列表 + 分页 + 多选删除 + 新增 / 修改 / 删除 / 导出」。

---

### 2.4 模拟面试场次 `interview_session` —— 1:N　✅ **已完成 2026-09-22（S1）**

⚠️ **这个模块不该有「新增 / 修改」表单** —— 它是面试流程的产物，不是学生手填的东西。

| 字段 | 含义 | 列表 | 表单 | 说明 |
| :--- | :--- | :--- | :--- | :--- |
| `session_no` | 场次编号 | 显示（可点开详情） | 不显示 | 后端生成 `S + yyyyMMddHHmmss + 3 位随机` |
| `job_profile_id` | 关联岗位画像 | 不显示 | 选择（必填） | 「开始面试」对话框里从**自己的**岗位画像选 |
| `industry` / `job_name` / `difficulty` | 面试参数 | 岗位名 + 难度显示 | 不传 | 由所选岗位画像带入，前端一律不传 |
| `question_type` | 题型 | 显示（多标签） | 选择（多选，可不选） | 学生显式选，逗号拼接后提交 |
| `total_count` / `answered_count` | 题数进度 | 合并为「已答 / 总题」 | 不传 | 系统维护 |
| `status` | 场次状态 | 显示（`dict-tag`） | 不传 | 建场时后端强制 `1`（进行中） |
| `score` | 本场总分 | 显示（空值 `-`） | 不传 | 评估后写入 |
| `start_time` / `end_time` / `duration` | 时间 | 显示（精确到分） | 不传 | `start_time` 建场时写 now |
| `report_id` | 关联报告 | 详情抽屉显示「已生成 / 未生成」 | 不传 | 冗余指针，权威关联是 `interview_report.session_id` |
| `user_id` / 系统字段 | — | 不显示 | 不传 | 见通用规则 |

**✅ 落地结果（2026-09-22，S1）**

- 页面 = **历史面试记录列表**：查询区只有「岗位名称 + 状态」；列 9 个；行内操作按 `status` 变化
- 「开始面试」对话框 = 目标岗位 + 题型（多选）+ 题目数（默认 5，上限 20）；**其余字段前端一律不传**
- 后端 `insertInterviewSession` 生成 `session_no` / `user_id` / 行业 / 岗位名 / 难度 / `status='1'` / `start_time`，
  并按「行业+难度+题型 → 行业+题型 → 仅题型」**逐层累积补抽**（每层只补差、用 `id not in` 排除已抽中的题）
  从 `question_bank`（`status='0'`）抽题写入 `interview_question`。
  ⚠️ 必须累积到凑够 `totalCount` 为止，不能「第一层命中就返回」——否则冷门组合只会出 1 道题
- 删除 = **只给场次删除入口**，`@Transactional` 级联删该场的题目 / 问答 / 报告
- `@Excel` 已清理：摘掉 `id` / `user_id` / `job_profile_id` / `status`；`difficulty` 补 `readConverterExp`；
  时间字段改 `yyyy-MM-dd HH:mm:ss`（原来只有日期，列表显示不出时分）

**偏差说明**：`question_type` 是多选拼接值（如 `1,2`），`readConverterExp` 做不了多值翻译，故导出时**不配转换**，保留原始码值。

---

### 2.5 面试题目 `interview_question` —— 1:N（属于某场次）　✅ **已完成 2026-09-22（S2）**

| 字段 | 含义 | 列表 | 表单 | 说明 |
| :--- | :--- | :--- | :--- | :--- |
| `session_id` | 所属场次 | 不显示（由路由 `?sessionId=` 限定） | 不传 | ← **4 个外键列之一**，由后端在抽题时写入 |
| `bank_question_id` | 关联题库 | 不显示 | 不传 | 后端写入 |
| `question_no` | 题号 | 显示（「第 N 题」） | 不传 | 后端写入，前端按它升序排 |
| `question_type` | 题型 | 显示（`dict-tag`） | 不传 | 从题库带过来 |
| `question_content` | 题干 | 显示（tooltip） | 不传 | 生成后不改 |
| `reference_answer` | 参考答案 | 只读（**提交后可见**） | 不传 | 见决策 1 |
| `key_points` | 关键要点 | 只读（**提交后可见**，`<ul>` 渲染） | 不传 | 见决策 1 |
| `is_follow_up` / `parent_question_id` | 追问关系 | 不显示 | 不传 | 阶段一恒为「否」 |
| `source` | 来源 | 显示（`dict-tag`） | 不传 | 题库抽取 = `2` |
| `user_id` / 系统字段 | — | 不显示 | 不传 | 见通用规则 |

**✅ 落地结果（2026-09-22，S2）**

- 页面 = **按场次查看题目**：入口条件只有路由参数 `?sessionId=x`
  - 不带 `sessionId` → 空态「请先从『模拟面试场次』选择一场面试」+ 场次下拉 + 「去场次列表」
  - 带 `sessionId` → 顶部场次信息条（场次编号 / 岗位名 / 状态 / 进度）+ 题目列表
- 去掉：整个查询区、新增 / 修改 / 删除按钮、多选列、编辑弹窗、两个手填外键框
- 列 = 题号 / 题型 / 题干 / 来源 / **我的作答（已作答·未作答）** / 操作（查看）
- 详情抽屉 = 题号 / 题型 / 来源 / 题干 / **我的作答**（时间·耗时·方式·内容·得分） / **参考答案 + 关键要点（门控）**
- **后端一行没改**：三个接口（`session/{id}`、`question/list?sessionId=`、`qa/list?sessionId=`）都已有，
  且都走 `scopeToCurrentUser`，「我的题目 / 我的作答」是后端按登录用户过滤的
- 导出保留（约束 5），导出时会带上当前 `sessionId`，只导这一场

**决策 1 的落地判据**（列表页与抽屉用同一规则）：

```
可见 = 场次 status === '2'（已完成）  ||  本题已有 interview_qa 记录
```

「本题已有作答」来自列表页一次性拉回的 `qaMap`（按 `questionId` 索引），通过 props 传给抽屉，抽屉不再单独请求。

**✅ S5 已做**：`InterviewQuestion` 的 `@Excel` 清理（9 → 5 列）—— 摘掉 `id` / `sessionId` / `userId` / `status`；
`questionType` 补 `"1=行为面,2=技术面,3=HR面,4=case面"`、`source` 补 `"1=AI生成,2=题库抽取,3=简历解析"`、
`isFollowUp` 补 `"0=否,1=是"`；`questionNo` 列名去括号（「题号(第几题)」→「题号」）。
**参考答案与关键要点本来就没挂 `@Excel`，不会从导出里漏出去。**

---

### 2.6 面试问答 `interview_qa` —— 1:N（属于某场次）　✅ **已完成 2026-09-22（S3）**

| 字段 | 含义 | 列表 | 表单 | 说明 |
| :--- | :--- | :--- | :--- | :--- |
| `session_id` / `question_id` | 归属 | 不显示 | 不手填 | ← **另外 3 个外键列**，后端带入 |
| `question_content` | 题干（冗余） | 显示 | 不显示 | — |
| `answer_content` | 作答内容 | 显示 | 可编辑 | **仅「进行中」可改** |
| `answer_type` | 作答方式 | 显示 | 可编辑 | 阶段一只做「文字」，其余选项先禁用 |
| `audio_url` / `video_url` | 音视频 | 不显示 | 不显示 | 阶段一不启用 |
| `answer_time` / `duration` | 作答时间 / 耗时 | 显示 | 不显示 | 提交时后端写 |
| `score` | 本题得分 | 显示 | 不显示 | AI 评分（阶段一不做） |
| `ai_comment` | AI 点评 | 显示 | 不显示 | 同上 |
| `is_follow_up` / `parent_id` | 追问关系 | 不显示 | 不显示 | — |
| 系统字段 | — | 不显示 | 不显示 | 见通用规则 |

**✅ 落地结果（2026-09-22，S3）**

- 页面 = **逐题作答页**：入口条件同样只有路由参数 `?sessionId=x`
  - 不带 `sessionId` → 空态「请先从『模拟面试场次』选择一场面试」+ 场次下拉 + 「去场次列表」
  - 场次 `未开始` / `进行中` → **逐题作答模式**：题号导航 + 当前题 + 文本域 + 「提交并下一题」+ 本题计时
  - 场次 `已完成` / `已中断` → **只读回顾模式**：题干 + 我的作答 + 参考答案 + 本题得分
  - 额外给了「提前结束」（进行中 → 已中断），避免中途退出只能删场次
- 写入口只有一个：`POST /interview/qa/submit`（`api/interview/qa.js` 的 `submitQa`）
  - 前端只传 `sessionId` / `questionId` / `answerContent` / `answerType` / `duration`
  - `answer_time` 由服务端取当前时间；`user_id` 取场次归属；`question_content` 取题目；`status` 固定正常
  - `score` / `ai_comment` 前端传了也不采信（阶段一由 AI 阶段写）
- 同一题重复提交 = **覆盖**（按 `session_id + question_id + is_follow_up='0'` 定位主作答），阶段一一题一条记录
- 全部题目答完 → 后端把场次置 `已完成`、写 `end_time`、算 `duration`；`answered_count` = 该场有作答记录的题目数（去重）
- 导出保留（约束 5），导出时会带上当前 `sessionId`，只导这一场

**✅ S5 已做**：`InterviewQa` 的 `@Excel` 清理（12 → 7 列）—— 摘掉 `id` / `sessionId` / `questionId` / `userId` / `status`；
`answerType` 补 `"1=文字,2=语音,3=视频"`、`isFollowUp` 补 `"0=否,1=是"`；`questionContent` / `answerContent` 列名去掉说明性括号；
`answerTime` 的 `dateFormat` 由 `yyyy-MM-dd` 改为 `yyyy-MM-dd HH:mm:ss`（与场次的时间列一致，原来时分被吞了）。
**`qa/view.vue` 已删除** —— 作答页不再用「列表 + 抽屉」形态，抽屉是死代码（与 `profile` / `resume` / `jobprofile` 一致）。

---

### 2.7 面试复盘报告 `interview_report` —— 1:1（对场次）　✅ **已完成 2026-09-22（S4）**

⚠️ 同样是**流程产物**，不该有 CRUD 表单。

| 字段 | 含义 | 列表 | 表单 | 说明 |
| :--- | :--- | :--- | :--- | :--- |
| `report_no` | 报告编号 | 显示（链接） | 不显示 | 后端生成 |
| `session_id` | 关联场次 | **不显示裸 id** | 不手填 | 后端带入；列表显示「岗位名 + 开始时间」 |
| `total_score` | 总分 | 显示 | 不显示 | 后端按五维平均算 |
| `score_completeness` / `_logic` / `_fluency` / `_depth` / `_confidence` | 五维得分 | 详情 | 手工填分时可填 | 雷达图五轴 |
| `radar_data` | 雷达图数据 | **不显示** | 不显示 | 阶段三 AI 的原始输出，阶段一恒为空；雷达图改由五维分构建 |
| `summary` / `weak_points` / `suggest` | 总结 / 薄弱点 / 建议 | 详情 | 手工填分时可填 | `weak_points` 是 JSON 数组 |
| `pdf_url` | PDF 地址 | 详情（下载入口） | 不显示 | 阶段一不生成，按钮先留好 |
| `generate_status` / `generate_time` | 生成状态 / 生成时间 | 显示 | 不显示 | — |
| 系统字段 | — | 不显示 | 不显示 | 见通用规则 |

**✅ 落地结果（2026-09-22，S4）**

- `report/index.vue`（两棵树）：408 行裸 CRUD → **348 行只读列表 + 手工填分**
  - **去掉**：新增 / 修改 / 删除按钮、`type="selection"` 多选列、编辑弹窗及其全部表单逻辑（`handleAdd` / `handleUpdate` / `submitForm` / `handleDelete` / `handleSelectionChange` / `reset` / `cancel` / `form` / `rules`）、手填的 `radar_data` 与五维输入框
  - **查询区**：换成「岗位名称 + 生成状态」（原「报告编号」「关联面试场次ID」「状态」三个框去掉）
  - **列表列**（18 → 6）：报告编号（`el-link`）/ **关联场次**（岗位名 + 开始时间，不再显示裸 `sessionId`）/ 总分 / 生成状态（`dict-tag`）/ 生成时间 / 操作
  - **操作**：「查看」（开详情抽屉）+「填分」（`v-hasPermi="['interview:report:edit']"`）
  - **保留**：分页 + 导出（导出按 `PLAN.md` §2.3 的全局决定保留）
  - `?sessionId=x` 下钻（S1 的「查看报告」）：先用 `listReport({sessionId, pageSize: 1})` 定位那一条再开抽屉
- `report/view.vue`（两棵树）：181 行平铺抽屉 → **364 行报告详情**
  - 场次信息条 + **总分大字**（52px）+ **五维雷达图**（`echarts` 5.6.0 的 `radar`）+ 五维分数条（`el-progress` 分段配色）+ 总结 / 薄弱点（`weak_points` JSON → `el-tag` 列表）/ 改进建议 + PDF 下载入口
  - **空态**：`generate_status` 为 `'0'` / `'1'` → 「报告生成中，稍后回来看看」；`'3'` → 「报告生成失败，可以重新生成」+「手工填分」按钮
  - 雷达图挂在 `el-drawer` 的 `@opened` 上画（抽屉展开动画结束才量得到尺寸，否则 `echarts.init` 拿到 0×0 画布）
- **写入口只有一个**：`POST /interview/report/fill`（`api/interview/report.js` 的 `fillReport`）
  - 前端只传 `sessionId` + 五维分 + `summary` / `weakPoints` / `suggest`
  - `totalScore` 由后端按五维平均算（保留两位）；`reportNo` / `userId` / `generateStatus` / `generateTime` 也由后端写
  - 写入前校验：场次属于当前学生 **且** `status='2'`（没答完不给报告）；五维都非空且 0~100；`weakPoints` 必须能解析成 JSON 数组
- **建壳时机**：场次置「已完成」时（`InterviewSessionServiceImpl.refreshSessionProgress`）幂等建一条 `generate_status='0'` 的壳；
  指针写入收在 `ensureReportShell` 里（「报告诞生」的唯一入口，答完自动建壳 / 手工填分补建壳都会走到）
- **补建入口**：工具条「生成报告」按钮列出「已完成但还没报告」的场次（`listSession({status:'2'})` 减 `listReport()` 已有的 `sessionId`），
  选中后走同一个 `/fill` —— 后端会先补建壳。**后端零新增接口。**
  报告列表为空时 `el-table` 的空态会提示「还有 N 场已完成的面试没有复盘报告，点上方『生成报告』补上」

**✅ S5 已做**：`InterviewReport` 的 `@Excel` 清理（13 → 9 列）—— 摘掉 `id` / `sessionId` / `userId` / `status`；
`generateStatus` 补 `"0=待生成,1=生成中,2=生成成功,3=生成失败"`；`generateTime` 的 `dateFormat` 改为 `yyyy-MM-dd HH:mm:ss`。
`summary` / `weakPoints` / `suggest` / `radarData` / `pdfUrl` **有意不加 `@Excel`** —— `weakPoints` 是 JSON 数组，导出会是乱码；
其余属于报告正文，阶段一不通过导出暴露（详情抽屉里有）。
**`fillReport` 是演示用的临时入口** —— 阶段三接入 AI 评分后应删除，或至少把 `interview:report:edit` 从学生角色收回。

---

### 2.8 题库题目 `question_bank` —— 共享（**无 `user_id`**）　✅ **已完成 2026-09-22**

**决策 2 已定：学生端只读。** 题库是全库共享的，学生端**去掉新增 / 修改 / 删除按钮**，只保留列表 + 查询 + 详情。

> **落地结果**（两棵树同步）：
> - `RuoYi-Vue3/src/views/interview/bank/index.vue` → 只读浏览页（367 → 247 行）
>   - **去掉**：新增 / 修改 / 删除按钮、`type="selection"` 多选列、新增/修改弹窗及其全部表单逻辑（`handleAdd` / `handleUpdate` / `submitForm` / `handleDelete` / `handleSelectionChange` / `reset` / `cancel` / `form` / `rules`）
>   - **保留**：列表 + 分页 + 查询 + 详情抽屉 + 导出（导出按 PLAN.md §2.3 的全局决定保留）
>   - 查询区从 4 个条件换成 3 个字典下拉：**题型 + 行业 + 难度**（原「岗位名称」「标签」「来源」是文本框，「状态」是内部字段）；管理员额外多一个「状态」下拉
>   - 列表去掉：主键ID / 创建者 / 更新者 / 更新时间
>   - 列表列：题干 / 题型(dict-tag) / 行业(dict-tag) / 难度(dict-tag) / 企业类型(dict-tag) / 岗位名称 / 标签 / 来源(dict-tag) / 参考答案 / 关键要点 / 被使用次数 / **状态（仅管理员）** / 操作（查看）
>   - 长文本列（题干 / 岗位名称 / 标签 / 参考答案 / 关键要点）一律 `:show-overflow-tooltip="true"`，不撑破表格
>   - `key_points` 是 JSON 数组，列表里用 `formatKeyPoints()` 解析后拼成「、」分隔的纯文本；解析不了就原样兜底
>   - 操作列只留「查看」，`fixed="right"`
> - `RuoYi-Vue3/src/views/interview/bank/view.vue` → 抽屉**重写**（163 → 202 行）
>   - **补上了原来没有的「参考答案」「关键要点」**（生成器漏渲染，而这两项恰恰是题库最核心的内容）
>   - 关键要点解析成 `<ul>` 列表渲染；参考答案 `white-space: pre-wrap` 保留换行
>   - 去掉：主键ID / 创建者 / 更新者 / 更新时间；「创建时间」改叫「收录时间」放最末；**「状态」仅管理员可见**
>   - 枚举字段全部换成 `<dict-tag>`（原先是裸码，如 `questionType` 直接显示 `1`）
> - `QuestionBank.java` → `@Excel` 11 → 9：摘掉 `id` / `status`；`questionType` / `industry` / `difficulty` / `companyType` / `source` 补 `readConverterExp`；`tags` 列名去括号
> - `StudentDataScopeUtils.java` → 新增 `STATUS_NORMAL` 常量与 `canViewStatus()`（共享资源可见状态判断）
> - `QuestionBankController.java` → `list` / `export` / `getInfo` 三处应用 `status` 可见性过滤（见下方「已拍板」表）
> - `Service` / `Mapper` **未动**（过滤是在查询条件上加 `status`，复用已有的 `<if test="status != null">` 条件列）

> 🔒 **写操作接口为什么不用删**：`QuestionBankController` 的 `add` / `edit` / `remove` 三个接口都带
> `@PreAuthorize("@ss.hasPermi('interview:bank:add')")` 这类权限校验，而「学生」角色**没有**这三个权限。
> 所以学生端就算知道接口也调不通 —— 只读是**权限层面**保证的，不是靠「前端不渲染按钮」。
> 这也是决策 2 里说的「按钮保留在 `sys_menu` 里（后台端要用），学生端靠 `v-hasPermi` 自然隐藏」的落地方式。
> 同理，`status` 过滤也做在**后端**：前端过滤能被直接调接口绕过。

> ⚠️ **与清单的一处有意偏差**：`reference_answer` / `key_points` 清单写的是「列表显示」，已照做（带 tooltip）；
> 但纯 JSON 塞进表格列不可读，所以**关键要点在列表里是解析后的纯文本、在抽屉里才是完整列表**。

下表「表单」列标 `可编辑` 的字段，是**后台端**编辑时用的控件类型；学生端不渲染这些输入框。

| 字段 | 含义 | 列表 | 表单 | 控件 / 校验 |
| :--- | :--- | :--- | :--- | :--- |
| `question_content` | 题干 | 显示（tooltip） | 可编辑 | **必填**（表里是 `NOT NULL`） |
| `question_type` | 题型 | 显示 dict-tag | 可编辑 | 下拉字典 `interview_question_type` |
| `industry` | 行业 | 显示 dict-tag | 可编辑 | 下拉字典 `student_industry` |
| `job_name` | 岗位名称 | 显示（tooltip） | 可编辑 | 最长 100 |
| `difficulty` | 难度 | 显示 dict-tag | 可编辑 | 下拉字典 `student_difficulty` |
| `company_type` | 企业类型 | 显示 dict-tag | 可编辑 | 下拉字典 `student_company_type` |
| `reference_answer` | 参考答案 | 显示（tooltip） | 可编辑 | 多行文本，抽屉里 `pre-wrap` |
| `key_points` | 关键要点 | 显示（解析后文本） | 可编辑 | JSON 数组，抽屉里渲染成列表 |
| `tags` | 标签 | 显示（tooltip） | 可编辑 | 逗号分隔 |
| `source` | 来源 | 显示 dict-tag | 可编辑 | 下拉字典 `question_bank_source` |
| `use_count` | 被使用次数 | 显示 | 只读 | 系统累计 |
| `create_time` | 收录时间 | 不显示 | 不显示 | 只在抽屉末尾展示 |
| `status` | 状态 | **仅管理员可见** | 不显示 | 列表/抽屉/查询区都按 `interview:data:all` 门控；学生看不到停用题，也不需要看到状态 |
| 系统字段 | — | 不显示 | 不显示 | 见通用规则 |

**查询区**：题型 + 行业 + 难度（三个字典下拉）。

**✅ 两个待定项已拍板（2026-09-22）**

| # | 问题 | 结论 | 落地 |
| :- | :--- | :--- | :--- |
| 1 | 导出按钮留不留？ | **保留** | 与 PLAN.md §2.3「8 个模块统一保留导出」一致，不动 |
| 2 | `status` 要不要过滤？ | **要，对学生隐藏停用题目** | **后端权限驱动**，见下 |

**`status` 过滤的实现（后端，三处）** —— 不放在前端，因为前端过滤能被直接调接口绕过：

- `StudentDataScopeUtils` 新增：
  - 常量 `STATUS_NORMAL = "0"`
  - `canViewStatus(String status)` → `canViewAll() || STATUS_NORMAL.equals(status)`
- `QuestionBankController` 三处应用：
  - `list()` / `export()`：`scopeVisibleStatus(questionBank)` —— 无 `interview:data:all` 权限时强制 `status = '0'`
  - `getInfo()`：记录不存在**或**状态不可见 → 抛 `ServiceException("数据不存在或已删除")`，防止用猜 id 绕过列表过滤
- **导出也一并受限**，否则「导出」会成为绕过隐藏的后门
- 拥有 `interview:data:all` 的角色（后台端 / 超管）不受影响，仍能看到与操作停用题目

**配套的界面处理（2026-09-22 补）** —— 只过滤不显示会有个副作用：**管理员看到 26 条，却认不出哪 2 条是停用的**。所以「状态」信息按权限门控展示：

| 位置 | 学生（无 `interview:data:all`） | 管理员 / 超管 |
| :--- | :--- | :--- |
| 查询区「状态」下拉 | 不渲染 | 渲染（字典 `sys_normal_disable`） |
| 列表「状态」列 | 不渲染 | 渲染（`dict-tag`，正常=primary / 停用=danger） |
| 详情抽屉「状态」 | 不渲染 | 渲染 |

- 前端用 `checkPermi(['interview:data:all'])`（`@/utils/permission`）包成 `computed`，模板上用 `v-if="canViewAll"`
  - 用 `computed` 而不是常量：`permissions` 是 Pinia 状态，`GetInfo` 返回后会自动重算
  - 不用 `v-hasPermi` 指令：它靠移除 DOM 实现，用在 `el-table-column` 这类**配置型组件**上不可靠
- 门控判据与后端**同一个权限点**（`interview:data:all`），前后端不会出现「后端给看、前端不给看」的错位

> 💡 **为什么题库是唯一加 `status` 过滤的模块**：其余 7 张表都是**学生自己的数据**（`user_id` 隔离），行内的 `status` 是后台「停用账号 / 记录」的标记，学生看到自己的记录无所谓。
> 而 `question_bank` 是**共享内容**，`status` 的语义是「这道题还要不要给学生看」—— 所以必须过滤。

**🧪 本地测试数据**：`sql/student_init.sql` 第 5 节（可选执行，幂等）—— 26 道样例题，覆盖全部题型 / 行业 / 难度 / 企业类型 / 来源，其中 **2 道 `status = '1'`（停用）**专门用来验证上面的过滤。
预期：学生登录看到 **24** 道、导出 **24** 行；`admin` 登录看到 **26** 道。

---

## 三、业务决策（2026-09-22 已拍板）

### 决策 1：`interview_question` 的参考答案，作答前能不能看？

**结论：A —— 作答前隐藏，提交后可见。**

- 更接近真实面试场景，答案留给复盘阶段
- 落地方式：前端按「该题是否已有 `interview_qa` 记录」或 `session.status` 判断显隐
  - `session.status = 2`（已完成）或该题存在对应 `qa` 记录 → 显示 `reference_answer` / `key_points`
  - 否则 → 隐藏

### 决策 2：题库 `question_bank` 学生能不能新增 / 修改？

**结论：A —— 学生端只读。**

- 题库是共享资源，学生改了会影响所有人
- 落地方式：学生端**去掉新增 / 修改 / 删除按钮**，只保留列表 + 查询 + 查看详情
- 菜单层面：`interview:bank:add` / `:edit` / `:remove` 三个按钮**保留在 `sys_menu` 里**（后台端要用），只是学生端页面不渲染它们 —— 靠 `v-hasPermi` 自然隐藏，不需要改数据
- 后续（可选）：如果将来要让学生投稿题目，需要给 `question_bank` 加归属字段（现在只有 `create_by` 存用户名，不是 `user_id`），那属于表结构变更

### 决策 3：`interview_session` / `interview_question` / `interview_report` 要不要保留 CRUD 表单？

**结论：B —— 暂时保留。**

- 现阶段不动这三个模块的表单，先把其余 5 个模块的字段语义做扎实
- 等阶段二「前端页面改造」时再一并收敛成流程页（历史面试记录 / 按场次看题 / 复盘报告详情）
- 注意：这三个模块的**字段取舍仍然按第二节的清单执行**（内部字段不显示、系统字段只读），只是「新增 / 修改 / 删除」按钮暂不摘除

---

## 四、业务字典（2026-09-22 已建）

现在页面只用了 `sys_user_sex` 和 `sys_normal_disable`，所以很多字段被迫用文本框。字典已经建好了：

**`sql/student_init.sql` 第 4 节**（原 `sql/student_dict.sql`）—— 13 个类型 + 45 条数据，全部 `where not exists` 守卫、不写死 `dict_id` / `dict_code`，可重复执行（重建顺序第 3 步），末尾自带校验查询（预期 `13 / 45`）。

**`dict_value` 一律用码，不用中文原文** —— 业务表里存的就是 `dict_value`，所以**改文案只改 `dict_label`，业务数据零迁移**。

| 字典类型 | 值域（`dict_value` = `dict_label`） | 用在哪 |
| :--- | :--- | :--- |
| `student_education` | 1=专科 2=本科 3=硕士 4=博士 | 学生档案 · 学历 |
| `student_industry` | 1=技术 2=产品 3=运营 4=财务 5=教师 | 岗位画像 / 场次 / 题库 · 行业 |
| `student_difficulty` | 1=初级 2=中级 3=高级 | 岗位画像 / 场次 / 题库 · 难度 |
| `student_company_type` | 1=BAT 2=央企 3=外企 4=其他 | 岗位画像 / 题库 · 企业类型 |
| `interview_question_type` | 1=行为面 2=技术面 3=HR面 4=case面 | 场次 / 题目 / 题库 · 题型 |
| `interview_session_status` | 0=未开始 1=进行中 2=已完成 3=已中断 | 场次 · 状态 |
| `interview_answer_type` | 1=文字 2=语音 3=视频 | 问答 · 作答方式 |
| `student_resume_source` | 1=本地上传 2=拍照导入 | 简历 · 来源 |
| `student_parse_status` | 0=未解析 1=解析中 2=解析成功 3=解析失败 | 简历 · 解析状态 |
| `interview_question_source` | 1=AI生成 2=题库抽取 3=简历解析 | 题目 · 来源 |
| `question_bank_source` | 1=真题 2=模拟 3=AI生成 | 题库 · 来源 |
| `student_guide_status` | 0=未完成 1=已完成 | 档案 · 引导状态 |
| `interview_report_status` | 0=待生成 1=生成中 2=生成成功 3=生成失败 | 报告 · 生成状态 |

> ⚠️ `interview_question_source` 与 `question_bank_source` 的**值域不同** —— 同为「来源」，但 1 的含义分别是「AI生成」和「真题」，别混用。
>
> ⚠️ 字典属于**共享面**。完整值域表 + 变更记录见 `doc/学生端对外契约.md` **第四节**；三端合并时请复用同一套 `dict_type`，不要另建「名字一样、值不一样」的字典。
>
> 已建过表的库，跑一次 `sql/student_patch.sql` 第 1 节把列注释同步成「码=含义」（幂等，不必 DROP 重建）。

前端用法：

```js
const { student_education } = useDict('student_education')
```

下拉用 `<el-option :label="d.label" :value="d.value" />`，列表回显用 `<dict-tag :options="student_education" :value="row.education" />`。

### 4.1 改码的连带影响：还有一批「中文枚举」文案要清

`dict_value` 改成码之后，下面这些地方**还写着中文枚举**，会和实际数据对不上，改造时要一并处理：

| 位置 | 现状 | 怎么改 |
| :--- | :--- | :--- |
| **Domain 类的 `@Excel` 注解** | `@Excel(name = "学历(专科/本科/硕士/博士)")`，但数据是 `2` | ① 配 `@Excel(readConverterExp = "1=专科,2=本科,3=硕士,4=博士")`；**或 ② 学生端不开放导出**（阶段一学生本来也不需要导出） |
| **前端列头 / 标签** | `label="学历(专科/本科/硕士/博士)"`、`<label>学历(专科/本科/硕士/博士)：</label>` | 改成 `label="学历"`，值交给 `dict-tag` 渲染 |
| **表注释** | ✅ 已改完 | `sql/student_init.sql` 第 1 节已是「码=含义」 |

**当前进度（2026-09-22）**：

| 模块 | Domain `@Excel` | 前端文案 |
| :--- | :--- | :--- |
| `StudentProfile` 学生档案 | ✅ 已改完 —— 走的是**方案 ①**：`id`/`userId`/`guideStatus`/`status` 摘掉 `@Excel`；`gender` 配 `"0=男,1=女,2=未知"`、`education` 配 `"1=专科,2=本科,3=硕士,4=博士"`，同时列名去掉括号里的枚举 | ✅ 已改完 |
| `StudentJobProfile` 岗位画像 | ✅ 已改完 —— `id`/`userId`/`status` 摘掉 `@Excel`；`industry`/`difficulty`/`companyType`/`isDefault` 补 `readConverterExp`，`jobName` 列名去掉括号说明 | ✅ 已改完 |
| `StudentResume` 简历 | ✅ 已改完 —— `id`/`userId`/`parseStatus`/`parseTime`/`status` 摘掉 `@Excel`（9 → 4）；`sourceType`/`isDefault` 补 `readConverterExp`，`fileType` 列名去说明 | ✅ 已改完 |
| `InterviewSession` 场次 | ✅ 已改完（S1）—— `id`/`userId`/`jobProfileId`/`status`/`reportId` 摘掉 `@Excel`；`difficulty` 补 `"1=初级,2=中级,3=高级"`；时间列 `dateFormat` 统一 `yyyy-MM-dd HH:mm:ss`。`questionType` 是**逗号多值**（`1,2`），`readConverterExp` 翻译不了，故不配 | ✅ 已改完 |
| `InterviewQuestion` 题目 | ✅ 已改完（S5）—— `id`/`sessionId`/`userId`/`status` 摘掉 `@Excel`（9 → 5）；`questionType`/`source`/`isFollowUp` 补 `readConverterExp`，`questionNo` 列名去括号 | ✅ 已改完 |
| `InterviewQa` 问答 | ✅ 已改完（S5）—— `id`/`sessionId`/`questionId`/`userId`/`status` 摘掉 `@Excel`（12 → 7）；`answerType`/`isFollowUp` 补 `readConverterExp`；`answerTime` 改到秒 | ✅ 已改完（作答页，无列表） |
| `InterviewReport` 报告 | ✅ 已改完（S5）—— `id`/`sessionId`/`userId`/`status` 摘掉 `@Excel`（13 → 9）；`generateStatus` 补 `readConverterExp`；`generateTime` 改到秒 | ✅ 已改完 |
| `QuestionBank` 题库 | ✅ 已改完 —— `id`/`status` 摘掉 `@Excel`（11 → 9）；`questionType`/`industry`/`difficulty`/`companyType`/`source` 补 `readConverterExp`，`tags` 列名去括号 | ✅ 已改完（只读页） |

> 决策：**统一走方案 ①**（配 `readConverterExp`），不摘导出按钮。理由：8 个模块的菜单脚本里都已经生成了 `interview:xxx:export` 按钮，单独给某个模块摘掉导出会造成菜单树与页面不一致；而 `readConverterExp` 一次性把「导出中文、库里存码」这件事做对，改动量也只是一行注解。

> ⚠️ **`RuoYi-Vue/` 与 `ruoyi/` 两棵树都要改** —— `ruoyi/` 是生成器产出暂存区，两份必须同步。
>
> 排查命令：`git grep -n "专科/本科\|技术/产品\|BAT/央企\|行为面/技术面\|真题/模拟"`

---

## 五、实施顺序建议

1. ~~先定上面 3 个决策~~ → **已完成**（2026-09-22，见第三节）
2. ~~建字典~~ → **已完成**：`sql/student_init.sql` 第 4 节（13 个类型 + 45 条数据）
3. **按模块改**，建议顺序：~~`学生档案`~~（✅ 2026-09-22）→ ~~`岗位画像`~~（✅ 2026-09-22）→ ~~`简历`~~（✅ 2026-09-22）→ ~~`题库`~~（✅ 2026-09-22）→ ~~三个流程模块~~（✅ 2026-09-22，S1 + S5）—— **8 个模块全部改完**
4. 每个模块改完都要过一遍：
   - 后端：`update` 语句里**没有** `user_id`；系统字段不允许被前端覆盖
   - 后端：`@Excel` 注解（见 4.1）+ 枚举字段的 `readConverterExp`
   - 前端：列表列 / 查询区 / 表单控件类型 / 校验规则
   - 前端：中文枚举文案清干净
   - 收尾：两棵树 `diff -rq` 无差异；文件保持 CRLF
5. **顺带排查**：`is_default` 这类布尔列是否被错接了 `sys_yes_no`（`Y`/`N`）字典 —— 岗位画像 ✅、简历 ✅ 均已修（改为 `el-switch` + `readConverterExp`，不接字典）；后续模块新建 `CHAR(1)` 存 `0/1` 的列时同样注意
