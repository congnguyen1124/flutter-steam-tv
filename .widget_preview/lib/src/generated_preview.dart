// ignore_for_file: implementation_imports

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:ui' as _i1;
import 'package:flutter/src/widget_previews/widget_previews.dart' as _i2;
import 'widget_preview.dart' as _i3;
import 'utils.dart' as _i4;
import 'package:flutter_steam_tv/core/widgets/steam_top_bar_preview.dart'
    as _i5;

List<_i3.WidgetPreview> previews() => [
  _i4.buildWidgetPreview(
    packageName: 'flutter_steam_tv',
    scriptUri:
        'file:///home/congnguyencn/CN_Develop/flutter_steam_tv/lib/core/widgets/steam_top_bar_preview.dart',
    line: 8,
    column: 1,
    previewFunction: () => _i5.steamTopBarPreview(),
    transformedPreview:
        _i2.Preview(
          group: 'Core design system',
          name: 'Steam top bar',
          size: _i1.Size(1280.0, 720.0),
        ).transform(),
  ),
  _i4.buildWidgetPreviewError(
    packageName: 'flutter_steam_tv',
    scriptUri:
        'file:///home/congnguyencn/CN_Develop/flutter_steam_tv/lib/features/home/presentation/view/home_screen_preview.dart',
    line: 11,
    column: 1,
    packageUri:
        'package:flutter_steam_tv/features/home/presentation/view/home_screen_preview.dart',
    functionName: 'homeContentPreview',
    dependencyHasErrors: true,
  ),
  _i4.buildWidgetPreviewError(
    packageName: 'flutter_steam_tv',
    scriptUri:
        'file:///home/congnguyencn/CN_Develop/flutter_steam_tv/lib/features/home/presentation/view/home_screen_preview.dart',
    line: 14,
    column: 1,
    packageUri:
        'package:flutter_steam_tv/features/home/presentation/view/home_screen_preview.dart',
    functionName: 'homeLoadingPreview',
    dependencyHasErrors: true,
  ),
  _i4.buildWidgetPreviewError(
    packageName: 'flutter_steam_tv',
    scriptUri:
        'file:///home/congnguyencn/CN_Develop/flutter_steam_tv/lib/features/home/presentation/view/home_screen_preview.dart',
    line: 17,
    column: 1,
    packageUri:
        'package:flutter_steam_tv/features/home/presentation/view/home_screen_preview.dart',
    functionName: 'homeErrorPreview',
    dependencyHasErrors: true,
  ),
  _i4.buildWidgetPreviewError(
    packageName: 'flutter_steam_tv',
    scriptUri:
        'file:///home/congnguyencn/CN_Develop/flutter_steam_tv/lib/features/main/presentation/view/main_screen_preview.dart',
    line: 10,
    column: 1,
    packageUri:
        'package:flutter_steam_tv/features/main/presentation/view/main_screen_preview.dart',
    functionName: 'mainSearchPreview',
    dependencyHasErrors: true,
  ),
  _i4.buildWidgetPreviewError(
    packageName: 'flutter_steam_tv',
    scriptUri:
        'file:///home/congnguyencn/CN_Develop/flutter_steam_tv/lib/features/main/presentation/view/main_screen_preview.dart',
    line: 19,
    column: 1,
    packageUri:
        'package:flutter_steam_tv/features/main/presentation/view/main_screen_preview.dart',
    functionName: 'mainProfilePreview',
    dependencyHasErrors: true,
  ),
];
