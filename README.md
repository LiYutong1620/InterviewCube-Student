# 面立方 - 多 Agent 模拟面试系统｜学生端

> 基于若依 (RuoYi-Vue) 开发，Web 网页版，面向学生 / 应届生，提供 AI 多 Agent 模拟面试、简历解析、面试复盘报告等能力。

**本文件只描述项目结构。** 开发进度与阶段目标记在本地维护的 `PLAN.md`（已加入 `.gitignore`，不随仓库分发）。

---

## 项目结构说明

> 本仓库 = 若依官方前后端框架（**原封不动**）+ 面立方学生端业务代码（**interview 模块**）+ 交付物料（`doc/`、`sql/`、`ruoyi/`）。
> 业务代码统一放在 `com.ruoyi.interview` 包与 `src/views/interview`、`src/api/interview` 下，**不侵入**若依原有 system / monitor / tool 模块。

### 一、顶层目录

```text
E:\00InterviewCube-Student\
├── RuoYi-Vue\              # 后端：若依 RuoYi-Vue（Spring Boot 多模块 Maven 工程）
├── RuoYi-Vue3\             # 前端：若依 RuoYi-Vue3（Vue3 + Vite + Element Plus）
├── ruoyi\                  # 代码生成器产出物暂存区（后端 main / 前端 vue / 8 张菜单 SQL）
├── doc\                    # 需求与设计文档（功能清单、实体映射、权限标识）
├── sql\                    # 数据库脚本（若依基础表 + 学生端业务表）
└── README.md               # 本文件：阶段目标、进度、结构说明
```

| 目录 | 说明 | 是否可直接运行 |
| :--- | :--- | :--- |
| `RuoYi-Vue/` | 后端主工程，业务代码已合入 `ruoyi-admin` 模块 | ✅ 是（Maven 启动 `ruoyi-admin`） |
| `RuoYi-Vue3/` | 前端主工程，业务页面已合入 `src` | ✅ 是（`npm run dev`） |
| `ruoyi/` | **暂存 / 备份**：代码生成器原始产出，与上面两个工程里的 interview 代码一一对应（后端 48 个文件、前端 24 个文件），改完再拷进框架目录 | ❌ 否（仅存档对照） |
| `doc/` | Excel 设计文档，非代码 | — |
| `sql/` | 建库脚本，需先执行 | — |

### 二、后端结构（`RuoYi-Vue/`）

```text
RuoYi-Vue\
├── pom.xml                 # 聚合父 POM，统一依赖版本
├── ry.bat / ry.sh          # Windows / Linux 启动脚本
├── ruoyi-admin\            # ★ 启动模块：业务代码 + 配置文件都在这里
├── ruoyi-common\           # 通用工具、注解、常量、基类
├── ruoyi-framework\        # 框架核心：Security、拦截器、数据源、AOP
├── ruoyi-system\           # 系统模块：用户 / 角色 / 菜单 / 部门 / 字典
├── ruoyi-generator\        # 代码生成器
├── ruoyi-quartz\           # 定时任务
└── sql\                    # 若依自带初始化脚本（ry_*.sql、quartz.sql）
```

业务代码全部落在 `ruoyi-admin\src\main\`，采用若依标准分层：

```text
ruoyi-admin\src\main\
├── java\com\ruoyi\interview\
│   ├── controller\   # 8 个 Controller，暴露 REST 接口（@PreAuthorize 控权限 + 学生数据隔离）
│   ├── domain\       # 8 个实体类（继承 BaseEntity，7 个实现 UserOwned）+ UserOwned 归属标记接口
│   ├── mapper\       # 8 个 Mapper 接口（MyBatis）
│   ├── service\      # 8 个 Service 接口 + impl 实现类
│   └── utils\        # StudentDataScopeUtils：学生端数据隔离统一入口
└── resources\mapper\interview\   # 8 个 MyBatis XML（SQL 映射）
```

### 三、前端结构（`RuoYi-Vue3/`）

```text
RuoYi-Vue3\
├── vite.config.js          # 构建配置 + 后端代理（/dev-api）
├── .env.development        # 开发环境变量
├── index.html
└── src\
    ├── main.js             # 入口
    ├── permission.js       # 路由守卫（登录校验、动态路由）
    ├── router\index.js     # 静态路由表
    ├── store\              # Pinia 状态管理（用户、权限、设置）
    ├── layout\             # 整体布局（侧边栏 / 顶栏 / 标签页）
    ├── components\         # 通用组件（分页、上传、字典标签等）
    ├── utils\              # 请求封装 request.js、权限指令等
    ├── api\interview\      # ★ 8 个业务接口封装
    └── views\
        ├── index.vue       # ★ 已替换为学生端首页
        ├── login.vue       # 登录页
        ├── system\         # 若依自带：用户/角色/菜单/字典…
        ├── monitor\        # 若依自带：监控
        ├── tool\           # 若依自带：代码生成、表单构建
        └── interview\      # ★ 8 个业务页面目录
```

每个业务页面目录下均为 `index.vue`（列表 + 增删改查弹窗）+ `view.vue`（详情页）。

### 四、8 个业务实体 → 表 → 菜单 → 权限对照

| # | 实体（三级菜单） | 数据库表 | 后端包路径（`com.ruoyi.interview`） | 前端目录 | 权限前缀 |
| :- | :--- | :--- | :--- | :--- | :--- |
| 1 | 学生档案 | `student_profile` | `StudentProfile*` | `views/interview/profile` | `interview:profile:*` |
| 2 | 学生简历 | `student_resume` | `StudentResume*` | `views/interview/resume` | `interview:resume:*` |
| 3 | 学生岗位画像 | `student_job_profile` | `StudentJobProfile*` | `views/interview/jobprofile` | `interview:jobprofile:*` |
| 4 | 模拟面试场次 | `interview_session` | `InterviewSession*` | `views/interview/session` | `interview:session:*` |
| 5 | 面试题目 | `interview_question` | `InterviewQuestion*` | `views/interview/question` | `interview:question:*` |
| 6 | 面试问答 | `interview_qa` | `InterviewQa*` | `views/interview/qa` | `interview:qa:*` |
| 7 | 面试复盘报告 | `interview_report` | `InterviewReport*` | `views/interview/report` | `interview:report:*` |
| 8 | 题库题目 | `question_bank` | `QuestionBank*` | `views/interview/bank` | `interview:bank:*` |

> 8 个实体在 `controller / mapper / service / service.impl` 各 8 个文件，`domain` 下 8 个实体类 + 1 个 `UserOwned` 接口，`utils` 下 1 个数据隔离工具类，加上 8 个 Mapper XML，后端共 50 个文件；前端 8 个 `api/*.js` + 8 组 `index.vue`/`view.vue` 共 24 个文件。
>
> **数据归属**：前 7 张表（学生档案 ~ 面试复盘报告）都有 `user_id`，由 `StudentDataScopeUtils` 做学生隔离（学生只看/改/删自己的，admin 不受限）；`question_bank` 是共享题库，无 `user_id`，只做角色权限控制。

### 五、交付物料说明

**`doc\`（设计文档）**

| 文件 | 内容 |
| :--- | :--- |
| `面立方-三级功能清单-学生.xlsx` | 完整三级功能清单（产品规划全量） |
| `一阶段三级功能清单.xlsx` | 阶段一裁剪后的 CRUD 范围：一级/二级/三级菜单 → 实体 → 表名 → CRUD 类型 → 权限标识 |
| `菜单权限标识清单.xlsx` | 8 个菜单的权限标识清单，如 `interview:resume:list/add/edit/remove` |

**`sql\`（数据库脚本 —— 分类与执行顺序详见 `sql\README.md`）**

| 文件 | 性质 | 内容 |
| :--- | :--- | :--- |
| `student.sql` | ✅ 可执行 | 学生端 8 张业务表建表语句（`DROP + CREATE`；均带若依习惯字段 `create_by/create_time/update_by/update_time/remark`，业务表另有 `user_id` 做数据归属） |
| `student_role_user.sql` | ✅ 可执行 | 「学生」角色 + `student01` / `student02` 账号 + 角色菜单绑定，幂等 |
| `cleanup_student_role_dup.sql` | ⚠️ 一次性 | 角色去重（保留 role 102，删 100 / 101）。**已执行完毕，勿再跑** |
| `README.md` | 说明 | SQL 分类、从零重建的 13 步顺序、内置账号 |
| `实体与表.xlsx` | 资料 | 实体 ↔ 表 ↔ 字段设计对照 |
| `代码生成器配置表.xlsx` | 资料 | 若依代码生成器导入配置（字段类型、查询方式、显示类型等） |

**`ruoyi\`（生成器产出暂存区）**

| 路径 | 内容 |
| :--- | :--- |
| `main\` | 生成的后端 Java + Mapper XML（与 `RuoYi-Vue\ruoyi-admin\src\main` 中 interview 部分一致） |
| `vue\` | 生成的前端 api + views（与 `RuoYi-Vue3\src` 中 interview 部分一致） |
| `*Menu.sql` | 8 张菜单的插入 SQL（profile / resume / jobprofile / session / question / qa / report / bank）。**幂等**，自带「学生端」目录创建，执行后菜单挂到该目录下，可单独运行 |
| `dataScopePermiMenu.sql` | 注册 `interview:data:all` 权限点，供后台端分配给非超管角色 |

### 六、运行顺序（本地起服务）

1. 建库 → 按 `sql\README.md` 的 **13 步顺序**执行：`RuoYi-Vue\sql\ry_20260417.sql` → `quartz.sql` → `sql\student.sql` → `ruoyi\*Menu.sql`（8 个）→ `ruoyi\dataScopePermiMenu.sql` → `sql\student_role_user.sql`。
   - ⚠️ `ruoyi\*Menu.sql`（第 4 ~ 11 步）**只能跑一次**，重跑会产生第二套菜单、绑定数翻倍；
   - ✅ 第 13 步会自动建出「学生」角色与 `student01` / `student02` 账号（初始密码 `admin123`）。
2. 改 `RuoYi-Vue\ruoyi-admin\src\main\resources\application-druid.yml` 里的数据库连接
3. 启动后端：运行 `RuoYi-Vue\ruoyi-admin` 的 `RuoYiApplication`（或 `ry.bat`）
4. 启动前端：`cd RuoYi-Vue3 && npm install && npm run dev`
5. 访问前端地址，用 `admin` 或 `student01` / `student02` 登录
