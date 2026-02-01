<!-- 我的交易记录页面 -->
<template>
  <view class="transaction-records-container">
    <view class="page-header">
      <text class="header-title">我的交易记录</text>
    </view>

    <!-- 筛选标签 -->
    <view class="filter-tabs">
      <view class="tab-item" :class="{ active: selectedTab === 'all' }" @click="selectTab('all')">
        <text class="tab-text">全部</text>
      </view>
      <view class="tab-item" :class="{ active: selectedTab === 'pending' }" @click="selectTab('pending')">
        <text class="tab-text">待交易</text>
      </view>
      <view class="tab-item" :class="{ active: selectedTab === 'completed' }" @click="selectTab('completed')">
        <text class="tab-text">已交易</text>
      </view>
    </view>
    
    <!-- 交易类型标签 -->
    <view class="filter-tabs type-tabs">
      <view class="tab-item" :class="{ active: selectedType === 'all' }" @click="selectType('all')">
        <text class="tab-text">全部</text>
      </view>
      <view class="tab-item" :class="{ active: selectedType === 'buy' }" @click="selectType('buy')">
        <text class="tab-text">买入</text>
      </view>
      <view class="tab-item" :class="{ active: selectedType === 'sell' }" @click="selectType('sell')">
        <text class="tab-text">卖出</text>
      </view>
    </view>

    <!-- 交易记录列表 -->
    <view class="records-list">
      <u-list v-if="filteredRecords.length > 0">
        <u-list-item v-for="(record, index) in filteredRecords" :key="index">
          <view class="record-item">
            <image class="book-cover" :src="getAvatarUrl(record.Cover) || '/static/images/book-placeholder.png'" mode="aspectFit"></image>
            <view class="record-info">
              <view class="book-title">{{ record.bookName }}</view>
              <view class="book-author">作者：{{ record.author }}</view>
              <view class="record-price">价格：¥{{ record.price }}</view>
              <view class="record-type-status">
                <u-tag :type="record.type === 'buy' ? 'primary' : 'success'" size="small">{{ record.type === 'buy' ? '买入' : '卖出' }}</u-tag>
                <u-tag :type="getStatusColor(record.status)" size="small" style="margin-left: 10rpx;">{{ getStatusText(record.status) }}</u-tag>
              </view>
              <view class="record-dates">
                <view class="date-item">
                  <text class="date-label">交易时间：</text>
                  <text class="date-text">{{ record.transactionDate }}</text>
                </view>
                <view class="date-item" v-if="record.completeDate">
                  <text class="date-label">完成时间：</text>
                  <text class="date-text">{{ record.completeDate }}</text>
                </view>
              </view>
            </view>
            <view class="record-actions" v-if="record.status === 'pending'">
              <u-button size="mini" type="primary" @click="confirmTransaction(record.recordId)">确认交易</u-button>
              <u-button size="mini" type="warning" @click="contactSeller(record.bookId)">{{ record.type === 'buy' ? '联系卖家' : '联系买家' }}</u-button>
            </view>
            <view class="record-actions" v-if="record.status === 'completed'">
              <u-button size="mini" type="info" @click="viewBookDetail(record.bookId)">查看书籍</u-button>
              <u-button size="mini" type="success" @click="goToReview(record.bookId)">评价书籍</u-button>
            </view>

          </view>
        </u-list-item>
      </u-list>
      <view v-else class="empty-tip">
        <image src="/static/icons/records-empty.png" mode="aspectFit" style="width: 120rpx; height: 120rpx; margin-bottom: 20rpx;"></image>
        <text>暂无交易记录</text>
        <u-button type="primary" size="default" @click="goToSearchBook" style="margin-top: 30rpx;">去购买书籍</u-button>
      </view>
    </view>
  </view>
</template>

<script>
import request from '@/common/request.js'
import uList from '@/uni_modules/uview-ui/components/u-list/u-list.vue'
import uListItem from '@/uni_modules/uview-ui/components/u-list-item/u-list-item.vue'
import uTag from '@/uni_modules/uview-ui/components/u-tag/u-tag.vue'
import uButton from '@/uni_modules/uview-ui/components/u-button/u-button.vue'

export default {
  components: {
    uList,
    uListItem,
    uTag,
    uButton
  },
  data() {
    return {
      transactionRecords: [],
      selectedTab: 'all',
      selectedType: 'all', // 交易类型：all-全部, buy-买入, sell-卖出
      userInfo: {}
    };
  },
  onShow() {
    // 获取用户信息
    this.userInfo = uni.getStorageSync('userInfo');
    // 获取交易记录
    this.getTransactionRecords();
  },
  computed: {
    // 过滤后的记录
    filteredRecords() {
      // 先根据状态过滤
      let filteredByStatus = [];
      if (this.selectedTab === 'all') {
        filteredByStatus = this.transactionRecords;
      } else {
        filteredByStatus = this.transactionRecords.filter(record => record.status === this.selectedTab);
      }
      
      // 再根据交易类型过滤
      if (this.selectedType === 'all') {
        return filteredByStatus;
      } else {
        return filteredByStatus.filter(record => record.type === this.selectedType);
      }
    }
  },
  methods: {
    // 获取书籍详情
    async getBookDetail(bookId) {
      try {
        const res = await request.post('/book/getById', {
          bookId: bookId
        });
        const responseData = res.data || {};
        console.log('获取书籍详情:', responseData);
        if (responseData.success || responseData.code === 200 || responseData.code === '00000') {
          return responseData.data || {};
        }
        return {};
      } catch (err) {
        console.error('获取书籍详情失败：', err);
        return null;
      }
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
    // 获取交易记录
    async getTransactionRecords() {
      try {
        // 检查用户信息是否存在
        console.log('用户信息:', this.userInfo);
        if (!this.userInfo.studentId) {
          console.error('用户未登录或学号不存在');
          uni.showToast({
            title: '请先登录',
            icon: 'none'
          });
          return;
        }
        
        console.log('当前用户信息:', this.userInfo);
        console.log('当前用户ID:', this.userInfo.studentId);
        
        const res = await request.post('/transaction/records', {
          studentId: this.userInfo.studentId
        });
        
        console.log('后端返回的完整响应:', JSON.stringify(res, null, 2));
        const responseData = res.data || {};
        
        // 处理后端返回的数据
        const records = responseData.records || responseData.data?.records || [];
        console.log('处理前的所有记录:', records);
        
        // 打印第一条记录的所有字段名，确认实际的字段名
        if (records.length > 0) {
          console.log('第一条记录的所有字段名:', Object.keys(records[0]));
          console.log('第一条记录的详细内容:', JSON.stringify(records[0], null, 2));
        }
        
        // 过滤掉状态不是0或1的记录（只保留待交易和已交易）
        const validRecords = records.filter(record => record.status === 0 || record.status === 1);
        console.log('过滤后的有效记录:', validRecords);
        
        // 获取每本交易记录对应的书籍详情
        const recordsWithBookInfo = await Promise.all(validRecords.map(async (record) => {
          // 将后端返回的整数状态转换为字符串
          const statusMap = {
            0: 'pending', // 待交易
            1: 'completed' // 已交易
          };
          
          // 确保bookId存在
          const bookId = record.bookId || record.book_id;
          
          // 获取书籍详情
          let bookInfo = {};
          if (bookId) {
            bookInfo = await this.getBookDetail(bookId) || {};
          }
          
          // 确定交易类型：根据当前用户ID与买家/卖家ID比较
          // 将所有ID转换为字符串类型以避免数据类型不匹配问题
          const currentStudentId = String(this.userInfo.studentId);
          
          // 检查记录中的所有可能与买家/卖家相关的字段
          console.log('当前记录的所有字段:', Object.keys(record));
          
          // 尝试从记录中获取买家和卖家ID，处理各种可能的命名格式
          const buyerId = String(record.buyer_student_id || record.buyerStudentId || record.buyer_id || record.buyerId || '');
          const sellerId = String(record.seller_student_id || record.sellerStudentId || record.seller_id || record.sellerId || '');
          
          // 详细的调试信息
          console.log('当前用户ID:', currentStudentId);
          console.log('获取到的买家ID:', buyerId);
          console.log('获取到的卖家ID:', sellerId);
          
          // 计算交易类型：只有当买家ID或卖家ID有效时才进行判断
          let type = 'sell'; // 默认值
          if (buyerId && sellerId) {
            type = currentStudentId === buyerId ? 'buy' : 'sell';
          } else if (buyerId) {
            type = currentStudentId === buyerId ? 'buy' : 'sell';
          } else if (sellerId) {
            type = currentStudentId === sellerId ? 'sell' : 'buy';
          }
          
          console.log('计算得到的交易类型:', type);
          
          // 将后端返回的日期格式化为前端期望的格式
          return {
            ...record,
            bookId: bookId,
            // 交易类型
            type: type,
            // 转换状态
            status: statusMap[record.status] || 'pending',
            // 格式化日期
            transactionDate: record.transactionTime ? new Date(record.transactionTime).toLocaleString() : '',
            completeDate: record.completeTime ? new Date(record.completeTime).toLocaleString() : '',
            // 合并书籍信息
            bookName: bookInfo.bookName || '未知书籍',
            author: bookInfo.author || '未知作者',
            bookCover: bookInfo.coverImage || '/static/images/book-placeholder.png'
          };
        }));
        
        this.transactionRecords = recordsWithBookInfo;
        console.log('处理后的交易记录(含书籍信息):', this.transactionRecords);
        console.log('处理后记录的交易类型分布:', this.transactionRecords.map(r => ({
          bookName: r.bookName, 
          type: r.type, 
          status: r.status, 
          // 显示所有可能的买家和卖家ID字段
          buyer_student_id: r.buyer_student_id,
          seller_student_id: r.seller_student_id,
          buyerStudentId: r.buyerStudentId,
          sellerStudentId: r.sellerStudentId,
          buyer_id: r.buyer_id,
          seller_id: r.seller_id,
          buyerId: r.buyerId,
          sellerId: r.sellerId
        })));
      } catch (err) {
        console.error('获取交易记录失败：', err);
        uni.showToast({
          title: '获取记录失败',
          icon: 'none'
        });
      }
    },
    // 选择标签
    selectTab(tab) {
      this.selectedTab = tab;
    },
    // 选择交易类型
    selectType(type) {
      this.selectedType = type;
    },
    // 获取状态颜色
    getStatusColor(status) {
      switch (status) {
        case 'pending':
          return 'warning';
        case 'completed':
          return 'success';
        default:
          return 'default';
      }
    },
    // 获取状态文本
    getStatusText(status) {
      switch (status) {
        case 'pending':
          return '待交易';
        case 'completed':
          return '已交易';
        default:
          return '未知状态';
      }
    },
    // 确认交易
    async confirmTransaction(recordId) {
      uni.showModal({
        title: '确认交易',
        content: '确定要确认完成这笔交易吗？',
        success: async (res) => {
          if (res.confirm) {
            try {
              const res = await request.post('/transaction/complete', {
                recordId: recordId
              });
              const responseData = res.data || {};
              
              if (responseData.success || responseData.code === 200 || responseData.code === '00000') {
                uni.showToast({
                  title: '交易完成',
                  icon: 'success'
                });
                // 重新加载记录
                this.getTransactionRecords();
              } else {
                uni.showToast({
                  title: '操作失败',
                  icon: 'none'
                });
              }
            } catch (err) {
              console.log('确认交易失败：', err);
              uni.showToast({
                title: '操作失败',
                icon: 'none'
              });
            }
          }
        }
      });
    },
    // 联系卖家
    contactSeller(bookId) {
      uni.navigateTo({
        url: `/pages/message-add/message-add?bookId=${bookId}`
      });
    },
    // 查看书籍详情
    viewBookDetail(bookId) {
      uni.navigateTo({
        url: `/pages/book-detail/book-detail?bookId=${bookId}`
      });
    },
    // 跳转到评价页面
    goToReview(bookId) {
      uni.navigateTo({
        url: `/pages/book-review/book-review?bookId=${bookId}`
      });
    },
    // 跳转到书籍搜索页面
    goToSearchBook() {
      uni.navigateTo({
        url: '/pages/book-search/book-search'
      });
    }
  }
};
</script>

<style scoped>
.transaction-records-container {
  background-color: #f5f5f5;
  min-height: 100vh;
  padding-bottom: 20rpx;
}

/* 页面头部 */
.page-header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 30rpx 40rpx;
  margin-bottom: 20rpx;
  text-align: center;
  box-shadow: 0 4rpx 12rpx rgba(102, 126, 234, 0.2);
}

.header-title {
  font-size: 38rpx;
  font-weight: bold;
  color: white;
  text-shadow: 0 2rpx 4rpx rgba(0, 0, 0, 0.1);
}

/* 筛选标签 */
.filter-tabs {
  display: flex;
  background-color: white;
  margin: 0 20rpx 30rpx;
  border-radius: 20rpx;
  padding: 10rpx;
  box-shadow: 0 4rpx 16rpx rgba(0, 0, 0, 0.08);
  overflow-x: auto;
}

/* 交易类型标签 */
.type-tabs {
  margin-bottom: 20rpx;
}

/* 记录类型和状态 */
.record-type-status {
  margin: 5rpx 0;
  display: flex;
  align-items: center;
}

.tab-item {
  flex: 1;
  min-width: 100rpx;
  text-align: center;
  padding: 18rpx 20rpx;
  border-radius: 16rpx;
  margin-right: 10rpx;
  background-color: #f8f9fa;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.tab-item:last-child {
  margin-right: 0;
}

.tab-item.active {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  box-shadow: 0 4rpx 12rpx rgba(102, 126, 234, 0.3);
  transform: translateY(-2rpx);
}

.tab-text {
  font-size: 28rpx;
  font-weight: 600;
}

/* 记录列表 */
.records-list {
  margin: 0 20rpx;
}

.record-item {
  display: flex;
  gap: 24rpx;
  padding: 28rpx;
  background-color: white;
  border-radius: 20rpx;
  margin-bottom: 24rpx;
  box-shadow: 0 4rpx 16rpx rgba(0, 0, 0, 0.08);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.record-item:hover {
  box-shadow: 0 8rpx 24rpx rgba(0, 0, 0, 0.12);
  transform: translateY(-2rpx);
}

.book-cover {
  width: 150rpx;
  height: 190rpx;
  border-radius: 12rpx;
  background-color: #f5f5f5;
  flex-shrink: 0;
  box-shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.1);
}

.record-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 14rpx;
}

.book-title {
  font-size: 34rpx;
  font-weight: bold;
  color: #333;
  line-height: 1.4;
  overflow: hidden;
  text-overflow: ellipsis;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
}

.book-author {
  font-size: 26rpx;
  color: #666;
}

.record-price {
  font-size: 32rpx;
  font-weight: bold;
  color: #ff6b35;
}

.record-status {
  margin: 5rpx 0;
}

.record-dates {
  display: flex;
  flex-direction: column;
  gap: 8rpx;
  margin-top: 8rpx;
}

.date-item {
  display: flex;
  align-items: center;
  font-size: 24rpx;
}

.date-label {
  color: #999;
  margin-right: 8rpx;
  flex-shrink: 0;
}

.date-text {
  color: #333;
  flex: 1;
  overflow: hidden;
  text-overflow: ellipsis;
}

.date-text.overdue {
  color: #ff4d4f;
  font-weight: bold;
}

/* 操作按钮 */
.record-actions {
  display: flex;
  flex-direction: column;
  gap: 14rpx;
  justify-content: center;
}

.record-actions u-button {
  min-width: 140rpx;
  font-weight: 600;
  border-radius: 12rpx;
  transition: all 0.3s ease;
}

.record-actions u-button:hover {
  transform: translateY(-2rpx);
  box-shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.15);
}

/* 空状态提示 */
.empty-tip {
  text-align: center;
  padding: 120rpx 0;
  color: #999;
}

.empty-tip text {
  display: block;
  font-size: 32rpx;
  margin-bottom: 24rpx;
  font-weight: 500;
}

.empty-tip u-button {
  margin-top: 30rpx;
  border-radius: 20rpx;
  padding: 16rpx 40rpx;
  font-size: 28rpx;
}
</style>