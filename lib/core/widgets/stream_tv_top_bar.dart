import 'package:flutter/material.dart';
import 'package:flutter_steam_tv/core/assets/app_assets.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

final class StreamTvTopBar extends StatelessWidget {
  const StreamTvTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Padding(
        padding: const .symmetric(horizontal: 48),
        child: Row(
          children: [
            const Text(
              'StreamTV',
              style: TextStyle(fontSize: 24, fontWeight: .w700),
            ),
            const Spacer(),
            _CurrentDestination(iconAsset: AppAssets.homeIcon, label: 'Home'),
          ],
        ),
      ),
    );
  }
}

final class _CurrentDestination extends StatelessWidget {
  const _CurrentDestination({required this.iconAsset, required this.label});

  final String iconAsset;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: StreamTvColors.surface,
        borderRadius: .circular(6),
      ),
      child: Padding(
        padding: const .symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisSize: .min,
          children: [
            SvgPicture.asset(
              iconAsset,
              width: 22,
              height: 22,
              colorFilter: const .mode(
                StreamTvColors.onSurface,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(fontWeight: .w500)),
          ],
        ),
      ),
    );
  }
}
