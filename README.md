# RPAutomation - RPA Control Center

**RPAutomation** là ứng dụng desktop đa nền tảng (tập trung vào Windows/Linux) được xây dựng bằng **Flutter**. Ứng dụng đóng vai trò là trung tâm điều khiển (Control Center) giúp quản lý, giám sát và lập lịch cho các Robot RPA (Robotic Process Automation).

![Project Status](https://img.shields.io/badge/Status-Release-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-02569B)
![Platform](https://img.shields.io/badge/Platform-Windows-blue)

## 🌟 Tính năng chính

* **Quản lý Robot:** Xem danh sách, trạng thái hoạt động (Online/Offline) của các Robot.
* **Giám sát tiến trình (Runs):**
    * Theo dõi các tác vụ đang chạy theo thời gian thực.
    * Hiển thị trạng thái: Pending, Waiting, Success, Failure, Cancel.
* **Lập lịch (Scheduling):** Cấu hình lịch chạy tự động cho Robot.
* **Real-time Logs:** Xem log chi tiết quá trình chạy thông qua kết nối Socket.
* **Native Integration:**
    * **Windows Taskbar Progress:** Hiển thị thanh tiến trình và trạng thái (Xanh/Đỏ) ngay trên icon thanh tác vụ của Windows (sử dụng C++ `ITaskbarList3`).
* **Giao diện hiện đại:** Hỗ trợ Lottie Animation, Badge trạng thái trực quan.

## 🛠️ Công nghệ sử dụng

* **Core:** [Flutter](https://flutter.dev/) & Dart.
* **State Management:** Provider.
* **Networking:** HTTP Client & Socket (cho realtime updates).
* **Assets:** Lottie (JSON animations).
* **Native Windows:** C++ (Win32 API).
* **Installer:** Inno Setup (file `setup.iss`).

## 📂 Cấu trúc dự án

```text
lib/
├── data/
│   ├── model/         # Các Data Model (Robot, Run, Schedule, Log...)
│   └── services/      # Các API Service gọi về Backend
├── providers/         # Quản lý trạng thái (State Management)
│   ├── robot/         # Logic xử lý dữ liệu Robot
│   ├── run/           # Logic xử lý dữ liệu Run
│   └── socket.dart    # Quản lý kết nối Socket realtime
├── screens/
│   └── home/          # Giao diện chính (Dashboard)
│       ├── views/     # Các màn hình con (Log, Robot, Run, Schedule)
│       └── widgets/   # Các Widget tái sử dụng
├── shared/            # Các cấu hình chung (Theme, Constants)
└── main.dart          # Entry point
windows/
└── runner/            # Mã nguồn C++ Native cho Windows