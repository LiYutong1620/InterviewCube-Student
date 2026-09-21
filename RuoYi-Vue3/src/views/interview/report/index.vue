<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="报告编号" prop="reportNo">
        <el-input
          v-model="queryParams.reportNo"
          placeholder="请输入报告编号"
          clearable
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item label="关联面试场次ID" prop="sessionId">
        <el-input
          v-model="queryParams.sessionId"
          placeholder="请输入关联面试场次ID"
          clearable
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item label="状态(0正常 1停用)" prop="status">
        <el-select v-model="queryParams.status" placeholder="请选择状态(0正常 1停用)" clearable>
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

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button
          type="primary"
          plain
          icon="Plus"
          @click="handleAdd"
          v-hasPermi="['interview:report:add']"
        >新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="success"
          plain
          icon="Edit"
          :disabled="single"
          @click="handleUpdate"
          v-hasPermi="['interview:report:edit']"
        >修改</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="danger"
          plain
          icon="Delete"
          :disabled="multiple"
          @click="handleDelete"
          v-hasPermi="['interview:report:remove']"
        >删除</el-button>
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

    <el-table v-loading="loading" :data="reportList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="主键ID" align="center" prop="id" />
      <el-table-column label="报告编号" align="center" prop="reportNo" />
      <el-table-column label="关联面试场次ID" align="center" prop="sessionId" />
      <el-table-column label="所属学生用户ID" align="center" prop="userId" />
      <el-table-column label="总分" align="center" prop="totalScore" />
      <el-table-column label="完整性得分" align="center" prop="scoreCompleteness" />
      <el-table-column label="逻辑性得分" align="center" prop="scoreLogic" />
      <el-table-column label="流畅度得分" align="center" prop="scoreFluency" />
      <el-table-column label="深度得分" align="center" prop="scoreDepth" />
      <el-table-column label="自信度得分" align="center" prop="scoreConfidence" />
      <el-table-column label="生成状态(0待生成 1生成中 2成功 3失败)" align="center" prop="generateStatus" />
      <el-table-column label="生成完成时间" align="center" prop="generateTime" width="180">
        <template #default="scope">
          <span>{{ parseTime(scope.row.generateTime, '{y}-{m}-{d}') }}</span>
        </template>
      </el-table-column>
      <el-table-column label="状态(0正常 1停用)" align="center" prop="status">
        <template #default="scope">
          <dict-tag :options="sys_normal_disable" :value="scope.row.status"/>
        </template>
      </el-table-column>
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
          <el-button link type="primary" icon="View" @click="handleViewData(scope.row)" v-hasPermi="['interview:report:query']">详情</el-button>
          <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-hasPermi="['interview:report:edit']">修改</el-button>
          <el-button link type="primary" icon="Delete" @click="handleDelete(scope.row)" v-hasPermi="['interview:report:remove']">删除</el-button>
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

    <!-- 面试复盘报告详情抽屉 -->
    <report-view-drawer ref="reportViewRef" />
    <!-- 添加或修改面试复盘报告对话框 -->
    <el-dialog :title="title" v-model="open" width="800px" append-to-body>
      <el-form ref="reportRef" :model="form" :rules="rules" label-width="100px">
        <el-row>
          <el-col :span="12">
            <el-form-item label="报告编号" prop="reportNo">
              <el-input v-model="form.reportNo" placeholder="请输入报告编号" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="关联面试场次ID" prop="sessionId">
              <el-input v-model="form.sessionId" placeholder="请输入关联面试场次ID" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="总分" prop="totalScore">
              <el-input v-model="form.totalScore" placeholder="请输入总分" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="完整性得分" prop="scoreCompleteness">
              <el-input v-model="form.scoreCompleteness" placeholder="请输入完整性得分" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="逻辑性得分" prop="scoreLogic">
              <el-input v-model="form.scoreLogic" placeholder="请输入逻辑性得分" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="流畅度得分" prop="scoreFluency">
              <el-input v-model="form.scoreFluency" placeholder="请输入流畅度得分" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="深度得分" prop="scoreDepth">
              <el-input v-model="form.scoreDepth" placeholder="请输入深度得分" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="自信度得分" prop="scoreConfidence">
              <el-input v-model="form.scoreConfidence" placeholder="请输入自信度得分" />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="雷达图数据(JSON)" prop="radarData">
              <el-input v-model="form.radarData" type="textarea" placeholder="请输入内容" />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="报告总结" prop="summary">
              <el-input v-model="form.summary" type="textarea" placeholder="请输入内容" />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="薄弱点(JSON数组)" prop="weakPoints">
              <el-input v-model="form.weakPoints" type="textarea" placeholder="请输入内容" />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="改进建议" prop="suggest">
              <el-input v-model="form.suggest" type="textarea" placeholder="请输入内容" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="PDF报告地址" prop="pdfUrl">
              <file-upload v-model="form.pdfUrl"/>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="生成完成时间" prop="generateTime">
              <el-date-picker clearable
                v-model="form.generateTime"
                type="date"
                value-format="YYYY-MM-DD"
                placeholder="请选择生成完成时间">
              </el-date-picker>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="状态(0正常 1停用)" prop="status">
              <el-select v-model="form.status" placeholder="请选择状态(0正常 1停用)">
                <el-option
                  v-for="dict in sys_normal_disable"
                  :key="dict.value"
                  :label="dict.label"
                  :value="dict.value"
                ></el-option>
              </el-select>
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

<script setup name="Report">
import { listReport, getReport, delReport, addReport, updateReport } from "@/api/interview/report"
import ReportViewDrawer from "./view"

const { proxy } = getCurrentInstance()
const { sys_normal_disable } = useDict('sys_normal_disable')

const reportList = ref([])
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
    reportNo: undefined,
    sessionId: undefined,
    generateStatus: undefined,
    status: undefined,
  },
  rules: {
    reportNo: [
      { required: true, message: "报告编号不能为空", trigger: "blur" }
    ],
    sessionId: [
      { required: true, message: "关联面试场次ID不能为空", trigger: "blur" }
    ],
  }
})

const { queryParams, form, rules } = toRefs(data)

/** 查询面试复盘报告列表 */
function getList() {
  loading.value = true
  listReport(queryParams.value).then(response => {
    reportList.value = response.rows
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
    reportNo: null,
    sessionId: null,
    userId: null,
    totalScore: null,
    scoreCompleteness: null,
    scoreLogic: null,
    scoreFluency: null,
    scoreDepth: null,
    scoreConfidence: null,
    radarData: null,
    summary: null,
    weakPoints: null,
    suggest: null,
    pdfUrl: null,
    generateStatus: null,
    generateTime: null,
    status: null,
    delFlag: null,
    createBy: null,
    createTime: null,
    updateBy: null,
    updateTime: null,
    remark: null
  }
  proxy.resetForm("reportRef")
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
  title.value = "添加面试复盘报告"
}

/** 修改按钮操作 */
function handleUpdate(row) {
  reset()
  const _id = row.id || ids.value
  getReport(_id).then(response => {
    form.value = response.data
    open.value = true
    title.value = "修改面试复盘报告"
  })
}

/** 提交按钮 */
function submitForm() {
  proxy.$refs["reportRef"].validate(valid => {
    if (valid) {
      if (form.value.id != null) {
        updateReport(form.value).then(() => {
          proxy.$modal.msgSuccess("修改成功")
          open.value = false
          getList()
        })
      } else {
        addReport(form.value).then(() => {
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
  proxy.$modal.confirm('是否确认删除面试复盘报告编号为"' + _ids + '"的数据项？').then(function() {
    return delReport(_ids)
  }).then(() => {
    getList()
    proxy.$modal.msgSuccess("删除成功")
  }).catch(() => {})
}

/** 详情按钮操作 */
function handleViewData(row) {
  proxy.$refs["reportViewRef"].open(row.id)
}

/** 导出按钮操作 */
function handleExport() {
  proxy.download('interview/report/export', {
    ...queryParams.value
  }, `report_${new Date().getTime()}.xlsx`)
}

getList()
</script>
