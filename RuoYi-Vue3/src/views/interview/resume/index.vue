<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="简历名称" prop="resumeName">
        <el-input
          v-model="queryParams.resumeName"
          placeholder="请输入简历名称"
          clearable
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item label="文件类型(pdf/doc/docx/jpg/png)" prop="fileType">
        <el-input
          v-model="queryParams.fileType"
          placeholder="请输入文件类型(pdf/doc/docx/jpg/png)"
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
          v-hasPermi="['interview:resume:add']"
        >新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="success"
          plain
          icon="Edit"
          :disabled="single"
          @click="handleUpdate"
          v-hasPermi="['interview:resume:edit']"
        >修改</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="danger"
          plain
          icon="Delete"
          :disabled="multiple"
          @click="handleDelete"
          v-hasPermi="['interview:resume:remove']"
        >删除</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="warning"
          plain
          icon="Download"
          @click="handleExport"
          v-hasPermi="['interview:resume:export']"
        >导出</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="resumeList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="主键ID" align="center" prop="id" />
      <el-table-column label="所属学生用户ID" align="center" prop="userId" />
      <el-table-column label="简历名称" align="center" prop="resumeName" />
      <el-table-column label="文件类型(pdf/doc/docx/jpg/png)" align="center" prop="fileType" />
      <el-table-column label="来源(1本地上传 2拍照导入)" align="center" prop="sourceType" />
      <el-table-column label="是否默认(0否 1是)" align="center" prop="isDefault">
        <template #default="scope">
          <dict-tag :options="sys_yes_no" :value="scope.row.isDefault"/>
        </template>
      </el-table-column>
      <el-table-column label="解析状态(0未解析 1解析中 2解析成功 3解析失败)" align="center" prop="parseStatus" />
      <el-table-column label="解析完成时间" align="center" prop="parseTime" width="180">
        <template #default="scope">
          <span>{{ parseTime(scope.row.parseTime, '{y}-{m}-{d}') }}</span>
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
          <el-button link type="primary" icon="View" @click="handleViewData(scope.row)" v-hasPermi="['interview:resume:query']">详情</el-button>
          <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-hasPermi="['interview:resume:edit']">修改</el-button>
          <el-button link type="primary" icon="Delete" @click="handleDelete(scope.row)" v-hasPermi="['interview:resume:remove']">删除</el-button>
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

    <!-- 学生简历详情抽屉 -->
    <resume-view-drawer ref="resumeViewRef" />
    <!-- 添加或修改学生简历对话框 -->
    <el-dialog :title="title" v-model="open" width="800px" append-to-body>
      <el-form ref="resumeRef" :model="form" :rules="rules" label-width="100px">
        <el-row>
          <el-col :span="12">
            <el-form-item label="简历名称" prop="resumeName">
              <el-input v-model="form.resumeName" placeholder="请输入简历名称" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="简历文件地址" prop="fileUrl">
              <file-upload v-model="form.fileUrl"/>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="文件类型(pdf/doc/docx/jpg/png)" prop="fileType">
              <el-input v-model="form.fileType" placeholder="请输入文件类型(pdf/doc/docx/jpg/png)" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="文件大小(字节)" prop="fileSize">
              <el-input v-model="form.fileSize" placeholder="请输入文件大小(字节)" />
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
          <el-col :span="24">
            <el-form-item label="AI解析结果(JSON)" prop="parseResult">
              <el-input v-model="form.parseResult" type="textarea" placeholder="请输入内容" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="解析完成时间" prop="parseTime">
              <el-date-picker clearable
                v-model="form.parseTime"
                type="date"
                value-format="YYYY-MM-DD"
                placeholder="请选择解析完成时间">
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

<script setup name="Resume">
import { listResume, getResume, delResume, addResume, updateResume } from "@/api/interview/resume"
import ResumeViewDrawer from "./view"

const { proxy } = getCurrentInstance()
const { sys_yes_no, sys_normal_disable } = useDict('sys_yes_no', 'sys_normal_disable')

const resumeList = ref([])
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
    resumeName: undefined,
    fileType: undefined,
    sourceType: undefined,
    isDefault: undefined,
    parseStatus: undefined,
    status: undefined,
  },
  rules: {
    resumeName: [
      { required: true, message: "简历名称不能为空", trigger: "blur" }
    ],
    fileUrl: [
      { required: true, message: "简历文件地址不能为空", trigger: "blur" }
    ],
  }
})

const { queryParams, form, rules } = toRefs(data)

/** 查询学生简历列表 */
function getList() {
  loading.value = true
  listResume(queryParams.value).then(response => {
    resumeList.value = response.rows
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
    resumeName: null,
    fileUrl: null,
    fileType: null,
    fileSize: null,
    sourceType: null,
    isDefault: null,
    parseStatus: null,
    parseResult: null,
    parseTime: null,
    status: null,
    delFlag: null,
    createBy: null,
    createTime: null,
    updateBy: null,
    updateTime: null,
    remark: null
  }
  proxy.resetForm("resumeRef")
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
  title.value = "添加学生简历"
}

/** 修改按钮操作 */
function handleUpdate(row) {
  reset()
  const _id = row.id || ids.value
  getResume(_id).then(response => {
    form.value = response.data
    open.value = true
    title.value = "修改学生简历"
  })
}

/** 提交按钮 */
function submitForm() {
  proxy.$refs["resumeRef"].validate(valid => {
    if (valid) {
      if (form.value.id != null) {
        updateResume(form.value).then(() => {
          proxy.$modal.msgSuccess("修改成功")
          open.value = false
          getList()
        })
      } else {
        addResume(form.value).then(() => {
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
  proxy.$modal.confirm('是否确认删除学生简历编号为"' + _ids + '"的数据项？').then(function() {
    return delResume(_ids)
  }).then(() => {
    getList()
    proxy.$modal.msgSuccess("删除成功")
  }).catch(() => {})
}

/** 详情按钮操作 */
function handleViewData(row) {
  proxy.$refs["resumeViewRef"].open(row.id)
}

/** 导出按钮操作 */
function handleExport() {
  proxy.download('interview/resume/export', {
    ...queryParams.value
  }, `resume_${new Date().getTime()}.xlsx`)
}

getList()
</script>
