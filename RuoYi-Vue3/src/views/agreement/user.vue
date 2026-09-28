<template>
  <div class="agreement">
    <div class="agreement-card">
      <div class="agreement-head">
        <h2 class="agreement-title">面立方 · 用户协议</h2>
        <span class="agreement-date">生效日期：2026 年 09 月 28 日</span>
      </div>

      <el-alert
        class="placeholder-tip"
        type="warning"
        :closable="false"
        show-icon
        title="当前为占位正文"
        description="上线前请由法务/运营替换为正式条款。正文结构已按条款分节，替换时保持小节标题即可，前端无需改动。"
      />

      <div class="agreement-body">
        <section>
          <h3>一、协议的范围</h3>
          <p>
            本协议是您与面立方（以下简称「本平台」）之间就使用本平台提供的 AI 模拟面试服务所订立的协议。
            本平台面向在校学生与应届生，提供岗位画像、简历管理、模拟面试、复盘报告等功能。
          </p>
          <p>
            您在注册、登录或使用本平台服务前，应当完整阅读本协议。当您勾选「我已阅读并同意」并完成注册或登录时，
            即表示您已充分理解并同意本协议的全部内容。
          </p>
        </section>

        <section>
          <h3>二、账号注册与使用</h3>
          <p>1. 本平台采用手机号 + 短信验证码的方式注册账号，一个手机号仅可注册一个账号。</p>
          <p>2. 您应当保证注册时提供的手机号真实、有效，并对账号下的全部行为负责。</p>
          <p>3. 您应妥善保管账号与密码，不得将账号出借、转让或与他人共享。</p>
          <p>4. 如发现账号被盗用或存在其他安全问题，请立即通过本平台公布的渠道联系我们。</p>
        </section>

        <section>
          <h3>三、服务内容</h3>
          <p>
            本平台提供的模拟面试、AI 评价与复盘报告等内容仅供参考，不构成任何形式的录用承诺或职业建议。
            您应结合自身情况独立判断，并自行承担相应决策后果。
          </p>
        </section>

        <section>
          <h3>四、用户行为规范</h3>
          <p>您承诺在使用本平台时遵守法律法规，且不得实施下列行为：</p>
          <p>1. 上传含有违法、淫秽、暴力、歧视或其他不良信息的简历或材料；</p>
          <p>2. 以任何方式干扰、破坏本平台的正常运行，或尝试绕过权限、批量抓取数据；</p>
          <p>3. 冒用他人身份、伪造简历信息，或侵犯他人的知识产权、隐私权等合法权益。</p>
        </section>

        <section>
          <h3>五、知识产权</h3>
          <p>
            本平台的界面设计、程序代码、题库内容及生成的报告模板等，其知识产权归本平台或相应权利人所有。
            您上传的简历等材料，其权利仍归您所有；您授权本平台在提供服务所必需的范围内使用这些材料。
          </p>
        </section>

        <section>
          <h3>六、服务的变更、中断与终止</h3>
          <p>
            本平台可能因升级、维护、不可抗力等原因调整或暂停部分服务，并将尽可能提前告知。
            若您严重违反本协议，我们有权限制或终止向您提供服务。
          </p>
        </section>

        <section>
          <h3>七、免责声明</h3>
          <p>
            对于因网络故障、设备故障、第三方服务异常等非本平台可控因素造成的服务中断或数据延迟，
            本平台在法律允许的范围内不承担责任。
          </p>
        </section>

        <section>
          <h3>八、协议的更新与联系方式</h3>
          <p>
            本协议可能不定期更新，更新后的版本将在本页面公布，并标注新的生效日期。
            如您对协议内容有疑问，可通过本平台公布的客服渠道与我们联系。
          </p>
        </section>
      </div>

      <div class="agreement-foot">
        <el-button @click="goBack">返 回</el-button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { useRouter } from "vue-router"

const router = useRouter()

function goBack() {
  if (window.history.length > 1) {
    router.back()
  } else {
    router.push("/login")
  }
}
</script>

<style lang="scss" scoped>
.agreement {
  min-height: 100vh;
  padding: 32px 16px 60px;
  background: #f5f7fa;
}

.agreement-card {
  max-width: 860px;
  margin: 0 auto;
  padding: 32px 40px 28px;
  border-radius: 10px;
  background: #ffffff;
  box-shadow: 0 6px 24px rgba(0, 0, 0, 0.08);
}

.agreement-head {
  padding-bottom: 16px;
  border-bottom: 1px solid #ebeef5;
}

.agreement-title {
  margin: 0 0 6px;
  font-size: 22px;
  color: #303133;
}

.agreement-date {
  font-size: 12px;
  color: #909399;
}

.placeholder-tip {
  margin: 16px 0 4px;
}

.agreement-body {
  margin-top: 12px;
  color: #303133;
  font-size: 14px;
  line-height: 1.9;

  section {
    margin-bottom: 22px;
  }

  h3 {
    margin: 0 0 8px;
    font-size: 15px;
    color: #303133;
  }

  p {
    margin: 0 0 6px;
    text-indent: 0;
    color: #606266;
  }
}

.agreement-foot {
  padding-top: 12px;
  text-align: center;
  border-top: 1px solid #ebeef5;
}
</style>
