import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_steam_tv/core/assets/app_assets.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_colors.dart';
import 'package:flutter_steam_tv/features/home/domain/model/home_item.dart';
import 'package:flutter_steam_tv/features/home/presentation/widget/home_network_image.dart';

enum HomeContentCardStyle {
  video(aspectRatio: 16 / 9, detailHeight: 46),
  popularVideo(aspectRatio: 16 / 9, detailHeight: 46, isRanked: true),
  series(aspectRatio: 16 / 9, detailHeight: 46),
  channel(aspectRatio: 16 / 9, detailHeight: 46),
  short(aspectRatio: 2 / 3, detailHeight: 64, descriptionMaxLines: 2),
  popularShort(
    aspectRatio: 2 / 3,
    detailHeight: 64,
    descriptionMaxLines: 2,
    isRanked: true,
  );

  const HomeContentCardStyle({
    required this.aspectRatio,
    required this.detailHeight,
    this.descriptionMaxLines = 1,
    this.isRanked = false,
  });

  final double aspectRatio;
  final double detailHeight;
  final int descriptionMaxLines;
  final bool isRanked;
}

final class HomeContentCardMetrics {
  const HomeContentCardMetrics({
    required this.itemWidth,
    required this.contentLeadingInset,
    required this.cardWidth,
    required this.thumbnailHeight,
    required this.itemHeight,
    required this.rankArtworkHeight,
    required this.rankOverlap,
  });

  factory HomeContentCardMetrics.fromItemWidth({
    required HomeContentCardStyle style,
    required double itemWidth,
  }) {
    final isPortrait = style.aspectRatio < 1;
    final contentLeadingInset = style.isRanked
        ? itemWidth * (isPortrait ? 0.31 : 0.24)
        : 0.0;
    final cardWidth = itemWidth - contentLeadingInset;
    final thumbnailHeight = cardWidth / style.aspectRatio;
    final rankArtworkHeight = style.isRanked
        ? math.min(132.0, thumbnailHeight * (isPortrait ? 0.34 : 0.60))
        : 0.0;
    final rankOverlap = style.isRanked
        ? (rankArtworkHeight * 0.10).clamp(10.0, 16.0)
        : 0.0;
    return HomeContentCardMetrics(
      itemWidth: itemWidth,
      contentLeadingInset: contentLeadingInset,
      cardWidth: cardWidth,
      thumbnailHeight: thumbnailHeight,
      itemHeight: thumbnailHeight + style.detailHeight,
      rankArtworkHeight: rankArtworkHeight,
      rankOverlap: rankOverlap,
    );
  }

  final double itemWidth;
  final double contentLeadingInset;
  final double cardWidth;
  final double thumbnailHeight;
  final double itemHeight;
  final double rankArtworkHeight;
  final double rankOverlap;
}

final class HomeContentCard extends StatelessWidget {
  const HomeContentCard({
    required this.item,
    required this.style,
    required this.metrics,
    required this.isSelected,
    this.rank,
    super.key,
  });

  final HomeItem item;
  final HomeContentCardStyle style;
  final HomeContentCardMetrics metrics;
  final bool isSelected;
  final int? rank;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: metrics.itemWidth,
      height: metrics.itemHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (rank case final position?)
            Positioned(
              left: 0,
              top: (metrics.thumbnailHeight - metrics.rankArtworkHeight) / 2,
              width: metrics.contentLeadingInset + metrics.rankOverlap,
              height: metrics.rankArtworkHeight,
              child: FittedBox(
                alignment: .centerRight,
                fit: .fitHeight,
                child: Image.asset(
                  AppAssets.rankImage(position),
                  semanticLabel: 'Rank $position',
                ),
              ),
            ),
          Positioned(
            left: metrics.contentLeadingInset,
            top: 0,
            width: metrics.cardWidth,
            height: metrics.itemHeight,
            child: Column(
              crossAxisAlignment: .start,
              children: [
                SizedBox(
                  width: metrics.cardWidth,
                  height: metrics.thumbnailHeight,
                  child: ClipRRect(
                    borderRadius: .circular(6),
                    child: ColoredBox(
                      color: StreamTvColors.surface,
                      child: Stack(
                        fit: .expand,
                        children: [
                          HomeNetworkImage(
                            imageUrl: item.thumbnailUrl,
                            semanticLabel: item.title,
                          ),
                          Positioned(
                            left: 7,
                            bottom: 7,
                            child: _ContentBadge(item: item),
                          ),
                          if (item.ageRestriction case final age?)
                            Positioned(
                              top: 7,
                              right: 7,
                              child: _Label(text: age),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: style.detailHeight,
                  child: Padding(
                    padding: const .only(top: 7),
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: .ellipsis,
                          style: TextStyle(
                            color: isSelected
                                ? StreamTvColors.primary
                                : StreamTvColors.onSurfaceMuted,
                            fontSize: 14,
                            fontWeight: .w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.description,
                          maxLines: style.descriptionMaxLines,
                          overflow: .ellipsis,
                          style: TextStyle(
                            color: isSelected
                                ? StreamTvColors.onSurfaceMuted
                                : StreamTvColors.onSurfaceMuted.withValues(
                                    alpha: 0.68,
                                  ),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final class _ContentBadge extends StatelessWidget {
  const _ContentBadge({required this.item});

  final HomeItem item;

  @override
  Widget build(BuildContext context) {
    final label = switch (item.kind) {
      .channel => 'LIVE',
      .series => '${item.episodes.length} EPISODES',
      .short => 'SHORT',
      .video => 'VIDEO',
    };
    return _Label(
      text: label,
      backgroundColor: item.kind == .channel
          ? StreamTvColors.live
          : Colors.black.withValues(alpha: 0.80),
    );
  }
}

final class _Label extends StatelessWidget {
  const _Label({
    required this.text,
    this.backgroundColor = const Color(0x99000000),
  });

  final String text;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: .circular(3),
      ),
      child: Padding(
        padding: const .symmetric(horizontal: 6, vertical: 2),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: .w500,
          ),
        ),
      ),
    );
  }
}
