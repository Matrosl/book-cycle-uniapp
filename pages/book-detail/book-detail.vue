<!-- 开发人：XXX，负责模块：书籍详情 -->
<template>
  <view class="detail-container">
    <!-- 加载状态 -->
    <u-loadmore v-if="isLoading" :status="'loading'" loading-text="正在加载书籍详情..." style="padding: 100rpx 0;"></u-loadmore>
    
    <!-- 书籍详情内容 -->
    <view v-else class="content-wrapper">
      <!-- 书籍封面 -->
      <view class="cover-section">
        <image class="book-cover" :src="getAvatarUrl(bookInfo.coverUrl) || '/static/images/default-book.png'" mode="aspectFit"></image>
      </view>
      
      <!-- 书籍基本信息 -->
      <view class="info-section">
        <view class="book-name">{{ bookInfo.bookName || '未知书籍' }}</view>
        <view class="book-author" v-if="bookInfo.author">作者：{{ bookInfo.author }}</view>
        <view class="book-publisher" v-if="bookInfo.publisher">出版社：{{ bookInfo.publisher }}</view>
        <view class="book-isbn">ISBN：{{ bookInfo.isbn || '无' }}</view>
        <view class="book-price">¥{{ bookInfo.price || '0.00' }}</view>
        <view class="book-quality">成色：{{ bookInfo.quality || '0' }}星</view>
      </view>
      
      <!-- 书籍详细信息 -->
      <view class="detail-section">
        <view class="section-title">书籍详情</view>
        <view class="detail-item" v-if="bookInfo.category">
          <text class="label">分类：</text>
          <text class="value">{{ bookInfo.category }}</text>
        </view>
        <view class="detail-item" v-if="bookInfo.publishDate">
          <text class="label">出版日期：</text>
          <text class="value">{{ bookInfo.publishDate }}</text>
        </view>
        <view class="detail-item" v-if="bookInfo.pages">
          <text class="label">页数：</text>
          <text class="value">{{ bookInfo.pages }}</text>
        </view>
        <view class="detail-item" v-if="bookInfo.description || bookInfo.remark">
          <text class="label">描述：</text>
          <text class="value">{{ bookInfo.description || bookInfo.remark }}</text>
        </view>
      </view>
      
      <!-- 操作按钮 -->
      <view class="action-buttons">
        <u-button type="primary" @click="toMessageAdd">发起留言</u-button>
      </view>
    </view>
  </view>
</template>

<script>
import uButton from '@/uni_modules/uview-ui/components/u-button/u-button.vue';
import uLoadmore from '@/uni_modules/uview-ui/components/u-loadmore/u-loadmore.vue';

export default {
  components: {
    uButton,
    uLoadmore
  },
  data() {
    return {
      bookId: '',
      bookInfo: {
        bookName: '',
        isbn: '',
        price: '',
        quality: '',
        remark: '',
        coverUrl: '',
        // 添加更多可能的书籍信息字段
        author: '',
        publisher: '',
        publishDate: '',
        category: '',
        pages: '',
        description: ''
      },
      isLoading: true
    };
  },
  onLoad(options) {
    this.bookId = options.id || options.bookId; // 兼容id和bookId两种参数名
    this.getBookDetail();
  },
  methods: {
	// 获取图片URL
	getAvatarUrl(avatarUrl) {
	  const baseUrl = "http://localhost:8080";
	  if (!avatarUrl) {
	    return '/static/images/default-book.png';
	  }
	  if (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://') || avatarUrl.startsWith('data:')) {
	    return avatarUrl;
	  }
	  return baseUrl + avatarUrl;
	},
    // 获取书籍详情
    async getBookDetail() {
      try {
        this.isLoading = true;
        // 构建请求参数，直接根据bookId获取单本书籍
        const body = {
          bookId: this.bookId
        };

        console.log('请求参数:', body);
        // 使用POST /book/getById接口直接获取单本书籍详情
        const res = await this.$request.post('/book/getById', body);
        console.log('后端返回:', res);
        
        // 检查HTTP请求是否成功
        if (res && res.statusCode === 200) {
          const responseData = res.data;
          console.log('业务响应数据:', responseData);
          
          // 检查业务逻辑是否成功
          if (responseData && responseData.success) {
            // 直接使用返回的单本书籍数据
            this.bookInfo = responseData.data || {};
          } else {
            console.error('获取书籍详情失败:', responseData);
            uni.showToast({
              title: responseData?.msg || '获取书籍详情失败',
              icon: 'none'
            });
          }
        } else {
          console.error('HTTP请求失败:', res);
          uni.showToast({
            title: '服务器连接失败',
            icon: 'none'
          });
        }
      } catch (err) {
        console.error('获取书籍详情失败：', err);
        uni.showToast({
          title: '获取书籍详情失败，请稍后重试',
          icon: 'none'
        });
      } finally {
        this.isLoading = false;
      }
    },
    // 跳转到留言页
    toMessageAdd() {
      uni.navigateTo({
        url: `/pages/message-add/message-add?bookId=${this.bookId}`
      });
    }
  }
};
</script>

<style scoped>
.detail-container {
  padding: 0;
  min-height: 100vh;
  background-color: #f8f8f8;
}

.content-wrapper {
  padding: 30rpx;
}

/* 封面区域 */
.cover-section {
  background-color: #fff;
  padding: 40rpx;
  border-radius: 0 0 20rpx 20rpx;
  box-shadow: 0 2rpx 10rpx rgba(0, 0, 0, 0.05);
  display: flex;
  justify-content: center;
  margin-bottom: 30rpx;
}

.book-cover {
  width: 240rpx;
  height: 320rpx;
  border-radius: 12rpx;
  box-shadow: 0 4rpx 15rpx rgba(0, 0, 0, 0.1);
}

/* 基本信息区域 */
.info-section {
  background-color: #fff;
  padding: 40rpx;
  border-radius: 20rpx;
  box-shadow: 0 2rpx 10rpx rgba(0, 0, 0, 0.05);
  margin-bottom: 30rpx;
}

.book-name {
  font-size: 38rpx;
  font-weight: bold;
  color: #333;
  margin-bottom: 15rpx;
  text-align: center;
}

.book-author {
  font-size: 30rpx;
  color: #666;
  margin-bottom: 10rpx;
  text-align: center;
}

.book-publisher {
  font-size: 28rpx;
  color: #999;
  margin-bottom: 15rpx;
  text-align: center;
}

.book-isbn {
  font-size: 26rpx;
  color: #999;
  margin-bottom: 20rpx;
  text-align: center;
}

.book-price {
  font-size: 40rpx;
  color: #f56c6c;
  font-weight: bold;
  margin-bottom: 15rpx;
  text-align: center;
}

.book-quality {
  font-size: 30rpx;
  color: #67c23a;
  text-align: center;
}

/* 详细信息区域 */
.detail-section {
  background-color: #fff;
  padding: 30rpx;
  border-radius: 20rpx;
  box-shadow: 0 2rpx 10rpx rgba(0, 0, 0, 0.05);
  margin-bottom: 30rpx;
}

.section-title {
  font-size: 32rpx;
  font-weight: bold;
  color: #333;
  margin-bottom: 25rpx;
  padding-bottom: 15rpx;
  border-bottom: 2rpx solid #f0f0f0;
}

.detail-item {
  display: flex;
  margin-bottom: 20rpx;
  padding: 10rpx 0;
}

.label {
  font-size: 28rpx;
  color: #666;
  width: 150rpx;
  flex-shrink: 0;
}

.value {
  font-size: 28rpx;
  color: #333;
  flex: 1;
}



/* 操作按钮区域 */
.action-buttons {
  background-color: #fff;
  padding: 30rpx;
  border-radius: 20rpx 20rpx 0 0;
  box-shadow: 0 -2rpx 10rpx rgba(0, 0, 0, 0.05);
  position: sticky;
  bottom: 0;
  left: 0;
  right: 0;
}

.action-buttons .u-button {
  width: 100%;
  height: 90rpx;
  font-size: 32rpx;
  border-radius: 15rpx;
}
</style>