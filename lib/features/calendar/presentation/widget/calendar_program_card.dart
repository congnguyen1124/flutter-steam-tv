import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_colors.dart';
import 'package:flutter_steam_tv/features/calendar/presentation/model/calendar_models.dart';
import 'package:flutter_steam_tv/features/home/presentation/widget/home_network_image.dart';

final class CalendarProgramCard extends StatelessWidget {
  const CalendarProgramCard({
    required this.program,
    required this.selected,
    super.key,
  });

  final CalendarProgram program;
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

@Preview(name: 'Calendar - program card', size: Size(214, 150))
Widget calendarProgramCardPreview() {
  const program = CalendarProgram(
    id: 'preview-program',
    title: 'Realm of the Bengal Tiger',
    description: 'A journey into the wild.',
    thumbnailUrl: '',
    startMinute: 7 * 60,
    endMinute: 9 * 60,
  );

  return const Material(
    color: StreamTvColors.background,
    child: CalendarProgramCard(program: program, selected: true),
  );
}
