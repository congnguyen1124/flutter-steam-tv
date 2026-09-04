import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_colors.dart';
import 'package:flutter_steam_tv/features/home/domain/model/home_item.dart';
import 'package:flutter_steam_tv/features/home/presentation/widget/home_banner_info.dart';
import 'package:flutter_steam_tv/features/home/presentation/widget/home_network_image.dart';

final class HomeHeroSection extends StatefulWidget {
  const HomeHeroSection({
    required this.items,
    required this.height,
    required this.focusNode,
    required this.initialSelectedIndex,
    required this.autofocus,
    required this.onFocused,
    required this.onSelectedIndexChanged,
    required this.onItemPressed,
    this.autoPlay = true,
    super.key,
  });

  final List<HomeItem> items;
  final double height;
  final FocusNode focusNode;
  final int initialSelectedIndex;
  final bool autofocus;
  final VoidCallback onFocused;
  final ValueChanged<int> onSelectedIndexChanged;
  final ValueChanged<HomeItem> onItemPressed;
  final bool autoPlay;

  @override
  State<HomeHeroSection> createState() => _HomeHeroSectionState();
}

final class _HomeHeroSectionState extends State<HomeHeroSection>
    with WidgetsBindingObserver {
  static const Duration _autoPlayInterval = Duration(seconds: 5);

  late int _selectedIndex;
  Timer? _timer;
  bool _hasFocus = false;
  bool _isAppActive = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _selectedIndex = _clampIndex(widget.initialSelectedIndex);
    _restartTimer();
  }

  @override
  void didUpdateWidget(HomeHeroSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length ||
        oldWidget.autoPlay != widget.autoPlay) {
      _selectedIndex = _clampIndex(_selectedIndex);
      _restartTimer();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isAppActive = state == .resumed;
    _restartTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }
    final activeItem = widget.items[_selectedIndex];

    return SizedBox(
      key: const ValueKey('home-hero-container'),
      height: widget.height,
      child: Focus(
        key: const ValueKey('home-hero-focus'),
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        onFocusChange: _handleFocusChanged,
        onKeyEvent: _handleKeyEvent,
        child: GestureDetector(
          behavior: .opaque,
          onTap: _activateSelection,
          child: Stack(
            fit: .expand,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: HomeNetworkImage(
                  key: ValueKey('home-hero-image-${activeItem.id}'),
                  imageUrl: activeItem.thumbnailUrl,
                  semanticLabel: activeItem.title,
                ),
              ),
              const _HeroGradients(),
              Align(
                alignment: .bottomLeft,
                child: Padding(
                  padding: const .only(left: 48, right: 48, bottom: 30),
                  child: SizedBox(
                    width: 540,
                    child: HomeBannerInfo(
                      item: activeItem,
                      itemCount: widget.items.length,
                      selectedIndex: _selectedIndex,
                      isFocused: _hasFocus,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _clampIndex(int index) {
    if (widget.items.isEmpty) {
      return 0;
    }
    return index.clamp(0, widget.items.length - 1);
  }

  void _handleFocusChanged(bool hasFocus) {
    if (_hasFocus != hasFocus) {
      setState(() => _hasFocus = hasFocus);
    }
    if (hasFocus) {
      widget.onFocused();
    }
    _restartTimer();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return .ignored;
    }
    return switch (event.logicalKey) {
      LogicalKeyboardKey.arrowLeft => _moveSelection(-1),
      LogicalKeyboardKey.arrowRight => _moveSelection(1),
      LogicalKeyboardKey.enter ||
      LogicalKeyboardKey.select ||
      LogicalKeyboardKey.numpadEnter => _activateSelection(),
      _ => .ignored,
    };
  }

  KeyEventResult _moveSelection(int delta) {
    final nextIndex = (_selectedIndex + delta) % widget.items.length;
    _select(nextIndex);
    return .handled;
  }

  KeyEventResult _activateSelection() {
    widget.onItemPressed(widget.items[_selectedIndex]);
    return .handled;
  }

  void _select(int index) {
    if (index == _selectedIndex) {
      return;
    }
    setState(() => _selectedIndex = index);
    widget.onSelectedIndexChanged(index);
    _restartTimer();
  }

  void _restartTimer() {
    _timer?.cancel();
    if (!widget.autoPlay ||
        !_isAppActive ||
        _hasFocus ||
        widget.items.length < 2) {
      return;
    }
    _timer = Timer(_autoPlayInterval, () {
      if (mounted) {
        _select((_selectedIndex + 1) % widget.items.length);
      }
    });
  }
}

final class _HeroGradients extends StatelessWidget {
  const _HeroGradients();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: .expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withValues(alpha: 0.88),
                Colors.black.withValues(alpha: 0.28),
                Colors.transparent,
              ],
              stops: const [0, 0.48, 0.82],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: .topCenter,
              end: .bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.40),
                Colors.transparent,
                StreamTvColors.background,
              ],
              stops: const [0, 0.52, 1],
            ),
          ),
        ),
      ],
    );
  }
}
