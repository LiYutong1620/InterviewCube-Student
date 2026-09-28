<template>
  <div class="forget">
    <el-form ref="formRef" :model="form" :rules="rules" class="forget-form">
      <h3 class="title">{{ title }}</h3>
      <p class="subtitle">手机号验证码重置密码</p>

      <el-steps :active="1" align-center class="forget-steps">
        <el-step title="验证手机号" />
        <el-step title="设置新密码" />
      </el-steps>

      <el-form-item prop="phone">
        <el-input
          v-model="form.phone"
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
          v-model="form.code"
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

      <el-form-item prop="password" :rules="infoPwdValidator">
        <el-input
          v-model="form.password"
          type="password"
          show-password
          size="large"
          auto-complete="off"
          placeholder="新密码"
        >
          <template #prefix><svg-icon icon-class="password" class="el-input__icon input-icon" /></template>
        </el-input>
      </el-form-item>

      <el-form-item prop="confirmPassword">
        <el-input
          v-model="form.confirmPassword"
          type="password"
          show-password
          size="large"
          auto-complete="off"
          placeholder="确认新密码"
          @keyup.enter="handleReset"
        >
          <template #prefix><svg-icon icon-class="password" class="el-input__icon input-icon" /></template>
        </el-input>
      </el-form-item>

      <el-form-item style="width:100%;">
        <el-button :loading="loading" size="large" type="primary" style="width:100%;" @click.prevent="handleReset">
          <span v-if="!loading">重 置 密 码</span>
          <span v-else>提 交 中...</span>
        </el-button>
        <div style="float: right;">
          <router-link class="link-type" :to="'/login'">返回登录</router-link>
        </div>
      </el-form-item>
    </el-form>

    <div class="el-forget-footer" v-if="footerVisible">
      <span>{{ footerContent }}</span>
    </div>
  </div>
</template>

<script setup>
import { ref, onBeforeUnmount, getCurrentInstance } from "vue"
import { useRouter } from "vue-router"
import { sendSmsCode, resetPwdByPhone } from "@/api/interview/auth"
import defaultSettings from "@/settings"
import { usePasswordRule } from "@/utils/passwordRule"

const title = import.meta.env.VITE_APP_TITLE
const footerContent = defaultSettings.footerContent
const footerVisible = defaultSettings.footerVisible
const router = useRouter()
const { proxy } = getCurrentInstance()
const { infoPwdValidator } = usePasswordRule()

/** 手机号格式（与后端 AuthCodeConstants.PHONE_PATTERN 保持一致） */
const PHONE_RE = /^1[3-9]\d{9}$/

const formRef = ref()
const loading = ref(false)
const sending = ref(false)
const countdown = ref(0)
const mockCode = ref("")
let timer = null

const form = ref({
  phone: "",
  code: "",
  password: "",
  confirmPassword: ""
})

const equalToPassword = (rule, value, callback) => {
  if (form.value.password !== value) {
    callback(new Error("两次输入的密码不一致"))
  } else {
    callback()
  }
}

const rules = {
  phone: [
    { required: true, trigger: "blur", message: "请输入手机号" },
    { pattern: PHONE_RE, trigger: "blur", message: "手机号格式不正确" }
  ],
  code: [{ required: true, trigger: "change", message: "请输入短信验证码" }],
  confirmPassword: [
    { required: true, trigger: "blur", message: "请再次输入新密码" },
    { required: true, validator: equalToPassword, trigger: "blur" }
  ]
}

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
  if (!PHONE_RE.test(form.value.phone)) {
    proxy.$modal.msgWarning("请输入正确的手机号")
    return
  }
  sending.value = true
  // 场景固定 resetPwd —— 后端验证码按场景隔离，登录用的码换不了密码
  sendSmsCode({ phone: form.value.phone, scene: "resetPwd" }).then(res => {
    if (res.mock && res.mockCode) {
      mockCode.value = res.mockCode
      form.value.code = res.mockCode
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

function handleReset() {
  formRef.value.validate(valid => {
    if (!valid) return
    loading.value = true
    resetPwdByPhone({
      phone: form.value.phone,
      code: form.value.code,
      password: form.value.password
    }).then(() => {
      proxy.$modal.msgSuccess("密码已重置，请用新密码登录")
      router.push({ path: "/login", query: { phone: form.value.phone } })
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
.forget {
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
  margin: 6px 0 4px;
  text-align: center;
  color: #909399;
  font-size: 12px;
  letter-spacing: 1px;
}

.forget-steps {
  margin: 12px 0 20px;

  :deep(.el-step__title) {
    font-size: 12px;
  }
}

.forget-form {
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

.mock-tip {
  margin-bottom: 16px;
}

.sms-btn {
  width: 40%;
  margin-left: 2%;
  padding: 0 8px;
  font-size: 13px;
}

.el-forget-footer {
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
