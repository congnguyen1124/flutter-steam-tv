import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_colors.dart';

/// The buffering spinner: a rotating arc over a faint full ring.
///
/// The Compose player plays a Lottie file here and falls back to a drawn arc when the composition
/// is unavailable. This is that fallback, promoted to the only implementation: the Flutter app
/// ships no Lottie runtime, and adding one for a 56dp spinner would be a dependency and a licence
/// review for something a `CustomPaint` does in forty lines.
///
/// It is the only thing on screen telling the viewer that playback is still coming, so it must
/// never be an empty box.
final class PlayerBufferingIndicator extends StatefulWidget {
  /// Draws the spinner at its natural size.
  const PlayerBufferingIndicator({super.key});

  /// Diameter, matching the Compose player.
  static const double size = 56;

  @override
  State<PlayerBufferingIndicator> createState() => _PlayerBufferingIndicatorState();
}

final class _PlayerBufferingIndicatorState extends State<PlayerBufferingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: PlayerBufferingIndicator.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _PlayerBufferingPainter(rotation: _controller.value * 2 * math.pi),
        ),
      ),
    );
  }
}

final class _PlayerBufferingPainter extends CustomPainter {
  const _PlayerBufferingPainter({required this.rotation});

  static const double _strokeWidth = 4;
  static const double _sweep = math.pi / 2;

  final double rotation;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      _strokeWidth / 2,
      _strokeWidth / 2,
      size.width - _strokeWidth,
      size.height - _strokeWidth,
    );
    final track = Paint()
      ..style = .stroke
      ..strokeWidth = _strokeWidth
      ..color = StreamTvColors.playerTrackIdle;
    final head = Paint()
      ..style = .stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = .round
      ..color = StreamTvColors.playerForeground;

    canvas.drawArc(rect, 0, 2 * math.pi, false, track);
    canvas.drawArc(rect, rotation, _sweep, false, head);
  }

  @override
  bool shouldRepaint(_PlayerBufferingPainter oldDelegate) => oldDelegate.rotation != rotation;
}
