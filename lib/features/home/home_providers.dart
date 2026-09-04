import 'package:flutter_steam_tv/features/home/data/repository/home_repository_impl.dart';
import 'package:flutter_steam_tv/features/home/data/source/home_data_source.dart';
import 'package:flutter_steam_tv/features/home/domain/repository/home_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_providers.g.dart';

@Riverpod(keepAlive: true)
HomeDataSource homeDataSource(Ref ref) => const HomeDummyDataSource();

@Riverpod(keepAlive: true)
HomeRepository homeRepository(Ref ref) {
  return HomeRepositoryImpl(ref.watch(homeDataSourceProvider));
}
