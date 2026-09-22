<template>
  <el-drawer title="面试题目详情" v-model="visible" direction="rtl" size="60%" append-to-body :before-close="handleClose" class="detail-drawer">
    <div v-loading="loading" class="drawer-content">
      <h4 class="section-header">题目信息</h4>
      <el-row :gutter="20" class="mb8">
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">题号：</label>
            <span class="info-value plaintext">第 {{ display(info.questionNo) }} 题</span>
          </div>
        </el-col>
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">题型：</label>
            <span class="info-value">
              <dict-tag :options="interview_question_type" :value="info.questionType" />
            </span>
          </div>
        </el-col>
      </el-row>
      <el-row :gutter="20" class="mb8">
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">来源：</label>
            <span class="info-value">
              <dict-tag :options="interview_question_source" :value="info.source" />
            </span>
          </div>
        </el-col>
      </el-row>
      <div class="block">
        <div class="block-title">题干内容</div>
        <div class="block-body multiline">{{ display(info.questionContent) }}</div>
      </div>

      <h4 class="section-header">我的作答</h4>
      <template v-if="answer">
        <el-row :gutter="20" class="mb8">
          <el-col :span="12">
            <div class="info-item">
              <label class="info-label">作答时间：</label>
              <span class="info-value plaintext">
                {{ parseTime(answer.answerTime, '{y}-{m}-{d} {h}:{i}') || '—' }}
              </span>
            </div>
          </el-col>
          <el-col :span="12">
            <div class="info-item">
              <label class="info-label">作答耗时：</label>
              <span class="info-value plaintext">{{ formatDuration(answer.duration) }}</span>
            </div>
          </el-col>
        </el-row>
        <el-row :gutter="20" class="mb8">
          <el-col :span="12">
            <div class="info-item">
              <label class="info-label">作答方式：</label>
              <span class="info-value">
                <dict-tag :options="interview_answer_type" :value="answer.answerType" />
              </span>
            </div>
          </el-col>
          <el-col :span="12">
            <div class="info-item">
              <label class="info-label">本题得分：</label>
              <span class="info-value plaintext">
                {{ answer.score == null ? '待评分' : answer.score }}
              </span>
            </div>
          </el-col>
        </el-row>
        <div class="block">
          <div class="block-title">作答内容</div>
          <div class="block-body multiline">{{ display(answer.answerContent) }}</div>
        </div>
      </template>
      <div v-else class="locked">本题还没有作答</div>

      <h4 class="section-header">参考答案</h4>
      <template v-if="canReveal">
        <div class="block">
          <div class="block-title">参考答案</div>
          <div class="block-body multiline">{{ display(info.referenceAnswer) }}</div>
        </div>
        <div class="block">
          <div class="block-title">关键要点</div>
          <ul v-if="keyPointList.length" class="key-point-list">
            <li v-for="(point, index) in keyPointList" :key="index">{{ point }}</li>
          </ul>
          <div v-else class="block-body text-muted">—</div>
        </div>
      </template>
      <div v-else class="locked">提交本题的作答后即可查看参考答案</div>
    </div>
  </el-drawer>
</template>

<script setup name="QuestionViewDrawer">
import { getQuestion } from '@/api/interview/question'

const props = defineProps({
  /** 该场已提交的作答，按 questionId 索引 */
  qaMap: {
    type: Object,
    default: () => ({})
  },
  /** 所属场次状态：'2'（已完成）时整场参考答案都可见 */
  sessionStatus: {
    type: String,
    default: undefined
  }
})

const {
  interview_question_type,
  interview_question_source,
  interview_answer_type
} = useDict('interview_question_type', 'interview_question_source', 'interview_answer_type')

const visible = ref(false)
const loading = ref(false)
const info = reactive({})
const keyPointList = ref([])

/** 本题的作答记录，没有则为 null */
const answer = computed(() => props.qaMap[info.id] || null)

/** 决策 1：场次已完成，或本题已有作答记录 → 参考答案可见 */
const canReveal = computed(() => props.sessionStatus === '2' || !!answer.value)

/** 空值统一显示为「—」 */
function display(value) {
  return value === null || value === undefined || value === '' ? '—' : value
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
    const res = await getQuestion(id)
    const data = res.data || {}
    Object.assign(info, data)
    keyPointList.value = resolveKeyPoints(data.keyPoints)
  } catch (error) {
    console.error('获取面试题目信息失败:', error)
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
.block {
  margin-bottom: 16px;
}

.block-title {
  font-size: 13px;
  color: #606266;
  margin-bottom: 6px;
}

.block-body {
  font-size: 13px;
  line-height: 1.8;
  color: #303133;
  padding: 10px 12px;
  background: #f8f9fb;
  border-radius: 6px;
}

.multiline {
  white-space: pre-wrap;
  word-break: break-word;
}

.key-point-list {
  margin: 0;
  padding: 10px 12px 10px 30px;
  background: #f8f9fb;
  border-radius: 6px;
}

.key-point-list li {
  font-size: 13px;
  line-height: 1.8;
  color: #303133;
}

.locked {
  font-size: 13px;
  color: #909399;
  padding: 14px 12px;
  background: #f8f9fb;
  border: 1px dashed #dcdfe6;
  border-radius: 6px;
  text-align: center;
}

.text-muted {
  color: #c0c4cc;
}
</style>
