<template>
  <div class="register">
    <el-form ref="registerRef" :model="registerForm" :rules="registerRules" class="register-form">
      <h3 class="title">{{ title }}</h3>
      <p class="subtitle">手机号验证码注册</p>

      <el-alert
        v-if="!registerEnabled"
        class="disabled-tip"
        type="error"
        :closable="false"
        show-icon
        title="当前系统未开放注册"
        description="请联系管理员在「系统管理 → 参数设置」里把 sys.account.registerUser 设为 true。"
      />

      <el-form-item prop="phone">
        <el-input
          v-model="registerForm.phone"
          maxlength="11"
          size="large"
          auto-complete="off"
          placeholder="手机号"
        >
          <template #prefix><svg-icon icon-class="phone" class="el-input__icon input-icon" /></template>
        </el-input>
      </el-form-item>

      <el-form-item prop="code">
        <el-input
          v-model="registerForm.code"
          maxlength="6"
          size="large"
          auto-complete="off"
          placeholder="短信验证码"
          style="width: 58%"
        >
          <template #prefix><svg-icon icon-class="message" class="el-input__icon input-icon" /></template>
        </el-input>
        <el-button
          class="sms-btn"
          :disabled="countdown > 0"
          :loading="sending"
          @click="handleSendSms"
        >
          {{ countdown > 0 ? countdown + ' 秒后重发' : '获取验证码' }}
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

      <el-form-item prop="password" :rules="registerPwdValidator">
        <el-input
          v-model="registerForm.password"
          type="password"
          show-password
          size="large"
          auto-complete="off"
          placeholder="设置密码"
        >
          <template #prefix><svg-icon icon-class="password" class="el-input__icon input-icon" /></template>
        </el-input>
      </el-form-item>

      <el-form-item prop="confirmPassword">
        <el-input
          v-model="registerForm.confirmPassword"
          type="password"
          show-password
          size="large"
          auto-complete="off"
          placeholder="确认密码"
          @keyup.enter="handleRegister"
        >
          <template #prefix><svg-icon icon-class="password" class="el-input__icon input-icon" /></template>
        </el-input>
      </el-form-item>

      <div class="agree-row" :class="{ shake: agreeShake }">
        <el-checkbox v-model="registerForm.agreed" size="small">我已阅读并同意</el-checkbox>
        <router-link class="agree-link" to="/agreement/user" target="_blank">《用户协议》</router-link>
        <span class="agree-and">和</span>
        <router-link class="agree-link" to="/agreement/privacy" target="_blank">《隐私政策》</router-link>
      </div>

      <el-form-item style="width:100%;">
        <el-button
          :loading="loading"
          :disabled="!registerEnabled"
          size="large"
          type="primary"
          style="width:100%;"
          @click.prevent="handleRegister"
        >
          <span v-if="!loading">注 册</span>
          <span v-else>注 册 中...</span>
        </el-button>
        <div style="float: right;">
          <router-link class="link-type" :to="'/login'">使用已有账户登录</router-link>
        </div>
      </el-form-item>
    </el-form>

    <div class="el-register-footer" v-if="footerVisible">
      <span>{{ footerContent }}</span>
    </div>
  </div>
</template>

<script setup>
import { ref, onBeforeUnmount, getCurrentInstance } from "vue"
import { useRouter } from "vue-router"
import { sendSmsCode, registerByPhone } from "@/api/interview/auth"
import { getConfigKey } from "@/api/system/config"
import defaultSettings from "@/settings"
import { usePasswordRule } from "@/utils/passwordRule"

const title = import.meta.env.VITE_APP_TITLE
const footerContent = defaultSettings.footerContent
const footerVisible = defaultSettings.footerVisible
const router = useRouter()
const { proxy } = getCurrentInstance()
const { registerPwdValidator } = usePasswordRule()

/** 手机号格式（与后端 AuthCodeConstants.PHONE_PATTERN 保持一致） */
const PHONE_RE = /^1[3-9]\d{9}$/

const registerRef = ref()
const loading = ref(false)
const sending = ref(false)
const countdown = ref(0)
const mockCode = ref("")
const agreeShake = ref(false)
const registerEnabled = ref(true)
let timer = null

const registerForm = ref({
  phone: "",
  code: "",
  password: "",
  confirmPassword: "",
  agreed: false
})

const equalToPassword = (rule, value, callback) => {
  if (registerForm.value.password !== value) {
    callback(new Error("两次输入的密码不一致"))
  } else {
    callback()
  }
}

const registerRules = {
  phone: [
    { required: true, trigger: "blur", message: "请输入手机号" },
    { pattern: PHONE_RE, trigger: "blur", message: "手机号格式不正确" }
  ],
  code: [{ required: true, trigger: "change", message: "请输入短信验证码" }],
  confirmPassword: [
    { required: true, trigger: "blur", message: "请再次输入您的密码" },
    { required: true, validator: equalToPassword, trigger: "blur" }
  ]
}

// 注册开关由后端 sys_config 控制，关掉时直接禁用按钮并说明原因，
// 而不是等用户填完一整屏再报「当前系统没有开启注册功能」
getConfigKey("sys.account.registerUser").then(res => {
  registerEnabled.value = res.msg === "true"
}).catch(() => {})

function startCountdown() {
  countdown.value = 60
  clearInterval(timer)
  timer = setInterval(() => {
    countdown.value -= 1
    if (countdown.value <= 0) clearInterval(timer)
  }, 1000)
}

function handleSendSms() {
  if (countdown.value > 0) return
  if (!PHONE_RE.test(registerForm.value.phone)) {
    proxy.$modal.msgWarning("请输入正确的手机号")
    return
  }
  sending.value = true
  sendSmsCode({ phone: registerForm.value.phone, scene: "register" }).then(res => {
    if (res.mock && res.mockCode) {
      mockCode.value = res.mockCode
      registerForm.value.code = res.mockCode
      proxy.$modal.msgSuccess("验证码已发送（开发模式已自动填入）")
    } else {
      proxy.$modal.msgSuccess("验证码已发送，请查看短信")
    }
    startCountdown()
  }).catch(() => {
    // 错误提示由 utils/request.js 统一弹出
  }).finally(() => {
    sending.value = false
  })
}

function handleRegister() {
  if (!registerForm.value.agreed) {
    agreeShake.value = true
    setTimeout(() => { agreeShake.value = false }, 600)
    proxy.$modal.msgWarning("请先阅读并勾选《用户协议》与《隐私政策》")
    return
  }
  registerRef.value.validate(valid => {
    if (!valid) return
    loading.value = true
    registerByPhone({
      phone: registerForm.value.phone,
      code: registerForm.value.code,
      password: registerForm.value.password,
      agreed: true
    }).then(() => {
      proxy.$modal.msgSuccess("注册成功，请用手机号和密码登录")
      router.push({ path: "/login", query: { phone: registerForm.value.phone } })
    }).catch(() => {
      loading.value = false
    })
  })
}

onBeforeUnmount(() => {
  clearInterval(timer)
})
</script>

<style lang="scss" scoped>
.register {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100%;
  min-height: 100vh;
  background-image: url("../assets/images/login-background.jpg");
  background-size: cover;
  background-position: center;
}

.title {
  margin: 0;
  text-align: center;
  color: #303133;
  font-size: 22px;
  letter-spacing: 1px;
}

.subtitle {
  margin: 6px 0 16px;
  text-align: center;
  color: #909399;
  font-size: 12px;
  letter-spacing: 1px;
}

.register-form {
  border-radius: 10px;
  background: #ffffff;
  width: 420px;
  padding: 28px 30px 10px;
  box-shadow: 0 12px 40px rgba(0, 0, 0, 0.18);

  .el-input {
    height: 40px;
    input {
      height: 40px;
    }
  }
  .input-icon {
    height: 39px;
    width: 14px;
    margin-left: 0px;
  }
}

.disabled-tip,
.mock-tip {
  margin-bottom: 16px;
}

.sms-btn {
  width: 40%;
  margin-left: 2%;
  padding: 0 8px;
  font-size: 13px;
}

.agree-row {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  margin: 0 0 16px;
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

.el-register-footer {
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
