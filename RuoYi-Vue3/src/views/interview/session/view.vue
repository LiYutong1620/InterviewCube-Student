<template>
  <el-drawer title="面试场次详情" v-model="visible" direction="rtl" size="60%" append-to-body :before-close="handleClose" class="detail-drawer">
    <div v-loading="loading" class="drawer-content">
      <h4 class="section-header">基本信息</h4>
      <el-row :gutter="20" class="mb8">
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">场次编号：</label>
            <span class="info-value plaintext">
              {{ display(info.sessionNo) }}
            </span>
          </div>
        </el-col>
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">岗位名称：</label>
            <span class="info-value plaintext">
              {{ display(info.jobName) }}
            </span>
          </div>
        </el-col>
      </el-row>
      <el-row :gutter="20" class="mb8">
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">行业：</label>
            <span class="info-value">
              <dict-tag :options="student_industry" :value="info.industry" />
            </span>
          </div>
        </el-col>
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">难度：</label>
            <span class="info-value">
              <dict-tag :options="student_difficulty" :value="info.difficulty" />
            </span>
          </div>
        </el-col>
      </el-row>
      <el-row :gutter="20" class="mb8">
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">题型：</label>
            <span class="info-value">
              <template v-if="questionTypeLabels.length">
                <el-tag
                  v-for="label in questionTypeLabels"
                  :key="label"
                  size="small"
                  class="mr4"
                >{{ label }}</el-tag>
              </template>
              <span v-else class="text-muted">—</span>
            </span>
          </div>
        </el-col>
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">状态：</label>
            <span class="info-value">
              <dict-tag :options="interview_session_status" :value="info.status" />
            </span>
          </div>
        </el-col>
      </el-row>
      <el-row :gutter="20" class="mb8">
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">答题进度：</label>
            <span class="info-value plaintext">
              {{ info.answeredCount || 0 }} / {{ info.totalCount || 0 }}
            </span>
          </div>
        </el-col>
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">本场总分：</label>
            <span class="info-value plaintext">
              {{ info.score == null ? '—' : info.score }}
            </span>
          </div>
        </el-col>
      </el-row>
      <el-row :gutter="20" class="mb8">
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">开始时间：</label>
            <span class="info-value plaintext">
              {{ parseTime(info.startTime, '{y}-{m}-{d} {h}:{i}') }}
            </span>
          </div>
        </el-col>
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">结束时间：</label>
            <span class="info-value plaintext">
              {{ parseTime(info.endTime, '{y}-{m}-{d} {h}:{i}') }}
            </span>
          </div>
        </el-col>
      </el-row>
      <el-row :gutter="20" class="mb8">
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">面试时长：</label>
            <span class="info-value plaintext">
              {{ formatDuration(info.duration) }}
            </span>
          </div>
        </el-col>
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">复盘报告：</label>
            <span class="info-value plaintext">
              {{ info.reportId ? '已生成' : '未生成' }}
            </span>
          </div>
        </el-col>
      </el-row>
      <el-row :gutter="20" class="mb8">
        <el-col :span="24">
          <div class="info-item">
            <label class="info-label">备注：</label>
            <span class="info-value plaintext">
              {{ display(info.remark) }}
            </span>
          </div>
        </el-col>
      </el-row>
    </div>
  </el-drawer>
</template>

<script setup name="SessionViewDrawer">
import { getSession } from '@/api/interview/session'

const {
  student_industry,
  student_difficulty,
  interview_question_type,
  interview_session_status
} = useDict(
  'student_industry',
  'student_difficulty',
  'interview_question_type',
  'interview_session_status'
)

const visible = ref(false)
const loading = ref(false)
const info = reactive({})

/** 题型是多选后以英文逗号拼接的，逐项翻译成标签 */
const questionTypeLabels = computed(() => {
  if (!info.questionType) {
    return []
  }
  return String(info.questionType)
    .split(',')
    .map(item => item.trim())
    .filter(item => item)
    .map(item => {
      const hit = interview_question_type.value.find(dict => dict.value === item)
      return hit ? hit.label : item
    })
})

/** 空值统一显示为「—」 */
function display(value) {
  return value === null || value === undefined || value === '' ? '—' : value
}

/** 面试时长（秒）转成「X 分 Y 秒」 */
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

const open = async (id) => {
  visible.value = true
  loading.value = true
  try {
    const res = await getSession(id)
    Object.assign(info, res.data || {})
  } catch (error) {
    console.error('获取模拟面试场次信息失败:', error)
  } finally {
    loading.value = false
  }
}

function handleClose() {
  visible.value = false
  Object.keys(info).forEach(key => delete info[key])
}

defineExpose({ open })
</script>

<style scoped>
.mr4 {
  margin-right: 4px;
}

.text-muted {
  color: #c0c4cc;
}
</style>
