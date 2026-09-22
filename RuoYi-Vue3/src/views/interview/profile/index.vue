<template>
  <div class="app-container">
    <el-card v-loading="loading" shadow="never">
      <template #header>
        <div class="profile-header">
          <span class="profile-title">我的档案</span>
          <span class="profile-tip">档案与登录账号一一对应，保存后立即生效</span>
        </div>
      </template>

      <el-form ref="profileRef" :model="form" :rules="rules" label-width="90px">
        <el-row :gutter="24">
          <el-col :span="24">
            <el-form-item label="头像" prop="avatar">
              <image-upload v-model="form.avatar" :limit="1" :fileSize="2" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="昵称" prop="nickname">
              <el-input v-model="form.nickname" placeholder="请输入昵称" maxlength="50" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="真实姓名" prop="realName">
              <el-input v-model="form.realName" placeholder="请输入真实姓名" maxlength="50" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="性别" prop="gender">
              <el-select v-model="form.gender" placeholder="请选择性别" clearable style="width: 100%">
                <el-option
                  v-for="dict in sys_user_sex"
                  :key="dict.value"
                  :label="dict.label"
                  :value="dict.value"
                />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="手机号" prop="phone">
              <el-input v-model="form.phone" placeholder="请输入手机号" maxlength="11" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="邮箱" prop="email">
              <el-input v-model="form.email" placeholder="请输入邮箱" maxlength="100" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="学校" prop="school">
              <el-input v-model="form.school" placeholder="请输入学校" maxlength="100" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="专业" prop="major">
              <el-input v-model="form.major" placeholder="请输入专业" maxlength="100" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="学历" prop="education">
              <el-select v-model="form.education" placeholder="请选择学历" clearable style="width: 100%">
                <el-option
                  v-for="dict in student_education"
                  :key="dict.value"
                  :label="dict.label"
                  :value="dict.value"
                />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="毕业年份" prop="graduationYear">
              <el-date-picker
                v-model="form.graduationYear"
                type="year"
                value-format="YYYY"
                placeholder="请选择毕业年份"
                style="width: 100%"
              />
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
                placeholder="请输入备注"
              />
            </el-form-item>
          </el-col>
        </el-row>

        <el-divider content-position="left">成长信息（由系统维护，不可编辑）</el-divider>

        <el-row :gutter="24">
          <el-col :span="8">
            <el-form-item label="当前等级">
              <span class="readonly-value">{{ display(form.currentLevel) }}</span>
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="当前积分">
              <span class="readonly-value">{{ display(form.currentPoints) }}</span>
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="引导状态">
              <dict-tag :options="student_guide_status" :value="form.guideStatus" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="账号状态">
              <dict-tag :options="sys_normal_disable" :value="form.status" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="创建时间">
              <span class="readonly-value">{{ parseTime(form.createTime, '{y}-{m}-{d} {h}:{i}') || '-' }}</span>
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="最后更新">
              <span class="readonly-value">{{ parseTime(form.updateTime, '{y}-{m}-{d} {h}:{i}') || '-' }}</span>
            </el-form-item>
          </el-col>
        </el-row>

        <el-row>
          <el-col :span="24" class="profile-actions">
            <el-button
              type="primary"
              :loading="saving"
              @click="submitForm"
              v-hasPermi="['interview:profile:edit']"
            >保 存</el-button>
            <el-button @click="loadProfile">重 置</el-button>
          </el-col>
        </el-row>
      </el-form>
    </el-card>
  </div>
</template>

<script setup name="Profile">
import { listProfile, addProfile, updateProfile } from "@/api/interview/profile"

const { proxy } = getCurrentInstance()
const { sys_user_sex, sys_normal_disable, student_education, student_guide_status } = useDict(
  'sys_user_sex',
  'sys_normal_disable',
  'student_education',
  'student_guide_status'
)

const loading = ref(false)
const saving = ref(false)

/** 可维护字段的白名单：等级/积分/引导状态/账号状态由系统维护，不参与提交 */
const EDITABLE_FIELDS = [
  'nickname', 'avatar', 'realName', 'gender', 'phone', 'email',
  'school', 'major', 'education', 'graduationYear', 'remark'
]

const data = reactive({
  form: {},
  rules: {
    nickname: [
      { required: true, message: "昵称不能为空", trigger: "blur" }
    ],
    phone: [
      { pattern: /^1[3-9]\d{9}$/, message: "请输入正确的手机号", trigger: "blur" }
    ],
    email: [
      { type: "email", message: "请输入正确的邮箱地址", trigger: ["blur", "change"] }
    ],
    graduationYear: [
      { pattern: /^(19|20)\d{2}$/, message: "请输入正确的毕业年份", trigger: "change" }
    ]
  }
})

const { form, rules } = toRefs(data)

/** 空值统一显示为「-」，避免出现 0 被当成空 */
function display(value) {
  return value === null || value === undefined || value === '' ? '-' : value
}

/** 加载当前登录学生的档案（学生端为 1:1，取第一条即可） */
function loadProfile() {
  loading.value = true
  listProfile({ pageNum: 1, pageSize: 1 }).then(response => {
    const row = (response.rows || [])[0]
    form.value = row ? { ...row } : { id: null }
    loading.value = false
  }).catch(() => {
    loading.value = false
  })
}

/** 保存 */
function submitForm() {
  proxy.$refs["profileRef"].validate(valid => {
    if (!valid) return
    const payload = { id: form.value.id }
    EDITABLE_FIELDS.forEach(field => {
      payload[field] = form.value[field]
    })
    saving.value = true
    const action = form.value.id ? updateProfile(payload) : addProfile(payload)
    action.then(() => {
      proxy.$modal.msgSuccess(form.value.id ? "保存成功" : "档案创建成功")
      loadProfile()
    }).catch(() => {}).finally(() => {
      saving.value = false
    })
  })
}

loadProfile()
</script>

<style scoped>
.profile-header {
  display: flex;
  align-items: baseline;
  gap: 12px;
}

.profile-title {
  font-size: 16px;
  font-weight: 600;
}

.profile-tip {
  font-size: 12px;
  color: #909399;
}

.readonly-value {
  color: #606266;
}

.profile-actions {
  text-align: center;
  margin-top: 8px;
}
</style>
