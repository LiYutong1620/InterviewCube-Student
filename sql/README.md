# sql/ 与 ruoyi/ 下的 SQL 使用说明

> 本仓库的 SQL 分**可执行脚本**与**设计资料**两类。前者有严格执行顺序，后者仅供查阅。
> 维护人：tong　最后更新：2026-09-22（含个人中心菜单与协议参数）

---

## 一、两类文件，先分清

| 类型 | 文件 | 能否执行 | 说明 |
| :--- | :--- | :--- | :--- |
| **① 可执行脚本**（权威） | `RuoYi-Vue/sql/ry_20260417.sql`、`RuoYi-Vue/sql/quartz.sql` | ✅ | 若依官方基础库，建 `sys_*` / `gen_*` / `qrtz_*`。**别改**，但要**先跑**（前置） |
| | **`sql/student_init.sql`** | ✅ **一键重建** | **学生端全部内容**：8 张业务表 + 菜单（含个人中心）+ 角色与账号 + 13 个字典 + 协议参数 + 26 道演示题。**跑完这一个文件，库就完整可用。** ⚠️ 第 1 节含 `DROP TABLE`，会清空这 8 张表 |
| | `sql/student_patch_mine.sql` | ⚠️ **旧库增量** | **已有库、不想重建时必跑**：个人中心菜单 + 角色绑定 + `student.agreement.*` 协议参数 |
| | `sql/student_patch.sql` | ⚠️ 旧库补丁 | 第 1 节改列注释、第 2 节角色去重。一般不需要 |
| **② 已被吸收的源文件**（留档，不要单独跑） | `sql/student.sql`、`student_menu.sql`、`student_role_user.sql`、`student_dict.sql`、`student_question_bank_seed.sql` | — | 已被 `sql/student_init.sql` 吸收，各自头部有 banner 指向对应节 |
| | `sql/alter_column_comment_to_code.sql`、`sql/cleanup_student_role_dup.sql` | — | 已被 `sql/student_patch.sql` 吸收 |
| | `ruoyi/*Menu.sql`（8 个）、`ruoyi/dataScopePermiMenu.sql` | — | 生成器产出留档，已被并入 `student_init.sql` 第 2 节 |
| **③ 设计资料** | `sql/实体与表.xlsx`、`sql/代码生成器配置表.xlsx` | — | 不是 SQL，仅供查阅 |

一句话记法：

- **`sql/student_init.sql`** = **从零重建跑这一个就够了**
- **`sql/student_patch_mine.sql`** = **旧库补个人中心 / 协议**（增量）
- `sql/student_patch.sql` = 列注释 / 角色去重补丁
- `RuoYi-Vue/sql/*.sql` = 若依官方基础库，必须先跑

---

## 二、从零重建一个可用的库（照这个顺序跑）

> 目标：跑完之后 `admin` / `student01` / `student02` 都能登录，学生端菜单（含个人中心）正常显示，数据隔离生效。

| 序 | 文件 | 作用 |
| :-- | :--- | :--- |
| 1 | `RuoYi-Vue/sql/ry_20260417.sql` | 建若依基础库（`sys_*`、`gen_*`），内置 `admin`、`ry` 两个账号 |
| 2 | `RuoYi-Vue/sql/quartz.sql` | 建定时任务表 `qrtz_*` |
| 3 | **`sql/student_init.sql`** | **学生端全部内容** —— 建表 → 菜单 → 角色账号 → 字典 → 协议参数 → 演示数据 |

就这三步。第 3 步内部节次：

| 节 | 内容 | 幂等 | 依赖 |
| :-- | :--- | :--- | :--- |
| 第 1 节 | 8 张业务表（`DROP + CREATE`） | ❌ **会清空这 8 张表** | 第 1 步基础库 |
| 第 2 节 | 学生端菜单（含个人中心）+ `interview:data:all` | ✅ | 基础库的 `sys_menu` |
| 第 3 节 | 「学生」角色 + `student01` / `student02` + 菜单绑定 | ✅ | **必须在第 2 节之后** |
| 第 4 节 | 13 个业务字典类型 + 45 条数据 | ✅ | 基础库的 `sys_dict_type` |
| 第 4.5 节 | 用户协议 / 隐私政策（`sys_config`） | ✅ | 基础库的 `sys_config` |
| 第 5 节 | 26 道题库演示题（可选） | ✅ | 第 1 节的 `question_bank` 表 |

> **已有库只想补个人中心**：不要重跑 `student_init.sql` 第 1 节，改跑 **`sql/student_patch_mine.sql`**，然后重新登录。

跑完后「总校验」预期：

| 指标 | 预期值 | 含义 |
| :--- | :--- | :--- |
| `table_cnt` | **8** | 8 张业务表都在 |
| `menu_cnt` | **52** | 1 个目录 + 9 个模块菜单 + 42 个按钮（不含 `data:all`） |
| `user_cnt` | **2** | student01、student02 |
| `role_menu_cnt` | **52** | 「学生」角色的菜单绑定数 |
| `data_all_bound` | **0** | `interview:data:all` 没有被误绑给「学生」角色 |
| `dict_type_cnt` / `dict_data_cnt` | **13 / 45** | 业务字典 |
| `bank_cnt` | **26** | 题库演示题（第 5 节没跑就是 0，不影响功能） |

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
   - `sys_menu` / `sys_role_menu` 的差集正是学生端菜单树（基础库原生菜单 + 学生端约 52 条，不含 `data:all`）；
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

五块齐了之后，「干净库 → 能登录 → 菜单可见 → 数据隔离生效 → 下拉字典可用」这条链路就是**纯脚本、可重放**的，阶段③的合并演练可以直接用。

`sql/student_init.sql` 第 3 节（原 `sql/student_role_user.sql`）的两个设计要点：

- **不写死 `menu_id`**：绑定关系按「学生端目录 → 其下全部菜单」动态 `INSERT ... SELECT` 算出来。三端合并后菜单 id 会整体重排，写死就废了。
- **不写死 `role_id` / `user_id`**：若依的 `sys_role`、`sys_user` 自增都从 100 起，写死会和别人撞车。脚本按 `role_key = 'student'`、`user_name = 'student01'` 查。

---

## 六、三端合并时的注意

1. **不要合并各自的整库 dump。** 需要备份就现场导出到本地，不要提交进仓库 —— 理由见第四节。
2. **学生端只需收集一个文件：`sql/student_init.sql`** —— 建表 + 菜单 + 角色账号 + 字典 + 演示数据都在里面，顺序也排好了。
   已在临时库实测过完整重建（8 项校验全部符合预期）与二次执行幂等。
   > 只想要「菜单」这一块的话，它在第 2 节，可以单独抠出来。
3. 收集三端全部脚本（学生端**只有一个**），在**干净库上按顺序重跑一遍**，而不是靠「约定号段」防冲突。
4. **账号命名空间**：学生端只用 `student01` / `student02`；后台端、企业端请用各自前缀，避免 `user_name` 撞车。
5. **角色 key 命名空间**：学生端只用 `student`；其他端不要复用这个 `role_key`。
6. 其余细节见 `doc/学生端对外契约.md`。
