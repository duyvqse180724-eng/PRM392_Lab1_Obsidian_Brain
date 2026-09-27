# PRN231 - Kiến Trúc ASP.NET Core Web API

> **Môn học:** PRN231 - Building Cross-Platform Applications  
> **Chủ đề:** RESTful API Design & Clean Architecture trong .NET 8

---

## 1. Cấu trúc Solution Clean Architecture
```
PRN231_Solution/
├── Core/
│   ├── Domain/         # Entities, Enums, Exceptions
│   └── Application/    # DTOs, Interfaces, CQRS Handlers (MediatR)
└── Infrastructure/
    ├── Persistence/    # EF Core DbContext, Migrations
    └── WebApi/         # Controllers, Middlewares, Program.cs
```

## 2. Dependency Injection Lifecycle
| Vòng đời | Phương thức đăng ký | Thời điểm tạo mới |
| :--- | :--- | :--- |
| **Transient** | `AddTransient<T, U>()` | Tạo instance mới mỗi lần được inject |
| **Scoped** | `AddScoped<T, U>()` | Một instance duy nhất trong 1 HTTP Request |
| **Singleton** | `AddSingleton<T, U>()` | Một instance duy nhất trong suốt vòng đời App |

## 3. Liên kết liên quan
- Mở rộng sang kiến trúc phân tán: [[02_Microservices_Patterns]]
- Quản lý tài liệu học tập: [[03_SecondBrain_Tips]]
