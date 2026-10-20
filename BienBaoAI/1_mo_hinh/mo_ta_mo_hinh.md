# Mô hình CNN nhận diện biển báo

## Mô hình làm gì
Nhận vào một ảnh biển báo (đã cắt sát biển), trả ra xác suất của 43 loại biển. Loại có xác suất cao nhất là kết quả.

- Đầu vào: ảnh màu RGB, kích thước 30 × 30, giá trị điểm ảnh 0–255.
- Đầu ra: 43 số (tổng bằng 1), mỗi số là xác suất của một loại biển (nhãn 0–42 theo bộ GTSRB).

## Cấu trúc (code trong traffic_sign.py)

| Lớp | Thông số | Kích thước ra | Số tham số |
|---|---|---|---|
| Conv2D | 32 bộ lọc 5×5, padding same, ReLU | 30×30×32 | 2.432 |
| Conv2D | 32 bộ lọc 5×5, padding same, ReLU | 30×30×32 | 25.632 |
| MaxPool + Dropout | 2×2, bỏ 25% | 15×15×32 | 0 |
| Conv2D | 64 bộ lọc 3×3, padding same, ReLU | 15×15×64 | 18.496 |
| Conv2D | 64 bộ lọc 3×3, padding same, ReLU | 15×15×64 | 36.928 |
| MaxPool + Dropout | 2×2, bỏ 25% | 7×7×64 | 0 |
| Flatten | | 3.136 | 0 |
| Dense + Dropout | 256 nơ-ron, ReLU, bỏ 50% | 256 | 803.072 |
| Dense | 43 nơ-ron, Softmax | 43 | 11.051 |
| **Tổng** | | | **897.611** |

Cách tính số tham số một lớp Conv: (k × k × số kênh vào + 1) × số bộ lọc.
Ví dụ lớp đầu: (5 × 5 × 3 + 1) × 32 = 2.432.

## Huấn luyện
- Dữ liệu: GTSRB, 39.209 ảnh huấn luyện, chia 80% học / 20% kiểm định (random_state = 42).
- 20 epoch, batch 32, bộ tối ưu Adam (tốc độ học 0,001), hàm mất mát categorical cross-entropy.
- Chạy bằng notebook `CNN_bien_bao_traffic_sign.ipynb` trên Google Colab (GPU T4), hoặc chạy `traffic_sign.py` trên máy có GPU.

Sau khi chạy sẽ có:
- `traffic_classifier.h5`: mô hình đầy đủ, dùng cho `gui.py` trên máy tính.
- `model.tflite`: bản rút gọn (lượng tử hóa) để chạy trên điện thoại, khoảng 0,9 MB.

## Các file trong thư mục này
| File | Dùng để |
|---|---|
| `traffic_sign.py` | Code huấn luyện gốc của nhóm (chỉ sửa lỗi đường dẫn và phần kiểm tra cuối file) |
| `CNN_bien_bao_traffic_sign.ipynb` | Cùng code đó, chia ô để chạy trên Colab, có thêm phần xuất đồ thị, bảng F1, file TFLite |
| `gui.py` | Giao diện trên máy tính: chọn ảnh → hiện tên biển và độ tin cậy |

Chạy giao diện: đặt `gui.py` cùng thư mục với `traffic_classifier.h5`, cài `pip install tensorflow pillow`, rồi `python gui.py`.

## Hạn chế cần biết
- Mô hình học trên biển báo của Đức. Biển nguy hiểm của Việt Nam nền vàng nên dễ bị nhầm hơn.
- Biển không thuộc 43 loại (ví dụ tốc độ tối đa 40 km/h) vẫn bị mô hình gán vào một loại gần giống. Vì vậy app có ngưỡng 60%: dưới ngưỡng thì báo "chưa chắc chắn".
- Ảnh phải cắt sát biển báo. Ảnh toàn cảnh đường phố thu về 30×30 thì biển gần như biến mất.
