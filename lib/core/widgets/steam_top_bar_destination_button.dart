import 'package:flutter/material.dart';
import 'package:flutter_steam_tv/core/widgets/steam_top_bar_item.dart';
import 'package:flutter_svg/flutter_svg.dart';

final class SteamTopBarDestinationButton extends StatelessWidget {
  const SteamTopBarDestinationButton({
    required this.item,
    required this.focusNode,
    required this.isFocused,
    required this.isSelected,
    required this.onFocusChanged,
    required this.onKeyEvent,
    required this.onPressed,
    super.key,
  });

  final SteamTopBarItem item;
  final FocusNode focusNode;
  final bool isFocused;
  final bool isSelected;
  final ValueChanged<bool> onFocusChanged;
  final FocusOnKeyEventCallback onKeyEvent;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foregroundColor = isFocused
        ? colorScheme.onPrimary
        : isSelected
        ? colorScheme.primary
        : colorScheme.onSurface;

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
          borderRadius: .circular(40),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const .all(8),
            decoration: BoxDecoration(
              color: isFocused
                  ? colorScheme.primary
                  : isSelected
                  ? colorScheme.primary.withValues(alpha: 0.16)
                  : Colors.transparent,
              border: Border.all(
                color: isSelected && !isFocused
                    ? colorScheme.primary.withValues(alpha: 0.36)
                    : Colors.transparent,
              ),
              borderRadius: .circular(40),
            ),
            child: Row(
              mainAxisSize: .min,
              children: [
                SvgPicture.asset(
                  item.iconAsset,
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    foregroundColor,
                    BlendMode.srcIn,
                  ),
                ),
                ClipRect(
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    alignment: .centerLeft,
                    child: isFocused
                        ? Padding(
                            padding: const .only(left: 8, right: 6),
                            child: Text(
                              item.label,
                              style: TextStyle(
                                color: foregroundColor,
                                fontSize: 14,
                                fontWeight: .w500,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
