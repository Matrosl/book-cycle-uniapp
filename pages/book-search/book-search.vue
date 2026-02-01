<template>
  <view class="search-container">
    <!-- 搜索栏 -->
    <view class="search-bar-container">
      <u-search
        v-model="searchKey"
        placeholder="请输入书名/ISBN检索"
        @input="onSearchInput"
        @search="searchBook"
        @custom="clearSearch"
        show-action
        action-text="取消"
        bgColor="#f5f7fa"
        borderColor="#e4e7ed"
        placeholderColor="#909399"
        cancelColor="#409eff"
        searchIconColor="#c0c4cc"
        clearIconColor="#c0c4cc"
        height="60"
        radius="45"
        auto-focus
      ></u-search>
    </view>
    
    <!-- 搜索历史 -->
    <view v-if="searchHistory.length > 0 && !isSearching" class="history-container">
      <view class="history-header">
        <text class="history-title">搜索历史</text>
        <u-icon name="trash" @click="clearHistory" color="#999" size="24"></u-icon>
      </view>
      <view class="history-list">
        <view 
          v-for="(item, index) in searchHistory" 
          :key="index"
          class="history-item"
          @click="searchByHistory(item)"
        >
          <text class="history-text">{{ item }}</text>
          <u-icon name="close" @click.stop="removeHistory(index)" color="#ccc" size="18"></u-icon>
        </view>
      </view>
    </view>
    
    <!-- 分类筛选 -->
    <u-subsection :list="['全部', '教材', '课外书']" :current="activeType" style="height: 40px; font-size: 40px;" @change="changeType"></u-subsection>
    
    <!-- 搜索结果数量 -->
    <view class="result-count">
      <text class="count-text">共找到 {{ total }} 本相关书籍</text>
    </view>
    
    <!-- 书籍列表 -->
    <view class="book-list">
      <!-- 初始加载状态 -->
      <view v-if="isLoading && bookList.length === 0" class="loading-container">
        <u-loadmore :status="'loading'"></u-loadmore>
      </view>
      
      <!-- 书籍列表 -->
      <view v-else-if="bookList.length > 0">
        <view 
          v-for="(item, index) in bookList" 
          :key="item.bookId || index"
          class="book-item"
          @click="toBookDetail(item)"
        >
          <image :src="getAvatarUrl(item.coverUrl) || '/static/images/default-book.png'" mode="aspectFill" style="width: 120rpx; height: 160rpx; border-radius: 8rpx;"></image>
          <view class="book-info">
            <view class="book-name">{{ item.bookName }}</view>
            <view class="book-isbn">ISBN：{{ item.isbn }}</view>
            <view class="book-meta">
              <text class="book-price">¥{{ item.price }}</text>
              <text class="book-quality">成色：{{ item.quality }}星</text>
            </view>
          </view>
          <view class="book-action">
            <u-button size="mini" type="primary" @click.stop="toMessageAdd(item.bookId)">留言</u-button>
          </view>
        </view>
        
        <!-- 加载更多 -->
        <view v-if="hasMore" class="load-more-container">
          <u-loadmore :status="'loading'" @click="loadMore"></u-loadmore>
        </view>
      </view>
      
      <!-- 空状态 -->
      <view v-else-if="!isLoading" class="empty-state">
        <image src="/static/images/empty-book.png" mode="widthFix" style="width: 200rpx; height: 200rpx; margin-bottom: 30rpx;"></image>
        <text class="empty-text">暂无书籍数据</text>
        <text class="empty-subtext">试试调整筛选条件或搜索关键词</text>
        <u-button size="small" type="primary" @click="resetAll">重置所有</u-button>
      </view>
    </view>
  </view>
</template>

<script>
import uSearch from '@/uni_modules/uview-ui/components/u-search/u-search.vue';
import uIcon from '@/uni_modules/uview-ui/components/u-icon/u-icon.vue';
import uSubsection from '@/uni_modules/uview-ui/components/u-subsection/u-subsection.vue';
import uButton from '@/uni_modules/uview-ui/components/u-button/u-button.vue';
import uLoadmore from '@/uni_modules/uview-ui/components/u-loadmore/u-loadmore.vue';

export default {
  components: {
    uSearch,
    uIcon,
    uSubsection,
    uButton,
    uLoadmore
  },
  data() {
    return {
      searchKey: '',
      activeType: 0, // 0-全部 1-教材 2-课外书
      bookList: [],
      pageNum: 1, // 分页
      pageSize: 10,
      hasMore: true,
      total: 0, // 总数量
      searchHistory: [], // 搜索历史
      isSearching: false, // 是否正在搜索中
      isLoading: false, // 是否正在加载
      historyKey: 'book_search_history', // 本地存储键名
      searchTimer: null, // 搜索防抖定时器
      debounceTime: 500 // 防抖时间(ms)
    };
  },
  onLoad() {
    // 加载搜索历史
    this.loadSearchHistory();
  },
  onShow() {
    // 初始化加载书籍
    this.getBookList();
  },
  
  onUnload() {
    // 组件销毁时清除定时器
    if (this.searchTimer) {
      clearTimeout(this.searchTimer);
    }
  },
  methods: {
    // 加载搜索历史
    loadSearchHistory() {
      const history = uni.getStorageSync(this.historyKey);
      this.searchHistory = Array.isArray(history) ? history : [];
    },
    
    // 保存搜索历史
    saveSearchHistory() {
      if (Array.isArray(this.searchHistory)) {
        uni.setStorageSync(this.historyKey, this.searchHistory);
      } else {
        console.error('searchHistory must be an array');
        this.searchHistory = [];
        uni.setStorageSync(this.historyKey, this.searchHistory);
      }
    },
    
    // 添加搜索历史
    addSearchHistory(keyword) {
      if (!keyword.trim()) return;
      
      // 去重：如果已存在则移到最前面
      const index = this.searchHistory.indexOf(keyword);
      if (index > -1) {
        this.searchHistory.splice(index, 1);
      }
      
      // 添加到最前面
      this.searchHistory.unshift(keyword);
      
      // 限制历史记录数量
      if (this.searchHistory.length > 10) {
        this.searchHistory.pop();
      }
      
      // 保存到本地存储
      this.saveSearchHistory();
    },
    
    // 通过历史记录搜索
    searchByHistory(keyword) {
      this.searchKey = keyword;
      this.searchBook();
    },
    
    // 删除单个历史记录
    removeHistory(index) {
      this.searchHistory.splice(index, 1);
      this.saveSearchHistory();
    },
    
    // 清空所有历史记录
    clearHistory() {
      uni.showModal({
        title: '提示',
        content: '确定要清空搜索历史吗？',
        success: res => {
          if (res.confirm) {
            this.searchHistory = [];
            this.saveSearchHistory();
          }
        }
      });
    },
    
    // 清除搜索输入
    clearSearch() {
      this.searchKey = '';
      this.isSearching = false;
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
    },
    // 获取书籍列表
    async getBookList() {
      try {
        // 设置加载状态
        if (this.pageNum === 1) {
          this.isLoading = true;
          this.isSearching = true;
        }
        
        // 构建请求参数
        const params = {
          searchKey: this.searchKey,
          type: this.activeType,
          pageNum: this.pageNum,
          pageSize: this.pageSize
        };

        console.log('请求参数:', params);
        const res = await this.$request.get('/book/list', params);
        console.log('后端返回:', res);
        
        // 检查HTTP请求是否成功
        if (res && res.statusCode === 200) {
          const responseData = res.data;
          console.log('业务响应数据:', responseData);
          
          // 检查业务逻辑是否成功
          if (responseData && responseData.success) {
            // 处理后端返回的数据
            const bookData = responseData.data || [];
            
            if (this.pageNum === 1) {
              this.bookList = bookData;
            } else {
              this.bookList = [...this.bookList, ...bookData];
            }
            
            // 更新总数量
            this.total = responseData.total || responseData.count || bookData.length;
            
            // 判断是否有更多数据
            this.hasMore = bookData.length === this.pageSize;
            
            console.log('书籍列表:', this.bookList);
            console.log('总数量:', this.total);
          } else {
            console.error('获取书籍失败:', responseData);
            uni.showToast({
              title: responseData?.msg || '获取书籍失败',
              icon: 'none'
            });
            this.bookList = [];
            this.total = 0;
          }
        } else {
          console.error('HTTP请求失败:', res);
          uni.showToast({
            title: '服务器连接失败',
            icon: 'none'
          });
          this.bookList = [];
          this.total = 0;
        }
      } catch (err) {
        console.error('获取书籍异常:', err);
        uni.showToast({
          title: '网络错误，请稍后重试',
          icon: 'none'
        });
        this.bookList = [];
        this.total = 0;
      } finally {
        // 关闭加载状态
        this.isLoading = false;
        this.isSearching = false;
      }
    },
    
    // 搜索输入防抖处理
    onSearchInput() {
      // 清除之前的定时器
      if (this.searchTimer) {
        clearTimeout(this.searchTimer);
      }
      
      // 设置新的定时器
      this.searchTimer = setTimeout(() => {
        if (this.searchKey.trim()) {
          this.pageNum = 1;
          this.isSearching = true;
          this.getBookList();
        } else {
          this.isSearching = false;
          // 清空搜索时加载全部数据
          this.pageNum = 1;
          this.getBookList();
        }
      }, this.debounceTime);
    },
    
    // 搜索书籍
    searchBook() {
      if (!this.searchKey.trim()) return;
      
      // 清除定时器，立即执行搜索
      if (this.searchTimer) {
        clearTimeout(this.searchTimer);
      }
      
      this.pageNum = 1;
      this.isSearching = true;
      
      // 添加到搜索历史
      this.addSearchHistory(this.searchKey);
      
      this.getBookList();
    },
    
    // 切换分类
    changeType(index) {
      // 确保index是有效的
      if (typeof index === 'number' && index >= 0 && index <= 2) {
        this.activeType = index;
        this.pageNum = 1;
        this.getBookList();
      }
    },
    
    // 下拉刷新
    onRefresh() {
      // 重置分页并重新获取数据
      this.pageNum = 1;
      this.getBookList();
    },
    
    // 加载更多
    loadMore() {
      this.pageNum++;
      this.getBookList();
    },
    
    // 跳转到书籍详情
    toBookDetail(item) {
      uni.navigateTo({
        url: `/pages/book-detail/book-detail?bookId=${item.bookId}`
      });
    },
    
    // 跳转到留言页
    toMessageAdd(bookId) {
      uni.navigateTo({
        url: `/pages/message-add/message-add?bookId=${bookId}`
      });
    },
    
    // 重置所有
    resetAll() {
      this.searchKey = '';
      this.activeType = 0;
      this.pageNum = 1;
      this.getBookList();
    }
  }
};
</script>

<style scoped>
.search-container {
  padding-bottom: 20rpx;
  background-color: #fafafa;
}

/* 搜索栏容器样式 */
.search-bar-container {
  padding: 20rpx 30rpx;
  background-color: #fff;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.05);
}

/* 搜索历史样式 */
.history-container {
  padding: 24rpx 30rpx;
  background-color: #fff;
  margin-bottom: 20rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.05);
  border-radius: 16rpx;
  margin: 20rpx 20rpx 30rpx;
  animation: slideUp 0.3s ease-out;
}

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(20rpx);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.history-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24rpx;
}

.history-title {
  font-size: 32rpx;
  font-weight: 600;
  color: #303133;
  letter-spacing: 0.5rpx;
}

.history-header u-icon {
  transition: all 0.3s ease;
}

.history-header u-icon:active {
  transform: scale(0.9);
  opacity: 0.8;
}

.history-list {
  display: flex;
  flex-wrap: wrap;
  gap: 16rpx;
}

.history-item {
  display: flex;
  align-items: center;
  background-color: #f5f7fa;
  border-radius: 24rpx;
  padding: 12rpx 20rpx;
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
  box-shadow: 0 2rpx 6rpx rgba(0, 0, 0, 0.05);
  animation: fadeIn 0.3s ease-out;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: scale(0.8);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}

.history-item:active {
  transform: scale(0.98);
  background-color: #ecf5ff;
  box-shadow: 0 2rpx 8rpx rgba(64, 158, 255, 0.15);
}

.history-text {
  font-size: 28rpx;
  color: #606266;
  margin-right: 12rpx;
  line-height: 1.4;
}

.history-item u-icon {
  transition: all 0.3s ease;
  color: #c0c4cc;
}

.history-item u-icon:active {
  color: #f56c6c;
  transform: scale(1.2);
}

/* 分类筛选样式 */
/* 自定义u-subsection样式 */
/deep/.u-subsection {
  background-color: #fff;
  margin: 0 20rpx 24rpx;
  border-radius: 24rpx;
  box-shadow: 0 4rpx 16rpx rgba(0, 0, 0, 0.08);
  overflow: hidden;
}

/deep/.u-subsection__wrap {
  padding: 8rpx;
  display: flex;
  justify-content: center;
  gap: 12rpx;
}

/deep/.u-subsection-item {
  font-size: 28rpx;
  font-weight: 500;
  color: #606266;
  transition: all 0.3s ease;
  padding: 12rpx 32rpx;
  border-radius: 16rpx;
  background-color: transparent;
  margin: 0;
}

/deep/.u-subsection-item:active {
  background-color: #ecf5ff;
  color: #409eff;
}

/deep/.u-subsection-item--active {
  color: #409eff;
  font-weight: 600;
  background-color: #ecf5ff;
  box-shadow: 0 2rpx 8rpx rgba(64, 158, 255, 0.2);
  transform: translateY(-1rpx);
}

/deep/.u-subsection-line {
  display: none; /* 隐藏下划线，使用背景色和阴影来标识激活状态 */
}

/* 搜索结果数量样式 */
.result-count {
  padding: 15rpx 20rpx;
  background-color: #fff;
  margin: 0 20rpx 20rpx;
  border-radius: 16rpx;
  box-shadow: 0 2rpx 8rpx rgba(0, 0, 0, 0.05);
}

.count-text {
  font-size: 26rpx;
  color: #666;
}

/* 空状态样式 */
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 80rpx 40rpx;
  background-color: #fff;
  margin: 20rpx 20rpx 0;
  border-radius: 16rpx;
  box-shadow: 0 4rpx 16rpx rgba(0, 0, 0, 0.08);
  animation: fadeIn 0.5s ease-out;
}

.empty-state image {
  opacity: 0.8;
  transition: opacity 0.3s ease;
}

.empty-state image:active {
  opacity: 1;
  transform: scale(1.05);
  transition: all 0.3s ease;
}

.empty-text {
  font-size: 34rpx;
  font-weight: 500;
  color: #303133;
  margin-bottom: 16rpx;
}

.empty-subtext {
  font-size: 26rpx;
  color: #909399;
  text-align: center;
  line-height: 1.5;
  margin-bottom: 48rpx;
  padding: 0 40rpx;
}

/* 加载状态样式 */
.loading-container {
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 80rpx 0;
  background-color: #fff;
  margin: 20rpx 20rpx 0;
  border-radius: 16rpx;
  box-shadow: 0 4rpx 16rpx rgba(0, 0, 0, 0.08);
}

/* 加载更多样式 */
.load-more-container {
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 40rpx 0;
}

/* 书籍列表容器 */
.book-list {
  padding: 0 20rpx;
}

/* 书籍列表美化 */
.book-item {
  display: flex;
  padding: 24rpx;
  margin-bottom: 24rpx;
  border-radius: 16rpx;
  box-shadow: 0 4rpx 16rpx rgba(0, 0, 0, 0.08);
  background-color: #fff;
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
  animation: bookItemSlideIn 0.4s ease-out;
  opacity: 0;
  animation-fill-mode: forwards;
}

/* 为不同的书籍项设置不同的动画延迟，形成交错效果 */
.book-item:nth-child(1) { animation-delay: 0.05s; }
.book-item:nth-child(2) { animation-delay: 0.1s; }
.book-item:nth-child(3) { animation-delay: 0.15s; }
.book-item:nth-child(4) { animation-delay: 0.2s; }
.book-item:nth-child(5) { animation-delay: 0.25s; }
.book-item:nth-child(6) { animation-delay: 0.3s; }
.book-item:nth-child(7) { animation-delay: 0.35s; }
.book-item:nth-child(8) { animation-delay: 0.4s; }
.book-item:nth-child(9) { animation-delay: 0.45s; }
.book-item:nth-child(10) { animation-delay: 0.5s; }

@keyframes bookItemSlideIn {
  from {
    opacity: 0;
    transform: translateX(-30rpx);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

/* 添加悬停效果 */
.book-item:active {
  transform: translateY(-2rpx);
  box-shadow: 0 8rpx 24rpx rgba(0, 0, 0, 0.12);
}

/* 书籍封面 */
.book-item image {
  width: 140rpx;
  height: 180rpx;
  border-radius: 8rpx;
  box-shadow: 0 2rpx 8rpx rgba(0, 0, 0, 0.1);
  transition: transform 0.3s ease;
}

.book-item:active image {
  transform: scale(1.05);
}

.book-info {
  flex: 1;
  padding: 0 24rpx;
  min-height: 180rpx;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.book-name {
  font-size: 34rpx;
  font-weight: 600;
  color: #303133;
  margin-bottom: 12rpx;
  overflow: hidden;
  text-overflow: ellipsis;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  line-height: 1.4;
}

.book-isbn {
  font-size: 24rpx;
  color: #909399;
  margin-bottom: 12rpx;
  line-height: 1.3;
}

.book-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: auto;
}

.book-price {
  font-size: 36rpx;
  color: #f56c6c;
  font-weight: bold;
  letter-spacing: 1rpx;
}

.book-quality {
  font-size: 24rpx;
  color: #606266;
  background-color: #f5f7fa;
  padding: 4rpx 12rpx;
  border-radius: 12rpx;
}

.book-action {
  display: flex;
  flex-direction: column;
  justify-content: flex-end;
  padding-bottom: 8rpx;
}

.book-action u-button {
  border-radius: 20rpx;
  font-size: 24rpx;
  padding: 12rpx 24rpx;
  box-shadow: 0 2rpx 8rpx rgba(64, 158, 255, 0.2);
  transition: all 0.3s ease;
}

.book-action u-button:active {
  transform: scale(0.95);
  box-shadow: 0 1rpx 4rpx rgba(64, 158, 255, 0.2);
}
</style>