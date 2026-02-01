<!-- 开发人：XXX，负责模块：书籍发布 -->
<template>
  <view class="publish-container">
    <u-form :model="bookForm" :rules="bookRules" ref="bookFormRef">
      <!-- 书籍封面上传 -->
      <u-form-item label="书籍封面">
        <u-upload
          :fileList="fileList"
          @afterRead="afterRead"
          @delete="deleteImg"
          name="cover"
          :multiple="false"
          maxCount="1"
          :previewFullImage="true"
          :delIcon="true"
          width="200"
          height="260"
        ></u-upload>
      </u-form-item>
      <u-form-item label="书名" prop="bookName">
        <u-input v-model="bookForm.bookName" placeholder="请输入书名"></u-input>
      </u-form-item>
      <u-form-item label="ISBN码" prop="isbn">
        <view class="isbn-input-group">
          <u-input v-model="bookForm.isbn" placeholder="请输入ISBN码"></u-input>
          <u-button @click="scanISBN" type="primary" size="small" class="scan-btn">扫码</u-button>
        </view>
      </u-form-item>
      <u-form-item label="书籍成色" prop="quality">
        <view class="quality-rating">
          <u-rate v-model="bookForm.quality" count="5" size="40" active-color="#faad14"></u-rate>
          <view class="quality-description">
            {{ qualityText }}
          </view>
        </view>
      </u-form-item>
      <u-form-item label="价格(元)" prop="price">
        <u-input v-model="bookForm.price" type="digit" placeholder="请输入价格"></u-input>
      </u-form-item>
      <u-form-item label="书籍类型" prop="type">
        <u-radio-group v-model="bookForm.type">
          <u-radio :name="'1'">教材</u-radio>
          <u-radio :name="'2'">课外书</u-radio>
        </u-radio-group>
      </u-form-item>
      <u-form-item label="作者" prop="author">
        <u-input v-model="bookForm.author" placeholder="请输入作者"></u-input>
      </u-form-item>
      <u-form-item label="出版社" prop="publisher">
        <u-input v-model="bookForm.publisher" placeholder="请输入出版社"></u-input>
      </u-form-item>
      
      <u-form-item label="备注">
        <u-input v-model="bookForm.remark" type="textarea" placeholder="请输入书籍备注（可选）" maxlength="500"></u-input>
      </u-form-item>
      <u-button type="primary" @click="publishBook" class="publish-btn" :loading="loading" :disabled="loading">发布书籍</u-button>
    </u-form>
  </view>
</template>

<script>
import request from '@/common/request.js';
import uForm from '@/uni_modules/uview-ui/components/u-form/u-form.vue';
import uFormItem from '@/uni_modules/uview-ui/components/u-form-item/u-form-item.vue';
import uUpload from '@/uni_modules/uview-ui/components/u-upload/u-upload.vue';
import uInput from '@/uni_modules/uview-ui/components/u-input/u-input.vue';
import uRadioGroup from '@/uni_modules/uview-ui/components/u-radio-group/u-radio-group.vue';
import uRadio from '@/uni_modules/uview-ui/components/u-radio/u-radio.vue';
import uButton from '@/uni_modules/uview-ui/components/u-button/u-button.vue';
import uRate from '@/uni_modules/uview-ui/components/u-rate/u-rate.vue';

export default {
  components: {
    uForm,
    uFormItem,
    uUpload,
    uInput,
    uRadioGroup,
    uRadio,
    uButton,
    uRate
  },
  data() {
    return {
      fileList: [],
      bookForm: {
        bookName: '',
        isbn: '',
        quality: 3,
        price: '',
        remark: '',
        coverUrl: '',
        studentId: '',
        type: 1,
        author: '',
        publisher: ''
      },
      // 加载状态
      loading: false,
      bookRules: {
        bookName: [
          { required: true, message: '请输入书名', trigger: 'blur' },
          { min: 2, max: 100, message: '书名长度应为2-100个字符', trigger: 'blur' }
        ],
        isbn: [
          { required: true, message: '请输入ISBN码', trigger: 'blur' },
          { pattern: /^\d{10}(\d{3})?$/, message: 'ISBN码格式不正确（应为10位或13位数字）', trigger: 'blur' }
        ],
        quality: [{ required: true, message: '请选择书籍成色' }],
        type: [{ required: true, message: '请选择书籍类型' }],
        price: [
          { required: true, message: '请输入价格', trigger: 'blur' },
          { pattern: /^\d+(\.\d{1,2})?$/, message: '价格格式不正确（最多两位小数）', trigger: 'blur' },
          { validator: (rule, value, callback) => { if (Number(value) <= 0) callback(new Error('价格必须大于0')); else callback(); }, trigger: 'blur' }
        ],
        author: [
          { max: 100, message: '作者名称不能超过100个字符', trigger: 'blur' }
        ],
        publisher: [
          { max: 100, message: '出版社名称不能超过100个字符', trigger: 'blur' }
        ],
        
      }
    };
  },
  computed: {
    qualityText() {
      const qualityMap = {
        1: '较旧',
        2: '一般',
        3: '中等',
        4: '良好',
        5: '全新'
      };
      return qualityMap[this.bookForm.quality] || '中等';
    }
  },
  onShow() {
    const userInfo = uni.getStorageSync('userInfo');
    if (userInfo && userInfo.studentId) {
      this.bookForm.studentId = userInfo.studentId;
    } else {
      uni.showToast({
        title: '请先登录',
        icon: 'none'
      });
      // uni.navigateTo({
      //   url: '/pages/login/login'
      // });
    }
  },
  methods: {
    async afterRead(event) {
      const file = event.file;
      
      // 显示上传中状态
      uni.showLoading({ title: '上传中...' });
      
      try {
        // 获取真实的文件路径，兼容不同平台
        const filePath = file.tempFilePath || file.url;
        const uploadRes = await new Promise((resolve, reject) => {
          uni.uploadFile({
            url: request.baseUrl + '/book/upload',
            filePath: filePath,
            name: 'file',
            success: resolve,
            fail: reject
          });
        });
        
        console.log('图片上传响应:', uploadRes);
        
        if (uploadRes.statusCode === 200) {
          try {
            const data = JSON.parse(uploadRes.data);
            if (data.code === 200 || data.success) {
              this.bookForm.coverUrl = data.data;
              this.fileList = [{ url: filePath, name: file.name }];
              uni.hideLoading();
              uni.showToast({
                title: '图片上传成功',
                icon: 'success'
              });
            } else {
              uni.hideLoading();
              uni.showToast({
                title: data.message || '图片上传失败',
                icon: 'none'
              });
            }
          } catch (e) {
            uni.hideLoading();
            uni.showToast({
              title: '服务器返回数据格式错误',
              icon: 'none'
            });
            console.error('解析服务器返回数据失败:', e, '原始数据:', uploadRes.data);
          }
        } else {
          uni.hideLoading();
          uni.showToast({
            title: `图片上传失败(${uploadRes.statusCode})`,
            icon: 'none'
          });
          console.error('图片上传失败，状态码:', uploadRes.statusCode, '响应:', uploadRes.data);
        }
      } catch (err) {
        uni.hideLoading();
        uni.showToast({
          title: '图片上传失败，请稍后重试',
          icon: 'none'
        });
        console.error('图片处理失败:', err);
      }
    },
    deleteImg(event) {
      this.fileList = [];
      this.bookForm.coverUrl = '';
    },
    // ISBN扫码功能
    async scanISBN() {
      try {
        const scanResult = await uni.scanCode({
          scanType: ['barCode'], // 只扫描条形码
          autoDecodeCharset: true
        });
        
        console.log(scanResult[1].result);
        
        if (scanResult && scanResult[1].result) {
          // 提取ISBN（去除可能的非数字字符）
          const isbn = scanResult[1].result;
          this.bookForm.isbn = isbn;
          console.log('提取的ISBN:', isbn);
          
          // 暂时注释掉该方法调用，因为该方法尚未实现
          // await this.fillBookInfoByISBN(isbn);
        } else {
          uni.showToast({
            title: '未获取到有效ISBN',
            icon: 'none'
          });
        }
      } catch (err) {
        console.error('扫码失败:', err);
        uni.showToast({
          title: '扫码失败，请重试',
          icon: 'none'
        });
      }
    },
    
    // 通过ISBN获取书籍信息
    
    async publishBook() {
      // 手动验证封面图片是否上传
      if (!this.bookForm.coverUrl || this.fileList.length === 0) {
        uni.showToast({ title: '请上传书籍封面', icon: 'none' });
        return;
      }
      
      const valid = await this.$refs.bookFormRef.validate();
      if (!valid) return;
      
      this.loading = true;
      try {
        const studentId = this.bookForm.studentId;
        const price = Number(this.bookForm.price);
        if (isNaN(price) || price <= 0) {
          uni.showToast({ title: '价格必须是大于0的数字', icon: 'none' });
          return;
        }
        const formData = { 
          ...this.bookForm, 
          price: price, 
          quality: Number(this.bookForm.quality), 
          type: Number(this.bookForm.type)
        };
        
        const res = await request.post('/book/add', formData);
        console.log('发布书籍响应:', res);
        
        // 从完整响应中获取data部分
        const responseData = res.data;
        if (responseData.code === 200 || responseData.success) {
          uni.showToast({
            title: '发布成功',
            icon: 'success'
          });
          // 使用动画效果重置表单
          this.$nextTick(() => {
            this.bookForm = {
              bookName: '',
              isbn: '',
              quality: 3,
              price: '',
              remark: '',
              coverUrl: '',
              studentId: studentId,
              type: 1,
              author: '',
              publisher: ''
            };
            this.fileList = [];
          });
        } else {
          uni.showToast({
            title: responseData.message || responseData.msg || '发布失败',
            icon: 'none'
          });
        }
      } catch (err) {
        console.error('发布失败：', err);
        uni.showToast({
          title: '发布失败，请稍后重试',
          icon: 'none'
        });
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.publish-container {
  min-height: 100vh;
  padding: 20rpx 30rpx;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
}

/* 表单容器 */
.u-form {
  background-color: #fff;
  border-radius: 20rpx;
  padding: 30rpx;
  box-shadow: 0 8rpx 24rpx rgba(0, 0, 0, 0.1);
}

/* 表单字段布局 */
.u-form-item {
  margin-bottom: 30rpx;
  transition: all 0.3s ease;
}

/* 封面上传区域 */
.u-upload {
  border: 2rpx dashed #e4e7ed;
  border-radius: 10rpx;
  padding: 40rpx;
  background-color: #fafafa;
  transition: all 0.3s ease;
}

.u-upload:hover {
  border-color: #667eea;
  background-color: #f0f5ff;
}

/* 输入框样式 */
.u-input {
  border-radius: 10rpx;
  border: 1rpx solid #e4e7ed;
  transition: all 0.3s ease;
}

.u-input:focus-within {
  border-color: #667eea;
  box-shadow: 0 0 0 2rpx rgba(102, 126, 234, 0.1);
}

/* 选择器样式 */
.u-radio-group {
  display: flex;
  flex-wrap: wrap;
  gap: 20rpx;
}

.u-radio {
  margin-right: 0;
  padding: 12rpx 24rpx;
  border-radius: 10rpx;
  border: 1rpx solid #e4e7ed;
  transition: all 0.3s ease;
}

.u-radio:hover {
  background-color: #f5f7fa;
  border-color: #667eea;
}

.u-radio--active {
  background-color: rgba(102, 126, 234, 0.1);
  border-color: #667eea;
}

/* 发布按钮样式 */
.publish-btn {
  margin-top: 40rpx;
  border-radius: 10rpx;
  height: 88rpx;
  font-size: 32rpx;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  box-shadow: 0 4rpx 12rpx rgba(102, 126, 234, 0.3);
  transition: all 0.3s ease;
}

.publish-btn:hover {
  transform: translateY(-2rpx);
  box-shadow: 0 6rpx 16rpx rgba(102, 126, 234, 0.4);
}

/* 文本域样式 */
.u-input--textarea {
  min-height: 160rpx;
  border-radius: 10rpx;
}

/* 表单标签样式 */
.u-form-item__label {
  font-size: 28rpx;
  font-weight: 500;
  color: #303133;
}

/* 星级评分样式 */
.quality-rating {
  display: flex;
  flex-direction: column;
  gap: 10rpx;
}

.quality-description {
  font-size: 24rpx;
  color: #606266;
  margin-left: 10rpx;
}

/* ISBN输入框和扫码按钮布局 */
.isbn-input-group {
  display: flex;
  align-items: center;
  gap: 15rpx;
  width: 100%;
}

.isbn-input-group .u-input {
  flex: 1;
  min-width: 0;
  font-size: 28rpx;
  padding: 20rpx;
  height: 80rpx;
}

.scan-btn {
  white-space: nowrap;
  width: 140rpx;
  font-size: 26rpx;
  padding: 0;
  height: 80rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* 星级评分组件 */
.u-rate {
  display: flex;
  align-items: center;
  gap: 10rpx;
}

.u-rate__content__item {
  transition: all 0.3s ease;
}

.u-rate__content__item__icon-wrap {
  cursor: pointer;
}
</style>