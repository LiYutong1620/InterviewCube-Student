<template>
  <div class="app-container mine-page">
    <el-row :gutter="20">
      <!-- 左侧：资料展示 -->
      <el-col :xs="24" :md="8">
        <el-card v-loading="profileLoading" shadow="never" class="mine-card">
          <template #header>
            <span class="card-title">资料展示</span>
          </template>
          <div class="profile-show">
            <el-avatar :size="88" :src="avatarUrl">
              <span>{{ nicknameInitial }}</span>
            </el-avatar>
            <div class="profile-show__name">{{ display(form.nickname) }}</div>
            <div class="profile-show__meta">{{ display(form.realName) }} · {{ genderLabel }}</div>
            <div class="profile-show__meta">{{ display(form.school) }} {{ display(form.major) }}</div>
            <el-button
              class="mt12"
              type="primary"
              link
              @click="goFullProfile"
            >完善更多档案信息</el-button>
          </div>
        </el-card>
      </el-col>

      <!-- 右侧：Tab 操作区 -->
      <el-col :xs="24" :md="16">
        <el-card shadow="never" class="mine-card">
          <el-tabs v-model="activeTab">
            <!-- 资料编辑：昵称 / 头像 -->
            <el-tab-pane label="资料编辑" name="profile">
              <el-form ref="profileRef" v-loading="profileLoading" :model="form" :rules="profileRules" label-width="80px">
                <el-form-item label="头像" prop="avatar">
                  <image-upload v-model="form.avatar" :limit="1" :fileSize="2" />
                </el-form-item>
                <el-form-item label="昵称" prop="nickname">
                  <el-input v-model="form.nickname" placeholder="请输入昵称" maxlength="50" style="max-width: 360px" />
                </el-form-item>
                <el-form-item>
                  <el-button
                    type="primary"
                    :loading="profileSaving"
                    v-hasPermi="['interview:profile:edit']"
                    @click="saveProfile"
                  >保 存</el-button>
                  <el-button @click="loadProfile">重 置</el-button>
                </el-form-item>
              </el-form>
            </el-tab-pane>

            <!-- 账号设置：若依 sys_user -->
            <el-tab-pane label="账号设置" name="account">
              <el-form ref="accountRef" v-loading="accountLoading" :model="accountForm" :rules="accountRules" label-width="90px">
                <el-form-item label="登录账号">
                  <span class="readonly-value">{{ accountForm.userName || '—' }}</span>
                </el-form-item>
                <el-form-item label="用户昵称" prop="nickName">
                  <el-input v-model="accountForm.nickName" maxlength="30" style="max-width: 360px" />
                </el-form-item>
                <el-form-item label="手机号码" prop="phonenumber">
                  <el-input v-model="accountForm.phonenumber" maxlength="11" style="max-width: 360px" />
                </el-form-item>
                <el-form-item label="邮箱" prop="email">
                  <el-input v-model="accountForm.email" maxlength="50" style="max-width: 360px" />
                </el-form-item>
                <el-form-item label="性别">
                  <el-radio-group v-model="accountForm.sex">
                    <el-radio value="0">男</el-radio>
                    <el-radio value="1">女</el-radio>
                  </el-radio-group>
                </el-form-item>
                <el-form-item>
                  <el-button type="primary" :loading="accountSaving" @click="saveAccount">保存账号信息</el-button>
                </el-form-item>
              </el-form>

              <el-divider content-position="left">修改密码</el-divider>
              <el-form ref="pwdRef" :model="pwdForm" :rules="pwdRules" label-width="90px">
                <el-form-item label="旧密码" prop="oldPassword">
                  <el-input v-model="pwdForm.oldPassword" type="password" show-password style="max-width: 360px" />
                </el-form-item>
                <el-form-item label="新密码" prop="newPassword" :rules="infoPwdValidator">
                  <el-input v-model="pwdForm.newPassword" type="password" show-password style="max-width: 360px" />
                </el-form-item>
                <el-form-item label="确认密码" prop="confirmPassword">
                  <el-input v-model="pwdForm.confirmPassword" type="password" show-password style="max-width: 360px" />
                </el-form-item>
                <el-form-item>
                  <el-button type="primary" :loading="pwdSaving" @click="savePassword">修改密码</el-button>
                </el-form-item>
              </el-form>
            </el-tab-pane>

            <!-- 协议 -->
            <el-tab-pane label="用户协议" name="agreement">
              <div v-loading="agreementLoading" class="agreement-box" v-html="userAgreementHtml"></div>
            </el-tab-pane>
            <el-tab-pane label="隐私政策" name="privacy">
              <div v-loading="agreementLoading" class="agreement-box" v-html="privacyPolicyHtml"></div>
            </el-tab-pane>

            <!-- 账号注销 -->
            <el-tab-pane label="账号注销" name="cancel">
              <el-alert
                title="注销后将无法使用本账号登录，相关业务数据会保留供管理员审计，请谨慎操作。"
                type="warning"
                :closable="false"
                show-icon
              />
              <div class="cancel-row">
                <el-button type="danger" :loading="cancelLoading" @click="handleCancel">注销账号</el-button>
              </div>
            </el-tab-pane>
          </el-tabs>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup name="Mine">
import { listProfile, addProfile, updateProfile } from '@/api/interview/profile'
import { cancelAccount } from '@/api/interview/mine'
import { getUserProfile, updateUserProfile, updateUserPwd } from '@/api/system/user'
import { getConfigKey } from '@/api/system/config'
import { usePasswordRule } from '@/utils/passwordRule'
import { isHttp, isEmpty } from '@/utils/validate'
import useUserStore from '@/store/modules/user'
import defAva from '@/assets/images/profile.jpg'

const { proxy } = getCurrentInstance()
const router = useRouter()
const userStore = useUserStore()
const { infoPwdValidator } = usePasswordRule()
const { sys_user_sex } = useDict('sys_user_sex')

const baseUrl = import.meta.env.VITE_APP_BASE_API
const activeTab = ref('profile')

const profileLoading = ref(false)
const profileSaving = ref(false)
const accountLoading = ref(false)
const accountSaving = ref(false)
const pwdSaving = ref(false)
const agreementLoading = ref(false)
const cancelLoading = ref(false)

const form = ref({ id: null, nickname: '', avatar: '', realName: '', gender: '', school: '', major: '' })
const accountForm = ref({ userName: '', nickName: '', phonenumber: '', email: '', sex: '0' })
const pwdForm = reactive({ oldPassword: undefined, newPassword: undefined, confirmPassword: undefined })
const userAgreementHtml = ref('')
const privacyPolicyHtml = ref('')

const profileRules = {
  nickname: [{ required: true, message: '昵称不能为空', trigger: 'blur' }]
}

const accountRules = {
  nickName: [{ required: true, message: '用户昵称不能为空', trigger: 'blur' }],
  email: [
    {
      validator: (rule, value, callback) => {
        if (!value) {
          callback()
        } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)) {
          callback(new Error('请输入正确的邮箱地址'))
        } else {
          callback()
        }
      },
      trigger: ['blur', 'change']
    }
  ],
  phonenumber: [
    {
      validator: (rule, value, callback) => {
        if (!value) {
          callback()
        } else if (!/^1[3-9]\d{9}$/.test(value)) {
          callback(new Error('请输入正确的手机号码'))
        } else {
          callback()
        }
      },
      trigger: 'blur'
    }
  ]
}

const equalToPassword = (rule, value, callback) => {
  if (pwdForm.newPassword !== value) {
    callback(new Error('两次输入的密码不一致'))
  } else {
    callback()
  }
}

const pwdRules = {
  oldPassword: [{ required: true, message: '旧密码不能为空', trigger: 'blur' }],
  confirmPassword: [
    { required: true, message: '确认密码不能为空', trigger: 'blur' },
    { validator: equalToPassword, trigger: 'blur' }
  ]
}

const avatarUrl = computed(() => {
  const avatar = form.value.avatar
  if (!avatar) {
    return userStore.avatar || defAva
  }
  if (isHttp(avatar)) {
    return avatar
  }
  return isEmpty(avatar) ? defAva : baseUrl + avatar
})

const nicknameInitial = computed(() => {
  const name = form.value.nickname || accountForm.value.nickName || '同'
  return String(name).charAt(0)
})

const genderLabel = computed(() => {
  const hit = (sys_user_sex.value || []).find(item => item.value === form.value.gender)
  return hit ? hit.label : '未填性别'
})

function display(value) {
  return value === null || value === undefined || value === '' ? '—' : value
}

function goFullProfile() {
  router.push('/student/profile')
}

function resolveAgreementHtml(raw, fallbackTitle) {
  if (!raw) {
    return `<p>${fallbackTitle}内容暂未配置，请联系管理员在「参数设置」中维护。</p>`
  }
  // 已是 HTML 则直接展示；纯文本转成段落，保留换行
  if (/<[a-z][\s\S]*>/i.test(raw)) {
    return raw
  }
  return `<p>${String(raw).replace(/\n/g, '<br/>')}</p>`
}

/** 加载学生档案（昵称 / 头像） */
function loadProfile() {
  profileLoading.value = true
  listProfile({ pageNum: 1, pageSize: 1 }).then(response => {
    const row = (response.rows || [])[0]
    form.value = row
      ? {
          id: row.id,
          nickname: row.nickname,
          avatar: row.avatar,
          realName: row.realName,
          gender: row.gender,
          school: row.school,
          major: row.major
        }
      : { id: null, nickname: '', avatar: '', realName: '', gender: '', school: '', major: '' }
  }).finally(() => {
    profileLoading.value = false
  })
}

/** 保存昵称 / 头像到 student_profile */
function saveProfile() {
  proxy.$refs.profileRef.validate(valid => {
    if (!valid) return
    const payload = {
      id: form.value.id,
      nickname: form.value.nickname,
      avatar: form.value.avatar
    }
    profileSaving.value = true
    const action = form.value.id ? updateProfile(payload) : addProfile(payload)
    action.then(() => {
      proxy.$modal.msgSuccess(form.value.id ? '保存成功' : '档案创建成功')
      loadProfile()
    }).catch(() => {}).finally(() => {
      profileSaving.value = false
    })
  })
}

/** 加载若依账号资料 */
function loadAccount() {
  accountLoading.value = true
  getUserProfile().then(response => {
    const user = response.data || {}
    accountForm.value = {
      userName: user.userName,
      nickName: user.nickName,
      phonenumber: user.phonenumber,
      email: user.email,
      sex: user.sex || '0'
    }
  }).finally(() => {
    accountLoading.value = false
  })
}

function saveAccount() {
  proxy.$refs.accountRef.validate(valid => {
    if (!valid) return
    accountSaving.value = true
    updateUserProfile({
      nickName: accountForm.value.nickName,
      phonenumber: accountForm.value.phonenumber,
      email: accountForm.value.email,
      sex: accountForm.value.sex
    }).then(() => {
      proxy.$modal.msgSuccess('账号信息已保存')
      userStore.nickName = accountForm.value.nickName
    }).catch(() => {}).finally(() => {
      accountSaving.value = false
    })
  })
}

function savePassword() {
  proxy.$refs.pwdRef.validate(valid => {
    if (!valid) return
    pwdSaving.value = true
    updateUserPwd(pwdForm.oldPassword, pwdForm.newPassword).then(() => {
      proxy.$modal.msgSuccess('密码修改成功')
      pwdForm.oldPassword = undefined
      pwdForm.newPassword = undefined
      pwdForm.confirmPassword = undefined
      proxy.resetForm('pwdRef')
    }).catch(() => {}).finally(() => {
      pwdSaving.value = false
    })
  })
}

function loadAgreements() {
  agreementLoading.value = true
  Promise.all([
    getConfigKey('student.agreement.user'),
    getConfigKey('student.agreement.privacy')
  ]).then(([userRes, privacyRes]) => {
    userAgreementHtml.value = resolveAgreementHtml(userRes.msg || userRes.data, '用户协议')
    privacyPolicyHtml.value = resolveAgreementHtml(privacyRes.msg || privacyRes.data, '隐私政策')
  }).catch(() => {
    userAgreementHtml.value = resolveAgreementHtml('', '用户协议')
    privacyPolicyHtml.value = resolveAgreementHtml('', '隐私政策')
  }).finally(() => {
    agreementLoading.value = false
  })
}

function handleCancel() {
  proxy.$modal.confirm('确认注销当前账号？注销后需重新注册才能使用。').then(() => {
    cancelLoading.value = true
    return cancelAccount()
  }).then(() => {
    proxy.$modal.msgSuccess('账号已注销')
    return userStore.logOut()
  }).then(() => {
    location.href = '/index'
  }).catch(() => {}).finally(() => {
    cancelLoading.value = false
  })
}

loadProfile()
loadAccount()
loadAgreements()
</script>

<style scoped lang="scss">
.mine-card {
  margin-bottom: 16px;
}

.card-title {
  font-size: 15px;
  font-weight: 600;
}

.profile-show {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 12px 0 8px;
  text-align: center;

  .profile-show__name {
    margin-top: 12px;
    font-size: 18px;
    font-weight: 600;
    color: #303133;
  }

  .profile-show__meta {
    margin-top: 6px;
    font-size: 13px;
    color: #909399;
  }
}

.readonly-value {
  color: #606266;
}

.agreement-box {
  min-height: 240px;
  max-height: 480px;
  overflow: auto;
  padding: 8px 4px;
  line-height: 1.8;
  color: #606266;
  font-size: 14px;
}

.cancel-row {
  margin-top: 20px;
}

.mt12 {
  margin-top: 12px;
}
</style>
