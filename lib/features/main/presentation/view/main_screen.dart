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
    this.showTopBarReadabilityLayer = false,
    super.key,
  });

  final String currentPath;
  final ValueChanged<String> onNavigate;
  final Widget child;
  final bool contentBehindTopBar;

  /// Whether to draw the readability layer behind the top bar.
  ///
  /// Only meaningful together with [contentBehindTopBar]: a destination that is inset below the bar
  /// has nothing to scroll under it. Requested by the destination, because it is the only thing that
  /// knows whether anything is behind the bar right now — see `TopBarReadability`.
  final bool showTopBarReadabilityLayer;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

final class _MainScreenState extends State<MainScreen> {
  static const Duration _overlayDuration = Duration(milliseconds: 160);

  // Slower than the focus overlay on purpose. `spec/README.md` puts this at about 300ms: it appears
  // while the viewer is scrolling the feed, and a fast fade there reads as a flash behind the bar.
  static const Duration _readabilityDuration = Duration(milliseconds: 300);

  // Taller than the bar so the gradient finishes below it. Ending exactly at the bar's edge leaves a
  // hard horizontal line across the artwork, which is more distracting than the collision it fixes.
  static const double _readabilityHeight = SteamTopBar.height * 1.6;
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
          // Below the focus overlay and below the bar itself: this protects the bar's own glyphs from
          // the content, and must not sit over the dim that says the bar owns focus.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: widget.showTopBarReadabilityLayer ? 1 : 0,
                duration: _readabilityDuration,
                child: SizedBox(
                  height: _readabilityHeight,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Theme.of(context).colorScheme.surface,
                          Theme.of(
                            context,
                          ).colorScheme.surface.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
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
