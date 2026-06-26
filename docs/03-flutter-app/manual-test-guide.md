# EventHub — Hướng dẫn test thủ công (demo từng luồng)

Ngắn gọn, dùng để demo/QA toàn bộ app. Mỗi mục: **làm gì → kỳ vọng thấy gì**.

---

## 0. Chuẩn bị

1. **Redeploy backend** (bắt buộc cho các luồng có dấu 🌐): Render → service `eventhub-api` → **Manual Deploy → Deploy latest commit**.
2. **Chạy app:**
   ```powershell
   flutter run -d emulator-5554 ^
     --dart-define=API_BASE_URL=https://eventhub-api-b4yb.onrender.com/api ^
     --dart-define=GOOGLE_SERVER_CLIENT_ID=900843335608-fr8h5ujhqk17h1v605f8dmm5nj6imk0u.apps.googleusercontent.com
   ```
3. Tài khoản demo: tạo nhanh 1 `user@demo.com` và 1 `organizer@demo.com` (mật khẩu ≥ 8 ký tự) ở màn Sign up.

> 🌐 = cần backend bản mới (đã redeploy). Không dấu = frontend thuần, chạy được ngay.

---

## 1. Auth — Đăng ký / Đăng nhập

- Sign up (chọn role User hoặc Organizer) → vào thẳng Home.
- Đăng xuất → Sign in lại bằng email vừa tạo.
- ✔️ Kỳ vọng: vào Home, header hiện tên + email + badge role.

## 2. Reset Password 🌐

- Màn **Sign in** → bấm **Forgot Password?** → nhập email → **SEND**.
- ✔️ Kỳ vọng: hộp xanh "If an account exists for that email...". (Cố ý không tiết lộ email có tồn tại không — chống dò tài khoản. Chưa gắn SMTP nên không gửi mail thật.)

## 3. Empty States

- User mới mở **Notifications** (drawer) khi chưa có thông báo.
- ✔️ Kỳ vọng: minh hoạ chuông + badge "0" + "No Notifications!".
- Mở **Events** → search `zzzzz` (không có kết quả).
- ✔️ Kỳ vọng: minh hoạ lịch + "No Upcoming Event" + nút **EXPLORE EVENTS**.

## 4. Events CRUD (Organizer)

- Đăng nhập **organizer** → Events → nút **+** (FAB) → tạo event (có thể chọn ảnh).
- ✔️ Kỳ vọng: quay lại list thấy event mới ngay (filter/search tự clear).
- Mở event vừa tạo → sửa → xoá; kiểm tra list cập nhật đúng.

## 5. See All Events

- Màn **Events** → bấm **See All** (cạnh "Upcoming Events" hoặc "Nearby You").
- ✔️ Kỳ vọng: list dọc đầy đủ; icon 🔍 mở ô tìm kiếm; chạm item → Event Detail.

## 6. Event Detail + Booking + Bookmark

- Mở 1 event → xem chi tiết.
- Bấm **Book** → kiểm tra **My Tickets** (drawer) thấy vé.
- Bấm icon bookmark → vào lại list thấy trạng thái bookmark đúng.

## 7. Share

- Trong Event Detail → nút share (góc ảnh).
- ✔️ Kỳ vọng: Android share sheet hiện tiêu đề + link sự kiện.

## 8. Reviews 🌐

- Event Detail → kéo xuống mục **Reviews** → viết review (chọn sao + comment).
- ✔️ Kỳ vọng: review xuất hiện ngay, số sao đúng.

## 9. Invite Friend

- Màn **Events** → banner "Invite your friends" → **INVITE**.
- Tìm + chạm chọn vài người (✓ xanh) → nút **INVITE (n)** → bấm.
- ✔️ Kỳ vọng: snackbar "Invitations sent..." rồi quay về.

## 10. Profile / Edit Profile 🌐

- Avatar header (hoặc drawer → My Profile) → **Edit**.
- Đổi tên/phone/bio/interests → Save.
- ✔️ Kỳ vọng: quay lại thấy thông tin đã cập nhật.

## 11. Organizer Profile 🌐

- Event Detail → chạm khu vực organizer.
- ✔️ Kỳ vọng: 3 tab **About / Events / Reviews**, số liệu Events & Reviews đúng.

## 12. Notifications + FCM Push

- Lịch sử thông báo: drawer → Notifications, chạm để đánh dấu đã đọc.
- Push thật: để app **chạy nền (không kill)** → gửi push → banner hiện (foreground) hoặc thông báo hệ thống (background).

## 13. Google Sign-In 🌐 (test sau cùng)

- Cần **thiết bị thật / emulator có tài khoản Google**.
- Sign in → **Continue with Google** → chọn tài khoản.
- ✔️ Kỳ vọng: vào Home như user thường; backend tạo/đăng nhập account `authProvider=google`.

---

## Lưu ý khi gặp lỗi

- **"Backend OK nhưng UI không hiện"** (vd tạo xong không thấy): thường do filter/search chưa reset hoặc backend prod chưa redeploy → kiểm tra mục 0.
- Màn 🌐 báo lỗi mạng/endpoint → gần như chắc chắn do **chưa Deploy latest commit** trên Render.
- Lệnh kiểm tra nhanh API: `node .remember/tmp/smoke.mjs` (đặt `SMOKE_BASE=<url>`).
