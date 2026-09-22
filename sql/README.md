# sql/ 与 ruoyi/ 下的 SQL 使用说明

> 本仓库的 SQL 分**可执行脚本**与**设计资料**两类。前者有严格执行顺序，后者仅供查阅。
> 维护人：tong　最后更新：2026-09-22

---

## 一、两类文件，先分清

| 类型 | 文件 | 能否执行 | 说明 |
| :--- | :--- | :--- | :--- |
| **① 可执行脚本**（权威） | `RuoYi-Vue/sql/ry_20260417.sql`、`RuoYi-Vue/sql/quartz.sql` | ✅ | 若依官方基础库，建 `sys_*` / `gen_*` / `qrtz_*` |
| | `sql/student.sql` | ✅ | 学生端 8 张业务表的 `DROP + CREATE`，手工维护 |
| | `ruoyi/*Menu.sql`（8 个） | ✅ **只能跑一次** | 8 个模块的菜单 + 按钮插入，可单独运行 |
| | `ruoyi/dataScopePermiMenu.sql` | ✅ | 注册 `interview:data:all` 权限点，幂等 |
| | `sql/student_role_user.sql` | ✅ | 「学生」角色 + 学生账号 + 角色菜单绑定，幂等 |
| | `sql/cleanup_student_role_dup.sql` | ⚠️ 一次性 | 角色去重（保留 102，删 100 / 101）。**已执行完毕，勿再跑** |
| **② 设计资料** | `sql/实体与表.xlsx`、`sql/代码生成器配置表.xlsx` | — | 不是 SQL，仅供查阅 |

一句话记法：

- `RuoYi-Vue/sql/*.sql` = **若依官方的**，别改
- `sql/student.sql` = **我手写的业务表**
- `ruoyi/*Menu.sql` = **代码生成器跑完后补的菜单**
- `sql/student_role_user.sql` = **学生角色和账号**

---

## 二、从零重建一个可用的库（照这个顺序跑）

> 目标：跑完之后 `admin` / `student01` / `student02` 都能登录，学生端 8 个菜单正常显示，数据隔离生效。

| 序 | 文件 | 作用 |
| :-- | :--- | :--- |
| 1 | `RuoYi-Vue/sql/ry_20260417.sql` | 建若依基础库（`sys_*`、`gen_*`），内置 `admin`、`ry` 两个账号 |
| 2 | `RuoYi-Vue/sql/quartz.sql` | 建定时任务表 `qrtz_*` |
| 3 | `sql/student.sql` | 建学生端 8 张业务表 |
| 4 | `ruoyi/profileMenu.sql` | 学生档案菜单 |
| 5 | `ruoyi/resumeMenu.sql` | 学生简历菜单 |
| 6 | `ruoyi/jobprofileMenu.sql` | 学生岗位画像菜单 |
| 7 | `ruoyi/sessionMenu.sql` | 模拟面试场次菜单 |
| 8 | `ruoyi/questionMenu.sql` | 面试题目菜单 |
| 9 | `ruoyi/qaMenu.sql` | 面试问答菜单 |
| 10 | `ruoyi/reportMenu.sql` | 面试复盘报告菜单 |
| 11 | `ruoyi/bankMenu.sql` | 题库题目菜单 |
| 12 | `ruoyi/dataScopePermiMenu.sql` | 注册 `interview:data:all` 权限点（给后台端，**不给学生**） |
| 13 | `sql/student_role_user.sql` | **「学生」角色 + `student01` / `student02` 账号 + 角色菜单绑定** |

顺序上的两点说明：

- 第 4 ~ 11 步之间**先后无所谓**。每个脚本都自带「学生端」目录的幂等创建，不必先手工建目录，也不会再把菜单挂到根节点。
- 第 13 步**必须放在最后**，它依赖第 4 ~ 12 步的菜单已经建好。

⚠️ **第 4 ~ 11 步只能跑一次。** 它们只在「学生端目录创建」上做了幂等保护，菜单本身的 `insert` 没有去重 —— 重复执行会产生**第二套菜单**（新的 `menu_id`），第 13 步的绑定数就会翻倍。要重跑请先删库重来。

跑完第 13 步会输出校验结果，预期：

| 指标 | 预期值 | 含义 |
| :--- | :--- | :--- |
| `menu_cnt` | **49** | 1 个目录 + 8 个模块菜单 + 40 个按钮 |
| `user_cnt` | **2** | student01、student02 |
| `data_all_bound` | **0** | `interview:data:all` 没有被误绑给「学生」角色 |

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
4. **三端各有一份 dump，合并时同 id 记录会互相覆盖。** 这是三端合并最典型的踩坑方式，见 `doc/学生端对外契约.md` 第七节。
5. **它的内容已被脚本完全覆盖。** 移除前逐表核对过：
   - 8 张业务表结构与 `sql/student.sql` **逐列一致**；
   - `sys_dict_type` / `sys_dict_data` / `sys_config` / `sys_dept` / `sys_post` / `sys_job` / `sys_notice` / `sys_role_dept` / `sys_user_post` 与若依基础库脚本**完全一致**；
   - `sys_menu` / `sys_role_menu` 的差集正是学生端的 49 条（基础库 85 + 学生端 49 = 134），原生菜单无缺失；
   - `sys_role` / `sys_user` / `sys_user_role` 的差集是 role 100 / 101 / 102 + student01 + 绑定，已由 `sql/student_role_user.sql` 覆盖（100 / 101 本就是被清理的脏数据）；
   - 唯一独有内容只剩运行时日志和 student01 的旧密码密文。

**需要「某个时间点的真实库长什么样」时，正确做法是现场用客户端导出到本地，不要提交进仓库。**

---

## 五、四块拼图（已补齐）

| 块 | 内容 | 文件 | 状态 |
| :-- | :--- | :--- | :--- |
| ① | 若依基础库 | `RuoYi-Vue/sql/ry_20260417.sql`、`RuoYi-Vue/sql/quartz.sql` | ✅ |
| ② | 学生端 8 张业务表 | `sql/student.sql` | ✅ |
| ③ | 学生端菜单 + 权限点 | `ruoyi/*Menu.sql`（8 个）、`ruoyi/dataScopePermiMenu.sql` | ✅ |
| ④ | 「学生」角色 + 学生账号 + 角色菜单绑定 | `sql/student_role_user.sql` | ✅ |

四块齐了之后，「干净库 → 能登录 → 菜单可见 → 数据隔离生效」这条链路就是**纯脚本、可重放**的，阶段③的合并演练可以直接用。

`sql/student_role_user.sql` 的两个设计要点：

- **不写死 `menu_id`**：绑定关系按「学生端目录 → 其下全部菜单」动态 `INSERT ... SELECT` 算出来。三端合并后菜单 id 会整体重排，写死就废了。
- **不写死 `role_id` / `user_id`**：若依的 `sys_role`、`sys_user` 自增都从 100 起，写死会和别人撞车。脚本按 `role_key = 'student'`、`user_name = 'student01'` 查。

---

## 六、三端合并时的注意

1. **不要合并各自的整库 dump。** 需要备份就现场导出到本地，不要提交进仓库 —— 理由见第四节。
2. **菜单 SQL 以 `ruoyi/*Menu.sql` 为准**，它们已与真实库结构一致（业务菜单挂在「学生端」目录下）。
3. 收集三端全部菜单 SQL，在**干净库上按顺序重跑一遍**，而不是靠「约定号段」防冲突。
4. **账号命名空间**：学生端只用 `student01` / `student02`；后台端、企业端请用各自前缀，避免 `user_name` 撞车。
5. **角色 key 命名空间**：学生端只用 `student`；其他端不要复用这个 `role_key`。
6. 其余细节见 `doc/学生端对外契约.md`。
