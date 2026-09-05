# Cầu nối player native (`flutter_stream_player`)

Tài liệu này giải thích cách `flutter_steam_tv` phát video: một API Flutter duy nhất, phía dưới là
player native khác nhau cho từng hệ điều hành. Tầng Flutter chỉ vẽ UI và gọi lệnh; mọi quyết định về
buffering, chọn rendition, phân loại lỗi và quảng cáo đều nằm ở tầng native.

> Bản đồ đầy đủ của package nằm ở [`../../flutter_stream_player/architecture.md`](../../flutter_stream_player/architecture.md).
> Hợp đồng trên đường truyền nằm ở [`../../flutter_stream_player/doc/channel_contract.md`](../../flutter_stream_player/doc/channel_contract.md).
> Tài liệu này chỉ nói phần **app dùng nó như thế nào**.

## 1. Hình dung tổng thể

```mermaid
flowchart TD
    Remote[TV remote] --> Screen[PlayerScreen]
    Screen -->|callback| VM[PlayerViewModel]
    VM -->|"StreamPlayerCommand"| Ctrl[StreamPlayerController]
    Ctrl -->|"dispatch"| Seam[["StreamPlayerPlatform<br/>(hợp đồng chung)"]]

    Seam --> Android[StreamPlayerAndroid]
    Seam --> Tizen[StreamPlayerTizen]

    Android -->|"MethodChannel + EventChannel"| Kotlin[StreamPlayerPlugin - Kotlin]
    Kotlin --> Engine["com.congnguyencn:stream-player<br/>Media3 / ExoPlayer"]

    Tizen -->|"gọi Dart trực tiếp"| VP[video_player]
    VP --> TizenNative["video_player_tizen - C++<br/>capi-media-player"]

    Engine -->|"snapshot → diff → fact"| Reducer
    TizenNative -->|"VideoPlayerValue → diff → fact"| Reducer
    Reducer[["reduceStreamPlayerEvent<br/>(thuần Dart, không cần thiết bị)"]] --> State["StreamPlayerState"]
    State --> UiState[PlayerUiState]
    UiState --> Screen
```

Bốn quy tắc quyết định toàn bộ thiết kế:

1. **Ghi là giá trị.** Mọi thay đổi là một object `StreamPlayerCommand`, nên nó log được, test được
   mà không cần player, không cần channel, không cần thiết bị.
2. **Đọc là một snapshot.** `StreamPlayerState` chứa tất cả những gì player biết, bất biến, trong một
   giá trị. Không màn hình nào tự suy luận lại "đang phát thật hay chỉ đang cố phát".
3. **Native phát ra *fact*, Dart gộp lại.** Native **không** serialize toàn bộ state mỗi lần đổi. Nó
   gửi fact hẹp nhất (`progressChanged` = ba số nguyên), rồi một reducer thuần trong Dart gộp thành
   snapshot. Nhờ vậy: payload nhỏ (tick 500 ms suốt cả bộ phim), và quan hệ giữa các field được định
   nghĩa **đúng một lần** cho mọi nền tảng.
4. **Không đổi thì trả về đúng instance cũ.** `StreamPlayerController` so sánh bằng `identical`, nên
   `Stream` state hoàn toàn im lặng khi player đứng yên.

## 2. Dependency và đăng ký host

`pubspec.yaml`:

```yaml
dependencies:
  stream_player:
    path: ../flutter_stream_player/packages/stream_player
  stream_player_tizen:
    path: ../flutter_stream_player/packages/stream_player_tizen
```

`stream_player_tizen` được khai báo cho mọi nền tảng vì pubspec không tách theo platform. Trên bản
build Android, phần native của nó bị flutter tool bỏ qua (nó chỉ khai báo platform `tizen`), chỉ code
Dart được biên dịch.

Đăng ký host trong [`lib/core/player/stream_player_host.dart`](../lib/core/player/stream_player_host.dart),
gọi từ `main()`:

```dart
void registerStreamPlayerHost() {
  if (StreamPlayerPlatform.isRegistered) {
    return;
  }
  if (Platform.isAndroid) {
    StreamPlayerAndroid.registerWith();
    return;
  }
  StreamPlayerTizen.registerWith();
}
```

Ba điểm đều có chủ ý:

- **`isRegistered` guard.** `stream_player_android` khai báo `dartPluginClass`, nên Dart plugin
  registrant sinh tự động có thể đã đăng ký host Android trước khi `main` chạy. Guard biến trường hợp
  đó thành no-op, và làm hot restart vô hại.
- **Gọi tên platform rõ ràng.** Viết kiểu "cái nào chưa ai chiếm thì đăng ký" trông gọn hơn nhưng
  sai: nếu registrant của Android vì lý do nào đó không chạy, bản đó sẽ **âm thầm** cài host *Tizen*
  trên Android — nơi `video_player` vẫn chạy được thật, nhưng chỉ với
  `StreamPlayerCapabilities.basic`. App vẫn phát video và im lặng mất tính năng chọn chất lượng, và
  không có gì báo tại sao. Gọi tên platform làm lỗi đó không thể xảy ra.
- **Không biến package Tizen thành plugin.** Nó có thể khai báo platform `tizen` với
  `dartPluginClass` để tool tự đăng ký, nhưng như vậy phụ thuộc vào cách `flutter-tizen` xử lý một
  Dart-only plugin implementation — thứ mà cả analyzer lẫn `flutter test` đều không kiểm chứng được.

Nếu không có host nào được đăng ký, `StreamPlayerPlatform.instance` ném `StateError` kèm hướng dẫn
sửa — tốt hơn nhiều so với một null dereference sâu trong widget build.

Trước khi build Android, publish engine một lần (và sau mỗi lần sửa engine):

```bash
cd ../android_stream_player && ./gradlew :stream-player:publishToMavenLocal
```

### Cấu hình Android bắt buộc

Tất cả đều là yêu cầu của **engine** hoặc toolchain của bridge, và mỗi cái fail bằng một thông báo
khác nhau. `android/` đã áp dụng đủ; app khác muốn dùng bridge này cần cả sáu.

| Cấu hình | Giá trị | Vì sao |
|---|---|---|
| `compileSdk` | **37** | Engine compile với 37; app không thể compile thấp hơn library nó dùng. Compile SDK tương thích ngược nên không ảnh hưởng `targetSdk`. |
| `minSdk` | **26** | Sàn của engine. Fail ở manifest merger, không phải lúc compile. |
| AGP | **≥ 9.1.0** (dùng 9.3.2 cho khớp engine) | Media3 1.11, Compose 1.12, core-ktx 1.19 đều từ chối AGP dưới 9.1.0. |
| Gradle wrapper | **≥ 9.5.0** (dùng 9.7.1 cho khớp engine) | AGP 9.3.2 yêu cầu. |
| Built-in Kotlin | `android.builtInKotlin=true`, không apply `org.jetbrains.kotlin.android` | AGP 9 cung cấp Kotlin trực tiếp. Flutter 3.47+ hỗ trợ chế độ này sau khi mọi plugin Android đã migrate. |
| Core library desugaring | **bật**, kèm `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")` | `media3-exoplayer-ima` và `interactivemedia` khai báo trong AAR metadata. Cần **kể cả khi tắt quảng cáo** — engine vẫn kéo chúng vào. |

Chọn đúng phiên bản AGP/Gradle của engine thay vì lấy mức tối thiểu, để cả hai đầu cầu chỉ có **một**
phiên bản phải giữ đồng bộ.

Engine và plugin Android cũng phải biên dịch bằng Kotlin `2.2.10`, là compiler được AGP 9.3.2 cung
cấp. Không publish engine bằng compiler mới hơn: metadata Kotlin mới có thể vượt khả năng đọc của
compiler trong app dù AGP/D8 vẫn hiểu bytecode đó.

Flutter 3.47 vẫn dùng legacy Variant API trong Flutter Gradle Plugin, vì vậy app tạm giữ
`android.newDsl=false`. `android.sync.suppressAgpWarnings` chỉ tắt hai mã warning do opt-out này;
không tắt warning Gradle/AGP khác. Bỏ cả hai dòng khi Flutter chuyển sang
`AndroidComponentsExtension`.

## 3. Cấu trúc feature `player`

Đúng quy ước feature-first trong [`riverpod_clean_architecture.md`](riverpod_clean_architecture.md):
`View -> ViewModel -> Repository -> DataSource`.

```text
lib/features/player/
|-- player_providers.dart                  # composition root: nối Repository với domain interface
|-- domain/
|   |-- model/playback_item.dart           # id, title, description, streamUrl, isLive
|   `-- repository/playback_repository.dart
|-- data/
|   |-- mapper/home_item_playback_mapper.dart      # HomeItem -> PlaybackItem
|   `-- repository/home_catalog_playback_repository.dart
`-- presentation/
    |-- model/
    |   |-- player_ui_state.dart           # state màn hình + copy lỗi + format đồng hồ
    |   |-- player_focus_owner.dart        # ai đang giữ D-pad + resolver thuần
    |   `-- player_settings_ui_state.dart  # suy ra menu cài đặt từ state + capabilities
    |-- view_model/player_view_model.dart  # playerControllerProvider + PlayerViewModel
    |-- view/
    |   |-- player_route.dart              # biết Riverpod và điều hướng
    |   |-- player_screen.dart             # thuần: nhận state + callback + surface
    |   `-- player_screen_preview.dart     # 5 preview xác định
    `-- widget/
        |-- player_controller_chrome.dart  # scrim + title + seek bar + control row
        |-- player_control_row.dart
        |-- player_seek_bar.dart
        |-- player_progress_bar.dart
        |-- player_icon_button.dart
        |-- player_buffering_indicator.dart
        |-- player_settings_panel.dart
        `-- player_error_panel.dart
```

Feature `player` **không có DataSource riêng**. Lý do ở mục kế tiếp.

### Player đọc catalogue của Home

`HomeItem` đã mang `videoUrl`, `trailerUrl`, `kind` và `episodes`, nên stream chỉ tồn tại **đúng một
lần**, ngay cạnh các row đang chào nó.

Bản đầu của feature này giữ **một catalogue thứ hai** bên trong player, key theo cùng id. Ngay khi id
bên Home đổi (`wild-frontier` → `video-wild-tiger`), mọi lần bấm đều mở ra một player không resolve
nổi chính item của nó — và không có gì trong widget tree bắt được lỗi đó. Hai danh sách của cùng một
thứ thì luôn lệch nhau; một danh sách thì không.

Vì vậy `HomeCatalogPlaybackRepository` phụ thuộc vào `HomeRepository` — **interface domain**, không
phải implementation — nên player không biết gì về DTO, DataSource hay chỗ catalogue thực sự nằm.

Quy tắc map, trong [`home_item_playback_mapper.dart`](../lib/features/player/data/mapper/home_item_playback_mapper.dart):

| Thuộc tính player | Lấy từ | Ghi chú |
|---|---|---|
| `streamUrl` | `videoUrl`, fallback `trailerUrl` | Trailer chỉ là phương án chống màn hình đen. Không bao giờ ngược lại — người xem bấm play là muốn xem phim. |
| `isLive` | `kind == channel` | Suy ra, không lưu cờ riêng: một row render là channel và một stream hành xử như live thì không thể lệch nhau. |
| item để phát | chính nó, hoặc episode đầu tiên | Bấm vào series nghĩa là "bắt đầu xem" → episode 1. Resolve ở đây nên player không cần biết series là gì. |
| `id` | id của item **thực sự đang phát** | Với series thì đây là id của episode, nhờ vậy "đang phát cái gì" trả lời được chỉ từ state. |

Tìm kiếm là **depth-first**, vì episode cũng là item của catalogue: id đi qua navigation có thể là id
của một episode, nên nếu chỉ quét item ở tầng đầu thì sẽ fail đúng vào những item mà series tồn tại
để chào.

Khi có API thật, class này là seam: một `CatalogRepository` phục vụ playback theo id sẽ thay thế nó,
và **không có gì phía trên `PlaybackRepository` phải sửa** — không ViewModel, không screen. Tên class
nói rõ dữ liệu hôm nay đến từ đâu chính là để việc thay thế đó hiển nhiên.

### Luồng từ Home tới Player

```mermaid
sequenceDiagram
    participant H as HomeScreen
    participant R as GoRouter
    participant PR as PlayerRoute
    participant VM as PlayerViewModel
    participant Repo as HomeCatalogPlaybackRepository
    participant Home as HomeRepository
    participant C as StreamPlayerController
    participant N as Native host

    H->>R: push('/player/video-wild-tiger')
    R->>PR: build(itemId)
    PR->>VM: ref.watch(playerViewModelProvider(itemId))
    VM->>Repo: getPlaybackItem(itemId)
    Repo->>Home: getHomeSections()
    Home-->>Repo: sections (đã có videoUrl, kind, episodes)
    Repo-->>VM: PlaybackItem (streamUrl đã parse, isLive đã suy ra)
    VM->>C: StreamPlayerController.create()
    C->>N: initialize() rồi create(config)
    N-->>C: playerId
    VM->>C: loadAndPlay(streamUrl)  %% không await: xem ghi chú bên dưới
    VM-->>PR: AsyncData(PlayerUiState)
    N-->>C: fact (progress, tracks, error...)
    C-->>VM: StreamPlayerState (đã gộp qua reducer)
    VM-->>PR: AsyncData(PlayerUiState mới)
```

Ba chi tiết trong luồng này đều có chủ ý:

- **Chỉ `id` đi qua navigation.** Truyền cả `HomeItem` qua `extra` sẽ chạy được hôm nay và vỡ ngay
  lần đầu có deep link mở player trực tiếp — lúc đó không có object nào để truyền.
- **`push`, không `go`.** Back trên remote quay lại đúng row cũ với focus còn nguyên; `go` sẽ dựng
  lại Home từ đầu và mất chỗ đang đứng.
- **Resolve item **trước** khi tạo player.** Nếu catalogue miss, `playerControllerProvider` không bao
  giờ được watch, nên không có decoder nào bị chiếm cho một màn hình sắp render lỗi.

Route của player nằm **ngoài `ShellRoute`** trong
[`app_router.dart`](../lib/app/router/app_router.dart): playback là full-screen, nếu đặt trong shell
thì nó sẽ render bên dưới top bar và top bar sẽ liên tục giành focus D-pad khỏi các control.

`loadAndPlay` không `await` trong `build`: nó hoàn thành khi native đã nhận lệnh, không phải khi có
frame đầu tiên. Await nó sẽ giữ provider ở `AsyncLoading` quá lâu, trong khi màn hình đã có thể vẽ
surface và spinner.

## 4. Vòng đời player — phần bắt buộc

```dart
@riverpod
Future<StreamPlayerController> playerController(Ref ref, String itemId) async {
  final controller = await StreamPlayerController.create();
  ref.onDispose(() => unawaited(controller.close()));
  return controller;
}
```

`close()` là **bắt buộc**. Một player bị leak vẫn giữ hardware decoder, và trên phần lớn TV thì
decoder bị leak thứ ba hoặc thứ tư là lúc playback bắt đầu không khởi tạo được nữa. Provider
auto-dispose nên rời màn hình là player được giải phóng.

`playerController` tách khỏi `PlayerViewModel` vì hai thứ này có vòng đời và người dùng khác nhau:
surface video cần chính object controller, còn màn hình cần snapshot. Tách ra cũng có nghĩa rebuild
màn hình không kéo player chết theo.

## 5. UI: port từ Compose `PlayerScreen.kt`

Bố cục, kích thước và cách xử lý focus lấy từ
`../steam_tv/app/src/main/java/com/congnguyencn/stream_tv/feature/player/presentation/component/PlayerScreen.kt`.

### Ý tưởng quan trọng nhất: một giá trị giữ focus

`PlayerFocusOwner` là **một** giá trị nói ai đang giữ D-pad: `surface`, `controller`, `settings` hay
`error`. Mọi điều kiện trên màn hình đọc đúng giá trị đó.

Cách viết hiển nhiên hơn — vài biến boolean, mỗi effect tự hiểu theo cách của nó — **đã từng sai** ở
bản Compose: panel mở ra khi controller vẫn còn được đánh dấu visible, kết quả là hai subtree đều tin
focus thuộc về mình, và cái nào thắng phụ thuộc effect nào chạy sau. Trên TV nó biểu hiện thành remote
đột nhiên không phản hồi. Đặt tên cho "ai đang giữ" làm trạng thái mâu thuẫn đó **không biểu diễn
được**.

```dart
PlayerFocusOwner resolvePlayerFocusOwner({
  required bool hasError,
  required bool isSettingsOpen,
  required bool isControllerVisible,
});
```

Thứ tự là độ ưu tiên: lỗi trên hết, panel đang mở trên controller, controller trên surface. Hàm thuần
nên test được mà không cần widget tree — xem
[`player_focus_owner_test.dart`](../test/features/player/presentation/model/player_focus_owner_test.dart).

### Các tầng, từ sau ra trước

| Tầng | Ghi chú |
|---|---|
| Màu đen | Để không có gì lọt qua trước frame đầu tiên |
| `videoSurface` | View của chính player native |
| Input target | Bất kỳ phím D-pad nào cũng hiện chrome. Chỉ focusable khi nó đang giữ focus, nên nó tự nhả focus lúc chrome xuất hiện |
| Spinner buffering | Vòng cung tự vẽ (Compose dùng Lottie; app Flutter không ship Lottie runtime) |
| Controller chrome | Scrim gradient, title block trên trái, seek bar + control row dưới |
| Settings panel | Neo vào cạnh phải, video vẫn phát bên cạnh |
| Error panel | Thay thế toàn bộ phía trên nó |

Một số quyết định giữ nguyên từ bản Compose và lý do:

- **Phím mở chrome bị "ăn"**, không truyền tiếp. Nếu không, key-up của nó rơi vào control vừa nhận
  focus và kích hoạt luôn.
- **Focus làm control đảo màu, không scale.** Scale một nút nằm trên pill dùng chung sẽ đẩy nó ra khỏi
  pill; đảo màu giữ hình học của row cố định mà vẫn đọc rõ từ xa.
- **Chrome chỉ mount khi nó đang giữ focus**, vì entry focus dựa trên `autofocus` — thứ chỉ chạy khi
  node được attach lần đầu, không phải khi opacity đổi.
- **Player đang pause thì chrome không tự ẩn.** Người xem dừng lại để nhìn cái gì đó; ẩn control lúc
  đó là phản tác dụng.
- **Live stream không có seek bar**, và resume nhảy về live edge thay vì về chỗ đã pause — nếu không,
  người xem bị tụt lại sau buổi phát mà không có đường quay lại.
- **Row Stack thay vì Row + spacer.** Nhóm transport phải nằm chính giữa panel bất kể cluster bên phải
  rộng bao nhiêu; row có spacer sẽ căn giữa *khoảng trống* giữa hai cluster, làm nút play trôi đi mỗi
  khi nút settings xuất hiện hoặc mất đi.

### Đối chiếu với `spec/player.md`

`../steam_tv/spec/player.md` là hợp đồng sản phẩm, không phụ thuộc framework — theo `AGENT.md` thì
nó, chứ không phải file Compose, mới là nguồn chuẩn. Bản port này theo spec ở những điểm sau:

| Yêu cầu của spec | Ở đây |
|---|---|
| `isSeekable` suy ra từ `duration`, **không** dùng cờ riêng | `PlayerUiState.isSeekable => duration > 0`. Cờ `isLive` của catalogue chỉ dùng cho badge `LIVE` và toggle live-edge, vì mọi item đều báo duration 0 lúc đang load |
| Live: seek bar bị thay bằng **một label elapsed** | `_ElapsedLabel` trong `player_controller_chrome.dart` |
| Live: không có rewind/forward | `_TransportCluster` gate theo `isSeekable` |
| Down từ seek bar về **control vừa dùng** | `_focusLastRowControl()`; các `FocusNode` của control row tự ghi lại, `progress` bị loại trừ |
| Down từ control row **không làm gì** | Surface hết focusable khi chrome hiện (`canRequestFocus`), nên không có gì bên dưới để nhảy tới |
| Đúng một group giữ focus, có thứ tự ưu tiên | `resolvePlayerFocusOwner` — hàm thuần, có test riêng |
| Focus phát ra ở **một chỗ** | Chỉ `PlayerScreen` gọi `requestFocus`; không widget con nào tự xin |
| Phím mở chrome không kích hoạt control | Surface ăn luôn key-down và trả `.handled` |
| Chrome tự ẩn sau ~5s, **chỉ khi đang phát** | `_restartAutoHide()` return sớm nếu `!isPlaying` |
| Trạng thái focus của control theo *chính nó*, không theo con | `InkWell.onFocusChange` (không phải `hasFocus` của subtree) |
| Retry = prepare rồi play, đúng thứ tự | `StreamPlayerController.retry()` |
| Title tối đa 2 dòng | `maxLines: 2` |

### Chưa port

| Của spec | Vì sao |
|---|---|
| Pill `Description` + metadata section | Cần dữ liệu nội dung (`collectionTitle`, `releaseYear`, cast…) mà app Flutter chưa có |
| Nút Comment + comments section | Cần API comment |
| Dải preview frame khi scrub (`seekPreview`) | Cần frame stills từ catalogue |
| Focus group `Parked` | Chỉ cần khi có section transition có animation; settings panel hiện tại mở/đóng ngay |
| Dòng phụ dưới title (`collectionTitle • releaseYear`) | Cùng lý do với metadata; hiện dùng `description` thay chỗ |
| Player dọc (`vertical-player.md`) | Chưa có surface nào cần tới |

Khi có API nội dung, cả nhóm trên ghép vào đúng chỗ mà settings đang ghép (`onOpenSettings`), và
`PlayerControlTarget` mở rộng thêm `description` với `comment`.

Spec cũng tự ghi một **known deviation** mà bản port này thừa hưởng: phụ đề do surface native vẽ có
thể nằm dưới control row khi chrome hiện. Cách sửa là truyền `showSubtitles: false` cho
`StreamPlayerView` trong lúc chrome hiện, hoặc tự vẽ phụ đề từ `StreamPlayerState.cues` — nhưng
`cues` chỉ có trên Android (xem `capabilities`), nên hiện chưa làm.

## 6. Capabilities — câu trả lời trung thực cho hai nền tảng không đều nhau

| | Android (`stream-player`) | Tizen (`video_player_tizen`) |
|---|---|---|
| Play / pause / stop / seek | có | có |
| Tốc độ phát | có | có |
| Danh sách rendition (chất lượng / audio / phụ đề) | có | **không** |
| Giới hạn bitrate | có | **không** |
| Cue phụ đề trong Dart | có | **không** (native tự vẽ) |
| Quảng cáo client-side (CSAI) | có | **không** |
| Tinh chỉnh buffer / cache | có | **không** (config bị bỏ qua) |
| Phân loại lỗi | có kiểu, từ HTTP status và decoder code | phỏng đoán, từ chuỗi mô tả |
| Live edge khi resume | có | quay về đầu item |

Lệnh cho capability mà host không làm được là **no-op có tài liệu**, không phải exception. Vì vậy:

```dart
if (uiState.settings.isAvailable) PlayerIconButton(/* settings */),
```

`PlayerSettingsUiState.from` kiểm tra `capabilities` **trước** rồi mới đến danh sách rendition, nên
trên Tizen nút settings không xuất hiện, thay vì mở ra một panel rỗng.

Ba lựa chọn khác đều tệ hơn: *throw* làm app crash lần đầu ai đó mở settings trên Tizen; *im lặng
no-op* làm menu hiện ra, người xem chọn 1080p, không có gì xảy ra và không phân biệt được với bug.

## 7. Về `video_player_tizen`: đủ dùng chưa, hay cần viết plugin riêng?

**Bắt đầu bằng `video_player_tizen`.** Nó do chính đội flutter-tizen viết và bảo trì, dùng player API
của Tizen, và nó đủ để chứng minh *hợp đồng* chạy được: play, pause, seek, tốc độ, HLS, progress.
Viết plugin C++ riêng ngay từ đầu là vài nghìn dòng chỉ kiểm chứng được trên TV Samsung thật — và cái
được kiểm chứng khi đó là "lần đầu viết media C++ trên Tizen", chứ không phải kiến trúc.

**Đổi sang plugin riêng khi cần một trong các thứ sau**, vì `video_player` không mở ra:

- Chọn chất lượng / audio / phụ đề (rendition).
- DRM (khi đó nhìn sang `video_player_videohole`).
- 4K trên mặt phẳng video của phần cứng (video hole), thay vì decode ra texture.
- CSAI / quảng cáo.
- Live edge thật khi resume, và phân loại lỗi theo enum lỗi thật của Tizen.

**Việc phải làm khi đổi là có giới hạn**, vì seam đã có sẵn:

1. Viết plugin Tizen C++ nói đúng hợp đồng trong
   [`channel_contract.md`](../../flutter_stream_player/doc/channel_contract.md) — cùng hợp đồng mà
   Kotlin đang nói. Tên method, key tham số và payload event đều đã ghi ở đó.
2. Thay `StreamPlayerTizen` bằng một channel client cỡ bằng `StreamPlayerAndroid`.
3. Mở rộng `capabilities` theo từng feature plugin làm được.

**Không có gì phía trên `StreamPlayerPlatform` phải sửa** — kể cả `PlayerScreen`. Ba chỗ nên xoá đầu
tiên: `mapTizenPlaybackError`, `TizenPlayerSession._bufferedEndOf`, và nhánh `atDefaultPosition`
trong `_toggle`.

## 8. Kiểm tra

Đã chạy xanh trên Flutter 3.47.2 / Dart 3.13.2, JDK 21, AGP 9.3.2, Gradle 9.7.1.

```bash
# 1. Engine phải được publish trước, mọi thứ Android mới resolve được
cd ../android_stream_player && ./gradlew :stream-player:publishToMavenLocal

# 2. Package (71 test)
cd ../flutter_stream_player/packages/stream_player_platform_interface && flutter pub get && flutter analyze && flutter test
cd ../stream_player                                                   && flutter pub get && flutter analyze && flutter test
cd ../stream_player_tizen                                             && flutter pub get && flutter analyze && flutter test

# 3. App (81 test). build_runner là bắt buộc vì player dùng provider generated
cd ../../../flutter-steam-tv
flutter pub get
dart run build_runner build
dart format .
flutter analyze
flutter test

# 4. Kotlin (10 test) + build APK — đây mới là thứ chứng minh cả cầu nối compile được
cd android && ./gradlew :stream_player_android:testDebugUnitTest
cd .. && flutter build apk --debug --target-platform android-arm64
```

**Tizen chưa verify được end-to-end.** Phần Dart analyze sạch, test pass, compile được với
`video_player 2.14.0` — nhưng máy này chưa cài `flutter-tizen` lẫn Tizen SDK (dòng PATH trong
`.zshrc` trỏ tới thư mục không tồn tại), nên chưa có gì từng chạy trên TV thật.

Chạy trên thiết bị:

```bash
flutter run -d <android-tv-device>
flutter-tizen run -d <tizen-device>
```

Preview:

```bash
flutter widget-preview start
```

Năm preview của player nằm trong
[`player_screen_preview.dart`](../lib/features/player/presentation/view/player_screen_preview.dart):
playing, buffering, live, error, và 1080p. Surface trong preview là một khối màu — preview không được
gọi plugin native, và `PlayerScreen` nhận surface dưới dạng widget chính vì lý do đó.

### Test nào canh cái gì

| File | Canh |
|---|---|
| [`home_catalog_playback_repository_test.dart`](../test/features/player/data/repository/home_catalog_playback_repository_test.dart) | Resolve từ catalogue: video, channel (live), episode theo id riêng, series → episode 1, fallback trailer, và **một test đi hết catalogue thật của Home** để id lệch không thể xảy ra âm thầm nữa |
| [`player_view_model_test.dart`](../test/features/player/presentation/view_model/player_view_model_test.dart) | Cả luồng mở player với host giả: resolve → create → load/prepare/play, thứ tự "resolve trước create", gộp fact thành state, live resume ở live edge, và `close()` khi rời màn hình |
| [`player_focus_owner_test.dart`](../test/features/player/presentation/model/player_focus_owner_test.dart) | Thứ tự ưu tiên của người giữ focus |
| [`player_ui_state_test.dart`](../test/features/player/presentation/model/player_ui_state_test.dart) | Seekability, clamp position, copy lỗi, suy ra menu cài đặt |
| [`player_screen_test.dart`](../test/features/player/presentation/view/player_screen_test.dart) | Điều khiển bằng remote: hiện chrome, không kích hoạt control bằng chính phím mở, auto-hide, error panel |

## 9. Ba điểm nối dễ mất khi merge

Luồng mở player nằm ở ba file **không** thuộc feature `player`, nên một branch khác sửa cùng chỗ sẽ
lặng lẽ vô hiệu hoá nó — đã xảy ra một lần khi branch home-screen merge vào main:

| File | Dòng cần có | Mất thì sao |
|---|---|---|
| [`main.dart`](../lib/main.dart) | `registerStreamPlayerHost();` | `StreamPlayerController.create()` ném `StateError` ngay lần bấm play đầu tiên |
| [`app_router.dart`](../lib/app/router/app_router.dart) | `GoRoute(path: PlayerRoute.path, ...)` **ngoài** `ShellRoute` | `push('/player/...')` không match route nào |
| [`home_screen.dart`](../lib/features/home/presentation/view/home_screen.dart) | `onItemPressed: (item) => _play(context, item)` | Bấm item mở dialog/không làm gì thay vì mở player |

Sau mỗi lần merge có xung đột ở ba file này, cách kiểm nhanh nhất là chạy
`flutter test test/features/player/` rồi mở app bấm thử một item.
