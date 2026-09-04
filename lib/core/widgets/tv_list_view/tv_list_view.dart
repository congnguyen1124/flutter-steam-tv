import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Marker node used by an app shell to enter a TV list without knowing its rows.
final class TvListViewEntryFocusNode extends FocusNode {
  TvListViewEntryFocusNode() : super(debugLabel: 'tv-list-view-entry');
}

/// A lazy TV list that keeps focused middle items at a stable viewport anchor.
final class TvListView extends StatefulWidget {
  const TvListView.builder({
    required this.itemCount,
    required this.itemBuilder,
    this.controller,
    this.padding,
    this.physics,
    this.scrollCacheExtent,
    this.focusedItemAlignment = 0.5,
    this.focusScrollDuration = const Duration(milliseconds: 220),
    this.verticalNavigationInterval = const Duration(milliseconds: 280),
    this.onFocusedItemChanged,
    super.key,
  }) : separatorBuilder = null;

  const TvListView.separated({
    required this.itemCount,
    required this.itemBuilder,
    required this.separatorBuilder,
    this.controller,
    this.padding,
    this.physics,
    this.scrollCacheExtent,
    this.focusedItemAlignment = 0.5,
    this.focusScrollDuration = const Duration(milliseconds: 220),
    this.verticalNavigationInterval = const Duration(milliseconds: 280),
    this.onFocusedItemChanged,
    super.key,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final IndexedWidgetBuilder? separatorBuilder;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final ScrollCacheExtent? scrollCacheExtent;
  final double focusedItemAlignment;
  final Duration focusScrollDuration;
  final Duration verticalNavigationInterval;
  final ValueChanged<int>? onFocusedItemChanged;

  @override
  State<TvListView> createState() => _TvListViewState();
}

final class _TvListViewState extends State<TvListView> {
  late final TvListViewEntryFocusNode _entryFocusNode =
      TvListViewEntryFocusNode();
  late ScrollController _scrollController =
      widget.controller ?? ScrollController();
  Timer? _verticalNavigationLock;
  int? _focusedIndex;

  @override
  void didUpdateWidget(TvListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (oldWidget.controller == null) {
        _scrollController.dispose();
      }
      _scrollController = widget.controller ?? ScrollController();
    }
    if (widget.itemCount == 0) {
      _focusedIndex = null;
    } else if (_focusedIndex case final index? when index >= widget.itemCount) {
      _focusedIndex = widget.itemCount - 1;
    }
  }

  @override
  void dispose() {
    _verticalNavigationLock?.cancel();
    _entryFocusNode.dispose();
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      key: const ValueKey('tv-list-view-entry-focus'),
      focusNode: _entryFocusNode,
      onFocusChange: _handleEntryFocusChanged,
      onKeyEvent: _handleVerticalKeyEvent,
      child: _buildList(),
    );
  }

  Widget _buildList() {
    final separatorBuilder = widget.separatorBuilder;
    if (separatorBuilder == null) {
      return ListView.builder(
        key: const ValueKey('tv-list-view-builder'),
        controller: _scrollController,
        padding: widget.padding,
        physics: widget.physics,
        scrollCacheExtent: widget.scrollCacheExtent,
        itemCount: widget.itemCount,
        itemBuilder: _buildTrackedItem,
      );
    }

    return ListView.separated(
      key: const ValueKey('tv-list-view-separated'),
      controller: _scrollController,
      padding: widget.padding,
      physics: widget.physics,
      scrollCacheExtent: widget.scrollCacheExtent,
      itemCount: widget.itemCount,
      itemBuilder: _buildTrackedItem,
      separatorBuilder: separatorBuilder,
    );
  }

  Widget _buildTrackedItem(BuildContext context, int index) {
    return _TvListItemMarker(
      index: index,
      child: Builder(
        builder: (itemContext) {
          return Focus(
            canRequestFocus: false,
            onFocusChange: (hasFocus) {
              if (hasFocus) {
                _handleItemFocused(itemContext, index);
              }
            },
            child: widget.itemBuilder(context, index),
          );
        },
      ),
    );
  }

  void _handleEntryFocusChanged(bool hasFocus) {
    if (hasFocus && _entryFocusNode.hasPrimaryFocus) {
      unawaited(_focusFirstItem());
    }
  }

  KeyEventResult _handleVerticalKeyEvent(FocusNode node, KeyEvent event) {
    if ((event is! KeyDownEvent && event is! KeyRepeatEvent) ||
        (event.logicalKey != LogicalKeyboardKey.arrowUp &&
            event.logicalKey != LogicalKeyboardKey.arrowDown)) {
      return .ignored;
    }
    if (_verticalNavigationLock?.isActive ?? false) {
      return .handled;
    }

    _verticalNavigationLock = Timer(widget.verticalNavigationInterval, () {});
    return .ignored;
  }

  Future<void> _focusFirstItem() async {
    if (widget.itemCount == 0) {
      return;
    }
    if (_scrollController.hasClients && _scrollController.offset != 0) {
      _scrollController.jumpTo(0);
    }
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted || !_entryFocusNode.hasPrimaryFocus) {
      return;
    }

    for (final node in _entryFocusNode.traversalDescendants) {
      if (node is FocusScopeNode ||
          !node.canRequestFocus ||
          !(node.context?.mounted ?? false) ||
          _itemIndexOf(node.context) != 0) {
        continue;
      }
      node.requestFocus();
      return;
    }
  }

  int? _itemIndexOf(BuildContext? context) {
    final marker = context
        ?.getElementForInheritedWidgetOfExactType<_TvListItemMarker>()
        ?.widget;
    return marker is _TvListItemMarker ? marker.index : null;
  }

  void _handleItemFocused(BuildContext itemContext, int index) {
    if (_focusedIndex == index) {
      return;
    }
    _focusedIndex = index;
    widget.onFocusedItemChanged?.call(index);

    final alignment = switch (index) {
      0 => 0.0,
      _ when index == widget.itemCount - 1 => 1.0,
      _ => widget.focusedItemAlignment,
    };
    unawaited(
      Scrollable.ensureVisible(
        itemContext,
        alignment: alignment,
        duration: widget.focusScrollDuration,
        curve: Curves.easeOutCubic,
      ),
    );
  }
}

final class _TvListItemMarker extends InheritedWidget {
  const _TvListItemMarker({required this.index, required super.child});

  final int index;

  @override
  bool updateShouldNotify(_TvListItemMarker oldWidget) {
    return index != oldWidget.index;
  }
}
