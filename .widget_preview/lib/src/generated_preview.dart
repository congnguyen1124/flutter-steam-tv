// ignore_for_file: implementation_imports

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:ui' as _i1;
import 'package:flutter/src/widget_previews/widget_previews.dart' as _i2;
import 'widget_preview.dart' as _i3;
import 'utils.dart' as _i4;
import 'package:flutter_steam_tv/core/widgets/list_content_view/list_content_view_preview.dart'
    as _i5;
import 'package:flutter_steam_tv/core/widgets/steam_top_bar_preview.dart'
    as _i6;
import 'package:flutter_steam_tv/core/widgets/tv_list_view/tv_list_view_preview.dart'
    as _i7;
import 'package:flutter_steam_tv/features/home/presentation/view/home_screen_preview.dart'
    as _i8;
import 'package:flutter_steam_tv/features/home/presentation/widget/home_components_preview.dart'
    as _i9;
import 'package:flutter_steam_tv/features/main/presentation/view/main_screen_preview.dart'
    as _i10;
import 'package:flutter_steam_tv/features/player/presentation/view/player_screen_preview.dart'
    as _i11;

List<_i3.WidgetPreview> previews() => [
  _i4.buildWidgetPreview(
    packageName: 'flutter_steam_tv',
    scriptUri:
        'file:///home/congnguyencn/CN_Develop/flutter_steam_tv/lib/core/widgets/list_content_view/list_content_view_preview.dart',
    line: 6,
    column: 1,
    previewFunction: () => _i5.listContentViewPreview(),
    transformedPreview:
        _i2.Preview(
          name: 'List content - separated',
          size: _i1.Size(1280.0, 220.0),
        ).transform(),
  ),
  _i4.buildWidgetPreview(
    packageName: 'flutter_steam_tv',
    scriptUri:
        'file:///home/congnguyencn/CN_Develop/flutter_steam_tv/lib/core/widgets/steam_top_bar_preview.dart',
    line: 8,
    column: 1,
    previewFunction: () => _i6.steamTopBarPreview(),
    transformedPreview:
        _i2.Preview(
          group: 'Core design system',
          name: 'Steam top bar',
          size: _i1.Size(1280.0, 720.0),
        ).transform(),
  ),
  _i4.buildWidgetPreview(
    packageName: 'flutter_steam_tv',
    scriptUri:
        'file:///home/congnguyencn/CN_Develop/flutter_steam_tv/lib/core/widgets/tv_list_view/tv_list_view_preview.dart',
    line: 6,
    column: 1,
    previewFunction: () => _i7.tvListViewPreview(),
    transformedPreview:
        _i2.Preview(
          name: 'TV list - focus anchored',
          size: _i1.Size(640.0, 480.0),
        ).transform(),
  ),
  _i4.buildWidgetPreview(
    packageName: 'flutter_steam_tv',
    scriptUri:
        'file:///home/congnguyencn/CN_Develop/flutter_steam_tv/lib/features/home/presentation/view/home_screen_preview.dart',
    line: 10,
    column: 1,
    previewFunction: () => _i8.homeContentPreview(),
    transformedPreview:
        _i2.Preview(
          group: 'Home LCE',
          name: 'Home - content',
          size: _i1.Size(1280.0, 720.0),
        ).transform(),
  ),
  _i4.buildWidgetPreview(
    packageName: 'flutter_steam_tv',
    scriptUri:
        'file:///home/congnguyencn/CN_Develop/flutter_steam_tv/lib/features/home/presentation/view/home_screen_preview.dart',
    line: 13,
    column: 1,
    previewFunction: () => _i8.homeContent1080Preview(),
    transformedPreview:
        _i2.Preview(
          group: 'Home LCE',
          name: 'Home - 1080p',
          size: _i1.Size(1920.0, 1080.0),
        ).transform(),
  ),
  _i4.buildWidgetPreview(
    packageName: 'flutter_steam_tv',
    scriptUri:
        'file:///home/congnguyencn/CN_Develop/flutter_steam_tv/lib/features/home/presentation/view/home_screen_preview.dart',
    line: 16,
    column: 1,
    previewFunction: () => _i8.homeLoadingPreview(),
    transformedPreview:
        _i2.Preview(
          group: 'Home LCE',
          name: 'Home - loading',
          size: _i1.Size(1280.0, 720.0),
        ).transform(),
  ),
  _i4.buildWidgetPreview(
    packageName: 'flutter_steam_tv',
    scriptUri:
        'file:///home/congnguyencn/CN_Develop/flutter_steam_tv/lib/features/home/presentation/view/home_screen_preview.dart',
    line: 19,
    column: 1,
    previewFunction: () => _i8.homeErrorPreview(),
    transformedPreview:
        _i2.Preview(
          group: 'Home LCE',
          name: 'Home - error',
          size: _i1.Size(1280.0, 720.0),
        ).transform(),
  ),
  _i4.buildWidgetPreview(
    packageName: 'flutter_steam_tv',
    scriptUri:
        'file:///home/congnguyencn/CN_Develop/flutter_steam_tv/lib/features/home/presentation/widget/home_components_preview.dart',
    line: 9,
    column: 1,
    previewFunction: () => _i9.homeVerticalBannerPreview(),
    transformedPreview:
        _i2.Preview(
          name: 'Home - vertical banner',
          size: _i1.Size(1280.0, 720.0),
        ).transform(),
  ),
  _i4.buildWidgetPreview(
    packageName: 'flutter_steam_tv',
    scriptUri:
        'file:///home/congnguyencn/CN_Develop/flutter_steam_tv/lib/features/home/presentation/widget/home_components_preview.dart',
    line: 12,
    column: 1,
    previewFunction: () => _i9.homeRankedRowPreview(),
    transformedPreview:
        _i2.Preview(
          name: 'Home - ranked row',
          size: _i1.Size(1280.0, 720.0),
        ).transform(),
  ),
  _i4.buildWidgetPreview(
    packageName: 'flutter_steam_tv',
    scriptUri:
        'file:///home/congnguyencn/CN_Develop/flutter_steam_tv/lib/features/main/presentation/view/main_screen_preview.dart',
    line: 11,
    column: 1,
    previewFunction: () => _i10.mainSearchPreview(),
    transformedPreview:
        _i2.Preview(
          group: 'Main navigation',
          name: 'Main shell - search',
          size: _i1.Size(1280.0, 720.0),
        ).transform(),
  ),
  _i4.buildWidgetPreview(
    packageName: 'flutter_steam_tv',
    scriptUri:
        'file:///home/congnguyencn/CN_Develop/flutter_steam_tv/lib/features/main/presentation/view/main_screen_preview.dart',
    line: 23,
    column: 1,
    previewFunction: () => _i10.mainProfilePreview(),
    transformedPreview:
        _i2.Preview(
          group: 'Main navigation',
          name: 'Main shell - profile',
          size: _i1.Size(1280.0, 720.0),
        ).transform(),
  ),
  _i4.buildWidgetPreview(
    packageName: 'flutter_steam_tv',
    scriptUri:
        'file:///home/congnguyencn/CN_Develop/flutter_steam_tv/lib/features/player/presentation/view/player_screen_preview.dart',
    line: 16,
    column: 1,
    previewFunction: () => _i11.playerPlayingPreview(),
    transformedPreview:
        _i2.Preview(
          group: 'Player',
          name: 'Player - playing',
          size: _i1.Size(1280.0, 720.0),
        ).transform(),
  ),
  _i4.buildWidgetPreview(
    packageName: 'flutter_steam_tv',
    scriptUri:
        'file:///home/congnguyencn/CN_Develop/flutter_steam_tv/lib/features/player/presentation/view/player_screen_preview.dart',
    line: 19,
    column: 1,
    previewFunction: () => _i11.playerBufferingPreview(),
    transformedPreview:
        _i2.Preview(
          group: 'Player',
          name: 'Player - buffering',
          size: _i1.Size(1280.0, 720.0),
        ).transform(),
  ),
  _i4.buildWidgetPreview(
    packageName: 'flutter_steam_tv',
    scriptUri:
        'file:///home/congnguyencn/CN_Develop/flutter_steam_tv/lib/features/player/presentation/view/player_screen_preview.dart',
    line: 22,
    column: 1,
    previewFunction: () => _i11.playerLivePreview(),
    transformedPreview:
        _i2.Preview(
          group: 'Player',
          name: 'Player - live',
          size: _i1.Size(1280.0, 720.0),
        ).transform(),
  ),
  _i4.buildWidgetPreview(
    packageName: 'flutter_steam_tv',
    scriptUri:
        'file:///home/congnguyencn/CN_Develop/flutter_steam_tv/lib/features/player/presentation/view/player_screen_preview.dart',
    line: 25,
    column: 1,
    previewFunction: () => _i11.playerErrorPreview(),
    transformedPreview:
        _i2.Preview(
          group: 'Player',
          name: 'Player - error',
          size: _i1.Size(1280.0, 720.0),
        ).transform(),
  ),
  _i4.buildWidgetPreview(
    packageName: 'flutter_steam_tv',
    scriptUri:
        'file:///home/congnguyencn/CN_Develop/flutter_steam_tv/lib/features/player/presentation/view/player_screen_preview.dart',
    line: 30,
    column: 1,
    previewFunction: () => _i11.playerPlayingFullHdPreview(),
    transformedPreview:
        _i2.Preview(
          group: 'Player',
          name: 'Player - playing 1080p',
          size: _i1.Size(1920.0, 1080.0),
        ).transform(),
  ),
];
