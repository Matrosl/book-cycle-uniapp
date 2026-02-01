-- 创建交易记录表来替代借阅记录表
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

-- 插入示例交易记录
INSERT INTO `transaction_record` (`book_id`, `buyer_student_id`, `seller_student_id`, `transaction_time`, `price`, `status`) 
VALUES (1, '2021002', '2021001', NOW(), 30.00, 0),
       (2, '2021003', '2021002', '2023-01-15 10:30:00', 25.00, 1);