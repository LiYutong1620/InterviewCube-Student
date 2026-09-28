<template>
  <div class="agreement">
    <div class="agreement-card">
      <div class="agreement-head">
        <h2 class="agreement-title">面立方 · 隐私政策</h2>
        <span class="agreement-date">生效日期：2026 年 09 月 28 日</span>
      </div>

      <el-alert
        class="placeholder-tip"
        type="warning"
        :closable="false"
        show-icon
        title="当前为占位正文"
        description="上线前请由法务/运营替换为正式条款，并核对「收集的信息」一节与系统实际采集的字段是否一致。"
      />

      <div class="agreement-body">
        <section>
          <h3>一、我们收集哪些信息</h3>
          <p>1. 账号信息：您注册时提供的手机号，以及系统生成的账号标识。</p>
          <p>2. 您主动填写的信息：学生档案（昵称、学历等）、岗位画像（意向行业、岗位、难度等）、简历文件及其解析结果。</p>
          <p>3. 面试过程数据：模拟面试场次、题目、您的作答内容，以及基于作答生成的复盘报告。</p>
          <p>4. 设备与日志信息：登录 IP、浏览器类型、操作系统、登录时间等，用于安全审计与问题排查。</p>
        </section>

        <section>
          <h3>二、我们如何使用这些信息</h3>
          <p>1. 提供核心服务：生成模拟面试题目、评价作答表现、输出复盘报告。</p>
          <p>2. 账号与安全：完成登录校验、找回密码、识别异常登录行为。</p>
          <p>3. 服务改进：在去除可识别个人身份的信息后，用于统计分析与产品优化。</p>
        </section>

        <section>
          <h3>三、信息的存储与保护</h3>
          <p>1. 您的信息存储于本平台部署的服务器中，我们会采取访问控制、传输加密等必要措施保护数据安全。</p>
          <p>2. 账号密码以不可逆加密方式存储，我们无法查看您的明文密码。</p>
          <p>3. 我们仅在实现服务目的所必需的期限内保留您的信息，超出期限后将删除或匿名化处理。</p>
        </section>

        <section>
          <h3>四、信息的共享与对外提供</h3>
          <p>
            我们不会向任何第三方出售您的个人信息。仅在下列情形下可能共享：
          </p>
          <p>1. 已获得您的明确同意；</p>
          <p>2. 为实现服务功能而必须使用的第三方服务商（例如短信验证码通道），且仅提供完成该功能所必需的信息；</p>
          <p>3. 依据法律法规或监管部门的强制性要求。</p>
        </section>

        <section>
          <h3>五、您的权利</h3>
          <p>1. 查阅与更正：您可以在「学生档案」「学生简历」等页面查看并修改自己填写的信息。</p>
          <p>2. 删除：您可以删除自己上传的简历、作答记录等内容。</p>
          <p>3. 注销：如需注销账号，可通过本平台公布的客服渠道提出申请。</p>
        </section>

        <section>
          <h3>六、未成年人保护</h3>
          <p>
            本平台主要面向在校学生与应届生。若您为未成年人，请在监护人陪同下阅读本政策，并在取得监护人同意后使用本平台服务。
          </p>
        </section>

        <section>
          <h3>七、政策更新与联系方式</h3>
          <p>
            本政策可能不定期更新，更新后的版本将在本页面公布，并标注新的生效日期。
            如您对本政策有疑问或需要行使上述权利，可通过本平台公布的客服渠道与我们联系。
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
