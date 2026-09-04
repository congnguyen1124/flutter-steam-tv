# Flutter StreamTV product specification

Thư mục này mô tả hành vi quan sát được của ứng dụng Flutter TV. Spec là nguồn yêu cầu chính cho
code Flutter; dự án `../android_stream_tv` chỉ là tham chiếu về sản phẩm và hình ảnh.

## Quy ước chung

- Thiết kế cho remote D-pad: mọi action chính phải dùng được bằng focus và phím Select/Enter.
- Focus không làm thay đổi kích thước hoặc đẩy layout xung quanh.
- Mỗi màn bất đồng bộ thể hiện đủ Loading, Content và Error (LCE).
- Giao diện dùng theme tối, màu nhấn tím nhạt và font Roboto.
- Top bar tồn tại xuyên suốt khi chuyển các destination chính.
- View dài phải tách thành widget theo trách nhiệm và có Widget Preview xác định.

Xem [Home](home.md) cho feed và [TV focus architecture](../doc_architechture/flutter_tv_focus.md)
cho quy ước triển khai focus.
