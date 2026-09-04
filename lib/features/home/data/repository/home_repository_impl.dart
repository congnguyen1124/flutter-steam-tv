import 'package:flutter_steam_tv/features/home/data/mapper/home_data_mapper.dart';
import 'package:flutter_steam_tv/features/home/data/source/home_data_source.dart';
import 'package:flutter_steam_tv/features/home/domain/model/home_section.dart';
import 'package:flutter_steam_tv/features/home/domain/repository/home_repository.dart';

final class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl(this._dataSource);

  final HomeDataSource _dataSource;

  @override
  Future<List<HomeSection>> getHomeSections() async {
    final data = await _dataSource.fetchHomeSections();
    return List.unmodifiable(data.map((section) => section.toDomain()));
  }
}
