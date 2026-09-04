# Home screen specification

Đọc [spec chung](README.md) trước. Tài liệu này mô tả kết quả mong muốn của Home trên Flutter, không
mô tả chi tiết từng class hoặc từng dòng code.

## Mục đích

Home là feed dọc gồm nhiều section biên tập khác nhau. `HomeScreen` là boundary cao nhất của feature:
nó nhận state từ Riverpod ViewModel, hiển thị LCE và xử lý action. Feature này không có `HomeRoute`.

## Dữ liệu ban đầu

Dummy data tương đương nội dung mẫu của Android và giữ thứ tự:

1. Featured today (`banner`)
2. Videos for you (`videos`)
3. Popular videos (`videosPopular`)
4. Documentary series (`listSeries`)
5. Live channels (`channels`)
6. Portrait discoveries (`verticalBanner`)
7. Fresh shorts (`shorts`)
8. Popular shorts (`shortPopular`)

Mỗi item có id ổn định, playback URL, trailer URL tùy chọn, thumbnail URL, tiêu đề, mô tả, phân loại
độ tuổi và loại nội dung. Series có thể chứa episode. Section rỗng hoặc chứa sai loại item phải bị
từ chối tại ranh giới map từ data sang domain.

## LCE

- Loading hiển thị progress và thông báo tải Home.
- Content hiển thị feed khi dữ liệu hợp lệ.
- Error hiển thị thông báo dễ hiểu và action `Try again` gọi `HomeViewModel.reload()`.
- Danh sách content rỗng hiển thị empty state, không tạo focus target giả.

## Bố cục feed

- Feed dùng cơ chế builder/lazy để không dựng tất cả section và card cùng lúc. Feed dọc sử dụng
  `TvListView.separated`; hàng ngang sử dụng `ListContentView.separated`. Cả hai giữ delegate lazy
  tương đương các named constructor của `ListView`.
- Khoảng cách giữa section là `34`, bottom padding là `54`, heading hàng thường bắt đầu tại `48`.
- Khi focus đi giữa các section, `TvListView` dùng một anchor duy nhất: item giữa được neo tại giữa
  viewport, item đầu neo đầu danh sách và item cuối neo cuối danh sách. Mỗi lần Down/Up chỉ cuộn tới
  đúng section vừa nhận focus, không cộng thêm offset từ lần cuộn trước.
- `TvListView` là entry focus target của feed. Khi nhận focus từ top bar, list tự về index `0` rồi
  focus descendant đầu tiên của item đó; không được giả định item đầu là hero hay một view type cụ
  thể. Key-repeat Up/Down bị giới hạn theo nhịp khoảng `280ms` để không nhảy qua nhiều section.
- Banner đầu tiên full bleed phía sau top bar. Chiều cao bằng viewport trừ `124`, giới hạn trong
  khoảng `320..600`, để vẫn lộ phần đầu section kế tiếp ở 720p và 1080p.
- Nếu section đầu không phải banner, content bắt đầu phía dưới top bar.

## Hero banner

- Hero có một focus target duy nhất.
- Trái/phải đổi item; Select/Enter mở item hiện tại; Up có thể chuyển tới top bar; Down chuyển section.
- Hiển thị thumbnail thật, lớp gradient để đọc chữ, title, mô tả, độ tuổi, nút `Watch now` và dots.
- Tự chuyển sau mỗi 5 giây khi banner không giữ focus; dừng khi app không active.
- Trailer playback chưa thuộc phase Home dummy hiện tại. Sau khi thêm player, trailer được phép bắt
  đầu sau 5 giây và phải quay lại ảnh khi video kết thúc/lỗi.

## Hàng content cố định

- Mỗi hàng chỉ có một focus target; card bên trong không được focus riêng.
- Khung chọn cố định tại inset trái `48`; item di chuyển dưới khung khi selection đổi.
- `ListContentView.builder/separated` dựng item lazy trên `ListView.builder`, có cache item kế bên và
  không cho cuộn gesture làm selection lệch khỏi vị trí hiển thị.
- Animation selection kéo dài khoảng `190ms`; key lặp trong lúc animation không tạo chuyển động chồng.
- Hàng không xếp hạng có hơn năm item loop từ cuối về đầu. Hàng tối đa năm item và mọi hàng ranked
  dừng ở item cuối.
- Mỗi section nhớ item đã chọn khi focus đi sang section khác.
- Select/Enter mở item đang nằm trong khung chọn.

## Card

- Landscape video, series và channel giữ artwork `16:9`; chiều rộng được tính theo viewport để thấy
  khoảng `5.5` item cùng lúc.
- Landscape ranked hiển thị khoảng `4` item. Số thứ hạng có vùng leading riêng nằm trong bounds của
  item, được chuẩn hóa cùng chiều cao thị giác và căn cạnh phải vào thumbnail. Thumbnail chỉ che một
  dải overlap nhỏ của số; artwork không bị co khác nhau theo kích thước canvas từng file.
- Short giữ artwork `2:3`, nhỏ hơn landscape hợp lý: hàng thường khoảng `6.5` item và ranked short
  khoảng `5` item trong viewport.
- Detail landscape cao `46`, detail short cao `64`; spacing responsive tương ứng loại thường/ranked.
- Card hiển thị thumbnail, badge loại nội dung/live, độ tuổi, title và mô tả rút gọn.
- Card đang chọn dùng màu tím nhạt của Flutter theme cho title/focus treatment.

## Portrait banner

- Section là carousel ảnh dọc ở nửa phải, có một focus target và điều khiển trái/phải/Select như hero.
- Khối title, description, metadata, play affordance và dots ở bên trái dùng chung widget info với
  hero banner.
- Carousel chỉ hiển thị đúng `5` poster. Item được chọn luôn nằm giữa; các item lân cận sát nhau,
  giảm scale/opacity theo khoảng cách nhưng vẫn căn giữa theo chiều cao của item đang chọn.
- Background của item đang chọn chỉ phủ vùng bên phải phía sau carousel và bắt đầu sau khối info;
  không đặt artwork phía sau title/description. Trái/phải chỉ dịch đúng một page.
- Nội dung short luôn mở trải nghiệm portrait, bất kể tên section.

## Khôi phục focus

- Cold launch focus section đầu nếu top bar không đang giữ focus.
- Home nhớ selection của từng section trong vòng đời màn.
- Đi Home từ top bar phải giữ focus tại nút Home cho tới khi người dùng nhấn Down. Shell chỉ chuyển
  focus tới entry target của content; `TvListView` chịu trách nhiệm đưa focus vào item index `0`,
  không khôi phục section cũ và không phụ thuộc view type của item đầu.

## Acceptance scenarios

- Hero và phần đầu section kế tiếp cùng xuất hiện ở viewport 1280x720 và 1920x1080.
- Hàng sáu item đi từ item sáu về item một mà không lộ khoảng trống cuối.
- Hàng năm item dừng tại item năm.
- Mọi hàng ranked dừng ở rank cuối và ảnh số không bị cắt.
- Viewport hiển thị xấp xỉ `5.5` landscape thường và `4` landscape ranked.
- Focus section giữa giữ cùng một anchor dọc; section đầu/cuối lần lượt khớp đầu/cuối feed.
- Giữ phím Up/Down không được bỏ qua nhiều section trong một animation scroll.
- Trái/phải không chuyển focus qua từng card; toàn hàng vẫn là một focus target.
- Select mở đúng item đang chọn.
- Loading, Content, Error và retry có widget test.
- Chọn Home từ top bar không giật focus xuống content.
- Nhấn Down từ Home trên top bar focus đúng section index `0`, kể cả khi section đó không phải hero.
