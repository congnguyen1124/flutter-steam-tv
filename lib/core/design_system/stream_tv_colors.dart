import 'package:flutter/material.dart';

abstract final class StreamTvColors {
  static const Color background = Color(0xFF090B0E);
  static const Color surface = Color(0xFF171A1F);
  static const Color surfaceFocused = Color(0xFFF4F5F7);
  static const Color onSurface = Color(0xFFF4F5F7);
  static const Color onSurfaceMuted = Color(0xFFAEB4BE);
  static const Color error = Color(0xFFFF6B6B);
  static const Color live = Color(0xFFE33D4E);
  static const Color blue = Color(0xFF275D8C);
  static const Color green = Color(0xFF326B57);
  static const Color red = Color(0xFF783B48);
  static const Color gold = Color(0xFF77632E);

  // region Player chrome
  //
  // Kept as their own group, and matching the Compose app's token names, because the player draws
  // on top of video rather than on `background`: every one of these is either pure black/white or a
  // translucency over the frame, and reusing a surface colour here would tint the picture.

  /// Behind the video, and the shutter before the first frame.
  static const Color playerBackground = Color(0xFF000000);

  /// Focused control fill, and the seek thumb.
  static const Color playerForeground = Color(0xFFFFFFFF);

  /// Body copy on the player: white would fight the picture behind it.
  static const Color playerMutedForeground = Color(0xFFECECEC);

  /// The played portion of the seek bar.
  static const Color playerAccent = Color(0xFF9AC6F1);

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

  /// The settings panel, which sits over video and must not be transparent enough to read through.
  static const Color playerPanel = Color(0xF2101418);
  // endregion
}
