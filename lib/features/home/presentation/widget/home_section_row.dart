import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_steam_tv/features/home/domain/model/home_item.dart';
import 'package:flutter_steam_tv/features/home/domain/model/home_section.dart';
import 'package:flutter_steam_tv/features/home/presentation/widget/home_content_card.dart';

final class HomeSectionRow extends StatefulWidget {
  const HomeSectionRow({
    required this.section,
    required this.autofocusFirstItem,
    required this.onItemPressed,
    super.key,
  });

  final HomeSection section;
  final bool autofocusFirstItem;
  final ValueChanged<HomeItem> onItemPressed;

  @override
  State<HomeSectionRow> createState() => _HomeSectionRowState();
}

final class _HomeSectionRowState extends State<HomeSectionRow> {
  late List<FocusNode> _focusNodes = _createFocusNodes();

  @override
  void didUpdateWidget(HomeSectionRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.section.items.length != widget.section.items.length) {
      _disposeFocusNodes();
      _focusNodes = _createFocusNodes();
    }
  }

  @override
  void dispose() {
    _disposeFocusNodes();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Padding(
            padding: const .symmetric(horizontal: 48),
            child: Text(
              widget.section.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView.separated(
              scrollDirection: .horizontal,
              padding: const .symmetric(horizontal: 48),
              itemCount: widget.section.items.length,
              separatorBuilder: (_, _) => const SizedBox(width: 18),
              itemBuilder: (context, index) {
                final item = widget.section.items[index];
                return HomeContentCard(
                  item: item,
                  focusNode: _focusNodes[index],
                  onKeyEvent: (_, event) => _handleHorizontalKey(index, event),
                  autofocus: widget.autofocusFirstItem && index == 0,
                  onPressed: () => widget.onItemPressed(item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  KeyEventResult _handleHorizontalKey(int index, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return .ignored;
    }

    final offset = switch (event.logicalKey) {
      LogicalKeyboardKey.arrowLeft => -1,
      LogicalKeyboardKey.arrowRight => 1,
      _ => 0,
    };
    final targetIndex = index + offset;
    if (offset == 0 || targetIndex < 0 || targetIndex >= _focusNodes.length) {
      return .ignored;
    }

    final targetNode = _focusNodes[targetIndex]..requestFocus();
    if (targetNode.context case final targetContext?) {
      unawaited(
        Scrollable.ensureVisible(
          targetContext,
          duration: const Duration(milliseconds: 190),
          curve: Curves.easeOut,
        ),
      );
    }
    return .handled;
  }

  List<FocusNode> _createFocusNodes() {
    return List.generate(
      widget.section.items.length,
      (index) => FocusNode(
        debugLabel: '${widget.section.id}:${widget.section.items[index].id}',
      ),
      growable: false,
    );
  }

  void _disposeFocusNodes() {
    for (final node in _focusNodes) {
      node.dispose();
    }
  }
}
