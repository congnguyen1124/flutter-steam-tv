import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_steam_tv/core/assets/app_assets.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_colors.dart';
import 'package:flutter_steam_tv/core/widgets/steam_top_bar_item.dart';
import 'package:flutter_svg/flutter_svg.dart';

final class SteamTopBar extends StatefulWidget {
  const SteamTopBar({
    required this.items,
    required this.selectedItemId,
    required this.onItemPressed,
    this.onFocusChanged,
    this.showScrim = true,
    super.key,
  });

  static const double height = 92;

  final List<SteamTopBarItem> items;
  final String? selectedItemId;
  final ValueChanged<SteamTopBarItem> onItemPressed;
  final ValueChanged<bool>? onFocusChanged;
  final bool showScrim;

  @override
  State<SteamTopBar> createState() => _SteamTopBarState();
}

final class _SteamTopBarState extends State<SteamTopBar> {
  late Map<String, FocusNode> _focusNodes = _createFocusNodes();
  String? _focusedItemId;

  List<SteamTopBarItem> get _visibleItems {
    final destinations = widget.items.where(
      (item) => item.role == .destination,
    );
    final profiles = widget.items.where((item) => item.role == .profile);
    return [...destinations, ...profiles];
  }

  @override
  void didUpdateWidget(SteamTopBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldIds = oldWidget.items.map((item) => item.id).toSet();
    final newIds = widget.items.map((item) => item.id).toSet();
    if (!setEquals(oldIds, newIds)) {
      _disposeFocusNodes();
      _focusNodes = _createFocusNodes();
      _focusedItemId = null;
    }
  }

  @override
  void dispose() {
    _disposeFocusNodes();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final destinationItems = widget.items
        .where((item) => item.role == .destination)
        .toList(growable: false);
    final profileItem = widget.items
        .where((item) => item.role == .profile)
        .firstOrNull;

    return Focus(
      canRequestFocus: false,
      onFocusChange: widget.onFocusChanged,
      child: SizedBox(
        height: SteamTopBar.height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: widget.showScrim
                ? LinearGradient(
                    begin: .topCenter,
                    end: .bottomCenter,
                    colors: [
                      StreamTvColors.background,
                      StreamTvColors.background.withValues(alpha: 0.78),
                      Colors.transparent,
                    ],
                    stops: const [0, 0.72, 1],
                  )
                : null,
          ),
          child: Padding(
            padding: const .symmetric(horizontal: 48, vertical: 6),
            child: Row(
              children: [
                Image.asset(
                  AppAssets.appLogo,
                  width: 128,
                  height: 48,
                  alignment: .centerLeft,
                  filterQuality: .high,
                  fit: .contain,
                ),
                const Spacer(),
                ...destinationItems.map(_buildDestination),
                if (profileItem case final item?) ...[
                  const SizedBox(width: 10),
                  _buildProfile(item),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDestination(SteamTopBarItem item) {
    final isFocused = item.id == _focusedItemId;
    return Padding(
      padding: const .symmetric(horizontal: 3),
      child: _SteamDestinationButton(
        key: ValueKey('steam-top-bar-item-${item.id}'),
        item: item,
        focusNode: _focusNodes[item.id]!,
        isFocused: isFocused,
        isSelected: item.id == widget.selectedItemId,
        onFocusChanged: (hasFocus) => _setItemFocus(item.id, hasFocus),
        onKeyEvent: (_, event) => _handleHorizontalKey(item, event),
        onPressed: () => widget.onItemPressed(item),
      ),
    );
  }

  Widget _buildProfile(SteamTopBarItem item) {
    return _SteamProfileButton(
      key: ValueKey('steam-top-bar-item-${item.id}'),
      item: item,
      focusNode: _focusNodes[item.id]!,
      isSelected: item.id == widget.selectedItemId,
      onFocusChanged: (hasFocus) => _setItemFocus(item.id, hasFocus),
      onKeyEvent: (_, event) => _handleHorizontalKey(item, event),
      onPressed: () => widget.onItemPressed(item),
    );
  }

  void _setItemFocus(String itemId, bool hasFocus) {
    if (hasFocus) {
      setState(() => _focusedItemId = itemId);
    } else if (_focusedItemId == itemId) {
      setState(() => _focusedItemId = null);
    }
  }

  KeyEventResult _handleHorizontalKey(SteamTopBarItem item, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return .ignored;
    }

    final offset = switch (event.logicalKey) {
      LogicalKeyboardKey.arrowLeft => -1,
      LogicalKeyboardKey.arrowRight => 1,
      _ => 0,
    };
    final currentIndex = _visibleItems.indexWhere(
      (candidate) => candidate.id == item.id,
    );
    final targetIndex = currentIndex + offset;
    if (offset == 0 || targetIndex < 0 || targetIndex >= _visibleItems.length) {
      return .ignored;
    }

    _focusNodes[_visibleItems[targetIndex].id]!.requestFocus();
    return .handled;
  }

  Map<String, FocusNode> _createFocusNodes() {
    return {
      for (final item in widget.items)
        item.id: FocusNode(debugLabel: 'top-bar:${item.id}'),
    };
  }

  void _disposeFocusNodes() {
    for (final focusNode in _focusNodes.values) {
      focusNode.dispose();
    }
  }
}

final class _SteamDestinationButton extends StatelessWidget {
  const _SteamDestinationButton({
    required this.item,
    required this.focusNode,
    required this.isFocused,
    required this.isSelected,
    required this.onFocusChanged,
    required this.onKeyEvent,
    required this.onPressed,
    super.key,
  });

  final SteamTopBarItem item;
  final FocusNode focusNode;
  final bool isFocused;
  final bool isSelected;
  final ValueChanged<bool> onFocusChanged;
  final FocusOnKeyEventCallback onKeyEvent;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foregroundColor = isFocused
        ? colorScheme.onPrimary
        : isSelected
        ? colorScheme.primary
        : colorScheme.onSurface;

    return Focus(
      canRequestFocus: false,
      onKeyEvent: onKeyEvent,
      child: Semantics(
        button: true,
        selected: isSelected,
        label: item.label,
        child: InkWell(
          focusNode: focusNode,
          onFocusChange: onFocusChanged,
          onTap: onPressed,
          borderRadius: .circular(40),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const .all(8),
            decoration: BoxDecoration(
              color: isFocused
                  ? colorScheme.primary
                  : isSelected
                  ? colorScheme.primary.withValues(alpha: 0.16)
                  : Colors.transparent,
              border: Border.all(
                color: isSelected && !isFocused
                    ? colorScheme.primary.withValues(alpha: 0.36)
                    : Colors.transparent,
              ),
              borderRadius: .circular(40),
            ),
            child: Row(
              mainAxisSize: .min,
              children: [
                SvgPicture.asset(
                  item.iconAsset,
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    foregroundColor,
                    BlendMode.srcIn,
                  ),
                ),
                ClipRect(
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    alignment: .centerLeft,
                    child: isFocused
                        ? Padding(
                            padding: const .only(left: 8, right: 6),
                            child: Text(
                              item.label,
                              style: TextStyle(
                                color: foregroundColor,
                                fontSize: 14,
                                fontWeight: .w500,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class _SteamProfileButton extends StatelessWidget {
  const _SteamProfileButton({
    required this.item,
    required this.focusNode,
    required this.isSelected,
    required this.onFocusChanged,
    required this.onKeyEvent,
    required this.onPressed,
    super.key,
  });

  final SteamTopBarItem item;
  final FocusNode focusNode;
  final bool isSelected;
  final ValueChanged<bool> onFocusChanged;
  final FocusOnKeyEventCallback onKeyEvent;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Focus(
      canRequestFocus: false,
      onKeyEvent: onKeyEvent,
      child: Semantics(
        button: true,
        selected: isSelected,
        label: item.label,
        child: InkWell(
          focusNode: focusNode,
          onFocusChange: onFocusChanged,
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: AnimatedContainer(
            width: 38,
            height: 38,
            duration: const Duration(milliseconds: 150),
            padding: const .all(8),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primary.withValues(alpha: 0.16)
                  : Colors.transparent,
              border: Border.all(
                color: focusNode.hasFocus
                    ? colorScheme.primary
                    : isSelected
                    ? colorScheme.primary.withValues(alpha: 0.36)
                    : Colors.transparent,
                width: 2,
              ),
              shape: .circle,
            ),
            child: SvgPicture.asset(
              item.iconAsset,
              colorFilter: ColorFilter.mode(
                focusNode.hasFocus || isSelected
                    ? colorScheme.primary
                    : StreamTvColors.onSurfaceMuted,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
