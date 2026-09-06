# Cách cập nhật ảnh cho README.md

Tài liệu vận hành cho việc chụp lại ảnh/GIF trong [`README.md`](README.md). Đọc file này **trước
khi** đụng vào ảnh trong [`docs/images/`](docs/images/).

Câu hỏi file này trả lời:

- Đổi UI ở file `X.dart` thì phải chụp lại **những capture nào**?
- Chỗ này nên là **ảnh tĩnh hay GIF**?
- Vào màn đó bằng **đường phím nào**, và dùng **item nội dung nào**?
- **Cột Tizen** trong mỗi bảng lấy ảnh ở đâu ra?
- Làm màn hình mới thì thêm capture kiểu gì?

> **Đây là tài liệu sống.** Thêm màn hình, thêm section, đổi thứ tự dummy data, hay đổi đường phím
> vào một màn — đều phải cập nhật file này trong **cùng một change**. Một bảng ánh xạ sai còn tệ hơn
> không có bảng, vì nó khiến người sau tin là mình đã chụp đủ.

---

## 1. Chuẩn bị

Flutter được cài ở `~/flutter` và **không** nằm sẵn trên PATH của shell không tương tác. Mọi lệnh
`flutter` dưới đây cần dòng này trước:

```bash
export PATH="$HOME/flutter/bin:$PATH"
```

```bash
adb devices          # phải thấy ĐÚNG MỘT device
ffmpeg -version      # cần cho cả WebP lẫn GIF
flutter build apk --debug
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

Công cụ chụp là [`tools/capture_media.py`](tools/capture_media.py). Nó tự force-stop rồi mở lại app
**và chờ tới khi app thật sự giữ window focus** trước mỗi capture, nên không capture nào thừa hưởng
focus của capture trước.

```bash
python3 tools/capture_media.py list              # xem toàn bộ capture và loại của nó
python3 tools/capture_media.py shot <tên>        # chụp một ảnh tĩnh
python3 tools/capture_media.py gif <tên>         # quay một GIF
python3 tools/capture_media.py all               # chụp lại toàn bộ (~15 phút)
```

Đầu ra luôn là `docs/images/<tên>-android.webp` hoặc `docs/images/<tên>-android.gif` — **tên capture
cộng hậu tố `-android` chính là tên file**, không cần đổi gì trong README nếu giữ nguyên tên.

**Không chạy `all` khi chỉ sửa một màn.** Chạy `all` mất ~15 phút và tạo diff rác trên những ảnh
không liên quan (video đang phát ở frame khác nhau). Chỉ chạy `all` khi đổi theme/token dùng chung.

---

## 2. Cột Tizen lấy ở đâu

Mỗi mục ảnh trong README là một bảng hai cột: **Android TV** và **Tizen TV**.

- Cột **Android** do `tools/capture_media.py` sinh ra. Tự động, lặp lại được.
- Cột **Tizen** phải **chụp tay** từ TV Samsung hoặc Tizen emulator.

`capture_media.py` chạy trên `adb` nên **vĩnh viễn không sinh được cột Tizen**. Đó là lý do mọi file
nó ghi ra đều có hậu tố `-android`: chỉ cần đặt file Tizen cạnh đó với đúng tên là README hiển thị
được ngay, không phải sửa đường dẫn.

| Ảnh Android | Ảnh Tizen cần đặt vào |
|---|---|
| `docs/images/home-overview-android.webp` | `docs/images/home-overview-tizen.webp` |
| `docs/images/player-controller-android.webp` | `docs/images/player-controller-tizen.webp` |
| … | … (cùng tên capture, đổi hậu tố) |

Sau khi có file Tizen, thay ô `<em>waiting for<br><code>…</code></em>` trong README bằng thẻ `<img>`
tương ứng.

### `player-settings-section` và `player-quality-section` GIỜ ĐÃ có bản Tizen

Trước đây hai ô này trong README ghi "Not applicable on Tizen": host Tizen chạy trên
`video_player_tizen`, vốn hiện thực federated interface của `video_player` nên **không mở ra rendition
nào**. Không có rendition → không có category → `settings.isAvailable` = `false` → nút Settings không
được vẽ.

Đổi host sang `video_player_avplay` (AVPlay của Samsung) thì manifest mở ra, nên **Quality và Audio
đã xuất hiện trên Tizen**. Hai ô đó giờ chờ ảnh thật như mọi ô Tizen khác.

**Ngoại lệ còn lại là Subtitles**, và là cố ý: AVPlay đổi được text track nhưng **không có đường tắt
phụ đề**, mà app luôn để `Off` làm dòng đầu. Menu mà dòng đầu bấm vào không làm gì thì tệ hơn là
không có menu — nên `textTrackSelection` vẫn `false` và category Subtitles không hiện trên Tizen.
Nếu sau này tìm được đường tắt phụ đề (hoặc chuyển sang tự vẽ cue trong Flutter), phải sửa cả bảng
capability ở mục 6 của README lẫn đoạn này.

**Lưu ý khi chụp cột Tizen:** `video_player_avplay` **không chạy trên TV emulator** — chỉ TV Samsung
thật. Mọi ảnh Tizen của player phải chụp từ thiết bị thật.

### Banner launcher KHÔNG phải capture

README nhúng [`banner_logo.webp`](android/app/src/main/res/drawable-xxxhdpi/banner_logo.webp) ngay ở
đầu file, nhưng nó **không** nằm trong `docs/images/` và `capture_media.py` không sinh ra nó. Đó là
asset thiết kế tay, README trỏ thẳng vào `res/` để không nhân đôi file nhị phân.

Đổi banner thì sửa cả 5 bucket density (mdpi → xxxhdpi) rồi cập nhật bảng kích thước ở mục 8 của
README. Đừng chạy capture nào cả.

---

## 3. Ảnh tĩnh hay GIF?

Quy tắc duy nhất: **thứ cần chứng minh có nằm ở sự thay đổi giữa các frame không?**

| Dùng | Khi điều cần nói là | Ví dụ trong README |
|---|---|---|
| **Ảnh tĩnh** (`shot`) | Bố cục, thứ bậc thị giác, màu, hoặc **một trạng thái cuối** | `player-controller`, `setting`, `calendar` |
| **GIF** (`gif`) | Focus di chuyển, animation, hoặc **quan hệ nhân quả giữa hai trạng thái** | `player-focus-restore`, `topbar-focus`, `home-row-navigation` |

GIF đắt hơn nhiều: hàng trăm KB đến vài MB mỗi cái so với 30–120 KB cho ảnh tĩnh. Chỉ dùng GIF khi
một ảnh tĩnh thực sự **không thể** nói được điều đó. Bốn cái đang dùng GIF:

- `player-focus-restore` — điểm mấu chốt là "chrome quay lại đúng nút cũ", tức là so sánh frame đầu
  và frame cuối.
- `vertical-player-panel` — quan hệ trái/phải bất đối xứng trong action row.
- `topbar-focus` — item TopBar giãn ngang lộ nhãn.
- `home-row-navigation` — selector đứng yên, list trượt bên dưới.

Ngược lại: "section mở ra ở mép phải" là **trạng thái**, không phải chuyển động → ảnh tĩnh.

---

## 4. Dùng item nội dung nào

### Quy ước chung

Mọi demo player dùng **stream Big Buck Bunny**, để hai orientation so sánh được với nhau và để người
đọc nhận ra ngay đây là cùng một nội dung.

| Demo | Item | Stream | Đường tới |
|---|---|---|---|
| Player ngang | `video-tokyo-culture` — *Tokyo: Tradition in motion* | `bigBuckBunnyAbr` | Banner, `RIGHT` ×2 |
| Player dọc | `short-festival-colors` — *Festival colors* | `bigBuckBunnyAbr` | Rail *Fresh shorts*, item đầu |

### Ba cái bẫy về dummy data

1. **`trailerUrl` xoay lệch một bậc so với `videoUrl`.** Item có *video* là Big Buck Bunny **không**
   phải item có *trailer* là Big Buck Bunny. Nếu sau này thêm demo trailer thì phải đếm lại.
2. **`short-cricket-focus` dùng `jwPlayerBigBuckBunny`** — tên có chữ BigBuckBunny nhưng là stream
   khác hẳn. Đừng chọn nó cho demo.
3. **Rail *Fresh shorts* là `discoveryShorts.reversed()`**, nên item đầu của nó là item **cuối** trong
   danh sách nguồn. Đổi thứ tự `discoveryShorts` là đổi luôn item mà player dọc mở ra.

Nguồn: [`home_dummy_data_source.dart`](lib/features/home/data/source/home_dummy_data_source.dart).

### Thứ tự điều hướng (dùng để tính số phím)

**Section trong Home, từ trên xuống** — số phím `DPAD_DOWN` từ Banner:

| # | Section | viewType |
|---|---|---|
| 0 | Featured today (hero) | `banner` |
| 1 | Videos for you | `videos` |
| 2 | Popular videos | `videosPopular` |
| 3 | Documentary series | `listSeries` |
| 4 | Live channels | `channels` |
| 5 | Portrait discoveries | `verticalBanner` |
| 6 | Fresh shorts | `shorts` |
| 7 | Popular shorts | `shortPopular` |

**TopBar, từ trái sang phải**: Search, Home, Calendar, Setting, Profile. Home được chọn sẵn lúc mở
app, nên từ Home: `LEFT` ×1 tới Search, `RIGHT` ×1 tới Calendar, ×2 tới Setting, ×3 tới Profile.

**Control row của player ngang**, chrome hiện ra là focus ở play/pause:

| Phím từ play/pause | Tới |
|---|---|
| `LEFT` ×1 | Rewind |
| `LEFT` ×2 | Pill `Description` |
| `RIGHT` ×1 | Forward |
| `RIGHT` ×2 | Like |
| `RIGHT` ×3 | Save |
| `RIGHT` ×4 | Settings |
| `UP` | Seek bar |

**Interaction panel của player dọc**: `RIGHT` từ stage vào thẳng **action đầu tiên** (Like), *không*
phải title block. Title block ở **một bước `UP`** từ đó.

---

## 5. Bẫy lớn nhất: chrome tự ẩn sau 5 giây

Đây là thứ làm hỏng capture nhiều nhất, và nó **không phải bug**.

Controller của player ngang tự ẩn sau 5 giây kể từ lần **kích hoạt** (activation) cuối cùng. **Di
chuyển focus dọc control row KHÔNG gia hạn bộ đếm** — bản Compose gốc cũng vậy
(`PlayerController.kt` chỉ gọi `onInteraction()` trong các `onClick`), và `spec/player.md` còn cấm
gắn bộ đếm vào focus change vì làm thế thì controller không bao giờ ẩn.

Hậu quả: một kịch bản kiểu "hiện chrome → bấm `RIGHT` bốn lần → bấm `CENTER`" là **đang chạy đua với
đồng hồ**. Khi thua, một phím bị tiêu vào việc hiện lại chrome, mọi phím sau đó lệch đi một nút, và
kết quả vẫn là **một tấm ảnh hợp lệ của sai màn hình** — lần đầu gặp là ảnh "Settings" nhưng focus
thực ra đang ở nút Save.

**Cách làm đúng, đã áp dụng trong `capture_media.py`:** không đếm phím trong khung 5 giây. Thay vào
đó `setup` đi tới **cuối control row** rồi chờ cho chrome ẩn hẳn:

```python
OPEN_LANDSCAPE = ["sleep:3", "DPAD_RIGHT", "DPAD_RIGHT", "DPAD_CENTER", "sleep:16"]
PARK_ON("DPAD_RIGHT")   # DOWN (hiện chrome) + RIGHT ×6 + sleep:7
RECALL                  # DOWN — chrome quay lại ĐÚNG nút vừa đỗ
```

Hai tính chất làm cách này không thể sai:

- **Đi tới cuối row thì tự sửa lỗi**: phím bị nuốt chỉ làm mất một bước, và phím thừa ở cuối row là
  no-op. Vì thế mới bấm dư (`ROW_OVERSHOOT = 6`) thay vì bấm vừa đủ.
- **Chrome quay lại ở nút cũ**, nên phần biểu diễn thật chỉ dài **hai phím** — thừa sức nằm trong 5
  giây.

Dùng `DPAD_DOWN` làm phím "hiện chrome" chứ không dùng `UP` hay `CENTER`: dưới control row không có
gì, nên `DOWN` là hướng duy nhất không thể vô tình làm focus dịch đi nếu chrome đang hiện.

`setup_delay` (mặc định 1.0s) và `step_delay` là **hai giá trị riêng** đúng vì lý do này: `setup` cần
nhịp thong thả cho điều hướng Home, còn `steps` đôi khi cần nhanh.

---

## 5b. Bẫy thứ hai: viền focus của stage dọc tự mờ đi

Stage của player dọc là focus target thật, và viền focus của nó **sáng trắng 2 giây rồi mờ dần trong
1 giây** xuống một đường viền nhạt (`playerFocusBorderSoftened`). Đây là hành vi cố ý — stage giữ
focus gần như suốt phiên xem, để viền trắng 6dp đứng nguyên thì cả màn hình lúc nào cũng bị đóng
khung.

Hệ quả cho việc chụp: capture `vertical-player` có `sleep:18` chờ stream load, mà 18 giây thì viền đã
mờ từ lâu. Một tấm ảnh chụp ngay lúc đó **không cho thấy stage là focus target** — nhìn như một cái
khung tĩnh.

Cách xử lý đang dùng: kết thúc `steps` bằng **`DPAD_CENTER` ×2**. Select khởi động lại chu kỳ viền,
và lần bấm thứ hai trả playback về đúng trạng thái lần đầu tìm thấy. Ảnh chụp ~1.6s sau đó, vẫn nằm
trong 2 giây viền sáng.

Chỉ Select mới khởi động lại chu kỳ — `LEFT`/`UP`/`DOWN` trên stage bị nuốt và không đụng tới nó.

---

## 6. Danh sách capture hiện có

| Tên capture | Loại | Nội dung | Đường vào (sau khi mở app) |
|---|---|---|---|
| `home-overview` | shot | Hero banner + rail đầu | — |
| `home-rows` | shot | Rail *Popular videos* | `DOWN` ×2 |
| `home-series` | shot | Rail *Documentary series* | `DOWN` ×3 |
| `home-channels` | shot | Rail *Live channels* | `DOWN` ×4 |
| `home-vertical-banner` | shot | Portrait carousel | `DOWN` ×5 |
| `home-shorts` | shot | Rail *Fresh shorts* | `DOWN` ×6 |
| `home-row-navigation` | **gif** | Xuống rail rồi sang phải trong rail | `DOWN`, `RIGHT` ×2, `DOWN`, `RIGHT` ×2 |
| `topbar-focus` | **gif** | Item TopBar giãn ngang lộ nhãn | `UP`, `LEFT`, `RIGHT` ×3 |
| `search` | shot | Search | `UP`, `LEFT`, `CENTER`, `DOWN` |
| `calendar` | shot | EPG lưới | `UP`, `RIGHT`, `CENTER`, `DOWN` |
| `setting` | shot | Setting hai pane | `UP`, `RIGHT` ×2, `CENTER`, `DOWN` |
| `profile` | shot | Profile / QR sign-in | `UP`, `RIGHT` ×3, `CENTER`, `DOWN` |
| `player-surface` | shot | Player ngang, không chrome | `RIGHT` ×2, `CENTER`, chờ 16s |
| `player-controller` | shot | Controller hiện, focus play/pause | ↑ rồi `CENTER` |
| `player-metadata-section` | shot | Section Metadata | ↑ rồi `PARK_ON(LEFT)`, `RECALL`, `CENTER` |
| `player-settings-section` | shot | Danh sách Settings | ↑ rồi `PARK_ON(RIGHT)`, `RECALL`, `CENTER` |
| `player-quality-section` | shot | Panel Quality chồng lên Settings | ↑ rồi `PARK_ON(RIGHT)`, `RECALL`, `CENTER` ×2 |
| `player-focus-restore` | **gif** | Chrome quay lại nút cũ → seek bar → về lại | ↑ rồi `PARK_ON(RIGHT)`, `RECALL`, `UP`, `DOWN` |
| `vertical-player` | shot | Stage 9:16 + interaction panel, viền focus sáng | `DOWN` ×6, `CENTER`, chờ 18s, rồi `CENTER` ×2 |
| `vertical-player-metadata` | shot | Section trong suốt trên nền ambient | ↑ rồi `RIGHT`, `UP`, `CENTER` |
| `vertical-player-panel` | **gif** | Stage → panel → dịch trong action row | ↑ rồi `RIGHT`, `UP`, `DOWN`, `RIGHT`, `LEFT` |

Định nghĩa đầy đủ (kể cả `settle`, `setup_delay`, `step_delay`, `duration`) nằm trong dict `CAPTURES`
của [`tools/capture_media.py`](tools/capture_media.py).

---

## 7. Sửa file nào thì chụp lại capture nào

Đây là bảng tra chính. Cột trái là thứ vừa sửa, cột phải là **toàn bộ** capture cần chạy lại.

### Player

| Sửa | Chụp lại |
|---|---|
| `widget/player_control_row.dart`, `player_controller_chrome.dart` | `player-controller`, `player-focus-restore` |
| `widget/player_seek_bar.dart` | `player-controller`, `player-focus-restore` |
| `view/player_screen.dart` | `player-surface`, `player-controller`, `player-focus-restore`, cả 3 section shot ngang |
| `view/vertical_player_screen.dart`, `widget/vertical_player_stage.dart`, `vertical_player_interaction_panel.dart`, `vertical_player_ambient_background.dart` | `vertical-player`, `vertical-player-panel`, `vertical-player-metadata` |
| `widget/player_section_panel.dart` — hàng Settings | `player-settings-section`, `player-quality-section` |
| `widget/player_section_host.dart` — header panel | cả 4 section shot (hai orientation) |
| `widget/player_section_panel.dart` | cả 4 section shot (hai orientation) |
| `widget/player_section_host.dart`, `player_animated_section.dart`, `player_parked_focus_target.dart` | cả 4 section shot (hai orientation) |
| `model/player_section_stack.dart`, `player_focus_owner.dart` | cả 4 section shot **và** `player-focus-restore` |
| `model/player_settings_ui_state.dart` | `player-settings-section`, `player-quality-section` |

### Home và shell

| Sửa | Chụp lại |
|---|---|
| `widget/home_hero_section.dart` | `home-overview` |
| `widget/home_vertical_banner_section.dart` | `home-vertical-banner` |
| `widget/home_section_row.dart`, card của rail | `home-rows`, `home-series`, `home-channels`, `home-shorts` |
| `core/widgets/tv_list_view/**` | `home-row-navigation` + 4 rail shot ở trên |
| `core/widgets/steam_top_bar*.dart`, `features/main/**` | `topbar-focus` **và mọi shot có TopBar** — tức toàn bộ mục 1 và 3 của README |
| `search/**`, `calendar/**`, `setting/**`, `profile/**` | `search`, `calendar`, `setting`, `profile` tương ứng |

### Thay đổi lan rộng

| Sửa | Chụp lại |
|---|---|
| `core/design_system/**` | `all` |
| `home_dummy_data_source.dart` — đổi thứ tự section hoặc item | `all`, **và** kiểm tra lại mọi đường phím ở mục 4 của file này |
| `flutter_stream_player` (bảng capability đổi) | `all` player shot, **và** cập nhật bảng capability ở mục 6 của README |

Ví dụ cụ thể — **sửa UI của `player_control_row.dart`**:

```bash
export PATH="$HOME/flutter/bin:$PATH"
flutter build apk --debug
adb install -r build/app/outputs/flutter-apk/app-debug.apk
python3 tools/capture_media.py shot player-controller
python3 tools/capture_media.py gif player-focus-restore
```

Rồi mở [`README.md`](README.md) mục *4. The landscape player*, đọc lại caption dưới hai ảnh đó xem
còn đúng không.

---

## 8. Làm một màn hình mới

Bốn bước, làm hết trong cùng một change:

1. **Thêm entry vào `CAPTURES`** trong [`tools/capture_media.py`](tools/capture_media.py). Đặt tên
   kebab-case theo dạng `<màn>-<thứ-cần-nói>`. Tách `setup` (đường phím để tới nơi, không quay) khỏi
   `steps` (chính phần biểu diễn) — GIF chỉ nên chứa phần biểu diễn.
2. **Nếu là GIF thì thêm tên vào `GIF_CAPTURES`.** Không thêm thì nó bị chụp thành ảnh tĩnh.
3. **Chạy thử và xem lại kết quả bằng mắt.** Đừng tin là nó đúng chỉ vì lệnh chạy xong không lỗi —
   đường phím sai vẫn cho ra một tấm ảnh hợp lệ của màn hình sai.
4. **Nhúng vào [`README.md`](README.md)** dưới dạng **bảng hai cột** như mọi mục khác, với ô Tizen là
   placeholder ghi rõ tên file đang chờ. Caption *in nghiêng* nói điều mà ảnh **chứng minh**, không
   phải mô tả lại thứ nhìn thấy được. Rồi **cập nhật mục 6 và 7 của file này**.

---

## 9. Checklist trước khi commit ảnh

- [ ] Đã **mở từng ảnh mới ra xem**. Đường phím sai vẫn tạo file thành công.
- [ ] Focus đang ở **đúng nút** mình định chụp — đếm lại theo bảng control row ở mục 4.
- [ ] Không có ảnh nào bị bắt **giữa animation** — panel section phải đứng yên hẳn.
- [ ] Không có ảnh nào bị bắt **giữa lúc list đang cuộn** — rail phải dừng hẳn.
- [ ] Không có ảnh player nào còn **buffering** hoặc đang ở frame đen đầu stream.
- [ ] Nội dung không **đè lên TopBar** — lớp readability gradient phải hiện khi feed đã cuộn.
- [ ] Player dùng đúng nội dung Big Buck Bunny.
- [ ] `python3 tools/capture_media.py list` khớp với bảng ở mục 6 của file này.
- [ ] Mọi đường dẫn ảnh trong README đều tồn tại, và mọi file trong `docs/images/` đều được dùng:

```bash
python3 - <<'PY'
import re, io, os
s = io.open('README.md', encoding='utf-8').read()
refs = set(re.findall(r'!\[[^\]]*\]\(([^)]+)\)', s)) | set(re.findall(r'<img src="([^"]+)"', s))
print("THIEU FILE:", [r for r in sorted(refs) if not os.path.exists(r)] or "khong")
print("ANH THUA:", sorted({f for f in os.listdir('docs/images')} - {os.path.basename(r) for r in refs}) or "khong")
PY
```

---

## 10. Những lỗi đã gặp, đừng gặp lại

| Triệu chứng | Nguyên nhân | Cách xử lý |
|---|---|---|
| Ảnh "Settings" nhưng focus ở nút **Save** | Chrome tự ẩn giữa chừng, một `RIGHT` bị tiêu vào việc hiện lại chrome | Xem mục 5 — dùng `PARK_ON` + `RECALL`, đừng đếm phím trong 5 giây |
| Player thành **màn hình đen chỉ còn video**, mọi phím vô tác dụng | Focus rơi vào parked anchor. Anchor luôn được compose và nằm ở mép trái, nên `LEFT` quá nút `Description` là đi vào đó | Đã sửa: `PlayerParkedFocusTarget` đặt `skipTraversal: true`. Nếu tái diễn, kiểm tra thuộc tính đó trước |
| Chrome hiện nhưng **không nút nào sáng** | Vẫn là parked anchor: nó giữ focus nên `autofocus` của chrome không đòi được | Như trên |
| Section bị bắt giữa lúc trượt vào | Khoảng nghỉ sau `steps` chỉ 0.6s, đủ cho một bước focus chứ không đủ cho animation panel | Thêm `"sleep:2"` vào cuối `steps` |
| Ảnh capture ra **TV launcher** chứ không phải app | `am start` chạy khi task cũ chưa đóng xong | Đã sửa: `relaunch()` chờ 2s rồi poll `dumpsys window displays` tới khi app giữ focus |
| Nội dung **đè lên logo STEAM TV** | Thiếu lớp readability gradient sau TopBar | Đã sửa: Home yêu cầu lớp này khi focus rời section đầu (`TopBarReadability`) |
| Ảnh destination bị mờ xám | Chọn destination xong focus vẫn ở TopBar, và TopBar phủ dim lên nội dung | Kết thúc `steps` bằng `DPAD_DOWN` |
| Player ra frame đen hoặc đang buffer | Chưa chờ stream render xong | `sleep:16` cho player ngang, `sleep:18` cho player dọc |
| Panel Settings chỉ có một dòng | Đúng như thiết kế — stream này không có phụ đề/audio thay thế, và Settings bỏ category có dưới hai lựa chọn | Không phải lỗi. Bấm `CENTER` thêm một lần để vào danh sách Quality |
| Vào nhầm màn | Đếm sai `DPAD_DOWN`, hoặc thứ tự section/TopBar đã đổi | Đối chiếu hai bảng thứ tự ở mục 4 |
| Stage dọc không thấy viền focus | Viền sáng 2s rồi mờ, mà `sleep:18` đã trôi qua từ lâu | Xem mục 5b — kết thúc `steps` bằng `CENTER` ×2 |
| Stage dọc nằm sát mép trái | Layout cũ dùng `Row` + `SizedBox(48)`. Bản đúng là **căn giữa rồi dịch trái 24** như `VerticalPlayerScreen.kt` của ottclouds | Đã sửa; test `stage placement` giữ đúng vị trí này |
| GIF quá nặng | `duration` dài, hoặc nền là video đang chạy nên mọi frame đều khác nhau | Rút ngắn `duration`, bớt `steps` |
| `flutter: command not found` | Flutter ở `~/flutter`, không nằm trên PATH mặc định | `export PATH="$HOME/flutter/bin:$PATH"` |
| Emulator không tải được stream dù ping được | TLS của emulator hỏng sau khi chạy lâu | `adb reboot`, chờ boot xong rồi chụp lại |
