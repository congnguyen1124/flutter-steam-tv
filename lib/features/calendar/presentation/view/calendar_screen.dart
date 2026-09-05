import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_colors.dart';
import 'package:flutter_steam_tv/features/calendar/presentation/data/calendar_dummy_schedule.dart';
import 'package:flutter_steam_tv/features/calendar/presentation/model/calendar_models.dart';
import 'package:flutter_steam_tv/features/calendar/presentation/widget/calendar_guide.dart';
import 'package:flutter_steam_tv/features/calendar/presentation/widget/calendar_metrics.dart';

final class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

final class _CalendarScreenState extends State<CalendarScreen> {
  static final CalendarDay _schedule = CalendarDummySchedule.build();

  final FocusNode _gridFocusNode = FocusNode(debugLabel: 'calendar-grid');
  int _selectedChannelIndex = 0;
  int _selectedProgramIndex = 0;
  double _horizontalOffset = 0;
  double _verticalOffset = 0;
  double _gridWidth = 0;
  double _gridHeight = 0;
  bool _isAnimating = false;
  Timer? _animationTimer;

  @override
  void initState() {
    super.initState();
    _normalizeSelection();
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    _gridFocusNode.dispose();
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
                child: CalendarGuide(
                  schedule: _schedule,
                  gridFocusNode: _gridFocusNode,
                  selectedChannelIndex: _selectedChannelIndex,
                  selectedProgramIndex: _selectedProgramIndex,
                  horizontalOffset: _horizontalOffset,
                  verticalOffset: _verticalOffset,
                  onKeyEvent: _handleGridKeyEvent,
                  onViewportChanged: _handleViewportChanged,
                ),
              )
            : const _CalendarMessage(
                message: 'No programs are available for this day',
              ),
      ),
    );
  }

  KeyEventResult _handleGridKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (_isAnimating) {
      return KeyEventResult.handled;
    }

    return switch (event.logicalKey) {
      LogicalKeyboardKey.arrowUp => _moveSelection(_CalendarDirection.up),
      LogicalKeyboardKey.arrowDown => _moveSelection(_CalendarDirection.down),
      LogicalKeyboardKey.arrowLeft => _moveSelection(_CalendarDirection.left),
      LogicalKeyboardKey.arrowRight => _moveSelection(_CalendarDirection.right),
      LogicalKeyboardKey.enter ||
      LogicalKeyboardKey.select ||
      LogicalKeyboardKey.numpadEnter => KeyEventResult.handled,
      _ => KeyEventResult.ignored,
    };
  }

  KeyEventResult _moveSelection(_CalendarDirection direction) {
    final target = _targetPosition(direction);
    if (target == null ||
        (target.channelIndex == _selectedChannelIndex &&
            target.programIndex == _selectedProgramIndex)) {
      return KeyEventResult.ignored;
    }

    setState(() {
      _isAnimating = true;
      _selectedChannelIndex = target.channelIndex;
      _selectedProgramIndex = target.programIndex;
      _syncViewport();
    });
    _animationTimer?.cancel();
    _animationTimer = Timer(CalendarGuide.moveDuration, () {
      if (mounted) {
        setState(() => _isAnimating = false);
      }
    });
    return KeyEventResult.handled;
  }

  _CalendarPosition? _targetPosition(_CalendarDirection direction) {
    final currentChannel = _schedule.channels[_selectedChannelIndex];
    final currentProgram = currentChannel.programs[_selectedProgramIndex];

    return switch (direction) {
      _CalendarDirection.up =>
        _selectedProgramIndex > 0
            ? _CalendarPosition(
                _selectedChannelIndex,
                _selectedProgramIndex - 1,
              )
            : null,
      _CalendarDirection.down =>
        _selectedProgramIndex < currentChannel.programs.length - 1
            ? _CalendarPosition(
                _selectedChannelIndex,
                _selectedProgramIndex + 1,
              )
            : null,
      _CalendarDirection.left ||
      _CalendarDirection.right => _horizontalTarget(direction, currentProgram),
    };
  }

  _CalendarPosition? _horizontalTarget(
    _CalendarDirection direction,
    CalendarProgram currentProgram,
  ) {
    final step = direction == _CalendarDirection.left ? -1 : 1;
    var channelIndex = _selectedChannelIndex + step;
    while (channelIndex >= 0 && channelIndex < _schedule.channels.length) {
      final targetPrograms = _schedule.channels[channelIndex].programs;
      if (targetPrograms.isNotEmpty) {
        final referenceMinute =
            (currentProgram.startMinute + currentProgram.endMinute) / 2;
        var bestIndex = 0;
        var bestScore = double.infinity;
        for (final entry in targetPrograms.indexed) {
          final program = entry.$2;
          final distance = _distanceFrom(program, referenceMinute);
          final midpoint = (program.startMinute + program.endMinute) / 2;
          final score = distance * 10000 + (midpoint - referenceMinute).abs();
          if (score < bestScore) {
            bestScore = score;
            bestIndex = entry.$1;
          }
        }
        return _CalendarPosition(channelIndex, bestIndex);
      }
      channelIndex += step;
    }
    return null;
  }

  double _distanceFrom(CalendarProgram program, double minute) {
    if (minute < program.startMinute) {
      return program.startMinute - minute;
    }
    if (minute >= program.endMinute) {
      return minute - program.endMinute;
    }
    return 0;
  }

  void _handleViewportChanged(double gridWidth, double gridHeight) {
    if (_gridWidth == gridWidth && _gridHeight == gridHeight) {
      return;
    }
    setState(() {
      _gridWidth = gridWidth;
      _gridHeight = gridHeight;
      _syncViewport();
    });
  }

  void _syncViewport() {
    if (_gridWidth <= 0 || _gridHeight <= 0) {
      _horizontalOffset = 0;
      _verticalOffset = 0;
      return;
    }
    final selected = _selectedProgram;
    final maxHorizontalOffset = math.max(
      0,
      CalendarMetrics.contentWidth(_schedule.channels.length) - _gridWidth,
    );
    final maxVerticalOffset = math.max(
      0,
      CalendarMetrics.contentHeight - _gridHeight,
    );
    _horizontalOffset = (_selectedChannelIndex * CalendarMetrics.columnPitch)
        .clamp(0.0, maxHorizontalOffset)
        .toDouble();
    _verticalOffset = CalendarMetrics.programTop(
      selected,
    ).clamp(0.0, maxVerticalOffset).toDouble();
  }

  void _normalizeSelection() {
    final firstChannelIndex = _schedule.channels.indexWhere((channel) {
      return channel.programs.isNotEmpty;
    });
    _selectedChannelIndex = math.max(firstChannelIndex, 0);
    _selectedProgramIndex = 0;
  }

  CalendarProgram get _selectedProgram {
    return _schedule
        .channels[_selectedChannelIndex]
        .programs[_selectedProgramIndex];
  }
}

final class _CalendarMessage extends StatelessWidget {
  const _CalendarMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(
          color: StreamTvColors.onSurfaceMuted,
          fontSize: 20,
        ),
      ),
    );
  }
}

enum _CalendarDirection { up, down, left, right }

final class _CalendarPosition {
  const _CalendarPosition(this.channelIndex, this.programIndex);

  final int channelIndex;
  final int programIndex;
}
