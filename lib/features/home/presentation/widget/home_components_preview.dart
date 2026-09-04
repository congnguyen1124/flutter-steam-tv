import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_theme.dart';
import 'package:flutter_steam_tv/features/home/domain/model/home_item.dart';
import 'package:flutter_steam_tv/features/home/domain/model/home_section.dart';
import 'package:flutter_steam_tv/features/home/presentation/widget/home_section_row.dart';
import 'package:flutter_steam_tv/features/home/presentation/widget/home_vertical_banner_section.dart';

@Preview(name: 'Home - vertical banner', size: Size(1280, 720))
Widget homeVerticalBannerPreview() => const _VerticalBannerPreview();

@Preview(name: 'Home - ranked row', size: Size(1280, 720))
Widget homeRankedRowPreview() => const _RankedRowPreview();

final class _VerticalBannerPreview extends StatefulWidget {
  const _VerticalBannerPreview();

  @override
  State<_VerticalBannerPreview> createState() => _VerticalBannerPreviewState();
}

final class _VerticalBannerPreviewState extends State<_VerticalBannerPreview> {
  late final FocusNode _focusNode = FocusNode(
    debugLabel: 'preview-vertical-banner',
  );

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: StreamTvTheme.dark,
      home: Scaffold(
        body: Center(
          child: HomeVerticalBannerSection(
            items: _portraitItems,
            focusNode: _focusNode,
            initialSelectedIndex: 3,
            autofocus: true,
            autoPlay: false,
            onFocused: () {},
            onSelectedIndexChanged: (_) {},
            onItemPressed: (_) {},
          ),
        ),
      ),
    );
  }
}

final class _RankedRowPreview extends StatefulWidget {
  const _RankedRowPreview();

  @override
  State<_RankedRowPreview> createState() => _RankedRowPreviewState();
}

final class _RankedRowPreviewState extends State<_RankedRowPreview> {
  late final FocusNode _focusNode = FocusNode(debugLabel: 'preview-ranked-row');

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: StreamTvTheme.dark,
      home: Scaffold(
        body: Center(
          child: HomeSectionRow(
            section: const HomeSection(
              id: 'preview-popular',
              title: 'Popular videos',
              viewType: .videosPopular,
              items: _landscapeItems,
            ),
            focusNode: _focusNode,
            initialSelectedIndex: 0,
            autofocus: true,
            onFocused: () {},
            onSelectedIndexChanged: (_) {},
            onItemPressed: (_) {},
          ),
        ),
      ),
    );
  }
}

const _portraitItems = [
  HomeItem(
    id: 'portrait-1',
    title: 'Quiet focus',
    description: 'A portrait story framed for the living room.',
    kind: .short,
    ageRestriction: 'P',
  ),
  HomeItem(
    id: 'portrait-2',
    title: 'Festival light',
    description: 'Tradition and color move through the city.',
    kind: .short,
    ageRestriction: 'P',
  ),
  HomeItem(
    id: 'portrait-3',
    title: 'Above the rim',
    description: 'A split-second contest at full speed.',
    kind: .short,
    ageRestriction: 'P',
  ),
  HomeItem(
    id: 'portrait-4',
    title: 'The wild gaze',
    description: 'A close portrait captures a quiet moment.',
    kind: .short,
    ageRestriction: 'T13',
  ),
  HomeItem(
    id: 'portrait-5',
    title: 'Motion on the pitch',
    description: 'One decisive touch changes the match.',
    kind: .short,
    ageRestriction: 'P',
  ),
  HomeItem(
    id: 'portrait-6',
    title: 'Old city walk',
    description: 'Every corner holds a new story.',
    kind: .short,
    ageRestriction: 'P',
  ),
];

const _landscapeItems = [
  HomeItem(
    id: 'video-1',
    title: 'Pulse of the court',
    description: 'Speed and focus under pressure.',
    kind: .video,
    ageRestriction: 'P',
  ),
  HomeItem(
    id: 'video-2',
    title: 'The wild frontier',
    description: 'A journey through hidden landscapes.',
    kind: .video,
    ageRestriction: 'T13',
  ),
  HomeItem(
    id: 'video-3',
    title: 'Tradition in motion',
    description: 'Old rituals meet a modern city.',
    kind: .video,
    ageRestriction: 'P',
  ),
  HomeItem(
    id: 'video-4',
    title: 'Opening night',
    description: 'Live from the main arena.',
    kind: .video,
    ageRestriction: 'P',
  ),
];
