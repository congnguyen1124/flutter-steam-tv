import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_steam_tv/core/widgets/list_content_view/list_content_view.dart';
import 'package:flutter_steam_tv/features/home/domain/model/home_item.dart';
import 'package:flutter_steam_tv/features/home/domain/model/home_section.dart';
import 'package:flutter_steam_tv/features/home/presentation/widget/home_content_card.dart';

final class HomeSectionRow extends StatelessWidget {
  const HomeSectionRow({
    required this.section,
    required this.focusNode,
    required this.initialSelectedIndex,
    required this.autofocus,
    required this.onFocused,
    required this.onSelectedIndexChanged,
    required this.onItemPressed,
    super.key,
  });

  final HomeSection section;
  final FocusNode focusNode;
  final int initialSelectedIndex;
  final bool autofocus;
  final VoidCallback onFocused;
  final ValueChanged<int> onSelectedIndexChanged;
  final ValueChanged<HomeItem> onItemPressed;

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(section.viewType);

    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = _HomeRowLayout.forViewport(
          style: style,
          viewportWidth: constraints.maxWidth,
        );
        return Column(
          crossAxisAlignment: .start,
          children: [
            Padding(
              padding: const .symmetric(horizontal: 48),
              child: Text(
                section.title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: .w500),
              ),
            ),
            const SizedBox(height: 12),
            ListContentView.separated(
              key: ValueKey('home-list-content-${section.id}'),
              itemCount: section.items.length,
              focusNode: focusNode,
              autofocus: autofocus,
              itemWidth: layout.metrics.itemWidth,
              itemHeight: layout.metrics.itemHeight,
              selectionLeadingInset: layout.metrics.contentLeadingInset,
              selectionWidth: layout.metrics.cardWidth,
              selectionHeight: layout.metrics.thumbnailHeight,
              separatorExtent: layout.separatorExtent,
              separatorBuilder: (_, _) => const SizedBox.shrink(),
              initialSelectedIndex: initialSelectedIndex,
              loopingEnabled: !style.isRanked,
              semanticLabelBuilder: (index) => section.items[index].title,
              onFocusChanged: (hasFocus) {
                if (hasFocus) {
                  onFocused();
                }
              },
              onSelectedIndexChanged: onSelectedIndexChanged,
              onSelectedItemPressed: (index) {
                onItemPressed(section.items[index]);
              },
              itemBuilder: (context, index, isSelected) {
                final item = section.items[index];
                return HomeContentCard(
                  key: ValueKey('home-content-${item.id}'),
                  item: item,
                  style: style,
                  metrics: layout.metrics,
                  isSelected: isSelected,
                  rank: style.isRanked ? index + 1 : null,
                );
              },
            ),
          ],
        );
      },
    );
  }

  HomeContentCardStyle _styleFor(HomeSectionViewType viewType) {
    return switch (viewType) {
      .videos => .video,
      .videosPopular => .popularVideo,
      .listSeries => .series,
      .channels => .channel,
      .shorts => .short,
      .shortPopular => .popularShort,
      .banner ||
      .verticalBanner => throw StateError('$viewType is not a content row'),
    };
  }
}

final class _HomeRowLayout {
  const _HomeRowLayout({required this.metrics, required this.separatorExtent});

  factory _HomeRowLayout.forViewport({
    required HomeContentCardStyle style,
    required double viewportWidth,
  }) {
    const leadingInset = 48.0;
    final isShort =
        style == HomeContentCardStyle.short ||
        style == HomeContentCardStyle.popularShort;
    final visibleItemCount = switch ((style.isRanked, isShort)) {
      (true, true) => 5.0,
      (true, false) => 4.0,
      (false, true) => 6.5,
      (false, false) => 5.5,
    };
    final separatorExtent = switch ((style.isRanked, isShort)) {
      (true, true) => 12.0,
      (true, false) => 16.0,
      (false, true) => 10.0,
      (false, false) => 12.0,
    };
    final visibleSeparatorCount = visibleItemCount == visibleItemCount.floor()
        ? visibleItemCount.toInt() - 1
        : visibleItemCount.floor();
    final availableWidth = math.max(viewportWidth - leadingInset, 1.0);
    final calculatedItemWidth =
        (availableWidth - separatorExtent * visibleSeparatorCount) /
        visibleItemCount;
    final minimumWidth = isShort ? 88.0 : 112.0;
    final itemWidth = math.max(calculatedItemWidth, minimumWidth);

    return _HomeRowLayout(
      metrics: HomeContentCardMetrics.fromItemWidth(
        style: style,
        itemWidth: itemWidth,
      ),
      separatorExtent: separatorExtent,
    );
  }

  final HomeContentCardMetrics metrics;
  final double separatorExtent;
}
