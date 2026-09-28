<template>
  <div class="guide-page">
    <div class="guide-shell">
      <!-- 顶部：品牌 + 跳过引导 -->
      <div class="guide-top">
        <div class="guide-brand">
          <svg-icon icon-class="guide" class="brand-icon" />
          <span class="brand-name">面立方</span>
          <el-tag size="small" type="info" effect="plain">新手引导</el-tag>
        </div>
        <el-button text @click="handleSkip">跳过引导</el-button>
      </div>

      <!-- 管理 / 后台端身份：只预览，不写库 -->
      <el-alert
        v-if="canViewAll"
        class="preview-alert"
        type="warning"
        :closable="false"
        show-icon
        title="当前账号带「查看全部数据」权限（超管 / 后台端），引导流程仅作预览，不会读写任何学生数据。"
      />

      <!-- 引导进度：步骤指示 -->
      <el-steps :active="stepIndex" align-center finish-status="success" class="guide-steps">
        <el-step v-for="s in STEPS" :key="s.key" :title="s.title" :description="s.desc" />
      </el-steps>

      <!-- 步骤内容 -->
      <div class="guide-body">
        <!-- ① 欢迎引导：欢迎页 + 引导轮播 -->
        <div v-if="current === 'welcome'" class="step-welcome">
          <h1 class="welcome-title">欢迎来到面立方 👋</h1>
          <p class="welcome-sub">用 1 分钟完成引导，让 AI 更懂你的目标岗位。</p>
          <el-carousel height="168px" :interval="4500" arrow="hover" indicator-position="outside">
            <el-carousel-item v-for="slide in SLIDES" :key="slide.title">
              <div class="slide">
                <el-icon :size="30" class="slide-icon"><component :is="slide.icon" /></el-icon>
                <h3 class="slide-title">{{ slide.title }}</h3>
                <p class="slide-desc">{{ slide.desc }}</p>
              </div>
            </el-carousel-item>
          </el-carousel>
        </div>

        <!-- ② 岗位画像：行业选择 / 岗位选择 / 难度选择 -->
        <div v-else-if="current === 'job'" class="step-panel">
          <el-form ref="jobFormRef" :model="form" :rules="jobRules" label-width="96px" class="step-form">
            <el-form-item label="行业" prop="industry">
              <el-select v-model="form.industry" placeholder="请选择行业" clearable style="width: 100%">
                <el-option
                  v-for="d in student_industry"
                  :key="d.value"
                  :label="d.label"
                  :value="d.value"
                />
              </el-select>
            </el-form-item>
            <el-form-item label="目标岗位" prop="jobName">
              <el-input
                v-model="form.jobName"
                placeholder="如：Java 后端开发、产品经理"
                maxlength="100"
                show-word-limit
              />
              <div class="quick-pick">
                <span class="quick-label">快速选择：</span>
                <el-tag
                  v-for="name in JOB_SUGGESTIONS"
                  :key="name"
                  class="quick-tag"
                  :type="form.jobName === name ? 'primary' : 'info'"
                  effect="plain"
                  @click="form.jobName = name"
                >{{ name }}</el-tag>
              </div>
            </el-form-item>
            <el-form-item label="面试难度" prop="difficulty">
              <el-radio-group v-model="form.difficulty">
                <el-radio-button
                  v-for="d in student_difficulty"
                  :key="d.value"
                  :value="d.value"
                >{{ d.label }}</el-radio-button>
              </el-radio-group>
            </el-form-item>
          </el-form>
        </div>

        <!-- ③ 简历上传：简历导入 -->
        <div v-else-if="current === 'resume'" class="step-panel">
          <el-alert
            class="step-alert"
            type="info"
            :closable="false"
            show-icon
            title="上传一份简历，AI 会围绕你的真实经历生成更有针对性的问题。"
          />
          <el-form label-width="96px" class="step-form">
            <el-form-item label="简历名称">
              <el-input
                v-model="resume.resumeName"
                placeholder="不填则自动取文件名"
                maxlength="100"
                show-word-limit
              />
            </el-form-item>
            <el-form-item label="简历文件">
              <file-upload
                v-model="resume.fileUrl"
                :limit="1"
                :fileSize="10"
                :fileType="['pdf', 'doc', 'docx']"
              />
            </el-form-item>
            <el-form-item label="解析状态">
              <el-tag :type="resume.fileUrl ? 'success' : 'info'" effect="plain">
                {{ resume.fileUrl ? '文件已上传，等待系统解析' : '尚未上传简历' }}
              </el-tag>
              <span class="step-hint">简历解析能力将在后续版本开放，当前仅保存文件，可先跳过。</span>
            </el-form-item>
          </el-form>
          <div class="step-extra">
            <el-button text type="primary" @click="goResumeModule">先去「我的简历」看看</el-button>
          </div>
        </div>

        <!-- ④ 目标企业：企业类型选择 -->
        <div v-else-if="current === 'company'" class="step-panel">
          <el-alert
            class="step-alert"
            type="info"
            :closable="false"
            show-icon
            title="选择你倾向的企业类型，AI 会据此调整问题的考察侧重点。"
          />
          <el-radio-group v-model="form.companyType" class="company-group">
            <el-radio
              v-for="d in student_company_type"
              :key="d.value"
              :value="d.value"
              border
              class="company-item"
            >{{ d.label }}</el-radio>
          </el-radio-group>
        </div>

        <!-- ⑤ 引导完成：进入首页 + 引导后推荐 -->
        <div v-else class="step-done">
          <el-icon :size="54" class="done-icon"><CircleCheckFilled /></el-icon>
          <h2 class="done-title">引导完成，开始你的第一场模拟面试吧</h2>

          <el-descriptions :column="2" border class="done-summary">
            <el-descriptions-item label="行业">{{ dictLabel(student_industry, form.industry) }}</el-descriptions-item>
            <el-descriptions-item label="目标岗位">{{ form.jobName || '-' }}</el-descriptions-item>
            <el-descriptions-item label="面试难度">{{ dictLabel(student_difficulty, form.difficulty) }}</el-descriptions-item>
            <el-descriptions-item label="目标企业">{{ dictLabel(student_company_type, form.companyType) }}</el-descriptions-item>
            <el-descriptions-item label="简历" :span="2">
              {{ resume.fileUrl ? (resume.resumeName || '已上传') : '未上传' }}
            </el-descriptions-item>
          </el-descriptions>

          <el-divider content-position="left">引导后推荐</el-divider>

          <el-row :gutter="16">
            <el-col :xs="24" :md="12">
              <div class="reco-card">
                <div class="reco-title">
                  <el-icon><Briefcase /></el-icon>
                  <span>推荐岗位</span>
                </div>
                <div v-if="recommendJobs.length" class="reco-tags">
                  <el-tag
                    v-for="j in recommendJobs"
                    :key="j"
                    class="reco-tag"
                    effect="plain"
                    @click="goInterview"
                  >{{ j }}</el-tag>
                </div>
                <div v-else class="reco-empty">{{ form.jobName || '先完成岗位画像，才有推荐' }}</div>
              </div>
            </el-col>
            <el-col :xs="24" :md="12">
              <div class="reco-card">
                <div class="reco-title">
                  <el-icon><Notebook /></el-icon>
                  <span>推荐练习</span>
                </div>
                <ul v-if="recommendQuestions.length" class="reco-list">
                  <li v-for="q in recommendQuestions" :key="q.id" @click="goBank">
                    <span class="reco-q">{{ q.questionContent }}</span>
                    <el-tag size="small" effect="plain">{{ dictLabel(student_difficulty, q.difficulty) }}</el-tag>
                  </li>
                </ul>
                <div v-else class="reco-empty">暂无匹配的练习题，可去题库自己挑</div>
              </div>
            </el-col>
          </el-row>
        </div>
      </div>

      <!-- 底部：引导进度 + 返回上一步 -->
      <div class="guide-bottom">
        <span class="guide-progress">第 {{ stepIndex + 1 }} / {{ STEPS.length }} 步</span>
        <div class="guide-actions">
          <el-button v-if="canPrev" :disabled="saving" @click="handlePrev">返回上一步</el-button>
          <el-button v-if="!isLast" type="primary" :loading="saving" @click="handleNext">下一步</el-button>
          <el-button v-else type="primary" :loading="saving" @click="handleFinish">完成引导，进入首页</el-button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup name="StudentGuide">
import { listProfile, addProfile, finishGuide } from "@/api/interview/profile"
import { listJobprofile, addJobprofile, updateJobprofile } from "@/api/interview/jobprofile"
import { listResume, addResume, updateResume } from "@/api/interview/resume"
import { listBank } from "@/api/interview/bank"
import { checkPermi } from "@/utils/permission"
import useUserStore from "@/store/modules/user"

const { proxy } = getCurrentInstance()
const router = useRouter()
const userStore = useUserStore()

/**
 * 引导是**学生端**流程。带 interview:data:all 的身份（超管 / 后台端）走这里只做预览：
 * 不读也不写任何学生数据 —— 否则 list 返回的是「别人的档案」，一完成就会改错人。
 */
const canViewAll = computed(() => checkPermi(['interview:data:all']))
const { student_industry, student_difficulty, student_company_type } = useDict(
  'student_industry',
  'student_difficulty',
  'student_company_type'
)

/** 本机标记：与首页共用同一组 key，跳过 / 完成之后不再自动弹出 */
const GUIDE_DONE_KEY = 'interview_guide_done'
const GUIDE_DISMISSED_KEY = 'interview_guide_dismissed'

/** 引导流程：欢迎引导 → 岗位画像 → 简历上传 → 目标企业 → 引导完成 */
const STEPS = [
  { key: 'welcome', title: '欢迎引导', desc: '认识面立方' },
  { key: 'job', title: '岗位画像', desc: '行业 / 岗位 / 难度' },
  { key: 'resume', title: '简历上传', desc: '导入简历文件' },
  { key: 'company', title: '目标企业', desc: '选择企业类型' },
  { key: 'done', title: '引导完成', desc: '进入首页' }
]

/** 欢迎页轮播：WEB 端用分步图文介绍 */
const SLIDES = [
  { icon: 'Aim', title: '建立岗位画像', desc: '选定行业、目标岗位与难度，AI 据此决定出题范围。' },
  { icon: 'Document', title: '上传你的简历', desc: '简历越具体，AI 的追问越贴近你的真实经历。' },
  { icon: 'TrendCharts', title: '面试 + 复盘闭环', desc: '每场面试都会生成复盘报告，短板一目了然。' }
]

/** 岗位名称是自由文本，给几个常见岗位降低填写成本 */
const JOB_SUGGESTIONS = ['Java 后端开发', '前端开发', '产品经理', '数据分析', '测试开发']

const stepIndex = ref(0)
const saving = ref(false)
const jobFormRef = ref()
const recommendJobs = ref([])
const recommendQuestions = ref([])

const form = reactive({
  industry: undefined,
  jobName: '',
  difficulty: undefined,
  companyType: undefined
})

const resume = reactive({
  resumeName: '',
  fileUrl: ''
})

const jobRules = {
  industry: [{ required: true, message: "请选择行业", trigger: "change" }],
  jobName: [{ required: true, message: "请填写目标岗位", trigger: "blur" }],
  difficulty: [{ required: true, message: "请选择面试难度", trigger: "change" }]
}

const current = computed(() => STEPS[stepIndex.value].key)
const isLast = computed(() => stepIndex.value === STEPS.length - 1)
const canPrev = computed(() => stepIndex.value > 0)

/** 字典值 → 文案。兼容传入 ref（script 里）与传入已解包的数组（模板里） */
function dictLabel(options, value) {
  if (value === null || value === undefined || value === '') return '-'
  const list = options && options.value !== undefined ? options.value : options
  const hit = (list || []).find(d => String(d.value) === String(value))
  return hit ? hit.label : value
}

/** 从上传返回的地址里取文件名（去掉扩展名）作为简历名称 */
function fileNameFromUrl(url) {
  if (!url) return ''
  const base = String(url).split('?')[0].split('#')[0].split('/').pop() || ''
  const dot = base.lastIndexOf('.')
  const name = dot > 0 ? base.slice(0, dot) : base
  return name || '我的简历'
}

/**
 * 岗位画像 / 简历都是 1:N，引导只维护「默认那条」。
 * 后端 list 支持 is_default 过滤，这里一次多取几行在前端挑，省一次往返。
 */
function pickDefault(rows) {
  const list = rows || []
  return list.find(r => r.isDefault === '1') || list[0] || null
}

/** ② 校验岗位画像 */
function validateJobStep() {
  return new Promise(resolve => {
    jobFormRef.value.validate(valid => resolve(!!valid))
  })
}

/** ③ 保存简历：已有默认记录则更新，否则新增（学生端简历可多条，引导只维护默认那条） */
function saveResumeStep() {
  if (!resume.fileUrl) return Promise.resolve(true)
  // 管理 / 后台端身份只预览，不写学生数据
  if (canViewAll.value) return Promise.resolve(true)
  saving.value = true
  return listResume({ pageNum: 1, pageSize: 20 }).then(res => {
    const exist = pickDefault(res.rows)
    const payload = {
      resumeName: resume.resumeName || fileNameFromUrl(resume.fileUrl),
      fileUrl: resume.fileUrl,
      sourceType: '1',
      isDefault: '1'
    }
    return exist ? updateResume({ ...payload, id: exist.id }) : addResume(payload)
  }).then(() => {
    proxy.$modal.msgSuccess("简历已保存")
    return true
  }).catch(() => false).finally(() => {
    saving.value = false
  })
}

/** ④ 保存岗位画像 + 目标企业类型（两者同属 student_job_profile，统一在此落库） */
function saveCompanyStep() {
  // 管理 / 后台端身份只预览，不写学生数据
  if (canViewAll.value) return Promise.resolve(true)
  saving.value = true
  const payload = {
    jobName: form.jobName,
    industry: form.industry,
    difficulty: form.difficulty,
    companyType: form.companyType,
    isDefault: '1'
  }
  return listJobprofile({ pageNum: 1, pageSize: 20 }).then(res => {
    const exist = pickDefault(res.rows)
    return exist ? updateJobprofile({ ...payload, id: exist.id }) : addJobprofile(payload)
  }).then(() => {
    proxy.$modal.msgSuccess("岗位画像已保存")
    loadRecommend()
    return true
  }).catch(() => false).finally(() => {
    saving.value = false
  })
}

/** 引导后推荐：一次查询同时产出「推荐岗位」与「推荐练习」 */
function loadRecommend() {
  const query = { pageNum: 1, pageSize: 20 }
  if (form.industry) query.industry = form.industry
  if (form.difficulty) query.difficulty = form.difficulty
  listBank(query).then(res => {
    const rows = res.rows || []
    // 行业 + 难度组合没有题时，放宽为仅按行业筛选
    if (!rows.length && form.industry) {
      return listBank({ pageNum: 1, pageSize: 20, industry: form.industry }).then(r2 => r2.rows || [])
    }
    return rows
  }).then(rows => {
    const list = rows || []
    recommendQuestions.value = list.slice(0, 3)
    recommendJobs.value = [...new Set(list.map(r => r.jobName).filter(Boolean))].slice(0, 3)
  }).catch(() => {})
}

/** 档案与账号 1:1：没有档案就先建一条，返回档案 id */
function ensureProfile() {
  return listProfile({ pageNum: 1, pageSize: 1 }).then(res => {
    const exist = (res.rows || [])[0]
    if (exist) return exist.id
    return addProfile({
      nickname: userStore.nickName || userStore.name || '同学',
      avatar: userStore.avatar || ''
    }).then(() => listProfile({ pageNum: 1, pageSize: 1 })).then(r2 => {
      const created = (r2.rows || [])[0]
      return created ? created.id : null
    })
  })
}

/** 下一步：先校验/落库当前步骤，成功再前进 */
function handleNext() {
  const tasks = {
    job: validateJobStep,
    resume: saveResumeStep,
    company: saveCompanyStep
  }
  const task = tasks[current.value]
  const run = task || (() => Promise.resolve(true))
  run().then(ok => {
    if (ok !== false) stepIndex.value++
  })
}

/** 返回上一步：回退修改已填内容，不回滚已落库数据 */
function handlePrev() {
  if (canPrev.value) stepIndex.value--
}

/** 完成引导：写入 guide_status 后回首页 */
function handleFinish() {
  // 管理 / 后台端身份只预览：不建档案、不写引导状态，直接回首页
  if (canViewAll.value) {
    proxy.$modal.msgSuccess("引导预览完成（当前身份不写入学生数据）")
    router.push('/index')
    return
  }
  saving.value = true
  ensureProfile().then(profileId => {
    if (!profileId) {
      proxy.$modal.msgError("学生档案创建失败，请稍后重试")
      return false
    }
    return finishGuide(profileId)
  }).then(ok => {
    if (ok === false) return
    localStorage.setItem(GUIDE_DONE_KEY, '1')
    localStorage.removeItem(GUIDE_DISMISSED_KEY)
    proxy.$modal.msgSuccess("引导完成，祝你面试顺利！")
    router.push('/index')
  }).catch(() => {}).finally(() => {
    saving.value = false
  })
}

/** 跳过引导：只记录本机不再自动弹出，首页仍保留入口 */
function handleSkip() {
  proxy.$modal.confirm("跳过引导后不再自动弹出，你随时可以从首页重新进入。确定跳过吗？")
    .then(() => {
      localStorage.setItem(GUIDE_DISMISSED_KEY, '1')
      router.push('/index')
    }).catch(() => {})
}

function goInterview() {
  router.push('/student/session')
}

function goBank() {
  router.push('/student/bank')
}

function goResumeModule() {
  router.push('/student/resume')
}

/** 回填已有数据，避免重复填写（管理 / 后台端身份不回填，免得把某个学生的数据读进来） */
function loadExisting() {
  if (canViewAll.value) return
  listJobprofile({ pageNum: 1, pageSize: 20 }).then(res => {
    const row = pickDefault(res.rows)
    if (!row) return
    form.industry = row.industry || form.industry
    form.jobName = row.jobName || form.jobName
    form.difficulty = row.difficulty || form.difficulty
    form.companyType = row.companyType || form.companyType
  }).catch(() => {})
  listResume({ pageNum: 1, pageSize: 20 }).then(res => {
    const row = pickDefault(res.rows)
    if (!row) return
    resume.resumeName = row.resumeName || resume.resumeName
    resume.fileUrl = row.fileUrl || resume.fileUrl
  }).catch(() => {})
}

/** 上传成功后自动用文件名填简历名称 */
watch(() => resume.fileUrl, url => {
  if (url && !resume.resumeName) {
    resume.resumeName = fileNameFromUrl(url)
  }
})

loadExisting()
</script>

<style scoped lang="scss">
.guide-page {
  min-height: 100vh;
  padding: 24px 16px 40px;
  box-sizing: border-box;
  background: #f5f7fa;
}

.guide-shell {
  max-width: 880px;
  margin: 0 auto;
  padding: 20px 28px 24px;
  background: #fff;
  border-radius: 10px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);
}

.guide-top {
  display: flex;
  align-items: center;
  justify-content: space-between;

  .guide-brand {
    display: flex;
    align-items: center;
    gap: 8px;

    .brand-icon {
      font-size: 22px;
      color: #409eff;
    }

    .brand-name {
      font-size: 17px;
      font-weight: 600;
      color: #303133;
    }
  }
}

.preview-alert {
  margin-top: 16px;
}

.guide-steps {
  margin: 26px 0 8px;

  :deep(.el-step__title) {
    font-size: 13px;
  }

  :deep(.el-step__description) {
    font-size: 12px;
  }
}

.guide-body {
  min-height: 320px;
  padding: 20px 4px 8px;
}

/* ① 欢迎引导 */
.step-welcome {
  text-align: center;

  .welcome-title {
    margin: 8px 0 6px;
    font-size: 22px;
    color: #303133;
  }

  .welcome-sub {
    margin: 0 0 18px;
    font-size: 13px;
    color: #909399;
  }

  .slide {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    height: 100%;
    padding: 0 32px;
    box-sizing: border-box;
    border-radius: 8px;
    background: linear-gradient(135deg, #ecf5ff 0%, #f0f9eb 100%);

    .slide-icon {
      color: #409eff;
    }

    .slide-title {
      margin: 10px 0 6px;
      font-size: 16px;
      color: #303133;
    }

    .slide-desc {
      margin: 0;
      font-size: 13px;
      line-height: 1.6;
      color: #606266;
    }
  }
}

/* ②③④ 表单步骤 */
.step-panel {
  max-width: 560px;
  margin: 0 auto;

  .step-alert {
    margin-bottom: 18px;
  }

  .step-form {
    .quick-pick {
      margin-top: 8px;
      line-height: 26px;

      .quick-label {
        font-size: 12px;
        color: #909399;
      }

      .quick-tag {
        margin: 0 6px 4px 0;
        cursor: pointer;
      }
    }

    .step-hint {
      margin-left: 10px;
      font-size: 12px;
      color: #909399;
    }
  }

  .step-extra {
    text-align: center;
  }
}

.company-group {
  display: block;

  .company-item {
    width: 100%;
    margin: 0 0 10px 0;
  }
}

/* ⑤ 引导完成 */
.step-done {
  text-align: center;

  .done-icon {
    color: #67c23a;
  }

  .done-title {
    margin: 12px 0 20px;
    font-size: 18px;
    color: #303133;
  }

  .done-summary {
    text-align: left;
  }

  .reco-card {
    padding: 14px 16px;
    border: 1px solid #ebeef5;
    border-radius: 8px;
    text-align: left;

    .reco-title {
      display: flex;
      align-items: center;
      gap: 6px;
      margin-bottom: 10px;
      font-size: 14px;
      font-weight: 600;
      color: #303133;
    }

    .reco-tags {
      .reco-tag {
        margin: 0 8px 8px 0;
        cursor: pointer;
      }
    }

    .reco-list {
      margin: 0;
      padding: 0;
      list-style: none;

      li {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 10px;
        padding: 6px 0;
        cursor: pointer;
        border-bottom: 1px dashed #ebeef5;

        &:last-child {
          border-bottom: none;
        }

        .reco-q {
          flex: 1;
          overflow: hidden;
          font-size: 13px;
          color: #606266;
          text-overflow: ellipsis;
          white-space: nowrap;
        }
      }
    }

    .reco-empty {
      font-size: 13px;
      color: #909399;
    }
  }
}

/* 底部：引导进度 + 操作 */
.guide-bottom {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding-top: 16px;
  border-top: 1px solid #ebeef5;

  .guide-progress {
    font-size: 13px;
    color: #909399;
  }
}
</style>
