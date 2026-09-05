import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_colors.dart';
import 'package:flutter_steam_tv/features/calendar/presentation/model/calendar_models.dart';
import 'package:flutter_steam_tv/features/calendar/presentation/widget/calendar_metrics.dart';
import 'package:flutter_steam_tv/features/home/presentation/widget/home_network_image.dart';

final class CalendarDateHeader extends StatelessWidget {
  const CalendarDateHeader({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: calendarHeaderDecoration(right: true, bottom: true),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label.substringBefore(','),
              style: const TextStyle(
                color: StreamTvColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label.substringAfter(',').trim(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: StreamTvColors.onSurface,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class CalendarChannelHeader extends StatelessWidget {
  const CalendarChannelHeader({required this.channel, super.key});

  final CalendarChannel channel;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: calendarHeaderDecoration(right: true, bottom: true),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipOval(
              child: SizedBox.square(
                dimension: 28,
                child: channel.logoUrl.isEmpty
                    ? CalendarChannelFallback(channel: channel)
                    : HomeNetworkImage(
                        imageUrl: channel.logoUrl,
                        semanticLabel: channel.title,
                      ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              channel.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: StreamTvColors.onSurface,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class CalendarChannelFallback extends StatelessWidget {
  const CalendarChannelFallback({required this.channel, super.key});

  final CalendarChannel channel;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: channel.accentColor,
      child: Center(
        child: Text(
          channel.initials,
          style: const TextStyle(
            color: StreamTvColors.onSurface,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

final class CalendarTimeLabel extends StatelessWidget {
  const CalendarTimeLabel({required this.minute, super.key});

  final int minute;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          (minute ~/ 60).clamp(0, 24).toString().padLeft(2, '0'),
          style: const TextStyle(
            color: StreamTvColors.onSurfaceMuted,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

BoxDecoration calendarHeaderDecoration({
  required bool right,
  required bool bottom,
}) {
  return BoxDecoration(
    border: Border(
      right: right
          ? BorderSide(color: Colors.white.withValues(alpha: 0.14))
          : BorderSide.none,
      bottom: bottom
          ? BorderSide(color: Colors.white.withValues(alpha: 0.14))
          : BorderSide.none,
    ),
  );
}

extension CalendarStringParts on String {
  String substringBefore(String pattern) {
    final index = indexOf(pattern);
    return index == -1 ? this : substring(0, index);
  }

  String substringAfter(String pattern) {
    final index = indexOf(pattern);
    return index == -1 ? '' : substring(index + pattern.length);
  }
}

@Preview(name: 'Calendar - headers', size: Size(360, 96))
Widget calendarHeadersPreview() {
  const channel = CalendarChannel(
    id: 'preview-news',
    title: 'Stream News',
    logoUrl: '',
    programs: [],
  );

  return const Material(
    color: StreamTvColors.background,
    child: Row(
      children: [
        SizedBox(
          width: CalendarMetrics.leadingWidth,
          height: CalendarMetrics.headerHeight,
          child: CalendarDateHeader(label: 'WED, 02 SEP'),
        ),
        SizedBox(
          width: CalendarMetrics.channelWidth,
          height: CalendarMetrics.headerHeight,
          child: CalendarChannelHeader(channel: channel),
        ),
      ],
    ),
  );
}
