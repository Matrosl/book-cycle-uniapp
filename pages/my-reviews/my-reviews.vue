<!-- 我的留言页面 -->
<template>
  <view class="my-messages-container">
    <view class="page-header">
      <text class="header-title">我的留言</text>
    </view>

    <!-- 留言列表 -->
    <view class="messages-list">
      <u-list v-if="messages.length > 0">
        <u-list-item v-for="(message, index) in messages" :key="index">
          <view class="message-item">
            <view class="message-header">
              <view class="message-status">
                <u-tag :type="message.status === '已回复' ? 'success' : 'warning'" size="small">
                  {{ message.status }}
                </u-tag>
              </view>
              <view class="message-date">{{ message.createTime }}</view>
            </view>
            <view class="message-content">
              <text class="content-label">我的留言：</text>
              <text>{{ message.content }}</text>
            </view>
            <view class="message-reply" v-if="message.status === '已回复' && message.replyContent">
              <text class="reply-label">回复内容：</text>
              <text>{{ message.replyContent }}</text>
              <view class="reply-date">回复时间：{{ message.replyTime }}</view>
            </view>
          </view>
        </u-list-item>
      </u-list>
      <view v-else class="empty-tip">
        <image src="/static/icons/no-data.svg" mode="aspectFit" style="width: 120rpx; height: 120rpx; margin-bottom: 20rpx;"></image>
        <text>暂无留言记录</text>
      </view>
    </view>
  </view>
</template>

<script>
import request from '@/common/request.js';
import uList from '@/uni_modules/uview-ui/components/u-list/u-list.vue';
import uListItem from '@/uni_modules/uview-ui/components/u-list-item/u-list-item.vue';
import uTag from '@/uni_modules/uview-ui/components/u-tag/u-tag.vue';

export default {
  components: {
    uList,
    uListItem,
    uTag
  },
  data() {
      return {
        messages: [],
        userInfo: {}
      };
    },
  onShow() {
    // 获取用户信息
    this.userInfo = uni.getStorageSync('userInfo');
    // 获取留言记录
    this.getMessages();
  },
  methods: {
    // 获取留言记录
    async getMessages() {
      try {
        // 确保用户已登录
        if (!this.userInfo || !this.userInfo.studentId) {
          uni.showToast({
            title: '用户未登录',
            icon: 'none'
          });
          return;
        }
        
        const res = await request.post('/message/my-messages', {
          studentId: this.userInfo.studentId
        });
        
        // 处理后端响应
        const responseData = res.data || {};
        if (responseData.success || responseData.code === 200 || responseData.code === '00000') {
          this.messages = responseData.data?.messages || responseData.messages || [];
        } else {
          uni.showToast({
            title: responseData.msg || '获取留言失败',
            icon: 'none'
          });
        }
      } catch (err) {
        console.error('获取留言记录失败：', err);
        uni.showToast({
          title: '获取留言失败',
          icon: 'none'
        });
      }
    }
  }
};
</script>

<style scoped>
.my-messages-container {
  background-color: #f5f5f5;
  min-height: 100vh;
  padding-bottom: 20rpx;
}

/* 页面头部 */
.page-header {
  background-color: white;
  padding: 30rpx 40rpx;
  margin-bottom: 20rpx;
  box-shadow: 0 2rpx 8rpx rgba(0, 0, 0, 0.05);
  text-align: center;
}

.header-title {
  font-size: 36rpx;
  font-weight: bold;
  color: #333;
}

/* 留言列表 */
.messages-list {
  margin: 0 20rpx;
}

.message-item {
  padding: 20rpx;
  background-color: white;
  border-radius: 16rpx;
  margin-bottom: 20rpx;
  box-shadow: 0 2rpx 8rpx rgba(0, 0, 0, 0.05);
}

.message-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15rpx;
}

.message-status {
  display: flex;
  align-items: center;
}

.message-date {
  font-size: 24rpx;
  color: #999;
}

.message-content {
  display: flex;
  flex-direction: column;
  gap: 10rpx;
  margin-bottom: 15rpx;
}

.content-label {
  font-size: 28rpx;
  font-weight: bold;
  color: #333;
}

.message-content text:not(.content-label) {
  font-size: 28rpx;
  color: #333;
  line-height: 1.6;
}

.message-reply {
  display: flex;
  flex-direction: column;
  gap: 10rpx;
  padding: 15rpx;
  background-color: #f8f9fa;
  border-radius: 8rpx;
}

.reply-label {
  font-size: 28rpx;
  font-weight: bold;
  color: #333;
}

.message-reply text:not(.reply-label) {
  font-size: 28rpx;
  color: #333;
  line-height: 1.6;
}

.reply-date {
  font-size: 24rpx;
  color: #999;
  align-self: flex-end;
  margin-top: 5rpx;
}

/* 空状态提示 */
.empty-tip {
  text-align: center;
  padding: 100rpx 0;
  color: #999;
}

.empty-tip text {
  display: block;
  font-size: 30rpx;
  margin-bottom: 20rpx;
}
</style>