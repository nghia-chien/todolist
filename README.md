# Todo App với AI Assistant

Ứng dụng quản lý công việc thông minh được tích hợp với AI để giúp bạn lên kế hoạch và quản lý công việc hiệu quả hơn.

## 🌟 Tính năng chính

### 1. Quản lý công việc
- Tạo và quản lý nhiều danh sách công việc
- Phân loại công việc theo độ ưu tiên
- Đặt thời hạn và nhắc nhở
- Tìm kiếm và lọc công việc
- Thống kê tiến độ

### 2. AI Assistant
- Tạo công việc thông minh từ mô tả của bạn
- Đề xuất cách chia nhỏ công việc
- Tự động phân loại độ ưu tiên
- Xem trước và chỉnh sửa trước khi thêm vào danh sách

### 3. Giao diện người dùng
- Thiết kế Material Design hiện đại
- Hỗ trợ chế độ sáng/tối
- Hiệu ứng chuyển động mượt mà
- Responsive trên nhiều thiết bị

## 🛠️ Công nghệ sử dụng

- **Flutter**: Framework UI cross-platform
- **Provider**: Quản lý state
- **SQLite**: Lưu trữ dữ liệu local
- **Gemini AI**: API trí tuệ nhân tạo của Google
- **HTTP**: Gọi API
- **Shared Preferences**: Lưu cấu hình người dùng

## 📱 Cài đặt

1. Clone repository:
```bash
git clone https://github.com/yourusername/todo-app.git
```

2. Cài đặt dependencies:
```bash
flutter pub get
```

3. Chạy ứng dụng:
```bash
flutter run
```

## 🔧 Cấu hình

1. Tạo file `.env` trong thư mục gốc:
```
GEMINI_API_KEY=your_api_key_here
```

2. Thêm API key vào `lib/services/gemini_service.dart`

## 📦 Cấu trúc thư mục

```
lib/
├── models/          # Data models
├── services/        # Business logic & API calls
├── ui/             # UI components
│   ├── screens/    # App screens
│   └── widgets/    # Reusable widgets
└── main.dart       # Entry point
```

## 🤝 Đóng góp

Mọi đóng góp đều được hoan nghênh! Vui lòng:

1. Fork repository
2. Tạo branch mới (`git checkout -b feature/AmazingFeature`)
3. Commit thay đổi (`git commit -m 'Add some AmazingFeature'`)
4. Push lên branch (`git push origin feature/AmazingFeature`)
5. Tạo Pull Request

## 📄 Giấy phép

Dự án này được cấp phép theo MIT License - xem file [LICENSE](LICENSE) để biết thêm chi tiết.

## 👥 Tác giả

- Your Name - [@hacphichien](https://github.com/nghia-chien)

## 🙏 Cảm ơn

- Flutter team
- Google Gemini AI
- Cộng đồng Flutter Việt Nam
