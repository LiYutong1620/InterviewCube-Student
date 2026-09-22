<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-width="80px">
      <el-form-item label="岗位名称" prop="jobName">
        <el-input
          v-model="queryParams.jobName"
          placeholder="请输入岗位名称"
          clearable
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="面试状态" clearable style="width: 160px">
          <el-option
            v-for="dict in interview_session_status"
            :key="dict.value"
            :label="dict.label"
            :value="dict.value"
          />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button
          type="primary"
          plain
          icon="Plus"
          @click="handleStart"
          v-hasPermi="['interview:session:add']"
        >开始面试</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="warning"
          plain
          icon="Download"
          @click="handleExport"
          v-hasPermi="['interview:session:export']"
        >导出</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="sessionList">
      <el-table-column label="场次编号" align="center" width="200">
        <template #default="scope">
          <el-link type="primary" :underline="false" @click="handleView(scope.row)">
            {{ scope.row.sessionNo }}
          </el-link>
        </template>
      </el-table-column>
      <el-table-column label="岗位名称" align="center" prop="jobName" :show-overflow-tooltip="true" />
      <el-table-column label="难度" align="center" width="90">
        <template #default="scope">
          <dict-tag :options="student_difficulty" :value="scope.row.difficulty" />
        </template>
      </el-table-column>
      <el-table-column label="题型" align="center" width="210">
        <template #default="scope">
          <template v-if="questionTypeLabels(scope.row.questionType).length">
            <el-tag
              v-for="label in questionTypeLabels(scope.row.questionType)"
              :key="label"
              size="small"
              class="mr4"
            >{{ label }}</el-tag>
          </template>
          <span v-else>-</span>
        </template>
      </el-table-column>
      <el-table-column label="进度" align="center" width="90">
        <template #default="scope">
          <span>{{ scope.row.answeredCount || 0 }} / {{ scope.row.totalCount || 0 }}</span>
        </template>
      </el-table-column>
      <el-table-column label="状态" align="center" width="100">
        <template #default="scope">
          <dict-tag :options="interview_session_status" :value="scope.row.status" />
        </template>
      </el-table-column>
      <el-table-column label="本场总分" align="center" width="100">
        <template #default="scope">
          <span>{{ scope.row.score == null ? '-' : scope.row.score }}</span>
        </template>
      </el-table-column>
      <el-table-column label="开始时间" align="center" width="170">
        <template #default="scope">
          <span>{{ parseTime(scope.row.startTime, '{y}-{m}-{d} {h}:{i}') }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" width="250" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button
            v-if="isOngoing(scope.row)"
            link
            type="primary"
            icon="VideoPlay"
            @click="handleAnswer(scope.row)"
          >继续作答</el-button>
          <el-button
            v-if="isFinished(scope.row)"
            link
            type="primary"
            icon="DataAnalysis"
            @click="handleReport(scope.row)"
          >查看报告</el-button>
          <el-button
            v-if="isFinished(scope.row) || isInterrupted(scope.row)"
            link
            type="primary"
            icon="Document"
            @click="handleReview(scope.row)"
          >回顾题目</el-button>
          <el-button
            link
            type="danger"
            icon="Delete"
            @click="handleDelete(scope.row)"
            v-hasPermi="['interview:session:remove']"
          >删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination
      v-show="total>0"
      :total="total"
      v-model:page="queryParams.pageNum"
      v-model:limit="queryParams.pageSize"
      @pagination="getList"
    />

    <!-- 模拟面试场次详情抽屉 -->
    <session-view-drawer ref="sessionViewRef" />

    <!-- 开始面试：只选目标岗位 + 题型 + 题目数，其余字段由后端生成 -->
    <el-dialog title="开始面试" v-model="startOpen" width="560px" append-to-body>
      <el-form ref="startRef" :model="startForm" :rules="startRules" label-width="90px">
        <el-form-item label="目标岗位" prop="jobProfileId">
          <el-select
            v-model="startForm.jobProfileId"
            placeholder="请选择目标岗位"
            style="width: 100%"
            :loading="profileLoading"
          >
            <el-option
              v-for="item in jobProfileList"
              :key="item.id"
              :label="profileLabel(item)"
              :value="item.id"
            />
          </el-select>
          <div v-if="!profileLoading && !jobProfileList.length" class="form-tip">
            还没有可用的岗位画像，请先到「学生岗位画像」新建一个
          </div>
        </el-form-item>
        <el-form-item label="题型" prop="questionType">
          <el-select
            v-model="startForm.questionType"
            multiple
            placeholder="不选表示不限题型"
            style="width: 100%"
          >
            <el-option
              v-for="dict in interview_question_type"
              :key="dict.value"
              :label="dict.label"
              :value="dict.value"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="题目数" prop="totalCount">
          <el-input-number v-model="startForm.totalCount" :min="1" :max="20" controls-position="right" />
          <div class="form-tip">题库中符合条件的题目不足时，按实际抽到的数量出题</div>
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" :loading="starting" @click="submitStart">开始面试</el-button>
          <el-button @click="startOpen = false">取 消</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="Session">
import { listSession, delSession, addSession } from "@/api/interview/session"
import { listJobprofile } from "@/api/interview/jobprofile"
import SessionViewDrawer from "./view"

const { proxy } = getCurrentInstance()
const router = useRouter()
const {
  interview_session_status,
  interview_question_type,
  student_difficulty,
  student_industry
} = useDict(
  'interview_session_status',
  'interview_question_type',
  'student_difficulty',
  'student_industry'
)

/** 未开始 / 进行中的场次都可以继续作答 */
const ONGOING_STATUS = ['0', '1']

const sessionList = ref([])
const loading = ref(true)
const showSearch = ref(true)
const total = ref(0)

const startOpen = ref(false)
const starting = ref(false)
const profileLoading = ref(false)
const jobProfileList = ref([])

const data = reactive({
  queryParams: {
    pageNum: 1,
    pageSize: 10,
    jobName: undefined,
    status: undefined
  },
  startForm: {
    jobProfileId: undefined,
    questionType: [],
    totalCount: 5
  },
  startRules: {
    jobProfileId: [{ required: true, message: "请选择目标岗位", trigger: "change" }],
    totalCount: [{ required: true, message: "请输入题目数", trigger: "blur" }]
  }
})

const { queryParams, startForm, startRules } = toRefs(data)

/** 查询我的面试场次列表（数据范围由后端按登录用户隔离） */
function getList() {
  loading.value = true
  listSession(queryParams.value).then(response => {
    sessionList.value = response.rows
    total.value = response.total
    loading.value = false
  })
}

/** 字典翻译，取不到时原样返回 */
function dictLabel(options, value) {
  const hit = options.value.find(dict => dict.value === value)
  return hit ? hit.label : value
}

/** 题型是多选后以英文逗号拼接的，逐项翻译成标签 */
function questionTypeLabels(raw) {
  if (!raw) {
    return []
  }
  return String(raw)
    .split(',')
    .map(item => item.trim())
    .filter(item => item)
    .map(item => dictLabel(interview_question_type, item))
}

/** 岗位画像下拉的展示文案：行业 · 岗位名 · 难度 */
function profileLabel(item) {
  return [
    dictLabel(student_industry, item.industry),
    item.jobName,
    dictLabel(student_difficulty, item.difficulty)
  ].filter(text => text).join(' · ')
}

/** 未开始 / 进行中：还可以继续作答 */
function isOngoing(row) {
  return ONGOING_STATUS.includes(row.status)
}

/** 已完成：可以看报告 */
function isFinished(row) {
  return row.status === '2'
}

/** 已中断：作答记录还在，可以回顾题目 */
function isInterrupted(row) {
  return row.status === '3'
}

/** 搜索按钮操作 */
function handleQuery() {
  queryParams.value.pageNum = 1
  getList()
}

/** 重置按钮操作 */
function resetQuery() {
  proxy.resetForm("queryRef")
  handleQuery()
}

/** 详情抽屉 */
function handleView(row) {
  proxy.$refs["sessionViewRef"].open(row.id)
}

/** 继续作答：带 sessionId 下钻到作答页 */
function handleAnswer(row) {
  router.push({ path: '/student/qa', query: { sessionId: row.id } })
}

/** 查看报告：带 sessionId 下钻到复盘报告页 */
function handleReport(row) {
  router.push({ path: '/student/report', query: { sessionId: row.id } })
}

/** 回顾题目：带 sessionId 下钻到题目回顾页 */
function handleReview(row) {
  router.push({ path: '/student/question', query: { sessionId: row.id } })
}

/** 打开「开始面试」对话框 */
function handleStart() {
  startForm.value = {
    jobProfileId: undefined,
    questionType: [],
    totalCount: 5
  }
  startOpen.value = true
  loadJobProfiles()
}

/** 拉取自己的岗位画像（只取正常状态） */
function loadJobProfiles() {
  profileLoading.value = true
  listJobprofile({ pageNum: 1, pageSize: 100, status: '0' }).then(response => {
    jobProfileList.value = response.rows || []
  }).finally(() => {
    profileLoading.value = false
  })
}

/** 提交开始面试：后端生成场次编号 / 归属 / 状态 / 开始时间，并从题库抽题 */
function submitStart() {
  proxy.$refs["startRef"].validate(valid => {
    if (!valid) {
      return
    }
    starting.value = true
    addSession({
      jobProfileId: startForm.value.jobProfileId,
      questionType: startForm.value.questionType.join(','),
      totalCount: startForm.value.totalCount
    }).then(response => {
      const created = response.data || {}
      startOpen.value = false
      proxy.$modal.msgSuccess('面试已开始，本场共 ' + (created.totalCount || 0) + ' 题')
      getList()
      // S1 遗留：建完场次直接进作答页，把 sessionId 带过去
      if (created.id) {
        router.push({ path: '/student/qa', query: { sessionId: created.id } })
      }
    }).finally(() => {
      starting.value = false
    })
  })
}

/** 删除按钮操作（后端会级联删除该场的题目 / 作答 / 报告） */
function handleDelete(row) {
  proxy.$modal.confirm('是否确认删除场次「' + row.sessionNo + '」？该场次的题目、作答记录与复盘报告将一并删除。').then(function() {
    return delSession(row.id)
  }).then(() => {
    getList()
    proxy.$modal.msgSuccess("删除成功")
  }).catch(() => {})
}

/** 导出按钮操作 */
function handleExport() {
  proxy.download('interview/session/export', {
    ...queryParams.value
  }, `session_${new Date().getTime()}.xlsx`)
}

getList()
</script>

<style scoped>
.mr4 {
  margin-right: 4px;
}

.form-tip {
  margin-top: 4px;
  font-size: 12px;
  line-height: 1.5;
  color: #909399;
}
</style>
