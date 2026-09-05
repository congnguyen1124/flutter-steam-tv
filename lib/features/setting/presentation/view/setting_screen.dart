import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_steam_tv/core/assets/app_assets.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_colors.dart';
import 'package:flutter_steam_tv/core/widgets/stream_tv_qr_code.dart';

enum _SettingItem {
  manageSubscription('Manage subscription'),
  paymentHistory('Payment history'),
  manageDevices('Manage devices'),
  giftCode('Gift code'),
  termsOfService('Terms of service'),
  privacyPolicy('Privacy policy'),
  sendFeedback('Send feedback'),
  clearSearchHistory('Clear search history'),
  clearWatchHistory('Clear watch history');

  const _SettingItem(this.label);

  final String label;
}

final class SettingScreen extends StatefulWidget {
  const SettingScreen({required this.onOpenSignIn, super.key});

  final VoidCallback onOpenSignIn;

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

final class _SettingScreenState extends State<SettingScreen> {
  final Map<_SettingItem, FocusNode> _menuFocusNodes = {
    for (final item in _SettingItem.values)
      item: FocusNode(debugLabel: 'setting-${item.name}'),
  };
  final FocusNode _detailActionFocusNode = FocusNode(
    debugLabel: 'setting-detail-action',
  );

  _SettingItem _selectedItem = _SettingItem.manageSubscription;
  bool _searchHistoryCleared = false;
  bool _watchHistoryCleared = false;

  @override
  void dispose() {
    for (final node in _menuFocusNodes.values) {
      node.dispose();
    }
    _detailActionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasDetailAction = _hasDetailAction(_selectedItem);

    return ColoredBox(
      key: const ValueKey('setting-screen'),
      color: StreamTvColors.background,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(48, 8, 48, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings',
              style: TextStyle(
                color: StreamTvColors.onSurface,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SettingMenu(
                    selectedItem: _selectedItem,
                    focusNodes: _menuFocusNodes,
                    hasDetailAction: hasDetailAction,
                    detailActionFocusNode: _detailActionFocusNode,
                    onSelectItem: (item) {
                      setState(() => _selectedItem = item);
                    },
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: _SettingDetailPane(
                        key: ValueKey(_selectedItem),
                        selectedItem: _selectedItem,
                        systemInfo: _SystemInfo.current(),
                        detailActionFocusNode: _detailActionFocusNode,
                        menuFocusNode: _menuFocusNodes[_selectedItem]!,
                        searchHistoryCleared: _searchHistoryCleared,
                        watchHistoryCleared: _watchHistoryCleared,
                        onOpenSignIn: widget.onOpenSignIn,
                        onClearSearchHistory: () => _clearHistory(
                          item: _SettingItem.clearSearchHistory,
                          update: () => _searchHistoryCleared = true,
                        ),
                        onClearWatchHistory: () => _clearHistory(
                          item: _SettingItem.clearWatchHistory,
                          update: () => _watchHistoryCleared = true,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasDetailAction(_SettingItem item) {
    return switch (item) {
      _SettingItem.manageSubscription ||
      _SettingItem.paymentHistory ||
      _SettingItem.giftCode => true,
      _SettingItem.clearSearchHistory => !_searchHistoryCleared,
      _SettingItem.clearWatchHistory => !_watchHistoryCleared,
      _SettingItem.manageDevices ||
      _SettingItem.termsOfService ||
      _SettingItem.privacyPolicy ||
      _SettingItem.sendFeedback => false,
    };
  }

  void _clearHistory({
    required _SettingItem item,
    required VoidCallback update,
  }) {
    _menuFocusNodes[item]!.requestFocus();
    setState(update);
  }
}

final class _SettingMenu extends StatelessWidget {
  const _SettingMenu({
    required this.selectedItem,
    required this.focusNodes,
    required this.hasDetailAction,
    required this.detailActionFocusNode,
    required this.onSelectItem,
  });

  static const List<(_SettingSection, List<_SettingItem>)> _sections = [
    (
      _SettingSection.account,
      [
        _SettingItem.manageSubscription,
        _SettingItem.paymentHistory,
        _SettingItem.manageDevices,
        _SettingItem.giftCode,
      ],
    ),
    (
      _SettingSection.about,
      [
        _SettingItem.termsOfService,
        _SettingItem.privacyPolicy,
        _SettingItem.sendFeedback,
      ],
    ),
    (
      _SettingSection.privacy,
      [_SettingItem.clearSearchHistory, _SettingItem.clearWatchHistory],
    ),
  ];

  final _SettingItem selectedItem;
  final Map<_SettingItem, FocusNode> focusNodes;
  final bool hasDetailAction;
  final FocusNode detailActionFocusNode;
  final ValueChanged<_SettingItem> onSelectItem;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 208,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          for (final indexedSection in _sections.indexed) ...[
            _SettingSectionLabel(
              label: indexedSection.$2.$1.label,
              topPadding: indexedSection.$1 == 0 ? 0 : 8,
            ),
            for (final item in indexedSection.$2.$2) ...[
              _SettingMenuItem(
                item: item,
                selected: item == selectedItem,
                focusNode: focusNodes[item]!,
                onSelect: () => onSelectItem(item),
                onMoveRight: hasDetailAction && item == selectedItem
                    ? detailActionFocusNode.requestFocus
                    : null,
              ),
              const SizedBox(height: 4),
            ],
          ],
        ],
      ),
    );
  }
}

enum _SettingSection {
  account('Account'),
  about('About StreamTV'),
  privacy('Privacy');

  const _SettingSection(this.label);

  final String label;
}

final class _SettingSectionLabel extends StatelessWidget {
  const _SettingSectionLabel({required this.label, required this.topPadding});

  final String label;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: topPadding, bottom: 4),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: StreamTvColors.onSurfaceMuted.withValues(alpha: 0.72),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

final class _SettingMenuItem extends StatefulWidget {
  const _SettingMenuItem({
    required this.item,
    required this.selected,
    required this.focusNode,
    required this.onSelect,
    this.onMoveRight,
  });

  final _SettingItem item;
  final bool selected;
  final FocusNode focusNode;
  final VoidCallback onSelect;
  final VoidCallback? onMoveRight;

  @override
  State<_SettingMenuItem> createState() => _SettingMenuItemState();
}

final class _SettingMenuItemState extends State<_SettingMenuItem> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final background = _focused
        ? StreamTvColors.onSurface
        : widget.selected
        ? Colors.white.withValues(alpha: 0.10)
        : StreamTvColors.surface;
    final foreground = _focused
        ? StreamTvColors.background
        : StreamTvColors.onSurface;

    return Focus(
      focusNode: widget.focusNode,
      onFocusChange: (focused) {
        setState(() => _focused = focused);
        if (focused) {
          widget.onSelect();
        }
      },
      onKeyEvent: _handleKeyEvent,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onSelect,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: 29,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: widget.selected && !_focused
                  ? Colors.white.withValues(alpha: 0.40)
                  : Colors.transparent,
            ),
          ),
          child: Text(
            widget.item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: foreground,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      widget.onMoveRight?.call();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.select ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter) {
      widget.onSelect();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }
}

final class _SettingDetailPane extends StatelessWidget {
  const _SettingDetailPane({
    required this.selectedItem,
    required this.systemInfo,
    required this.detailActionFocusNode,
    required this.menuFocusNode,
    required this.searchHistoryCleared,
    required this.watchHistoryCleared,
    required this.onOpenSignIn,
    required this.onClearSearchHistory,
    required this.onClearWatchHistory,
    super.key,
  });

  final _SettingItem selectedItem;
  final _SystemInfo systemInfo;
  final FocusNode detailActionFocusNode;
  final FocusNode menuFocusNode;
  final bool searchHistoryCleared;
  final bool watchHistoryCleared;
  final VoidCallback onOpenSignIn;
  final VoidCallback onClearSearchHistory;
  final VoidCallback onClearWatchHistory;

  @override
  Widget build(BuildContext context) {
    return ExcludeFocus(
      excluding: false,
      child: switch (selectedItem) {
        _SettingItem.manageSubscription ||
        _SettingItem.paymentHistory ||
        _SettingItem.giftCode => _SignInRequiredPane(
          actionFocusNode: detailActionFocusNode,
          menuFocusNode: menuFocusNode,
          onGetStarted: onOpenSignIn,
        ),
        _SettingItem.manageDevices => _SystemInfoPane(systemInfo: systemInfo),
        _SettingItem.termsOfService => const _DocumentPane(
          title: 'Terms of service',
          body:
              'StreamTV is a demonstration television client. The catalog, schedule and account features it presents are sample content, and using it creates no purchase, subscription or entitlement.\n\nStream quality follows the connection this device reports. Playback may pause while the app buffers, and a program may end or move without notice.\n\nUse the app on a device you own or control, and do not capture, redistribute or re-transmit what it plays.',
        ),
        _SettingItem.privacyPolicy => const _DocumentPane(
          title: 'Privacy policy',
          body:
              'This build keeps what it needs on the device and nothing more: the searches you type and the programs you play.\n\nNothing on this screen leaves the device. Sign-in pairing is presentation-only in this release, so no account, payment or contact detail is collected.\n\nClearing search or watch history below removes that record from this device.',
        ),
        _SettingItem.sendFeedback => const _FeedbackPane(),
        _SettingItem.clearSearchHistory => _HistoryPane(
          title: 'Clear search history',
          message: searchHistoryCleared
              ? 'Search history cleared on this device.'
              : 'Removes the search terms this device remembers. Your recommendations stay as they are.',
          isCleared: searchHistoryCleared,
          actionFocusNode: detailActionFocusNode,
          menuFocusNode: menuFocusNode,
          onClear: onClearSearchHistory,
        ),
        _SettingItem.clearWatchHistory => _HistoryPane(
          title: 'Clear watch history',
          message: watchHistoryCleared
              ? 'Watch history cleared on this device.'
              : 'Removes what this device has played. Anything you saved stays in your list.',
          isCleared: watchHistoryCleared,
          actionFocusNode: detailActionFocusNode,
          menuFocusNode: menuFocusNode,
          onClear: onClearWatchHistory,
        ),
      },
    );
  }
}

final class _SignInRequiredPane extends StatelessWidget {
  const _SignInRequiredPane({
    required this.actionFocusNode,
    required this.menuFocusNode,
    required this.onGetStarted,
  });

  final FocusNode actionFocusNode;
  final FocusNode menuFocusNode;
  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            AppAssets.appLogo,
            width: 152,
            height: 31,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 20),
          const SizedBox(
            width: 380,
            child: Text(
              'This feature belongs to a signed-in account. Sign in or create one to carry on from this TV.',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: StreamTvColors.onSurfaceMuted,
                fontSize: 14,
                height: 1.55,
              ),
            ),
          ),
          const SizedBox(height: 22),
          _TvActionButton(
            label: 'Get started',
            focusNode: actionFocusNode,
            onMoveLeft: menuFocusNode.requestFocus,
            onPressed: onGetStarted,
          ),
        ],
      ),
    );
  }
}

final class _SystemInfoPane extends StatelessWidget {
  const _SystemInfoPane({required this.systemInfo});

  final _SystemInfo systemInfo;

  @override
  Widget build(BuildContext context) {
    return ExcludeFocus(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _DetailLabel('Version information'),
          const SizedBox(height: 8),
          _DetailCard(
            title: 'StreamTV ${systemInfo.versionName}',
            subtitle:
                'Version code ${systemInfo.versionCode} · ${systemInfo.buildType} build',
          ),
          const SizedBox(height: 18),
          const _DetailLabel('Current device'),
          const SizedBox(height: 8),
          _DetailCard(
            title: systemInfo.deviceName,
            subtitle:
                '${systemInfo.platformLabel} · ${systemInfo.brand} · ${systemInfo.model} · ${systemInfo.timeZoneId}',
          ),
        ],
      ),
    );
  }
}

final class _DocumentPane extends StatelessWidget {
  const _DocumentPane({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return ExcludeFocus(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: StreamTvColors.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Text(
              body,
              style: const TextStyle(
                color: StreamTvColors.onSurfaceMuted,
                fontSize: 14,
                height: 22 / 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final class _FeedbackPane extends StatelessWidget {
  const _FeedbackPane();

  static const String _feedbackUrl = 'https://feedback.streamtv.example.com';

  @override
  Widget build(BuildContext context) {
    return ExcludeFocus(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Send feedback',
              style: TextStyle(
                color: StreamTvColors.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            const SizedBox(
              width: 340,
              child: Text(
                'Tell us what to build next. Scan the code to open the feedback form on your phone.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: StreamTvColors.onSurfaceMuted,
                  fontSize: 14,
                  height: 22 / 14,
                ),
              ),
            ),
            const SizedBox(height: 18),
            const StreamTvQrCode(
              content: _feedbackUrl,
              size: 116,
              semanticLabel:
                  'QR code that opens the StreamTV feedback form in a phone browser',
            ),
            const SizedBox(height: 12),
            const Text(
              'feedback.streamtv.example.com',
              style: TextStyle(
                color: StreamTvColors.onSurfaceMuted,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _HistoryPane extends StatelessWidget {
  const _HistoryPane({
    required this.title,
    required this.message,
    required this.isCleared,
    required this.actionFocusNode,
    required this.menuFocusNode,
    required this.onClear,
  });

  final String title;
  final String message;
  final bool isCleared;
  final FocusNode actionFocusNode;
  final FocusNode menuFocusNode;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: StreamTvColors.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 400,
          child: Text(
            message,
            style: const TextStyle(
              color: StreamTvColors.onSurfaceMuted,
              fontSize: 14,
              height: 22 / 14,
            ),
          ),
        ),
        if (!isCleared) ...[
          const SizedBox(height: 18),
          _TvActionButton(
            label: 'Clear now',
            focusNode: actionFocusNode,
            onMoveLeft: menuFocusNode.requestFocus,
            onPressed: onClear,
          ),
        ],
      ],
    );
  }
}

final class _DetailLabel extends StatelessWidget {
  const _DetailLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: StreamTvColors.onSurface,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

final class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: StreamTvColors.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: StreamTvColors.onSurfaceMuted,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

final class _TvActionButton extends StatefulWidget {
  const _TvActionButton({
    required this.label,
    required this.onPressed,
    this.focusNode,
    this.onMoveLeft,
  });

  final String label;
  final VoidCallback onPressed;
  final FocusNode? focusNode;
  final VoidCallback? onMoveLeft;

  @override
  State<_TvActionButton> createState() => _TvActionButtonState();
}

final class _TvActionButtonState extends State<_TvActionButton> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: widget.focusNode,
      onFocusChange: (focused) => setState(() => _focused = focused),
      onKeyEvent: _handleKeyEvent,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _focused ? StreamTvColors.onSurface : StreamTvColors.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _focused
                  ? StreamTvColors.background
                  : StreamTvColors.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft &&
        widget.onMoveLeft != null) {
      widget.onMoveLeft!();
      return KeyEventResult.handled;
    }
    return switch (event.logicalKey) {
      LogicalKeyboardKey.enter ||
      LogicalKeyboardKey.select ||
      LogicalKeyboardKey.numpadEnter => _press(),
      _ => KeyEventResult.ignored,
    };
  }

  KeyEventResult _press() {
    widget.onPressed();
    return KeyEventResult.handled;
  }
}

final class _SystemInfo {
  const _SystemInfo({
    required this.versionName,
    required this.versionCode,
    required this.buildType,
    required this.deviceName,
    required this.brand,
    required this.model,
    required this.platformLabel,
    required this.timeZoneId,
  });

  factory _SystemInfo.current() {
    final platformLabel = switch (defaultTargetPlatform) {
      TargetPlatform.android => 'Android',
      TargetPlatform.iOS => 'iOS',
      TargetPlatform.macOS => 'macOS',
      TargetPlatform.windows => 'Windows',
      TargetPlatform.linux => 'Linux',
      TargetPlatform.fuchsia => 'Fuchsia',
    };
    const model = 'StreamTV Flutter host';
    final brand = platformLabel.toLowerCase();
    final deviceName = model.toLowerCase().startsWith(brand.toLowerCase())
        ? model
        : '$brand $model';

    return _SystemInfo(
      versionName: '1.0.0',
      versionCode: '1',
      buildType: kReleaseMode
          ? 'release'
          : kProfileMode
          ? 'profile'
          : 'debug',
      deviceName: deviceName,
      brand: brand,
      model: model,
      platformLabel: platformLabel,
      timeZoneId: DateTime.now().timeZoneName,
    );
  }

  final String versionName;
  final String versionCode;
  final String buildType;
  final String deviceName;
  final String brand;
  final String model;
  final String platformLabel;
  final String timeZoneId;
}
