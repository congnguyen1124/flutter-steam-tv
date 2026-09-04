import 'package:flutter/material.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_colors.dart';

final class HomeNetworkImage extends StatelessWidget {
  const HomeNetworkImage({
    required this.imageUrl,
    required this.semanticLabel,
    this.fit = BoxFit.cover,
    super.key,
  });

  final String imageUrl;
  final String semanticLabel;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _placeholder;
    }

    return Image.network(
      imageUrl,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      semanticLabel: semanticLabel,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return child;
        }
        return _placeholder;
      },
      errorBuilder: (_, _, _) => _placeholder,
    );
  }

  Widget get _placeholder {
    return const ColoredBox(
      color: StreamTvColors.surfaceContainer,
      child: Center(
        child: Icon(
          Icons.movie_outlined,
          color: StreamTvColors.onSurfaceMuted,
          size: 40,
        ),
      ),
    );
  }
}
