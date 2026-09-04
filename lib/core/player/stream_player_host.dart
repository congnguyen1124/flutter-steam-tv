import 'dart:io';

import 'package:stream_player/stream_player.dart';
import 'package:stream_player_android/stream_player_android.dart';
import 'package:stream_player_tizen/stream_player_tizen.dart';

/// Registers the native player host for this platform, before the first player is created.
///
/// ## Why the app owns this
///
/// Only the app knows which platforms it ships, and the two hosts register differently:
///
/// - **Android's** is a real plugin. Its Kotlin half is registered by the generated plugin
///   registrant, and its Dart half declares `dartPluginClass`, so it may already be registered by
///   the time `main` runs — hence the [StreamPlayerPlatform.isRegistered] guard.
/// - **Tizen's** is pure Dart: it adapts `video_player_tizen` rather than owning a native plugin,
///   so nothing can register it automatically.
///
/// ## Why the platform is named explicitly
///
/// Registering "whatever has not claimed the seam yet" would look tidier, and it would be wrong: if
/// Android's Dart registrant ever failed to run, that version would silently install the *Tizen*
/// host on Android — where `video_player` genuinely works, but with only basic capabilities. The app
/// would keep playing video and quietly lose quality selection, and nothing would say why.
///
/// Naming the platform makes that failure impossible. A host that is missing is a loud
/// [StateError] with the fix in its message, which is the outcome worth having.
///
/// Idempotent, so a hot restart re-running `main` is harmless.
///
/// See `../../../flutter_stream_player/architecture.md`, "Registration".
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
