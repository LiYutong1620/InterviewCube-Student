<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="面试场次编号" prop="sessionNo">
        <el-input
          v-model="queryParams.sessionNo"
          placeholder="请输入面试场次编号"
          clearable
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item label="岗位名称" prop="jobName">
        <el-input
          v-model="queryParams.jobName"
          placeholder="请输入岗位名称"
          clearable
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item label="开始时间" style="width: 308px">
        <el-date-picker
          v-model="daterangeStartTime"
          value-format="YYYY-MM-DD"
          type="daterange"
          range-separator="-"
          start-placeholder="开始日期"
          end-placeholder="结束日期"
        ></el-date-picker>
      </el-form-item>
      <el-form-item label="结束时间" style="width: 308px">
        <el-date-picker
          v-model="daterangeEndTime"
          value-format="YYYY-MM-DD"
          type="daterange"
          range-separator="-"
          start-placeholder="开始日期"
          end-placeholder="结束日期"
        ></el-date-picker>
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
          v-hasPermi="['interview:session:add']"
        >新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="success"
          plain
          icon="Edit"
          :disabled="single"
          @click="handleUpdate"
          v-hasPermi="['interview:session:edit']"
        >修改</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="danger"
          plain
          icon="Delete"
          :disabled="multiple"
          @click="handleDelete"
          v-hasPermi="['interview:session:remove']"
        >删除</el-button>
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

    <el-table v-loading="loading" :data="sessionList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="主键ID" align="center" prop="id" />
      <el-table-column label="面试场次编号" align="center" prop="sessionNo" />
      <el-table-column label="所属学生用户ID" align="center" prop="userId" />
      <el-table-column label="关联岗位画像ID" align="center" prop="jobProfileId" />
      <el-table-column label="行业" align="center" prop="industry" />
      <el-table-column label="岗位名称" align="center" prop="jobName" />
      <el-table-column label="难度(1初级 2中级 3高级)" align="center" prop="difficulty" />
      <el-table-column label="题型(行为面/技术面/HR面/case面)" align="center" prop="questionType" />
      <el-table-column label="题目总数" align="center" prop="totalCount" />
      <el-table-column label="已答题数" align="center" prop="answeredCount" />
      <el-table-column label="状态(0未开始 1进行中 2已完成 3已中断)" align="center" prop="status" />
      <el-table-column label="本场总分" align="center" prop="score" />
      <el-table-column label="开始时间" align="center" prop="startTime" width="180">
        <template #default="scope">
          <span>{{ parseTime(scope.row.startTime, '{y}-{m}-{d}') }}</span>
        </template>
      </el-table-column>
      <el-table-column label="结束时间" align="center" prop="endTime" width="180">
        <template #default="scope">
          <span>{{ parseTime(scope.row.endTime, '{y}-{m}-{d}') }}</span>
        </template>
      </el-table-column>
      <el-table-column label="面试时长(秒)" align="center" prop="duration" />
      <el-table-column label="创建者" align="center" prop="createBy" />
      <el-table-column label="创建时间" align="center" prop="createTime" width="180">
        <template #default="scope">
          <span>{{ parseTime(scope.row.createTime, '{y}-{m}-{d}') }}</span>
        </template>
      </el-table-column>
      <el-table-column label="更新者" align="center" prop="updateBy" />
      <el-table-column label="更新时间" align="center" prop="updateTime" width="180">
        <template #default="scope">
          <span>{{ parseTime(scope.row.updateTime, '{y}-{m}-{d}') }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button link type="primary" icon="View" @click="handleViewData(scope.row)" v-hasPermi="['interview:session:query']">详情</el-button>
          <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-hasPermi="['interview:session:edit']">修改</el-button>
          <el-button link type="primary" icon="Delete" @click="handleDelete(scope.row)" v-hasPermi="['interview:session:remove']">删除</el-button>
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
    <!-- 添加或修改模拟面试场次对话框 -->
    <el-dialog :title="title" v-model="open" width="800px" append-to-body>
      <el-form ref="sessionRef" :model="form" :rules="rules" label-width="100px">
        <el-row>
          <el-col :span="12">
            <el-form-item label="面试场次编号" prop="sessionNo">
              <el-input v-model="form.sessionNo" placeholder="请输入面试场次编号" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="关联岗位画像ID" prop="jobProfileId">
              <el-input v-model="form.jobProfileId" placeholder="请输入关联岗位画像ID" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="岗位名称" prop="jobName">
              <el-input v-model="form.jobName" placeholder="请输入岗位名称" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="题目总数" prop="totalCount">
              <el-input v-model="form.totalCount" placeholder="请输入题目总数" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="已答题数" prop="answeredCount">
              <el-input v-model="form.answeredCount" placeholder="请输入已答题数" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="本场总分" prop="score">
              <el-input v-model="form.score" placeholder="请输入本场总分" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="开始时间" prop="startTime">
              <el-date-picker clearable
                v-model="form.startTime"
                type="date"
                value-format="YYYY-MM-DD"
                placeholder="请选择开始时间">
              </el-date-picker>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="结束时间" prop="endTime">
              <el-date-picker clearable
                v-model="form.endTime"
                type="date"
                value-format="YYYY-MM-DD"
                placeholder="请选择结束时间">
              </el-date-picker>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="面试时长(秒)" prop="duration">
              <el-input v-model="form.duration" placeholder="请输入面试时长(秒)" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="关联复盘报告ID" prop="reportId">
              <el-input v-model="form.reportId" placeholder="请输入关联复盘报告ID" />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="备注" prop="remark">
              <el-input v-model="form.remark" type="textarea" placeholder="请输入内容" />
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

<script setup name="Session">
import { listSession, getSession, delSession, addSession, updateSession } from "@/api/interview/session"
import SessionViewDrawer from "./view"

const { proxy } = getCurrentInstance()

const sessionList = ref([])
const open = ref(false)
const loading = ref(true)
const showSearch = ref(true)
const ids = ref([])
const single = ref(true)
const multiple = ref(true)
const total = ref(0)
const title = ref("")
const daterangeStartTime = ref([])
const daterangeEndTime = ref([])

const data = reactive({
  form: {},
  queryParams: {
    pageNum: 1,
    pageSize: 10,
    sessionNo: undefined,
    industry: undefined,
    jobName: undefined,
    difficulty: undefined,
    questionType: undefined,
    status: undefined,
    startTime: undefined,
    endTime: undefined,
  },
  rules: {
    sessionNo: [
      { required: true, message: "面试场次编号不能为空", trigger: "blur" }
    ],
  }
})

const { queryParams, form, rules } = toRefs(data)

/** 查询模拟面试场次列表 */
function getList() {
  loading.value = true
  queryParams.value.params = {}
  if (null != daterangeStartTime.value && '' != daterangeStartTime.value) {
    queryParams.value.params["beginStartTime"] = daterangeStartTime.value[0]
    queryParams.value.params["endStartTime"] = daterangeStartTime.value[1]
  }
  if (null != daterangeEndTime.value && '' != daterangeEndTime.value) {
    queryParams.value.params["beginEndTime"] = daterangeEndTime.value[0]
    queryParams.value.params["endEndTime"] = daterangeEndTime.value[1]
  }
  listSession(queryParams.value).then(response => {
    sessionList.value = response.rows
    total.value = response.total
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
    sessionNo: null,
    userId: null,
    jobProfileId: null,
    industry: null,
    jobName: null,
    difficulty: null,
    questionType: null,
    totalCount: null,
    answeredCount: null,
    status: null,
    score: null,
    startTime: null,
    endTime: null,
    duration: null,
    reportId: null,
    delFlag: null,
    createBy: null,
    createTime: null,
    updateBy: null,
    updateTime: null,
    remark: null
  }
  proxy.resetForm("sessionRef")
}

/** 搜索按钮操作 */
function handleQuery() {
  queryParams.value.pageNum = 1
  getList()
}

/** 重置按钮操作 */
function resetQuery() {
  daterangeStartTime.value = []
  daterangeEndTime.value = []
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
  title.value = "添加模拟面试场次"
}

/** 修改按钮操作 */
function handleUpdate(row) {
  reset()
  const _id = row.id || ids.value
  getSession(_id).then(response => {
    form.value = response.data
    open.value = true
    title.value = "修改模拟面试场次"
  })
}

/** 提交按钮 */
function submitForm() {
  proxy.$refs["sessionRef"].validate(valid => {
    if (valid) {
      if (form.value.id != null) {
        updateSession(form.value).then(() => {
          proxy.$modal.msgSuccess("修改成功")
          open.value = false
          getList()
        })
      } else {
        addSession(form.value).then(() => {
          proxy.$modal.msgSuccess("新增成功")
          open.value = false
          getList()
        })
      }
    }
  })
}

/** 删除按钮操作 */
function handleDelete(row) {
  const _ids = row.id || ids.value
  proxy.$modal.confirm('是否确认删除模拟面试场次编号为"' + _ids + '"的数据项？').then(function() {
    return delSession(_ids)
  }).then(() => {
    getList()
    proxy.$modal.msgSuccess("删除成功")
  }).catch(() => {})
}

/** 详情按钮操作 */
function handleViewData(row) {
  proxy.$refs["sessionViewRef"].open(row.id)
}

/** 导出按钮操作 */
function handleExport() {
  proxy.download('interview/session/export', {
    ...queryParams.value
  }, `session_${new Date().getTime()}.xlsx`)
}

getList()
</script>
