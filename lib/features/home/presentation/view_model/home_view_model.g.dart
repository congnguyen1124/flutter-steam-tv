// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HomeViewModel)
final homeViewModelProvider = HomeViewModelProvider._();

final class HomeViewModelProvider
    extends $AsyncNotifierProvider<HomeViewModel, List<HomeSection>> {
  HomeViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeViewModelHash();

  @$internal
  @override
  HomeViewModel create() => HomeViewModel();
}

String _$homeViewModelHash() => r'e8b8441e2af14ab08734ea227837d94ac43fba7f';

abstract class _$HomeViewModel extends $AsyncNotifier<List<HomeSection>> {
  FutureOr<List<HomeSection>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<HomeSection>>, List<HomeSection>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<HomeSection>>, List<HomeSection>>,
              AsyncValue<List<HomeSection>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
