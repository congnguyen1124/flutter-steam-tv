import 'package:flutter_steam_tv/features/home/domain/model/home_section.dart';

abstract interface class HomeRepository {
  Future<List<HomeSection>> getHomeSections();
}
