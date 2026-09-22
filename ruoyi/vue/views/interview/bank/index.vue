<template>
  <div class="app-container">
    <!-- 查询区：题型 + 行业 + 难度 -->
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="题型" prop="questionType">
        <el-select v-model="queryParams.questionType" placeholder="请选择题型" clearable style="width: 160px">
          <el-option
            v-for="dict in interview_question_type"
            :key="dict.value"
            :label="dict.label"
            :value="dict.value"
          />
        </el-select>
      </el-form-item>
      <el-form-item label="行业" prop="industry">
        <el-select v-model="queryParams.industry" placeholder="请选择行业" clearable style="width: 160px">
          <el-option
            v-for="dict in student_industry"
            :key="dict.value"
            :label="dict.label"
            :value="dict.value"
          />
        </el-select>
      </el-form-item>
      <el-form-item label="难度" prop="difficulty">
        <el-select v-model="queryParams.difficulty" placeholder="请选择难度" clearable style="width: 160px">
          <el-option
            v-for="dict in student_difficulty"
            :key="dict.value"
            :label="dict.label"
            :value="dict.value"
          />
        </el-select>
      </el-form-item>
      <el-form-item v-if="canViewAll" label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="请选择状态" clearable style="width: 160px">
          <el-option
            v-for="dict in sys_normal_disable"
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

    <!-- 题库为全库共享资源，学生端只读：不提供新增 / 修改 / 删除 -->
    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button
          type="warning"
          plain
          icon="Download"
          @click="handleExport"
          v-hasPermi="['interview:bank:export']"
        >导出</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="bankList">
      <el-table-column label="题干" align="left" prop="questionContent" min-width="220" :show-overflow-tooltip="true" />
      <el-table-column label="题型" align="center" prop="questionType" width="100">
        <template #default="scope">
          <dict-tag :options="interview_question_type" :value="scope.row.questionType"/>
        </template>
      </el-table-column>
      <el-table-column label="行业" align="center" prop="industry" width="90">
        <template #default="scope">
          <dict-tag :options="student_industry" :value="scope.row.industry"/>
        </template>
      </el-table-column>
      <el-table-column label="难度" align="center" prop="difficulty" width="90">
        <template #default="scope">
          <dict-tag :options="student_difficulty" :value="scope.row.difficulty"/>
        </template>
      </el-table-column>
      <el-table-column label="企业类型" align="center" prop="companyType" width="100">
        <template #default="scope">
          <dict-tag :options="student_company_type" :value="scope.row.companyType"/>
        </template>
      </el-table-column>
      <el-table-column label="岗位名称" align="center" prop="jobName" width="120" :show-overflow-tooltip="true">
        <template #default="scope">
          <span v-if="scope.row.jobName">{{ scope.row.jobName }}</span>
          <span v-else class="text-muted">—</span>
        </template>
      </el-table-column>
      <el-table-column label="标签" align="center" prop="tags" width="140" :show-overflow-tooltip="true">
        <template #default="scope">
          <span v-if="scope.row.tags">{{ scope.row.tags }}</span>
          <span v-else class="text-muted">—</span>
        </template>
      </el-table-column>
      <el-table-column label="来源" align="center" prop="source" width="100">
        <template #default="scope">
          <dict-tag :options="question_bank_source" :value="scope.row.source"/>
        </template>
      </el-table-column>
      <el-table-column label="参考答案" align="left" prop="referenceAnswer" min-width="200" :show-overflow-tooltip="true">
        <template #default="scope">
          <span v-if="scope.row.referenceAnswer">{{ scope.row.referenceAnswer }}</span>
          <span v-else class="text-muted">—</span>
        </template>
      </el-table-column>
      <el-table-column label="关键要点" align="left" prop="keyPoints" min-width="160" :show-overflow-tooltip="true">
        <template #default="scope">
          <span v-if="scope.row.keyPoints">{{ formatKeyPoints(scope.row.keyPoints) }}</span>
          <span v-else class="text-muted">—</span>
        </template>
      </el-table-column>
      <el-table-column label="被使用次数" align="center" prop="useCount" width="100">
        <template #default="scope">
          <span>{{ scope.row.useCount == null ? '—' : scope.row.useCount }}</span>
        </template>
      </el-table-column>
      <el-table-column v-if="canViewAll" label="状态" align="center" prop="status" width="90">
        <template #default="scope">
          <dict-tag :options="sys_normal_disable" :value="scope.row.status"/>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" width="80" class-name="small-padding fixed-width" fixed="right">
        <template #default="scope">
          <el-button link type="primary" icon="View" @click="handleViewData(scope.row)" v-hasPermi="['interview:bank:query']">查看</el-button>
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

    <!-- 题库题目详情抽屉 -->
    <bank-view-drawer ref="bankViewRef" />
  </div>
</template>

<script setup name="Bank">
import { listBank } from "@/api/interview/bank"
import { checkPermi } from "@/utils/permission"
import BankViewDrawer from "./view"

const { proxy } = getCurrentInstance()
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

const bankList = ref([])
const loading = ref(true)
const showSearch = ref(true)
const total = ref(0)

/**
 * 是否拥有全量数据权限（后台端 / 超管）。
 * 学生没有这个权限：看不到「状态」列与状态筛选，也查不到停用题目（后端会强制 status='0'）。
 * 管理员能看到，用来识别哪些题被停用了。
 */
const canViewAll = computed(() => checkPermi(['interview:data:all']))

const data = reactive({
  queryParams: {
    pageNum: 1,
    pageSize: 10,
    questionType: undefined,
    industry: undefined,
    difficulty: undefined,
    status: undefined
  }
})

const { queryParams } = toRefs(data)

/** 关键要点库里存的是 JSON 数组，列表里拼成「、」分隔的纯文本 */
function formatKeyPoints(raw) {
  if (!raw) return ''
  try {
    const arr = JSON.parse(raw)
    return Array.isArray(arr) ? arr.join('、') : String(raw)
  } catch (e) {
    return String(raw)
  }
}

/** 查询题库题目列表 */
function getList() {
  loading.value = true
  listBank(queryParams.value).then(response => {
    bankList.value = response.rows
    total.value = response.total
    loading.value = false
  }).catch(() => {
    loading.value = false
  })
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

/** 查看详情 */
function handleViewData(row) {
  proxy.$refs["bankViewRef"].open(row.id)
}

/** 导出按钮操作 */
function handleExport() {
  proxy.download('interview/bank/export', {
    ...queryParams.value
  }, `bank_${new Date().getTime()}.xlsx`)
}

getList()
</script>

<style scoped>
.text-muted {
  color: #c0c4cc;
}
</style>
