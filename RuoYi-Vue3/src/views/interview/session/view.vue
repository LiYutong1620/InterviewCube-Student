<template>
  <el-drawer title="模拟面试场次详情" v-model="visible" direction="rtl" size="60%" append-to-body :before-close="handleClose" class="detail-drawer">
    <div v-loading="loading" class="drawer-content">
      <h4 class="section-header">基本信息</h4>
      <el-row :gutter="20" class="mb8">
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">面试场次编号：</label>
            <span class="info-value plaintext">
              {{ info.sessionNo }}
            </span>
          </div>
        </el-col>
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">所属学生用户ID：</label>
            <span class="info-value plaintext">
              {{ info.userId }}
            </span>
          </div>
        </el-col>
      </el-row>
      <el-row :gutter="20" class="mb8">
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">关联岗位画像ID：</label>
            <span class="info-value plaintext">
              {{ info.jobProfileId }}
            </span>
          </div>
        </el-col>
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">行业：</label>
            <span class="info-value plaintext">
              {{ info.industry }}
            </span>
          </div>
        </el-col>
      </el-row>
      <el-row :gutter="20" class="mb8">
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">岗位名称：</label>
            <span class="info-value plaintext">
              {{ info.jobName }}
            </span>
          </div>
        </el-col>
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">难度(1初级 2中级 3高级)：</label>
            <span class="info-value plaintext">
              {{ info.difficulty }}
            </span>
          </div>
        </el-col>
      </el-row>
      <el-row :gutter="20" class="mb8">
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">题型(行为面/技术面/HR面/case面)：</label>
            <span class="info-value plaintext">
              {{ info.questionType }}
            </span>
          </div>
        </el-col>
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">题目总数：</label>
            <span class="info-value plaintext">
              {{ info.totalCount }}
            </span>
          </div>
        </el-col>
      </el-row>
      <el-row :gutter="20" class="mb8">
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">已答题数：</label>
            <span class="info-value plaintext">
              {{ info.answeredCount }}
            </span>
          </div>
        </el-col>
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">状态(0未开始 1进行中 2已完成 3已中断)：</label>
            <span class="info-value plaintext">
              {{ info.status }}
            </span>
          </div>
        </el-col>
      </el-row>
      <el-row :gutter="20" class="mb8">
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">本场总分：</label>
            <span class="info-value plaintext">
              {{ info.score }}
            </span>
          </div>
        </el-col>
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">开始时间：</label>
            <span class="info-value plaintext">
              {{ parseTime(info.startTime, '{y}-{m}-{d}') }}
            </span>
          </div>
        </el-col>
      </el-row>
      <el-row :gutter="20" class="mb8">
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">结束时间：</label>
            <span class="info-value plaintext">
              {{ parseTime(info.endTime, '{y}-{m}-{d}') }}
            </span>
          </div>
        </el-col>
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">面试时长(秒)：</label>
            <span class="info-value plaintext">
              {{ info.duration }}
            </span>
          </div>
        </el-col>
      </el-row>
      <el-row :gutter="20" class="mb8">
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">创建者：</label>
            <span class="info-value plaintext">
              {{ info.createBy }}
            </span>
          </div>
        </el-col>
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">创建时间：</label>
            <span class="info-value plaintext">
              {{ parseTime(info.createTime, '{y}-{m}-{d}') }}
            </span>
          </div>
        </el-col>
      </el-row>
      <el-row :gutter="20" class="mb8">
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">更新者：</label>
            <span class="info-value plaintext">
              {{ info.updateBy }}
            </span>
          </div>
        </el-col>
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">更新时间：</label>
            <span class="info-value plaintext">
              {{ parseTime(info.updateTime, '{y}-{m}-{d}') }}
            </span>
          </div>
        </el-col>
      </el-row>
    </div>
  </el-drawer>
</template>

<script setup name="SessionViewDrawer">
import { getSession } from '@/api/interview/session'


const visible = ref(false)
const loading = ref(false)
const info = reactive({})

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
