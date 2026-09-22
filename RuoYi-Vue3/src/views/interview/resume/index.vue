<template>
  <div class="app-container">
    <!-- 查询区：只保留「简历名称」 -->
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="简历名称" prop="resumeName">
        <el-input
          v-model="queryParams.resumeName"
          placeholder="请输入简历名称"
          clearable
          style="width: 220px"
          @keyup.enter="handleQuery"
        />
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
      <el-table-column label="简历名称" align="center" prop="resumeName" :show-overflow-tooltip="true" />
      <el-table-column label="文件" align="center" width="90">
        <template #default="scope">
          <el-link
            v-if="scope.row.fileUrl"
            type="primary"
            :href="resolveFileUrl(scope.row.fileUrl)"
            target="_blank"
            rel="noopener"
            :underline="false"
          >查看</el-link>
          <span v-else class="text-muted">—</span>
        </template>
      </el-table-column>
      <el-table-column label="类型" align="center" prop="fileType" width="80">
        <template #default="scope">
          <span v-if="scope.row.fileType">{{ scope.row.fileType }}</span>
          <span v-else class="text-muted">—</span>
        </template>
      </el-table-column>
      <el-table-column label="来源" align="center" prop="sourceType" width="110">
        <template #default="scope">
          <dict-tag :options="student_resume_source" :value="scope.row.sourceType"/>
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

    <!-- 添加或修改学生简历对话框 -->
    <el-dialog :title="title" v-model="open" width="640px" append-to-body>
      <el-form ref="resumeRef" :model="form" :rules="rules" label-width="100px">
        <el-row :gutter="20">
          <el-col :span="24">
            <el-form-item label="简历名称" prop="resumeName">
              <el-input
                v-model="form.resumeName"
                placeholder="如：Java 后端开发-校招版"
                maxlength="100"
                show-word-limit
              />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="简历文件" prop="fileUrl">
              <file-upload
                v-model="form.fileUrl"
                :limit="1"
                :fileSize="10"
                :fileType="['pdf', 'doc', 'docx']"
              />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="来源" prop="sourceType">
              <el-select v-model="form.sourceType" placeholder="请选择来源" style="width: 100%">
                <el-option
                  v-for="dict in student_resume_source"
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
              <span class="form-tip">设为默认后，你名下的其他简历会自动取消默认（同时只允许一个默认）。</span>
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
                placeholder="给自己看的备注"
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

<script setup name="Resume">
import { listResume, getResume, delResume, addResume, updateResume } from "@/api/interview/resume"

const { proxy } = getCurrentInstance()
const { student_resume_source } = useDict('student_resume_source')

const baseUrl = import.meta.env.VITE_APP_BASE_API

/** 可维护字段的白名单：status / parse_* 由系统维护，不参与提交 */
const EDITABLE_FIELDS = ['resumeName', 'fileUrl', 'sourceType', 'isDefault', 'remark']

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
    resumeName: undefined
  },
  rules: {
    resumeName: [
      { required: true, message: "简历名称不能为空", trigger: "blur" }
    ],
    fileUrl: [
      { required: true, message: "请上传简历文件", trigger: "change" }
    ]
  }
})

const { queryParams, form, rules } = toRefs(data)

/** 把上传返回的相对地址补成完整地址（已是 http 开头的不动） */
function resolveFileUrl(url) {
  if (!url) return ''
  return /^https?:\/\//i.test(url) ? url : baseUrl + url
}

/** 从文件地址推文件类型：若依上传接口只返回 url，不返回类型 */
function resolveFileType(url) {
  if (!url) return ''
  const clean = String(url).split('?')[0].split('#')[0]
  const dot = clean.lastIndexOf('.')
  if (dot < 0) return ''
  const ext = clean.slice(dot + 1).toLowerCase()
  return ext.length > 0 && ext.length <= 20 ? ext : ''
}

/** 查询学生简历列表 */
function getList() {
  loading.value = true
  listResume(queryParams.value).then(response => {
    resumeList.value = response.rows
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
    resumeName: null,
    fileUrl: null,
    fileType: null,
    sourceType: "1",
    isDefault: "0",
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
  title.value = "新增简历"
}

/** 修改按钮操作 */
function handleUpdate(row) {
  reset()
  const _id = row.id || ids.value
  getResume(_id).then(response => {
    const detail = response.data || {}
    form.value = {
      id: detail.id,
      resumeName: detail.resumeName,
      fileUrl: detail.fileUrl,
      fileType: detail.fileType,
      sourceType: detail.sourceType || "1",
      isDefault: detail.isDefault || "0",
      remark: detail.remark
    }
    open.value = true
    title.value = "修改简历"
  })
}

/** 提交按钮 */
function submitForm() {
  proxy.$refs["resumeRef"].validate(valid => {
    if (!valid) return
    const payload = { id: form.value.id }
    EDITABLE_FIELDS.forEach(field => {
      payload[field] = form.value[field]
    })
    // 文件类型由文件地址推导，学生不手填
    payload.fileType = resolveFileType(payload.fileUrl)
    const action = form.value.id ? updateResume(payload) : addResume(payload)
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
  proxy.$modal.confirm('是否确认删除所选简历？').then(function() {
    return delResume(_ids)
  }).then(() => {
    getList()
    proxy.$modal.msgSuccess("删除成功")
  }).catch(() => {})
}

/** 导出按钮操作 */
function handleExport() {
  proxy.download('interview/resume/export', {
    ...queryParams.value
  }, `resume_${new Date().getTime()}.xlsx`)
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
