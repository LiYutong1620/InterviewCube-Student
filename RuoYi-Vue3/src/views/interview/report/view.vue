<template>
  <el-drawer
    title="面试复盘报告"
    v-model="visible"
    direction="rtl"
    size="70%"
    append-to-body
    class="detail-drawer"
    @opened="drawRadar"
  >
    <div v-loading="loading" class="report-detail">
      <!-- 场次信息条 -->
      <div class="session-bar">
        <span class="session-bar__no">{{ info.sessionNo || '—' }}</span>
        <el-tag v-if="info.jobName" size="small" type="info">{{ info.jobName }}</el-tag>
        <dict-tag :options="interview_report_status" :value="info.generateStatus" />
        <span class="session-bar__meta">面试时间 {{ formatTime(info.startTime) }}</span>
        <span class="session-bar__meta">报告编号 {{ info.reportNo || '—' }}</span>
      </div>

      <!-- 空态：还没生成 / 生成失败 -->
      <el-empty v-if="!generated" :description="emptyText">
        <el-button v-if="failed" type="primary" icon="EditPen" @click="emit('fill', info)">手工填分</el-button>
      </el-empty>

      <template v-else>
        <!-- 总分 -->
        <el-card shadow="never" class="score-card">
          <div class="score-card__value">{{ info.totalScore }}</div>
          <div class="score-card__label">本场综合得分</div>
          <div class="score-card__meta">生成时间 {{ formatTime(info.generateTime) }}</div>
        </el-card>

        <!-- 五维雷达图 + 分数条 -->
        <el-row :gutter="16">
          <el-col :xs="24" :md="11">
            <el-card shadow="never" class="block">
              <template #header><span class="block__title">能力雷达图</span></template>
              <div ref="radarRef" class="radar"></div>
            </el-card>
          </el-col>
          <el-col :xs="24" :md="13">
            <el-card shadow="never" class="block">
              <template #header><span class="block__title">维度得分</span></template>
              <div v-for="item in DIMENSIONS" :key="item.prop" class="dimension">
                <span class="dimension__label">{{ item.label }}</span>
                <el-progress
                  class="dimension__bar"
                  :percentage="toScore(info[item.prop])"
                  :stroke-width="10"
                  :color="scoreColor"
                />
              </div>
            </el-card>
          </el-col>
        </el-row>

        <!-- 总结 / 薄弱点 / 改进建议 -->
        <el-card shadow="never" class="block">
          <template #header><span class="block__title">总体评价</span></template>
          <p class="paragraph">{{ info.summary || '暂无' }}</p>
        </el-card>

        <el-card shadow="never" class="block">
          <template #header><span class="block__title">薄弱点</span></template>
          <template v-if="weakPointList.length">
            <el-tag
              v-for="(point, index) in weakPointList"
              :key="index"
              class="mr8"
              type="warning"
              effect="light"
            >{{ point }}</el-tag>
          </template>
          <p v-else class="paragraph">暂无</p>
        </el-card>

        <el-card shadow="never" class="block">
          <template #header><span class="block__title">改进建议</span></template>
          <p class="paragraph">{{ info.suggest || '暂无' }}</p>
        </el-card>

        <!-- PDF 导出 -->
        <div class="pdf-row">
          <el-button
            type="primary"
            plain
            icon="Document"
            :loading="pdfLoading"
            v-hasPermi="['interview:report:export']"
            @click="generatePdf"
          >生成 PDF 报告</el-button>
          <el-button
            type="primary"
            plain
            icon="Download"
            :disabled="!info.pdfUrl"
            @click="downloadPdf"
          >下载 PDF 报告</el-button>
          <span v-if="!info.pdfUrl" class="pdf-tip">生成成功后可下载 PDF</span>
        </div>
      </template>
    </div>
  </el-drawer>
</template>

<script setup name="ReportViewDrawer">
import * as echarts from 'echarts'
import { getReport, exportReportPdf } from '@/api/interview/report'
import { parseTime } from '@/utils/ruoyi'

const { proxy } = getCurrentInstance()
const { interview_report_status } = useDict('interview_report_status')

/** 生成成功：只有这个状态才有分数和雷达图 */
const GENERATE_SUCCESS = '2'

/** 五个评分维度，顺序即雷达图 / 分数条的展示顺序 */
const DIMENSIONS = [
  { prop: 'scoreCompleteness', label: '完整性' },
  { prop: 'scoreLogic', label: '逻辑性' },
  { prop: 'scoreFluency', label: '流畅度' },
  { prop: 'scoreDepth', label: '深度' },
  { prop: 'scoreConfidence', label: '自信度' }
]

const emit = defineEmits(['fill'])

const visible = ref(false)
const loading = ref(false)
const pdfLoading = ref(false)
const info = reactive({})
const radarRef = ref(null)

const baseUrl = import.meta.env.VITE_APP_BASE_API

let chart = null

const generated = computed(() => info.generateStatus === GENERATE_SUCCESS)
const failed = computed(() => info.generateStatus === '3')
const emptyText = computed(() => failed.value ? '报告生成失败，可以重新生成' : '报告生成中，稍后回来看看')
const weakPointList = computed(() => resolveList(info.weakPoints))

/** 打开抽屉：列表行里已带齐全部字段直接用；只给 id 时再查一次 */
async function open(row) {
  resetInfo()
  visible.value = true
  if (row && typeof row === 'object') {
    Object.assign(info, row)
  } else if (row) {
    loading.value = true
    try {
      const res = await getReport(row)
      Object.assign(info, res.data || {})
    } finally {
      loading.value = false
    }
  }
}

/** 时间统一走 parseTime，空值显示占位符 */
function formatTime(value) {
  return parseTime(value, '{y}-{m}-{d} {h}:{i}') || '—'
}

/** 分数取不到时按 0 处理，避免进度条 / 雷达图拿到 NaN */
function toScore(value) {
  const num = Number(value)
  return Number.isFinite(num) ? num : 0
}

/** 分数条颜色按分段给：优秀 / 良好 / 及格 / 待提升 */
function scoreColor(percentage) {
  if (percentage >= 80) {
    return '#67c23a'
  }
  if (percentage >= 60) {
    return '#409eff'
  }
  if (percentage >= 40) {
    return '#e6a23c'
  }
  return '#f56c6c'
}

/** 薄弱点存的是 JSON 数组，解析成标签渲染；解析不了就按单行纯文本兜底 */
function resolveList(raw) {
  if (!raw) {
    return []
  }
  try {
    const arr = JSON.parse(raw)
    return Array.isArray(arr) ? arr.map(item => String(item)).filter(item => item) : [String(raw)]
  } catch (e) {
    return [String(raw)]
  }
}

/** 雷达图数据直接用五个维度分构建，不依赖 radar_data（那是阶段三 AI 的原始输出） */
function buildRadarOption() {
  return {
    tooltip: { trigger: 'item' },
    radar: {
      radius: '68%',
      center: ['50%', '54%'],
      indicator: DIMENSIONS.map(item => ({ name: item.label, max: 100 })),
      axisName: { color: '#606266', fontSize: 12 },
      splitLine: { lineStyle: { color: '#e4e7ed' } },
      splitArea: { areaStyle: { color: ['#ffffff', '#fafafa'] } },
      axisLine: { lineStyle: { color: '#e4e7ed' } }
    },
    series: [
      {
        type: 'radar',
        symbolSize: 6,
        lineStyle: { color: '#409eff', width: 2 },
        itemStyle: { color: '#409eff' },
        areaStyle: { color: 'rgba(64, 158, 255, 0.25)' },
        data: [{ value: DIMENSIONS.map(item => toScore(info[item.prop])), name: '本场得分' }]
      }
    ]
  }
}

/** 抽屉展开动画结束后才量得到真实尺寸，所以挂在 @opened 上画 */
function drawRadar() {
  if (!generated.value || !radarRef.value) {
    return
  }
  if (!chart) {
    chart = echarts.init(radarRef.value)
  }
  chart.setOption(buildRadarOption(), true)
  chart.resize()
}

/** 窗口尺寸变化时同步缩放雷达图 */
function handleResize() {
  if (chart) {
    chart.resize()
  }
}

/** 生成 PDF 并回写 pdfUrl */
function generatePdf() {
  if (!info.id) {
    return
  }
  pdfLoading.value = true
  exportReportPdf(info.id).then(res => {
    Object.assign(info, res.data || {})
    proxy.$modal.msgSuccess('PDF 生成成功')
  }).catch(() => {}).finally(() => {
    pdfLoading.value = false
  })
}

function downloadPdf() {
  if (!info.pdfUrl) {
    return
  }
  const url = /^https?:\/\//i.test(info.pdfUrl) ? info.pdfUrl : (baseUrl + info.pdfUrl)
  window.open(url)
}

function resetInfo() {
  Object.keys(info).forEach(key => delete info[key])
}

onMounted(() => {
  window.addEventListener('resize', handleResize)
})

onUnmounted(() => {
  window.removeEventListener('resize', handleResize)
  if (chart) {
    chart.dispose()
    chart = null
  }
})

defineExpose({ open })
</script>

<style lang="scss" scoped>
.report-detail {
  padding-bottom: 16px;
}

.session-bar {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 12px;
  padding: 12px 16px;
  margin-bottom: 16px;
  background: #f5f7fa;
  border-radius: 4px;

  .session-bar__no {
    font-size: 14px;
    font-weight: 500;
    color: #303133;
  }

  .session-bar__meta {
    font-size: 13px;
    color: #909399;
  }
}

.score-card {
  margin-bottom: 16px;
  text-align: center;

  :deep(.el-card__body) {
    padding: 24px 16px;
  }

  .score-card__value {
    font-size: 52px;
    font-weight: 600;
    line-height: 1.1;
    color: #409eff;
  }

  .score-card__label {
    margin-top: 6px;
    font-size: 14px;
    color: #606266;
  }

  .score-card__meta {
    margin-top: 4px;
    font-size: 12px;
    color: #909399;
  }
}

.block {
  margin-bottom: 16px;

  .block__title {
    font-size: 14px;
    font-weight: 500;
    color: #303133;
  }
}

.radar {
  width: 100%;
  height: 280px;
}

.dimension {
  display: flex;
  align-items: center;
  margin-bottom: 14px;

  .dimension__label {
    flex-shrink: 0;
    width: 60px;
    font-size: 13px;
    color: #606266;
  }

  .dimension__bar {
    flex: 1;
  }
}

.paragraph {
  margin: 0;
  font-size: 14px;
  line-height: 1.8;
  color: #606266;
  white-space: pre-wrap;
}

.mr8 {
  margin: 0 8px 8px 0;
}

.pdf-row {
  display: flex;
  align-items: center;
  gap: 12px;

  .pdf-tip {
    font-size: 12px;
    color: #909399;
  }
}
</style>
