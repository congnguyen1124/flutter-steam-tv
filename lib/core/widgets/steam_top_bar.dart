import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_steam_tv/core/assets/app_assets.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_colors.dart';
import 'package:flutter_steam_tv/core/widgets/steam_top_bar_destination_button.dart';
import 'package:flutter_steam_tv/core/widgets/steam_top_bar_item.dart';
import 'package:flutter_steam_tv/core/widgets/steam_top_bar_profile_button.dart';

final class SteamTopBar extends StatefulWidget {
  const SteamTopBar({
    required this.items,
    required this.selectedItemId,
    required this.onItemPressed,
    this.controller,
    this.onFocusChanged,
    this.onMoveDown,
    this.showScrim = true,
    super.key,
  });

  static const double height = 80;

  final List<SteamTopBarItem> items;
  final String? selectedItemId;
  final ValueChanged<SteamTopBarItem> onItemPressed;
  final SteamTopBarController? controller;
  final ValueChanged<bool>? onFocusChanged;
  final VoidCallback? onMoveDown;
  final bool showScrim;

  @override
  State<SteamTopBar> createState() => _SteamTopBarState();
}

final class SteamTopBarController {
  ValueChanged<String?>? _requestFocusCallback;

  void requestFocus([String? itemId]) => _requestFocusCallback?.call(itemId);

  void _attach(ValueChanged<String?> requestFocus) {
    _requestFocusCallback = requestFocus;
  }

  void _detach() {
    _requestFocusCallback = null;
  }
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
  void initState() {
    super.initState();
    widget.controller?._attach(_requestFocus);
  }

  @override
  void didUpdateWidget(SteamTopBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach();
      widget.controller?._attach(_requestFocus);
    }
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
    widget.controller?._detach();
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
      child: SteamTopBarDestinationButton(
        key: ValueKey('steam-top-bar-item-${item.id}'),
        item: item,
        focusNode: _focusNodes[item.id]!,
        isFocused: isFocused,
        isSelected: item.id == widget.selectedItemId,
        onFocusChanged: (hasFocus) => _setItemFocus(item.id, hasFocus),
        onKeyEvent: (_, event) => _handleNavigationKey(item, event),
        onPressed: () => widget.onItemPressed(item),
      ),
    );
  }

  Widget _buildProfile(SteamTopBarItem item) {
    return SteamTopBarProfileButton(
      key: ValueKey('steam-top-bar-item-${item.id}'),
      item: item,
      focusNode: _focusNodes[item.id]!,
      isSelected: item.id == widget.selectedItemId,
      onFocusChanged: (hasFocus) => _setItemFocus(item.id, hasFocus),
      onKeyEvent: (_, event) => _handleNavigationKey(item, event),
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

  void _requestFocus(String? itemId) {
    if (_visibleItems.isEmpty) {
      return;
    }
    final selectedItemId = itemId ?? widget.selectedItemId;
    final targetItem = _visibleItems.firstWhere(
      (item) => item.id == selectedItemId,
      orElse: () => _visibleItems.first,
    );
    _focusNodes[targetItem.id]?.requestFocus();
  }

  KeyEventResult _handleNavigationKey(SteamTopBarItem item, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return .ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      final onMoveDown = widget.onMoveDown;
      if (onMoveDown == null) {
        return .ignored;
      }
      onMoveDown();
      return .handled;
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
