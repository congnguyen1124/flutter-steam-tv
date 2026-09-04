import 'package:flutter/material.dart';
import 'package:flutter_steam_tv/core/widgets/steam_top_bar.dart';
import 'package:flutter_steam_tv/features/main/presentation/navigation/main_top_bar_items.dart';

final class MainScreen extends StatefulWidget {
  const MainScreen({
    required this.currentPath,
    required this.onNavigate,
    required this.child,
    super.key,
  });

  final String currentPath;
  final ValueChanged<String> onNavigate;
  final Widget child;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

final class _MainScreenState extends State<MainScreen> {
  static const Duration _overlayDuration = Duration(milliseconds: 160);
  static const double _contentTopInset = 78;

  bool _isTopBarFocused = false;

  @override
  Widget build(BuildContext context) {
    final selectedItem = MainTopBarItems.itemForPath(widget.currentPath);

    return Scaffold(
      body: Stack(
        fit: .expand,
        children: [
          Positioned.fill(
            child: Padding(
              padding: const .only(top: _contentTopInset),
              child: widget.child,
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
                items: MainTopBarItems.defaults,
                selectedItemId: selectedItem.id,
                onFocusChanged: (hasFocus) {
                  if (_isTopBarFocused != hasFocus) {
                    setState(() => _isTopBarFocused = hasFocus);
                  }
                },
                onItemPressed: (item) {
                  final path = MainTopBarItems.pathFor(item);
                  if (path != widget.currentPath) {
                    widget.onNavigate(path);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
