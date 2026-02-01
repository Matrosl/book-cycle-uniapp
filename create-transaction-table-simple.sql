CREATE TABLE `transaction_record` (
  `record_id` int(11) NOT NULL AUTO_INCREMENT,
  `book_id` int(11) NOT NULL,
  `buyer_student_id` varchar(20) NOT NULL,
  `seller_student_id` varchar(20) NOT NULL,
  `transaction_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `complete_time` datetime DEFAULT NULL,
  `price` double(10,2) NOT NULL,
  `status` int(11) DEFAULT 0,
  `remarks` text DEFAULT NULL,
  PRIMARY KEY (`record_id`),
  KEY `idx_book_id` (`book_id`),
  KEY `idx_buyer` (`buyer_student_id`),
  KEY `idx_seller` (`seller_student_id`),
  CONSTRAINT `transaction_record_ibfk_1` FOREIGN KEY (`book_id`) REFERENCES `book` (`book_id`),
  CONSTRAINT `transaction_record_ibfk_2` FOREIGN KEY (`buyer_student_id`) REFERENCES `user` (`student_id`),
  CONSTRAINT `transaction_record_ibfk_3` FOREIGN KEY (`seller_student_id`) REFERENCES `user` (`student_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `transaction_record` (`book_id`, `buyer_student_id`, `seller_student_id`, `transaction_time`, `price`, `status`) 
VALUES (1, '2021002', '2021001', NOW(), 30.00, 0),
       (2, '2021003', '2021002', '2023-01-15 10:30:00', 25.00, 1);