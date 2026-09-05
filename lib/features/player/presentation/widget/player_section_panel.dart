import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_steam_tv/core/assets/app_assets.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_colors.dart';
import 'package:flutter_steam_tv/features/player/presentation/model/player_section.dart';
import 'package:flutter_steam_tv/features/player/presentation/model/player_settings_ui_state.dart';
import 'package:flutter_steam_tv/features/player/presentation/widget/player_section_host.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Maps a [PlayerSection] to the panel that renders it.
///
/// One `switch` over the section set, so adding a panel is a compile error until it is drawn —
/// which is the point of the section being a closed enum rather than a string.
final class PlayerSectionPanel extends StatelessWidget {
  /// Renders [section].
  const PlayerSectionPanel({
    required this.section,
    required this.isFocusEnabled,
    required this.dismissOnLeft,
    required this.hasPanelBackground,
    required this.onDismiss,
    required this.title,
    required this.description,
    required this.settings,
    required this.onOpenSection,
    required this.onOptionSelected,
    super.key,
  });

  /// Which panel to draw.
  final PlayerSection section;

  /// Whether this panel is the settled top layer and may take focus.
  final bool isFocusEnabled;

  /// Whether Left dismisses.
  final bool dismissOnLeft;

  /// Whether the panel draws its rounded translucent card.
  final bool hasPanelBackground;

  /// Pop this panel.
  final VoidCallback onDismiss;

  /// Item title, for the metadata panel.
  final String title;

  /// Item description, for the metadata panel.
  final String description;

  /// What the setting panels can offer.
  final PlayerSettingsUiState settings;

  /// Push a child panel.
  final ValueChanged<PlayerSection> onOpenSection;

  /// A rendition was chosen.
  final void Function(PlayerSettingKind kind, String optionId) onOptionSelected;

  @override
  Widget build(BuildContext context) {
    final body = switch (section) {
      PlayerSection.metadata => _MetadataBody(
        title: title,
        description: description,
        autofocus: isFocusEnabled,
      ),
      PlayerSection.settings => _SettingsBody(
        settings: settings,
        isFocusEnabled: isFocusEnabled,
        onOpenSection: onOpenSection,
      ),
      PlayerSection.quality => _OptionsBody(
        kind: PlayerSettingKind.quality,
        settings: settings,
        isFocusEnabled: isFocusEnabled,
        onOptionSelected: onOptionSelected,
      ),
      PlayerSection.audio => _OptionsBody(
        kind: PlayerSettingKind.audio,
        settings: settings,
        isFocusEnabled: isFocusEnabled,
        onOptionSelected: onOptionSelected,
      ),
      PlayerSection.subtitles => _OptionsBody(
        kind: PlayerSettingKind.subtitles,
        settings: settings,
        isFocusEnabled: isFocusEnabled,
        onOptionSelected: onOptionSelected,
      ),
    };

    return PlayerSectionKeyHandler(
      onDismiss: onDismiss,
      dismissOnLeft: dismissOnLeft,
      child: PlayerSectionSurface(
        title: section.title,
        hasBackground: hasPanelBackground,
        child: body,
      ),
    );
  }
}

/// Title and description, scrollable with the D-pad.
///
/// Focusable even though there is nothing here to activate. Two reasons, and the second is the one
/// that bites: a description longer than the panel needs Up and Down to read, and — more basically —
/// a panel with nothing focusable in it leaves focus parked on the off-screen anchor, which
/// swallows every key including Back. The viewer would be trapped in the panel.
final class _MetadataBody extends StatelessWidget {
  const _MetadataBody({
    required this.title,
    required this.description,
    required this.autofocus,
  });

  final String title;
  final String description;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return _FocusableScroll(
      autofocus: autofocus,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: StreamTvColors.playerForeground,
              fontSize: 20,
              height: 1.3,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              color: StreamTvColors.playerMutedForeground,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// A scroll view that takes focus and moves on Up and Down.
///
/// Flutter scrolls a focused scrollable with the arrow keys only when the focus is *inside* it;
/// prose has nothing inside to focus, so the scroller has to be the focus target itself.
final class _FocusableScroll extends StatefulWidget {
  const _FocusableScroll({
    required this.autofocus,
    required this.padding,
    required this.child,
  });

  final bool autofocus;
  final EdgeInsets padding;
  final Widget child;

  @override
  State<_FocusableScroll> createState() => _FocusableScrollState();
}

final class _FocusableScrollState extends State<_FocusableScroll> {
  static const double _step = 96;

  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: widget.autofocus,
      onKeyEvent: _onKeyEvent,
      child: SingleChildScrollView(
        controller: _controller,
        padding: widget.padding,
        child: widget.child,
      ),
    );
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final delta = switch (event.logicalKey) {
      LogicalKeyboardKey.arrowDown => _step,
      LogicalKeyboardKey.arrowUp => -_step,
      _ => null,
    };
    if (delta == null || !_controller.hasClients) {
      return KeyEventResult.ignored;
    }
    final target = (_controller.offset + delta).clamp(
      0.0,
      _controller.position.maxScrollExtent,
    );
    unawaited(
      _controller.animateTo(
        target,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
      ),
    );
    return KeyEventResult.handled;
  }
}

/// One row per setting category, each showing the option in effect and opening its own panel.
///
/// A list of categories rather than every option flattened into one panel: with three categories
/// and a handful of options each, a flat list is long enough that the viewer scrolls past the thing
/// they came for, and there is no header telling them what a row means.
final class _SettingsBody extends StatelessWidget {
  const _SettingsBody({
    required this.settings,
    required this.isFocusEnabled,
    required this.onOpenSection,
  });

  final PlayerSettingsUiState settings;
  final bool isFocusEnabled;
  final ValueChanged<PlayerSection> onOpenSection;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
      children: [
        for (final (index, category) in settings.categories.indexed)
          _SectionRow(
            iconAsset: _iconFor(category.kind),
            label: _labelFor(category.kind),
            trailing: category.selectedLabel,
            // The first row takes focus, so the panel is usable the instant it settles.
            autofocus: isFocusEnabled && index == 0,
            onPressed: () => onOpenSection(_sectionFor(category.kind)),
          ),
      ],
    );
  }

  static PlayerSection _sectionFor(PlayerSettingKind kind) => switch (kind) {
    PlayerSettingKind.quality => PlayerSection.quality,
    PlayerSettingKind.audio => PlayerSection.audio,
    PlayerSettingKind.subtitles => PlayerSection.subtitles,
  };

  static String _iconFor(PlayerSettingKind kind) => switch (kind) {
    PlayerSettingKind.quality => AppAssets.hdIcon,
    PlayerSettingKind.audio => AppAssets.audioIcon,
    PlayerSettingKind.subtitles => AppAssets.subtitlesIcon,
  };

  static String _labelFor(PlayerSettingKind kind) => switch (kind) {
    PlayerSettingKind.quality => 'Quality',
    PlayerSettingKind.audio => 'Audio',
    PlayerSettingKind.subtitles => 'Subtitles',
  };
}

/// The options of one category.
final class _OptionsBody extends StatelessWidget {
  const _OptionsBody({
    required this.kind,
    required this.settings,
    required this.isFocusEnabled,
    required this.onOptionSelected,
  });

  final PlayerSettingKind kind;
  final PlayerSettingsUiState settings;
  final bool isFocusEnabled;
  final void Function(PlayerSettingKind kind, String optionId) onOptionSelected;

  @override
  Widget build(BuildContext context) {
    final options = settings.categories
        .where((category) => category.kind == kind)
        .expand((category) => category.options)
        .toList(growable: false);

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
      children: [
        for (final (index, option) in options.indexed)
          _SectionRow(
            label: option.label,
            isSelected: option.isSelected,
            // The option in effect takes focus, so the viewer starts on what is playing rather
            // than at the top of a list they have to walk down to find their place in.
            autofocus: isFocusEnabled && _autofocusIndex(options) == index,
            onPressed: () => onOptionSelected(kind, option.id),
          ),
      ],
    );
  }

  static int _autofocusIndex(List<PlayerSettingOption> options) {
    for (var index = 0; index < options.length; index++) {
      if (options[index].isSelected) {
        return index;
      }
    }
    return 0;
  }
}

/// One focusable row: optional leading icon, label, and either a trailing value or a tick.
final class _SectionRow extends StatefulWidget {
  const _SectionRow({
    required this.label,
    required this.onPressed,
    this.iconAsset,
    this.trailing,
    this.isSelected = false,
    this.autofocus = false,
  });

  final String label;
  final VoidCallback onPressed;
  final String? iconAsset;
  final String? trailing;
  final bool isSelected;
  final bool autofocus;

  @override
  State<_SectionRow> createState() => _SectionRowState();
}

final class _SectionRowState extends State<_SectionRow> {
  bool _hasFocus = false;

  @override
  Widget build(BuildContext context) {
    final foreground = _hasFocus
        ? StreamTvColors.playerBackground
        : StreamTvColors.playerForeground;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        autofocus: widget.autofocus,
        onTap: widget.onPressed,
        onFocusChange: (hasFocus) => setState(() => _hasFocus = hasFocus),
        borderRadius: BorderRadius.circular(8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: _hasFocus
                ? StreamTvColors.playerForeground
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                if (widget.iconAsset case final iconAsset?) ...[
                  SvgPicture.asset(
                    iconAsset,
                    width: 18,
                    height: 18,
                    colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(
                    widget.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: foreground, fontSize: 15),
                  ),
                ),
                if (widget.trailing case final trailing?)
                  Text(
                    trailing,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: foreground.withValues(
                        alpha: _hasFocus ? 0.7 : 0.6,
                      ),
                      fontSize: 14,
                    ),
                  ),
                // A tick rather than a radio dot: adaptive selection can move the choice underneath
                // the viewer, and a tick reads as "this is what is playing" rather than "this is
                // what you chose".
                if (widget.isSelected)
                  SvgPicture.asset(
                    AppAssets.checkIcon,
                    width: 16,
                    height: 16,
                    colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
