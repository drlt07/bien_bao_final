# Biển Báo AI – nhận diện biển báo giao thông bằng CNN

Bộ sản phẩm gồm 3 phần:

```
1_mo_hinh/          Huấn luyện mô hình CNN (code traffic_sign.py của nhóm) + giao diện máy tính
2_app_dien_thoai/   Mã nguồn app Android (Flutter), chạy mô hình ngay trên điện thoại
3_kiem_thu/         Hướng dẫn kiểm tra, file Excel ghi kết quả, script tính F1
```

## Kết quả lần huấn luyện ngày 20/10/2026
- Mô hình: 897.611 tham số, 20 epoch, batch 32, Adam.
- 8.000 ảnh kiểm thử: Macro-Precision 0,93 – Macro-Recall 0,92 – Macro-F1 0,92 (bảng chi tiết trong `1_mo_hinh/ket_qua_huan_luyen/`).
- Lớp yếu nhất: các biển nguy hiểm hình tam giác (người đi bộ cắt ngang F1 0,59; chỗ ngoặt vòng trái 0,69).
- `model.tflite`: 0,87 MB.

## Thứ tự làm

1. **Huấn luyện** – mở `1_mo_hinh/CNN_bien_bao_traffic_sign.ipynb` trên Google Colab
   (File → Upload notebook), chọn Runtime → Change runtime type → T4 GPU, rồi Runtime → Run all.
   Khoảng 10–20 phút. Tải về: `traffic_classifier.h5`, `model.tflite`, đồ thị, bảng F1.
2. **Chạy thử trên máy tính** – `traffic_classifier.h5` đã có sẵn trong `1_mo_hinh/`. Cài `pip install tensorflow pillow`, vào thư mục đó chạy `python gui.py`.
3. **Làm app** – file `model.tflite` đã có sẵn trong `2_app_dien_thoai/bien_bao_ai/assets/` (lần chạy ngày 20/10). Nếu huấn luyện lại thì chép đè file mới vào đó. Build APK (xem dưới).
4. **Kiểm tra** – làm theo `3_kiem_thu/huong_dan_kiem_thu.md`, ghi vào `phieu_ghi_ket_qua.xlsx`.
5. Đưa số liệu vào báo cáo và sổ nhật ký.

Chi tiết về cấu trúc mô hình: `1_mo_hinh/mo_ta_mo_hinh.md`.

## App điện thoại

Luồng xử lý một lần nhận diện:
```
Chụp / chọn ảnh → khung ngắm (cắt vùng có biển) → ảnh RGB 30×30
→ mô hình TFLite chạy trên máy → xác suất 43 loại biển
→ ≥ 60%: hiện tên, mã QCVN, ý nghĩa   |   < 60%: báo "chưa chắc chắn"
→ lưu lịch sử kèm thời gian xử lý
```

Các màn hình: trang chủ, khung ngắm, kết quả (tên biển, mã hiệu, nhóm biển, ý nghĩa, độ tin cậy, 3 khả năng cao nhất, thời gian xử lý), tra cứu 43 biển, ôn tập trắc nghiệm, lịch sử (có thời gian trung bình).

Dữ liệu biển báo nằm trong `assets/signs.json`. Mã hiệu có dấu `*` (nhóm R.301, DP.133) cần đối chiếu lại với QCVN 41:2024/BGTVT rồi sửa trong file này. Lớp 30 (đường có băng tuyết) là biển của Đức, Việt Nam không có.

### Build APK bằng GitHub (không cần cài gì)
1. Tạo repo mới trên github.com.
2. Tải toàn bộ nội dung thư mục `bien_bao_ai` lên (kể cả thư mục `.github` và file `assets/model.tflite`).
   Nếu trình duyệt không tải được thư mục `.github`: Add file → Create new file, gõ tên
   `.github/workflows/build-apk.yml`, dán nội dung file đó vào.
3. Tab Actions → Build APK → Run workflow. Chờ khoảng 10 phút.
4. Mở lần chạy đã xong → Artifacts → tải `BienBaoAI-apk`, giải nén, chép file `.apk` sang điện thoại và cài
   (cho phép cài ứng dụng không rõ nguồn gốc).

Nếu bước nào báo đỏ, mở bước đó, chép phần lỗi để sửa.

### Build trên máy tính (nếu có cài Flutter)
Cần Flutter 3.24.5, Android Studio, JDK 17. Trong thư mục `bien_bao_ai`:
```
flutter create --platforms=android --project-name bien_bao_ai --org vn.khkt .
bash ci/patch_android.sh
flutter pub get
flutter build apk --release
```
File APK ở `build/app/outputs/flutter-apk/app-release.apk`.

## Phần mềm, thư viện sử dụng
- Huấn luyện: Python, TensorFlow/Keras, NumPy, Pandas, Pillow, scikit-learn, Matplotlib, Google Colab
- Dữ liệu: GTSRB (Stallkamp và cộng sự, 2011), tải qua Kaggle
- App: Flutter, tflite_flutter, image_picker, image, shared_preferences
