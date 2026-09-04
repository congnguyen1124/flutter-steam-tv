import 'package:flutter/material.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_colors.dart';
import 'package:flutter_steam_tv/core/widgets/steam_top_bar_item.dart';
import 'package:flutter_svg/flutter_svg.dart';

final class SteamTopBarProfileButton extends StatelessWidget {
  const SteamTopBarProfileButton({
    required this.item,
    required this.focusNode,
    required this.isSelected,
    required this.onFocusChanged,
    required this.onKeyEvent,
    required this.onPressed,
    super.key,
  });

  final SteamTopBarItem item;
  final FocusNode focusNode;
  final bool isSelected;
  final ValueChanged<bool> onFocusChanged;
  final FocusOnKeyEventCallback onKeyEvent;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Focus(
      canRequestFocus: false,
      onKeyEvent: onKeyEvent,
      child: Semantics(
        button: true,
        selected: isSelected,
        label: item.label,
        child: InkWell(
          focusNode: focusNode,
          onFocusChange: onFocusChanged,
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: AnimatedContainer(
            width: 38,
            height: 38,
            duration: const Duration(milliseconds: 150),
            padding: const .all(8),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primary.withValues(alpha: 0.16)
                  : Colors.transparent,
              border: Border.all(
                color: focusNode.hasFocus
                    ? colorScheme.primary
                    : isSelected
                    ? colorScheme.primary.withValues(alpha: 0.36)
                    : Colors.transparent,
                width: 2,
              ),
              shape: .circle,
            ),
            child: SvgPicture.asset(
              item.iconAsset,
              colorFilter: ColorFilter.mode(
                focusNode.hasFocus || isSelected
                    ? colorScheme.primary
                    : StreamTvColors.onSurfaceMuted,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
