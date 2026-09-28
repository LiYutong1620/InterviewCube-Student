# sql/ 与 ruoyi/ 下的 SQL 使用说明

> 本仓库的 SQL 分**可执行脚本**与**设计资料**两类。前者有严格执行顺序，后者仅供查阅。
> 维护人：tong　最后更新：2026-09-28

---

## 一、两类文件，先分清

| 类型 | 文件 | 能否执行 | 说明 |
| :--- | :--- | :--- | :--- |
| **① 可执行脚本**（权威） | `RuoYi-Vue/sql/ry_20260417.sql`、`RuoYi-Vue/sql/quartz.sql` | ✅ | 若依官方基础库，建 `sys_*` / `gen_*` / `qrtz_*`。**别改**，但要**先跑**（前置） |
| | **`sql/student_init.sql`** | ✅ **一键重建** | **学生端全部内容**：8 张业务表 + 50 条菜单 + 角色与账号 + 13 个字典类型 + 26 道演示题 + 运行时配置。**跑完这一个文件，库就完整可用。** ⚠️ 第 1 节含 `DROP TABLE`，会清空这 8 张表 |
| | `sql/student_patch.sql` | ⚠️ 旧库补丁 | **只在已建过库、不想重建时用**（**5 节**）：第 1 节改列注释、第 2 节角色去重、第 3 节修「学生档案」菜单的 `route_name`（不修会导致点右上角头像「个人中心」404）、第 4 节打开注册开关、第 5 节把「面试问答」菜单并入「面试环节」（含把 `interview:qa:list` 降级成 F 型按钮补回来）。一般不需要 |
| **② 已被吸收的源文件**（留档，不要单独跑） | `sql/student.sql`、`student_menu.sql`、`student_role_user.sql`、`student_dict.sql`、`student_question_bank_seed.sql` | — | 已被 `sql/student_init.sql` 的第 1~5 节吸收，各自头部有 banner 指向对应节 |
| | `sql/alter_column_comment_to_code.sql`、`sql/cleanup_student_role_dup.sql`、`sql/student_route_name_fix.sql`、`sql/student_qa_merge_menu.sql` | — | 已被 `sql/student_patch.sql` 的第 1~3、5 节吸收（`student_qa_merge_menu.sql` 同时是 `student_init.sql` 第 2 节末尾的「迁移」段） |
| | `sql/student_auth_config.sql` | — | 同一个文件同时是 `sql/student_init.sql` 第 6 节与 `sql/student_patch.sql` 第 4 节（两个产物都要用到它） |
| | `ruoyi/*Menu.sql`（8 个）、`ruoyi/dataScopePermiMenu.sql` | — | 生成器产出留档，已被 `student_menu.sql` → `student_init.sql` 第 2 节吸收 |
| **③ 设计资料** | `sql/实体与表.xlsx`、`sql/代码生成器配置表.xlsx` | — | 不是 SQL，仅供查阅 |

一句话记法：

- **`sql/student_init.sql`** = **跑这一个就够了**（从零重建学生端全部内容，文件内已排好 6 节顺序）
- `sql/student_patch.sql` = **旧库补丁**（已建过库、不想重建时才用）
- `RuoYi-Vue/sql/*.sql` = **若依官方的**，别改，但必须先跑（前置）
- `sql/` 下其余 10 个 + `ruoyi/` 下 9 个 = **已被上面两个吸收的源文件**，保留留档，**不要单独跑**

---

## 二、从零重建一个可用的库（照这个顺序跑）

> 目标：跑完之后 `admin` / `student01` / `student02` 都能登录，学生端 8 个菜单正常显示，数据隔离生效。

| 序 | 文件 | 作用 |
| :-- | :--- | :--- |
| 1 | `RuoYi-Vue/sql/ry_20260417.sql` | 建若依基础库（`sys_*`、`gen_*`），内置 `admin`、`ry` 两个账号 |
| 2 | `RuoYi-Vue/sql/quartz.sql` | 建定时任务表 `qrtz_*` |
| 3 | **`sql/student_init.sql`** | **学生端全部内容** —— 建表 → 菜单 → 角色账号 → 字典 → 演示数据，文件内已排好顺序 |

就这三步。第 3 步虽然是一个文件，但内部是 **6 节**，顺序已经排好：

| 节 | 内容 | 幂等 | 依赖 |
| :-- | :--- | :--- | :--- |
| 第 1 节 | 8 张业务表（`DROP + CREATE`） | ❌ **会清空这 8 张表** | 第 1 步基础库 |
| 第 2 节 | 学生端 50 条菜单（1 目录 + 7 模块菜单 + 41 按钮）+ `interview:data:all` 权限点 | ✅ | 基础库的 `sys_menu` |
| 第 3 节 | 「学生」角色 + `student01` / `student02` + 菜单绑定 | ✅ | **必须在第 2 节之后** |
| 第 4 节 | 13 个业务字典类型 + 45 条数据 | ✅ | 基础库的 `sys_dict_type` |
| 第 5 节 | 26 道题库演示题（可选） | ✅ | 第 1 节的 `question_bank` 表 |
| 第 6 节 | 运行时配置：打开 `sys.account.registerUser`（手机号验证码注册要用） | ✅ | 基础库的 `sys_config` |

> **不需要演示数据**？把第 5 节整段注释掉即可 —— 它只影响本地能不能看到题库列表内容，不影响其他功能。

**为什么合并**（2026-09-22）：

学生端原先有 9 个脚本要按序跑，现在只剩 1 个（`student_init.sql`）。合并是**逐节提取**做的，不是重打：
`student_init.sql` 的 6 节内容与 6 个源文件**逐字一致**（生成器 `.workbuddy-ai/tmp/merge_sql_further.py` 会按节比对），源文件保留未删（各自头部有 banner 指向对应节）。

> ⚠️ **产物是生成物，不要直接手改。**
> 2026-09-28 发现一次事故隐患：「路由名修正」那一节当初是**直接手改进产物**的，源文件不存在 —— 生成器与产物已经不同步，重跑生成器会把那一节弄丢。本次已把它抽回 `sql/student_route_name_fix.sql`，并新增 `sql/student_auth_config.sql`，**生成器重新成为唯一权威**。要改内容请改源文件再重跑生成器。

> **实测记录**：在临时库上跑「基础库 + `student_init.sql`」，退出码 0、零报错；
> 再跑第二遍验证幂等 —— `sys_menu` / `sys_dict_type` / `question_bank` / `sys_role_menu` 行数**零变化**。

跑完第 3 步，文件末尾的「总校验」会输出这些数字，预期：

| 指标 | 预期值 | 含义 |
| :--- | :--- | :--- |
| `table_cnt` | **8** | 8 张业务表都在 |
| `menu_cnt` | **49** | 1 个目录 + 7 个模块菜单 + 41 个按钮（不含 `data:all`）。**2026-09-28「面试问答」不再有独立模块菜单，但模块菜单 8 → 7、按钮 40 → 41（`:list` 降级成按钮），总数守恒仍是 49** |
| `user_cnt` | **2** | student01、student02 |
| `role_menu_cnt` | **49** | 「学生」角色的菜单绑定数（跟随菜单树，保持 49） |
| `data_all_bound` | **0** | `interview:data:all` 没有被误绑给「学生」角色 |
| `legacy_qa_menu_cnt` | **0** | 已无 **C 型**「面试问答」模块菜单（查询必须带 `menu_type = 'C'` —— 修复后 `:list` 本身是一条 F 型按钮，不带限定会数成 1） |
| `qa_permi_cnt` | **6** | `interview:qa:*` 权限点一个不少（全部 F 型，挂在「面试环节」下，**含 `:list`**） |
| `dict_type_cnt` / `dict_data_cnt` | **13 / 45** | 业务字典 |
| `bank_cnt` | **26** | 题库演示题（第 5 节没跑就是 0，不影响功能） |
| `register_enabled_cnt` | **1** | 注册开关已打开（第 6 节；手机号验证码注册要用） |

> 唯一不覆盖的情形：如果某个菜单**已存在但 `parent_id` 挂错了**，脚本会跳过它、不会自动纠正。干净库重建不会出现这种情况；真遇到了手工改一行即可。

### 字典值域：`dict_value` 一律用码

`sql/student_init.sql` 第 4 节（原 `sql/student_dict.sql`）里 **`dict_value` 用数字码，不用中文原文**（如 `education` 存 `'2'` 代表本科）。

- 原因：业务表里存的**就是** `dict_value`。用码之后，**改文案只改 `dict_label`，业务数据零迁移**；用中文则每改一次文案就要 `UPDATE` 所有历史行，且容易留下新旧值并存。
- 值域速查：见 `sql/student_init.sql` 第 4 节头部，或 `doc/学生端对外契约.md` 第四节（含变更记录）。
- 列注释已同步成「码=含义」写法（如 `学历(1专科 2本科 3硕士 4博士)`）。**已经建过表的库**跑一次 `sql/student_patch.sql` 的第 1 节即可同步，不必 DROP 重建。

---

## 三、内置账号

| 账号 | 初始密码 | 角色 | 用途 |
| :--- | :--- | :--- | :--- |
| `admin` | `admin123` | 超级管理员 | 后台管理，**能看到全部学生数据**（不做隔离） |
| `ry` | `admin123` | 普通角色 | 若依自带测试账号 |
| `student01` | `admin123` | 学生 | 学生端主测试账号 |
| `student02` | `admin123` | 学生 | 数据隔离验证用（与 student01 互相看不到对方数据） |

关于密码：

- `admin` / `ry` 的密码来自若依基础库脚本自带的种子密文，明文就是 `admin123`。
- `student01` / `student02` 复用**同一个种子密文**，所以初始密码也是 `admin123` —— 这样别人拿到仓库不用先重置密码就能登录。
- ⚠️ **BCrypt 每次加密结果都不同**，密文不能手写、也不能复制粘贴来「改密码」。改密码一律走后台「重置密码」。
- ⚠️ 以上密码**仅供开发与演示**，上线前必须全部改掉。

---

## 四、仓库里为什么没有整库 dump

> 2026-09-22：原本的 `sql/ry-vue.sql`（Navicat 整库快照）已从仓库移除。

移除的原因，也是**以后不要再往仓库里放整库 dump** 的理由：

1. **dump 不是脚本。** 它包含 `sys_oper_log`、`sys_logininfor` 等运行时日志（各上百条），每次导出都不同，diff 全是噪音。
2. **它带 `DROP TABLE` + 全量 `INSERT`**，谁不小心执行一次就会**覆盖整个库**，包括别的端的数据。
3. **它必然过期。** 那份快照停在 2026-09-21 16:32，早于角色去重，也早于 `interview:data:all` 的创建；照它恢复会把已清理的脏数据带回来。
4. **三端各有一份 dump，合并时同 id 记录会互相覆盖。** 这是三端合并最典型的踩坑方式，见 `doc/学生端对外契约.md` 第八节。
5. **它的内容已被脚本完全覆盖。** 移除前逐表核对过：
   - 8 张业务表结构与 `sql/student.sql` **逐列一致**；
   - `sys_dict_type` / `sys_dict_data` / `sys_config` / `sys_dept` / `sys_post` / `sys_job` / `sys_notice` / `sys_role_dept` / `sys_user_post` 与若依基础库脚本**完全一致**；
   - `sys_menu` / `sys_role_menu` 的差集正是学生端的 49 条（基础库 85 + 学生端 49 = 134），原生菜单无缺失；
   - `sys_role` / `sys_user` / `sys_user_role` 的差集是 role 100 / 101 / 102 + student01 + 绑定，已由 `sql/student_role_user.sql` 覆盖（100 / 101 本就是被清理的脏数据）；
   - 唯一独有内容只剩运行时日志和 student01 的旧密码密文。

**需要「某个时间点的真实库长什么样」时，正确做法是现场用客户端导出到本地，不要提交进仓库。**

---

## 五、五块拼图（已补齐）

| 块 | 内容 | 文件 | 状态 |
| :-- | :--- | :--- | :--- |
| ① | 若依基础库 | `RuoYi-Vue/sql/ry_20260417.sql`、`RuoYi-Vue/sql/quartz.sql` | ✅ |
| ②~⑤ | 学生端 8 张业务表 / 菜单+权限点 / 角色账号绑定 / 业务字典 | **`sql/student_init.sql` 的第 1~4 节**（合并成一个文件） | ✅ |
| （附） | 题库演示数据（可选） | `sql/student_init.sql` 第 5 节 | ✅ |
| （附） | 运行时配置（打开注册开关 `sys.account.registerUser`） | `sql/student_init.sql` 第 6 节 | ✅ |

五块齐了之后，「干净库 → 能登录 → 菜单可见 → 数据隔离生效 → 下拉字典可用」这条链路就是**纯脚本、可重放**的，阶段③的合并演练可以直接用。

`sql/student_init.sql` 第 3 节（原 `sql/student_role_user.sql`）的两个设计要点：

- **不写死 `menu_id`**：绑定关系按「学生端目录 → 其下全部菜单」动态 `INSERT ... SELECT` 算出来。三端合并后菜单 id 会整体重排，写死就废了。
- **不写死 `role_id` / `user_id`**：若依的 `sys_role`、`sys_user` 自增都从 100 起，写死会和别人撞车。脚本按 `role_key = 'student'`、`user_name = 'student01'` 查。

---

## 六、三端合并时的注意

1. **不要合并各自的整库 dump。** 需要备份就现场导出到本地，不要提交进仓库 —— 理由见第四节。
2. **学生端只需收集一个文件：`sql/student_init.sql`** —— 建表 + 菜单 + 角色账号 + 字典 + 演示数据 + 运行时配置都在里面，顺序也排好了。
   已在临时库实测过完整重建（8 项校验全部符合预期）与二次执行幂等。
   > 只想要「菜单」这一块的话，它在第 2 节，可以单独抠出来。
3. 收集三端全部脚本（学生端**只有一个**），在**干净库上按顺序重跑一遍**，而不是靠「约定号段」防冲突。
4. **账号命名空间**：学生端只用 `student01` / `student02`；后台端、企业端请用各自前缀，避免 `user_name` 撞车。
5. **角色 key 命名空间**：学生端只用 `student`；其他端不要复用这个 `role_key`。
6. 其余细节见 `doc/学生端对外契约.md`。
