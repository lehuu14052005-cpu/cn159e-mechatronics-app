# CN159E – Mechatronics English

Ứng dụng học tập và thi thử tiếng Anh chuyên ngành Cơ điện tử (môn **CN159E – Đại học Cần Thơ**), hoạt động **100% offline** trên Android và iOS.

## Phạm vi nội dung (Reading)
Chỉ sử dụng phần **Reading** và sơ đồ minh họa liên quan trong 4 chương:
- **Chapter 4**: Actuators (`CN159E-4.pdf`)
- **Chapter 5.1**: Control System (`CN159E-5.pdf`)
- **Chapter 5.2**: Microcontroller (`CN159E-5.2.pdf`)
- **Chapter 6**: Internet of Things (`CN159E-6.pdf`)

## Cấu trúc đề thi thử 90 phút (Tổng 10.0 điểm)
- **Phần I**: 20 câu trắc nghiệm Anh – Việt (0.125 điểm/câu = **2.5 điểm**), cân bằng 4 chương, xáo trộn câu hỏi & đáp án.
- **Phần II**: 10 thuật ngữ Anh – Việt (0.25 điểm/câu = **2.5 điểm**), chấm theo danh sách nghĩa tương đương, không phân biệt hoa/thường/dấu câu.
- **Phần III**: 1 đoạn văn dịch Anh – Việt (**2.5 điểm**, chấm ước lượng theo rubric từ khóa & độ đầy đủ).
- **Phần IV**: 1 đoạn văn dịch Việt – Anh (**2.5 điểm**, chấm ước lượng theo rubric từ khóa & độ đầy đủ).
- **Timer**: Đếm ngược 90:00 dựa trên timestamp thực (`expectedEndAtMs`), tự lưu liên tục, khôi phục khi mở lại app và tự động nộp khi hết giờ.

---

## 1. Cài đặt Android (APK)
File APK Release: `CN159E_Mechatronics_English.apk` (hoặc `build/app/outputs/flutter-apk/app-release.apk`).

### Cách cài trên điện thoại Android:
1. Chép file `CN159E_Mechatronics_English.apk` vào điện thoại.
2. Mở file APK trên điện thoại.
3. Nếu được hỏi, bật **Cho phép cài đặt ứng dụng từ nguồn này (Install unknown apps)**.
4. Nhấn **Cài đặt (Install)** và mở ứng dụng.

### Lệnh tự build APK từ source code:
```bash
flutter pub get
flutter build apk --release
```

---

## 2. Build & Cài đặt iOS (IPA)
> **Lưu ý môi trường**: Build file `.ipa` bắt buộc phải thực hiện trên **macOS có cài Xcode** (Apple không hỗ trợ biên dịch iOS binary trên Windows). Project iOS hoàn chỉnh đã được cấu hình sẵn trong thư mục `ios/`.

### Các bước build IPA trên máy Mac:
1. Cài đặt Flutter SDK, Xcode và CocoaPods (`sudo gem install cocoapods`).
2. Mở thư mục `cn159e_app` trên Mac và chạy:
   ```bash
   flutter pub get
   cd ios && pod install && cd ..
   ```
3. Mở `ios/Runner.xcworkspace` bằng **Xcode**:
   - Chọn **Runner** -> **Signing & Capabilities**.
   - Chọn **Team** (Apple Developer Account của bạn).
   - Đặt **Bundle Identifier** duy nhất (ví dụ `vn.edu.ctu.cn159eApp`).
   - Deployment Target khuyến nghị: iOS 13.0+.
4. Build file IPA:
   ```bash
   flutter build ipa --release
   ```
   File xuất ra nằm tại `build/ios/ipa/cn159e_app.ipa` (có thể đổi tên thành `CN159E_Mechatronics_English.ipa`).

### Các phương thức cài đặt & phân phối iOS hợp lệ:
- **TestFlight / App Store Connect**: Upload `.ipa` qua Xcode Organizer hoặc ứng dụng **Transporter** trên Mac, sau đó mời sinh viên cài qua TestFlight.
- **Cài trực tiếp qua Xcode / Apple Configurator**: Kết nối iPhone qua cáp USB trên Mac và Run/Install bản Release (với tài khoản Apple Developer).

---

## 3. Cập nhật ngân hàng dữ liệu
Toàn bộ dữ liệu nằm trong `assets/data/`:
- `vocabulary.json` (từ vựng & thuật ngữ + các biến thể nghĩa chấp nhận)
- `questions.json` (ngân hàng trắc nghiệm)
- `translations.json` (đoạn văn luyện dịch Anh–Việt & Việt–Anh + rubric từ khóa)

Sau khi chỉnh sửa JSON, chỉ cần chạy lại `flutter build apk --release` hoặc `flutter build ipa --release`.

## 4. Sao lưu & Khôi phục dữ liệu (Backup / Restore)
Trong tab **Profile -> Export dữ liệu (JSON)** để xuất toàn bộ tiến độ từ vựng, lịch sử thi, điểm số và danh sách lỗi sai ra file `.json`. Dùng **Import / Restore dữ liệu (JSON)** để khôi phục trên thiết bị khác.
