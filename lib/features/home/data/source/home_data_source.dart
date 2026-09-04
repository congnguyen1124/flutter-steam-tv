import 'package:flutter_steam_tv/features/home/data/model/home_section_dto.dart';

abstract interface class HomeDataSource {
  Future<List<HomeSectionDto>> fetchHomeSections();
}
