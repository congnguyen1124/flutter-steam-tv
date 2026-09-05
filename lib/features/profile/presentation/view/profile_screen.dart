import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_steam_tv/core/assets/app_assets.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_colors.dart';
import 'package:flutter_steam_tv/core/widgets/stream_tv_qr_code.dart';
import 'package:flutter_svg/flutter_svg.dart';

final class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

final class _ProfileScreenState extends State<ProfileScreen> {
  static const String _pairingCode = 'XHSZ-QBKX';
  static const String _pairingUrl =
      'https://tv.streamtv.example.com/pair?code=$_pairingCode';
  static const String _validUntil = '14:17';

  bool _phoneSignInSelected = false;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      key: const ValueKey('profile-screen'),
      color: StreamTvColors.background,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(48, 8, 48, 20),
        child: Row(
          children: [
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: _ProfileSignInColumn(
                    phoneSignInSelected: _phoneSignInSelected,
                    onPhoneSignInPressed: () {
                      setState(() => _phoneSignInSelected = true);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 32),
            const _PairingPanel(
              pairingUrl: _pairingUrl,
              pairingCode: _pairingCode,
              validUntil: _validUntil,
            ),
          ],
        ),
      ),
    );
  }
}

final class _ProfileSignInColumn extends StatelessWidget {
  const _ProfileSignInColumn({
    required this.phoneSignInSelected,
    required this.onPhoneSignInPressed,
  });

  final bool phoneSignInSelected;
  final VoidCallback onPhoneSignInPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          AppAssets.appLogo,
          width: 168,
          height: 34,
          semanticLabel: 'StreamTV',
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 16),
        const Text(
          'Sign In or Sign Up',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: StreamTvColors.onSurface,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 72,
          child: Text(
            phoneSignInSelected
                ? 'Phone sign-in continues on your mobile device. Scan the code to finish on this TV.'
                : 'Start streaming the channels, movies and shows made for your big screen.',
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: StreamTvColors.onSurfaceMuted,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 24),
        _TvActionButton(
          label: 'Sign in with phone number',
          onPressed: onPhoneSignInPressed,
        ),
      ],
    );
  }
}

final class _PairingPanel extends StatelessWidget {
  const _PairingPanel({
    required this.pairingUrl,
    required this.pairingCode,
    required this.validUntil,
  });

  final String pairingUrl;
  final String pairingCode;
  final String validUntil;

  @override
  Widget build(BuildContext context) {
    return ExcludeFocus(
      child: Container(
        width: 344,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              StreamTvColors.primaryContainer.withValues(alpha: 0.35),
              Colors.white.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Use the StreamTV app',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: StreamTvColors.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            const _PairingStep(
              number: 1,
              text: 'Open "Account" in the StreamTV mobile app',
              child: _MobileAppArt(),
            ),
            const SizedBox(height: 12),
            const _PairingStep(
              number: 2,
              text: 'Scan the QR code or enter the sign-in code to sign in',
            ),
            const SizedBox(height: 14),
            StreamTvQrCode(
              content: pairingUrl,
              size: 124,
              semanticLabel:
                  'QR code that opens StreamTV sign-in in the mobile app',
            ),
            const SizedBox(height: 12),
            const _OrDivider(),
            const SizedBox(height: 10),
            const Text(
              'Sign-in code',
              style: TextStyle(
                color: StreamTvColors.onSurfaceMuted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              pairingCode,
              style: const TextStyle(
                color: StreamTvColors.onSurface,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Valid until $validUntil',
              style: TextStyle(
                color: StreamTvColors.onSurfaceMuted.withValues(alpha: 0.72),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _PairingStep extends StatelessWidget {
  const _PairingStep({required this.number, required this.text, this.child});

  final int number;
  final String text;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: StreamTvColors.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$number',
            style: const TextStyle(
              color: StreamTvColors.onPrimaryContainer,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: StreamTvColors.onSurface,
                  fontSize: 13,
                  height: 1.2,
                ),
              ),
              if (child != null) ...[const SizedBox(height: 8), child!],
            ],
          ),
        ),
      ],
    );
  }
}

final class _MobileAppArt extends StatelessWidget {
  const _MobileAppArt();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            AppAssets.homeIcon,
            width: 12,
            height: 12,
            colorFilter: const ColorFilter.mode(
              StreamTvColors.primary,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            'Home',
            style: TextStyle(color: StreamTvColors.onSurface, fontSize: 9),
          ),
          const SizedBox(width: 9),
          for (final icon in [
            AppAssets.searchIcon,
            AppAssets.appsIcon,
            AppAssets.bookmarkOutlineIcon,
          ]) ...[
            SvgPicture.asset(
              icon,
              width: 12,
              height: 12,
              colorFilter: ColorFilter.mode(
                StreamTvColors.onSurfaceMuted.withValues(alpha: 0.55),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 9),
          ],
          Container(
            width: 19,
            height: 19,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: StreamTvColors.primary),
            ),
            child: SvgPicture.asset(
              AppAssets.profileIcon,
              width: 11,
              height: 11,
              colorFilter: const ColorFilter.mode(
                StreamTvColors.onSurface,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: Colors.white24)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'OR',
            style: TextStyle(
              color: StreamTvColors.onSurfaceMuted,
              fontSize: 11,
              letterSpacing: 1,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: Colors.white24)),
      ],
    );
  }
}

final class _TvActionButton extends StatefulWidget {
  const _TvActionButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  State<_TvActionButton> createState() => _TvActionButtonState();
}

final class _TvActionButtonState extends State<_TvActionButton> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
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
