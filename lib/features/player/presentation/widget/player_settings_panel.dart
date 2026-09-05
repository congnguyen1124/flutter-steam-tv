import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_steam_tv/core/assets/app_assets.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_colors.dart';
import 'package:flutter_steam_tv/features/player/presentation/model/player_settings_ui_state.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The settings side panel: quality, audio and subtitle renditions.
///
/// ## Why a side panel and not a dialog
///
/// A dialog on a TV covers the video and stops playback being watched while a setting is compared.
/// The Compose player anchors a narrow panel to the right edge for exactly that reason, and the
/// video keeps playing beside it.
///
/// Categories are flattened into one scrollable list rather than nested behind a category screen.
/// Nesting costs the viewer a press in and a press out per change; with at most three categories
/// and a handful of options each, everything fits on one panel and every option is one press away.
///
/// Left dismisses, matching the direction the panel came from.
final class PlayerSettingsPanel extends StatelessWidget {
  /// The panel for [settings].
  const PlayerSettingsPanel({
    required this.settings,
    required this.onOptionSelected,
    required this.onDismiss,
    super.key,
  });

  static const double _width = 315;

  /// What the host has to offer.
  final PlayerSettingsUiState settings;

  /// Called with the category and the chosen option id.
  final void Function(PlayerSettingKind kind, String optionId) onOptionSelected;

  /// Close the panel.
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: .centerRight,
      child: Padding(
        padding: const .symmetric(horizontal: 30, vertical: 30),
        child: SizedBox(
          width: _width,
          child: Focus(
            onKeyEvent: _onKeyEvent,
            child: FocusTraversalGroup(
              policy: ReadingOrderTraversalPolicy(),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: StreamTvColors.playerPanel,
                  borderRadius: .circular(12),
                ),
                child: ListView(
                  padding: const .symmetric(horizontal: 16, vertical: 20),
                  children: [
                    for (final (index, category)
                        in settings.categories.indexed) ...[
                      if (index > 0) const SizedBox(height: 18),
                      _CategoryHeader(kind: category.kind),
                      const SizedBox(height: 8),
                      for (final option in category.options)
                        _OptionRow(
                          option: option,
                          // The first option of the first category takes focus, so the panel is
                          // usable the instant it appears.
                          autofocus:
                              index == 0 && option == category.options.first,
                          onPressed: () =>
                              onOptionSelected(category.kind, option.id),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return .ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      onDismiss();
      return .handled;
    }
    return .ignored;
  }
}

final class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({required this.kind});

  final PlayerSettingKind kind;

  @override
  Widget build(BuildContext context) {
    final (asset, label) = switch (kind) {
      PlayerSettingKind.quality => (AppAssets.hdIcon, 'Quality'),
      PlayerSettingKind.audio => (AppAssets.audioIcon, 'Audio'),
      PlayerSettingKind.subtitles => (AppAssets.subtitlesIcon, 'Subtitles'),
    };

    return Row(
      children: [
        SvgPicture.asset(
          asset,
          width: 18,
          height: 18,
          colorFilter: const ColorFilter.mode(
            StreamTvColors.playerMutedForeground,
            .srcIn,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: StreamTvColors.playerMutedForeground,
            fontSize: 13,
            fontWeight: .w500,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }
}

final class _OptionRow extends StatefulWidget {
  const _OptionRow({
    required this.option,
    required this.autofocus,
    required this.onPressed,
  });

  final PlayerSettingOption option;
  final bool autofocus;
  final VoidCallback onPressed;

  @override
  State<_OptionRow> createState() => _OptionRowState();
}

final class _OptionRowState extends State<_OptionRow> {
  bool _hasFocus = false;

  @override
  Widget build(BuildContext context) {
    final foreground = _hasFocus
        ? StreamTvColors.playerBackground
        : StreamTvColors.playerForeground;

    return Padding(
      padding: const .only(bottom: 4),
      child: InkWell(
        autofocus: widget.autofocus,
        onTap: widget.onPressed,
        onFocusChange: (hasFocus) => setState(() => _hasFocus = hasFocus),
        borderRadius: .circular(8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: _hasFocus
                ? StreamTvColors.playerForeground
                : Colors.transparent,
            borderRadius: .circular(8),
          ),
          child: Padding(
            padding: const .symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.option.label,
                    maxLines: 1,
                    overflow: .ellipsis,
                    style: TextStyle(color: foreground, fontSize: 15),
                  ),
                ),
                // A tick rather than a radio dot: the selection can change underneath the viewer
                // when adaptive selection moves, and a tick reads as "this is what is playing"
                // rather than as "this is what you chose".
                if (widget.option.isSelected)
                  SvgPicture.asset(
                    AppAssets.checkIcon,
                    width: 16,
                    height: 16,
                    colorFilter: ColorFilter.mode(foreground, .srcIn),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
