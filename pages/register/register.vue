<!-- 开发人：XXX，负责模块：注册功能 -->
<template>
  <view class="register-container">
    <u-form :model="registerForm" :rules="registerRules" ref="registerFormRef">
      <u-form-item label="校园学号" prop="studentId">
        <u-input v-model="registerForm.studentId" placeholder="请输入学号"></u-input>
      </u-form-item>
      <u-form-item label="昵称" prop="nickName">
        <u-input v-model="registerForm.nickName" placeholder="请输入昵称"></u-input>
      </u-form-item>
      <u-form-item label="密码" prop="password">
        <u-input v-model="registerForm.password" type="password" placeholder="请输入密码"></u-input>
      </u-form-item>
      <u-form-item label="确认密码" prop="confirmPassword">
        <u-input v-model="registerForm.confirmPassword" type="password" placeholder="请再次输入密码"></u-input>
      </u-form-item>
      <u-form-item label="真实姓名" prop="realName">
        <u-input v-model="registerForm.realName" placeholder="请输入真实姓名"></u-input>
      </u-form-item>
      <u-form-item label="手机号" prop="phone">
        <u-input v-model="registerForm.phone" placeholder="请输入手机号"></u-input>
      </u-form-item>
      <u-button type="primary" @click="register" class="register-btn">注册</u-button>
      <view class="login-link">
        <text>已有账号？</text>
        <text class="link-text" @click="goToLogin">立即登录</text>
      </view>
    </u-form>
  </view>
</template>

<script>
import request from '@/common/request.js';

export default {
  data() {
    return {
      registerForm: {
        studentId: '',
        nickName: '',
        password: '',
        confirmPassword: '',
        realName: '',
        phone: '',
        email: '',
        department: ''
      },
      registerRules: {
        studentId: [
          { required: true, message: '请输入校园学号', trigger: 'blur' }
        ],
        nickName: [
          { required: true, message: '请输入昵称', trigger: 'blur' }
        ],
        password: [
          { required: true, message: '请输入密码', trigger: 'blur' },
          { min: 6, max: 20, message: '密码长度在6-20个字符', trigger: 'blur' }
        ],
        confirmPassword: [
          { required: true, message: '请输入确认密码', trigger: 'blur' },
          { validator: this.validateConfirmPassword, trigger: 'blur' }
        ],
        realName: [
          { required: true, message: '请输入真实姓名', trigger: 'blur' }
        ],
        phone: [
          { required: true, message: '请输入手机号', trigger: 'blur' },
          { pattern: /^1[3-9]\d{9}$/, message: '手机号格式不正确', trigger: 'blur' }
        ]
      }
    };
  },
  methods: {
    // 验证确认密码
    validateConfirmPassword(rule, value, callback) {
      if (value !== this.registerForm.password) {
        return callback(new Error('两次输入的密码不一致'));
      }
      callback();
    },
    // 注册
    async register() {
      // 表单校验
      const valid = await this.$refs.registerFormRef.validate();
      if (!valid) return;
      // 调用注册接口
      try {
        const registerData = {
          studentId: this.registerForm.studentId,
          nickName: this.registerForm.nickName,
          password: this.registerForm.password,
          realName: this.registerForm.realName,
          phone: this.registerForm.phone,
          email: this.registerForm.email,
          department: this.registerForm.department
        };
        const res = await request.post('/user/register', registerData);
        console.log('注册响应:', res);
        const responseData = res.data || {};
        // 首先检查HTTP状态码是否为200
        if (res.statusCode === 200) {
          // 然后检查业务状态字段
          if (responseData.code === 200 || responseData.success || !responseData.code) {
            uni.showToast({
              title: '注册成功',
              icon: 'success'
            });
            // 注册成功后跳转到登录页面
            setTimeout(() => {
              uni.navigateBack();
            }, 1500);
          } else {
            uni.showToast({
              title: responseData.message || responseData.msg || '注册失败',
              icon: 'none'
            });
          }
        } else {
          uni.showToast({
            title: '网络请求失败',
            icon: 'none'
          });
        }
      } catch (err) {
        console.log('注册失败：', err);
        uni.showToast({
          title: '注册失败，请稍后重试',
          icon: 'none'
        });
      }
    },
    // 跳转到登录页面
    goToLogin() {
      uni.navigateBack();
    }
  }
};
</script>

<style scoped>
.register-container {
  padding: 40rpx 30rpx;
}
.register-btn {
  margin-top: 40rpx;
}
.login-link {
  margin-top: 30rpx;
  text-align: center;
  font-size: 28rpx;
}
.link-text {
  color: #2979ff;
  margin-left: 10rpx;
}
</style>