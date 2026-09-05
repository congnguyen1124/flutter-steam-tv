import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_colors.dart';
import 'package:flutter_steam_tv/features/home/presentation/widget/home_network_image.dart';

final class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

final class _CalendarScreenState extends State<CalendarScreen> {
  static final _CalendarDay _schedule = _CalendarDay.dummy();

  final FocusNode _gridFocusNode = FocusNode(debugLabel: 'calendar-grid');
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();
  int _selectedChannelIndex = 0;
  int _selectedProgramIndex = 0;
  bool _moving = false;

  @override
  void initState() {
    super.initState();
    _normalizeSelection();
  }

  @override
  void dispose() {
    _gridFocusNode.dispose();
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasPrograms = _schedule.channels.any((channel) {
      return channel.programs.isNotEmpty;
    });

    return ColoredBox(
      key: const ValueKey('calendar-screen'),
      color: StreamTvColors.background,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 2, 6, 6),
        child: hasPrograms
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _CalendarGuide(
                  schedule: _schedule,
                  gridFocusNode: _gridFocusNode,
                  horizontalController: _horizontalController,
                  verticalController: _verticalController,
                  selectedChannelIndex: _selectedChannelIndex,
                  selectedProgramIndex: _selectedProgramIndex,
                  moving: _moving,
                  onKeyEvent: _handleGridKeyEvent,
                ),
              )
            : const Center(
                child: Text(
                  'No programs are available for this day',
                  style: TextStyle(
                    color: StreamTvColors.onSurfaceMuted,
                    fontSize: 20,
                  ),
                ),
              ),
      ),
    );
  }

  KeyEventResult _handleGridKeyEvent(FocusNode node, KeyEvent event) {
    if (_moving || (event is! KeyDownEvent && event is! KeyRepeatEvent)) {
      return KeyEventResult.ignored;
    }

    return switch (event.logicalKey) {
      LogicalKeyboardKey.arrowUp => _moveVertical(-1),
      LogicalKeyboardKey.arrowDown => _moveVertical(1),
      LogicalKeyboardKey.arrowLeft => _moveHorizontal(-1),
      LogicalKeyboardKey.arrowRight => _moveHorizontal(1),
      LogicalKeyboardKey.enter ||
      LogicalKeyboardKey.select ||
      LogicalKeyboardKey.numpadEnter => KeyEventResult.handled,
      _ => KeyEventResult.ignored,
    };
  }

  KeyEventResult _moveVertical(int delta) {
    final channel = _schedule.channels[_selectedChannelIndex];
    final nextIndex = _selectedProgramIndex + delta;
    if (nextIndex < 0 || nextIndex >= channel.programs.length) {
      return KeyEventResult.ignored;
    }
    _startMove(_selectedChannelIndex, nextIndex);
    return KeyEventResult.handled;
  }

  KeyEventResult _moveHorizontal(int delta) {
    final nextChannelIndex = _nextNonEmptyChannel(delta);
    if (nextChannelIndex == null) {
      return KeyEventResult.ignored;
    }

    final current = _selectedProgram;
    final midpoint = (current.startMinute + current.endMinute) / 2;
    final targetPrograms = _schedule.channels[nextChannelIndex].programs;
    var bestIndex = 0;
    var bestScore = double.infinity;
    for (var index = 0; index < targetPrograms.length; index++) {
      final program = targetPrograms[index];
      final containsMidpoint =
          midpoint >= program.startMinute && midpoint < program.endMinute;
      final programMidpoint = (program.startMinute + program.endMinute) / 2;
      final distance = containsMidpoint
          ? 0.0
          : math.min(
              (midpoint - program.startMinute).abs(),
              (midpoint - program.endMinute).abs(),
            );
      final score = distance * 10000 + (programMidpoint - midpoint).abs();
      if (score < bestScore) {
        bestScore = score;
        bestIndex = index;
      }
    }
    _startMove(nextChannelIndex, bestIndex);
    return KeyEventResult.handled;
  }

  int? _nextNonEmptyChannel(int delta) {
    var index = _selectedChannelIndex + delta;
    while (index >= 0 && index < _schedule.channels.length) {
      if (_schedule.channels[index].programs.isNotEmpty) {
        return index;
      }
      index += delta;
    }
    return null;
  }

  void _startMove(int channelIndex, int programIndex) {
    setState(() {
      _moving = true;
      _selectedChannelIndex = channelIndex;
      _selectedProgramIndex = programIndex;
    });
    _syncViewport();
    Timer(const Duration(milliseconds: 190), () {
      if (mounted) {
        setState(() => _moving = false);
      }
    });
  }

  void _syncViewport() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final selected = _selectedProgram;
      final targetX = (_selectedChannelIndex * _CalendarMetrics.columnPitch)
          .clamp(0.0, _maxScrollExtent(_horizontalController));
      final targetY = (selected.startMinute / 60 * _CalendarMetrics.hourHeight)
          .clamp(0.0, _maxScrollExtent(_verticalController));

      unawaited(
        _horizontalController.animateTo(
          targetX,
          duration: const Duration(milliseconds: 190),
          curve: Curves.easeOutCubic,
        ),
      );
      unawaited(
        _verticalController.animateTo(
          targetY,
          duration: const Duration(milliseconds: 190),
          curve: Curves.easeOutCubic,
        ),
      );
    });
  }

  void _normalizeSelection() {
    final channelIndex = _schedule.channels.indexWhere((channel) {
      return channel.programs.isNotEmpty;
    });
    _selectedChannelIndex = math.max(channelIndex, 0);
    _selectedProgramIndex = 0;
  }

  _CalendarProgram get _selectedProgram {
    return _schedule
        .channels[_selectedChannelIndex]
        .programs[_selectedProgramIndex];
  }

  double _maxScrollExtent(ScrollController controller) {
    if (!controller.hasClients) {
      return 0;
    }
    return controller.positions
        .map((position) => position.maxScrollExtent)
        .fold<double>(0, math.max);
  }
}

final class _CalendarGuide extends StatelessWidget {
  const _CalendarGuide({
    required this.schedule,
    required this.gridFocusNode,
    required this.horizontalController,
    required this.verticalController,
    required this.selectedChannelIndex,
    required this.selectedProgramIndex,
    required this.moving,
    required this.onKeyEvent,
  });

  final _CalendarDay schedule;
  final FocusNode gridFocusNode;
  final ScrollController horizontalController;
  final ScrollController verticalController;
  final int selectedChannelIndex;
  final int selectedProgramIndex;
  final bool moving;
  final FocusOnKeyEventCallback onKeyEvent;

  @override
  Widget build(BuildContext context) {
    const contentHeight = _CalendarMetrics.hourHeight * 24;
    final contentWidth =
        schedule.channels.length * _CalendarMetrics.channelWidth +
        (schedule.channels.length - 1) * _CalendarMetrics.channelGap;
    final selectedProgram =
        schedule.channels[selectedChannelIndex].programs[selectedProgramIndex];

    return Focus(
      focusNode: gridFocusNode,
      onKeyEvent: onKeyEvent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final gridWidth =
              constraints.maxWidth - _CalendarMetrics.leadingWidth;
          final gridHeight =
              constraints.maxHeight - _CalendarMetrics.headerHeight;
          return Stack(
            children: [
              Positioned.fill(
                child: ColoredBox(color: Colors.white.withValues(alpha: 0.04)),
              ),
              Positioned(
                left: 0,
                top: 0,
                width: _CalendarMetrics.leadingWidth,
                height: _CalendarMetrics.headerHeight,
                child: _DateHeader(label: schedule.dateLabel),
              ),
              Positioned(
                left: _CalendarMetrics.leadingWidth,
                top: 0,
                width: gridWidth,
                height: _CalendarMetrics.headerHeight,
                child: _HorizontalViewport(
                  controller: horizontalController,
                  width: contentWidth,
                  child: Row(
                    children: [
                      for (final indexed in schedule.channels.indexed) ...[
                        SizedBox(
                          width: _CalendarMetrics.channelWidth,
                          height: _CalendarMetrics.headerHeight,
                          child: _ChannelHeader(channel: indexed.$2),
                        ),
                        if (indexed.$1 != schedule.channels.length - 1)
                          const SizedBox(width: _CalendarMetrics.channelGap),
                      ],
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: _CalendarMetrics.headerHeight,
                width: _CalendarMetrics.leadingWidth,
                height: gridHeight,
                child: _VerticalViewport(
                  controller: verticalController,
                  height: contentHeight,
                  child: const _TimeRuler(),
                ),
              ),
              Positioned(
                left: _CalendarMetrics.leadingWidth,
                top: _CalendarMetrics.headerHeight,
                width: gridWidth,
                height: gridHeight,
                child: _SyncedGridViewport(
                  horizontalController: horizontalController,
                  verticalController: verticalController,
                  contentWidth: contentWidth,
                  contentHeight: contentHeight,
                  child: _ProgramGrid(
                    schedule: schedule,
                    selectedChannelIndex: selectedChannelIndex,
                    selectedProgramIndex: selectedProgramIndex,
                  ),
                ),
              ),
              Positioned(
                left: _CalendarMetrics.leadingWidth,
                top: _CalendarMetrics.headerHeight,
                width: gridWidth,
                height: gridHeight,
                child: IgnorePointer(
                  child: Stack(
                    children: [
                      AnimatedBuilder(
                        animation: Listenable.merge([
                          horizontalController,
                          verticalController,
                          gridFocusNode,
                        ]),
                        builder: (context, _) {
                          final offsetX = _scrollPixels(horizontalController);
                          final offsetY = _scrollPixels(verticalController);
                          return AnimatedPositioned(
                            duration: const Duration(milliseconds: 190),
                            curve: Curves.easeOutCubic,
                            left:
                                selectedChannelIndex *
                                    _CalendarMetrics.columnPitch -
                                offsetX -
                                2,
                            top:
                                selectedProgram.startMinute /
                                    60 *
                                    _CalendarMetrics.hourHeight -
                                offsetY -
                                2,
                            width: _CalendarMetrics.channelWidth + 4,
                            height: _programHeight(selectedProgram) + 4,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: gridFocusNode.hasFocus
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.28),
                                  width: gridFocusNode.hasFocus ? 3 : 1,
                                ),
                              ),
                            ),
                          );
                        },
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

double _scrollPixels(ScrollController controller) {
  if (!controller.hasClients) {
    return 0;
  }
  return controller.positions.first.pixels;
}

final class _HorizontalViewport extends StatelessWidget {
  const _HorizontalViewport({
    required this.controller,
    required this.width,
    required this.child,
  });

  final ScrollController controller;
  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: controller,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: SizedBox(width: width, child: child),
    );
  }
}

final class _VerticalViewport extends StatelessWidget {
  const _VerticalViewport({
    required this.controller,
    required this.height,
    required this.child,
  });

  final ScrollController controller;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: controller,
      physics: const NeverScrollableScrollPhysics(),
      child: SizedBox(height: height, child: child),
    );
  }
}

final class _SyncedGridViewport extends StatelessWidget {
  const _SyncedGridViewport({
    required this.horizontalController,
    required this.verticalController,
    required this.contentWidth,
    required this.contentHeight,
    required this.child,
  });

  final ScrollController horizontalController;
  final ScrollController verticalController;
  final double contentWidth;
  final double contentHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: verticalController,
      physics: const NeverScrollableScrollPhysics(),
      child: SingleChildScrollView(
        controller: horizontalController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: SizedBox(
          width: contentWidth,
          height: contentHeight,
          child: child,
        ),
      ),
    );
  }
}

final class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: _headerDecoration(right: true, bottom: true),
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

final class _ChannelHeader extends StatelessWidget {
  const _ChannelHeader({required this.channel});

  final _CalendarChannel channel;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: _headerDecoration(right: true, bottom: true),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipOval(
              child: SizedBox.square(
                dimension: 28,
                child: channel.logoUrl.isEmpty
                    ? _ChannelFallback(channel: channel)
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

final class _ChannelFallback extends StatelessWidget {
  const _ChannelFallback({required this.channel});

  final _CalendarChannel channel;

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

final class _TimeRuler extends StatelessWidget {
  const _TimeRuler();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TimeRulerPainter(),
      child: Stack(
        children: [
          for (var hour = 0; hour <= 24; hour++)
            Positioned(
              top: hour * _CalendarMetrics.hourHeight - 8,
              left: 0,
              right: 14,
              child: Text(
                hour.toString().padLeft(2, '0'),
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: StreamTvColors.onSurfaceMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

final class _TimeRulerPainter extends CustomPainter {
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
    for (var hour = 0; hour <= 24; hour++) {
      final y = hour * _CalendarMetrics.hourHeight;
      canvas.drawLine(Offset(size.width - 9, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_TimeRulerPainter oldDelegate) => false;
}

final class _ProgramGrid extends StatelessWidget {
  const _ProgramGrid({
    required this.schedule,
    required this.selectedChannelIndex,
    required this.selectedProgramIndex,
  });

  final _CalendarDay schedule;
  final int selectedChannelIndex;
  final int selectedProgramIndex;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridLinePainter(channelCount: schedule.channels.length),
      child: Stack(
        children: [
          for (final channelEntry in schedule.channels.indexed)
            for (final programEntry in channelEntry.$2.programs.indexed)
              Positioned(
                left: channelEntry.$1 * _CalendarMetrics.columnPitch,
                top:
                    programEntry.$2.startMinute /
                    60 *
                    _CalendarMetrics.hourHeight,
                width: _CalendarMetrics.channelWidth,
                height: _programHeight(programEntry.$2),
                child: _ProgramCard(
                  program: programEntry.$2,
                  selected:
                      channelEntry.$1 == selectedChannelIndex &&
                      programEntry.$1 == selectedProgramIndex,
                ),
              ),
        ],
      ),
    );
  }
}

final class _GridLinePainter extends CustomPainter {
  const _GridLinePainter({required this.channelCount});

  final int channelCount;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..strokeWidth = 1;
    for (var hour = 0; hour <= 24; hour++) {
      final y = hour * _CalendarMetrics.hourHeight;
      canvas.drawLine(
        Offset.zero.translate(0, y),
        Offset(size.width, y),
        paint,
      );
    }
    for (var channel = 0; channel <= channelCount; channel++) {
      final x =
          channel * _CalendarMetrics.columnPitch -
          _CalendarMetrics.channelGap / 2;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_GridLinePainter oldDelegate) {
    return oldDelegate.channelCount != channelCount;
  }
}

final class _ProgramCard extends StatelessWidget {
  const _ProgramCard({required this.program, required this.selected});

  final _CalendarProgram program;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final showsArtwork =
        program.durationMinutes >= 60 && program.thumbnailUrl.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1.5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: ColoredBox(
          color: const Color(0xFF162633),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (showsArtwork) ...[
                HomeNetworkImage(
                  imageUrl: program.thumbnailUrl,
                  semanticLabel: program.title,
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.08),
                        Colors.black.withValues(alpha: 0.85),
                      ],
                    ),
                  ),
                ),
              ],
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      program.title,
                      maxLines: program.durationMinutes < 60 ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected
                            ? StreamTvColors.onSurface
                            : StreamTvColors.onSurface.withValues(alpha: 0.88),
                        fontSize: 14,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                    if (program.durationMinutes >= 60) ...[
                      const SizedBox(height: 3),
                      Text(
                        program.timeLabel,
                        maxLines: 1,
                        style: const TextStyle(
                          color: StreamTvColors.onSurfaceMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

BoxDecoration _headerDecoration({required bool right, required bool bottom}) {
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

double _programHeight(_CalendarProgram program) {
  return math.max(
    20,
    program.durationMinutes / 60 * _CalendarMetrics.hourHeight - 3,
  );
}

extension on String {
  String substringBefore(String pattern) {
    final index = indexOf(pattern);
    return index == -1 ? this : substring(0, index);
  }

  String substringAfter(String pattern) {
    final index = indexOf(pattern);
    return index == -1 ? '' : substring(index + pattern.length);
  }
}

abstract final class _CalendarMetrics {
  static const double leadingWidth = 76;
  static const double headerHeight = 64;
  static const double channelWidth = 214;
  static const double channelGap = 8;
  static const double hourHeight = 76;
  static const double columnPitch = channelWidth + channelGap;
}

final class _CalendarDay {
  const _CalendarDay({required this.dateLabel, required this.channels});

  factory _CalendarDay.dummy() {
    return _CalendarDay(
      dateLabel: 'WED, 02 SEP',
      channels: [
        _CalendarChannel(
          id: 'stream-nature',
          title: 'Stream Nature',
          logoUrl: _Images.tiger,
          programs: _programs('nature', [
            _entry('00:00', '02:00', 'Wild Asia: Night Hunters', _Images.tiger),
            _entry(
              '02:00',
              '03:30',
              'Secrets of the Rainforest',
              _Images.forest,
            ),
            _entry('03:30', '04:00', 'Nature Briefing', ''),
            _entry('04:00', '06:00', 'Ocean Frontiers', _Images.ocean),
            _entry('06:00', '07:00', 'Planet at Dawn', _Images.forest),
            _entry(
              '07:00',
              '09:00',
              'Realm of the Bengal Tiger',
              _Images.tiger,
            ),
            _entry('09:00', '09:45', 'Wildlife Update', ''),
            _entry('09:45', '12:00', 'The Great Migration', _Images.forest),
            _entry('12:00', '14:00', 'Earth From Above', _Images.ocean),
            _entry('14:00', '16:30', 'Giants of the Deep', _Images.ocean),
            _entry('16:30', '18:00', 'Forest Families', _Images.tiger),
            _entry('18:00', '20:00', 'Asia Untamed', _Images.forest),
            _entry('20:00', '22:30', 'Blue Planet Stories', _Images.ocean),
            _entry('22:30', '24:00', 'Night in the Wild', _Images.tiger),
          ]),
        ),
        _CalendarChannel(
          id: 'stream-sport',
          title: 'Stream Sport',
          logoUrl: _Images.basketball,
          programs: _programs('sport', [
            _entry('00:00', '01:00', 'Matchday Review', _Images.football),
            _entry('01:00', '03:00', 'Classic Football', _Images.football),
            _entry('03:00', '04:00', 'Sports Desk', _Images.basketball),
            _entry(
              '04:00',
              '06:30',
              'Live: International Cricket',
              _Images.cricket,
            ),
            _entry('06:30', '07:15', 'Morning Scores', ''),
            _entry('07:15', '09:00', 'Basketball Focus', _Images.basketball),
            _entry('09:00', '11:30', 'Live: Court Central', _Images.basketball),
            _entry('11:30', '12:00', 'Half-Time Report', ''),
            _entry('12:00', '14:00', 'Road to the Final', _Images.football),
            _entry('14:00', '16:00', 'Cricket Classics', _Images.cricket),
            _entry(
              '16:00',
              '18:30',
              'Live: Championship Football',
              _Images.football,
            ),
            _entry('18:30', '19:00', 'Final Whistle', ''),
            _entry('19:00', '21:00', 'Prime Basketball', _Images.basketball),
            _entry('21:00', '24:00', 'Live: Stadium Night', _Images.football),
          ]),
        ),
        const _CalendarChannel(
          id: 'stream-local',
          title: 'Stream Local',
          logoUrl: '',
          programs: [],
        ),
        _CalendarChannel(
          id: 'stream-asia',
          title: 'Stream Asia',
          logoUrl: _Images.festival,
          programs: _programs('asia', [
            _entry('00:00', '02:30', 'Tokyo After Dark', _Images.tokyo),
            _entry('02:30', '04:00', 'Living Heritage', _Images.festival),
            _entry('04:00', '05:00', 'Asia Today', _Images.tokyo),
            _entry(
              '05:00',
              '07:00',
              'Grace in Every Gesture',
              _Images.ceremony,
            ),
            _entry('07:00', '07:40', 'Culture Minute', ''),
            _entry(
              '07:40',
              '10:00',
              'Colors of a Chinese Festival',
              _Images.festival,
            ),
            _entry('10:00', '12:00', 'Old Streets of Tokyo', _Images.tokyo),
            _entry('12:00', '13:00', 'Asia Today', _Images.festival),
            _entry('13:00', '15:30', 'The Silk Road', _Images.festival),
            _entry('15:30', '17:00', 'Japanese Craft', _Images.ceremony),
            _entry('17:00', '19:30', 'Cities in Motion', _Images.tokyo),
            _entry('19:30', '20:00', 'Evening Update', ''),
            _entry('20:00', '22:30', 'Dynasties of China', _Images.festival),
            _entry('22:30', '24:00', 'Quiet Japan', _Images.ceremony),
          ]),
        ),
        _CalendarChannel(
          id: 'stream-cinema',
          title: 'Stream Cinema',
          logoUrl: _Images.tokyo,
          programs: _programs('cinema', [
            _entry('00:00', '02:15', 'Midnight Crossing', _Images.tokyo),
            _entry('02:15', '04:00', 'The Last Lantern', _Images.festival),
            _entry('04:00', '06:00', 'A Long Way Home', _Images.forest),
            _entry('06:00', '06:30', 'Cinema Preview', ''),
            _entry('06:30', '09:00', 'Beyond the Horizon', _Images.ocean),
            _entry('09:00', '11:00', 'The Decisive Touch', _Images.football),
            _entry('11:00', '13:15', 'Autumn Letters', _Images.ceremony),
            _entry('13:15', '15:00', 'City of Stories', _Images.tokyo),
            _entry('15:00', '17:30', 'Guardians of the Forest', _Images.tiger),
            _entry('17:30', '18:00', 'Coming Up', ''),
            _entry('18:00', '20:15', 'A Festival of Light', _Images.festival),
            _entry('20:15', '22:30', 'Blue Distance', _Images.ocean),
            _entry('22:30', '24:00', 'Late Night Cinema', _Images.tokyo),
          ]),
        ),
        _CalendarChannel(
          id: 'stream-kids',
          title: 'Stream Kids',
          logoUrl: _Images.ocean,
          programs: _programs('kids', [
            _entry('00:00', '05:00', 'Dreamtime Stories', _Images.forest),
            _entry('05:00', '06:00', 'Wake Up Club', _Images.festival),
            _entry('06:00', '08:00', 'Animal Adventures', _Images.tiger),
            _entry('08:00', '08:25', 'Mini Explorers', ''),
            _entry('08:25', '10:00', 'Ocean Friends', _Images.ocean),
            _entry('10:00', '12:00', 'Junior Champions', _Images.basketball),
            _entry('12:00', '14:00', 'Festival Friends', _Images.festival),
            _entry('14:00', '16:30', 'Forest Detectives', _Images.forest),
            _entry('16:30', '18:00', 'Tiger Tales', _Images.tiger),
            _entry('18:00', '20:00', 'Around the World', _Images.tokyo),
            _entry('20:00', '21:00', 'Bedtime Club', _Images.ceremony),
            _entry('21:00', '24:00', 'Dreamtime Stories', _Images.forest),
          ]),
        ),
        _CalendarChannel(
          id: 'stream-news',
          title: 'Stream News',
          logoUrl: _Images.tokyo,
          programs: [
            for (var hour = 0; hour < 24; hour++)
              _CalendarProgram(
                id: 'news-${hour + 1}',
                title: hour % 3 == 0 ? 'World News' : 'Newsroom Live',
                description: 'News programming on StreamTV.',
                thumbnailUrl: _Images.tokyo,
                startMinute: hour * 60,
                endMinute: (hour + 1) * 60,
              ),
          ],
        ),
      ],
    );
  }

  final String dateLabel;
  final List<_CalendarChannel> channels;
}

final class _CalendarChannel {
  const _CalendarChannel({
    required this.id,
    required this.title,
    required this.logoUrl,
    required this.programs,
  });

  final String id;
  final String title;
  final String logoUrl;
  final List<_CalendarProgram> programs;

  String get initials {
    return title
        .split(' ')
        .where((word) => word.isNotEmpty)
        .take(2)
        .map((word) => word.characters.first)
        .join()
        .toUpperCase();
  }

  Color get accentColor {
    const palette = [
      Color(0xFF2E7D68),
      Color(0xFF28669B),
      Color(0xFF6D4A8F),
      Color(0xFF9A5A35),
      Color(0xFF8A3E59),
    ];
    return palette[id.hashCode.abs() % palette.length];
  }
}

final class _CalendarProgram {
  const _CalendarProgram({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.startMinute,
    required this.endMinute,
  });

  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final int startMinute;
  final int endMinute;

  int get durationMinutes => endMinute - startMinute;
  String get timeLabel => '${_clock(startMinute)} - ${_clock(endMinute)}';
}

final class _ProgramEntry {
  const _ProgramEntry(this.start, this.end, this.title, this.thumbnailUrl);

  final String start;
  final String end;
  final String title;
  final String thumbnailUrl;
}

List<_CalendarProgram> _programs(
  String channelId,
  List<_ProgramEntry> entries,
) {
  return entries.indexed
      .map((entry) {
        final value = entry.$2;
        return _CalendarProgram(
          id: '$channelId-${entry.$1 + 1}',
          title: value.title,
          description: '${value.title} on StreamTV.',
          thumbnailUrl: value.thumbnailUrl,
          startMinute: _minute(value.start),
          endMinute: _minute(value.end),
        );
      })
      .toList(growable: false);
}

_ProgramEntry _entry(String start, String end, String title, String imageUrl) {
  return _ProgramEntry(start, end, title, imageUrl);
}

int _minute(String time) {
  final parts = time.split(':').map(int.parse).toList(growable: false);
  return parts[0] * 60 + parts[1];
}

String _clock(int minute) {
  final bounded = minute.clamp(0, 1440);
  if (bounded == 1440) {
    return '24:00';
  }
  final hour = bounded ~/ 60;
  final minutes = bounded % 60;
  return '${hour.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
}

abstract final class _Images {
  static const String basketball =
      'https://images.pexels.com/photos/9839903/pexels-photo-9839903.jpeg?auto=compress&cs=tinysrgb&w=1200';
  static const String football =
      'https://images.pexels.com/photos/36958062/pexels-photo-36958062.jpeg?auto=compress&cs=tinysrgb&w=1200';
  static const String cricket =
      'https://images.pexels.com/photos/11023865/pexels-photo-11023865.jpeg?auto=compress&cs=tinysrgb&w=1200';
  static const String tiger =
      'https://images.pexels.com/photos/25785873/pexels-photo-25785873.jpeg?auto=compress&cs=tinysrgb&w=1200';
  static const String forest =
      'https://images.pexels.com/photos/1671325/pexels-photo-1671325.jpeg?auto=compress&cs=tinysrgb&w=1200';
  static const String ocean =
      'https://images.pexels.com/photos/920163/pexels-photo-920163.jpeg?auto=compress&cs=tinysrgb&w=1200';
  static const String festival =
      'https://images.pexels.com/photos/30765119/pexels-photo-30765119/free-photo-of-vibrant-traditional-chinese-cultural-festival.jpeg?auto=compress&cs=tinysrgb&w=1200';
  static const String tokyo =
      'https://images.pexels.com/photos/12343886/pexels-photo-12343886.jpeg?auto=compress&cs=tinysrgb&w=1200';
  static const String ceremony =
      'https://images.pexels.com/photos/31370378/pexels-photo-31370378.jpeg?auto=compress&cs=tinysrgb&w=1200';
}
