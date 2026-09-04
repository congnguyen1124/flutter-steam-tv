import 'package:flutter/material.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_colors.dart';

abstract final class StreamTvTheme {
  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      primary: StreamTvColors.onSurface,
      onPrimary: StreamTvColors.background,
      surface: StreamTvColors.surface,
      onSurface: StreamTvColors.onSurface,
      error: StreamTvColors.error,
    );

    return ThemeData(
      brightness: .dark,
      colorScheme: colorScheme,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: StreamTvColors.background,
      useMaterial3: true,
      visualDensity: .standard,
    );
  }
}
