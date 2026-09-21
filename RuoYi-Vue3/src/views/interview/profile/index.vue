<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="昵称" prop="nickname">
        <el-input
          v-model="queryParams.nickname"
          placeholder="请输入昵称"
          clearable
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item label="真实姓名" prop="realName">
        <el-input
          v-model="queryParams.realName"
          placeholder="请输入真实姓名"
          clearable
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item label="性别" prop="gender">
        <el-select v-model="queryParams.gender" placeholder="请选择性别" clearable>
          <el-option
            v-for="dict in sys_user_sex"
            :key="dict.value"
            :label="dict.label"
            :value="dict.value"
          />
        </el-select>
      </el-form-item>
      <el-form-item label="手机号" prop="phone">
        <el-input
          v-model="queryParams.phone"
          placeholder="请输入手机号"
          clearable
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item label="邮箱" prop="email">
        <el-input
          v-model="queryParams.email"
          placeholder="请输入邮箱"
          clearable
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item label="学校" prop="school">
        <el-input
          v-model="queryParams.school"
          placeholder="请输入学校"
          clearable
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item label="专业" prop="major">
        <el-input
          v-model="queryParams.major"
          placeholder="请输入专业"
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
          v-hasPermi="['interview:profile:add']"
        >新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="success"
          plain
          icon="Edit"
          :disabled="single"
          @click="handleUpdate"
          v-hasPermi="['interview:profile:edit']"
        >修改</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="danger"
          plain
          icon="Delete"
          :disabled="multiple"
          @click="handleDelete"
          v-hasPermi="['interview:profile:remove']"
        >删除</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="warning"
          plain
          icon="Download"
          @click="handleExport"
          v-hasPermi="['interview:profile:export']"
        >导出</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="profileList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="主键ID" align="center" prop="id" />
      <el-table-column label="关联若依用户ID(sys_user.user_id)" align="center" prop="userId" />
      <el-table-column label="昵称" align="center" prop="nickname" />
      <el-table-column label="头像地址" align="center" prop="avatar" width="100">
        <template #default="scope">
          <image-preview :src="scope.row.avatar" :width="50" :height="50"/>
        </template>
      </el-table-column>
      <el-table-column label="真实姓名" align="center" prop="realName" />
      <el-table-column label="性别" align="center" prop="gender">
        <template #default="scope">
          <dict-tag :options="sys_user_sex" :value="scope.row.gender"/>
        </template>
      </el-table-column>
      <el-table-column label="手机号" align="center" prop="phone" />
      <el-table-column label="邮箱" align="center" prop="email" />
      <el-table-column label="学校" align="center" prop="school" />
      <el-table-column label="专业" align="center" prop="major" />
      <el-table-column label="学历(专科/本科/硕士/博士)" align="center" prop="education" />
      <el-table-column label="毕业年份" align="center" prop="graduationYear" />
      <el-table-column label="引导状态(0未完成 1已完成)" align="center" prop="guideStatus" />
      <el-table-column label="当前等级" align="center" prop="currentLevel" />
      <el-table-column label="当前积分" align="center" prop="currentPoints" />
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
          <el-button link type="primary" icon="View" @click="handleViewData(scope.row)" v-hasPermi="['interview:profile:query']">详情</el-button>
          <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-hasPermi="['interview:profile:edit']">修改</el-button>
          <el-button link type="primary" icon="Delete" @click="handleDelete(scope.row)" v-hasPermi="['interview:profile:remove']">删除</el-button>
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

    <!-- 学生档案详情抽屉 -->
    <profile-view-drawer ref="profileViewRef" />
    <!-- 添加或修改学生档案对话框 -->
    <el-dialog :title="title" v-model="open" width="800px" append-to-body>
      <el-form ref="profileRef" :model="form" :rules="rules" label-width="100px">
        <el-row>
          <el-col :span="12">
            <el-form-item label="昵称" prop="nickname">
              <el-input v-model="form.nickname" placeholder="请输入昵称" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="头像地址" prop="avatar">
              <image-upload v-model="form.avatar"/>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="真实姓名" prop="realName">
              <el-input v-model="form.realName" placeholder="请输入真实姓名" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="性别" prop="gender">
              <el-select v-model="form.gender" placeholder="请选择性别">
                <el-option
                  v-for="dict in sys_user_sex"
                  :key="dict.value"
                  :label="dict.label"
                  :value="dict.value"
                ></el-option>
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="手机号" prop="phone">
              <el-input v-model="form.phone" placeholder="请输入手机号" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="邮箱" prop="email">
              <el-input v-model="form.email" placeholder="请输入邮箱" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="学校" prop="school">
              <el-input v-model="form.school" placeholder="请输入学校" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="专业" prop="major">
              <el-input v-model="form.major" placeholder="请输入专业" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="毕业年份" prop="graduationYear">
              <el-input v-model="form.graduationYear" placeholder="请输入毕业年份" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="当前等级" prop="currentLevel">
              <el-input v-model="form.currentLevel" placeholder="请输入当前等级" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="当前积分" prop="currentPoints">
              <el-input v-model="form.currentPoints" placeholder="请输入当前积分" />
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

<script setup name="Profile">
import { listProfile, getProfile, delProfile, addProfile, updateProfile } from "@/api/interview/profile"
import ProfileViewDrawer from "./view"

const { proxy } = getCurrentInstance()
const { sys_user_sex, sys_normal_disable } = useDict('sys_user_sex', 'sys_normal_disable')

const profileList = ref([])
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
    nickname: undefined,
    realName: undefined,
    gender: undefined,
    phone: undefined,
    email: undefined,
    school: undefined,
    major: undefined,
    education: undefined,
    guideStatus: undefined,
    status: undefined,
  },
  rules: {
    nickname: [
      { required: true, message: "昵称不能为空", trigger: "blur" }
    ],
  }
})

const { queryParams, form, rules } = toRefs(data)

/** 查询学生档案列表 */
function getList() {
  loading.value = true
  listProfile(queryParams.value).then(response => {
    profileList.value = response.rows
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
    nickname: null,
    avatar: null,
    realName: null,
    gender: null,
    phone: null,
    email: null,
    school: null,
    major: null,
    education: null,
    graduationYear: null,
    guideStatus: null,
    currentLevel: null,
    currentPoints: null,
    status: null,
    delFlag: null,
    createBy: null,
    createTime: null,
    updateBy: null,
    updateTime: null,
    remark: null
  }
  proxy.resetForm("profileRef")
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
  title.value = "添加学生档案"
}

/** 修改按钮操作 */
function handleUpdate(row) {
  reset()
  const _id = row.id || ids.value
  getProfile(_id).then(response => {
    form.value = response.data
    open.value = true
    title.value = "修改学生档案"
  })
}

/** 提交按钮 */
function submitForm() {
  proxy.$refs["profileRef"].validate(valid => {
    if (valid) {
      if (form.value.id != null) {
        updateProfile(form.value).then(() => {
          proxy.$modal.msgSuccess("修改成功")
          open.value = false
          getList()
        })
      } else {
        addProfile(form.value).then(() => {
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
  proxy.$modal.confirm('是否确认删除学生档案编号为"' + _ids + '"的数据项？').then(function() {
    return delProfile(_ids)
  }).then(() => {
    getList()
    proxy.$modal.msgSuccess("删除成功")
  }).catch(() => {})
}

/** 详情按钮操作 */
function handleViewData(row) {
  proxy.$refs["profileViewRef"].open(row.id)
}

/** 导出按钮操作 */
function handleExport() {
  proxy.download('interview/profile/export', {
    ...queryParams.value
  }, `profile_${new Date().getTime()}.xlsx`)
}

getList()
</script>
