import 'package:flutter/material.dart';
import 'package:flutter_steam_tv/core/assets/app_assets.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_colors.dart';
import 'package:flutter_steam_tv/features/home/domain/model/home_item.dart';
import 'package:flutter_svg/flutter_svg.dart';

final class HomeContentCard extends StatefulWidget {
  const HomeContentCard({
    required this.item,
    required this.focusNode,
    required this.onKeyEvent,
    required this.onPressed,
    this.autofocus = false,
    super.key,
  });

  final HomeItem item;
  final FocusNode focusNode;
  final FocusOnKeyEventCallback onKeyEvent;
  final VoidCallback onPressed;
  final bool autofocus;

  @override
  State<HomeContentCard> createState() => _HomeContentCardState();
}

final class _HomeContentCardState extends State<HomeContentCard> {
  bool _hasFocus = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: widget.onKeyEvent,
      child: InkWell(
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        onFocusChange: (hasFocus) => setState(() => _hasFocus = hasFocus),
        onTap: widget.onPressed,
        borderRadius: .circular(6),
        child: AnimatedContainer(
          width: 272,
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: StreamTvColors.surface,
            border: Border.all(
              color: _hasFocus
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: 3,
            ),
            borderRadius: .circular(6),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: .start,
            children: [
              _Artwork(item: widget.item),
              Expanded(
                child: Padding(
                  padding: const .symmetric(horizontal: 12, vertical: 6),
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text(
                        widget.item.title,
                        maxLines: 1,
                        overflow: .ellipsis,
                        style: const TextStyle(fontWeight: .w500),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.item.description,
                        maxLines: 1,
                        overflow: .ellipsis,
                        style: const TextStyle(
                          color: StreamTvColors.onSurfaceMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _Artwork extends StatelessWidget {
  const _Artwork({required this.item});

  final HomeItem item;

  @override
  Widget build(BuildContext context) {
    final (asset, color, label) = switch (item.kind) {
      .video => (AppAssets.playIcon, StreamTvColors.blue, 'VIDEO'),
      .series => (AppAssets.appsIcon, StreamTvColors.green, 'SERIES'),
      .channel => (AppAssets.homeIcon, StreamTvColors.red, 'LIVE'),
      .short => (AppAssets.playIcon, StreamTvColors.gold, 'SHORT'),
    };

    return ColoredBox(
      color: color,
      child: SizedBox(
        width: double.infinity,
        height: 153,
        child: Stack(
          children: [
            Center(
              child: SvgPicture.asset(
                asset,
                width: 48,
                height: 48,
                colorFilter: const .mode(Colors.white, BlendMode.srcIn),
              ),
            ),
            Positioned(
              left: 10,
              bottom: 8,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.72),
                  borderRadius: .circular(3),
                ),
                child: Padding(
                  padding: const .symmetric(horizontal: 7, vertical: 3),
                  child: Text(label, style: const TextStyle(fontSize: 10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
