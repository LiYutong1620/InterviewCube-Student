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

    <!-- 带了 sessionId：场次信息条 + 该场的题目 -->
    <template v-else>
      <el-card shadow="never" class="session-bar">
        <div class="session-bar__main">
          <span class="session-bar__no">{{ sessionInfo.sessionNo }}</span>
          <el-tag v-if="sessionInfo.jobName" size="small" type="info">{{ sessionInfo.jobName }}</el-tag>
          <dict-tag :options="interview_session_status" :value="sessionInfo.status" />
          <span class="session-bar__progress">
            进度 {{ sessionInfo.answeredCount || 0 }} / {{ sessionInfo.totalCount || 0 }}
          </span>
        </div>
        <div class="session-bar__actions">
          <el-button link type="primary" icon="Back" @click="goSessionList">返回场次列表</el-button>
          <el-button
            link
            type="primary"
            icon="Download"
            @click="handleExport"
            v-hasPermi="['interview:question:export']"
          >导出</el-button>
        </div>
      </el-card>

      <el-alert
        v-if="!revealAll"
        class="mb8"
        type="info"
        show-icon
        :closable="false"
        title="本场面试完成后才能查看参考答案"
      />

      <el-table v-loading="loading" :data="questionList">
        <el-table-column label="题号" align="center" width="70" prop="questionNo" />
        <el-table-column label="题型" align="center" width="110">
          <template #default="scope">
            <dict-tag :options="interview_question_type" :value="scope.row.questionType" />
          </template>
        </el-table-column>
        <el-table-column label="题干" align="left" prop="questionContent" :show-overflow-tooltip="true" />
        <el-table-column label="来源" align="center" width="110">
          <template #default="scope">
            <dict-tag :options="interview_question_source" :value="scope.row.source" />
          </template>
        </el-table-column>
        <el-table-column label="我的作答" align="center" width="100">
          <template #default="scope">
            <el-tag v-if="hasAnswer(scope.row)" type="success" size="small">已作答</el-tag>
            <el-tag v-else type="info" size="small">未作答</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" align="center" width="90" class-name="small-padding fixed-width">
          <template #default="scope">
            <el-button link type="primary" icon="View" @click="handleView(scope.row)">查看</el-button>
          </template>
        </el-table-column>
      </el-table>
    </template>

    <!-- 面试题目详情抽屉 -->
    <question-view-drawer
      ref="questionViewRef"
      :qa-map="qaMap"
      :session-status="sessionInfo.status"
    />
  </div>
</template>

<script setup name="Question">
import { listQuestion } from "@/api/interview/question"
import { listQa } from "@/api/interview/qa"
import { listSession, getSession } from "@/api/interview/session"
import QuestionViewDrawer from "./view"

const { proxy } = getCurrentInstance()
const route = useRoute()
const router = useRouter()
const {
  interview_question_type,
  interview_question_source,
  interview_session_status
} = useDict(
  'interview_question_type',
  'interview_question_source',
  'interview_session_status'
)

/** 该场的题目一次性取完（单场最多 20 道，不需要分页） */
const PAGE_ALL = { pageNum: 1, pageSize: 100 }

/** 路由参数里的场次 ID，是本页唯一的入口条件 */
const sessionId = computed(() => route.query.sessionId)

const loading = ref(false)
const sessionLoading = ref(false)
const sessionOptions = ref([])
const sessionInfo = ref({})
const questionList = ref([])
/** 该场已提交的作答，按 questionId 索引，用于「已作答/未作答」与参考答案门控 */
const qaMap = ref({})
const pickedSessionId = ref(undefined)

/** 场次已完成：整场的参考答案都可见 */
const revealAll = computed(() => sessionInfo.value.status === '2')

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

/** 该题是否已作答 */
function hasAnswer(row) {
  return !!qaMap.value[row.id]
}

/** 拉取该场的场次信息 + 题目 + 作答记录 */
async function loadSessionData(id) {
  loading.value = true
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
      map[qa.questionId] = qa
    })
    qaMap.value = map
  } catch (error) {
    // 场次不存在或不属于当前学生时，后端会直接报错，这里清空展示即可
    resetSessionData()
  } finally {
    loading.value = false
  }
}

/** 退出某个场次时把数据清空，避免串场 */
function resetSessionData() {
  sessionInfo.value = {}
  questionList.value = []
  qaMap.value = {}
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

/** 详情抽屉 */
function handleView(row) {
  proxy.$refs["questionViewRef"].open(row.id)
}

/** 回场次列表 */
function goSessionList() {
  router.push('/student/session')
}

/** 导出：只导当前这一场的题目 */
function handleExport() {
  proxy.download('interview/question/export', {
    ...PAGE_ALL,
    sessionId: sessionId.value
  }, `question_${sessionId.value}_${new Date().getTime()}.xlsx`)
}

/** 空态里选中场次后，把 sessionId 写进路由，本页据此加载 */
watch(pickedSessionId, (val) => {
  if (val) {
    router.replace({ path: '/student/question', query: { sessionId: val } })
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

  .session-bar__progress {
    font-size: 13px;
    color: #909399;
  }

  .session-bar__actions {
    flex-shrink: 0;
  }
}
</style>
