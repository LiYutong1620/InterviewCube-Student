<template>
  <div class="app-container">
    <!-- 查询区：只保留有筛选意义的两个条件 -->
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-width="68px">
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
          @click="handleAdd"
          v-hasPermi="['interview:jobprofile:add']"
        >新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="success"
          plain
          icon="Edit"
          :disabled="single"
          @click="handleUpdate"
          v-hasPermi="['interview:jobprofile:edit']"
        >修改</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="danger"
          plain
          icon="Delete"
          :disabled="multiple"
          @click="handleDelete"
          v-hasPermi="['interview:jobprofile:remove']"
        >删除</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="warning"
          plain
          icon="Download"
          @click="handleExport"
          v-hasPermi="['interview:jobprofile:export']"
        >导出</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="jobprofileList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="岗位名称" align="center" prop="jobName" :show-overflow-tooltip="true" />
      <el-table-column label="行业" align="center" prop="industry" width="100">
        <template #default="scope">
          <dict-tag :options="student_industry" :value="scope.row.industry"/>
        </template>
      </el-table-column>
      <el-table-column label="难度" align="center" prop="difficulty" width="100">
        <template #default="scope">
          <dict-tag :options="student_difficulty" :value="scope.row.difficulty"/>
        </template>
      </el-table-column>
      <el-table-column label="目标企业类型" align="center" prop="companyType" width="130">
        <template #default="scope">
          <dict-tag :options="student_company_type" :value="scope.row.companyType"/>
        </template>
      </el-table-column>
      <el-table-column label="默认" align="center" prop="isDefault" width="90">
        <template #default="scope">
          <el-tag v-if="scope.row.isDefault === '1'" type="success" disable-transitions>默认</el-tag>
          <span v-else class="text-muted">—</span>
        </template>
      </el-table-column>
      <el-table-column label="创建时间" align="center" prop="createTime" width="120">
        <template #default="scope">
          <span>{{ parseTime(scope.row.createTime, '{y}-{m}-{d}') }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" width="160" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-hasPermi="['interview:jobprofile:edit']">修改</el-button>
          <el-button link type="primary" icon="Delete" @click="handleDelete(scope.row)" v-hasPermi="['interview:jobprofile:remove']">删除</el-button>
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

    <!-- 添加或修改学生岗位画像对话框 -->
    <el-dialog :title="title" v-model="open" width="640px" append-to-body>
      <el-form ref="jobprofileRef" :model="form" :rules="rules" label-width="100px">
        <el-row :gutter="20">
          <el-col :span="24">
            <el-form-item label="岗位名称" prop="jobName">
              <el-input
                v-model="form.jobName"
                placeholder="如：Java 后端开发、产品经理"
                maxlength="100"
                show-word-limit
              />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="行业" prop="industry">
              <el-select v-model="form.industry" placeholder="请选择行业" style="width: 100%">
                <el-option
                  v-for="dict in student_industry"
                  :key="dict.value"
                  :label="dict.label"
                  :value="dict.value"
                />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="难度" prop="difficulty">
              <el-select v-model="form.difficulty" placeholder="请选择难度" style="width: 100%">
                <el-option
                  v-for="dict in student_difficulty"
                  :key="dict.value"
                  :label="dict.label"
                  :value="dict.value"
                />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="目标企业类型" prop="companyType">
              <el-select v-model="form.companyType" placeholder="请选择目标企业类型" clearable style="width: 100%">
                <el-option
                  v-for="dict in student_company_type"
                  :key="dict.value"
                  :label="dict.label"
                  :value="dict.value"
                />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="设为默认" prop="isDefault">
              <el-switch v-model="form.isDefault" active-value="1" inactive-value="0" />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item>
              <span class="form-tip">设为默认后，你名下的其他岗位画像会自动取消默认（同时只允许一个默认）。</span>
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="备注" prop="remark">
              <el-input
                v-model="form.remark"
                type="textarea"
                :rows="3"
                maxlength="500"
                show-word-limit
                placeholder="给自己看的备注，比如为什么想投这个岗位"
              />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" @click="submitForm">确 定</el-button>
          <el-button @click="cancel">取 消</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="Jobprofile">
import { listJobprofile, getJobprofile, delJobprofile, addJobprofile, updateJobprofile } from "@/api/interview/jobprofile"

const { proxy } = getCurrentInstance()
const { student_industry, student_difficulty, student_company_type } = useDict(
  'student_industry',
  'student_difficulty',
  'student_company_type'
)

/** 可维护字段的白名单：status 由系统 / 后台维护，不参与提交 */
const EDITABLE_FIELDS = ['jobName', 'industry', 'difficulty', 'companyType', 'isDefault', 'remark']

const jobprofileList = ref([])
const open = ref(false)
const loading = ref(true)
const showSearch = ref(true)
const ids = ref([])
const single = ref(true)
const multiple = ref(true)
const total = ref(0)
const title = ref("")

const data = reactive({
  form: {},
  queryParams: {
    pageNum: 1,
    pageSize: 10,
    industry: undefined,
    difficulty: undefined
  },
  rules: {
    jobName: [
      { required: true, message: "岗位名称不能为空", trigger: "blur" }
    ],
    industry: [
      { required: true, message: "行业不能为空", trigger: "change" }
    ],
    difficulty: [
      { required: true, message: "难度不能为空", trigger: "change" }
    ]
  }
})

const { queryParams, form, rules } = toRefs(data)

/** 查询学生岗位画像列表 */
function getList() {
  loading.value = true
  listJobprofile(queryParams.value).then(response => {
    jobprofileList.value = response.rows
    total.value = response.total
    loading.value = false
  }).catch(() => {
    loading.value = false
  })
}

/** 取消按钮 */
function cancel() {
  open.value = false
  reset()
}

/** 表单重置 */
function reset() {
  form.value = {
    id: null,
    jobName: null,
    industry: null,
    difficulty: null,
    companyType: null,
    isDefault: "0",
    remark: null
  }
  proxy.resetForm("jobprofileRef")
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

/** 多选框选中数据 */
function handleSelectionChange(selection) {
  ids.value = selection.map(item => item.id)
  single.value = selection.length != 1
  multiple.value = !selection.length
}

/** 新增按钮操作 */
function handleAdd() {
  reset()
  open.value = true
  title.value = "新增目标岗位"
}

/** 修改按钮操作 */
function handleUpdate(row) {
  reset()
  const _id = row.id || ids.value
  getJobprofile(_id).then(response => {
    const detail = response.data || {}
    form.value = {
      id: detail.id,
      jobName: detail.jobName,
      industry: detail.industry,
      difficulty: detail.difficulty,
      companyType: detail.companyType,
      isDefault: detail.isDefault || "0",
      remark: detail.remark
    }
    open.value = true
    title.value = "修改目标岗位"
  })
}

/** 提交按钮 */
function submitForm() {
  proxy.$refs["jobprofileRef"].validate(valid => {
    if (!valid) return
    const payload = { id: form.value.id }
    EDITABLE_FIELDS.forEach(field => {
      payload[field] = form.value[field]
    })
    const action = form.value.id ? updateJobprofile(payload) : addJobprofile(payload)
    action.then(() => {
      proxy.$modal.msgSuccess(form.value.id ? "修改成功" : "新增成功")
      open.value = false
      getList()
    }).catch(() => {})
  })
}

/** 删除按钮操作 */
function handleDelete(row) {
  const _ids = row.id || ids.value
  proxy.$modal.confirm('是否确认删除所选的目标岗位？').then(function() {
    return delJobprofile(_ids)
  }).then(() => {
    getList()
    proxy.$modal.msgSuccess("删除成功")
  }).catch(() => {})
}

/** 导出按钮操作 */
function handleExport() {
  proxy.download('interview/jobprofile/export', {
    ...queryParams.value
  }, `jobprofile_${new Date().getTime()}.xlsx`)
}

getList()
</script>

<style scoped>
.text-muted {
  color: #c0c4cc;
}

.form-tip {
  font-size: 12px;
  color: #909399;
  line-height: 1.5;
}
</style>
