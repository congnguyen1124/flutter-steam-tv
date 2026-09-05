import 'package:flutter/material.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_colors.dart';
import 'package:flutter_steam_tv/features/home/domain/model/home_item.dart';

/// Shared information block for landscape and portrait Home banners.
final class HomeBannerInfo extends StatelessWidget {
  const HomeBannerInfo({
    required this.item,
    required this.itemCount,
    required this.selectedIndex,
    required this.isFocused,
    this.maxWidth = 540,
    super.key,
  });

  final HomeItem item;
  final int itemCount;
  final int selectedIndex;
  final bool isFocused;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          Text(
            item.title,
            maxLines: 2,
            overflow: .ellipsis,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: .w700,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (item.ageRestriction case final age?) ...[
                _BannerMetadata(text: age),
                const SizedBox(width: 10),
              ],
              _BannerMetadata(text: item.kind.name.toUpperCase()),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.description,
            maxLines: 2,
            overflow: .ellipsis,
            style: const TextStyle(
              color: StreamTvColors.onSurfaceMuted,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                padding: const .symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: isFocused
                      ? StreamTvColors.surfaceFocused
                      : Colors.white.withValues(alpha: 0.14),
                  borderRadius: .circular(16),
                ),
                child: Row(
                  mainAxisSize: .min,
                  children: [
                    Icon(
                      Icons.play_arrow_rounded,
                      color: isFocused
                          ? StreamTvColors.onPrimary
                          : Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'Watch now',
                      style: TextStyle(
                        color: isFocused
                            ? StreamTvColors.onPrimary
                            : Colors.white,
                        fontWeight: .w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Flexible(
                child: _BannerDots(
                  itemCount: itemCount,
                  selectedIndex: selectedIndex,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

final class _BannerMetadata extends StatelessWidget {
  const _BannerMetadata({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.58),
        borderRadius: .circular(4),
      ),
      child: Padding(
        padding: const .symmetric(horizontal: 7, vertical: 3),
        child: Text(text, style: const TextStyle(fontSize: 11)),
      ),
    );
  }
}

final class _BannerDots extends StatelessWidget {
  const _BannerDots({required this.itemCount, required this.selectedIndex});

  final int itemCount;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: .min,
      children: [
        for (var index = 0; index < itemCount; index++) ...[
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: index == selectedIndex ? 22 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: index == selectedIndex
                  ? StreamTvColors.primary
                  : Colors.white.withValues(alpha: 0.38),
              borderRadius: .circular(4),
            ),
          ),
          if (index < itemCount - 1) const SizedBox(width: 6),
        ],
      ],
    );
  }
}
