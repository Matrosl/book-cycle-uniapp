<!-- 开发人：XXX，负责模块：登录功能 -->
<template>
  <view class="login-container">
    <!-- 品牌标题区域 -->
    <view class="brand-section">
      <view class="brand-logo">📚</view>
      <view class="brand-title">校园二手书交易系统</view>
      <view class="brand-subtitle">知识传递，环保先行</view>
    </view>
    
    <!-- 登录表单卡片 -->
    <view class="login-card">
      <u-form :model="loginForm" :rules="loginRules" ref="loginFormRef">
        <u-form-item label="校园学号" prop="studentId">
          <u-input v-model="loginForm.studentId" placeholder="请输入学号"></u-input>
        </u-form-item>
        <u-form-item label="密码" prop="password">
          <u-input v-model="loginForm.password" type="password" placeholder="请输入密码"></u-input>
        </u-form-item>
        <u-form-item>
          <u-switch v-model="loginForm.rememberPwd" label="记住密码"></u-switch>记住密码
        </u-form-item>
        <u-button type="primary" @click="login" class="login-btn">登录</u-button>
      </u-form>
    </view>
    
    <!-- 注册链接 -->
    <view class="register-link">
      <text>没有账号？</text>
      <text class="link-text" @click="goToRegister">立即注册</text>
    </view>
  </view>
</template>

<script>
import request from '@/common/request.js';

export default {
  data() {
    return {
      loginForm: {
        studentId: '',
        password: '',
        rememberPwd: false
      },
      loginRules: {
        studentId: [{ required: true, message: '请输入校园学号', trigger: 'blur' }],
        password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
      }
    };
  },
  onShow() {
    // 读取本地缓存的密码
    const rememberInfo = uni.getStorageSync('loginInfo');
    if (rememberInfo) {
      this.loginForm.studentId = rememberInfo.studentId;
      this.loginForm.password = rememberInfo.password;
      this.loginForm.rememberPwd = true;
    }
  },
  methods: {
    // 跳转到注册页面
    goToRegister() {
      uni.navigateTo({
        url: '/pages/register/register'
      });
    },
    async login() {
      // 表单校验
      const valid = await this.$refs.loginFormRef.validate();
      if (!valid) return;
      // 调用登录接口
      try {
        const res = await request.post('/user/login', this.loginForm);
        console.log('登录响应:', res);
        // 从完整响应中获取data部分
        const responseData = res.data;
        if (responseData.code === 200 || responseData.success) {
          // 记住密码
          if (this.loginForm.rememberPwd) {
            uni.setStorageSync('loginInfo', {
              studentId: this.loginForm.studentId,
              password: this.loginForm.password
            });
          } else {
            uni.removeStorageSync('loginInfo');
          }
          // 存储用户信息和学号，跳转到检索页
          const userInfo = responseData.data || { studentId: this.loginForm.studentId };
          uni.setStorageSync('userInfo', userInfo);
          uni.setStorageSync('studentId', userInfo.studentId || this.loginForm.studentId);
          uni.switchTab({
            url: '/pages/book-search/book-search'
          });
        } else {
          uni.showToast({
            title: responseData.message || responseData.msg || '登录失败',
            icon: 'none'
          });
        }
      } catch (err) {
        console.log('登录失败：', err);
        uni.showToast({
          title: '登录失败，请稍后重试',
          icon: 'none'
        });
      }
    }
  }
};
</script>

<style scoped>
/* 登录容器，添加渐变背景 */
.login-container {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 40rpx 30rpx;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

/* 品牌标题区域 */
.brand-section {
  text-align: center;
  margin-bottom: 60rpx;
}

.brand-logo {
  font-size: 120rpx;
  margin-bottom: 20rpx;
  animation: bounce 1.5s ease-in-out infinite;
}

.brand-title {
  font-size: 48rpx;
  font-weight: bold;
  color: #fff;
  margin-bottom: 10rpx;
}

.brand-subtitle {
  font-size: 28rpx;
  color: rgba(255, 255, 255, 0.8);
}

/* 登录卡片容器 */
.login-card {
  width: 100%;
  max-width: 600rpx;
  background-color: #fff;
  border-radius: 24rpx;
  padding: 50rpx 40rpx;
  box-shadow: 0 20rpx 60rpx rgba(0, 0, 0, 0.2);
  backdrop-filter: blur(10rpx);
}

/* 表单美化 */
.u-form-item {
  margin-bottom: 30rpx;
}

.u-form-item__label {
  font-size: 32rpx;
  font-weight: 500;
  color: #333;
}

.u-input {
  height: 80rpx;
  font-size: 30rpx;
  border-radius: 12rpx;
  border: 2rpx solid #e4e7ed;
  transition: all 0.3s ease;
}

.u-input:focus {
  border-color: #667eea;
  box-shadow: 0 0 0 4rpx rgba(102, 126, 234, 0.1);
}

/* 登录按钮美化 */
.login-btn {
  margin-top: 50rpx;
  height: 90rpx;
  font-size: 34rpx;
  font-weight: bold;
  border-radius: 16rpx;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;
  transition: all 0.3s ease;
}

.login-btn:hover {
  transform: translateY(-2rpx);
  box-shadow: 0 10rpx 30rpx rgba(102, 126, 234, 0.4);
}

.login-btn:active {
  transform: translateY(0);
}

/* 注册链接 */
.register-link {
  margin-top: 40rpx;
  text-align: center;
  font-size: 28rpx;
  color: rgba(255, 255, 255, 0.9);
}

.link-text {
  color: #fff;
  margin-left: 10rpx;
  font-weight: 500;
  text-decoration: underline;
  transition: color 0.3s ease;
}

.link-text:hover {
  color: #f0f0f0;
}

/* 记住密码开关 */
.u-switch {
  font-size: 28rpx;
  color: #666;
}

/* 动画效果 */
@keyframes bounce {
  0%, 20%, 50%, 80%, 100% {
    transform: translateY(0);
  }
  40% {
    transform: translateY(-10rpx);
  }
  60% {
    transform: translateY(-5rpx);
  }
}
</style>