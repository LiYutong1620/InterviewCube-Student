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
      <el-form-item label="生成状态" prop="generateStatus">
        <el-select
          v-model="queryParams.generateStatus"
          placeholder="报告生成状态"
          clearable
          style="width: 160px"
        >
          <el-option
            v-for="dict in interview_report_status"
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
      <el-col v-if="canFill" :span="4">
        <el-button type="primary" plain icon="MagicStick" @click="handleGenerate">
          {{ pendingCount > 0 ? '生成报告（' + pendingCount + ' 场待生成）' : '生成报告' }}
        </el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="warning"
          plain
          icon="Download"
          @click="handleExport"
          v-hasPermi="['interview:report:export']"
        >导出</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="reportList" :empty-text="emptyText">
      <el-table-column label="报告编号" align="center" width="200">
        <template #default="scope">
          <el-link type="primary" :underline="false" @click="handleView(scope.row)">
            {{ scope.row.reportNo }}
          </el-link>
        </template>
      </el-table-column>
      <el-table-column label="关联场次" align="left" :show-overflow-tooltip="true">
        <template #default="scope">
          <div class="session-cell">
            <span class="session-cell__job">{{ scope.row.jobName || '—' }}</span>
            <span class="session-cell__time">{{ formatTime(scope.row.startTime) }}</span>
          </div>
        </template>
      </el-table-column>
      <el-table-column label="总分" align="center" width="90">
        <template #default="scope">
          <span :class="['total-score', { 'total-score--empty': scope.row.totalScore == null }]">
            {{ scope.row.totalScore == null ? '—' : scope.row.totalScore }}
          </span>
        </template>
      </el-table-column>
      <el-table-column label="生成状态" align="center" width="110">
        <template #default="scope">
          <dict-tag :options="interview_report_status" :value="scope.row.generateStatus" />
        </template>
      </el-table-column>
      <el-table-column label="生成时间" align="center" width="170">
        <template #default="scope">
          <span>{{ formatTime(scope.row.generateTime) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" width="150" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button link type="primary" icon="View" @click="handleView(scope.row)">查看</el-button>
          <el-button
            link
            type="primary"
            icon="EditPen"
            @click="handleFill(scope.row)"
            v-hasPermi="['interview:report:edit']"
          >填分</el-button>
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

    <!-- 复盘报告详情抽屉 -->
    <report-view-drawer ref="reportViewRef" @fill="handleFill" />

    <!--
      填分 / 生成报告：阶段一的演示入口，阶段三由 AI 自动评分替换。
      两种来源共用这一个弹窗：
        · 列表行「填分」  → 场次固定（fillSessionLocked = true）
        · 工具条「生成报告」→ 场次下拉列出「已完成但还没报告」的场次
      提交走 POST /interview/report/fill，后端在该场没有报告壳时会先补建（见 fillReport）。
    -->
    <el-dialog title="手工填分" v-model="fillOpen" width="680px" append-to-body destroy-on-close>
      <el-alert
        class="mb8"
        type="info"
        show-icon
        :closable="false"
        title="阶段一演示入口：AI 评分接入前，先手工填入五个维度得分，用来打通「报告 → 雷达图」这条链路。"
      />
      <el-form ref="fillRef" :model="fillForm" :rules="fillRules" label-width="90px">
        <el-form-item label="关联场次" prop="sessionId">
          <el-select
            v-model="fillForm.sessionId"
            placeholder="选择一场已完成的面试"
            :disabled="fillSessionLocked"
            style="width: 100%"
          >
            <el-option
              v-for="item in fillSessionOptions"
              :key="item.id"
              :label="sessionOptionLabel(item)"
              :value="item.id"
            />
          </el-select>
        </el-form-item>
        <el-row :gutter="16">
          <el-col :span="12" v-for="item in DIMENSIONS" :key="item.prop">
            <el-form-item :label="item.label" :prop="item.prop">
              <el-input-number
                v-model="fillForm[item.prop]"
                :min="0"
                :max="100"
                :precision="2"
                :step="1"
                controls-position="right"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="报告总结" prop="summary">
          <el-input
            v-model="fillForm.summary"
            type="textarea"
            :rows="3"
            maxlength="2000"
            show-word-limit
            placeholder="选填"
          />
        </el-form-item>
        <el-form-item label="薄弱点" prop="weakPoints">
          <el-input
            v-model="fillForm.weakPoints"
            type="textarea"
            :rows="2"
            placeholder='JSON 数组，例如 ["表达不够结构化","缺少量化数据"]'
          />
        </el-form-item>
        <el-form-item label="改进建议" prop="suggest">
          <el-input
            v-model="fillForm.suggest"
            type="textarea"
            :rows="3"
            maxlength="2000"
            show-word-limit
            placeholder="选填"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" :loading="filling" @click="submitFill">提 交</el-button>
          <el-button @click="fillOpen = false">取 消</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="Report">
import { listReport, fillReport } from "@/api/interview/report"
import { listSession } from "@/api/interview/session"
import { checkPermi } from "@/utils/permission"
import { parseTime } from "@/utils/ruoyi"
import ReportViewDrawer from "./view"

const { proxy } = getCurrentInstance()
const route = useRoute()
const { interview_report_status } = useDict('interview_report_status')

/** 一次取完用于算差集；学生自己的场次 / 报告量级很小，够用 */
const PAGE_ALL = { pageNum: 1, pageSize: 500 }

/** 只有「已完成」的场次才该有复盘报告 */
const SESSION_STATUS_FINISHED = '2'

/** 五个评分维度，顺序即雷达图 / 分数条的展示顺序 */
const DIMENSIONS = [
  { prop: 'scoreCompleteness', label: '完整性' },
  { prop: 'scoreLogic', label: '逻辑性' },
  { prop: 'scoreFluency', label: '流畅度' },
  { prop: 'scoreDepth', label: '深度' },
  { prop: 'scoreConfidence', label: '自信度' }
]

const reportList = ref([])
const loading = ref(true)
const showSearch = ref(true)
const total = ref(0)

/** 「已完成但还没有报告」的场次 —— 「生成报告」按钮的候选 */
const pendingSessions = ref([])

const fillOpen = ref(false)
const filling = ref(false)
const fillSessionOptions = ref([])
/** 从列表行进来时场次是定的，不让改 */
const fillSessionLocked = ref(false)

/** 能填分 / 能生成报告（与后端 /fill 的权限点一致） */
const canFill = computed(() => checkPermi(['interview:report:edit']))
const pendingCount = computed(() => pendingSessions.value.length)
const emptyText = computed(() => {
  if (canFill.value && pendingCount.value > 0) {
    return '还有 ' + pendingCount.value + ' 场已完成的面试没有复盘报告，点上方「生成报告」补上'
  }
  return '还没有复盘报告 —— 完成一场面试后会自动生成'
})

const data = reactive({
  queryParams: {
    pageNum: 1,
    pageSize: 10,
    jobName: undefined,
    generateStatus: undefined
  },
  fillForm: {},
  fillRules: {
    sessionId: [{ required: true, message: "请选择要填分的面试场次", trigger: "change" }],
    scoreCompleteness: [{ required: true, message: "请填写完整性得分", trigger: "blur" }],
    scoreLogic: [{ required: true, message: "请填写逻辑性得分", trigger: "blur" }],
    scoreFluency: [{ required: true, message: "请填写流畅度得分", trigger: "blur" }],
    scoreDepth: [{ required: true, message: "请填写深度得分", trigger: "blur" }],
    scoreConfidence: [{ required: true, message: "请填写自信度得分", trigger: "blur" }]
  }
})

const { queryParams, fillForm, fillRules } = toRefs(data)

/** 查询我的复盘报告列表（数据范围由后端按登录用户隔离） */
function getList() {
  loading.value = true
  listReport(queryParams.value).then(response => {
    reportList.value = response.rows
    total.value = response.total
    loading.value = false
  })
}

/**
 * 刷新「待生成」场次：已完成的场次 减去 已有报告的场次。
 * 报告壳是「场次答完」时才建的，所以 S4 之前就已完成的场次不会有壳 —— 这里把它们捞出来补上。
 */
function loadPending() {
  if (!canFill.value) {
    return Promise.resolve()
  }
  return Promise.all([
    listSession({ ...PAGE_ALL, status: SESSION_STATUS_FINISHED }),
    listReport({ ...PAGE_ALL })
  ]).then(([sessionRes, reportRes]) => {
    const reported = new Set((reportRes.rows || []).map(item => item.sessionId))
    pendingSessions.value = (sessionRes.rows || []).filter(item => !reported.has(item.id))
  }).catch(() => {
    // 拦截器已提示，这里只是别让待生成数量挡住列表
    pendingSessions.value = []
  })
}

/** 时间统一走 parseTime，空值显示占位符 */
function formatTime(value) {
  return parseTime(value, '{y}-{m}-{d} {h}:{i}') || '—'
}

/** 场次下拉的展示文案：场次编号 · 岗位名 · 时间 */
function sessionOptionLabel(item) {
  return [
    item.sessionNo,
    item.jobName,
    parseTime(item.endTime || item.startTime, '{y}-{m}-{d} {h}:{i}')
  ].filter(text => text).join(' · ')
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

/** 查看详情：列表行已带齐全部字段，直接交给抽屉渲染 */
function handleView(row) {
  proxy.$refs["reportViewRef"].open(row)
}

/** 清空填分表单 */
function resetFill() {
  fillForm.value = {
    sessionId: undefined,
    scoreCompleteness: undefined,
    scoreLogic: undefined,
    scoreFluency: undefined,
    scoreDepth: undefined,
    scoreConfidence: undefined,
    summary: undefined,
    weakPoints: undefined,
    suggest: undefined
  }
  fillSessionOptions.value = []
  fillSessionLocked.value = false
}

/** 打开「生成报告」：列出「已完成但还没报告」的场次，选一场填分，后端会顺手把报告壳补出来 */
function handleGenerate() {
  if (!pendingCount.value) {
    proxy.$modal.msgWarning('没有待生成的报告 —— 需要先有一场「已完成」的面试')
    return
  }
  resetFill()
  fillSessionOptions.value = pendingSessions.value
  fillOpen.value = true
}

/** 打开「填分」：针对列表里已有报告的那一场，场次固定不可改 */
function handleFill(row) {
  resetFill()
  fillForm.value = {
    sessionId: row.sessionId,
    scoreCompleteness: row.scoreCompleteness,
    scoreLogic: row.scoreLogic,
    scoreFluency: row.scoreFluency,
    scoreDepth: row.scoreDepth,
    scoreConfidence: row.scoreConfidence,
    summary: row.summary,
    weakPoints: row.weakPoints,
    suggest: row.suggest
  }
  fillSessionOptions.value = [{
    id: row.sessionId,
    sessionNo: row.sessionNo,
    jobName: row.jobName,
    startTime: row.startTime
  }]
  fillSessionLocked.value = true
  fillOpen.value = true
}

/** 提交填分：总分由后端按五维平均算，前端不传 */
function submitFill() {
  proxy.$refs["fillRef"].validate(valid => {
    if (!valid) {
      return
    }
    filling.value = true
    fillReport({ ...fillForm.value }).then(response => {
      proxy.$modal.msgSuccess('报告已生成')
      fillOpen.value = false
      getList()
      loadPending()
      const saved = response.data
      if (saved && saved.id) {
        proxy.$refs["reportViewRef"].open(saved)
      }
    }).finally(() => {
      filling.value = false
    })
  })
}

/** 导出按钮操作 */
function handleExport() {
  proxy.download('interview/report/export', {
    ...queryParams.value
  }, `report_${new Date().getTime()}.xlsx`)
}

/**
 * 从「模拟面试场次」的「查看报告」下钻进来时只带 sessionId，
 * 而报告是按 id 取的，先按 sessionId 定位到那一条再打开抽屉。
 */
function openBySession(id) {
  listReport({ pageNum: 1, pageSize: 1, sessionId: id }).then(response => {
    const row = (response.rows || [])[0]
    if (row) {
      proxy.$refs["reportViewRef"].open(row)
    } else {
      proxy.$modal.msgWarning('这场面试还没有复盘报告，点上方「生成报告」补上')
      loadPending()
    }
  })
}

watch(() => route.query.sessionId, val => {
  if (val) {
    nextTick(() => openBySession(val))
  }
}, { immediate: true })

getList()
loadPending()
</script>

<style lang="scss" scoped>
.session-cell {
  display: flex;
  flex-direction: column;
  line-height: 1.5;

  .session-cell__job {
    color: #303133;
  }

  .session-cell__time {
    font-size: 12px;
    color: #909399;
  }
}

.total-score {
  font-weight: 600;
  color: #409eff;
}

.total-score--empty {
  font-weight: 400;
  color: #c0c4cc;
}
</style>
