// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Owns the native player for one item.
///
/// Separate from [PlayerViewModel] because the two have different lifetimes and different
/// consumers: the video surface needs the controller object itself, while the screen needs a state
/// snapshot. Keeping them apart also means a rebuild of the screen cannot take the player down
/// with it.
///
/// Auto-disposed, and [Ref.onDispose] closes the player. That is not optional — a leaked player
/// holds a hardware decoder, and on most TVs the third or fourth leaked decoder is where playback
/// stops being able to start at all. Navigating away disposes this provider, which releases it.

@ProviderFor(playerController)
final playerControllerProvider = PlayerControllerFamily._();

/// Owns the native player for one item.
///
/// Separate from [PlayerViewModel] because the two have different lifetimes and different
/// consumers: the video surface needs the controller object itself, while the screen needs a state
/// snapshot. Keeping them apart also means a rebuild of the screen cannot take the player down
/// with it.
///
/// Auto-disposed, and [Ref.onDispose] closes the player. That is not optional — a leaked player
/// holds a hardware decoder, and on most TVs the third or fourth leaked decoder is where playback
/// stops being able to start at all. Navigating away disposes this provider, which releases it.

final class PlayerControllerProvider
    extends
        $FunctionalProvider<
          AsyncValue<StreamPlayerController>,
          StreamPlayerController,
          FutureOr<StreamPlayerController>
        >
    with
        $FutureModifier<StreamPlayerController>,
        $FutureProvider<StreamPlayerController> {
  /// Owns the native player for one item.
  ///
  /// Separate from [PlayerViewModel] because the two have different lifetimes and different
  /// consumers: the video surface needs the controller object itself, while the screen needs a state
  /// snapshot. Keeping them apart also means a rebuild of the screen cannot take the player down
  /// with it.
  ///
  /// Auto-disposed, and [Ref.onDispose] closes the player. That is not optional — a leaked player
  /// holds a hardware decoder, and on most TVs the third or fourth leaked decoder is where playback
  /// stops being able to start at all. Navigating away disposes this provider, which releases it.
  PlayerControllerProvider._({
    required PlayerControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'playerControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$playerControllerHash();

  @override
  String toString() {
    return r'playerControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<StreamPlayerController> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<StreamPlayerController> create(Ref ref) {
    final argument = this.argument as String;
    return playerController(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PlayerControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$playerControllerHash() => r'3c3511fd447edaf96f4c411058f4ee8b23af1866';

/// Owns the native player for one item.
///
/// Separate from [PlayerViewModel] because the two have different lifetimes and different
/// consumers: the video surface needs the controller object itself, while the screen needs a state
/// snapshot. Keeping them apart also means a rebuild of the screen cannot take the player down
/// with it.
///
/// Auto-disposed, and [Ref.onDispose] closes the player. That is not optional — a leaked player
/// holds a hardware decoder, and on most TVs the third or fourth leaked decoder is where playback
/// stops being able to start at all. Navigating away disposes this provider, which releases it.

final class PlayerControllerFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<StreamPlayerController>, String> {
  PlayerControllerFamily._()
    : super(
        retry: null,
        name: r'playerControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Owns the native player for one item.
  ///
  /// Separate from [PlayerViewModel] because the two have different lifetimes and different
  /// consumers: the video surface needs the controller object itself, while the screen needs a state
  /// snapshot. Keeping them apart also means a rebuild of the screen cannot take the player down
  /// with it.
  ///
  /// Auto-disposed, and [Ref.onDispose] closes the player. That is not optional — a leaked player
  /// holds a hardware decoder, and on most TVs the third or fourth leaked decoder is where playback
  /// stops being able to start at all. Navigating away disposes this provider, which releases it.

  PlayerControllerProvider call(String itemId) =>
      PlayerControllerProvider._(argument: itemId, from: this);

  @override
  String toString() => r'playerControllerProvider';
}

/// Drives the player screen.
///
/// Resolves the item, starts playback, and republishes the player's snapshot as [PlayerUiState].
/// Every action is a one-line forward to the controller: the screen has no playback logic, and
/// neither does this class — that all lives in the native host behind `stream_player`.

@ProviderFor(PlayerViewModel)
final playerViewModelProvider = PlayerViewModelFamily._();

/// Drives the player screen.
///
/// Resolves the item, starts playback, and republishes the player's snapshot as [PlayerUiState].
/// Every action is a one-line forward to the controller: the screen has no playback logic, and
/// neither does this class — that all lives in the native host behind `stream_player`.
final class PlayerViewModelProvider
    extends $AsyncNotifierProvider<PlayerViewModel, PlayerUiState> {
  /// Drives the player screen.
  ///
  /// Resolves the item, starts playback, and republishes the player's snapshot as [PlayerUiState].
  /// Every action is a one-line forward to the controller: the screen has no playback logic, and
  /// neither does this class — that all lives in the native host behind `stream_player`.
  PlayerViewModelProvider._({
    required PlayerViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'playerViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$playerViewModelHash();

  @override
  String toString() {
    return r'playerViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PlayerViewModel create() => PlayerViewModel();

  @override
  bool operator ==(Object other) {
    return other is PlayerViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$playerViewModelHash() => r'148811c177606dec8089bdbb143589dc9aef08e3';

/// Drives the player screen.
///
/// Resolves the item, starts playback, and republishes the player's snapshot as [PlayerUiState].
/// Every action is a one-line forward to the controller: the screen has no playback logic, and
/// neither does this class — that all lives in the native host behind `stream_player`.

final class PlayerViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          PlayerViewModel,
          AsyncValue<PlayerUiState>,
          PlayerUiState,
          FutureOr<PlayerUiState>,
          String
        > {
  PlayerViewModelFamily._()
    : super(
        retry: null,
        name: r'playerViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Drives the player screen.
  ///
  /// Resolves the item, starts playback, and republishes the player's snapshot as [PlayerUiState].
  /// Every action is a one-line forward to the controller: the screen has no playback logic, and
  /// neither does this class — that all lives in the native host behind `stream_player`.

  PlayerViewModelProvider call(String itemId) =>
      PlayerViewModelProvider._(argument: itemId, from: this);

  @override
  String toString() => r'playerViewModelProvider';
}

/// Drives the player screen.
///
/// Resolves the item, starts playback, and republishes the player's snapshot as [PlayerUiState].
/// Every action is a one-line forward to the controller: the screen has no playback logic, and
/// neither does this class — that all lives in the native host behind `stream_player`.

abstract class _$PlayerViewModel extends $AsyncNotifier<PlayerUiState> {
  late final _$args = ref.$arg as String;
  String get itemId => _$args;

  FutureOr<PlayerUiState> build(String itemId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<PlayerUiState>, PlayerUiState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PlayerUiState>, PlayerUiState>,
              AsyncValue<PlayerUiState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
