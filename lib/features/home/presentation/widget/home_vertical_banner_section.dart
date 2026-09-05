import 'dart:async';
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_colors.dart';
import 'package:flutter_steam_tv/features/home/domain/model/home_item.dart';
import 'package:flutter_steam_tv/features/home/presentation/widget/home_banner_info.dart';
import 'package:flutter_steam_tv/features/home/presentation/widget/home_network_image.dart';

final class HomeVerticalBannerSection extends StatefulWidget {
  const HomeVerticalBannerSection({
    required this.items,
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
  final FocusNode focusNode;
  final int initialSelectedIndex;
  final bool autofocus;
  final VoidCallback onFocused;
  final ValueChanged<int> onSelectedIndexChanged;
  final ValueChanged<HomeItem> onItemPressed;
  final bool autoPlay;

  @override
  State<HomeVerticalBannerSection> createState() =>
      _HomeVerticalBannerSectionState();
}

final class _HomeVerticalBannerSectionState
    extends State<HomeVerticalBannerSection>
    with WidgetsBindingObserver {
  static const double _sectionHeight = 420;
  static const double _carouselHeight = 330;
  static const double _carouselViewportFraction = 0.20;
  static const int _loopMultiplier = 100;
  static const Duration _moveDuration = Duration(milliseconds: 240);
  static const Duration _autoPlayInterval = Duration(seconds: 5);

  late PageController _pageController;
  late int _selectedIndex;
  late int _virtualIndex;
  Timer? _timer;
  bool _hasFocus = false;
  bool _isAnimating = false;
  bool _isAppActive = true;

  bool get _canLoop => widget.items.length >= 5;
  int get _virtualItemCount =>
      _canLoop ? widget.items.length * _loopMultiplier : widget.items.length;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _selectedIndex = _clampIndex(widget.initialSelectedIndex);
    _virtualIndex = _initialVirtualIndex(_selectedIndex);
    _pageController = _createPageController();
    _restartTimer();
  }

  @override
  void didUpdateWidget(HomeVerticalBannerSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length) {
      _selectedIndex = _clampIndex(_selectedIndex);
      _virtualIndex = _initialVirtualIndex(_selectedIndex);
      _pageController.dispose();
      _pageController = _createPageController();
    }
    _restartTimer();
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
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }
    final activeItem = widget.items[_selectedIndex];
    final viewportWidth = MediaQuery.sizeOf(context).width;

    return SizedBox(
      key: const ValueKey('home-vertical-banner-container'),
      height: _sectionHeight,
      child: Focus(
        key: const ValueKey('home-vertical-banner-focus'),
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
              const ColoredBox(color: StreamTvColors.background),
              Positioned(
                top: 0,
                right: 0,
                bottom: 0,
                width: viewportWidth * 0.58,
                child: _VerticalBannerArtworkBackground(item: activeItem),
              ),
              const _VerticalBannerBackdrop(),
              Positioned(
                left: 48,
                top: 0,
                bottom: 0,
                width: viewportWidth * 0.36,
                child: Align(
                  alignment: .centerLeft,
                  child: HomeBannerInfo(
                    item: activeItem,
                    itemCount: widget.items.length,
                    selectedIndex: _selectedIndex,
                    isFocused: _hasFocus,
                    maxWidth: 470,
                  ),
                ),
              ),
              Positioned(
                top: (_sectionHeight - _carouselHeight) / 2,
                right: 22,
                width: viewportWidth * 0.56,
                height: _carouselHeight,
                child: _buildCarousel(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarousel() {
    return ExcludeFocus(
      child: PageView.builder(
        key: const ValueKey('home-vertical-banner-list'),
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _virtualItemCount,
        itemBuilder: (context, virtualIndex) {
          final item = widget.items[virtualIndex % widget.items.length];
          return AnimatedBuilder(
            animation: _pageController,
            child: _VerticalBannerCard(
              key: ValueKey('home-vertical-banner-card-$virtualIndex'),
              item: item,
              isFocused: _hasFocus && virtualIndex == _virtualIndex,
            ),
            builder: (context, child) {
              final distance = (_currentPage - virtualIndex).abs().clamp(
                0.0,
                2.0,
              );
              final fraction = distance / 1.5;
              final scale = lerpDouble(1.0, 0.72, fraction)!;
              return Transform.scale(
                scale: scale,
                child: Opacity(opacity: 1, child: child),
              );
            },
          );
        },
      ),
    );
  }

  double get _currentPage {
    if (!_pageController.hasClients ||
        !_pageController.position.hasContentDimensions) {
      return _virtualIndex.toDouble();
    }
    return _pageController.page ?? _virtualIndex.toDouble();
  }

  PageController _createPageController() {
    return PageController(
      initialPage: _virtualIndex,
      viewportFraction: _carouselViewportFraction,
    );
  }

  int _initialVirtualIndex(int selectedIndex) {
    if (!_canLoop) {
      return selectedIndex;
    }
    final middle = _virtualItemCount ~/ 2;
    return middle - middle % widget.items.length + selectedIndex;
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

  KeyEventResult _activateSelection() {
    if (!_isAnimating) {
      widget.onItemPressed(widget.items[_selectedIndex]);
    }
    return .handled;
  }

  KeyEventResult _moveSelection(int delta) {
    if (_isAnimating) {
      return .handled;
    }
    final nextIndex = _selectedIndex + delta;
    if (!_canLoop && (nextIndex < 0 || nextIndex >= widget.items.length)) {
      return .handled;
    }

    setState(() {
      _selectedIndex = (nextIndex + widget.items.length) % widget.items.length;
      _virtualIndex += delta;
      _isAnimating = true;
    });
    widget.onSelectedIndexChanged(_selectedIndex);
    unawaited(_animateToSelection());
    return .handled;
  }

  Future<void> _animateToSelection() async {
    if (!_pageController.hasClients) {
      if (mounted) {
        setState(() => _isAnimating = false);
      }
      return;
    }
    await _pageController.animateToPage(
      _virtualIndex,
      duration: _moveDuration,
      curve: Curves.easeOutCubic,
    );
    if (!mounted) {
      return;
    }
    setState(() => _isAnimating = false);
    _restartTimer();
  }

  void _restartTimer() {
    _timer?.cancel();
    if (!widget.autoPlay ||
        !_canLoop ||
        !_isAppActive ||
        _hasFocus ||
        _isAnimating) {
      return;
    }
    _timer = Timer(_autoPlayInterval, () {
      if (mounted) {
        _moveSelection(1);
      }
    });
  }
}

final class _VerticalBannerArtworkBackground extends StatelessWidget {
  const _VerticalBannerArtworkBackground({required this.item});

  final HomeItem item;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      key: const ValueKey('home-vertical-banner-background'),
      child: Stack(
        fit: .expand,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            child: Opacity(
              key: ValueKey('home-vertical-background-${item.id}'),
              opacity: 0.38,
              child: HomeNetworkImage(
                imageUrl: item.thumbnailUrl,
                semanticLabel: item.title,
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  StreamTvColors.background,
                  StreamTvColors.background.withValues(alpha: 0.56),
                  Colors.transparent,
                ],
                stops: const [0, 0.20, 0.52],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: .topCenter,
                end: .bottomCenter,
                colors: [
                  StreamTvColors.background,
                  Colors.transparent,
                  StreamTvColors.background,
                ],
                stops: const [0, 0.46, 1],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final class _VerticalBannerCard extends StatelessWidget {
  const _VerticalBannerCard({
    required this.item,
    required this.isFocused,
    super.key,
  });

  final HomeItem item;
  final bool isFocused;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 2 / 3,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          foregroundDecoration: BoxDecoration(
            border: Border.all(
              color: isFocused
                  ? StreamTvColors.primary
                  : Colors.white.withValues(alpha: 0.14),
              width: isFocused ? 3 : 1,
            ),
            borderRadius: .circular(8),
          ),
          child: ClipRRect(
            borderRadius: .circular(8),
            child: ColoredBox(
              color: StreamTvColors.surface,
              child: HomeNetworkImage(
                imageUrl: item.thumbnailUrl,
                semanticLabel: item.title,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final class _VerticalBannerBackdrop extends StatelessWidget {
  const _VerticalBannerBackdrop();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: .expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                StreamTvColors.background,
                StreamTvColors.background.withValues(alpha: 0.74),
                Colors.transparent,
              ],
              stops: const [0, 0.42, 0.78],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: .topCenter,
              end: .bottomCenter,
              colors: [
                StreamTvColors.background,
                Colors.transparent,
                StreamTvColors.background,
              ],
              stops: const [0, 0.48, 1],
            ),
          ),
        ),
      ],
    );
  }
}
