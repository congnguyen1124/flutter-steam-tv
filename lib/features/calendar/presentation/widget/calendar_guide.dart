import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_colors.dart';
import 'package:flutter_steam_tv/features/calendar/presentation/data/calendar_dummy_schedule.dart';
import 'package:flutter_steam_tv/features/calendar/presentation/model/calendar_models.dart';
import 'package:flutter_steam_tv/features/calendar/presentation/widget/calendar_headers.dart';
import 'package:flutter_steam_tv/features/calendar/presentation/widget/calendar_metrics.dart';
import 'package:flutter_steam_tv/features/calendar/presentation/widget/calendar_program_card.dart';

typedef CalendarViewportChanged =
    void Function(double gridWidth, double gridHeight);

final class CalendarGuide extends StatelessWidget {
  const CalendarGuide({
    required this.schedule,
    required this.gridFocusNode,
    required this.selectedChannelIndex,
    required this.selectedProgramIndex,
    required this.horizontalOffset,
    required this.verticalOffset,
    required this.onKeyEvent,
    required this.onViewportChanged,
    super.key,
  });

  static const Duration moveDuration = Duration(milliseconds: 190);

  final CalendarDay schedule;
  final FocusNode gridFocusNode;
  final int selectedChannelIndex;
  final int selectedProgramIndex;
  final double horizontalOffset;
  final double verticalOffset;
  final FocusOnKeyEventCallback onKeyEvent;
  final CalendarViewportChanged onViewportChanged;

  @override
  Widget build(BuildContext context) {
    final selectedProgram =
        schedule.channels[selectedChannelIndex].programs[selectedProgramIndex];

    return Focus(
      key: const ValueKey('calendar-guide-focus'),
      focusNode: gridFocusNode,
      onKeyEvent: onKeyEvent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final gridWidth = constraints.maxWidth - CalendarMetrics.leadingWidth;
          final gridHeight =
              constraints.maxHeight - CalendarMetrics.headerHeight;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onViewportChanged(gridWidth, gridHeight);
          });

          return Stack(
            children: [
              Positioned.fill(
                child: ColoredBox(color: Colors.white.withValues(alpha: 0.04)),
              ),
              Positioned(
                left: 0,
                top: 0,
                width: CalendarMetrics.leadingWidth,
                height: CalendarMetrics.headerHeight,
                child: CalendarDateHeader(label: schedule.dateLabel),
              ),
              Positioned(
                left: CalendarMetrics.leadingWidth,
                top: 0,
                width: gridWidth,
                height: CalendarMetrics.headerHeight,
                child: _CalendarColumnHeaderViewport(
                  schedule: schedule,
                  horizontalOffset: horizontalOffset,
                  viewportWidth: gridWidth,
                ),
              ),
              Positioned(
                left: 0,
                top: CalendarMetrics.headerHeight,
                width: CalendarMetrics.leadingWidth,
                height: gridHeight,
                child: _CalendarTimeRulerViewport(
                  verticalOffset: verticalOffset,
                  viewportHeight: gridHeight,
                ),
              ),
              Positioned(
                left: CalendarMetrics.leadingWidth,
                top: CalendarMetrics.headerHeight,
                width: gridWidth,
                height: gridHeight,
                child: _CalendarProgramViewport(
                  schedule: schedule,
                  selectedChannelIndex: selectedChannelIndex,
                  selectedProgramIndex: selectedProgramIndex,
                  horizontalOffset: horizontalOffset,
                  verticalOffset: verticalOffset,
                  viewportWidth: gridWidth,
                  viewportHeight: gridHeight,
                ),
              ),
              Positioned(
                left: CalendarMetrics.leadingWidth,
                top: CalendarMetrics.headerHeight,
                width: gridWidth,
                height: gridHeight,
                child: IgnorePointer(
                  child: Stack(
                    children: [
                      AnimatedPositioned(
                        duration: moveDuration,
                        curve: Curves.easeOutCubic,
                        left:
                            selectedChannelIndex * CalendarMetrics.columnPitch -
                            horizontalOffset -
                            CalendarMetrics.selectedItemPadding,
                        top:
                            CalendarMetrics.programTop(selectedProgram) -
                            verticalOffset -
                            CalendarMetrics.selectedItemPadding,
                        width:
                            CalendarMetrics.channelWidth +
                            CalendarMetrics.selectedItemPadding * 2,
                        height:
                            CalendarMetrics.programHeight(selectedProgram) +
                            CalendarMetrics.selectedItemPadding * 2,
                        child: AnimatedBuilder(
                          animation: gridFocusNode,
                          builder: (context, _) {
                            return DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: gridFocusNode.hasFocus
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.28),
                                  width: gridFocusNode.hasFocus ? 3 : 1,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

final class _CalendarColumnHeaderViewport extends StatelessWidget {
  const _CalendarColumnHeaderViewport({
    required this.schedule,
    required this.horizontalOffset,
    required this.viewportWidth,
  });

  final CalendarDay schedule;
  final double horizontalOffset;
  final double viewportWidth;

  @override
  Widget build(BuildContext context) {
    final range = _visibleColumnRange(horizontalOffset, viewportWidth);

    return ClipRect(
      child: Stack(
        children: [
          for (
            var index = range.start;
            index <= range.end && index < schedule.channels.length;
            index++
          )
            AnimatedPositioned(
              key: ValueKey('calendar-header-${schedule.channels[index].id}'),
              duration: CalendarGuide.moveDuration,
              curve: Curves.easeOutCubic,
              left: index * CalendarMetrics.columnPitch - horizontalOffset,
              top: 0,
              width: CalendarMetrics.channelWidth,
              height: CalendarMetrics.headerHeight,
              child: CalendarChannelHeader(channel: schedule.channels[index]),
            ),
        ],
      ),
    );
  }
}

final class _CalendarTimeRulerViewport extends StatelessWidget {
  const _CalendarTimeRulerViewport({
    required this.verticalOffset,
    required this.viewportHeight,
  });

  final double verticalOffset;
  final double viewportHeight;

  @override
  Widget build(BuildContext context) {
    final range = _visibleHourRange(verticalOffset, viewportHeight);

    return ClipRect(
      child: CustomPaint(
        painter: _TimeRulerPainter(verticalOffset: verticalOffset),
        child: Stack(
          children: [
            for (var hour = range.start; hour <= range.end; hour++)
              AnimatedPositioned(
                key: ValueKey('calendar-time-$hour'),
                duration: CalendarGuide.moveDuration,
                curve: Curves.easeOutCubic,
                top: hour * CalendarMetrics.hourHeight - verticalOffset - 12,
                left: 0,
                right: 0,
                height: 24,
                child: CalendarTimeLabel(minute: hour * 60),
              ),
          ],
        ),
      ),
    );
  }
}

final class _CalendarProgramViewport extends StatelessWidget {
  const _CalendarProgramViewport({
    required this.schedule,
    required this.selectedChannelIndex,
    required this.selectedProgramIndex,
    required this.horizontalOffset,
    required this.verticalOffset,
    required this.viewportWidth,
    required this.viewportHeight,
  });

  final CalendarDay schedule;
  final int selectedChannelIndex;
  final int selectedProgramIndex;
  final double horizontalOffset;
  final double verticalOffset;
  final double viewportWidth;
  final double viewportHeight;

  @override
  Widget build(BuildContext context) {
    final columnRange = _visibleColumnRange(horizontalOffset, viewportWidth);
    final startMinute = _visibleStartMinute(verticalOffset);
    final endMinute = _visibleEndMinute(verticalOffset, viewportHeight);

    return ClipRect(
      child: DecoratedBox(
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05)),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _CalendarGridPainter(
                  channelCount: schedule.channels.length,
                  horizontalOffset: horizontalOffset,
                  verticalOffset: verticalOffset,
                ),
              ),
            ),
            for (
              var channelIndex = columnRange.start;
              channelIndex <= columnRange.end &&
                  channelIndex < schedule.channels.length;
              channelIndex++
            )
              for (final programEntry
                  in schedule.channels[channelIndex].programs.indexed)
                if (_shouldBuildProgram(
                  channelIndex: channelIndex,
                  programIndex: programEntry.$1,
                  selectedChannelIndex: selectedChannelIndex,
                  selectedProgramIndex: selectedProgramIndex,
                  program: programEntry.$2,
                  startMinute: startMinute,
                  endMinute: endMinute,
                ))
                  AnimatedPositioned(
                    key: ValueKey(
                      'calendar-program-${schedule.channels[channelIndex].id}-${programEntry.$2.id}',
                    ),
                    duration: CalendarGuide.moveDuration,
                    curve: Curves.easeOutCubic,
                    left:
                        channelIndex * CalendarMetrics.columnPitch -
                        horizontalOffset,
                    top:
                        CalendarMetrics.programTop(programEntry.$2) -
                        verticalOffset,
                    width: CalendarMetrics.channelWidth,
                    height: CalendarMetrics.programHeight(programEntry.$2),
                    child: CalendarProgramCard(
                      program: programEntry.$2,
                      selected:
                          channelIndex == selectedChannelIndex &&
                          programEntry.$1 == selectedProgramIndex,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

final class _CalendarGridPainter extends CustomPainter {
  const _CalendarGridPainter({
    required this.channelCount,
    required this.horizontalOffset,
    required this.verticalOffset,
  });

  final int channelCount;
  final double horizontalOffset;
  final double verticalOffset;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..strokeWidth = 1;

    final firstHour = math.max(
      0,
      (verticalOffset / CalendarMetrics.hourHeight).floor() - 1,
    );
    final lastHour = math.min(
      24,
      ((verticalOffset + size.height) / CalendarMetrics.hourHeight).ceil() + 1,
    );
    for (var hour = firstHour; hour <= lastHour; hour++) {
      final y = hour * CalendarMetrics.hourHeight - verticalOffset;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    final range = _visibleColumnRange(horizontalOffset, size.width);
    for (
      var channel = range.start;
      channel <= range.end + 1 && channel <= channelCount;
      channel++
    ) {
      final x = channel * CalendarMetrics.columnPitch - horizontalOffset;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_CalendarGridPainter oldDelegate) {
    return oldDelegate.channelCount != channelCount ||
        oldDelegate.horizontalOffset != horizontalOffset ||
        oldDelegate.verticalOffset != verticalOffset;
  }
}

final class _TimeRulerPainter extends CustomPainter {
  const _TimeRulerPainter({required this.verticalOffset});

  final double verticalOffset;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.16)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(size.width - 1, 0),
      Offset(size.width - 1, size.height),
      paint,
    );

    final range = _visibleHourRange(verticalOffset, size.height);
    for (var hour = range.start; hour <= range.end; hour++) {
      final y = hour * CalendarMetrics.hourHeight - verticalOffset;
      canvas.drawLine(Offset(size.width - 9, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_TimeRulerPainter oldDelegate) {
    return oldDelegate.verticalOffset != verticalOffset;
  }
}

bool _shouldBuildProgram({
  required int channelIndex,
  required int programIndex,
  required int selectedChannelIndex,
  required int selectedProgramIndex,
  required CalendarProgram program,
  required int startMinute,
  required int endMinute,
}) {
  if (channelIndex == selectedChannelIndex &&
      programIndex == selectedProgramIndex) {
    return true;
  }
  return program.startMinute < endMinute && program.endMinute > startMinute;
}

({int start, int end}) _visibleColumnRange(
  double horizontalOffset,
  double viewportWidth,
) {
  final start =
      (horizontalOffset / CalendarMetrics.columnPitch).floor() -
      CalendarMetrics.beyondBoundsColumnCount;
  final end =
      ((horizontalOffset + viewportWidth) / CalendarMetrics.columnPitch)
          .ceil() +
      CalendarMetrics.beyondBoundsColumnCount;
  return (start: math.max(0, start), end: math.max(0, end));
}

({int start, int end}) _visibleHourRange(
  double verticalOffset,
  double viewportHeight,
) {
  final start = (verticalOffset / CalendarMetrics.hourHeight).floor() - 1;
  final end =
      ((verticalOffset + viewportHeight) / CalendarMetrics.hourHeight).ceil() +
      1;
  return (start: math.max(0, start), end: math.min(24, end));
}

int _visibleStartMinute(double verticalOffset) {
  return ((verticalOffset / CalendarMetrics.hourHeight) * 60).floor() -
      CalendarMetrics.beyondBoundsMinuteCount;
}

int _visibleEndMinute(double verticalOffset, double viewportHeight) {
  return (((verticalOffset + viewportHeight) / CalendarMetrics.hourHeight) * 60)
          .ceil() +
      CalendarMetrics.beyondBoundsMinuteCount;
}

@Preview(name: 'Calendar - lazy guide', size: Size(1280, 720))
Widget calendarGuidePreview() {
  final focusNode = FocusNode(debugLabel: 'calendar-preview');

  return Material(
    color: StreamTvColors.background,
    child: Padding(
      padding: const EdgeInsets.all(6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CalendarGuide(
          schedule: CalendarDummySchedule.build(),
          gridFocusNode: focusNode,
          selectedChannelIndex: 0,
          selectedProgramIndex: 3,
          horizontalOffset: 0,
          verticalOffset: 0,
          onViewportChanged: (_, _) {},
          onKeyEvent: (_, _) => KeyEventResult.ignored,
        ),
      ),
    ),
  );
}
