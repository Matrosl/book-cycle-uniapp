-- 数据库创建语句
CREATE DATABASE IF NOT EXISTS `book_cycle` DEFAULT CHARSET utf8 COLLATE utf8_general_ci;
USE `book_cycle`;

-- 用户表
CREATE TABLE `user` (
  `student_id` varchar(20) NOT NULL COMMENT '学号（主键）',
  `password` varchar(255) NOT NULL COMMENT '密码',
  `nick_name` varchar(50) DEFAULT NULL COMMENT '昵称',
  `score` int(11) DEFAULT 0 COMMENT '积分',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `avatar_url` varchar(255) DEFAULT NULL COMMENT '头像URL',
  `real_name` varchar(50) DEFAULT NULL COMMENT '真实姓名',
  `department` varchar(100) DEFAULT NULL COMMENT '院系',
  `class` varchar(100) DEFAULT NULL COMMENT '专业班级',
  `phone` varchar(20) DEFAULT NULL COMMENT '手机号',
  `email` varchar(100) DEFAULT NULL COMMENT '邮箱',
  `introduction` text DEFAULT NULL COMMENT '个人简介',
  PRIMARY KEY (`student_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='用户表';

-- 书籍表
CREATE TABLE `book` (
  `book_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '书籍ID（主键，自增）',
  `book_name` varchar(100) NOT NULL COMMENT '书名',
  `isbn` varchar(20) NOT NULL COMMENT 'ISBN码',
  `quality` int(11) DEFAULT 3 COMMENT '成色（1-5星）',
  `price` double(10,2) NOT NULL COMMENT '价格',
  `remark` text DEFAULT NULL COMMENT '备注',
  `cover_url` varchar(255) DEFAULT NULL COMMENT '封面图片路径',
  `student_id` varchar(20) NOT NULL COMMENT '发布人学号',
  `publish_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间',
  `cycle_count` int(11) DEFAULT 0 COMMENT '循环次数',
  `type` int(11) DEFAULT 1 COMMENT '类型（0-全部 1-教材 2-课外书）',
  `author` varchar(100) DEFAULT NULL COMMENT '作者',
  `publisher` varchar(100) DEFAULT NULL COMMENT '出版社',
  `publish_year` varchar(20) DEFAULT NULL COMMENT '出版年份',
  `status` int(11) DEFAULT 0 COMMENT '状态（0-可购买 1-已售出 2-已下架）',
  PRIMARY KEY (`book_id`),
  KEY `idx_student_id` (`student_id`),
  KEY `idx_isbn` (`isbn`),
  KEY `idx_type` (`type`),
  CONSTRAINT `book_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `user` (`student_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='书籍表';

-- 留言表
CREATE TABLE `message` (
  `message_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '留言ID（主键，自增）',
  `book_id` int(11) NOT NULL COMMENT '书籍ID',
  `student_id` varchar(20) NOT NULL COMMENT '留言人学号',
  `content` text NOT NULL COMMENT '留言内容',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '留言时间',
  `status` varchar(20) DEFAULT '待回复' COMMENT '状态（待回复/已回复）',
  `reply_content` text DEFAULT NULL COMMENT '回复内容',
  `reply_time` datetime DEFAULT NULL COMMENT '回复时间',
  PRIMARY KEY (`message_id`),
  KEY `idx_book_id` (`book_id`),
  KEY `idx_student_id` (`student_id`),
  CONSTRAINT `message_ibfk_1` FOREIGN KEY (`book_id`) REFERENCES `book` (`book_id`),
  CONSTRAINT `message_ibfk_2` FOREIGN KEY (`student_id`) REFERENCES `user` (`student_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='留言表';

-- 交易记录表
CREATE TABLE `transaction_record` (
  `record_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '记录ID（主键，自增）',
  `book_id` int(11) NOT NULL COMMENT '书籍ID',
  `buyer_student_id` varchar(20) NOT NULL COMMENT '买家学号',
  `seller_student_id` varchar(20) NOT NULL COMMENT '卖家学号',
  `transaction_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '交易时间',
  `complete_time` datetime DEFAULT NULL COMMENT '完成时间',
  `price` double(10,2) NOT NULL COMMENT '交易价格',
  `status` int(11) DEFAULT 0 COMMENT '状态（0-待交易 1-已完成 2-已取消）',
  `remarks` text DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`record_id`),
  KEY `idx_book_id` (`book_id`),
  KEY `idx_buyer` (`buyer_student_id`),
  KEY `idx_seller` (`seller_student_id`),
  CONSTRAINT `transaction_record_ibfk_1` FOREIGN KEY (`book_id`) REFERENCES `book` (`book_id`),
  CONSTRAINT `transaction_record_ibfk_2` FOREIGN KEY (`buyer_student_id`) REFERENCES `user` (`student_id`),
  CONSTRAINT `transaction_record_ibfk_3` FOREIGN KEY (`seller_student_id`) REFERENCES `user` (`student_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='交易记录表';

-- 评价表
CREATE TABLE `review` (
  `review_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '评价ID（主键，自增）',
  `book_id` int(11) NOT NULL COMMENT '书籍ID',
  `student_id` varchar(20) NOT NULL COMMENT '评价人学号',
  `rating` int(11) NOT NULL COMMENT '评分（1-5星）',
  `content` text DEFAULT NULL COMMENT '评价内容',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '评价时间',
  `is_public` tinyint(1) DEFAULT 1 COMMENT '是否公开（1-公开 0-私密）',
  PRIMARY KEY (`review_id`),
  KEY `idx_book_id` (`book_id`),
  KEY `idx_student_id` (`student_id`),
  CONSTRAINT `review_ibfk_1` FOREIGN KEY (`book_id`) REFERENCES `book` (`book_id`),
  CONSTRAINT `review_ibfk_2` FOREIGN KEY (`student_id`) REFERENCES `user` (`student_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='评价表';

-- 消息表
CREATE TABLE `notification` (
  `notification_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '消息ID（主键，自增）',
  `student_id` varchar(20) NOT NULL COMMENT '接收人学号',
  `title` varchar(100) NOT NULL COMMENT '消息标题',
  `content` text NOT NULL COMMENT '消息内容',
  `type` int(11) DEFAULT 0 COMMENT '消息类型（0-系统通知 1-交易消息 2-评价消息）',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `is_read` tinyint(1) DEFAULT 0 COMMENT '是否已读（0-未读 1-已读）',
  PRIMARY KEY (`notification_id`),
  KEY `idx_student_id` (`student_id`),
  KEY `idx_type` (`type`),
  CONSTRAINT `notification_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `user` (`student_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='消息表';

-- 初始化示例数据
-- 插入示例用户
INSERT INTO `user` (`student_id`, `password`, `nick_name`, `score`, `create_time`) 
VALUES ('2021001', '123456', '小明同学', 100, NOW()),
       ('2021002', '123456', '小红同学', 200, NOW()),
       ('2021003', '123456', '小李同学', 150, NOW());

-- 插入示例书籍
INSERT INTO `book` (`book_name`, `isbn`, `quality`, `price`, `remark`, `cover_url`, `student_id`, `publish_time`, `cycle_count`, `type`, `author`, `publisher`) 
VALUES ('Java编程思想', '9787111213826', 4, 30.00, '二手书，保存良好', null, '2021001', NOW(), 0, 2, 'Bruce Eckel', '机械工业出版社'),
       ('数据结构与算法分析', '9787111428386', 3, 25.00, '书角有轻微磨损', null, '2021002', NOW(), 0, 1, 'Mark Allen Weiss', '机械工业出版社'),
       ('JavaScript高级程序设计', '9787115351491', 5, 40.00, '几乎全新，无笔记', null, '2021003', NOW(), 0, 2, 'Nicholas C. Zakas', '人民邮电出版社');

-- 插入示例留言
INSERT INTO `message` (`book_id`, `student_id`, `content`, `create_time`, `status`) 
VALUES (1, '2021002', '这本书可以借阅吗？', NOW(), '待回复'),
       (2, '2021001', '请问价格可以优惠吗？', NOW(), '已回复'),
       (3, '2021002', '这本书是第几版的？', NOW(), '待回复');

-- 插入示例交易记录
INSERT INTO `transaction_record` (`book_id`, `buyer_student_id`, `seller_student_id`, `transaction_time`, `price`, `status`) 
VALUES (1, '2021002', '2021001', NOW(), 30.00, 0),
       (2, '2021003', '2021002', '2023-01-15 10:30:00', 25.00, 1);

-- 插入示例评价
INSERT INTO `review` (`book_id`, `student_id`, `rating`, `content`, `create_time`, `is_public`) 
VALUES (1, '2021002', 5, '这本书非常好，内容详细，讲解清晰。', NOW(), 1),
       (2, '2021003', 4, '书的内容不错，就是纸张质量一般。', '2023-02-15 09:00:00', 1);

-- 插入示例消息
INSERT INTO `notification` (`student_id`, `title`, `content`, `type`, `create_time`, `is_read`) 
VALUES ('2021001', '新的借阅请求', '用户2021002请求借阅您的"Java编程思想"', 1, NOW(), 0),
       ('2021002', '书籍已归还', '您借阅的"数据结构与算法分析"已归还', 1, '2023-02-15 09:30:00', 1),
       ('2021003', '系统通知', '欢迎使用图书循环系统！', 0, NOW(), 0);