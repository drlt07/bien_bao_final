# Cách kiểm tra mô hình và ứng dụng

Kiểm tra ở 3 mức, từ dễ đến khó.

## Mức 1. Tập kiểm thử GTSRB (làm trên Colab)
Notebook tự làm phần này ở ô 6 và ô 7:
- Chạy mô hình trên ảnh trong `Test.csv` (ảnh không dùng để huấn luyện).
- Lấy ngẫu nhiên 8.000 ảnh (random_state = 42) để tính các chỉ số giống báo cáo.
- Xuất `bang9_precision_recall_f1.csv` (P, R, F1 của 43 lớp) → dùng cho Bảng 9.
- Chạy lại bản `model.tflite` trên cùng 8.000 ảnh để chắc chắn chuyển sang điện thoại không làm giảm độ chính xác.

## Mức 2. Ảnh biển báo chụp ở Việt Nam
1. Gom ảnh vào thư mục `anh_thuc_te`, mỗi thư mục con đặt tên bằng số nhãn của biển, ví dụ:
   ```
   anh_thuc_te/14/hqv_01.jpg     (biển Dừng lại)
   anh_thuc_te/17/xt_03.jpg      (biển Cấm đi ngược chiều)
   ```
   Tra số nhãn trong sheet "Tinh F1" của file Excel.
2. Ảnh nên cắt sát biển báo (giống khi dùng khung ngắm trong app).
3. Nén thành `anh_thuc_te.zip`, kéo vào khung Files của Colab, chạy ô 8.
4. Kết quả: tỷ lệ đúng, danh sách ảnh sai, file `ket_qua_anh_thuc_te.csv`.
5. Tính F1 cho bộ ảnh này: `python tinh_f1.py ket_qua_anh_thuc_te.csv`
   → ra bảng P/R/F1 từng lớp, Macro-F1 và ảnh ma trận nhầm lẫn.

## Mức 3. Thử ứng dụng trên điện thoại
Chuẩn bị: 2–3 điện thoại khác nhau (ít nhất 1 máy Android cấu hình thấp), app đã cài, file `phieu_ghi_ket_qua.xlsx`.

Mỗi điều kiện thử khoảng 20 lần:

| Điều kiện | Cách làm |
|---|---|
| Ban ngày, đủ sáng | Chụp thẳng, cách biển 3–5 m |
| Trời râm | Buổi sáng sớm hoặc trời nhiều mây |
| Chiều tối | Sau 18h, biển có đèn đường chiếu |
| Góc nghiêng | Đứng lệch khoảng 30° so với mặt biển |
| Khoảng cách xa | Cách biển 10–15 m, phóng to trong khung ngắm |
| Ảnh có sẵn | Chọn ảnh từ thư viện máy |

Mỗi lần thử, ghi một dòng vào sheet **"Ghi tung lan"**: điều kiện, tên máy, nhãn biển thật, nhãn app trả ra, độ tin cậy, thời gian (ms, app hiện ở màn hình kết quả). Cột "Đúng" tự tính.
Sheet **"Tong hop dieu kien"** và **"Thiet bi"** tự cộng lại → chép sang Bảng 14, Bảng 15 của báo cáo.

Lưu ý:
- Bật chế độ máy bay khi thử để chứng minh app chạy không cần mạng.
- Đứng trên vỉa hè, không ra lòng đường.
- Chụp màn hình vài kết quả đúng, vài kết quả sai, và ảnh nhóm đang thử → làm minh chứng (Hình 6, Hình 7).
- Muốn tính F1 cho phần thử app: lưu sheet "Ghi tung lan" thành CSV rồi chạy `python tinh_f1.py ten_file.csv`.

## Hiểu nhanh các chỉ số
Ví dụ với lớp "Dừng lại", thử 10 ảnh biển Dừng lại và 90 ảnh biển khác:
- Máy đoán đúng 9 ảnh Dừng lại → **TP = 9**
- 1 ảnh Dừng lại bị đoán thành biển khác → **FN = 1**
- 2 ảnh biển khác bị đoán thành Dừng lại → **FP = 2**

| Chỉ số | Công thức | Ví dụ | Ý nghĩa |
|---|---|---|---|
| Precision | TP / (TP + FP) | 9 / 11 = 0,82 | Khi máy nói "Dừng lại", đúng bao nhiêu phần |
| Recall | TP / (TP + FN) | 9 / 10 = 0,90 | Trong các biển Dừng lại thật, máy tìm ra bao nhiêu |
| F1 | 2·P·R / (P + R) | 0,86 | Cân bằng giữa hai chỉ số trên |

Macro-F1 = trung bình F1 của tất cả các lớp. Dùng macro để lớp ít ảnh cũng được tính ngang lớp nhiều ảnh.
