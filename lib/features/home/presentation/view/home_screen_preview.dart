import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_theme.dart';
import 'package:flutter_steam_tv/features/home/domain/model/home_item.dart';
import 'package:flutter_steam_tv/features/home/domain/model/home_section.dart';
import 'package:flutter_steam_tv/features/home/presentation/view/home_screen.dart';
import 'package:flutter_steam_tv/features/main/presentation/view/main_screen.dart';

@Preview(name: 'Home - content', group: 'Home LCE', size: Size(1280, 720))
Widget homeContentPreview() => _preview(const .data(_previewSections));

@Preview(name: 'Home - 1080p', group: 'Home LCE', size: Size(1920, 1080))
Widget homeContent1080Preview() => _preview(const .data(_previewSections));

@Preview(name: 'Home - loading', group: 'Home LCE', size: Size(1280, 720))
Widget homeLoadingPreview() => _preview(const .loading());

@Preview(name: 'Home - error', group: 'Home LCE', size: Size(1280, 720))
Widget homeErrorPreview() {
  return _preview(
    AsyncValue.error(
      StateError('Unable to load Home content'),
      StackTrace.empty,
    ),
  );
}

Widget _preview(AsyncValue<List<HomeSection>> state) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: StreamTvTheme.dark,
    home: MainScreen(
      currentPath: HomeScreen.path,
      onNavigate: (_) {},
      contentBehindTopBar: true,
      child: HomeLceView(
        state: state,
        onRetry: () {},
        onItemPressed: (_) {},
        autoPlayBanners: false,
      ),
    ),
  );
}

const _previewSections = [
  HomeSection(
    id: 'featured',
    title: 'Featured today',
    viewType: .banner,
    items: [
      HomeItem(
        id: 'opening-night',
        title: 'Opening Night',
        description: 'Live coverage from the main arena',
        kind: .video,
      ),
      HomeItem(
        id: 'wild-frontier',
        title: 'Wild Frontier',
        description: 'A journey into untouched landscapes',
        kind: .video,
      ),
      HomeItem(
        id: 'after-the-storm',
        title: 'After the Storm',
        description: 'Stories of recovery and resilience',
        kind: .video,
      ),
    ],
  ),
  HomeSection(
    id: 'for-you',
    title: 'Videos for you',
    viewType: .videos,
    items: [
      HomeItem(
        id: 'city-lines',
        title: 'City Lines',
        description: 'Architecture after dark',
        kind: .video,
      ),
      HomeItem(
        id: 'field-notes',
        title: 'Field Notes',
        description: 'Short stories from the road',
        kind: .video,
      ),
    ],
  ),
];
