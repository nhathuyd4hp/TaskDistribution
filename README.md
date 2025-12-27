# Task Distribution - Robot Management System

![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-blue)
![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20Linux-lightgrey)
![License](https://img.shields.io/badge/License-MIT-green)

**Task Distribution** là ứng dụng Desktop (Cross-platform) được xây dựng bằng **Flutter** theo phong cách **Fluent Design (Windows 11)**. Hệ thống giúp quản lý, giám sát và phân phối tác vụ cho các Robot tự động hóa (RPA/Automation Robots) theo thời gian thực.

## ✨ Tính năng chính

* **🤖 Quản lý Robot (Robot Management):**
    * Xem danh sách Robot và trạng thái hoạt động (Active/Inactive).
    * Tìm kiếm và lọc Robot theo tên.
    * Thao tác nhanh: Chạy ngay (Run) hoặc Lập lịch (Schedule).

* **📜 Lịch sử thực thi (Runs History):**
    * Theo dõi lịch sử chạy của các tác vụ.
    * Lọc theo trạng thái (Success, Failure, Pending, etc.) và tìm kiếm theo ID/Tên.
    * Xem chi tiết tham số và kết quả của từng lần chạy.
    * Tải xuống kết quả thực thi.

* **📅 Lập lịch (Scheduling):**
    * Thiết lập lịch chạy tự động cho Robot (Cronjob/Time-based).
    * Quản lý các lịch trình đã đặt.

* **📝 Nhật ký thực thi (Execution Logs):**
    * Xem log chi tiết (Timestamp, Level, Message) của từng Run ID.
    * Hỗ trợ theo dõi Log Real-time (qua WebSocket).

* **🎨 Giao diện hiện đại:**
    * Sử dụng **Fluent UI** đem lại trải nghiệm Native trên Windows.
    * Hỗ trợ Dark Mode/Light Mode (tùy chỉnh hệ thống).

## 🛠 Công nghệ sử dụng

* **Core Framework:** [Flutter](https://flutter.dev/) (Dart).
* **State Management:** [Provider](https://pub.dev/packages/provider).
* **UI Library:** [fluent_ui](https://pub.dev/packages/fluent_ui) (Microsoft Fluent Design).
* **Networking:**
    * `http`: Kết nối REST API.
    * `web_socket_channel`: Kết nối WebSocket realtime.
* **Local Notifications:** `local_notifier` (Hiển thị thông báo hệ thống).

## 📂 Cấu trúc dự án

```text
lib/
├── core/                   # Các thành phần cốt lõi dùng chung
│   └── widget/             # Các Widget tái sử dụng (Header, Badges, EmptyState...)
├── model/                  # Data Models (Robot, Run, Log, Schedule)
├── provider/               # State Management (Logic xử lý dữ liệu)
│   ├── robot/              # Logic Robot & Filter
│   ├── run/                # Logic Run & Filter
│   ├── schedule/           # Logic Schedule
│   ├── page.dart           # Quản lý Navigation
│   └── socket.dart         # Quản lý kết nối WebSocket
├── service/                # Lớp giao tiếp với Backend API
├── view/                   # Giao diện người dùng (UI Screens)
│   ├── log/                # Màn hình xem Log
│   ├── robot/              # Màn hình danh sách Robot
│   ├── run/                # Màn hình lịch sử chạy
│   └── schedule/           # Màn hình lập lịch
└── main.dart               # Entry point