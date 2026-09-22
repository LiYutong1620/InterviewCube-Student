# 面立方 - 多 Agent 模拟面试系统｜学生端

> 基于若依 (RuoYi-Vue) 开发，Web 网页版，面向学生 / 应届生，提供模拟面试、简历管理、复盘报告等能力。

**本文件描述项目结构、功能范围与本地启动方式。** 开发进度与阶段目标记在本地维护的 `PLAN.md`（已加入 `.gitignore`，不随仓库分发）。

---

## 当前能力概览

| 能力 | 说明 | 状态 |
| :--- | :--- | :--- |
| 学生档案 | 头像上传、昵称及其他字段修改 / 重置 / 保存 | ✅ |
| 学生简历 | 本地文件上传（pdf / doc / docx，≤10MB） | ✅ |
| 个人中心 | 资料展示与编辑、账号设置、用户协议、隐私政策、账号注销 | ✅ |
| 岗位画像 / 题库 / 面试流程 | 场次 → 题目 → 作答 → 复盘报告（阶段二 CRUD + 流程页） | ✅ |
| 复盘报告 PDF | 详情页「生成 PDF」写入 `pdf_url`，可下载 | ✅ |
| AI 评分 / AI 出题 | 阶段三能力，当前为手工填分演示 | ⏸ 押后 |

---

## 项目结构说明

> 本仓库 = 若依官方前后端框架 + 面立方学生端业务代码（**interview 模块**）+ 交付物料（`doc/`、`sql/`、`ruoyi/`）。
> 业务代码统一放在 `com.ruoyi.interview` 包与 `src/views/interview`、`src/api/interview` 下，**不侵入**若依原有 system / monitor / tool 模块。

### 一、顶层目录

```text
InterviewCube-Student\
├── RuoYi-Vue\              # 后端：若依 RuoYi-Vue（Spring Boot 多模块 Maven 工程）
├── RuoYi-Vue3\             # 前端：若依 RuoYi-Vue3（Vue3 + Vite + Element Plus）
├── ruoyi\                  # 代码生成器产出物暂存区（对照用，勿直接运行）
├── doc\                    # 需求与设计文档
├── sql\                    # 学生端数据库脚本（详见 sql/README.md）
└── README.md               # 本文件
```

| 目录 | 说明 | 是否可直接运行 |
| :--- | :--- | :--- |
| `RuoYi-Vue/` | 后端主工程，业务代码已合入 `ruoyi-admin` | ✅ Maven 启动 `ruoyi-admin` |
| `RuoYi-Vue3/` | 前端主工程，业务页面已合入 `src` | ✅ `npm run dev` |
| `ruoyi/` | 生成器原始产出暂存 / 对照 | ❌ |
| `doc/` | 设计文档 | — |
| `sql/` | 建库与补丁脚本 | — |

### 二、后端结构（`RuoYi-Vue/`）

```text
RuoYi-Vue\
├── pom.xml                 # 聚合父 POM（含 OpenPDF 等依赖版本）
├── ry.bat / ry.sh
├── ruoyi-admin\            # ★ 启动模块：业务代码 + 配置
├── ruoyi-common\
├── ruoyi-framework\
├── ruoyi-system\
├── ruoyi-generator\
├── ruoyi-quartz\
└── sql\                    # 若依官方基础库脚本（ry_*.sql、quartz.sql）
```

业务代码落在 `ruoyi-admin\src\main\`：

```text
ruoyi-admin\src\main\
├── java\com\ruoyi\interview\
│   ├── controller\   # 业务 Controller（含 StudentMineController 个人中心注销）
│   ├── domain\       # 8 个实体 + UserOwned
│   ├── mapper\
│   ├── service\      # 含复盘报告 fillReport / exportPdf
│   └── utils\        # StudentDataScopeUtils、ReportPdfUtils（PDF 生成）
└── resources\
    ├── application.yml              # ★ ruoyi.profile 文件上传根目录
    ├── application-druid.yml        # 数据库连接
    └── mapper\interview\            # MyBatis XML
```

### 三、前端结构（`RuoYi-Vue3/`）

```text
RuoYi-Vue3\src\
├── api\interview\          # 业务接口（含 report.js PDF、mine.js 注销）
├── views\
│   ├── index.vue           # 学生端首页（快捷入口）
│   └── interview\
│       ├── mine\           # ★ 个人中心
│       ├── profile\        # 学生档案（一页式表单）
│       ├── resume\         # 学生简历（列表 + 上传弹窗）
│       ├── jobprofile\
│       ├── session\        # 面试场次（流程主干）
│       ├── question\       # 面试题目（按 sessionId 回顾）
│       ├── qa\             # 面试作答
│       ├── report\         # 复盘报告（列表 + 详情抽屉 + PDF）
│       └── bank\           # 题库（只读浏览）
└── layout\components\Navbar.vue   # 学生角色「个人中心」跳转 /student/mine
```

### 四、业务模块对照

| # | 菜单 | 表 / 实体 | 前端 | 权限前缀 | 备注 |
| :- | :--- | :--- | :--- | :--- | :--- |
| — | 个人中心 | `student_profile` + `sys_user` + `sys_config` | `views/interview/mine` | `interview:mine:*` | 昵称头像 / 账号 / 协议 / 注销 |
| 1 | 学生档案 | `student_profile` | `views/interview/profile` | `interview:profile:*` | 头像 + 全字段编辑 |
| 2 | 学生简历 | `student_resume` | `views/interview/resume` | `interview:resume:*` | 文件上传 |
| 3 | 学生岗位画像 | `student_job_profile` | `views/interview/jobprofile` | `interview:jobprofile:*` | |
| 4 | 模拟面试场次 | `interview_session` | `views/interview/session` | `interview:session:*` | 流程主干 |
| 5 | 面试题目 | `interview_question` | `views/interview/question` | `interview:question:*` | |
| 6 | 面试问答 | `interview_qa` | `views/interview/qa` | `interview:qa:*` | |
| 7 | 面试复盘报告 | `interview_report` | `views/interview/report` | `interview:report:*` | Excel 导出 + **PDF** |
| 8 | 题库题目 | `question_bank` | `views/interview/bank` | `interview:bank:*` | 共享只读 |

> **数据归属**：带 `user_id` 的表由 `StudentDataScopeUtils` 隔离（学生只看自己的；拥有 `interview:data:all` 的角色可看全部）。`question_bank` 无 `user_id`，按状态对学生可见。

**关键接口补充：**

| 方法 | 路径 | 说明 |
| :--- | :--- | :--- |
| `POST` | `/interview/report/pdf/{id}` | 生成 PDF，回写 `pdf_url`（权限 `interview:report:export`） |
| `POST` | `/interview/report/fill` | 手工填分（演示用） |
| `DELETE` | `/interview/mine/cancel` | 学生自助注销账号 |
| `POST` | `/common/upload` | 通用上传（头像、简历等） |
| `GET` | `/system/config/configKey/{key}` | 读协议正文（`student.agreement.user` / `privacy`） |

---

## 五、交付物料

**`doc/`**

| 文件 | 内容 |
| :--- | :--- |
| `学生端对外契约.md` | 三端合并对接依据 |
| `CRUD字段清单.md` | 各模块字段取舍 |
| `面试流程四件套形态方案.md` | 场次 / 题目 / 问答 / 报告形态（S1~S5 已落地） |
| 若干 `.xlsx` | 功能清单、权限标识、实体映射等 |

**`sql/`（执行顺序详见 `sql/README.md`）**

| 文件 | 性质 | 内容 |
| :--- | :--- | :--- |
| **`student_init.sql`** | ✅ 一键重建 | 建表 + 菜单（含个人中心）+ 角色账号 + 字典 + 协议参数 + 演示题 |
| `student_patch_mine.sql` | ⚠️ 旧库增量 | 个人中心菜单绑定 + 协议 `sys_config`（**已有库必跑**） |
| `student_patch.sql` | ⚠️ 旧库补丁 | 列注释改码 / 角色去重 |
| 其余 `student_*.sql` 等 | 留档 | 已被 `student_init.sql` 吸收，勿单独跑 |

---

## 六、本地运行

### 1. 建库

按 `sql/README.md` 顺序：

1. `RuoYi-Vue/sql/ry_20260417.sql`
2. `RuoYi-Vue/sql/quartz.sql`
3. **`sql/student_init.sql`**（从零重建）

若库早已建好、只想补个人中心与协议参数，执行：

```text
sql/student_patch_mine.sql
```

然后**重新登录**学生账号以刷新菜单。

### 2. 改配置

| 文件 | 必改项 |
| :--- | :--- |
| `RuoYi-Vue/.../application-druid.yml` | 数据库 URL / 账号 / 密码 |
| `RuoYi-Vue/.../application.yml` → `ruoyi.profile` | **文件上传根目录，必须指向本机真实存在的磁盘路径** |

当前默认：

```yaml
ruoyi:
  profile: C:/ruoyi/uploadPath
```

> 本机若无对应盘符，上传头像 / 简历 / 生成 PDF 都会失败。请改成实际路径，并确保目录可写（建议预先创建 `upload`、`avatar` 子目录）。

另需本机 **Redis**（若依默认连接本地 Redis）。

### 3. 启动

```bash
# 后端（IDE 运行 RuoYiApplication，或）
# 在 RuoYi-Vue 下用 Maven 启动 ruoyi-admin

# 前端
cd RuoYi-Vue3
npm install
npm run dev
```

- 前端默认：http://localhost:80 （代理到后端 8080）
- 测试账号：`student01` / `student02`，初始密码一般为 `admin123`（以库内实际为准；也可用 `admin`）

### 4. 功能自测建议

1. 登录 `student01` → 侧栏应出现 **个人中心**
2. 个人中心 / 学生档案 → 上传头像并保存
3. 学生简历 → 新增并上传 pdf/doc/docx
4. 复盘报告 → 打开已生成报告 → **生成 PDF** → 下载

---

## 七、注意事项

- 先起后端再起前端；否则 Vite 会出现 `ECONNREFUSED` / 「连接失败」。
- 执行菜单补丁后必须**重新登录**，动态路由与权限才会刷新。
- `interview:data:all` 仅给后台管理角色，**不要**绑给学生角色。
- `ruoyi/` 与主工程改完应对齐（生成器留档），以 `RuoYi-Vue` / `RuoYi-Vue3` 为准运行。
