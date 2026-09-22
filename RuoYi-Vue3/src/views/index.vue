<template>
  <div class="app-container student-home">
    <!-- 欢迎区 -->
    <el-card class="welcome-card" shadow="never">
      <div class="welcome-inner">
        <div class="welcome-text">
          <h2>你好，{{ nickName }} 👋</h2>
          <p>今天也要加油面试，离 offer 更近一步。</p>
        </div>
        <div class="welcome-avatar">
          <el-avatar :size="64" :src="avatar" />
        </div>
      </div>
    </el-card>

    <!-- 快捷入口 -->
    <el-row :gutter="20" class="entry-row">
      <el-col :xs="24" :sm="12" :md="6">
        <el-card class="entry-card" shadow="hover" @click="goInterview">
          <el-icon class="entry-icon" :size="36"><VideoCamera /></el-icon>
          <div class="entry-title">开始面试</div>
          <div class="entry-desc">选择行业与岗位，进入 AI 模拟面试</div>
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="12" :md="6">
        <el-card class="entry-card" shadow="hover" @click="goResume">
          <el-icon class="entry-icon" :size="36"><Document /></el-icon>
          <div class="entry-title">我的简历</div>
          <div class="entry-desc">上传、查看、解析你的简历</div>
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="12" :md="6">
        <el-card class="entry-card" shadow="hover" @click="goReport">
          <el-icon class="entry-icon" :size="36"><DataAnalysis /></el-icon>
          <div class="entry-title">复盘报告</div>
          <div class="entry-desc">查看历史面试记录与多维评分</div>
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="12" :md="6">
        <el-card class="entry-card" shadow="hover" @click="goMine">
          <el-icon class="entry-icon" :size="36"><User /></el-icon>
          <div class="entry-title">个人中心</div>
          <div class="entry-desc">昵称头像、账号设置与协议</div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 最近报告摘要（阶段一先静态占位） -->
    <el-card class="recent-card" shadow="never">
      <template #header>
        <div class="card-header">
          <span>最近一次面试</span>
          <el-button text type="primary" @click="goReport">查看全部</el-button>
        </div>
      </template>
      <el-empty description="还没有面试记录，先去开始一场模拟面试吧" />
    </el-card>
  </div>
</template>

<script setup name="Index">
import { computed } from "vue";
import { useRouter } from "vue-router";
import useUserStore from "@/store/modules/user";

const router = useRouter();
const userStore = useUserStore();

const nickName = computed(() => userStore.nickName || userStore.name || "同学");
const avatar = computed(() => userStore.avatar || "");

function goInterview() {
  // 进入「模拟面试场次」页，那里才有「开始面试」入口
  router.push("/student/session");
}

function goResume() {
  router.push("/student/resume");
}

function goReport() {
  router.push("/student/report");
}

function goMine() {
  router.push("/student/mine");
}
</script>

<style scoped lang="scss">
.student-home {
  .welcome-card {
    margin-bottom: 20px;
    border: none;
    background: linear-gradient(135deg, #409eff 0%, #79bbff 100%);
    color: #fff;

    :deep(.el-card__body) {
      padding: 24px 28px;
    }

    .welcome-inner {
      display: flex;
      align-items: center;
      justify-content: space-between;
    }

    .welcome-text {
      h2 {
        margin: 0 0 8px;
        font-size: 22px;
        color: #fff;
      }
      p {
        margin: 0;
        font-size: 14px;
        color: rgba(255, 255, 255, 0.9);
      }
    }
  }

  .entry-row {
    margin-bottom: 20px;

    .el-col {
      margin-bottom: 20px;
    }
  }

  .entry-card {
    cursor: pointer;
    text-align: center;
    padding: 10px 0;
    transition: transform 0.2s;

    &:hover {
      transform: translateY(-4px);
    }

    .entry-icon {
      color: #409eff;
    }

    .entry-title {
      margin-top: 10px;
      font-size: 16px;
      font-weight: 600;
    }

    .entry-desc {
      margin-top: 6px;
      font-size: 13px;
      color: #909399;
    }
  }

  .recent-card {
    .card-header {
      display: flex;
      align-items: center;
      justify-content: space-between;
    }
  }
}
</style>
