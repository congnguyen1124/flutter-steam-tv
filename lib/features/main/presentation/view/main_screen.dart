import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_steam_tv/core/widgets/steam_top_bar.dart';
import 'package:flutter_steam_tv/core/widgets/steam_top_bar_item.dart';
import 'package:flutter_steam_tv/core/widgets/tv_list_view/tv_list_view.dart';
import 'package:flutter_steam_tv/features/main/presentation/navigation/main_top_bar_items.dart';

final class MainScreen extends StatefulWidget {
  const MainScreen({
    required this.currentPath,
    required this.onNavigate,
    required this.child,
    this.contentBehindTopBar = false,
    super.key,
  });

  final String currentPath;
  final ValueChanged<String> onNavigate;
  final Widget child;
  final bool contentBehindTopBar;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

final class _MainScreenState extends State<MainScreen> {
  static const Duration _overlayDuration = Duration(milliseconds: 160);
  static const double _contentTopInset = SteamTopBar.height;

  late final FocusScopeNode _contentFocusScopeNode = FocusScopeNode(
    debugLabel: 'main-content',
  );
  final SteamTopBarController _topBarController = SteamTopBarController();
  bool _isTopBarFocused = false;

  @override
  void dispose() {
    _contentFocusScopeNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedItem = MainTopBarItems.itemForPath(widget.currentPath);

    return Scaffold(
      body: Stack(
        fit: .expand,
        children: [
          Positioned.fill(
            child: Focus(
              canRequestFocus: false,
              onKeyEvent: _handleContentKeyEvent,
              child: FocusScope(
                node: _contentFocusScopeNode,
                child: Padding(
                  padding: .only(
                    top: widget.contentBehindTopBar ? 0 : _contentTopInset,
                  ),
                  child: widget.child,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: _isTopBarFocused ? 1 : 0,
                duration: _overlayDuration,
                child: ColoredBox(
                  color: Theme.of(
                    context,
                  ).colorScheme.surface.withValues(alpha: 0.74),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: SteamTopBar(
                key: const ValueKey('steam-top-bar'),
                items: MainTopBarItems.defaults,
                selectedItemId: selectedItem.id,
                controller: _topBarController,
                onMoveDown: _requestContentFocus,
                onFocusChanged: (hasFocus) {
                  if (_isTopBarFocused != hasFocus) {
                    setState(() => _isTopBarFocused = hasFocus);
                  }
                },
                onItemPressed: _navigateFromTopBar,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateFromTopBar(SteamTopBarItem item) {
    final path = MainTopBarItems.pathFor(item);
    if (path == widget.currentPath) {
      return;
    }

    widget.onNavigate(path);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _topBarController.requestFocus(item.id);
        }
      });
      WidgetsBinding.instance.scheduleFrame();
    });
  }

  void _requestContentFocus() {
    for (final node
        in _contentFocusScopeNode.traversalDescendants
            .whereType<TvListViewEntryFocusNode>()) {
      if (node.canRequestFocus && (node.context?.mounted ?? false)) {
        node.requestFocus();
        return;
      }
    }

    for (final node in _contentFocusScopeNode.traversalDescendants) {
      if (node is FocusScopeNode ||
          !node.canRequestFocus ||
          node.skipTraversal ||
          !(node.context?.mounted ?? false)) {
        continue;
      }
      node.requestFocus();
      return;
    }
  }

  KeyEventResult _handleContentKeyEvent(FocusNode node, KeyEvent event) {
    if ((event is! KeyDownEvent && event is! KeyRepeatEvent) ||
        event.logicalKey != LogicalKeyboardKey.arrowUp) {
      return .ignored;
    }

    final primaryFocus = FocusManager.instance.primaryFocus;
    if (primaryFocus?.focusInDirection(.up) ?? false) {
      return .handled;
    }

    _topBarController.requestFocus();
    return .handled;
  }
}
