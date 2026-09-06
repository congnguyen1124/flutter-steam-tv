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
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  static const double _sectionHeight = 420;
  static const double _carouselHeight = 330;
  static const Duration _moveDuration = Duration(milliseconds: 240);
  static const Duration _autoPlayInterval = Duration(seconds: 5);

  /// Width of the centred card. Every other card is this width times its scale.
  static const double _cardWidth = 150;

  /// Portrait cards, so height follows width.
  static const double _cardAspectRatio = 2 / 3;

  /// The gap held between every pair of neighbouring cards, whatever their scale.
  static const double _cardGap = 12;

  /// Scale of a card two steps out. Reached by extrapolation, not by clamping — see [_scaleFor].
  static const double _minScale = 0.72;

  /// How many steps out the scale ramp is measured over.
  static const double _scaleFalloff = 1.5;

  /// Alpha of the scrim over every card that is not the centred one.
  static const double _dimAlpha = 0.30;

  late final AnimationController _moveController = AnimationController(
    vsync: this,
    duration: _moveDuration,
  );
  late Animation<double> _pageAnimation;
  late int _selectedIndex;
  late int _virtualIndex;
  Timer? _timer;
  bool _hasFocus = false;
  bool _isAnimating = false;
  bool _isAppActive = true;

  bool get _canLoop => widget.items.length >= 5;

  /// Where the strip currently sits, in cards. Fractional while a move animates.
  double get _page => _pageAnimation.value;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _selectedIndex = _clampIndex(widget.initialSelectedIndex);
    _virtualIndex = _selectedIndex;
    _pageAnimation = AlwaysStoppedAnimation(_virtualIndex.toDouble());
    _restartTimer();
  }

  @override
  void didUpdateWidget(HomeVerticalBannerSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length) {
      _selectedIndex = _clampIndex(_selectedIndex);
      _virtualIndex = _selectedIndex;
      _moveController.stop();
      _pageAnimation = AlwaysStoppedAnimation(_virtualIndex.toDouble());
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
    _moveController.dispose();
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
                width: viewportWidth * 0.72,
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

  /// Lays the strip out by accumulated width rather than into fixed slots.
  ///
  /// ## Why not a `PageView`
  ///
  /// A `PageView` gives every page the same slot width, and a card scaled down inside its slot
  /// leaves the leftover as empty space. The visible gap between two cards is therefore
  /// `slot - (widthA + widthB) / 2`, which **grows the further out a pair sits**: at the previous
  /// settings the centre pair sat about 13 apart and the next pair about 40. No amount of tuning
  /// fixes that, because the gap is whatever the scale ramp leaves over.
  ///
  /// Placing each card at its neighbour's edge plus a fixed [_cardGap] inverts the relationship —
  /// the gap is the input and the positions fall out of it — so every pair sits the same distance
  /// apart no matter how far down the scale ramp it is.
  Widget _buildCarousel() {
    return ExcludeFocus(
      child: ClipRect(
        child: LayoutBuilder(
          builder: (context, constraints) => AnimatedBuilder(
            animation: _moveController,
            builder: (context, _) =>
                _buildStrip(width: constraints.maxWidth, height: constraints.maxHeight),
          ),
        ),
      ),
    );
  }

  Widget _buildStrip({required double width, required double height}) {
    final page = _page;
    final base = page.floor();
    // One more than fills the viewport at the smallest scale, so a card is never missing at an edge
    // mid-animation.
    final span = (width / (_cardWidth * _minScale + _cardGap)).ceil() + 1;

    final offsets = <int, double>{base: 0};
    for (var index = base + 1; index <= base + span; index++) {
      offsets[index] =
          offsets[index - 1]! +
          _halfWidth(index - 1, page) +
          _cardGap +
          _halfWidth(index, page);
    }
    for (var index = base - 1; index >= base - span; index--) {
      offsets[index] =
          offsets[index + 1]! -
          _halfWidth(index + 1, page) -
          _cardGap -
          _halfWidth(index, page);
    }

    // The strip is anchored on the fractional page, not on the nearest whole card, so it glides
    // rather than snapping as `page` crosses an integer.
    final anchor = lerpDouble(offsets[base]!, offsets[base + 1]!, page - base)!;
    final cardHeight = _cardWidth / _cardAspectRatio;

    return Stack(
      key: const ValueKey('home-vertical-banner-list'),
      clipBehavior: Clip.none,
      children: [
        for (final entry in offsets.entries)
          if (_isDrawable(entry.key))
            Positioned(
              left: width / 2 + entry.value - anchor - _cardWidth / 2,
              top: (height - cardHeight) / 2,
              width: _cardWidth,
              height: cardHeight,
              child: Transform.scale(
                scale: _scaleFor(entry.key - page),
                child: _VerticalBannerCard(
                  key: ValueKey('home-vertical-banner-card-${entry.key}'),
                  item: widget.items[_itemIndex(entry.key)],
                  isFocused: _hasFocus && entry.key == _virtualIndex,
                  // Uniform across every card that is not the centred one, so the strip reads as
                  // one dimmed row with a single lit item rather than as a gradient of importance.
                  // Ramped over the first step out only, so it animates with the move.
                  dimAlpha: _dimAlpha * (entry.key - page).abs().clamp(0.0, 1.0),
                ),
              ),
            ),
      ],
    );
  }

  double _scaleFor(double delta) {
    final distance = delta.abs().clamp(0.0, 2.0);
    return lerpDouble(1.0, _minScale, distance / _scaleFalloff)!;
  }

  double _halfWidth(int index, double page) =>
      _cardWidth * _scaleFor(index - page) / 2;

  /// Whether a virtual index maps onto a real item. Always true while looping.
  bool _isDrawable(int virtualIndex) =>
      _canLoop || (virtualIndex >= 0 && virtualIndex < widget.items.length);

  int _itemIndex(int virtualIndex) {
    final length = widget.items.length;
    return ((virtualIndex % length) + length) % length;
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
    _pageAnimation =
        Tween<double>(
          begin: _page,
          end: _virtualIndex.toDouble(),
        ).animate(
          CurvedAnimation(parent: _moveController, curve: Curves.easeOutCubic),
        );
    await _moveController.forward(from: 0);
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
              opacity: 0.62,
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
                stops: const [0, 0.10, 0.34],
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
                  Colors.transparent,
                  StreamTvColors.background,
                ],
                // A band rather than a single clear point. Two stops meeting at 0.46 meant the
                // artwork was only ever fully visible along one line and faded everywhere else.
                stops: const [0, 0.28, 0.74, 1],
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
    required this.dimAlpha,
    super.key,
  });

  final HomeItem item;
  final bool isFocused;

  /// How heavily to scrim this card. Zero on the centred one, uniform on all the rest.
  final double dimAlpha;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
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
        child: Stack(
          fit: .expand,
          children: [
            ColoredBox(
              color: StreamTvColors.surface,
              child: HomeNetworkImage(
                imageUrl: item.thumbnailUrl,
                semanticLabel: item.title,
              ),
            ),
            // A scrim rather than reduced opacity: opacity would let the section's own background
            // through and tint each thumbnail differently depending on what sits behind it, which
            // is exactly the inconsistency the uniform dimming is meant to remove.
            if (dimAlpha > 0)
              ColoredBox(color: Colors.black.withValues(alpha: dimAlpha)),
          ],
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
                StreamTvColors.background.withValues(alpha: 0.70),
                Colors.transparent,
              ],
              // Still opaque across the info column, which ends around 0.40 of the width, and clear
              // by 0.58 — otherwise this layer spends its fade sitting on top of the artwork and
              // undoes the widening.
              stops: const [0, 0.40, 0.58],
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
