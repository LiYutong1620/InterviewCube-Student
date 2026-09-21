<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="所属面试场次ID" prop="sessionId">
        <el-input
          v-model="queryParams.sessionId"
          placeholder="请输入所属面试场次ID"
          clearable
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item label="关联面试题目ID" prop="questionId">
        <el-input
          v-model="queryParams.questionId"
          placeholder="请输入关联面试题目ID"
          clearable
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item label="是否追问(0否 1是)" prop="isFollowUp">
        <el-select v-model="queryParams.isFollowUp" placeholder="请选择是否追问(0否 1是)" clearable>
          <el-option
            v-for="dict in sys_yes_no"
            :key="dict.value"
            :label="dict.label"
            :value="dict.value"
          />
        </el-select>
      </el-form-item>
      <el-form-item label="作答时间" style="width: 308px">
        <el-date-picker
          v-model="daterangeAnswerTime"
          value-format="YYYY-MM-DD"
          type="daterange"
          range-separator="-"
          start-placeholder="开始日期"
          end-placeholder="结束日期"
        ></el-date-picker>
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
          v-hasPermi="['interview:qa:add']"
        >新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="success"
          plain
          icon="Edit"
          :disabled="single"
          @click="handleUpdate"
          v-hasPermi="['interview:qa:edit']"
        >修改</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="danger"
          plain
          icon="Delete"
          :disabled="multiple"
          @click="handleDelete"
          v-hasPermi="['interview:qa:remove']"
        >删除</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="warning"
          plain
          icon="Download"
          @click="handleExport"
          v-hasPermi="['interview:qa:export']"
        >导出</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="qaList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="主键ID" align="center" prop="id" />
      <el-table-column label="所属面试场次ID" align="center" prop="sessionId" />
      <el-table-column label="关联面试题目ID" align="center" prop="questionId" />
      <el-table-column label="所属学生用户ID" align="center" prop="userId" />
      <el-table-column label="题干内容(冗余,便于查询)" align="center" prop="questionContent" />
      <el-table-column label="作答内容(文字)" align="center" prop="answerContent" />
      <el-table-column label="作答方式(1文字 2语音 3视频)" align="center" prop="answerType" />
      <el-table-column label="是否追问(0否 1是)" align="center" prop="isFollowUp">
        <template #default="scope">
          <dict-tag :options="sys_yes_no" :value="scope.row.isFollowUp"/>
        </template>
      </el-table-column>
      <el-table-column label="作答时间" align="center" prop="answerTime" width="180">
        <template #default="scope">
          <span>{{ parseTime(scope.row.answerTime, '{y}-{m}-{d}') }}</span>
        </template>
      </el-table-column>
      <el-table-column label="作答耗时(秒)" align="center" prop="duration" />
      <el-table-column label="本题得分" align="center" prop="score" />
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
          <el-button link type="primary" icon="View" @click="handleViewData(scope.row)" v-hasPermi="['interview:qa:query']">详情</el-button>
          <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-hasPermi="['interview:qa:edit']">修改</el-button>
          <el-button link type="primary" icon="Delete" @click="handleDelete(scope.row)" v-hasPermi="['interview:qa:remove']">删除</el-button>
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

    <!-- 面试问答详情抽屉 -->
    <qa-view-drawer ref="qaViewRef" />
    <!-- 添加或修改面试问答对话框 -->
    <el-dialog :title="title" v-model="open" width="800px" append-to-body>
      <el-form ref="qaRef" :model="form" :rules="rules" label-width="100px">
        <el-row>
          <el-col :span="12">
            <el-form-item label="所属面试场次ID" prop="sessionId">
              <el-input v-model="form.sessionId" placeholder="请输入所属面试场次ID" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="关联面试题目ID" prop="questionId">
              <el-input v-model="form.questionId" placeholder="请输入关联面试题目ID" />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="题干内容(冗余,便于查询)" prop="questionContent">
              <el-input v-model="form.questionContent" type="textarea" placeholder="请输入内容" />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="作答内容(文字)" prop="answerContent">
              <el-input v-model="form.answerContent" type="textarea" placeholder="请输入内容" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="语音文件地址" prop="audioUrl">
              <file-upload v-model="form.audioUrl"/>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="视频文件地址" prop="videoUrl">
              <file-upload v-model="form.videoUrl"/>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="是否追问(0否 1是)" prop="isFollowUp">
              <el-radio-group v-model="form.isFollowUp">
                <el-radio
                  v-for="dict in sys_yes_no"
                  :key="dict.value"
                  :label="dict.value"
                >{{dict.label}}</el-radio>
              </el-radio-group>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="上级问答ID(追问时使用)" prop="parentId">
              <el-input v-model="form.parentId" placeholder="请输入上级问答ID(追问时使用)" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="作答时间" prop="answerTime">
              <el-date-picker clearable
                v-model="form.answerTime"
                type="date"
                value-format="YYYY-MM-DD"
                placeholder="请选择作答时间">
              </el-date-picker>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="作答耗时(秒)" prop="duration">
              <el-input v-model="form.duration" placeholder="请输入作答耗时(秒)" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="本题得分" prop="score">
              <el-input v-model="form.score" placeholder="请输入本题得分" />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="AI点评" prop="aiComment">
              <el-input v-model="form.aiComment" type="textarea" placeholder="请输入内容" />
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

<script setup name="Qa">
import { listQa, getQa, delQa, addQa, updateQa } from "@/api/interview/qa"
import QaViewDrawer from "./view"

const { proxy } = getCurrentInstance()
const { sys_yes_no, sys_normal_disable } = useDict('sys_yes_no', 'sys_normal_disable')

const qaList = ref([])
const open = ref(false)
const loading = ref(true)
const showSearch = ref(true)
const ids = ref([])
const single = ref(true)
const multiple = ref(true)
const total = ref(0)
const title = ref("")
const daterangeAnswerTime = ref([])

const data = reactive({
  form: {},
  queryParams: {
    pageNum: 1,
    pageSize: 10,
    sessionId: undefined,
    questionId: undefined,
    questionContent: undefined,
    answerType: undefined,
    isFollowUp: undefined,
    answerTime: undefined,
    status: undefined,
  },
  rules: {
    sessionId: [
      { required: true, message: "所属面试场次ID不能为空", trigger: "blur" }
    ],
    questionId: [
      { required: true, message: "关联面试题目ID不能为空", trigger: "blur" }
    ],
  }
})

const { queryParams, form, rules } = toRefs(data)

/** 查询面试问答列表 */
function getList() {
  loading.value = true
  queryParams.value.params = {}
  if (null != daterangeAnswerTime.value && '' != daterangeAnswerTime.value) {
    queryParams.value.params["beginAnswerTime"] = daterangeAnswerTime.value[0]
    queryParams.value.params["endAnswerTime"] = daterangeAnswerTime.value[1]
  }
  listQa(queryParams.value).then(response => {
    qaList.value = response.rows
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
    sessionId: null,
    questionId: null,
    userId: null,
    questionContent: null,
    answerContent: null,
    answerType: null,
    audioUrl: null,
    videoUrl: null,
    isFollowUp: null,
    parentId: null,
    answerTime: null,
    duration: null,
    score: null,
    aiComment: null,
    status: null,
    delFlag: null,
    createBy: null,
    createTime: null,
    updateBy: null,
    updateTime: null,
    remark: null
  }
  proxy.resetForm("qaRef")
}

/** 搜索按钮操作 */
function handleQuery() {
  queryParams.value.pageNum = 1
  getList()
}

/** 重置按钮操作 */
function resetQuery() {
  daterangeAnswerTime.value = []
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
  title.value = "添加面试问答"
}

/** 修改按钮操作 */
function handleUpdate(row) {
  reset()
  const _id = row.id || ids.value
  getQa(_id).then(response => {
    form.value = response.data
    open.value = true
    title.value = "修改面试问答"
  })
}

/** 提交按钮 */
function submitForm() {
  proxy.$refs["qaRef"].validate(valid => {
    if (valid) {
      if (form.value.id != null) {
        updateQa(form.value).then(() => {
          proxy.$modal.msgSuccess("修改成功")
          open.value = false
          getList()
        })
      } else {
        addQa(form.value).then(() => {
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
  proxy.$modal.confirm('是否确认删除面试问答编号为"' + _ids + '"的数据项？').then(function() {
    return delQa(_ids)
  }).then(() => {
    getList()
    proxy.$modal.msgSuccess("删除成功")
  }).catch(() => {})
}

/** 详情按钮操作 */
function handleViewData(row) {
  proxy.$refs["qaViewRef"].open(row.id)
}

/** 导出按钮操作 */
function handleExport() {
  proxy.download('interview/qa/export', {
    ...queryParams.value
  }, `qa_${new Date().getTime()}.xlsx`)
}

getList()
</script>
