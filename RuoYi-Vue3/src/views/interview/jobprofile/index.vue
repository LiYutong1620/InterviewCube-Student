<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="岗位名称(如Java开发、产品经理)" prop="jobName">
        <el-input
          v-model="queryParams.jobName"
          placeholder="请输入岗位名称(如Java开发、产品经理)"
          clearable
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item label="是否默认(0否 1是)" prop="isDefault">
        <el-select v-model="queryParams.isDefault" placeholder="请选择是否默认(0否 1是)" clearable>
          <el-option
            v-for="dict in sys_yes_no"
            :key="dict.value"
            :label="dict.label"
            :value="dict.value"
          />
        </el-select>
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
      <el-table-column label="主键ID" align="center" prop="id" />
      <el-table-column label="所属学生用户ID" align="center" prop="userId" />
      <el-table-column label="行业(技术/产品/运营/财务/教师)" align="center" prop="industry" />
      <el-table-column label="岗位名称(如Java开发、产品经理)" align="center" prop="jobName" />
      <el-table-column label="难度(1初级 2中级 3高级)" align="center" prop="difficulty" />
      <el-table-column label="目标企业类型(BAT/央企/外企/其他)" align="center" prop="companyType" />
      <el-table-column label="是否默认(0否 1是)" align="center" prop="isDefault">
        <template #default="scope">
          <dict-tag :options="sys_yes_no" :value="scope.row.isDefault"/>
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
          <el-button link type="primary" icon="View" @click="handleViewData(scope.row)" v-hasPermi="['interview:jobprofile:query']">详情</el-button>
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

    <!-- 学生岗位画像详情抽屉 -->
    <jobprofile-view-drawer ref="jobprofileViewRef" />
    <!-- 添加或修改学生岗位画像对话框 -->
    <el-dialog :title="title" v-model="open" width="800px" append-to-body>
      <el-form ref="jobprofileRef" :model="form" :rules="rules" label-width="100px">
        <el-row>
          <el-col :span="12">
            <el-form-item label="岗位名称(如Java开发、产品经理)" prop="jobName">
              <el-input v-model="form.jobName" placeholder="请输入岗位名称(如Java开发、产品经理)" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="是否默认(0否 1是)" prop="isDefault">
              <el-radio-group v-model="form.isDefault">
                <el-radio
                  v-for="dict in sys_yes_no"
                  :key="dict.value"
                  :label="dict.value"
                >{{dict.label}}</el-radio>
              </el-radio-group>
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

<script setup name="Jobprofile">
import { listJobprofile, getJobprofile, delJobprofile, addJobprofile, updateJobprofile } from "@/api/interview/jobprofile"
import JobprofileViewDrawer from "./view"

const { proxy } = getCurrentInstance()
const { sys_yes_no, sys_normal_disable } = useDict('sys_yes_no', 'sys_normal_disable')

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
    jobName: undefined,
    difficulty: undefined,
    companyType: undefined,
    isDefault: undefined,
    status: undefined,
  },
  rules: {
    industry: [
      { required: true, message: "行业(技术/产品/运营/财务/教师)不能为空", trigger: "change" }
    ],
    jobName: [
      { required: true, message: "岗位名称(如Java开发、产品经理)不能为空", trigger: "blur" }
    ],
    difficulty: [
      { required: true, message: "难度(1初级 2中级 3高级)不能为空", trigger: "change" }
    ],
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
    userId: null,
    industry: null,
    jobName: null,
    difficulty: null,
    companyType: null,
    isDefault: null,
    status: null,
    delFlag: null,
    createBy: null,
    createTime: null,
    updateBy: null,
    updateTime: null,
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
  title.value = "添加学生岗位画像"
}

/** 修改按钮操作 */
function handleUpdate(row) {
  reset()
  const _id = row.id || ids.value
  getJobprofile(_id).then(response => {
    form.value = response.data
    open.value = true
    title.value = "修改学生岗位画像"
  })
}

/** 提交按钮 */
function submitForm() {
  proxy.$refs["jobprofileRef"].validate(valid => {
    if (valid) {
      if (form.value.id != null) {
        updateJobprofile(form.value).then(() => {
          proxy.$modal.msgSuccess("修改成功")
          open.value = false
          getList()
        })
      } else {
        addJobprofile(form.value).then(() => {
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
  proxy.$modal.confirm('是否确认删除学生岗位画像编号为"' + _ids + '"的数据项？').then(function() {
    return delJobprofile(_ids)
  }).then(() => {
    getList()
    proxy.$modal.msgSuccess("删除成功")
  }).catch(() => {})
}

/** 详情按钮操作 */
function handleViewData(row) {
  proxy.$refs["jobprofileViewRef"].open(row.id)
}

/** 导出按钮操作 */
function handleExport() {
  proxy.download('interview/jobprofile/export', {
    ...queryParams.value
  }, `jobprofile_${new Date().getTime()}.xlsx`)
}

getList()
</script>
