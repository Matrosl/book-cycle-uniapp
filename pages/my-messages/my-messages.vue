<template>
	<view class="messages-container">
		<!-- 筛选标签 -->
		<view class="filter-tabs">
			<view 
				v-for="(tab, index) in filterTabs" 
				:key="index"
				:class="['tab-item', { active: activeTab === tab.type }]"
				@click="activeTab = tab.type"
			>
				{{ tab.name }}
			</view>
		</view>

		<!-- 消息列表 -->
		<view class="messages-list">
			<view 
				v-for="(message, index) in filteredMessages" 
				:key="message.notificationId"
				:class="['message-item', { unread: !message.isRead }]"
				@click="viewMessageDetail(message)"
			>
				<!-- 消息头像/图标 -->
				<view class="message-avatar">
					<text class="avatar-icon" :style="{backgroundColor: getMessageColor(message.type)}">{{ getMessageIcon(message.type) }}</text>
				</view>

				<!-- 消息内容 -->
				<view class="message-content">
					<view class="message-header">
						<text class="message-title">{{ message.title }}</text>
						<text class="message-time">{{ formatTime(message.createTime) }}</text>
					</view>
					<text class="message-preview">{{ message.content }}</text>
				</view>

				<!-- 未读标记 -->
				<view v-if="!message.isRead" class="unread-dot"></view>
			</view>
		</view>

		<!-- 空状态 -->
		<view v-if="filteredMessages.length === 0" class="empty-state">
			<text class="empty-icon">📭</text>
			<text class="empty-text">暂无{{ currentTabName }}消息</text>
		</view>
	</view>
</template>

<script>
import request from '@/common/request.js'

export default {
	data() {
		return {
			activeTab: 'all', // 默认显示全部消息
			filterTabs: [
				{ type: 'all', name: '全部消息' },
				{ type: 'system', name: '系统通知' },
				{ type: 'transaction', name: '交易消息' },
				{ type: 'comment', name: '评价消息' },
				{ type: 'unread', name: '未读消息' }
			],
			messages: [] // 空数组，用于存储从API获取的消息
		};
	},

	computed: {
		filteredMessages() {
			// 根据选中的标签筛选消息
			if (this.activeTab === 'all') {
				return this.messages;
			} else if (this.activeTab === 'unread') {
				return this.messages.filter(msg => !msg.isRead);
			} else {
				// 将后端的type值转换为前端的tab类型
				const typeMap = {
					1: 'system',
					2: 'transaction',
					3: 'comment'
				};
				return this.messages.filter(msg => typeMap[msg.type] === this.activeTab);
			}
		},

		currentTabName() {
			const tab = this.filterTabs.find(t => t.type === this.activeTab);
			return tab ? tab.name.replace('消息', '') : '';
		}
	},

	methods: {
		// 获取消息图标
		getMessageIcon(type) {
			const iconMap = {
				1: '系', // 系统通知
				2: '交', // 交易消息
				3: '评'  // 评价消息
			};
			return iconMap[type] || '消';
		},

		// 获取消息颜色
		getMessageColor(type) {
			const colorMap = {
				1: '#2196F3', // 系统通知
				2: '#4CAF50', // 交易消息
				3: '#FF9800'  // 评价消息
			};
			return colorMap[type] || '#999';
		},

		// 格式化时间
		formatTime(time) {
			if (!time) return '';
			// 假设时间格式是ISO格式或时间戳，这里简单处理
			return time.toString().slice(0, 16);
		},

		// 查看消息详情
		viewMessageDetail(message) {
			// 标记为已读
			message.isRead = true;
			// 调用API标记为已读
			this.markAsRead(message.notificationId);
			
			uni.showToast({
				title: '查看消息详情',
				icon: 'none'
			});
		},

		// 标记消息为已读
		markAsRead(notificationId) {
			request.put(`/notification/${notificationId}`, { isRead: true }).then(res => {
				const responseData = res.data || {};
				if (responseData.success || responseData.code === 200 || responseData.code === '00000') {
					console.log('消息已标记为已读:', res);
				} else {
					console.error('标记已读失败:', responseData.msg || '未知错误');
				}
			}).catch(err => {
				console.error('标记已读失败:', err);
			});
		},

		// 从API获取消息列表
		loadMessages() {
			// 从登录状态获取用户ID
			const userInfo = uni.getStorageSync('userInfo');
			const studentId = userInfo && userInfo.studentId ? userInfo.studentId : '';
			if (!studentId) {
				console.error('用户未登录');
				return;
			}
			
			request.get(`/notification/user/${studentId}`).then(res => {
				console.log('获取到的消息数据:', res);
				const responseData = res.data || {};
				if (responseData.success || responseData.code === 200 || responseData.code === '00000') {
					this.messages = responseData.data || [];
				} else {
					console.error('获取消息失败:', responseData.msg || '未知错误');
				}
			}).catch(err => {
				console.error('获取消息列表失败:', err);
			});
		}
	},

	// 页面加载时
	onLoad() {
		// 调用API获取消息列表
		this.loadMessages();
	}
};
</script>

<style scoped>
/* 整体容器样式 */
.messages-container {
	min-height: 100vh;
	background-color: #f5f5f5;
	padding-bottom: 20rpx;
}

/* 筛选标签样式 */
.filter-tabs {
	display: flex;
	flex-wrap: nowrap;
	background-color: #ffffff;
	padding: 20rpx 30rpx;
	overflow-x: auto;
	white-space: nowrap;
	box-shadow: 0 2rpx 8rpx rgba(0, 0, 0, 0.05);
}

.tab-item {
	padding: 15rpx 30rpx;
	margin-right: 20rpx;
	border-radius: 25rpx;
	background-color: #f0f0f0;
	color: #666666;
	font-size: 28rpx;
	transition: all 0.3s ease;
}

.tab-item.active {
	background-color: #2979ff;
	color: #ffffff;
}

/* 消息列表样式 */
.messages-list {
	padding: 20rpx 30rpx;
}

/* 消息项样式 */
.message-item {
	background-color: #ffffff;
	border-radius: 12rpx;
	padding: 30rpx;
	margin-bottom: 20rpx;
	display: flex;
	align-items: center;
	transition: all 0.3s ease;
	box-shadow: 0 2rpx 8rpx rgba(0, 0, 0, 0.05);
}

.message-item:active {
	transform: scale(0.98);
	box-shadow: 0 1rpx 4rpx rgba(0, 0, 0, 0.1);
}

/* 未读消息样式 */
.message-item.unread {
	border-left: 6rpx solid #2979ff;
	background-color: #f9faff;
}

/* 消息头像样式 */
.message-avatar {
	width: 80rpx;
	height: 80rpx;
	border-radius: 50%;
	display: flex;
	align-items: center;
	justify-content: center;
	margin-right: 30rpx;
	flex-shrink: 0;
}

.avatar-icon {
	width: 80rpx;
	height: 80rpx;
	border-radius: 50%;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 28rpx;
	font-weight: 500;
	color: #ffffff;
}

/* 消息内容样式 */
.message-content {
	flex: 1;
	min-width: 0;
}

.message-header {
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 10rpx;
}

.message-title {
	font-size: 32rpx;
	font-weight: 500;
	color: #333333;
}

.message-time {
	font-size: 24rpx;
	color: #999999;
}

.message-preview {
	display: -webkit-box;
	-webkit-box-orient: vertical;
	-webkit-line-clamp: 2;
	overflow: hidden;
	font-size: 28rpx;
	color: #666666;
	line-height: 1.5;
}

/* 未读标记样式 */
.unread-dot {
	width: 12rpx;
	height: 12rpx;
	border-radius: 50%;
	background-color: #2979ff;
}

/* 空状态样式 */
.empty-state {
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	padding: 150rpx 0;
}

.empty-icon {
	font-size: 120rpx;
	margin-bottom: 40rpx;
}

.empty-text {
	font-size: 28rpx;
	color: #999999;
}
</style>