# 学生端 · 8 个模块字段清单（CRUD 语义收紧）

> 目的：把若依代码生成器产出的「后台管理式」CRUD，收紧成「学生端」该有的样子。
> 维护人：tong　最后更新：2026-09-22
> 配套：`sql/student.sql`（表结构）、`PLAN.md`「阶段二」

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
| `remark` | 不显示 | 不显示 | 内部备注，学生端不需要 |

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

### 2.2 学生简历 `student_resume` —— 1:N（可多份）

| 字段 | 含义 | 列表 | 表单 | 控件 / 校验 |
| :--- | :--- | :--- | :--- | :--- |
| `id` / `user_id` | — | 不显示 | 隐藏提交 / 后端写入 | — |
| `resume_name` | 简历名称 | 显示 | 可编辑 | **必填**，最长 100 |
| `file_url` | 文件地址 | 显示（下载 / 预览入口） | 可编辑 | **必填**；`file-upload`，限制 pdf / doc / docx |
| `file_type` | 文件类型 | 不显示 | 不显示 | 后端从上传结果取 |
| `file_size` | 文件大小 | 显示（格式化为 KB/MB） | 不显示 | 后端从上传结果取 |
| `source_type` | 来源 | 显示（dict-tag） | 可编辑 | 下拉：本地上传 / 拍照导入（需新建字典） |
| `is_default` | 是否默认 | 显示（tag） | 可编辑 | **补校验**：设为默认时，把该用户其他份取消默认 |
| `parse_status` | 解析状态 | 不显示（阶段一） | 不显示 | AI 解析阶段一不做，恒为「未解析」，先不显示 |
| `parse_result` | 解析结果 | 不显示 | 不显示 | JSON，阶段一不启用 |
| `parse_time` | 解析时间 | 不显示 | 不显示 | — |
| `status` 及系统字段 | — | 不显示 | 不显示 | 见通用规则 |

**查询区**：只留「简历名称」（模糊匹配）。

---

### 2.3 学生岗位画像 `student_job_profile` —— 1:N（可多个目标岗位）

| 字段 | 含义 | 列表 | 表单 | 控件 / 校验 |
| :--- | :--- | :--- | :--- | :--- |
| `industry` | 行业 | 显示 | 可编辑 | **控件改下拉**：技术 / 产品 / 运营 / 财务 / 教师（需新建字典）；**必填** |
| `job_name` | 岗位名称 | 显示 | 可编辑 | **必填**，最长 100 |
| `difficulty` | 难度 | 显示（tag） | 可编辑 | 下拉：初级 / 中级 / 高级（需新建字典） |
| `company_type` | 目标企业类型 | 显示 | 可编辑 | 下拉：BAT / 央企 / 外企 / 其他（需新建字典） |
| `is_default` | 是否默认 | 显示（tag） | 可编辑 | **补校验**：唯一默认 |
| 系统字段 | — | 不显示 | 不显示 | 见通用规则 |

**查询区**：行业 + 难度。

---

### 2.4 模拟面试场次 `interview_session` —— 1:N

⚠️ **这个模块基本不该有「新增 / 修改」表单** —— 它是面试流程的产物，不是学生手填的东西。

| 字段 | 含义 | 列表 | 表单 | 说明 |
| :--- | :--- | :--- | :--- | :--- |
| `session_no` | 场次编号 | 显示 | 不显示 | 后端生成 |
| `job_profile_id` | 关联岗位画像 | 显示（展示岗位名） | 不手填 | 从岗位画像选择带入 |
| `industry` / `job_name` / `difficulty` / `question_type` | 面试参数 | 显示 | 只读 | 由所选岗位画像带入 |
| `total_count` / `answered_count` | 题数进度 | 显示 | 不显示 | 系统维护 |
| `status` | 场次状态 | 显示（tag） | 不显示 | 未开始 / 进行中 / 已完成 / 已中断 |
| `score` | 本场总分 | 显示 | 不显示 | 评估后写入 |
| `start_time` / `end_time` / `duration` | 时间 | 显示 | 不显示 | 系统维护 |
| `report_id` | 关联报告 | 显示（「查看报告」入口） | 不显示 | — |
| 系统字段 | — | 不显示 | 不显示 | 见通用规则 |

**建议**：前端改造时做成「历史面试记录」列表页（只读 + 一个「继续作答」按钮），**去掉新增 / 修改 / 删除**。

---

### 2.5 面试题目 `interview_question` —— 1:N（属于某场次）

| 字段 | 含义 | 列表 | 表单 | 说明 |
| :--- | :--- | :--- | :--- | :--- |
| `session_id` | 所属场次 | 不显示 | 不手填 | ← **4 个外键列之一**，必须由后端带入 |
| `bank_question_id` | 关联题库 | 不显示 | 不手填 | — |
| `question_no` | 题号 | 显示 | 不显示 | — |
| `question_type` | 题型 | 显示 | 不显示 | — |
| `question_content` | 题干 | 显示 | 不显示 | 生成后不改 |
| `reference_answer` | 参考答案 | 只读（**提交后可见**） | 不显示 | 见决策 1 |
| `key_points` | 关键要点 | 只读（**提交后可见**） | 不显示 | 见决策 1 |
| `is_follow_up` / `parent_question_id` | 追问关系 | 不显示 | 不显示 | — |
| `source` | 来源 | 显示（tag） | 不显示 | AI 生成 / 题库抽取 / 简历解析 |
| 系统字段 | — | 不显示 | 不显示 | 见通用规则 |

**建议**：同样去掉新增 / 修改 / 删除，改为「按场次查看题目」。

---

### 2.6 面试问答 `interview_qa` —— 1:N（属于某场次）

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

---

### 2.7 面试复盘报告 `interview_report` —— 1:1（对场次）

⚠️ 同样是**流程产物**，不该有 CRUD 表单。

| 字段 | 含义 | 列表 | 表单 | 说明 |
| :--- | :--- | :--- | :--- | :--- |
| `report_no` | 报告编号 | 显示 | 不显示 | 后端生成 |
| `session_id` | 关联场次 | 显示 | 不手填 | — |
| `total_score` | 总分 | 显示 | 不显示 | 评估后写入 |
| `score_completeness` / `_logic` / `_fluency` / `_depth` / `_confidence` | 五维得分 | 显示 | 不显示 | 雷达图五轴 |
| `radar_data` | 雷达图数据 | 显示（渲染图） | 不显示 | JSON |
| `summary` / `weak_points` / `suggest` | 总结 / 薄弱点 / 建议 | 显示 | 不显示 | — |
| `pdf_url` | PDF 地址 | 显示（下载入口） | 不显示 | 阶段一不生成 |
| `generate_status` / `generate_time` | 生成状态 | 显示 | 不显示 | — |
| 系统字段 | — | 不显示 | 不显示 | 见通用规则 |

**建议**：做成「复盘报告」详情页，去掉 CRUD 按钮。

---

### 2.8 题库题目 `question_bank` —— 共享（**无 `user_id`**）

**决策 2 已定：学生端只读。** 题库是全库共享的，学生端**去掉新增 / 修改 / 删除按钮**，只保留列表 + 查询 + 详情。

下表「表单」列标 `可编辑` 的字段，是**后台端**编辑时用的控件类型；学生端不渲染这些输入框。

| 字段 | 含义 | 列表 | 表单 | 控件 / 校验 |
| :--- | :--- | :--- | :--- | :--- |
| `question_content` | 题干 | 显示 | 可编辑 | **必填**（表里是 `NOT NULL`） |
| `question_type` | 题型 | 显示 | 可编辑 | 下拉：行为面 / 技术面 / HR面 / case面（需新建字典） |
| `industry` | 行业 | 显示 | 可编辑 | 下拉，同「行业」字典 |
| `job_name` | 岗位名称 | 显示 | 可编辑 | 最长 100 |
| `difficulty` | 难度 | 显示 | 可编辑 | 下拉，同「难度」字典 |
| `company_type` | 企业类型 | 显示 | 可编辑 | 下拉，同「企业类型」字典 |
| `reference_answer` | 参考答案 | 显示 | 可编辑 | 多行文本 |
| `key_points` | 关键要点 | 显示 | 可编辑 | JSON 数组，建议多行文本 |
| `tags` | 标签 | 显示 | 可编辑 | 逗号分隔 |
| `source` | 来源 | 显示 | 可编辑 | 下拉：真题 / 模拟 / AI生成 |
| `use_count` | 被使用次数 | 显示 | 只读 | 系统累计 |
| 系统字段 | — | 不显示 | 不显示 | 见通用规则 |

**查询区**：题型 + 行业 + 难度（这三个才是学生真正想筛的）。

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

**`sql/student_dict.sql`** —— 13 个类型 + 45 条数据，全部 `where not exists` 守卫、不写死 `dict_id` / `dict_code`，可重复执行。已并入 `sql/README.md` 重建顺序的**第 14 步**，末尾自带校验查询（预期 `13 / 45`）。

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
> 已建过表的库，跑一次 `sql/alter_column_comment_to_code.sql` 把列注释同步成「码=含义」（幂等，不必 DROP 重建）。

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
| **表注释** | ✅ 已改完 | `sql/student.sql` 已是「码=含义」 |

**当前进度（2026-09-22）**：

| 模块 | Domain `@Excel` | 前端文案 |
| :--- | :--- | :--- |
| `StudentProfile` 学生档案 | ✅ 已改完 —— 走的是**方案 ①**：`id`/`userId`/`guideStatus`/`status` 摘掉 `@Excel`；`gender` 配 `"0=男,1=女,2=未知"`、`education` 配 `"1=专科,2=本科,3=硕士,4=博士"`，同时列名去掉括号里的枚举 | ✅ 已改完 |
| `StudentResume` 简历 | ⬜ 待办 | ⬜ 待办 |
| `StudentJobProfile` 岗位画像 | ⬜ 待办 | ⬜ 待办 |
| `InterviewSession` 场次 | ⬜ 待办 | ⬜ 待办 |
| `InterviewQuestion` 题目 | ⬜ 待办 | ⬜ 待办 |
| `InterviewQa` 问答 | ⬜ 待办 | ⬜ 待办 |
| `InterviewReport` 报告 | ⬜ 待办 | ⬜ 待办 |
| `QuestionBank` 题库 | ⬜ 待办 | ⬜ 待办 |

> 决策：**统一走方案 ①**（配 `readConverterExp`），不摘导出按钮。理由：8 个模块的菜单脚本里都已经生成了 `interview:xxx:export` 按钮，单独给某个模块摘掉导出会造成菜单树与页面不一致；而 `readConverterExp` 一次性把「导出中文、库里存码」这件事做对，改动量也只是一行注解。

> ⚠️ **`RuoYi-Vue/` 与 `ruoyi/` 两棵树都要改** —— `ruoyi/` 是生成器产出暂存区，两份必须同步。
>
> 排查命令：`git grep -n "专科/本科\|技术/产品\|BAT/央企\|行为面/技术面\|真题/模拟"`

---

## 五、实施顺序建议

1. ~~先定上面 3 个决策~~ → **已完成**（2026-09-22，见第三节）
2. ~~建字典~~ → **已完成**：`sql/student_dict.sql`（13 个类型 + 45 条数据）
3. **按模块改**，建议顺序：~~`学生档案`~~（✅ 2026-09-22 完成，样板已落地）→ `岗位画像` → `简历` → `题库` → 三个流程模块
4. 每个模块改完都要过一遍：
   - 后端：`update` 语句里**没有** `user_id`；系统字段不允许被前端覆盖
   - 前端：列表列 / 查询区 / 表单控件类型 / 校验规则
   - 收尾：`@Excel` 注解（见 4.1）+ 中文枚举文案 + 两棵树同步
