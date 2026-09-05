import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_colors.dart';

typedef ListContentIndexedWidgetBuilder =
    Widget Function(BuildContext context, int index, bool isSelected);

/// A horizontal lazy list whose items move under one fixed TV focus target.
final class ListContentView extends StatefulWidget {
  const ListContentView.builder({
    required this.itemCount,
    required this.focusNode,
    required this.itemWidth,
    required this.itemHeight,
    required this.itemBuilder,
    required this.onSelectedItemPressed,
    this.autofocus = false,
    this.selectionHeight,
    this.selectionLeadingInset = 0,
    this.selectionWidth,
    this.contentPadding = const .symmetric(horizontal: 48),
    this.initialSelectedIndex = 0,
    this.loopingEnabled = true,
    this.onFocusChanged,
    this.onSelectedIndexChanged,
    this.semanticLabelBuilder,
    super.key,
  }) : separatorBuilder = null,
       separatorExtent = 0;

  const ListContentView.separated({
    required this.itemCount,
    required this.focusNode,
    required this.itemWidth,
    required this.itemHeight,
    required this.itemBuilder,
    required this.separatorBuilder,
    required this.separatorExtent,
    required this.onSelectedItemPressed,
    this.autofocus = false,
    this.selectionHeight,
    this.selectionLeadingInset = 0,
    this.selectionWidth,
    this.contentPadding = const .symmetric(horizontal: 48),
    this.initialSelectedIndex = 0,
    this.loopingEnabled = true,
    this.onFocusChanged,
    this.onSelectedIndexChanged,
    this.semanticLabelBuilder,
    super.key,
  }) : assert(separatorExtent >= 0);

  final int itemCount;
  final FocusNode focusNode;
  final double itemWidth;
  final double itemHeight;
  final double? selectionHeight;
  final double selectionLeadingInset;
  final double? selectionWidth;
  final ListContentIndexedWidgetBuilder itemBuilder;
  final IndexedWidgetBuilder? separatorBuilder;
  final double separatorExtent;
  final ValueChanged<int> onSelectedItemPressed;
  final bool autofocus;
  final EdgeInsets contentPadding;
  final int initialSelectedIndex;
  final bool loopingEnabled;
  final ValueChanged<bool>? onFocusChanged;
  final ValueChanged<int>? onSelectedIndexChanged;
  final String Function(int index)? semanticLabelBuilder;

  @override
  State<ListContentView> createState() => _ListContentViewState();
}

final class _ListContentViewState extends State<ListContentView> {
  static const Duration _selectionDuration = Duration(milliseconds: 190);
  static const double _selectionPadding = 2;

  late final ScrollController _scrollController = ScrollController();
  late int _selectedIndex;
  late int _virtualIndex;
  bool _hasFocus = false;
  bool _isAnimating = false;

  bool get _canLoop => widget.loopingEnabled && widget.itemCount > 5;
  double get _itemExtent => widget.itemWidth + widget.separatorExtent;

  @override
  void initState() {
    super.initState();
    _selectedIndex = _clampIndex(widget.initialSelectedIndex);
    _virtualIndex = _selectedIndex;
  }

  @override
  void didUpdateWidget(ListContentView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.itemCount != widget.itemCount ||
        oldWidget.itemWidth != widget.itemWidth ||
        oldWidget.separatorExtent != widget.separatorExtent) {
      _selectedIndex = _clampIndex(_selectedIndex);
      _virtualIndex = _selectedIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToSelection());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itemCount == 0) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: widget.itemHeight + _selectionPadding * 2,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final trailingPadding =
              (constraints.maxWidth -
                      widget.contentPadding.left -
                      widget.itemWidth -
                      _selectionPadding)
                  .clamp(widget.contentPadding.right, double.infinity);

          return Focus(
            key: ValueKey(
              'list-content-view-focus-${widget.focusNode.debugLabel}',
            ),
            focusNode: widget.focusNode,
            autofocus: widget.autofocus,
            onFocusChange: _handleFocusChanged,
            onKeyEvent: _handleKeyEvent,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: ExcludeFocus(
                    child: ListView.builder(
                      key: ValueKey(
                        'list-content-view-${widget.focusNode.debugLabel}',
                      ),
                      controller: _scrollController,
                      scrollDirection: .horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: .only(
                        left: widget.contentPadding.left + _selectionPadding,
                        right: trailingPadding,
                        top: _selectionPadding,
                        bottom: _selectionPadding,
                      ),
                      scrollCacheExtent: .pixels(_itemExtent * 2),
                      itemCount: _canLoop
                          ? widget.itemCount * 2
                          : widget.itemCount,
                      itemExtent: _itemExtent,
                      itemBuilder: _buildVirtualItem,
                    ),
                  ),
                ),
                Positioned(
                  left:
                      widget.contentPadding.left + widget.selectionLeadingInset,
                  top: 0,
                  width:
                      (widget.selectionWidth ?? widget.itemWidth) +
                      _selectionPadding * 2,
                  height:
                      (widget.selectionHeight ?? widget.itemHeight) +
                      _selectionPadding * 2,
                  child: Semantics(
                    button: true,
                    selected: _hasFocus,
                    label: _selectedSemanticsLabel,
                    onTap: _activateSelection,
                    child: GestureDetector(
                      behavior: .opaque,
                      onTap: _activateSelection,
                      child: AnimatedContainer(
                        key: const ValueKey(
                          'list-content-view-selection-frame',
                        ),
                        duration: const Duration(milliseconds: 140),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _hasFocus
                                ? StreamTvColors.surfaceFocused
                                : Colors.transparent,
                            width: 3,
                          ),
                          borderRadius: .circular(6),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVirtualItem(BuildContext context, int virtualIndex) {
    final index = virtualIndex % widget.itemCount;
    return Row(
      children: [
        SizedBox(
          width: widget.itemWidth,
          height: widget.itemHeight,
          child: KeyedSubtree(
            key: ValueKey('list-content-view-item-$index'),
            child: widget.itemBuilder(context, index, index == _selectedIndex),
          ),
        ),
        if (widget.separatorBuilder case final builder?)
          SizedBox(
            width: widget.separatorExtent,
            height: widget.itemHeight,
            child: builder(context, index),
          ),
      ],
    );
  }

  String get _selectedSemanticsLabel {
    return widget.semanticLabelBuilder?.call(_selectedIndex) ??
        'Selected item ${_selectedIndex + 1} of ${widget.itemCount}';
  }

  int _clampIndex(int index) {
    if (widget.itemCount == 0) {
      return 0;
    }
    return index.clamp(0, widget.itemCount - 1);
  }

  void _handleFocusChanged(bool hasFocus) {
    if (_hasFocus != hasFocus) {
      setState(() => _hasFocus = hasFocus);
    }
    widget.onFocusChanged?.call(hasFocus);
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
    if (!_isAnimating && widget.itemCount > 0) {
      widget.onSelectedItemPressed(_selectedIndex);
    }
    return .handled;
  }

  KeyEventResult _moveSelection(int delta) {
    if (_isAnimating) {
      return .handled;
    }
    if (delta < 0 && _selectedIndex == 0) {
      return .ignored;
    }
    if (delta > 0 && _selectedIndex == widget.itemCount - 1) {
      if (!_canLoop) {
        return .handled;
      }
      _startMove(nextSelectedIndex: 0, nextVirtualIndex: _virtualIndex + 1);
      return .handled;
    }

    _startMove(
      nextSelectedIndex: _selectedIndex + delta,
      nextVirtualIndex: _virtualIndex + delta,
    );
    return .handled;
  }

  void _startMove({
    required int nextSelectedIndex,
    required int nextVirtualIndex,
  }) {
    setState(() {
      _selectedIndex = nextSelectedIndex;
      _virtualIndex = nextVirtualIndex;
      _isAnimating = true;
    });
    widget.onSelectedIndexChanged?.call(_selectedIndex);
    unawaited(
      _animateToSelection(resetLoop: _virtualIndex >= widget.itemCount),
    );
  }

  Future<void> _animateToSelection({required bool resetLoop}) async {
    if (!_scrollController.hasClients) {
      if (mounted) {
        setState(() => _isAnimating = false);
      }
      return;
    }

    await _scrollController.animateTo(
      _virtualIndex * _itemExtent,
      duration: _selectionDuration,
      curve: Curves.easeOutCubic,
    );
    if (!mounted) {
      return;
    }
    if (resetLoop) {
      _virtualIndex = 0;
      _scrollController.jumpTo(0);
    }
    setState(() => _isAnimating = false);
  }

  void _jumpToSelection() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_virtualIndex * _itemExtent);
    }
  }
}
