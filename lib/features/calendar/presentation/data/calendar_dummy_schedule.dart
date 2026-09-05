import 'package:flutter_steam_tv/features/calendar/presentation/model/calendar_models.dart';

abstract final class CalendarDummySchedule {
  static CalendarDay build() {
    return CalendarDay(
      dateLabel: 'WED, 02 SEP',
      channels: [
        CalendarChannel(
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
        CalendarChannel(
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
        const CalendarChannel(
          id: 'stream-local',
          title: 'Stream Local',
          logoUrl: '',
          programs: [],
        ),
        CalendarChannel(
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
        CalendarChannel(
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
        CalendarChannel(
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
        CalendarChannel(
          id: 'stream-news',
          title: 'Stream News',
          logoUrl: _Images.tokyo,
          programs: [
            for (var hour = 0; hour < 24; hour++)
              CalendarProgram(
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
}

final class _ProgramEntry {
  const _ProgramEntry(this.start, this.end, this.title, this.thumbnailUrl);

  final String start;
  final String end;
  final String title;
  final String thumbnailUrl;
}

List<CalendarProgram> _programs(String channelId, List<_ProgramEntry> entries) {
  return entries.indexed
      .map((entry) {
        final value = entry.$2;
        return CalendarProgram(
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
