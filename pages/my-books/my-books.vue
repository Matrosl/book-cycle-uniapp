<template>
  <view class="my-books">
    <view class="page-header">
      <text class="page-title">我的书籍</text>
    </view>
    
    <view class="books-list" v-if="userBooks.length > 0">
      <view v-for="(book, index) in userBooks" :key="book.id" class="book-item">
        <image 
          class="book-cover" 
          :src="getAvatarUrl(book.cover)" 
          mode="aspectFit"
        ></image>
        <view class="book-info">
          <view class="book-title">{{ book.title }}</view>
          <view class="book-author">{{ book.author || '未知作者' }}</view>
          <view class="book-status">
            <text class="status-text">{{ book.status === 'available' ? '可购买' : book.status === 'sold' ? '已售出' : '已下架' }}</text>
          </view>
        </view>
        <view class="book-actions">
          <u-button type="error" size="mini" @click="deleteBook(book.id, index)">删除</u-button>
        </view>
      </view>
    </view>
    
    <!-- 空状态提示 -->
    <view v-if="userBooks.length === 0" class="empty-state">
      <image src="/static/icons/no-data.svg" mode="aspectFit" class="empty-image"></image>
      <text class="empty-text">暂无发布的书籍</text>
    </view>
  </view>
</template>

<script>
import request from '@/common/request.js';
import uImage from '@/uni_modules/uview-ui/components/u-image/u-image.vue';
import uButton from '@/uni_modules/uview-ui/components/u-button/u-button.vue';

export default {
  components: {
    uImage,
    uButton
  },
  data() {
    return {
      userBooks: []
    };
  },
  onLoad() {
    this.loadUserBooks();
  },
  methods: {
    loadUserBooks() {
      const userInfo = uni.getStorageSync('userInfo');
      const studentId = userInfo && userInfo.studentId ? userInfo.studentId : '';
      if (!studentId) {
        uni.showToast({
          title: '用户未登录',
          icon: 'none'
        });
        return;
      }
      
      request.post('/user/info', { studentId })
        .then(res => {
          console.log('我的书籍数据:', res);
          const responseData = res.data || {};
          if (responseData.success || responseData.code === 200 || responseData.code === '00000' || responseData.status === 'success') {
            const backendData = responseData.data || {};
            if (backendData.bookList || backendData.books) {
              const bookList = backendData.bookList || backendData.books;
              this.userBooks = bookList.map(book => ({
                id: book.bookId || book.book_id,
                title: book.bookName || book.book_name,
                author: book.author || '',
                cover: book.coverUrl || book.cover_url,
                status: book.status === 0 ? 'available' : book.status === 1 ? 'sold' : 'unavailable'
              }));
            }
          }
        })
        .catch(err => {
          console.error('获取书籍列表失败:', err);
          uni.showToast({
            title: '获取书籍列表失败',
            icon: 'none'
          });
        });
    },
    getAvatarUrl(avatarUrl) {
      const baseUrl = "http://localhost:8080";
      if (!avatarUrl) {
        return '/static/icons/book-placeholder.svg';
      }
      if (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://') || avatarUrl.startsWith('data:')) {
        return avatarUrl;
      }
      return baseUrl + avatarUrl;
    },
    deleteBook(bookId, index) {
      uni.showModal({
        title: '确认删除',
        content: '确定要删除这本书吗？',
        success: (res) => {
          if (res.confirm) {
            request.post('/book/delete', { bookId: bookId })
              .then(response => {
                console.log('删除书籍后端响应:', response);
                const responseData = response.data || {};
                if (responseData.success || responseData.code === 200 || responseData.code === '00000') {
                  this.userBooks.splice(index, 1);
                  uni.showToast({
                    title: responseData.msg || '删除成功',
                    icon: 'success'
                  });
                } else {
                  uni.showToast({
                    title: responseData.msg || '删除失败',
                    icon: 'none'
                  });
                }
              })
              .catch(err => {
                console.error('删除书籍失败:', err);
                uni.showToast({
                  title: '删除失败',
                  icon: 'none'
                });
              });
          }
        }
      });
    }
  }
};
</script>

<style scoped>
.my-books {
  min-height: 100vh;
  background-color: #f5f5f5;
  padding: 20rpx;
}

.page-header {
  background-color: #fff;
  padding: 30rpx;
  margin-bottom: 20rpx;
  border-radius: 12rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.1);
  text-align: center;
}

.page-title {
  font-size: 36rpx;
  font-weight: bold;
  color: #333;
}

.books-list {
  display: flex;
  flex-direction: column;
}

.book-item {
  background-color: #fff;
  margin-bottom: 20rpx;
  border-radius: 12rpx;
  padding: 30rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.1);
  display: flex;
  align-items: center;
}

.book-cover {
  width: 100rpx;
  height: 140rpx;
  margin-right: 20rpx;
  border-radius: 8rpx;
}

.book-info {
  flex: 1;
}

.book-title {
  font-size: 28rpx;
  font-weight: bold;
  color: #333;
  margin-bottom: 8rpx;
}

.book-author {
  font-size: 24rpx;
  color: #666;
  margin-bottom: 8rpx;
}

.book-status {
  font-size: 20rpx;
}

.status-text {
  padding: 4rpx 12rpx;
  border-radius: 12rpx;
  background-color: #f0f0f0;
  color: #666;
}

.book-actions {
  margin-left: 20rpx;
}

.empty-state {
  background-color: #fff;
  padding: 100rpx 30rpx;
  text-align: center;
  border-radius: 12rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.1);
}

.empty-image {
  width: 200rpx;
  height: 200rpx;
  margin-bottom: 30rpx;
}

.empty-text {
  font-size: 28rpx;
  color: #999;
}
</style>