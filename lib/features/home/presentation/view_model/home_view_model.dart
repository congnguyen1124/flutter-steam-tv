import 'package:flutter_steam_tv/features/home/domain/model/home_section.dart';
import 'package:flutter_steam_tv/features/home/home_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_view_model.g.dart';

@riverpod
final class HomeViewModel extends _$HomeViewModel {
  @override
  Future<List<HomeSection>> build() =>
      ref.watch(homeRepositoryProvider).getHomeSections();

  Future<void> reload() async {
    state = const .loading();
    state = await AsyncValue.guard(
      ref.read(homeRepositoryProvider).getHomeSections,
    );
  }
}
