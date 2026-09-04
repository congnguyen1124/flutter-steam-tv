import 'package:flutter/material.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_colors.dart';

abstract final class StreamTvTheme {
  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      primary: StreamTvColors.primary,
      onPrimary: StreamTvColors.onPrimary,
      primaryContainer: StreamTvColors.primaryContainer,
      onPrimaryContainer: StreamTvColors.onPrimaryContainer,
      secondary: StreamTvColors.secondary,
      onSecondary: StreamTvColors.onSecondary,
      surface: StreamTvColors.surface,
      onSurface: StreamTvColors.onSurface,
      error: StreamTvColors.error,
    );

    return ThemeData(
      brightness: .dark,
      colorScheme: colorScheme,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: StreamTvColors.background,
      focusColor: StreamTvColors.primary,
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: StreamTvColors.primary,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: StreamTvColors.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: StreamTvColors.primary),
      ),
      useMaterial3: true,
      visualDensity: .standard,
    );
  }
}
