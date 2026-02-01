<!-- 开发人：XXX，负责模块：交易留言 -->
<template>
  <view class="message-container">
    <u-form :model="messageForm" :rules="messageRules" ref="messageFormRef">
      <u-form-item label="留言内容" prop="content">
        <u-input v-model="messageForm.content" type="textarea" placeholder="请输入您的留言内容" :height="150"></u-input>
      </u-form-item>
      <u-form-item label="联系电话" prop="phone">
        <u-input v-model="messageForm.phone" placeholder="请输入您的联系电话" type="number"></u-input>
      </u-form-item>
      <u-button type="primary" @click="sendMessage" class="send-btn">发送留言</u-button>
    </u-form>
  </view>
</template>

<script>
export default {
  data() {
    return {
      messageForm: {
        bookId: '',
        studentId: '',
        content: ''
      },
      messageRules: {
        content: [{ required: true, message: '请输入留言内容', trigger: 'blur' }]
      }
    };
  },
  onLoad(options) {
    this.messageForm.bookId = options.bookId;
    // 获取当前登录用户学号
    const userInfo = uni.getStorageSync('userInfo');
    if (userInfo && userInfo.studentId) {
      this.messageForm.studentId = userInfo.studentId;
    } else {
      // 未登录时跳转登录页
      uni.navigateTo({ url: '/pages/login/login' });
    }
  },
  methods: {
    // 发送留言
    async sendMessage() {
      const valid = await this.$refs.messageFormRef.validate();
      if (!valid) return;
      try {
        const res = await this.$request.post('/message/add', this.messageForm);
        uni.showToast({
          title: '留言成功',
          icon: 'success'
        });
        // 留言成功后返回上一页
        setTimeout(() => {
          uni.navigateBack();
        }, 1500);
      } catch (err) {
        console.log('留言失败：', err);
        uni.showToast({
          title: '留言失败，请稍后重试',
          icon: 'none'
        });
      }
    }
  }
};
</script>

<style scoped>
.message-container {
  padding: 40rpx 30rpx;
}
.send-btn {
  margin-top: 40rpx;
}
</style>