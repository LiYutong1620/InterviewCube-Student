<template>
  <el-drawer title="题目详情" v-model="visible" direction="rtl" size="60%" append-to-body :before-close="handleClose" class="detail-drawer">
    <div v-loading="loading" class="drawer-content">
      <h4 class="section-header">题目信息</h4>
      <el-row :gutter="20" class="mb8">
        <el-col :span="24">
          <div class="info-item">
            <label class="info-label">题干：</label>
            <span class="info-value plaintext multiline">{{ display(info.questionContent) }}</span>
          </div>
        </el-col>
      </el-row>
      <el-row :gutter="20" class="mb8">
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">题型：</label>
            <span class="info-value plaintext">
              <dict-tag :options="interview_question_type" :value="info.questionType" />
            </span>
          </div>
        </el-col>
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">行业：</label>
            <span class="info-value plaintext">
              <dict-tag :options="student_industry" :value="info.industry" />
            </span>
          </div>
        </el-col>
      </el-row>
      <el-row :gutter="20" class="mb8">
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">难度：</label>
            <span class="info-value plaintext">
              <dict-tag :options="student_difficulty" :value="info.difficulty" />
            </span>
          </div>
        </el-col>
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">企业类型：</label>
            <span class="info-value plaintext">
              <dict-tag :options="student_company_type" :value="info.companyType" />
            </span>
          </div>
        </el-col>
      </el-row>
      <el-row :gutter="20" class="mb8">
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">岗位名称：</label>
            <span class="info-value plaintext">{{ display(info.jobName) }}</span>
          </div>
        </el-col>
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">来源：</label>
            <span class="info-value plaintext">
              <dict-tag :options="question_bank_source" :value="info.source" />
            </span>
          </div>
        </el-col>
      </el-row>
      <el-row :gutter="20" class="mb8">
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">标签：</label>
            <span class="info-value plaintext">{{ display(info.tags) }}</span>
          </div>
        </el-col>
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">被使用次数：</label>
            <span class="info-value plaintext">{{ display(info.useCount) }}</span>
          </div>
        </el-col>
      </el-row>

      <h4 class="section-header">参考答案</h4>
      <div class="info-item">
        <label class="info-label">参考答案：</label>
        <span class="info-value plaintext multiline">{{ display(info.referenceAnswer) }}</span>
      </div>
      <div class="info-item">
        <label class="info-label">关键要点：</label>
        <span class="info-value plaintext">
          <ul v-if="keyPointList.length" class="key-point-list">
            <li v-for="(point, index) in keyPointList" :key="index">{{ point }}</li>
          </ul>
          <span v-else class="text-muted">—</span>
        </span>
      </div>

      <h4 class="section-header">其他</h4>
      <el-row :gutter="20" class="mb8">
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">收录时间：</label>
            <span class="info-value plaintext">{{ parseTime(info.createTime, '{y}-{m}-{d}') || '—' }}</span>
          </div>
        </el-col>
        <el-col v-if="canViewAll" :span="12">
          <div class="info-item">
            <label class="info-label">状态：</label>
            <span class="info-value plaintext">
              <dict-tag :options="sys_normal_disable" :value="info.status" />
            </span>
          </div>
        </el-col>
      </el-row>
    </div>
  </el-drawer>
</template>

<script setup name="BankViewDrawer">
import { getBank } from '@/api/interview/bank'
import { checkPermi } from '@/utils/permission'

const {
  interview_question_type,
  student_industry,
  student_difficulty,
  student_company_type,
  question_bank_source,
  sys_normal_disable
} = useDict(
  'interview_question_type',
  'student_industry',
  'student_difficulty',
  'student_company_type',
  'question_bank_source',
  'sys_normal_disable'
)

/** 只有拥有全量数据权限的账号才需要看到「状态」——学生根本查不到停用题目 */
const canViewAll = computed(() => checkPermi(['interview:data:all']))

const visible = ref(false)
const loading = ref(false)
const info = reactive({})
const keyPointList = ref([])

/** 空值统一显示为「—」 */
function display(value) {
  return value === null || value === undefined || value === '' ? '—' : value
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

const open = async (id) => {
  visible.value = true
  loading.value = true
  try {
    const res = await getBank(id)
    const data = res.data || {}
    Object.assign(info, data)
    keyPointList.value = resolveKeyPoints(data.keyPoints)
  } catch (error) {
    console.error('获取题库题目信息失败:', error)
  } finally {
    loading.value = false
  }
}

function handleClose() {
  visible.value = false
  Object.keys(info).forEach(key => delete info[key])
  keyPointList.value = []
}

defineExpose({ open })
</script>

<style scoped>
.multiline {
  white-space: pre-wrap;
  word-break: break-word;
}

.key-point-list {
  margin: 0;
  padding-left: 18px;
}

.key-point-list li {
  line-height: 1.8;
}

.text-muted {
  color: #c0c4cc;
}
</style>
