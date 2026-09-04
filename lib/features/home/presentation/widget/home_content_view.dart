import 'package:flutter/material.dart';
import 'package:flutter_steam_tv/core/widgets/steam_top_bar.dart';
import 'package:flutter_steam_tv/core/widgets/tv_list_view/tv_list_view.dart';
import 'package:flutter_steam_tv/features/home/domain/model/home_item.dart';
import 'package:flutter_steam_tv/features/home/domain/model/home_section.dart';
import 'package:flutter_steam_tv/features/home/presentation/widget/home_hero_section.dart';
import 'package:flutter_steam_tv/features/home/presentation/widget/home_section_row.dart';
import 'package:flutter_steam_tv/features/home/presentation/widget/home_vertical_banner_section.dart';

final class HomeContentView extends StatefulWidget {
  const HomeContentView({
    required this.sections,
    required this.autofocusContent,
    required this.onItemPressed,
    this.autoPlayBanners = true,
    super.key,
  });

  final List<HomeSection> sections;
  final bool autofocusContent;
  final ValueChanged<HomeItem> onItemPressed;
  final bool autoPlayBanners;

  @override
  State<HomeContentView> createState() => _HomeContentViewState();
}

final class _HomeContentViewState extends State<HomeContentView> {
  static const double _sectionSpacing = 34;
  static const double _bottomPadding = 54;

  late final Map<String, FocusNode> _sectionFocusNodes = {};
  final Map<String, int> _selectedIndices = {};
  int _focusedSectionIndex = 0;

  @override
  void initState() {
    super.initState();
    _syncFocusNodes();
  }

  @override
  void didUpdateWidget(HomeContentView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncFocusNodes();
    if (widget.sections.isNotEmpty) {
      _focusedSectionIndex = _focusedSectionIndex.clamp(
        0,
        widget.sections.length - 1,
      );
    }
  }

  @override
  void dispose() {
    for (final node in _sectionFocusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.sections.isEmpty) {
      return const Center(child: Text('No content is available yet'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final firstSection = widget.sections.first;
        final topPadding = firstSection.viewType.isBanner
            ? 0.0
            : SteamTopBar.height;
        final heroHeight = (constraints.maxHeight - 124).clamp(320.0, 600.0);

        return FocusTraversalGroup(
          policy: OrderedTraversalPolicy(),
          child: TvListView.separated(
            key: const ValueKey('home-section-list'),
            padding: .only(top: topPadding, bottom: _bottomPadding),
            scrollCacheExtent: .pixels(constraints.maxHeight),
            itemCount: widget.sections.length,
            onFocusedItemChanged: (index) => _focusedSectionIndex = index,
            separatorBuilder: (_, _) => const SizedBox(height: _sectionSpacing),
            itemBuilder: (context, index) {
              final section = widget.sections[index];
              return FocusTraversalOrder(
                order: NumericFocusOrder(index.toDouble()),
                child: _buildSection(
                  section: section,
                  sectionIndex: index,
                  heroHeight: heroHeight,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSection({
    required HomeSection section,
    required int sectionIndex,
    required double heroHeight,
  }) {
    final focusNode = _sectionFocusNodes[section.id]!;
    final defaultSelectedIndex = section.viewType == .verticalBanner
        ? section.items.length ~/ 2
        : 0;
    final initialSelectedIndex =
        (_selectedIndices[section.id] ?? defaultSelectedIndex).clamp(
          0,
          section.items.length - 1,
        );
    final autofocus = widget.autofocusContent && sectionIndex == 0;
    void onFocused() => _focusedSectionIndex = sectionIndex;

    void onSelectedIndexChanged(int index) {
      _selectedIndices[section.id] = index;
    }

    return switch (section.viewType) {
      .banner => HomeHeroSection(
        items: section.items,
        height: heroHeight,
        focusNode: focusNode,
        initialSelectedIndex: initialSelectedIndex,
        autofocus: autofocus,
        autoPlay: widget.autoPlayBanners,
        onFocused: onFocused,
        onSelectedIndexChanged: onSelectedIndexChanged,
        onItemPressed: widget.onItemPressed,
      ),
      .verticalBanner => HomeVerticalBannerSection(
        items: section.items,
        focusNode: focusNode,
        initialSelectedIndex: initialSelectedIndex,
        autofocus: autofocus,
        autoPlay: widget.autoPlayBanners,
        onFocused: onFocused,
        onSelectedIndexChanged: onSelectedIndexChanged,
        onItemPressed: widget.onItemPressed,
      ),
      _ => HomeSectionRow(
        section: section,
        focusNode: focusNode,
        initialSelectedIndex: initialSelectedIndex,
        autofocus: autofocus,
        onFocused: onFocused,
        onSelectedIndexChanged: onSelectedIndexChanged,
        onItemPressed: widget.onItemPressed,
      ),
    };
  }

  void _syncFocusNodes() {
    final sectionIds = widget.sections.map((section) => section.id).toSet();
    final removedIds = _sectionFocusNodes.keys
        .where((id) => !sectionIds.contains(id))
        .toList(growable: false);
    for (final id in removedIds) {
      _sectionFocusNodes.remove(id)?.dispose();
      _selectedIndices.remove(id);
    }
    for (final section in widget.sections) {
      _sectionFocusNodes.putIfAbsent(
        section.id,
        () => FocusNode(debugLabel: 'home-section:${section.id}'),
      );
    }
  }
}
