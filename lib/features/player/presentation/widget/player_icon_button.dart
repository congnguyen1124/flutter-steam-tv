import 'package:flutter/material.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A circular player control.
///
/// ## Why focus inverts the fill instead of scaling the button
///
/// Scaling a control that sits on a cluster's shared pill pushes it out of the pill. Inverting —
/// white circle, dark glyph — keeps the row's geometry fixed while still reading unmistakably from
/// across a room. Ported from the Compose player's `PlayerIconButton`, including that reasoning.
///
/// The caption under the focused button is part of the same idea: the row reserves height for it
/// always, so a caption appearing cannot shift the controls beside it.
final class PlayerIconButton extends StatefulWidget {
  /// A circular control showing [iconAsset].
  const PlayerIconButton({
    required this.iconAsset,
    required this.semanticLabel,
    required this.onPressed,
    required this.focusNode,
    this.label,
    this.size = defaultSize,
    this.iconSize = defaultIconSize,
    this.idleColor = StreamTvColors.playerControlIdle,
    this.autofocus = false,
    super.key,
  });

  /// Diameter of a secondary control.
  static const double defaultSize = 44;

  /// Glyph size inside a secondary control.
  static const double defaultIconSize = 22;

  /// Diameter of the transport primary. Larger so the eye finds pause without hunting.
  static const double primarySize = 60;

  /// Glyph size inside the transport primary.
  static const double primaryIconSize = 26;

  /// How far below the button the caption sits.
  static const double labelOffset = 22;

  /// SVG asset for the glyph.
  final String iconAsset;

  /// Screen-reader label. Also the caption when [label] is null.
  final String semanticLabel;

  /// Invoked by a tap, and by Select or Enter on a remote.
  final VoidCallback onPressed;

  /// Owned by the screen, so focus can be restored after the chrome is rebuilt.
  final FocusNode focusNode;

  /// Caption shown under the button while it holds focus, or null for none.
  ///
  /// Null for play/pause: a transport glyph needs no caption, and the Compose player omits it there
  /// too.
  final String? label;

  /// Diameter.
  final double size;

  /// Glyph size.
  final double iconSize;

  /// Fill while unfocused.
  ///
  /// Pass [Colors.transparent] for a button on a cluster's shared pill, so only the pill is drawn
  /// until the button takes focus.
  final Color idleColor;

  /// Whether this button claims focus when it first appears.
  final bool autofocus;

  @override
  State<PlayerIconButton> createState() => _PlayerIconButtonState();
}

final class _PlayerIconButtonState extends State<PlayerIconButton> {
  bool _hasFocus = false;

  @override
  Widget build(BuildContext context) {
    final foreground = _hasFocus
        ? StreamTvColors.playerBackground
        : StreamTvColors.playerForeground;

    return Stack(
      clipBehavior: .none,
      alignment: .center,
      children: [
        Semantics(
          button: true,
          label: widget.semanticLabel,
          child: InkWell(
            focusNode: widget.focusNode,
            autofocus: widget.autofocus,
            onTap: widget.onPressed,
            onFocusChange: (hasFocus) => setState(() => _hasFocus = hasFocus),
            customBorder: const CircleBorder(),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: .circle,
                color: _hasFocus ? StreamTvColors.playerForeground : widget.idleColor,
              ),
              child: SizedBox.square(
                dimension: widget.size,
                child: Center(
                  child: SvgPicture.asset(
                    widget.iconAsset,
                    width: widget.iconSize,
                    height: widget.iconSize,
                    colorFilter: ColorFilter.mode(foreground, .srcIn),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (widget.label case final label? when _hasFocus)
          Positioned(
            top: widget.size / 2 + PlayerIconButton.labelOffset,
            child: Text(
              label,
              maxLines: 1,
              overflow: .ellipsis,
              style: const TextStyle(
                color: StreamTvColors.playerMutedForeground,
                fontSize: 12,
                fontWeight: .w500,
              ),
            ),
          ),
      ],
    );
  }
}
