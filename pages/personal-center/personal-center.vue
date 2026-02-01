<template>
  <view class="personal-center">
    <!-- 顶部用户信息区 -->
    <view class="user-info-section">
      <view class="user-avatar-wrapper">
        <image 
          class="user-avatar" 
          :src="getAvatarUrl(userInfo.avatarUrl)" 
          mode="aspectFill"
        ></image>
      </view>
      <view class="user-details">
        <view class="user-name">{{ userInfo.nickName || '未设置昵称' }}</view>
        <view class="user-student-id">学号：{{ userInfo.studentId || '未知学号' }}</view>
      </view>
    </view>

    <!-- 统计数据区 -->
    <view class="statistics-section">
      <view class="stat-item" @click="goToMyBooks">
        <view class="stat-number">{{ userStatistics.publishedBooks }}</view>
        <view class="stat-label">已发布</view>
      </view>
      <view class="stat-item" @click="goToTransactionRecords">
        <view class="stat-number">{{ userStatistics.purchasedBooks }}</view>
        <view class="stat-label">已购买</view>
      </view>
      <view class="stat-item" @click="goToMyReviews">
        <view class="stat-number">{{ userStatistics.soldBooks }}</view>
        <view class="stat-label">已售出</view>
      </view>
      <view class="stat-item">
        <view class="stat-number">{{ userStatistics.score }}</view>
        <view class="stat-label">积分</view>
      </view>
    </view>

    <!-- 功能菜单区 -->
    <u-cell-group class="menu-group">
      <u-cell 
          :title="'我的书籍'" 
          :value="myBooksCount" 
          :icon="'bookmark'"
          icon-size="24"
          is-link 
          @click="goToMyBooks"
      />
      <u-cell 
          :title="'交易记录'" 
          :value="transactionCount" 
          :icon="'clock'"
          icon-size="24"
          is-link 
          @click="goToTransactionRecords"
      />
      <u-cell 
          :title="'我的留言'" 
          :value="reviewsCount" 
          :icon="'chat'"
          icon-size="24"
          is-link 
          @click="goToMyReviews"
      />
      <u-cell 
          :title="'设置'" 
          :icon="'setting'"
          icon-size="24"
          is-link 
          @click="goToSettings"
      />
    </u-cell-group>

    <!-- 书籍展示区域 -->
    <view>
      <!-- 已发布书籍列表 -->
      <view class="books-section" v-if="userBooks.length > 0">
        <view class="section-title">
          <text>我发布的书籍</text>
          <u-button type="text" size="mini" @click="goToMyBooks">查看全部</u-button>
        </view>
        <view class="books-list">
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
      </view>

      <!-- 空状态提示 -->
      <view v-if="userBooks.length === 0" class="empty-state">
        <image src="/static/icons/no-data.svg" mode="aspectFit" class="empty-image"></image>
        <text class="empty-text">暂无发布的书籍</text>
      </view>
    </view>
  </view>
</template>

<script>
import request from '@/common/request.js';
import uButton from '@/uni_modules/uview-ui/components/u-button/u-button.vue';
import uCellGroup from '@/uni_modules/uview-ui/components/u-cell-group/u-cell-group.vue';
import uCell from '@/uni_modules/uview-ui/components/u-cell/u-cell.vue';
import uIcon from '@/uni_modules/uview-ui/components/u-icon/u-icon.vue';

export default {
  components: {
    uButton,
    uCellGroup,
    uCell,
    uIcon
  },
  data() {
    return {
      userInfo: {
        nickName: '',
        studentId: '',
        department: '',
        avatarUrl: '',
        classField: '',
        phone: '',
        email: '',
        introduction: ''
      },
      userStatistics: {
        publishedBooks: 0,
        purchasedBooks: 0,
        soldBooks: 0,
        score: 5.0
      },
      userBooks: []
    };
  },
  onLoad() {
    this.loadUserCenterData();
  },

  methods: {
    // 从后端加载个人中心数据
    loadUserCenterData() {
      // 从缓存获取用户信息
      const userInfo = uni.getStorageSync('userInfo');
      const studentId = userInfo && userInfo.studentId ? userInfo.studentId : '';
      if (!studentId) {
        console.error('用户未登录');
        uni.showToast({
          title: '用户未登录',
          icon: 'none'
        });
        return;
      }

      console.log('开始请求个人中心数据，学号:', studentId);

      // 调用后端个人中心数据接口
      request.post('/user/info', { studentId }) 
        .then(res => {
          console.log('后端返回的个人中心数据:', res);
          
          // 处理不同的后端响应格式，从res.data中获取业务状态
          const responseData = res.data || {};
          if (responseData.success || responseData.code === 200 || responseData.code === '00000' || responseData.status === 'success') {
            const backendData = responseData.data || {};
            
            console.log('处理后的后端数据:', backendData);
            
            // 处理用户信息
            if (backendData.user) {
              const userData = backendData.user;
              this.userInfo = {
                nickName: userData.nickName || userData.nick_name || '',
                studentId: userData.studentId || userData.student_id || studentId,
                department: userData.department || '',
                avatarUrl: userData.avatarUrl || userData.avatar_url || '',
                classField: userData.classField || userData.class || '',
                phone: userData.phone || '',
                email: userData.email || '',
                introduction: userData.introduction || ''
              };
              
              // 更新积分统计
              this.userStatistics.score = userData.score || 0;
              
              // 保存用户信息到本地缓存
              uni.setStorageSync('userInfo', this.userInfo);
              console.log('用户信息更新:', this.userInfo);
            }
            
            // 处理书籍列表
            if (backendData.bookList || backendData.books) {
              const bookList = backendData.bookList || backendData.books;
              // 将后端的 Book 实体映射到前端可用的格式
              this.userBooks = bookList.map(book => ({
                id: book.bookId || book.book_id,
                title: book.bookName || book.book_name,
                author: book.author || '',
                cover: book.coverUrl || book.cover_url,
                status: book.status === 0 ? 'available' : book.status === 1 ? 'sold' : 'unavailable'
              }));
              
              // 更新已发布书籍数量
              this.userStatistics.publishedBooks = this.userBooks.length;
              console.log('已发布书籍数量:', this.userStatistics.publishedBooks);
            }
            
            // 更新购买记录和已售出记录数量（从后端获取）
            this.userStatistics.purchasedBooks = backendData.purchasedBooks || backendData.purchased_books || 0;
            this.userStatistics.soldBooks = backendData.soldBooks || backendData.sold_books || 0;
            console.log('统计数据更新:', this.userStatistics);
            
            console.log('个人中心数据加载完成');
          } else {
            console.error('获取个人中心数据失败:', responseData.msg || responseData.message || '未知错误');
            uni.showToast({
              title: responseData.msg || responseData.message || '获取个人中心数据失败',
              icon: 'none'
            });
          }
        }) 
        .catch(err => {
          console.error('获取个人中心数据失败:', err);
          uni.showToast({
            title: '获取个人中心数据失败',
            icon: 'none'
          });
        });
    },
    // 获取完整的头像URL
    getAvatarUrl(avatarUrl) {
      const baseUrl = "http://localhost:8080";
      if (!avatarUrl) {
        return '/static/icons/user-placeholder.svg';
      }
      if (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://') || avatarUrl.startsWith('data:')) {
        return avatarUrl;
      }
      return baseUrl + avatarUrl;
    },
    
    // 前往我的书籍
    goToMyBooks() {
      uni.navigateTo({
        url: '/pages/my-books/my-books'
      });
    },
    // 前往交易记录
    goToTransactionRecords() {
      uni.navigateTo({
        url: '/pages/borrow-records/borrow-records'
      });
    },
    // 前往我的评价
    goToMyReviews() {
      uni.navigateTo({
        url: '/pages/my-reviews/my-reviews'
      });
    },
    // 前往设置
    goToSettings() {
      uni.navigateTo({
        url: '/pages/settings/settings'
      });
    },
    // 删除书籍
    deleteBook(bookId, index) {
      uni.showModal({
        title: '确认删除',
        content: '确定要删除这本书吗？',
        success: (res) => {
          if (res.confirm) {
            // 调用删除书籍的API
            request.post('/book/delete', { bookId: bookId }) 
              .then(response => {
                console.log('删除书籍后端响应:', response);
                const responseData = response.data || {};
                if (responseData.success || responseData.code === 200 || responseData.code === '00000') {
                  // 从列表中移除
                  this.userBooks.splice(index, 1);
                  this.userStatistics.publishedBooks--;
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
/* 主容器样式 */
.personal-center {
  min-height: 100vh;
  background-color: #f5f5f5;
}

/* 用户信息区域 */
.user-info-section {
  background-color: #fff;
  padding: 40rpx 30rpx;
  margin-bottom: 20rpx;
  border-radius: 12rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.1);
  display: flex;
  align-items: center;
}

.user-avatar-wrapper {
  margin-right: 30rpx;
}

.user-avatar {
  width: 120rpx;
  height: 120rpx;
  border-radius: 60rpx;
  border: 4rpx solid #f0f0f0;
}

.user-details {
  flex: 1;
  margin-right: 30rpx;
}

.user-name {
  font-size: 36rpx;
  font-weight: bold;
  color: #333;
  margin-bottom: 10rpx;
}

.user-student-id {
  font-size: 28rpx;
  color: #666;
  margin-bottom: 8rpx;
}

.user-department {
  font-size: 24rpx;
  color: #999;
}

.user-class {
  font-size: 22rpx;
  color: #999;
}

.user-info-section .edit-button {
  
  width: 200rpx !important;
  font-size: 18rpx !important;
  margin-right: 20px;
  padding: 4rpx 8rpx !important;
  height: 50rpx !important;
  line-height: 50rpx !important;
  border-radius: 18rpx !important;
}

/* 统计数据区域 */
.statistics-section {
  background-color: #fff;
  padding: 30rpx;
  margin-bottom: 20rpx;
  border-radius: 12rpx;
  display: flex;
  justify-content: space-around;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.1);
}

.stat-item {
  text-align: center;
  flex: 1;
}

.stat-number {
  font-size: 36rpx;
  font-weight: bold;
  color: #333;
  margin-bottom: 10rpx;
}

.stat-label {
  font-size: 24rpx;
  color: #999;
}

/* 菜单区域 */
.menu-section {
  background-color: #fff;
  margin-bottom: 20rpx;
  border-radius: 12rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.1);
}

/* 书籍区域 */
.books-section {
  background-color: #fff;
  padding: 30rpx;
  border-radius: 12rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.1);
  margin-bottom: 20rpx;
}

.section-title {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30rpx;
  font-size: 32rpx;
  font-weight: bold;
  color: #333;
}

.books-list {
  display: flex;
  flex-direction: column;
}

.book-item {
  display: flex;
  align-items: center;
  padding: 20rpx 0;
  border-bottom: 1rpx solid #eee;
}

.book-item:last-child {
  border-bottom: none;
}

.book-cover {
  width: 120rpx;
  height: 160rpx;
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

/* 空状态 */
.empty-state {
  background-color: #fff;
  padding: 100rpx 30rpx;
  text-align: center;
  border-radius: 12rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.1);
}

.empty-image {
  width: 30rpx;
  height: 30rpx;
  margin-bottom: 30rpx;
}

.empty-text {
  font-size: 28rpx;
  color: #999;
}
</style>