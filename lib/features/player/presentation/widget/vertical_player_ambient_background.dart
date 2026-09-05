import 'package:flutter/material.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_colors.dart';

/// The gradient behind the portrait stage.
///
/// A television panel is landscape and a portrait video cannot fill it. Something has to occupy the
/// width beside the stage, and the two obvious answers are both bad: black bars read as a broken
/// layout, and cropping the video to fill the panel throws away the top and bottom of every frame.
///
/// A horizontal gradient — darkest on the leading edge, picking up the brand tint on the trailing
/// edge where the interaction panel sits — makes that width look deliberate, and quietly points the
/// eye toward the controls.
final class VerticalPlayerAmbientBackground extends StatelessWidget {
  /// Fills its box with the ambient gradient.
  const VerticalPlayerAmbientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            StreamTvColors.playerBackground,
            StreamTvColors.playerBackground,
            StreamTvColors.primaryContainer,
          ],
          // The tint only arrives in the last third, so the stage still sits against black and the
          // video is never colour-cast by what is behind it.
          stops: [0, 0.55, 1],
        ),
      ),
      child: SizedBox.expand(),
    );
  }
}
