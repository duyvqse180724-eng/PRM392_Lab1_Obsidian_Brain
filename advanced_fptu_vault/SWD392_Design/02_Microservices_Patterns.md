# SWD392 - Microservices Architecture Patterns

> **Môn học:** SWD392 - Software Architecture & Design  
> **Chủ đề:** Tích hợp hệ thống phân tán & Message Brokers

---

## 1. Saga Pattern (Quản lý phân tán Transaction)
Trong kiến trúc Microservices, để đảm bảo tính nhất quán dữ liệu qua nhiều dịch vụ độc lập:
- **Choreography-based Saga:** Các service trao đổi trực tiếp thông qua Event (Kafka / RabbitMQ).
- **Orchestration-based Saga:** Một Orchestrator trung tâm điều phối trạng thái và gửi lệnh bồi hoàn (Compensating Transaction) khi xảy ra lỗi.

## 2. API Gateway Pattern
Đóng vai trò Reverse Proxy đơn điểm tiếp nhận Request từ Client (Web/Mobile/Desktop):
- Định tuyến động (Dynamic Routing).
- Rate Limiting & Throttling.
- Xác thực tập trung JWT / OAuth2.

## 3. Liên kết liên quan
- Triển khai backend Web API: [[01_WebApi_Architecture]]
- Quản lý tri thức hệ thống: [[03_SecondBrain_Tips]]
