import Vue from 'vue'
import App from './App'
// 引入uView UI
import uView from '@/uni_modules/uview-ui'
Vue.use(uView)

Vue.config.productionTip = false

// 挂载全局网络请求方法
import request from './common/request.js'
Vue.prototype.$request = request

App.mpType = 'app'

const app = new Vue({
    ...App
})
app.$mount()