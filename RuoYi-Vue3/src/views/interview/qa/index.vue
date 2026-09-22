<template>
  <div class="app-container">
    <!-- 没带 sessionId：空态 + 场次下拉 -->
    <el-card v-if="!sessionId" shadow="never" class="picker-card">
      <el-empty description="请先从「模拟面试场次」选择一场面试">
        <div class="picker-actions">
          <el-select
            v-model="pickedSessionId"
            placeholder="选择一场面试"
            style="width: 360px"
            :loading="sessionLoading"
          >
            <el-option
              v-for="item in sessionOptions"
              :key="item.id"
              :label="sessionOptionLabel(item)"
              :value="item.id"
            />
          </el-select>
          <el-button type="primary" icon="VideoPlay" @click="goSessionList">去场次列表</el-button>
        </div>
      </el-empty>
    </el-card>

    <!-- 带了 sessionId：场次信息条 + 逐题作答 / 只读回顾 -->
    <div v-else v-loading="loading">
      <el-card shadow="never" class="session-bar">
        <div class="session-bar__main">
          <span class="session-bar__no">{{ sessionInfo.sessionNo }}</span>
          <el-tag v-if="sessionInfo.jobName" size="small" type="info">{{ sessionInfo.jobName }}</el-tag>
          <dict-tag :options="interview_session_status" :value="sessionInfo.status" />
          <span class="session-bar__progress">
            进度 {{ sessionInfo.answeredCount || 0 }} / {{ sessionInfo.totalCount || 0 }}
          </span>
          <span class="session-bar__meta">
            {{ readonly ? '本场用时 ' + formatDuration(sessionInfo.duration) : '本题已用 ' + formatClock(elapsed) }}
          </span>
        </div>
        <div class="session-bar__actions">
          <el-button link type="primary" icon="Back" @click="goSessionList">返回场次列表</el-button>
          <el-button
            link
            type="primary"
            icon="Download"
            @click="handleExport"
            v-hasPermi="['interview:qa:export']"
          >导出</el-button>
          <el-button
            v-if="!readonly"
            link
            type="danger"
            icon="CircleClose"
            :loading="aborting"
            @click="handleAbort"
          >提前结束</el-button>
        </div>
      </el-card>

      <el-empty v-if="!questionList.length" description="本场还没有题目" />

      <el-row v-else :gutter="16">
        <!-- 左：题号导航（已答 / 未答 / 当前） -->
        <el-col :xs="24" :sm="7" :md="5">
          <el-card shadow="never" class="nav-card">
            <div class="nav-title">题目导航</div>
            <div class="nav-grid">
              <el-button
                v-for="(item, index) in questionList"
                :key="item.id"
                class="nav-cell"
                :class="navClass(item, index)"
                @click="goTo(index)"
              >{{ item.questionNo }}</el-button>
            </div>
            <div class="nav-legend">
              <span><i class="dot dot--done"></i>已答</span>
              <span><i class="dot dot--todo"></i>未答</span>
              <span><i class="dot dot--current"></i>当前</span>
            </div>
          </el-card>
        </el-col>

        <!-- 右：当前题 -->
        <el-col :xs="24" :sm="17" :md="19">
          <el-card shadow="never" class="question-card">
            <div class="question-head">
              <span class="question-no">第 {{ current.questionNo }} 题</span>
              <dict-tag :options="interview_question_type" :value="current.questionType" />
              <el-tag v-if="currentAnswer" type="success" size="small">已作答</el-tag>
              <el-tag v-else type="info" size="small">未作答</el-tag>
            </div>
            <div class="question-content">{{ current.questionContent }}</div>

            <!-- ===== 逐题作答模式（场次进行中） ===== -->
            <template v-if="!readonly">
              <el-input
                v-model="draft"
                type="textarea"
                :rows="10"
                maxlength="5000"
                show-word-limit
                placeholder="请在此填写作答内容；提交后本题的参考答案即可查看"
              />
              <div class="question-actions">
                <el-button :disabled="currentIndex === 0" @click="goTo(currentIndex - 1)">上一题</el-button>
                <el-button
                  v-if="!isLast"
                  type="primary"
                  :loading="submitting"
                  @click="handleSubmit(true)"
                >提交并下一题</el-button>
                <el-button
                  v-else
                  type="primary"
                  :loading="submitting"
                  @click="handleSubmit(false)"
                >提交</el-button>
                <span class="question-tip">本题已用 {{ formatClock(elapsed) }}</span>
              </div>

              <!-- 决策 1：本题已作答 → 参考答案解锁 -->
              <div v-if="currentAnswer" class="block">
                <div class="block-title">参考答案（本题已作答，已解锁）</div>
                <div class="block-body multiline">{{ current.referenceAnswer || '—' }}</div>
                <ul v-if="keyPointList.length" class="key-point-list">
                  <li v-for="(point, index) in keyPointList" :key="index">{{ point }}</li>
                </ul>
              </div>
            </template>

            <!-- ===== 只读回顾模式（已完成 / 已中断） ===== -->
            <template v-else>
              <div class="block">
                <div class="block-title">我的作答</div>
                <div v-if="currentAnswer" class="block-body multiline">{{ currentAnswer.answerContent }}</div>
                <div v-else class="locked">本题没有作答</div>
              </div>
              <el-row v-if="currentAnswer" :gutter="20" class="mb8">
                <el-col :span="8">
                  <div class="info-item">
                    <label class="info-label">作答方式：</label>
                    <span class="info-value">
                      <dict-tag :options="interview_answer_type" :value="currentAnswer.answerType" />
                    </span>
                  </div>
                </el-col>
                <el-col :span="8">
                  <div class="info-item">
                    <label class="info-label">作答耗时：</label>
                    <span class="info-value plaintext">{{ formatDuration(currentAnswer.duration) }}</span>
                  </div>
                </el-col>
                <el-col :span="8">
                  <div class="info-item">
                    <label class="info-label">本题得分：</label>
                    <span class="info-value plaintext">
                      {{ currentAnswer.score == null ? '待评分' : currentAnswer.score }}
                    </span>
                  </div>
                </el-col>
              </el-row>
              <div class="block">
                <div class="block-title">参考答案</div>
                <template v-if="canReveal">
                  <div class="block-body multiline">{{ current.referenceAnswer || '—' }}</div>
                  <ul v-if="keyPointList.length" class="key-point-list">
                    <li v-for="(point, index) in keyPointList" :key="index">{{ point }}</li>
                  </ul>
                </template>
                <div v-else class="locked">提交本题的作答后即可查看参考答案</div>
              </div>
              <div class="question-actions">
                <el-button :disabled="currentIndex === 0" @click="goTo(currentIndex - 1)">上一题</el-button>
                <el-button :disabled="isLast" @click="goTo(currentIndex + 1)">下一题</el-button>
              </div>
            </template>
          </el-card>
        </el-col>
      </el-row>
    </div>
  </div>
</template>

<script setup name="Qa">
import { listQa, submitQa } from "@/api/interview/qa"
import { listQuestion } from "@/api/interview/question"
import { listSession, getSession, abortSession } from "@/api/interview/session"

const { proxy } = getCurrentInstance()
const route = useRoute()
const router = useRouter()
const {
  interview_session_status,
  interview_question_type,
  interview_answer_type
} = useDict(
  'interview_session_status',
  'interview_question_type',
  'interview_answer_type'
)

/** 单场最多 20 道题，一次取完，不需要分页 */
const PAGE_ALL = { pageNum: 1, pageSize: 100 }

/** 阶段一只做文字作答 */
const ANSWER_TYPE_TEXT = '1'

/** 路由参数里的场次 ID，是本页唯一的入口条件 */
const sessionId = computed(() => route.query.sessionId)

const loading = ref(false)
const submitting = ref(false)
const aborting = ref(false)
const sessionLoading = ref(false)
const sessionOptions = ref([])
const sessionInfo = ref({})
const questionList = ref([])
/** 该场已提交的作答，按 questionId 索引 */
const qaMap = ref({})
const pickedSessionId = ref(undefined)
const currentIndex = ref(0)
/** 当前题的作答草稿 */
const draft = ref('')
/** 当前题已用秒数 */
const elapsed = ref(0)

let timer = null
let enteredAt = 0

const current = computed(() => questionList.value[currentIndex.value] || {})
const currentAnswer = computed(() => qaMap.value[current.value.id] || null)
const isLast = computed(() => currentIndex.value >= questionList.value.length - 1)
/** 已完成 / 已中断 → 只读回顾模式 */
const readonly = computed(() => ['2', '3'].includes(sessionInfo.value.status))
/** 决策 1：场次已完成，或本题已有作答 → 参考答案可见 */
const canReveal = computed(() => sessionInfo.value.status === '2' || !!currentAnswer.value)
const keyPointList = computed(() => resolveKeyPoints(current.value.keyPoints))

/** 字典翻译，取不到时原样返回 */
function dictLabel(options, value) {
  const hit = options.value.find(dict => dict.value === value)
  return hit ? hit.label : value
}

/** 场次下拉的展示文案：场次编号 · 岗位名 · 状态 */
function sessionOptionLabel(item) {
  return [
    item.sessionNo,
    item.jobName,
    dictLabel(interview_session_status, item.status)
  ].filter(text => text).join(' · ')
}

/** 作答耗时（秒）转成「X 分 Y 秒」 */
function formatDuration(seconds) {
  if (!seconds) {
    return '—'
  }
  const minutes = Math.floor(seconds / 60)
  const rest = seconds % 60
  if (!minutes) {
    return rest + ' 秒'
  }
  return minutes + ' 分 ' + rest + ' 秒'
}

/** 秒数转 mm:ss，用于本题计时 */
function formatClock(seconds) {
  const total = seconds || 0
  const minutes = String(Math.floor(total / 60)).padStart(2, '0')
  const rest = String(total % 60).padStart(2, '0')
  return minutes + ':' + rest
}

/** 关键要点存的是 JSON 数组，解析成列表渲染；解析不了就按单行纯文本兜底 */
function resolveKeyPoints(raw) {
  if (!raw) return []
  try {
    const arr = JSON.parse(raw)
    return Array.isArray(arr) ? arr.map(item => String(item)) : [String(raw)]
  } catch (e) {
    return [String(raw)]
  }
}

/** 题号导航的样式：已答 / 当前 */
function navClass(item, index) {
  return {
    'nav-cell--done': !!qaMap.value[item.id],
    'nav-cell--current': index === currentIndex.value
  }
}

/** 停掉本题计时 */
function stopTimer() {
  if (timer) {
    clearInterval(timer)
    timer = null
  }
}

/** 本题计时：切题时归零重计（只读模式不计时） */
function startTimer() {
  stopTimer()
  enteredAt = Date.now()
  elapsed.value = 0
  timer = setInterval(() => {
    elapsed.value = Math.floor((Date.now() - enteredAt) / 1000)
  }, 1000)
}

/** 切题：同步草稿 + 重置计时 */
function goTo(index) {
  if (index < 0 || index >= questionList.value.length) {
    return
  }
  currentIndex.value = index
  draft.value = currentAnswer.value ? (currentAnswer.value.answerContent || '') : ''
  if (!readonly.value) {
    startTimer()
  }
}

/** 第一道还没作答的题，全答完了返回 -1 */
function firstUnansweredIndex() {
  return questionList.value.findIndex(item => !qaMap.value[item.id])
}

/** 拉取该场的场次信息 + 题目 + 作答记录 */
async function loadSessionData(id) {
  loading.value = true
  stopTimer()
  try {
    const [sessionRes, questionRes, qaRes] = await Promise.all([
      getSession(id),
      listQuestion({ ...PAGE_ALL, sessionId: id }),
      listQa({ ...PAGE_ALL, sessionId: id })
    ])
    sessionInfo.value = sessionRes.data || {}
    questionList.value = (questionRes.rows || [])
      .slice()
      .sort((a, b) => (a.questionNo || 0) - (b.questionNo || 0))
    const map = {}
    ;(qaRes.rows || []).forEach(qa => {
      // 追问（is_follow_up = 1）不占题号导航的位置
      if (qa.isFollowUp !== '1') {
        map[qa.questionId] = qa
      }
    })
    qaMap.value = map
    // 进行中的场次直接从第一道未答题开始，已完成的从第 1 题开始回顾
    const next = firstUnansweredIndex()
    goTo(next >= 0 ? next : 0)
  } catch (error) {
    // 场次不存在或不属于当前学生时，后端会直接报错，这里清空展示即可
    resetSessionData()
  } finally {
    loading.value = false
  }
}

/** 退出某个场次时把数据清空，避免串场 */
function resetSessionData() {
  stopTimer()
  sessionInfo.value = {}
  questionList.value = []
  qaMap.value = {}
  currentIndex.value = 0
  draft.value = ''
  elapsed.value = 0
}

/** 空态下的场次下拉数据 */
async function loadSessionOptions() {
  sessionLoading.value = true
  try {
    const res = await listSession({ ...PAGE_ALL })
    sessionOptions.value = res.rows || []
  } catch (error) {
    sessionOptions.value = []
  } finally {
    sessionLoading.value = false
  }
}

/** 提交当前题；advance = true 表示提交后直接进下一题 */
function handleSubmit(advance) {
  const content = (draft.value || '').trim()
  if (!content) {
    proxy.$modal.msgWarning('请先填写作答内容')
    return
  }
  submitting.value = true
  submitQa({
    sessionId: Number(sessionId.value),
    questionId: current.value.id,
    answerContent: content,
    answerType: ANSWER_TYPE_TEXT,
    duration: elapsed.value
  }).then(res => {
    qaMap.value = { ...qaMap.value, [current.value.id]: res.data || {} }
    if (res.session) {
      sessionInfo.value = res.session
    }
    // 最后一题答完，后端已把场次置为「已完成」
    if (readonly.value) {
      stopTimer()
      proxy.$modal.msgSuccess('本场面试已全部作答完成，可以去看复盘报告了')
      return
    }
    if (advance && !isLast.value) {
      goTo(currentIndex.value + 1)
      proxy.$modal.msgSuccess('已提交，进入下一题')
      return
    }
    // 最后一题提交后还有漏答的，直接跳到第一道未答题
    const next = firstUnansweredIndex()
    if (next >= 0) {
      goTo(next)
      proxy.$modal.msgWarning('已提交；本场还有未作答的题目')
    } else {
      goTo(currentIndex.value)
      proxy.$modal.msgSuccess('已提交')
    }
  }).finally(() => {
    submitting.value = false
  })
}

/** 提前结束本场面试（进行中 → 已中断） */
function handleAbort() {
  proxy.$modal.confirm('提前结束本场面试？已作答的题目会保留，但本场将标记为「已中断」，之后不能再继续作答。').then(() => {
    aborting.value = true
    return abortSession(sessionId.value)
  }).then(res => {
    sessionInfo.value = res.data || sessionInfo.value
    stopTimer()
    proxy.$modal.msgSuccess('本场面试已中断，可随时回顾题目与作答')
  }).catch(() => {}).finally(() => {
    aborting.value = false
  })
}

/** 回场次列表 */
function goSessionList() {
  router.push('/student/session')
}

/** 导出：只导当前这一场的作答 */
function handleExport() {
  proxy.download('interview/qa/export', {
    ...PAGE_ALL,
    sessionId: sessionId.value
  }, `qa_${sessionId.value}_${new Date().getTime()}.xlsx`)
}

/** 空态里选中场次后，把 sessionId 写进路由，本页据此加载 */
watch(pickedSessionId, (val) => {
  if (val) {
    router.replace({ path: '/student/qa', query: { sessionId: val } })
  }
})

/** sessionId 变化（直接带参进入、从场次列表下钻）时重新加载 */
watch(sessionId, (val) => {
  if (val) {
    loadSessionData(val)
  } else {
    resetSessionData()
    loadSessionOptions()
  }
}, { immediate: true })

onUnmounted(stopTimer)
</script>

<style lang="scss" scoped>
.picker-card {
  :deep(.el-card__body) {
    padding: 48px 20px;
  }
}

.picker-actions {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
}

.session-bar {
  margin-bottom: 12px;

  :deep(.el-card__body) {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 12px 16px;
  }

  .session-bar__main {
    display: flex;
    align-items: center;
    gap: 12px;
  }

  .session-bar__no {
    font-size: 14px;
    font-weight: 500;
    color: #303133;
  }

  .session-bar__progress,
  .session-bar__meta {
    font-size: 13px;
    color: #909399;
  }

  .session-bar__actions {
    flex-shrink: 0;
  }
}

.nav-card {
  :deep(.el-card__body) {
    padding: 12px;
  }

  .nav-title {
    margin-bottom: 10px;
    font-size: 13px;
    font-weight: 500;
    color: #303133;
  }

  .nav-grid {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
  }

  .nav-cell {
    width: 40px;
    height: 32px;
    margin: 0 !important;
    padding: 0;
    font-size: 13px;
  }

  .nav-cell--done {
    color: #67c23a;
    border-color: #b3e19d;
    background: #f0f9eb;
  }

  .nav-cell--current {
    color: #fff;
    border-color: #409eff;
    background: #409eff;
  }

  .nav-legend {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    margin-top: 12px;
    font-size: 12px;
    color: #909399;
  }

  .dot {
    display: inline-block;
    width: 8px;
    height: 8px;
    margin-right: 4px;
    border-radius: 50%;
  }

  .dot--done {
    background: #67c23a;
  }

  .dot--todo {
    background: #dcdfe6;
  }

  .dot--current {
    background: #409eff;
  }
}

.question-card {
  :deep(.el-card__body) {
    padding: 16px 20px 20px;
  }

  .question-head {
    display: flex;
    align-items: center;
    gap: 10px;
    margin-bottom: 10px;
  }

  .question-no {
    font-size: 14px;
    font-weight: 600;
    color: #303133;
  }

  .question-content {
    padding: 12px 14px;
    margin-bottom: 14px;
    font-size: 15px;
    line-height: 1.8;
    color: #303133;
    white-space: pre-wrap;
    word-break: break-word;
    background: #f8f9fb;
    border-radius: 6px;
  }

  .question-actions {
    display: flex;
    align-items: center;
    gap: 12px;
    margin-top: 14px;
  }

  .question-tip {
    font-size: 12px;
    color: #909399;
  }
}

.block {
  margin-top: 16px;
}

.block-title {
  margin-bottom: 6px;
  font-size: 13px;
  color: #606266;
}

.block-body {
  padding: 10px 12px;
  font-size: 13px;
  line-height: 1.8;
  color: #303133;
  background: #f8f9fb;
  border-radius: 6px;
}

.multiline {
  white-space: pre-wrap;
  word-break: break-word;
}

.key-point-list {
  margin: 8px 0 0;
  padding: 10px 12px 10px 30px;
  background: #f8f9fb;
  border-radius: 6px;

  li {
    font-size: 13px;
    line-height: 1.8;
    color: #303133;
  }
}

.locked {
  padding: 14px 12px;
  font-size: 13px;
  color: #909399;
  text-align: center;
  background: #f8f9fb;
  border: 1px dashed #dcdfe6;
  border-radius: 6px;
}

.info-item {
  margin-bottom: 8px;
  font-size: 13px;
  line-height: 1.8;
}

.info-label {
  color: #606266;
}

.info-value {
  color: #303133;
}

.plaintext {
  word-break: break-word;
}
</style>
