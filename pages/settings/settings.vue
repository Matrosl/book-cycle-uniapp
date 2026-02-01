<!-- 设置页面 -->
<template>
	<view class="settings-container">
		<view class="section">
			<view class="section-title">账户设置</view>
			<view class="settings-item" @click="changePassword">
				<text>修改密码</text>
				<text class="arrow">></text>
			</view>
			<view class="settings-item">
				<text>绑定手机/邮箱</text>
				<text class="arrow">></text>
			</view>
		</view>

		<view class="section">
			<view class="section-title">应用设置</view>
			<view class="settings-item">
				<text>清除缓存</text>
				<text class="arrow">></text>
			</view>
			<view class="settings-item">
				<text>通知设置</text>
				<text class="arrow">></text>
			</view>
		</view>

		<view class="section">
			<view class="section-title">关于我们</view>
			<view class="settings-item">
				<text>版本信息</text>
				<text class="arrow">></text>
			</view>
			<view class="settings-item">
				<text>使用帮助</text>
				<text class="arrow">></text>
			</view>
			<view class="settings-item">
				<text>联系我们</text>
				<text class="arrow">></text>
			</view>
		</view>

		<view class="logout-btn-container">
			<u-button type="error" size="large" @click="logout">退出登录</u-button>
		</view>
	</view>
</template>

<script>
	import request from '@/common/request.js'
	import uButton from '@/uni_modules/uview-ui/components/u-button/u-button.vue'

export default {
	components: {
		uButton
	},
	data() {
		return {
			userInfo: {},
			passwordForm: {
				oldPassword: '',
				newPassword: '',
				confirmPassword: ''
			}
		}
	},
	
	onLoad() {
		this.userInfo = uni.getStorageSync('userInfo') || {}
	},
	
	methods: {
			// 修改密码
		changePassword() {
			this.resetPasswordForm()
			this.getOldPassword()
		},
		
		// 获取旧密码
		getOldPassword() {
			uni.showModal({
				title: '输入旧密码',
				content: '',
				editable: true,
				placeholderText: '请输入旧密码',
				showInput: true,
				password: true,
				success: (res) => {
					if (res.confirm && res.content.trim()) {
						this.passwordForm.oldPassword = res.content.trim()
						this.getNewPassword()
					}
				}
			})
		},
		
		// 获取新密码
		getNewPassword() {
			uni.showModal({
				title: '输入新密码',
				content: '',
				editable: true,
				placeholderText: '请输入新密码',
				showInput: true,
				password: true,
				success: (res) => {
					if (res.confirm && res.content.trim()) {
						this.passwordForm.newPassword = res.content.trim()
						this.confirmNewPassword()
					}
				}
			})
		},
		
		// 确认新密码
		confirmNewPassword() {
			uni.showModal({
				title: '确认新密码',
				content: '',
				editable: true,
				placeholderText: '请再次输入新密码',
				showInput: true,
				password: true,
				success: (res) => {
					if (res.confirm && res.content.trim()) {
						this.passwordForm.confirmPassword = res.content.trim()
						this.confirmChangePassword()
					}
				}
			})
		},
		
		// 确认修改密码
 		async confirmChangePassword() {
 			// 验证密码
 			if (this.passwordForm.newPassword !== this.passwordForm.confirmPassword) {
 				uni.showToast({
 					title: '新密码和确认密码不一致',
 					icon: 'none'
 				})
 				return
 			}
 			

 			if (this.passwordForm.oldPassword === this.passwordForm.newPassword) {
 				uni.showToast({
 					title: '新密码不能和旧密码相同',
 					icon: 'none'
 				})
 				return
 			}
 			

 			try {
 				// 调用后端接口修改密码
 				const res = await request.post('/user/updatePassword', {
 					studentId: this.userInfo.studentId,
 					oldPassword: this.passwordForm.oldPassword,
 					newPassword: this.passwordForm.newPassword
 				})
 				

 				const responseData = res.data || {}
					console.log('修改密码响应:', responseData)
 					
 					if (responseData.success || responseData.code === 200 || responseData.code === '00000') {
 						uni.showToast({
 							title: responseData.msg || '密码修改成功',
 							icon: 'success'
 						})
 						
 						// 重置密码表单
 						this.passwordForm = {
 							oldPassword: '',
 							newPassword: '',
 							confirmPassword: ''
 						}
 					} else {
 						uni.showToast({
 							title: responseData.msg || '修改失败',
 							icon: 'none'
 						})
 					}
 			} catch (err) {
 				console.log('修改密码失败：', err)
 				uni.showToast({
 					title: '密码修改失败',
 					icon: 'none'
 				})
 			}
 		},
		
		// 重置密码表单
		resetPasswordForm() {
			this.passwordForm = {
				oldPassword: '',
				newPassword: '',
				confirmPassword: ''
			}
		},
		
		// 退出登录
		logout() {
			uni.showModal({
				title: '确认退出登录',
				content: '您确定要退出登录吗？',
				success: (res) => {
					if (res.confirm) {
						// 调用后端退出登录接口
						request.post('/user/logout').then(() => {
							// 清除本地用户信息
							uni.removeStorageSync('userInfo')
							// 跳转到登录页面
							uni.reLaunch({
								url: '/pages/login/login'
							})
						})
					}
				}
			})
		}
	}
}
</script>

<style scoped>
	.settings-container {
		padding: 20rpx;
		background-color: #f5f5f5;
		min-height: 100vh;
	}

	.section {
		margin-bottom: 30rpx;
		background-color: white;
		border-radius: 10rpx;
	}

	.section-title {
		padding: 30rpx 30rpx 15rpx;
		font-size: 28rpx;
		color: #999;
	}

	.settings-item {
		display: flex;
		justify-content: space-between;
		align-items: center;
		padding: 30rpx;
		border-bottom: 1rpx solid #eee;
	}

	.settings-item:last-child {
		border-bottom: none;
	}

	.arrow {
		color: #ccc;
		font-size: 28rpx;
	}

	.logout-btn-container {
		padding: 40rpx 20rpx;
	}
</style>