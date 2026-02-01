<template>
  <view class="index-container">
    <!-- 顶部用户信息栏 -->
    <view class="header">
      <view class="user-info" @click="goToUser">
        <image class="avatar" :src="getAvatarUrl(userInfo.avatarUrl)" mode="aspectFill"></image>
        <text class="user-name">{{userInfo.nickName ? '你好，' + userInfo.nickName : (userInfo.studentId ? '你好，' + userInfo.studentId + '同学' : '未登录')}}</text>
      </view>
      <view class="header-right">
        <image class="icon" src="/static/icons/message.svg" mode="aspectFit" @click="goToNotification"></image>
      </view>
    </view>
    
    <!-- 轮播图 -->
    <view class="banner">
      <swiper :indicator-dots="true" :autoplay="true" :interval="3000" :duration="1000" circular="true">
        <swiper-item v-for="(item, index) in bannerList" :key="index">
          <view class="banner-placeholder" :style="{backgroundColor: item.color}">
            <text class="banner-text">{{item.title}}</text>
          </view>
        </swiper-item>
      </swiper>
    </view>
    
    <!-- 搜索框 -->
    <view class="search-container" @click="goToSearch">
      <text class="search-icon-text">🔍</text>
      <text class="search-placeholder">搜索你想要的书籍...</text>
    </view>
    
    <!-- 功能导航 -->
    <view class="function-nav">
        <view class="nav-item" @click="goToBrowse">
          <image class="nav-icon" src="/static/icons/browse-books.svg" mode="aspectFit"></image>
          <text class="nav-text">浏览书籍</text>
        </view>
        <view class="nav-item" @click="goToPublish">
          <image class="nav-icon" src="/static/icons/publish-books.svg" mode="aspectFit"></image>
          <text class="nav-text">发布书籍</text>
        </view>
        <view class="nav-item" @click="goToTransactions">
          <image class="nav-icon" src="/static/icons/transactions.svg" mode="aspectFit"></image>
          <text class="nav-text">交易记录</text>
        </view>
        <view class="nav-item" @click="goToBookshelf">
          <image class="nav-icon" src="/static/icons/bookshelf.svg" mode="aspectFit"></image>
          <text class="nav-text">我的书架</text>
        </view>
      </view>
    

    
    <!-- 校园小贴士 -->
    <view class="campus-tips-section">
      <view class="section-header">
        <text class="section-title">校园小贴士</text>
      </view>
      <view class="tips-container">
        <view class="tip-item" v-for="(tip, index) in campusTips" :key="index">
          <view class="tip-icon">💡</view>
          <view class="tip-content">
            <text class="tip-title">{{tip.title}}</text>
            <text class="tip-desc">{{tip.content}}</text>
          </view>
        </view>
      </view>
    </view>
    
    <!-- 最新发布 -->
    <view class="new-section">
      <view class="section-header">
        <text class="section-title">最新发布</text>
        <text class="more-btn" @click="goToAllBooks">查看全部 ></text>
      </view>
      <view class="books-list">
        <view class="book-item" v-for="(book, index) in newBooks" :key="index" @click="goToBookDetail(book.id)">
          <image class="book-cover" :src="getAvatarUrl(book.coverUrl)" mode="aspectFill"></image>
          <view class="book-info">
            <text class="book-name">{{book.bookName}}</text>
            <text class="book-price">¥{{book.price}}</text>
            <text class="book-status" :class="{'status-sold': book.status === 1}">{{book.status === 0 ? '待交易' : '已交易'}}</text>
            <text class="book-publish-time">{{formatPublishTime(book.publishTime)}}</text>
          </view>
        </view>
      </view>
    </view>
  </view>
</template>

<script>
	import request from '@/common/request.js';
		export default {
			data() {
				return {
					userInfo: {},
					bannerList: [
						{ id: 1, title: '校园图书循环', color: '#667eea' },
						{ id: 2, title: '知识传递', color: '#f093fb' },
						{ id: 3, title: '环保先行', color: '#4facfe' }
					],
					newBooks: [],
					campusTips: [
						{ id: 1, title: '图书捐赠', content: '闲置书籍可以捐赠到图书馆，帮助更多同学' },
						{ id: 2, title: '交易安全', content: '建议在学校安全区域进行书籍交易，注意个人财物' },
						{ id: 3, title: '图书维护', content: '请爱护书籍，保持书籍整洁，让知识传递更久' },
						{ id: 4, title: '借阅提醒', content: '借阅书籍请按时归还，避免影响他人使用' }
					],

					title: '校园图书循环系统'
				}
			},
			onShow() {
				// 加载用户信息
				this.loadUserInfo();
				// 加载书籍数据
				this.loadBooksData();
			},
			methods: {
				// 加载用户信息
				loadUserInfo() {
					try {
						const userInfo = uni.getStorageSync('userInfo');
						if (userInfo) {
							this.userInfo = userInfo;
						}
					} catch (e) {
						console.error('加载用户信息失败:', e);
					}
				},
				
				// 加载书籍数据
			async loadBooksData() {
				try {
					// 计算14天日期范围
					const today = new Date();
					const twoWeeksAgo = new Date();
					twoWeeksAgo.setDate(today.getDate() - 14);
					
					// 格式化日期为YYYY-MM-DD格式
					const formatDate = (date) => {
						return date.toISOString().split('T')[0];
					};
					
					const endDate = formatDate(today); // 当天日期，格式：YYYY-MM-DD
					const startDate = formatDate(twoWeeksAgo); // 14天前的日期
					
					console.log('请求日期范围:', startDate, '至', endDate);
				
				// 调用真实API获取最新发布
				// API将使用book表的publish_time字段进行日期筛选
				const newRes = await request.get('/book/list', { 
					pageNum: 1, 
					pageSize: 3,
					startDate: startDate,
					endDate: endDate
				});
				
				console.log('API响应:', newRes);
					
					// 处理响应数据
					const responseData = newRes.data || {};
					
					console.log('处理后的响应数据:', responseData);
					
					// 检查业务状态码
					if (responseData.success || responseData.code === 200 || responseData.code === '00000') {
						const books = responseData.data || [];
						console.log('原始书籍数据:', books);
						this.newBooks = books.map(book => ({
							id: book.bookId || book.book_id,
							bookName: book.bookName || book.book_name,
							coverUrl: book.coverUrl || book.cover_url || '/static/icons/book-placeholder.svg',
							price: book.price || 0,
							status: book.status || 0,
							publishTime: book.publishTime || book.publish_time // 保存发布时间
						}));
						console.log('映射后的书籍数据:', this.newBooks);
					} else {
						// API调用成功但业务逻辑失败
						console.warn('获取最新发布书籍失败:', responseData.msg || responseData.message);
						this.newBooks = []; // 清空数据
					}
				} catch (e) {
					console.error('加载书籍数据失败:', e);
					this.newBooks = []; // 清空数据
				}
			},
			
			// 格式化发布时间
			formatPublishTime(publishTime) {
				if (!publishTime) return '';
				
				const date = new Date(publishTime);
				const now = new Date();
				const diffTime = Math.abs(now - date);
				const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));
				
				if (diffDays === 0) {
					// 今天发布
					const hours = date.getHours().toString().padStart(2, '0');
					const minutes = date.getMinutes().toString().padStart(2, '0');
					return `${hours}:${minutes}`;
				} else if (diffDays === 1) {
					// 昨天发布
					return '昨天';
				} else if (diffDays < 7) {
					// 一周内发布
					return `${diffDays}天前`;
				} else {
					// 一周前发布，显示完整日期
					const year = date.getFullYear();
					const month = (date.getMonth() + 1).toString().padStart(2, '0');
					const day = date.getDate().toString().padStart(2, '0');
					return `${year}-${month}-${day}`;
				}
			},
				
				// 页面跳转方法
				goToUser() {
					uni.navigateTo({ url: '/pages/personal-center/personal-center' });
				},
				goToNotification() {
					// 暂时跳转到个人中心，因为项目中没有notification页面
					uni.navigateTo({ url: '/pages/personal-center/personal-center' });
				},
				goToSearch() {
					uni.switchTab({ url: '/pages/book-search/book-search' });
				},
				goToBrowse() {
					uni.switchTab({ url: '/pages/book-search/book-search' });
				},
				goToPublish() {
					uni.switchTab({ url: '/pages/book-publish/book-publish' });
				},
				goToTransactions() {
					uni.navigateTo({ url: '/pages/borrow-records/borrow-records' });
				},
				goToBookshelf() {
					// 使用my-books代替bookshelf，因为项目中没有bookshelf页面
					uni.navigateTo({ url: '/pages/my-books/my-books' });
				},
				goToAllBooks() {
					uni.switchTab({ url: '/pages/book-search/book-search' });
				},
				goToBookDetail(bookId) {
					uni.navigateTo({ url: `/pages/book-detail/book-detail?id=${bookId}` });
				},
				getAvatarUrl(avatarUrl) {
					const baseUrl = "http://localhost:8080";
					if (!avatarUrl) {
						return '/static/icons/user-placeholder.svg';
					}
					if (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://') || avatarUrl.startsWith('data:')) {
						return avatarUrl;
					}
					return baseUrl + avatarUrl;
				}

			}
		}
</script>

<style scoped>
/* 整体容器 */
.index-container {
  min-height: 100vh;
  background-color: #f5f7fa;
  padding-bottom: 40rpx;
}

/* 顶部用户信息栏 */
.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 30rpx 40rpx;
  background-color: #fff;
  box-shadow: 0 2rpx 10rpx rgba(0, 0, 0, 0.05);
}

.user-info {
  display: flex;
  align-items: center;
}

.avatar {
  width: 80rpx;
  height: 80rpx;
  border-radius: 50%;
  margin-right: 20rpx;
  border: 2rpx solid #e4e7ed;
}

.user-name {
  font-size: 32rpx;
  font-weight: 500;
  color: #333;
}

.header-right {
  display: flex;
  align-items: center;
}

.icon {
  width: 50rpx;
  height: 50rpx;
  margin-left: 40rpx;
}

/* 轮播图 */
.banner {
  margin: 20rpx 30rpx;
  border-radius: 15rpx;
  overflow: hidden;
  box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.1);
}

.banner-placeholder {
  width: 100%;
  height: 320rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  background-size: cover;
  background-position: center;
  transition: transform 0.3s ease;
}

.banner-placeholder:active {
  transform: scale(0.98);
}

.banner-text {
  font-size: 40rpx;
  font-weight: bold;
  color: #fff;
  text-shadow: 2rpx 2rpx 4rpx rgba(0, 0, 0, 0.3);
  animation: fadeIn 1s ease;
}

/* 轮播图指示器样式 */
.swiper .uni-swiper-dot {
  width: 16rpx;
  height: 16rpx;
  background-color: rgba(255, 255, 255, 0.5);
  border-radius: 50%;
  margin: 0 8rpx;
}

.swiper .uni-swiper-dot-active {
  background-color: #fff;
  width: 40rpx;
  border-radius: 8rpx;
  transition: width 0.3s ease;
}

/* 淡入动画 */
@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(20rpx);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* 搜索框 */
.search-container {
  display: flex;
  align-items: center;
  background-color: #fff;
  margin: 0 30rpx;
  padding: 20rpx 30rpx;
  border-radius: 50rpx;
  box-shadow: 0 2rpx 10rpx rgba(0, 0, 0, 0.05);
}

.search-icon-text {
  font-size: 36rpx;
  margin-right: 20rpx;
  color: #909399;
}

.search-placeholder {
  font-size: 32rpx;
  color: #909399;
  flex: 1;
}

/* 功能导航 */
.function-nav {
  display: flex;
  justify-content: space-around;
  background-color: #fff;
  margin: 30rpx 30rpx;
  padding: 40rpx 0;
  box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.05);
  border-radius: 15rpx;
}

.nav-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 20rpx;
  border-radius: 15rpx;
  transition: all 0.3s ease;
}

.nav-item:active {
  background-color: #f5f7fa;
  transform: scale(0.95);
}

.nav-icon {
  width: 100rpx;
  height: 100rpx;
  margin-bottom: 15rpx;
  padding: 15rpx;
  border-radius: 20rpx;
  box-shadow: 0 8rpx 25rpx rgba(0, 0, 0, 0.15);
  transition: all 0.3s ease;
}

.nav-icon:hover {
  transform: translateY(-5rpx);
  box-shadow: 0 12rpx 35rpx rgba(0, 0, 0, 0.2);
}

.nav-text {
  font-size: 28rpx;
  font-weight: 500;
  color: #333;
  margin-top: 5rpx;
}



/* 校园小贴士区域 */
.campus-tips-section {
  background-color: #fff;
  margin: 20rpx 30rpx;
  padding: 20rpx;
  box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.05);
  border-radius: 15rpx;
}

.tips-container {
  display: flex;
  flex-direction: column;
  gap: 10rpx;
  margin-top: 15rpx;
}

.tip-item {
  display: flex;
  align-items: flex-start;
  padding: 20rpx;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 14rpx;
  box-shadow: 0 4rpx 15rpx rgba(102, 126, 234, 0.3);
  transition: all 0.3s ease;
  color: #fff;
  margin-bottom: 10rpx;
  position: relative;
  overflow: hidden;
}

.tip-item::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4rpx;
  background: linear-gradient(90deg, transparent, #fff, transparent);
  animation: shine 2s infinite;
}

@keyframes shine {
  0% { transform: translateX(-100%); }
  100% { transform: translateX(100%); }
}

.tip-item:active {
  transform: translateY(-5rpx);
  box-shadow: 0 10rpx 35rpx rgba(102, 126, 234, 0.6);
}

.tip-icon {
  font-size: 32rpx;
  margin-right: 15rpx;
  margin-top: 2rpx;
  flex-shrink: 0;
}

.tip-content {
  flex: 1;
}

.tip-title {
  display: block;
  font-size: 28rpx;
  font-weight: bold;
  margin-bottom: 6rpx;
}

.tip-desc {
  display: block;
  font-size: 22rpx;
  line-height: 32rpx;
  opacity: 0.9;
}

/* 书籍推荐区域 */
.new-section {
  background-color: #fff;
  margin: 20rpx 30rpx;
  padding: 30rpx;
  box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.05);
  border-radius: 15rpx;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30rpx;
  padding-bottom: 15rpx;
  border-bottom: 2rpx solid #f0f0f0;
}

.section-title {
  font-size: 36rpx;
  font-weight: bold;
  color: #333;
  position: relative;
}

.section-title::after {
  content: '';
  position: absolute;
  bottom: -17rpx;
  left: 0;
  width: 60rpx;
  height: 4rpx;
  background-color: #667eea;
  border-radius: 2rpx;
}

.more-btn {
  font-size: 28rpx;
  color: #667eea;
  font-weight: 500;
  transition: color 0.3s ease;
}

.more-btn:active {
  color: #5568d1;
}

/* 书籍列表 */
.books-list {
  display: flex;
  overflow-x: auto;
  padding-bottom: 20rpx;
  scrollbar-width: none;
}

.books-list::-webkit-scrollbar {
  display: none;
}

.book-item {
  width: 220rpx;
  margin-right: 30rpx;
  flex-shrink: 0;
  border-radius: 15rpx;
  padding: 15rpx;
  transition: all 0.3s ease;
  box-shadow: 0 2rpx 10rpx rgba(0, 0, 0, 0.05);
}

.book-item:active {
  transform: translateY(-10rpx);
  box-shadow: 0 10rpx 30rpx rgba(0, 0, 0, 0.1);
}

.book-cover {
  width: 190rpx;
  height: 266rpx;
  border-radius: 10rpx;
  box-shadow: 0 6rpx 20rpx rgba(0, 0, 0, 0.15);
  background-color: #f5f7fa;
  display: flex;
  align-items: center;
  justify-content: center;
}

.book-cover image {
  width: 100%;
  height: 100%;
  border-radius: 10rpx;
}

.book-info {
  margin-top: 20rpx;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  height: 120rpx;
}

.book-name {
  display: block;
  font-size: 28rpx;
  font-weight: 500;
  color: #333;
  margin-bottom: 10rpx;
  overflow: hidden;
  text-overflow: ellipsis;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  line-height: 40rpx;
}

.book-price {
  display: block;
  font-size: 34rpx;
  font-weight: bold;
  color: #ff6b6b;
  margin-bottom: 10rpx;
}

.book-status {
  display: inline-block;
  font-size: 24rpx;
  padding: 6rpx 16rpx;
  border-radius: 20rpx;
  background-color: #e1f5fe;
  color: #0288d1;
  font-weight: 500;
  align-self: flex-start;
}

.book-status.status-sold {
  background-color: #ffebee;
  color: #d32f2f;
}

/* 发布时间 */
.book-publish-time {
  font-size: 22rpx;
  color: #909399;
  margin-top: 8rpx;
  display: block;
  align-self: flex-start;
}

/* 响应式设计 */
/* 大屏设备（桌面端） */
@media screen and (min-width: 750rpx) {
  .index-container {
    max-width: 750rpx;
    margin: 0 auto;
    padding: 0 30rpx;
  }
  
  .books-list {
    justify-content: space-between;
  }
  
  .book-item {
    margin-right: 0;
  }
}

/* 小屏设备（手机端） */
@media screen and (max-width: 375px) {
  /* 调整整体容器 */
  .index-container {
    padding: 0 20rpx;
  }
  
  /* 调整轮播图高度 */
  .banner-placeholder {
    height: 260rpx;
  }
  
  .banner-text {
    font-size: 32rpx;
  }
  
  /* 调整功能导航 */
  .function-nav {
    margin: 20rpx 20rpx;
    padding: 30rpx 0;
  }
  
  .nav-icon {
    width: 76rpx;
    height: 76rpx;
    padding: 16rpx;
  }

  /* 调整校园小贴士和书籍推荐 */
  .campus-tips-section, .new-section {
    margin: 20rpx 20rpx;
    padding: 25rpx;
  }
  
  .book-item {
    width: 180rpx;
    margin-right: 25rpx;
  }
  
  .book-cover {
    width: 150rpx;
    height: 210rpx;
  }
  
  .book-name {
    font-size: 26rpx;
    line-height: 36rpx;
  }
  
  .book-price {
    font-size: 30rpx;
  }
}

/* 平板设备 */
@media screen and (min-width: 751rpx) and (max-width: 1024px) {
  .index-container {
    max-width: 1000rpx;
    margin: 0 auto;
    padding: 0 40rpx;
  }
  
  .books-list {
    justify-content: flex-start;
    flex-wrap: wrap;
  }
  
  .book-item {
    margin-bottom: 30rpx;
  }
}
</style>
