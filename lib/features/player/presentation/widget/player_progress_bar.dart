import 'package:flutter/material.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_colors.dart';

/// A two-layer progress bar: buffered ahead behind, played position in front.
///
/// Ported from the Compose player's `PlayerProgressBar`. Each layer is skipped at zero rather than
/// drawn with zero width, because an empty child still costs a layout pass on every progress tick —
/// and there are two ticks a second for the length of a film.
final class PlayerProgressBar extends StatelessWidget {
  /// Draws played and buffered progress, both in `0..1`.
  const PlayerProgressBar({
    required this.progressFraction,
    required this.bufferedFraction,
    super.key,
  });

  /// Height of the track. Also the reference the seek thumb is centred against.
  static const double height = 4;

  /// Played position, in `0..1`.
  final double progressFraction;

  /// How far the buffer reaches, in `0..1`.
  final double bufferedFraction;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: .circular(2),
        child: Stack(
          // Expand, so each fractional layer measures against the full track rather than against a
          // childless box that would collapse to nothing.
          fit: .expand,
          children: [
            const ColoredBox(color: StreamTvColors.playerTrackIdle),
            if (bufferedFraction > 0)
              _Fill(
                widthFactor: bufferedFraction,
                color: StreamTvColors.playerTrackBuffered,
              ),
            if (progressFraction > 0)
              _Fill(
                widthFactor: progressFraction,
                color: StreamTvColors.playerAccent,
              ),
          ],
        ),
      ),
    );
  }
}

final class _Fill extends StatelessWidget {
  const _Fill({required this.widthFactor, required this.color});

  final double widthFactor;
  final Color color;

  @override
  Widget build(BuildContext context) => FractionallySizedBox(
    alignment: .centerLeft,
    widthFactor: widthFactor,
    // Explicit, because `FractionallySizedBox` leaves an axis with no factor loosely constrained,
    // and a `ColoredBox` with no child of its own then measures as zero on that axis.
    heightFactor: 1,
    child: ColoredBox(color: color),
  );
}
