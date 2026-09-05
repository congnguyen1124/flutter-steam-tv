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

/// Layout metrics shared by the settings rows.
///
/// One object rather than numbers inlined at each use, because the root list and the option list
/// have to agree on spacing and radius for the two levels to read as one component when a child
/// panel slides over its parent.
final class _SettingMetrics {
  const _SettingMetrics._();

  static const double itemRadius = 8;
  static const double rootItemHeight = 54;
  static const double optionItemHeight = 42;
  static const double iconSize = 20;
  static const double trailingIconSize = 14;
  static const double itemSpacing = 4;
  static const double labelSize = 15;
  static const double labelHeight = 20 / 15;
  static const double captionSize = 12;
  static const double captionHeight = 16 / 12;

  /// How far the caption is dimmed against the row's own foreground.
  static const double inactiveCaptionAlpha = 0.6;
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
          _SettingRootRow(
            iconAsset: _iconFor(category.kind),
            label: _labelFor(category.kind),
            selectedLabel: category.selectedLabel,
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
          _SettingOptionRow(
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

/// A category row: icon, name, the value in effect underneath, and a chevron into its panel.
///
/// The value sits **below** the name rather than trailing it. A long rendition label — a dubbing
/// track's full language name, say — pushes a trailing value into an ellipsis at exactly the width
/// this panel has, and the value is the half the viewer is checking. Stacked, both fit.
///
/// The chevron is what separates this row from an option row at a glance: one opens a list, the
/// other commits a choice, and on a remote there is no hover state to disambiguate them.
final class _SettingRootRow extends StatelessWidget {
  const _SettingRootRow({
    required this.iconAsset,
    required this.label,
    required this.selectedLabel,
    required this.autofocus,
    required this.onPressed,
  });

  final String iconAsset;
  final String label;
  final String selectedLabel;
  final bool autofocus;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return _SettingSurface(
      autofocus: autofocus,
      onPressed: onPressed,
      minHeight: _SettingMetrics.rootItemHeight,
      builder: (foreground) => Row(
        children: [
          SvgPicture.asset(
            iconAsset,
            width: _SettingMetrics.iconSize,
            height: _SettingMetrics.iconSize,
            colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foreground,
                    fontSize: _SettingMetrics.labelSize,
                    height: _SettingMetrics.labelHeight,
                  ),
                ),
                Text(
                  selectedLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foreground.withValues(
                      alpha: _SettingMetrics.inactiveCaptionAlpha,
                    ),
                    fontSize: _SettingMetrics.captionSize,
                    height: _SettingMetrics.captionHeight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SvgPicture.asset(
            AppAssets.chevronRightIcon,
            width: _SettingMetrics.trailingIconSize,
            height: _SettingMetrics.trailingIconSize,
            colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
          ),
        ],
      ),
    );
  }
}

/// One selectable option, ticked when it is the value in effect.
final class _SettingOptionRow extends StatelessWidget {
  const _SettingOptionRow({
    required this.label,
    required this.isSelected,
    required this.autofocus,
    required this.onPressed,
  });

  final String label;
  final bool isSelected;
  final bool autofocus;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return _SettingSurface(
      autofocus: autofocus,
      onPressed: onPressed,
      isCurrentValue: isSelected,
      minHeight: _SettingMetrics.optionItemHeight,
      builder: (foreground) => Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: foreground,
                fontSize: _SettingMetrics.labelSize,
                height: _SettingMetrics.labelHeight,
              ),
            ),
          ),
          // A tick rather than a radio dot: adaptive selection can move the choice underneath the
          // viewer, and a tick reads as "this is what is playing" rather than "this is what you
          // chose".
          if (isSelected)
            SvgPicture.asset(
              AppAssets.checkIcon,
              width: _SettingMetrics.trailingIconSize,
              height: _SettingMetrics.trailingIconSize,
              colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
            ),
        ],
      ),
    );
  }
}

/// The focusable chip both settings rows are drawn on.
///
/// Three states, and the middle one is the one worth keeping: focused inverts to a white fill with
/// dark content; the row holding the **value in effect** takes a faint fill and a hairline; every
/// other row is transparent with dimmed content. Without the middle state a viewer who has moved
/// focus away cannot tell which rendition is playing — the tick alone is easy to miss at three
/// metres, and it is the only other signal.
///
/// The chip never grows on focus. These rows are 4 apart; a scaled row would overlap its neighbour.
final class _SettingSurface extends StatefulWidget {
  const _SettingSurface({
    required this.builder,
    required this.onPressed,
    required this.minHeight,
    required this.autofocus,
    this.isCurrentValue = false,
  });

  /// Builds the row content against the foreground colour its current state resolves to.
  final Widget Function(Color foreground) builder;

  final VoidCallback onPressed;
  final double minHeight;
  final bool autofocus;
  final bool isCurrentValue;

  @override
  State<_SettingSurface> createState() => _SettingSurfaceState();
}

final class _SettingSurfaceState extends State<_SettingSurface> {
  bool _hasFocus = false;

  @override
  Widget build(BuildContext context) {
    final foreground = switch ((_hasFocus, widget.isCurrentValue)) {
      (true, _) => StreamTvColors.playerBackground,
      (false, true) => StreamTvColors.playerForeground,
      (false, false) => StreamTvColors.playerMutedForeground,
    };
    final background = switch ((_hasFocus, widget.isCurrentValue)) {
      (true, _) => StreamTvColors.playerForeground,
      (false, true) => StreamTvColors.playerSettingSelected,
      (false, false) => Colors.transparent,
    };
    // Only on the unfocused current value: a focused row is already the brightest thing in the
    // panel, and an outline on top of a white fill just muddies its edge.
    final border = !_hasFocus && widget.isCurrentValue
        ? Border.all(color: StreamTvColors.playerSettingSelectedBorder)
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: _SettingMetrics.itemSpacing),
      child: InkWell(
        autofocus: widget.autofocus,
        onTap: widget.onPressed,
        onFocusChange: (hasFocus) => setState(() => _hasFocus = hasFocus),
        borderRadius: BorderRadius.circular(_SettingMetrics.itemRadius),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: background,
            border: border,
            borderRadius: BorderRadius.circular(_SettingMetrics.itemRadius),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: widget.minHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Center(child: widget.builder(foreground)),
            ),
          ),
        ),
      ),
    );
  }
}
