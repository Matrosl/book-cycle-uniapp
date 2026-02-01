
const baseUrl = "http://localhost:8080"; // 使用localhost确保本地开发环境正常连接

export default {
  baseUrl: baseUrl,
  // 通用请求方法
  request(url, method, data = {}) {
    return new Promise((resolve, reject) => {
      uni.showLoading({
        title: '加载中...'
      });
      uni.request({
        url: baseUrl + url,
        method: method || 'GET',
        data: data,
        header: {
          'Content-Type': 'application/json'
        },
        success: (res) => {
          uni.hideLoading();
          console.log('HTTP请求成功:', res);
          // 直接返回完整响应，让调用方处理
          resolve(res);
        },
        fail: (err) => {
          uni.hideLoading();
          console.error('HTTP请求失败:', err);
          uni.showToast({
            title: '网络异常，请检查连接',
            icon: 'none'
          });
          reject(err);
        }
      });
    });
  },
  // GET请求封装
  get(url, data) {
    return this.request(url, 'GET', data);
  },
  // POST请求封装
  post(url, data) {
    return this.request(url, 'POST', data);
  }
}