<template>
  <view class="book-add-container">
    <view class="book-cover-section">
      <view class="cover-placeholder" @tap="chooseImage">
        <image :src="coverImage" mode="aspectFill" class="cover-image"></image>
        <view class="add-cover-overlay" v-if="!coverImage">
          <text class="add-cover-icon">+</text>
          <text class="add-cover-text">上传封面</text>
        </view>
      </view>
    </view>

    <view class="form-section">
      <view class="form-item">
        <text class="label">书籍名称</text>
        <u-input v-model="book.title" placeholder="请输入书籍名称" />
      </view>

      <view class="form-item">
        <text class="label">作者</text>
        <u-input v-model="book.author" placeholder="请输入作者名称" />
      </view>

      <view class="form-item">
        <text class="label">出版社</text>
        <u-input v-model="book.publisher" placeholder="请输入出版社名称" />
      </view>

      <view class="form-item">
        <text class="label">ISBN</text>
        <u-input v-model="book.isbn" placeholder="请输入ISBN号码" />
      </view>

      <view class="form-item">
        <text class="label">分类</text>
        <picker @change="onCategoryChange" :value="categoryIndex" :range="categoryOptions">
          <view class="picker-view">
            <text>{{ categoryOptions[categoryIndex] }}</text>
            <u-icon name="arrow-down" color="#999"></u-icon>
          </view>
        </picker>
      </view>

      <view class="form-item">
        <text class="label">书籍状态</text>
        <view class="status-radio-group">
          <u-radio-group v-model="book.status" direction="row">
            <u-radio label="全新" name="new"></u-radio>
            <u-radio label="九成新" name="like-new"></u-radio>
            <u-radio label="七成新" name="good"></u-radio>
            <u-radio label="五成新" name="fair"></u-radio>
          </u-radio-group>
        </view>
      </view>

      <view class="form-item">
        <text class="label">描述</text>
        <u-input v-model="book.description" placeholder="请输入书籍描述" type="textarea" :maxlength="500" show-word-limit></u-input>
      </view>
    </view>

    <view class="action-section">
      <u-button type="primary" size="default" @click="submitBook" :disabled="!canSubmit" :loading="submitting">
        发布书籍
      </u-button>
    </view>
  </view>
</template>

<script>
export default {
  data() {
    return {
      coverImage: '',
      book: {
        title: '',
        author: '',
        publisher: '',
        isbn: '',
        category: '',
        status: 'good',
        description: ''
      },
      categoryOptions: ['计算机', '文学', '历史', '哲学', '经济', '管理', '法律', '教育', '医学', '艺术', '自然科学', '其他'],
      categoryIndex: 0,
      submitting: false,
      canSubmit: false
    };
  },

  onLoad() {
    // 页面加载时初始化
  },

  methods: {
    // 选择图片
    chooseImage() {
      uni.chooseImage({
        count: 1,
        sizeType: ['compressed'],
        sourceType: ['album', 'camera'],
        success: (res) => {
          this.coverImage = res.tempFilePaths[0];
          this.checkCanSubmit();
        },
        fail: (err) => {
          console.log('选择图片失败:', err);
        }
      });
    },

    // 分类选择
    onCategoryChange(e) {
      this.categoryIndex = e.detail.value;
      this.book.category = this.categoryOptions[this.categoryIndex];
      this.checkCanSubmit();
    },

    // 检查是否可以提交
    checkCanSubmit() {
      this.canSubmit = !!(this.coverImage && this.book.title && this.book.author && this.book.category);
    },

    // 表单输入变化时检查提交状态
    onInputChange() {
      this.checkCanSubmit();
    },

    // 提交书籍信息
    async submitBook() {
      if (!this.canSubmit) return;

      this.submitting = true;

      try {
        // 模拟图片上传
        const uploadResult = await this.uploadImage();
        
        if (uploadResult.success) {
          this.book.cover = uploadResult.url;
        }

        // 提交书籍信息到服务器
        await this.submitBookToServer();

        uni.showToast({
          title: '发布成功',
          icon: 'success'
        });

        // 返回上一页
        uni.navigateBack();

      } catch (error) {
        console.error('发布失败:', error);
        uni.showToast({
          title: '发布失败',
          icon: 'none'
        });
      } finally {
        this.submitting = false;
      }
    },

    // 模拟图片上传
    async uploadImage() {
      return new Promise((resolve) => {
        setTimeout(() => {
          resolve({
            success: true,
            url: this.coverImage
          });
        }, 1000);
      });
    },

    // 模拟提交书籍信息到服务器
    async submitBookToServer() {
      return new Promise((resolve) => {
        setTimeout(() => {
          resolve({
            success: true,
            message: '书籍发布成功'
          });
        }, 1500);
      });
    }
  },

  // 监听表单输入变化
  watch: {
    'book.title': 'onInputChange',
    'book.author': 'onInputChange',
    'book.category': 'onInputChange'
  }
};
</script>

<style scoped>
.book-add-container {
  background-color: #f5f5f5;
  min-height: 100vh;
  padding-bottom: 40rpx;
}

/* 书籍封面区域 */
.book-cover-section {
  background-color: white;
  padding: 40rpx 40rpx 20rpx;
  margin-bottom: 20rpx;
  box-shadow: 0 2rpx 8rpx rgba(0, 0, 0, 0.05);
}

.cover-placeholder {
  width: 200rpx;
  height: 280rpx;
  background-color: #f0f0f0;
  border-radius: 8rpx;
  margin: 0 auto;
  position: relative;
  overflow: hidden;
}

.cover-image {
  width: 100%;
  height: 100%;
}

.add-cover-overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  background-color: rgba(255, 255, 255, 0.7);
}

.add-cover-icon {
  font-size: 60rpx;
  font-weight: bold;
  color: #999;
  margin-bottom: 10rpx;
}

.add-cover-text {
  font-size: 26rpx;
  color: #999;
}

/* 表单区域 */
.form-section {
  background-color: white;
  padding: 0 40rpx;
  margin-bottom: 20rpx;
  box-shadow: 0 2rpx 8rpx rgba(0, 0, 0, 0.05);
}

.form-item {
  padding: 30rpx 0;
  border-bottom: 1rpx solid #f0f0f0;
}

.form-item:last-child {
  border-bottom: none;
}

.label {
  display: block;
  font-size: 28rpx;
  font-weight: 500;
  color: #333;
  margin-bottom: 20rpx;
}

.picker-view {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20rpx;
  background-color: #f9f9f9;
  border-radius: 8rpx;
}

.picker-view text {
  font-size: 28rpx;
  color: #333;
}

.status-radio-group {
  padding: 20rpx 0;
}

/* 操作区域 */
.action-section {
  padding: 0 40rpx;
}
</style>