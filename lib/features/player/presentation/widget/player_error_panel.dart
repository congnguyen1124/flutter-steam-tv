import 'package:flutter/material.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_colors.dart';
import 'package:flutter_steam_tv/features/player/presentation/model/player_ui_state.dart';

/// Replaces the video entirely on failure.
///
/// Opaque, not an overlay: a frozen last frame behind an error message reads as the app being
/// broken rather than as the stream having stopped.
///
/// [onRetry] is null when the host classified the failure as not worth retrying, and then no button
/// is offered at all — a retry for a forbidden stream only invites the viewer to fail twice.
final class PlayerErrorPanel extends StatelessWidget {
  /// The error panel for [error].
  const PlayerErrorPanel({
    required this.error,
    required this.onRetry,
    super.key,
  });

  /// What went wrong, already turned into copy by the screen's state.
  final PlayerErrorUiItem error;

  /// Re-prepare and play, or null when retrying cannot help.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: StreamTvColors.playerBackground,
      child: Padding(
        padding: const .all(48),
        child: Column(
          mainAxisAlignment: .center,
          children: [
            Text(
              error.message,
              textAlign: .center,
              maxLines: 3,
              overflow: .ellipsis,
              style: const TextStyle(
                color: StreamTvColors.playerMutedForeground,
                fontSize: 22,
                fontWeight: .w500,
              ),
            ),
            if (onRetry case final onRetry?) ...[
              const SizedBox(height: 20),
              _RetryButton(onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}

final class _RetryButton extends StatefulWidget {
  const _RetryButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_RetryButton> createState() => _RetryButtonState();
}

final class _RetryButtonState extends State<_RetryButton> {
  bool _hasFocus = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // The only focusable thing on screen while an error shows, so it takes focus on appearance —
      // otherwise the remote has nothing to aim at and the viewer is stuck.
      autofocus: true,
      onTap: widget.onPressed,
      onFocusChange: (hasFocus) => setState(() => _hasFocus = hasFocus),
      borderRadius: .circular(24),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _hasFocus
              ? StreamTvColors.playerForeground
              : StreamTvColors.playerControlIdle,
          borderRadius: .circular(24),
        ),
        child: Padding(
          padding: const .symmetric(horizontal: 28, vertical: 12),
          child: Text(
            'Try again',
            style: TextStyle(
              color: _hasFocus
                  ? StreamTvColors.playerBackground
                  : StreamTvColors.playerForeground,
              fontSize: 16,
              fontWeight: .w500,
            ),
          ),
        ),
      ),
    );
  }
}
