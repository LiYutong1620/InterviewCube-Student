<template>
  <div class="login">
    <div class="login-card">
      <h3 class="title">{{ title }}</h3>
      <p class="subtitle">AI 多 Agent 模拟面试 · 学生端</p>

      <el-tabs v-model="activeTab" class="login-tabs" stretch>
        <!-- ==================== 1. 密码登录 ==================== -->
        <el-tab-pane label="密码登录" name="password">
          <el-form ref="pwdFormRef" :model="pwdForm" :rules="pwdRules" size="large">
            <el-form-item prop="username">
              <el-input
                v-model="pwdForm.username"
                placeholder="手机号 / 账号"
                auto-complete="off"
                @keyup.enter="handleSubmit"
              >
                <template #prefix><svg-icon icon-class="user" class="input-icon" /></template>
              </el-input>
            </el-form-item>

            <el-form-item prop="password">
              <el-input
                v-model="pwdForm.password"
                type="password"
                show-password
                placeholder="密码"
                auto-complete="off"
                @keyup.enter="handleSubmit"
              >
                <template #prefix><svg-icon icon-class="password" class="input-icon" /></template>
              </el-input>
            </el-form-item>

            <el-form-item prop="code" v-if="captchaEnabled">
              <el-input
                v-model="pwdForm.code"
                placeholder="验证码"
                style="width: 62%"
                @keyup.enter="handleSubmit"
              >
                <template #prefix><svg-icon icon-class="validCode" class="input-icon" /></template>
              </el-input>
              <div class="login-code">
                <img :src="codeUrl" class="login-code-img" alt="验证码" @click="getCode" />
              </div>
            </el-form-item>

            <div class="row-between">
              <el-checkbox v-model="pwdForm.rememberMe">记住密码</el-checkbox>
              <el-link type="primary" :underline="false" @click="goForgetPwd">忘记密码？</el-link>
            </div>
          </el-form>
        </el-tab-pane>

        <!-- ==================== 2. 验证码登录 ==================== -->
        <el-tab-pane label="验证码登录" name="sms">
          <el-form ref="smsFormRef" :model="smsForm" :rules="smsRules" size="large">
            <el-form-item prop="phone">
              <el-input
                v-model="smsForm.phone"
                maxlength="11"
                placeholder="手机号"
                auto-complete="off"
                @keyup.enter="handleSubmit"
              >
                <template #prefix><svg-icon icon-class="phone" class="input-icon" /></template>
              </el-input>
            </el-form-item>

            <el-form-item prop="code">
              <el-input
                v-model="smsForm.code"
                maxlength="6"
                placeholder="短信验证码"
                style="width: 58%"
                @keyup.enter="handleSubmit"
              >
                <template #prefix><svg-icon icon-class="message" class="input-icon" /></template>
              </el-input>
              <el-button
                class="sms-btn"
                :disabled="smsCountdown > 0"
                :loading="sendingSms"
                @click="handleSendSms"
              >
                {{ smsCountdown > 0 ? smsCountdown + ' 秒后重发' : '获取验证码' }}
              </el-button>
            </el-form-item>

            <el-alert
              v-if="mockCode"
              class="mock-tip"
              type="warning"
              :closable="false"
              show-icon
              :title="'开发模式验证码：' + mockCode + '（已自动填入）'"
            />
          </el-form>
        </el-tab-pane>

        <!-- ==================== 3. 微信登录（UI 占位） ==================== -->
        <el-tab-pane label="微信登录" name="wechat">
          <div class="wechat-box">
            <div class="wechat-qr">
              <svg-icon icon-class="wechat" class="wechat-icon" />
            </div>
            <p class="wechat-title">微信登录即将开放</p>
            <p class="wechat-desc">
              将同时支持小程序与 H5 两种方式：小程序内一键授权，H5 扫码登录。<br />
              当前版本仅提供入口占位，请先用密码或验证码登录。
            </p>
          </div>
        </el-tab-pane>
      </el-tabs>

      <!-- ==================== 协议勾选 ==================== -->
      <div class="agree-row" :class="{ shake: agreeShake }">
        <el-checkbox v-model="agreed" size="small">我已阅读并同意</el-checkbox>
        <router-link class="agree-link" to="/agreement/user" target="_blank">《用户协议》</router-link>
        <span class="agree-and">和</span>
        <router-link class="agree-link" to="/agreement/privacy" target="_blank">《隐私政策》</router-link>
      </div>

      <el-button class="login-btn" :loading="loading" size="large" type="primary" @click="handleSubmit">
        <span v-if="!loading">登 录</span>
        <span v-else>登 录 中...</span>
      </el-button>

      <div class="row-bottom">
        <template v-if="registerEnabled">
          <span class="tip">还没有账号？</span>
          <el-link type="primary" :underline="false" @click="goRegister">立即注册</el-link>
        </template>
      </div>
    </div>

    <div class="el-login-footer" v-if="footerVisible">
      <span>{{ footerContent }}</span>
    </div>
  </div>
</template>

<script setup>
import { ref, watch, onBeforeUnmount, getCurrentInstance } from "vue"
import { useRouter, useRoute } from "vue-router"
import Cookies from "js-cookie"
import { encrypt, decrypt } from "@/utils/jsencrypt"
import { getCodeImg } from "@/api/login"
import { getConfigKey } from "@/api/system/config"
import { sendSmsCode } from "@/api/interview/auth"
import useUserStore from "@/store/modules/user"
import defaultSettings from "@/settings"

const title = import.meta.env.VITE_APP_TITLE
const footerContent = defaultSettings.footerContent
const footerVisible = defaultSettings.footerVisible
const userStore = useUserStore()
const router = useRouter()
const route = useRoute()
const { proxy } = getCurrentInstance()

/** 手机号格式（与后端 AuthCodeConstants.PHONE_PATTERN 保持一致） */
const PHONE_RE = /^1[3-9]\d{9}$/

/** 当前 Tab：password 密码登录 / sms 验证码登录 / wechat 微信登录（占位） */
const activeTab = ref("password")
const loading = ref(false)

/** 登录成功后的回跳地址（由 permission.js 拼的 ?redirect=... 带过来） */
const redirect = ref(undefined)

// ---------------- 协议勾选 ----------------
// 刻意不做本地持久化：每次进登录页都要显式勾选一次，避免「同意」被静默记住
const agreed = ref(false)
const agreeShake = ref(false)

function requireAgree() {
  if (agreed.value) return true
  agreeShake.value = true
  setTimeout(() => { agreeShake.value = false }, 600)
  proxy.$modal.msgWarning("请先阅读并勾选《用户协议》与《隐私政策》")
  return false
}

// ---------------- 注册入口开关 ----------------
const registerEnabled = ref(false)
getConfigKey("sys.account.registerUser").then(res => {
  registerEnabled.value = res.msg === "true"
}).catch(() => {})

// ==================== 密码登录 ====================
const pwdFormRef = ref()
const pwdForm = ref({
  username: "",
  password: "",
  rememberMe: false,
  code: "",
  uuid: ""
})

const pwdRules = {
  username: [{ required: true, trigger: "blur", message: "请输入您的账号或手机号" }],
  password: [{ required: true, trigger: "blur", message: "请输入您的密码" }],
  code: [{ required: true, trigger: "change", message: "请输入验证码" }]
}

const codeUrl = ref("")
const captchaEnabled = ref(true)

function getCode() {
  getCodeImg().then(res => {
    captchaEnabled.value = res.captchaEnabled === undefined ? true : res.captchaEnabled
    if (captchaEnabled.value) {
      codeUrl.value = "data:image/gif;base64," + res.img
      pwdForm.value.uuid = res.uuid
    }
  })
}

function getCookie() {
  const username = Cookies.get("username")
  const password = Cookies.get("password")
  const rememberMe = Cookies.get("rememberMe")
  pwdForm.value.username = username === undefined ? "" : username
  pwdForm.value.password = password === undefined ? "" : decrypt(password)
  pwdForm.value.rememberMe = rememberMe === undefined ? false : Boolean(rememberMe)
}

function handlePasswordLogin() {
  pwdFormRef.value.validate(valid => {
    if (!valid) return
    loading.value = true
    if (pwdForm.value.rememberMe) {
      Cookies.set("username", pwdForm.value.username, { expires: 30 })
      Cookies.set("password", encrypt(pwdForm.value.password), { expires: 30 })
      Cookies.set("rememberMe", pwdForm.value.rememberMe, { expires: 30 })
    } else {
      Cookies.remove("username")
      Cookies.remove("password")
      Cookies.remove("rememberMe")
    }
    userStore.login(pwdForm.value).then(() => {
      goAfterLogin()
    }).catch(() => {
      loading.value = false
      // 密码错了也要换一张图形验证码，避免同一张图被反复用
      if (captchaEnabled.value) getCode()
    })
  })
}

// ==================== 验证码登录 ====================
const smsFormRef = ref()
const smsForm = ref({ phone: "", code: "" })
const smsRules = {
  phone: [
    { required: true, trigger: "blur", message: "请输入手机号" },
    { pattern: PHONE_RE, trigger: "blur", message: "手机号格式不正确" }
  ],
  code: [{ required: true, trigger: "change", message: "请输入短信验证码" }]
}

const sendingSms = ref(false)
const smsCountdown = ref(0)
let smsTimer = null

/** 开发期 Mock 通道回显的验证码（真实通道不会有值） */
const mockCode = ref("")

function startCountdown() {
  smsCountdown.value = 60
  clearInterval(smsTimer)
  smsTimer = setInterval(() => {
    smsCountdown.value -= 1
    if (smsCountdown.value <= 0) clearInterval(smsTimer)
  }, 1000)
}

function handleSendSms() {
  if (smsCountdown.value > 0) return
  if (!PHONE_RE.test(smsForm.value.phone)) {
    proxy.$modal.msgWarning("请输入正确的手机号")
    return
  }
  sendingSms.value = true
  sendSmsCode({ phone: smsForm.value.phone, scene: "login" }).then(res => {
    if (res.mock && res.mockCode) {
      // 开发期 Mock 通道：后端把验证码回显回来了，直接填上省一次手输
      mockCode.value = res.mockCode
      smsForm.value.code = res.mockCode
      proxy.$modal.msgSuccess("验证码已发送（开发模式已自动填入）")
    } else {
      proxy.$modal.msgSuccess("验证码已发送，请查看短信")
    }
    startCountdown()
  }).catch(() => {
    // 错误提示由 utils/request.js 统一弹出（如「发送过于频繁」）
  }).finally(() => {
    sendingSms.value = false
  })
}

function handleSmsLogin() {
  smsFormRef.value.validate(valid => {
    if (!valid) return
    loading.value = true
    userStore.smsLogin(smsForm.value).then(() => {
      goAfterLogin()
    }).catch(() => {
      loading.value = false
    })
  })
}

// ==================== 公共 ====================
function handleSubmit() {
  if (!requireAgree()) return
  if (activeTab.value === "password") {
    handlePasswordLogin()
  } else if (activeTab.value === "sms") {
    handleSmsLogin()
  } else {
    proxy.$modal.msgWarning("微信登录即将开放，请先用密码或验证码登录")
  }
}

function goAfterLogin() {
  const query = route.query
  const otherQueryParams = Object.keys(query).reduce((acc, cur) => {
    if (cur !== "redirect") acc[cur] = query[cur]
    return acc
  }, {})
  router.push({ path: redirect.value || "/", query: otherQueryParams })
}

function goRegister() {
  router.push("/register")
}

function goForgetPwd() {
  router.push("/forgetPwd")
}

watch(route, newRoute => {
  redirect.value = newRoute.query && newRoute.query.redirect
  // 从「注册成功」「重置密码成功」跳回来时带 phone，直接填进两个表单并切到密码登录
  const phone = newRoute.query && newRoute.query.phone
  if (phone) {
    pwdForm.value.username = phone
    smsForm.value.phone = phone
    activeTab.value = "password"
  }
}, { immediate: true })

onBeforeUnmount(() => {
  clearInterval(smsTimer)
})

getCode()
getCookie()
</script>

<style lang="scss" scoped>
.login {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100%;
  min-height: 100vh;
  background-image: url("../assets/images/login-background.jpg");
  background-size: cover;
  background-position: center;
}

.login-card {
  width: 420px;
  padding: 28px 30px 20px;
  border-radius: 10px;
  background: #ffffff;
  box-shadow: 0 12px 40px rgba(0, 0, 0, 0.18);
}

.title {
  margin: 0;
  text-align: center;
  color: #303133;
  font-size: 22px;
  letter-spacing: 1px;
}

.subtitle {
  margin: 6px 0 12px;
  text-align: center;
  color: #909399;
  font-size: 12px;
  letter-spacing: 1px;
}

.login-tabs {
  :deep(.el-tabs__header) {
    margin-bottom: 18px;
  }
  :deep(.el-tabs__item) {
    font-size: 14px;
  }
}

.input-icon {
  height: 39px;
  width: 14px;
  margin-left: 0;
}

.login-code {
  width: 36%;
  height: 40px;
  text-align: right;
}

.login-code-img {
  height: 40px;
  cursor: pointer;
  vertical-align: middle;
  border-radius: 4px;
}

.sms-btn {
  width: 40%;
  margin-left: 2%;
  padding: 0 8px;
  font-size: 13px;
}

.mock-tip {
  margin-bottom: 4px;
}

.row-between {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin: 0 0 18px 0;
}

.agree-row {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  margin: 4px 0 14px;
  font-size: 12px;
  color: #909399;
}

.agree-row.shake {
  animation: shake 0.5s ease;
}

@keyframes shake {
  0%, 100% { transform: translateX(0); }
  20% { transform: translateX(-8px); }
  40% { transform: translateX(8px); }
  60% { transform: translateX(-6px); }
  80% { transform: translateX(6px); }
}

.agree-link {
  color: #409eff;
  text-decoration: none;

  &:hover {
    text-decoration: underline;
  }
}

.agree-and {
  margin: 0 2px;
}

.login-btn {
  width: 100%;
}

.row-bottom {
  height: 34px;
  line-height: 34px;
  text-align: center;

  .tip {
    font-size: 13px;
    color: #909399;
  }
}

.wechat-box {
  padding: 8px 4px 24px;
  text-align: center;
}

.wechat-qr {
  width: 150px;
  height: 150px;
  margin: 0 auto 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 1px dashed #c0c4cc;
  border-radius: 8px;
  background: #fafafa;
}

.wechat-icon {
  width: 56px;
  height: 56px;
  color: #07c160;
}

.wechat-title {
  margin: 0 0 8px;
  font-size: 15px;
  color: #303133;
}

.wechat-desc {
  margin: 0;
  font-size: 12px;
  line-height: 1.8;
  color: #909399;
}

.el-login-footer {
  height: 40px;
  line-height: 40px;
  position: fixed;
  bottom: 0;
  width: 100%;
  text-align: center;
  color: #fff;
  font-family: Arial;
  font-size: 12px;
  letter-spacing: 1px;
  text-shadow: 0 1px 3px rgba(0, 0, 0, 0.4);
}
</style>
