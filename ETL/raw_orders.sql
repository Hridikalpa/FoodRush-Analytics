DROP TABLE IF EXISTS raw_orders;

CREATE TABLE raw_orders
(
    order_id VARCHAR(20),
    customer_id VARCHAR(20),
    restaurant_id VARCHAR(20),
    order_date VARCHAR(30),
    order_amount VARCHAR(30),
    order_status VARCHAR(30),
    acquisition_channel VARCHAR(50)
);

INSERT INTO raw_orders VALUES
('1001','101','201','2024-01-05','550','Delivered','Google Ads'),
('1002','102','202','2024-01-06','420','Delivered','Referral'),
('1003',NULL,'203','2024-01-07','350','Delivered','Instagram'),
('1004','104','204',NULL,'610','Delivered','Organic'),
('1005','105','205','2024-01-09','-250','Delivered','Referral'),
('1006','106','206','2024-13-02','480','Delivered','Google Ads'),
('1007','107',NULL,'2024-01-11','520','Cancelled','Organic'),
('1008','108','208','2024-01-12','0','Delivered','Referral'),
('1008','108','208','2024-01-12','0','Delivered','Referral'),
('1009','109','209','2024-01-14','999999','Delivered','Google Ads');
