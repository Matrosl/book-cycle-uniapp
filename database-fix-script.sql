-- 校园二手书循环利用系统 - 数据库表结构修复脚本
-- 用于修复个人中心界面 SQL 错误：Unknown column 'class' in 'field list'

-- 使用 MySQL 命令行或数据库管理工具（如 phpMyAdmin、Navicat）执行以下语句：

-- 连接到你的数据库
-- mysql -u your_username -p your_database_name

-- 1. 添加缺失的 class 字段到 user 表中
-- class 字段对应 User 实体类中的 classField
ALTER TABLE user 
ADD COLUMN class VARCHAR(100) DEFAULT NULL COMMENT '专业班级';

-- 2. 可选：更新所有现有记录的 class 字段为默认值（如果需要）
UPDATE user 
SET class = '未设置班级' 
WHERE class IS NULL;

-- 执行完成后，请验证：
-- - User 表中是否已存在 class 字段
-- - 用户登录功能是否正常
-- - 个人中心数据是否能正确显示
-- - 个人信息编辑功能是否正常

-- 如果需要进一步调试，请检查：
-- 1. UserMapper 中的 SQL 语句是否正确引用了 class AS classField
-- 2. User 实体类是否正确定义了 classField 字段
-- 3. 后端 API 响应格式是否与前端预期一致