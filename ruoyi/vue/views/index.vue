<template>
  <div v-loading="loading" class="app-container student-home">
    <!-- ① 运营位：顶部横幅 / 轮播图（P2）—— 阶段一为静态运营位，不依赖后端 -->
    <el-carousel
      class="banner"
      height="140px"
      :interval="5000"
      arrow="hover"
      indicator-position="none"
    >
      <el-carousel-item v-for="item in BANNERS" :key="item.title">
        <div class="banner-slide" :style="{ background: item.background }">
          <div class="banner-text">
            <h3>{{ item.title }}</h3>
            <p>{{ item.desc }}</p>
          </div>
          <el-button round class="banner-btn" @click="goBanner(item)">{{ item.actionText }}</el-button>
        </div>
      </el-carousel-item>
    </el-carousel>

    <!-- ② 欢迎区 + 成长状态（等级 / 积分） -->
    <el-row :gutter="20" class="top-row">
      <el-col :xs="24" :md="14">
        <el-card class="welcome-card" shadow="never">
          <div class="welcome-inner">
            <div class="welcome-text">
              <h2>你好，{{ nickName }} 👋</h2>
              <p>{{ welcomeTip }}</p>
            </div>
            <el-avatar :size="64" :src="avatar" />
          </div>
        </el-card>
      </el-col>

      <el-col :xs="24" :md="10">
        <el-card class="growth-card" shadow="never">
          <div class="growth-head">
            <el-icon class="growth-head__icon" :size="18"><Medal /></el-icon>
            <span class="growth-head__title">成长状态</span>
          </div>

          <div class="growth-main">
            <div class="growth-level">
              <span class="growth-level__name">{{ levelName }}</span>
              <span class="growth-level__tip">{{ levelTip }}</span>
            </div>
            <div class="growth-points">
              <span class="growth-points__num">{{ points }}</span>
              <span class="growth-points__unit">积分</span>
            </div>
          </div>

          <el-progress
            class="growth-bar"
            :percentage="levelProgress"
            :stroke-width="8"
            :show-text="false"
            color="#409eff"
          />

          <!-- 等级阶梯：面试小白 → 面霸 -->
          <div class="level-track">
            <template v-for="(level, index) in LEVELS" :key="level.name">
              <span v-if="index" class="level-track__sep">›</span>
              <span
                class="level-track__item"
                :class="{ 'is-reached': index <= levelIndex, 'is-current': index === levelIndex }"
              >{{ level.short }}</span>
            </template>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- ③ 新手引导入口（保留） -->
    <el-card class="guide-card" shadow="never">
      <div class="guide-inner">
        <div class="guide-left">
          <el-icon class="guide-icon" :size="26"><Compass /></el-icon>
          <div class="guide-text">
            <div class="guide-title">{{ guideCardTitle }}</div>
            <div class="guide-desc">{{ guideCardDesc }}</div>
          </div>
        </div>
        <el-button :type="guideDone && !canViewAll ? 'default' : 'primary'" @click="goGuide">
          {{ guideCardAction }}
        </el-button>
      </div>
    </el-card>

    <!-- ④ 快速开始（P0） -->
    <el-card class="section-card" shadow="never">
      <template #header>
        <div class="card-header"><span>快速开始</span></div>
      </template>
      <el-row :gutter="16">
        <el-col :xs="24" :sm="12">
          <div class="quick-item quick-item--primary" @click="goStartInterview">
            <el-icon class="quick-item__icon" :size="30"><VideoCamera /></el-icon>
            <div class="quick-item__text">
              <div class="quick-item__title">开始面试</div>
              <div class="quick-item__desc">一键进入岗位选择，AI 面试官已就位</div>
            </div>
            <el-icon class="quick-item__arrow" :size="16"><ArrowRight /></el-icon>
          </div>
        </el-col>

        <el-col :xs="24" :sm="12">
          <div
            class="quick-item"
            :class="{ 'is-disabled': !ongoingSession }"
            @click="goContinueInterview"
          >
            <el-icon class="quick-item__icon" :size="30"><VideoPlay /></el-icon>
            <div class="quick-item__text">
              <div class="quick-item__title">继续面试</div>
              <div class="quick-item__desc">{{ continueDesc }}</div>
            </div>
            <el-icon class="quick-item__arrow" :size="16"><ArrowRight /></el-icon>
          </div>
        </el-col>
      </el-row>
    </el-card>

    <!-- ⑤ 个性化推荐（P1） -->
    <el-row :gutter="20" class="recommend-row">
      <!-- 岗位推荐 -->
      <el-col :xs="24" :md="8">
        <el-card class="rec-card" shadow="never">
          <template #header>
            <div class="card-header">
              <span class="card-header__title"><el-icon><Briefcase /></el-icon> 岗位推荐</span>
            </div>
          </template>

          <div class="rec-block">
            <div class="rec-block__label">你的目标岗位</div>
            <template v-if="targetJob">
              <div class="rec-target">
                <span class="rec-target__name">{{ targetJob.jobName || '未填写岗位' }}</span>
                <el-tag v-if="targetJob.difficulty" size="small" type="info">
                  {{ dictLabel(student_difficulty, targetJob.difficulty) }}
                </el-tag>
              </div>
              <div class="rec-target__meta">
                {{ dictLabel(student_industry, targetJob.industry) || '未填写行业' }}
                <template v-if="targetJob.companyType">
                  · 目标 {{ dictLabel(student_company_type, targetJob.companyType) }}
                </template>
              </div>
            </template>
            <div v-else class="rec-empty">
              还没设置岗位画像，
              <el-link type="primary" underline="never" @click="goJobProfile">去设置</el-link>
            </div>
          </div>

          <div class="rec-block">
            <div class="rec-block__label">
              同行业热门岗位
              <span v-if="targetJob" class="rec-block__hint">基于你的行业</span>
            </div>
            <div v-if="recommendJobs.length" class="rec-tags">
              <el-tag v-for="job in recommendJobs" :key="job" class="rec-tag" effect="plain">{{ job }}</el-tag>
            </div>
            <div v-else-if="historyJobs.length" class="rec-tags">
              <el-tag v-for="job in historyJobs" :key="job" class="rec-tag" effect="plain">{{ job }}</el-tag>
            </div>
            <div v-else class="rec-empty">暂无推荐，先去完成一场面试吧</div>
          </div>

          <el-button class="rec-btn" type="primary" plain @click="goStartInterview">按推荐开始面试</el-button>
        </el-card>
      </el-col>

      <!-- 薄弱点练习 -->
      <el-col :xs="24" :md="8">
        <el-card class="rec-card" shadow="never">
          <template #header>
            <div class="card-header">
              <span class="card-header__title"><el-icon><Aim /></el-icon> 薄弱点练习</span>
            </div>
          </template>

          <template v-if="weakDimension">
            <div class="rec-block">
              <div class="rec-block__label">最需要提升的维度</div>
              <div class="weak-head">
                <span class="weak-head__name">{{ weakDimension.label }}</span>
                <span class="weak-head__score">{{ weakDimension.score }} 分</span>
              </div>
              <div class="weak-head__meta">
                已按该维度推送
                <el-tag size="small" effect="plain">
                  {{ dictLabel(interview_question_type, weakDimension.questionType) }}
                </el-tag>
              </div>
            </div>

            <div class="rec-block">
              <div class="rec-block__label">推荐练习题目</div>
              <ul v-if="weakQuestions.length" class="rec-list">
                <li v-for="item in weakQuestions" :key="item.id" @click="goBank({ questionType: weakDimension.questionType })">
                  {{ item.questionContent }}
                </li>
              </ul>
              <div v-else class="rec-empty">题库里暂时没有这类题目</div>
            </div>

            <el-button class="rec-btn" type="primary" plain @click="goBank({ questionType: weakDimension.questionType })">
              去题库练这一类
            </el-button>
          </template>

          <el-empty v-else description="完成一场面试并生成报告后，就能看到你的薄弱点" :image-size="72" />
        </el-card>
      </el-col>

      <!-- 真题范例入口 -->
      <el-col :xs="24" :md="8">
        <el-card class="rec-card" shadow="never">
          <template #header>
            <div class="card-header">
              <span class="card-header__title"><el-icon><Reading /></el-icon> 真题范例</span>
              <span class="card-header__hint">高频真题 · 优秀回答范例</span>
            </div>
          </template>

          <div v-if="hotQuestions.length" class="hot-list">
            <div v-for="item in hotQuestions" :key="item.id" class="hot-item" @click="goBank({})">
              <div class="hot-item__title">{{ item.questionContent }}</div>
              <div class="hot-item__meta">
                <el-tag v-if="item.questionType" size="small" effect="plain">
                  {{ dictLabel(interview_question_type, item.questionType) }}
                </el-tag>
                <el-tag v-if="item.source" size="small" type="success" effect="plain">
                  {{ dictLabel(question_bank_source, item.source) }}
                </el-tag>
                <span class="hot-item__count">被练 {{ item.useCount || 0 }} 次</span>
              </div>
            </div>
          </div>
          <el-empty v-else description="题库暂时没有可展示的真题" :image-size="72" />

          <el-button class="rec-btn" type="primary" plain @click="goBank({})">进入题库看范例</el-button>
        </el-card>
      </el-col>
    </el-row>

    <!-- ⑥ 最近报告摘要（P1）：上次得分 + 雷达图缩略 -->
    <el-card class="recent-card" shadow="never">
      <template #header>
        <div class="card-header">
          <span>最近报告</span>
          <el-button text type="primary" @click="goReport()">查看全部</el-button>
        </div>
      </template>

      <template v-if="latestReport && latestReport.generateStatus === GENERATE_SUCCESS">
        <el-row :gutter="16">
          <el-col :xs="24" :sm="8">
            <div class="score-block">
              <div class="score-block__value">{{ latestReport.totalScore }}</div>
              <div class="score-block__label">上次综合得分</div>
              <div class="score-block__meta">
                {{ latestReport.jobName || '—' }} · {{ parseTime(latestReport.startTime, '{y}-{m}-{d}') || '—' }}
              </div>
              <el-button class="score-block__btn" type="primary" plain size="small" @click="goReport(latestReport.sessionId)">
                看完整报告
              </el-button>
            </div>
          </el-col>
          <el-col :xs="24" :sm="16">
            <div ref="radarRef" class="radar-thumb"></div>
          </el-col>
        </el-row>
        <div v-if="latestReport.summary" class="report-summary">
          <span class="report-summary__label">总体评价</span>
          <p class="report-summary__text">{{ latestReport.summary }}</p>
        </div>
      </template>

      <el-empty v-else description="还没有生成过复盘报告，先去完成一场模拟面试吧">
        <el-button type="primary" @click="goStartInterview">开始面试</el-button>
      </el-empty>
    </el-card>
  </div>
</template>

<script setup name="Index">
import { computed, nextTick, onBeforeUnmount, onMounted, ref, watch } from "vue";
import { useRouter } from "vue-router";
import * as echarts from "echarts";
import useUserStore from "@/store/modules/user";
import { listProfile } from "@/api/interview/profile";
import { listSession } from "@/api/interview/session";
import { listReport } from "@/api/interview/report";
import { listJobprofile } from "@/api/interview/jobprofile";
import { listBank } from "@/api/interview/bank";
import { checkPermi } from "@/utils/permission";
import { parseTime } from "@/utils/ruoyi";

/**
 * 首页数据来源（全部走已有的 list 接口，后端一行没改）：
 *   1. listProfile      → 等级 / 积分 / 引导状态（取第一条，后端按登录用户隔离）
 *   2. listSession      → 续答未完成的场次 + 历史练过的岗位
 *   3. listReport       → 最近一份报告的得分与五维（后端已 order by id desc）
 *   4. listJobprofile   → 目标岗位画像（岗位推荐基准）
 *   5. listBank(source=1, 按 useCount 倒序) → 真题范例（高频真题）
 *   6. listBank(industry=目标岗位行业)      → 同行业岗位池（聚合出推荐岗位）
 *   7. listBank(questionType=最弱维度映射)  → 薄弱点推题
 *
 * ⚠️ 后端的 list 对**管理员**（`interview:data:all`）不做 user_id 限定 —— 实测 admin 登录时
 * listProfile / listSession / listReport 返回的是**全部学生**的行。
 * 所以这里统一用 `userId === 当前登录用户 id` 过滤一遍：
 *   学生端本来就是自己的（后端已限定，过滤是空操作）；管理员则只看自己的，没有就显示空态。
 * 这样既不串号，也不因为身份而丢掉首页功能。
 */

/** 与引导页共用同一组 key */
const GUIDE_DONE_KEY = "interview_guide_done";
const GUIDE_DISMISSED_KEY = "interview_guide_dismissed";

/** 报告「生成成功」状态：只有它才有分数与雷达图 */
const GENERATE_SUCCESS = "2";

/** 可以续答的场次状态：未开始 / 进行中 */
const ONGOING_STATUS = ["0", "1"];

/**
 * 成长等级阶梯。⚠️ `student_profile.current_level` 目前**没有字典、也没有任何后端代码写它**
 * （DDL 默认值就是 '小白'），所以等级按 `current_points` 推导；
 * 若 `current_level` 被后台写成了阶梯以外的值，则以库里的为准（见 levelName）。
 * 阶段三接入积分 / 等级服务后，这里改成直接取 `current_level` 即可。
 */
const LEVELS = [
  { min: 0, name: "面试小白", short: "小白" },
  { min: 100, name: "初出茅庐", short: "新芽" },
  { min: 300, name: "渐入佳境", short: "进阶" },
  { min: 600, name: "对答如流", short: "流利" },
  { min: 1000, name: "面试达人", short: "达人" },
  { min: 1500, name: "面霸", short: "面霸" }
];

/** DDL 默认值，视同「未设置等级」 */
const DEFAULT_LEVEL = "小白";

/**
 * 五维得分 → 题型 的映射，用于「薄弱点练习」推题。
 * 这是阶段一的**前端启发式**（不是 AI 结论）：按每个维度最吃哪种面试形式来对应，
 * 阶段三由 AI 直接给推荐题单后，这块整体替换。
 */
const DIMENSIONS = [
  { prop: "scoreCompleteness", label: "完整性", questionType: "1" },
  { prop: "scoreLogic", label: "逻辑性", questionType: "4" },
  { prop: "scoreFluency", label: "流畅度", questionType: "3" },
  { prop: "scoreDepth", label: "深度", questionType: "2" },
  { prop: "scoreConfidence", label: "自信度", questionType: "3" }
];

/** 运营位（P2）：阶段一静态配置，阶段三可换成后台可配的运营表 / sys_config */
const BANNERS = [
  {
    title: "AI 模拟面试，随时开练",
    desc: "选岗位、挑题型，AI 面试官全程陪你练到稳",
    actionText: "立即开始",
    to: "/student/session",
    background: "linear-gradient(135deg, #409eff 0%, #79bbff 100%)"
  },
  {
    title: "简历传上来，AI 帮你改",
    desc: "上传简历自动解析，生成针对你经历的追问",
    actionText: "上传简历",
    to: "/student/resume",
    background: "linear-gradient(135deg, #36cfc9 0%, #5cdbd3 100%)"
  },
  {
    title: "复盘报告，看清短板",
    desc: "五维雷达图 + 薄弱点标签，每次面试都知道差在哪",
    actionText: "看看报告",
    to: "/student/report",
    background: "linear-gradient(135deg, #9254de 0%, #b37feb 100%)"
  }
];

const { student_industry, student_difficulty, student_company_type, interview_question_type, question_bank_source } =
  useDict(
    "student_industry",
    "student_difficulty",
    "student_company_type",
    "interview_question_type",
    "question_bank_source"
  );

const router = useRouter();
const userStore = useUserStore();

const loading = ref(true);
const nickName = computed(() => userStore.nickName || userStore.name || "同学");
const avatar = computed(() => userStore.avatar || "");
const guideDone = ref(localStorage.getItem(GUIDE_DONE_KEY) === "1");

const profile = ref(null);
const profileLoaded = ref(false);
const sessionList = ref([]);
const latestReport = ref(null);
const jobProfiles = ref([]);
const industryBank = ref([]);
const hotQuestions = ref([]);
const weakQuestions = ref([]);

const radarRef = ref(null);
let chart = null;

/** 带 interview:data:all 的身份（超管 / 后台端）：引导卡片文案与「是否自动进引导」要用 */
const canViewAll = computed(() => checkPermi(["interview:data:all"]));

/**
 * 当前登录用户 id（`getInfo` 里写入 `user.userId`）。
 * 后端的 list 对管理员不做 user_id 限定，所以首页拿到列表后统一按它过滤一次，
 * 保证「我的成长状态 / 我的未完成面试 / 我的最近报告」永远是**本人**的数据。
 */
const myUserId = computed(() => userStore.id);

function isMine(row) {
  return row && String(row.userId) === String(myUserId.value);
}

// ---------------------------------------------------------------- 欢迎 / 引导

const welcomeTip = computed(() =>
  canViewAll.value
    ? "当前身份带「查看全部数据」权限，首页只展示属于你自己的数据，不汇总其他学生。"
    : "今天也要加油面试，离 offer 更近一步。"
);

const guideCardTitle = computed(() =>
  canViewAll.value ? "新手引导" : guideDone.value ? "新手引导已完成" : "还差一步，完成新手引导"
);
const guideCardDesc = computed(() =>
  canViewAll.value
    ? "当前身份带「查看全部数据」权限，进入后仅作预览，不会读写学生数据。"
    : guideDone.value
      ? "想再看看？可以随时重新走一遍引导流程。"
      : "填写岗位画像、上传简历、选择目标企业，让 AI 更懂你。"
);
const guideCardAction = computed(() =>
  canViewAll.value ? "预览引导" : guideDone.value ? "重新体验引导" : "开始引导"
);

// ---------------------------------------------------------------- 成长状态

const points = computed(() => {
  const value = Number(profile.value && profile.value.currentPoints);
  return Number.isFinite(value) ? value : 0;
});

const levelIndex = computed(() => {
  let hit = 0;
  LEVELS.forEach((level, index) => {
    if (points.value >= level.min) {
      hit = index;
    }
  });
  return hit;
});

const levelName = computed(() => {
  const raw = ((profile.value && profile.value.currentLevel) || "").trim();
  // 库里写过自定义等级就用它；否则按积分推导
  return raw && raw !== DEFAULT_LEVEL ? raw : LEVELS[levelIndex.value].name;
});

const levelProgress = computed(() => {
  const current = LEVELS[levelIndex.value];
  const next = LEVELS[levelIndex.value + 1];
  if (!next) {
    return 100;
  }
  const span = next.min - current.min;
  return Math.max(0, Math.min(100, Math.round(((points.value - current.min) / span) * 100)));
});

const levelTip = computed(() => {
  const next = LEVELS[levelIndex.value + 1];
  if (!next) {
    return "已是最高等级，继续保持！";
  }
  return `再攒 ${next.min - points.value} 积分升到「${next.name}」`;
});

// ---------------------------------------------------------------- 快速开始

const ongoingSession = computed(
  () => sessionList.value.find(item => ONGOING_STATUS.includes(item.status)) || null
);

const continueDesc = computed(() => {
  const session = ongoingSession.value;
  if (!session) {
    return "暂无未完成的面试，先去开始一场";
  }
  const job = session.jobName || "模拟面试";
  return `「${job}」已答 ${session.answeredCount || 0} / ${session.totalCount || 0} 题，接着答`;
});

// ---------------------------------------------------------------- 个性化推荐

const targetJob = computed(
  () => jobProfiles.value.find(item => item.isDefault === "1") || jobProfiles.value[0] || null
);

const historyJobs = computed(() => {
  const seen = new Set();
  const list = [];
  sessionList.value.forEach(item => {
    const name = (item.jobName || "").trim();
    if (name && !seen.has(name)) {
      seen.add(name);
      list.push(name);
    }
  });
  return list.slice(0, 3);
});

/** 推荐岗位 = 同行业题库覆盖的岗位，排除自己的目标岗位与练过的岗位 */
const recommendJobs = computed(() => {
  const exclude = new Set([targetJob.value && targetJob.value.jobName, ...historyJobs.value].filter(Boolean));
  const seen = new Set();
  const list = [];
  industryBank.value.forEach(item => {
    const name = (item.jobName || "").trim();
    if (name && !exclude.has(name) && !seen.has(name)) {
      seen.add(name);
      list.push(name);
    }
  });
  return list.slice(0, 3);
});

/** 最弱维度：取五维里分数最低的一项（无报告 / 未生成成功时为 null） */
const weakDimension = computed(() => {
  const report = latestReport.value;
  if (!report || report.generateStatus !== GENERATE_SUCCESS) {
    return null;
  }
  let weakest = null;
  DIMENSIONS.forEach(dimension => {
    const score = Number(report[dimension.prop]);
    if (!Number.isFinite(score)) {
      return;
    }
    if (!weakest || score < weakest.score) {
      weakest = { ...dimension, score };
    }
  });
  return weakest;
});

// ---------------------------------------------------------------- 数据加载

/**
 * 字典翻译，取不到时原样返回。
 * 兼容两种入参：`<script>` 里传进来的是 ref（`useDict` 的产物），
 * 模板里传进来的是被自动解包后的数组 —— 两种都要能跑。
 */
function dictLabel(options, value) {
  if (value === null || value === undefined || value === "") {
    return "";
  }
  const list = Array.isArray(options) ? options : (options && options.value) || [];
  const hit = list.find(dict => dict.value === String(value));
  return hit ? hit.label : String(value);
}

function loadProfile() {
  return listProfile({ pageNum: 1, pageSize: 1 })
    .then(response => {
      profile.value = (response.rows || []).find(isMine) || null;
      profileLoaded.value = true;
      // 库里有档案且引导已完成 → 同步本机标记
      if (profile.value && profile.value.guideStatus === "1") {
        guideDone.value = true;
        localStorage.setItem(GUIDE_DONE_KEY, "1");
      }
    })
    .catch(() => {
      profileLoaded.value = false;
    });
}

/** 一次拉 20 条最近场次：既用来找「续答未完成」，也用来汇总练过的岗位 */
function loadSessions() {
  return listSession({ pageNum: 1, pageSize: 20, orderByColumn: "id", isAsc: "desc" })
    .then(response => {
      sessionList.value = (response.rows || []).filter(isMine);
    })
    .catch(() => {});
}

function loadLatestReport() {
  // 后端已 order by ir.id desc，这里不要再传 orderByColumn
  return listReport({ pageNum: 1, pageSize: 1 })
    .then(response => {
      latestReport.value = (response.rows || []).find(isMine) || null;
    })
    .catch(() => {});
}

function loadJobProfiles() {
  return listJobprofile({ pageNum: 1, pageSize: 20, status: "0" })
    .then(response => {
      jobProfiles.value = (response.rows || []).filter(isMine);
    })
    .catch(() => {});
}

/** 高频真题：题库里 source=1（真题），按被使用次数倒序 */
function loadHotQuestions() {
  return listBank({ pageNum: 1, pageSize: 3, source: "1", orderByColumn: "useCount", isAsc: "desc" })
    .then(response => {
      hotQuestions.value = response.rows || [];
    })
    .catch(() => {});
}

/** 同行业岗位池：用来聚合推荐岗位 */
function loadIndustryBank() {
  const industry = targetJob.value && targetJob.value.industry;
  if (!industry) {
    return Promise.resolve();
  }
  return listBank({ pageNum: 1, pageSize: 20, industry })
    .then(response => {
      industryBank.value = response.rows || [];
    })
    .catch(() => {});
}

/** 薄弱点推题：按最弱维度映射到的题型取题 */
function loadWeakQuestions() {
  const dimension = weakDimension.value;
  if (!dimension) {
    return Promise.resolve();
  }
  return listBank({
    pageNum: 1,
    pageSize: 3,
    questionType: dimension.questionType,
    orderByColumn: "useCount",
    isAsc: "desc"
  })
    .then(response => {
      weakQuestions.value = response.rows || [];
    })
    .catch(() => {});
}

async function loadAll() {
  loading.value = true;
  await Promise.allSettled([
    loadProfile(),
    loadSessions(),
    loadLatestReport(),
    loadJobProfiles(),
    loadHotQuestions()
  ]);
  // 这两步依赖上面的结果（目标岗位的行业 / 报告的最弱维度）
  await Promise.allSettled([loadIndustryBank(), loadWeakQuestions()]);
  loading.value = false;
  autoEnterGuide();
}

// ---------------------------------------------------------------- 雷达图缩略

function toScore(value) {
  const num = Number(value);
  return Number.isFinite(num) ? num : 0;
}

/** 用五个维度分构建雷达图（与报告详情页同源，缩略版去掉 tooltip / 面积描边） */
function buildRadarOption() {
  const report = latestReport.value || {};
  return {
    radar: {
      radius: "62%",
      center: ["50%", "52%"],
      indicator: DIMENSIONS.map(item => ({ name: item.label, max: 100 })),
      axisName: { color: "#606266", fontSize: 11 },
      splitLine: { lineStyle: { color: "#e4e7ed" } },
      splitArea: { areaStyle: { color: ["#ffffff", "#fafafa"] } },
      axisLine: { lineStyle: { color: "#e4e7ed" } }
    },
    series: [
      {
        type: "radar",
        symbolSize: 4,
        lineStyle: { color: "#409eff", width: 2 },
        itemStyle: { color: "#409eff" },
        areaStyle: { color: "rgba(64, 158, 255, 0.25)" },
        data: [{ value: DIMENSIONS.map(item => toScore(report[item.prop])), name: "上次得分" }]
      }
    ]
  };
}

function drawRadar() {
  if (!latestReport.value || latestReport.value.generateStatus !== GENERATE_SUCCESS) {
    return;
  }
  if (!radarRef.value) {
    return;
  }
  if (!chart) {
    chart = echarts.init(radarRef.value);
  }
  chart.setOption(buildRadarOption(), true);
  chart.resize();
}

/**
 * 报告数据到位、或雷达容器挂载完成时各触发一次。
 * 只靠 loadAll 末尾的 nextTick 有静默失败风险：`v-if` 容器还没渲染完时
 * `radarRef.value` 是 null，drawRadar 会直接 return，图就再也不画了。
 */
watch([latestReport, radarRef], () => {
  nextTick(drawRadar);
});

function handleResize() {
  if (chart) {
    chart.resize();
  }
}

// ---------------------------------------------------------------- 引导自动进入

/** 首次进入：引导未完成（student_profile.guide_status = 0）时自动进入引导 */
function autoEnterGuide() {
  // 已在本机跳过或已完成，就不再自动弹出，首页入口仍然可用
  if (localStorage.getItem(GUIDE_DISMISSED_KEY) === "1") return;
  if (localStorage.getItem(GUIDE_DONE_KEY) === "1") return;
  // 超管 / 后台端不自动进引导：list 返回的是全部学生的档案，拿别人的 guide_status 判断会误跳
  if (canViewAll.value) return;
  // 档案没读到（接口失败）就不跳，避免把正常用户误送去引导
  if (!profileLoaded.value) return;
  if (profile.value && profile.value.guideStatus === "1") return;
  nextTick(() => router.push("/guide"));
}

// ---------------------------------------------------------------- 跳转

function goBanner(item) {
  router.push(item.to);
}

/** 开始面试：带 ?start=1 进「模拟面试场次」，由那一页直接弹开岗位选择对话框 */
function goStartInterview() {
  router.push({ path: "/student/session", query: { start: "1" } });
}

/** 继续面试：带 sessionId 进「模拟面试场次」，那一页直接切到作答模式接着答 */
function goContinueInterview() {
  const session = ongoingSession.value;
  if (!session) {
    router.push("/student/session");
    return;
  }
  router.push({ path: "/student/session", query: { sessionId: session.id } });
}

function goJobProfile() {
  router.push("/student/jobprofile");
}

/** 复盘报告：带 sessionId 时直接定位到那一场 */
function goReport(sessionId) {
  if (sessionId) {
    router.push({ path: "/student/report", query: { sessionId } });
    return;
  }
  router.push("/student/report");
}

/** 题库：带筛选条件进入（题库页会把它们回填到查询区） */
function goBank(query) {
  router.push({ path: "/student/bank", query });
}

function goGuide() {
  router.push("/guide");
}

onMounted(() => {
  window.addEventListener("resize", handleResize);
  loadAll();
});

onBeforeUnmount(() => {
  window.removeEventListener("resize", handleResize);
  if (chart) {
    chart.dispose();
    chart = null;
  }
});
</script>

<style scoped lang="scss">
.student-home {
  /* ① 运营位 */
  .banner {
    margin-bottom: 20px;
    border-radius: 6px;
    overflow: hidden;
  }

  .banner-slide {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 24px;
    height: 100%;
    padding: 0 32px;
    color: #fff;
  }

  .banner-text {
    min-width: 0;

    h3 {
      margin: 0 0 8px;
      font-size: 20px;
      font-weight: 600;
      color: #fff;
    }

    p {
      margin: 0;
      font-size: 13px;
      color: rgba(255, 255, 255, 0.92);
    }
  }

  .banner-btn {
    flex-shrink: 0;
    color: #409eff;
    background: #fff;
    border: none;
  }

  /* ② 欢迎区 + 成长状态 */
  .top-row {
    margin-bottom: 20px;

    .el-col {
      margin-bottom: 20px;
    }
  }

  .welcome-card {
    height: 100%;
    border: none;
    background: linear-gradient(135deg, #409eff 0%, #79bbff 100%);
    color: #fff;

    :deep(.el-card__body) {
      height: 100%;
      padding: 24px 28px;
    }

    .welcome-inner {
      display: flex;
      align-items: center;
      justify-content: space-between;
      height: 100%;
      gap: 16px;
    }

    .welcome-text {
      min-width: 0;

      h2 {
        margin: 0 0 8px;
        font-size: 22px;
        color: #fff;
      }

      p {
        margin: 0;
        font-size: 14px;
        line-height: 1.6;
        color: rgba(255, 255, 255, 0.9);
      }
    }
  }

  .growth-card {
    height: 100%;

    :deep(.el-card__body) {
      height: 100%;
      padding: 18px 20px;
    }

    .growth-head {
      display: flex;
      align-items: center;
      gap: 6px;

      &__icon {
        color: #e6a23c;
      }

      &__title {
        font-size: 14px;
        font-weight: 600;
        color: #303133;
      }
    }

    .growth-main {
      display: flex;
      align-items: baseline;
      justify-content: space-between;
      gap: 12px;
      margin-top: 12px;
    }

    .growth-level {
      min-width: 0;

      &__name {
        display: block;
        font-size: 20px;
        font-weight: 600;
        color: #409eff;
      }

      &__tip {
        display: block;
        margin-top: 4px;
        font-size: 12px;
        color: #909399;
      }
    }

    .growth-points {
      flex-shrink: 0;

      &__num {
        font-size: 24px;
        font-weight: 600;
        color: #303133;
      }

      &__unit {
        margin-left: 2px;
        font-size: 12px;
        color: #909399;
      }
    }

    .growth-bar {
      margin-top: 12px;
    }

    .level-track {
      display: flex;
      align-items: center;
      flex-wrap: wrap;
      gap: 2px;
      margin-top: 10px;

      &__sep {
        font-size: 11px;
        color: #dcdfe6;
      }

      &__item {
        font-size: 11px;
        color: #c0c4cc;

        &.is-reached {
          color: #409eff;
        }

        &.is-current {
          padding: 0 6px;
          font-weight: 600;
          color: #fff;
          background: #409eff;
          border-radius: 8px;
        }
      }
    }
  }

  /* ③ 引导入口 */
  .guide-card {
    margin-bottom: 20px;

    :deep(.el-card__body) {
      padding: 16px 24px;
    }

    .guide-inner {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 16px;
    }

    .guide-left {
      display: flex;
      align-items: center;
      gap: 14px;
      min-width: 0;
    }

    .guide-icon {
      color: #409eff;
      flex-shrink: 0;
    }

    .guide-title {
      font-size: 15px;
      font-weight: 600;
      color: #303133;
    }

    .guide-desc {
      margin-top: 4px;
      font-size: 13px;
      color: #909399;
    }
  }

  /* ④ 快速开始 */
  .section-card {
    margin-bottom: 20px;

    .quick-item {
      display: flex;
      align-items: center;
      gap: 16px;
      padding: 18px 20px;
      cursor: pointer;
      border: 1px solid #ebeef5;
      border-radius: 6px;
      transition: all 0.2s;

      &:hover {
        border-color: #409eff;
        box-shadow: 0 2px 12px rgba(64, 158, 255, 0.18);
      }

      &__icon {
        flex-shrink: 0;
        color: #409eff;
      }

      &__text {
        flex: 1;
        min-width: 0;
      }

      &__title {
        font-size: 16px;
        font-weight: 600;
        color: #303133;
      }

      &__desc {
        margin-top: 6px;
        font-size: 13px;
        color: #909399;
      }

      &__arrow {
        flex-shrink: 0;
        color: #c0c4cc;
      }

      &--primary {
        background: #f2f8ff;
        border-color: #b3d8ff;
      }

      &.is-disabled {
        cursor: not-allowed;
        background: #fafafa;

        &:hover {
          border-color: #ebeef5;
          box-shadow: none;
        }

        .quick-item__icon,
        .quick-item__arrow {
          color: #c0c4cc;
        }

        .quick-item__title {
          color: #909399;
        }
      }
    }
  }

  /* ⑤ 个性化推荐 */
  .recommend-row {
    margin-bottom: 20px;

    .el-col {
      margin-bottom: 20px;
    }
  }

  .rec-card {
    height: 100%;
    display: flex;
    flex-direction: column;

    :deep(.el-card__body) {
      flex: 1;
      display: flex;
      flex-direction: column;
    }

    .rec-block {
      margin-bottom: 16px;

      &__label {
        margin-bottom: 8px;
        font-size: 13px;
        font-weight: 600;
        color: #606266;
      }

      &__hint {
        margin-left: 6px;
        font-weight: 400;
        color: #c0c4cc;
      }
    }

    .rec-target {
      display: flex;
      align-items: center;
      gap: 8px;

      &__name {
        font-size: 15px;
        font-weight: 600;
        color: #303133;
      }

      &__meta {
        margin-top: 6px;
        font-size: 12px;
        color: #909399;
      }
    }

    .rec-tags {
      display: flex;
      flex-wrap: wrap;
      gap: 8px;
    }

    .rec-tag {
      margin: 0;
    }

    .rec-empty {
      font-size: 13px;
      line-height: 1.7;
      color: #909399;
    }

    .rec-btn {
      width: 100%;
      margin-top: auto;
    }

    .weak-head {
      display: flex;
      align-items: baseline;
      justify-content: space-between;
      gap: 8px;

      &__name {
        font-size: 15px;
        font-weight: 600;
        color: #e6a23c;
      }

      &__score {
        font-size: 14px;
        font-weight: 600;
        color: #303133;
      }

      &__meta {
        margin-top: 6px;
        font-size: 12px;
        color: #909399;
      }
    }

    .rec-list {
      margin: 0;
      padding-left: 18px;

      li {
        margin-bottom: 8px;
        font-size: 13px;
        line-height: 1.6;
        color: #606266;
        cursor: pointer;

        &:hover {
          color: #409eff;
        }
      }
    }

    .hot-list {
      display: flex;
      flex-direction: column;
      gap: 12px;
    }

    .hot-item {
      padding-bottom: 12px;
      cursor: pointer;
      border-bottom: 1px dashed #ebeef5;

      &:last-child {
        padding-bottom: 0;
        border-bottom: none;
      }

      &__title {
        font-size: 13px;
        line-height: 1.6;
        color: #303133;
        display: -webkit-box;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
        overflow: hidden;
      }

      &:hover &__title {
        color: #409eff;
      }

      &__meta {
        display: flex;
        align-items: center;
        gap: 6px;
        margin-top: 6px;
      }

      &__count {
        font-size: 12px;
        color: #c0c4cc;
      }
    }
  }

  /* ⑥ 最近报告 */
  .recent-card {
    .card-header {
      display: flex;
      align-items: center;
      justify-content: space-between;
    }

    .score-block {
      text-align: center;
      padding: 8px 0;

      &__value {
        font-size: 46px;
        font-weight: 600;
        line-height: 1.1;
        color: #409eff;
      }

      &__label {
        margin-top: 6px;
        font-size: 14px;
        color: #606266;
      }

      &__meta {
        margin-top: 4px;
        font-size: 12px;
        color: #909399;
      }

      &__btn {
        margin-top: 12px;
      }
    }

    .radar-thumb {
      width: 100%;
      height: 220px;
    }

    .report-summary {
      margin-top: 16px;
      padding: 12px 16px;
      background: #f5f7fa;
      border-radius: 4px;

      &__label {
        font-size: 13px;
        font-weight: 600;
        color: #606266;
      }

      &__text {
        margin: 6px 0 0;
        font-size: 13px;
        line-height: 1.8;
        color: #606266;
        white-space: pre-wrap;
      }
    }
  }

  /* 通用卡片头 */
  .card-header {
    display: flex;
    align-items: center;
    justify-content: space-between;

    &__title {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      font-size: 14px;
      font-weight: 600;
      color: #303133;
    }

    &__hint {
      font-size: 12px;
      color: #c0c4cc;
    }
  }
}
</style>
