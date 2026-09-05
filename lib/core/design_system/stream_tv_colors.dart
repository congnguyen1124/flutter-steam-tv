import 'package:flutter/material.dart';

abstract final class StreamTvColors {
  static const Color background = Color(0xFF090B0E);
  static const Color surface = Color(0xFF18171D);
  static const Color surfaceContainer = Color(0xFF242129);
  static const Color surfaceFocused = Color(0xFFF4F5F7);
  static const Color onSurface = Color(0xFFF4F5F7);
  static const Color onSurfaceMuted = Color(0xFFB8B2BF);
  static const Color primary = Color(0xFFD9B8FF);
  static const Color onPrimary = Color(0xFF35124F);
  static const Color primaryContainer = Color(0xFF603D78);
  static const Color onPrimaryContainer = Color(0xFFF3E5FF);
  static const Color secondary = Color(0xFFA8D8CC);
  static const Color onSecondary = Color(0xFF0D3931);
  static const Color error = Color(0xFFFF6B6B);
  static const Color live = Color(0xFFE33D4E);
  static const Color blue = Color(0xFF275D8C);
  static const Color green = Color(0xFF326B57);
  static const Color red = Color(0xFF783B48);
  static const Color gold = Color(0xFF77632E);

  // region Player chrome
  //
  // Their own group, and mostly not surface colours, because the player draws on top of video
  // rather than on `background`: every one of these is either pure black/white or a translucency
  // over the frame, and reusing a surface colour here would tint the picture.

  /// Behind the video, and the shutter before the first frame.
  static const Color playerBackground = Color(0xFF000000);

  /// Focused control fill, and the seek thumb.
  static const Color playerForeground = Color(0xFFFFFFFF);

  /// Body copy on the player: pure white would fight the picture behind it.
  static const Color playerMutedForeground = Color(0xFFECECEC);

  /// The played portion of the seek bar.
  ///
  /// Aliases [primary] rather than pinning its own value, so the player follows the app's accent
  /// when the design system moves. The Compose reference hardcodes its own blue here; that would
  /// leave the Flutter player showing an accent no other screen uses.
  static const Color playerAccent = primary;

  /// Idle control fill.
  static const Color playerControlIdle = Color(0x1AFFFFFF);

  /// The unplayed seek track.
  static const Color playerTrackIdle = Color(0x33FFFFFF);

  /// The buffered-ahead portion of the seek bar.
  static const Color playerTrackBuffered = Color(0x66FFFFFF);

  /// Top of the controller scrim, so the title stays legible over a bright frame.
  static const Color playerScrimTop = Color(0x99000000);

  /// Bottom of the controller scrim, which carries denser chrome and so needs more cover.
  static const Color playerScrimBottom = Color(0xCC000000);

  /// The settings panel, which sits over video and must not be readable through.
  static const Color playerPanel = Color(0xF2101418);
  // endregion
}
