// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'top_bar_readability_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the current destination is asking for the top-bar readability layer.
///
/// ## Why a provider and not a callback
///
/// The top bar lives in the browsing shell; the content that scrolls under it lives in a routed
/// destination. They are siblings under a `ShellRoute`, not parent and child, so there is no prop to
/// pass — the shell composes `child`, and go_router owns what that child is.
///
/// The alternative, an `InheritedWidget` published by the shell, would work and would put the shell
/// in charge of a value only the destination can compute. This keeps the direction the same as every
/// other piece of state in the app: the destination writes, the shell watches.
///
/// ## Why the destination decides
///
/// Only a destination that draws *behind* the bar needs the layer, and only while something is
/// actually behind it. Home is the one such destination today: its hero carries its own scrim, so the
/// layer would be redundant — and visibly wrong — over the first section, and necessary over every
/// section below it. `spec/home.md` states exactly that rule, and it is Home's to state.
///
/// Auto-dispose, so leaving the shell resets it. A destination that never asks gets `false`.

@ProviderFor(TopBarReadability)
final topBarReadabilityProvider = TopBarReadabilityProvider._();

/// Whether the current destination is asking for the top-bar readability layer.
///
/// ## Why a provider and not a callback
///
/// The top bar lives in the browsing shell; the content that scrolls under it lives in a routed
/// destination. They are siblings under a `ShellRoute`, not parent and child, so there is no prop to
/// pass — the shell composes `child`, and go_router owns what that child is.
///
/// The alternative, an `InheritedWidget` published by the shell, would work and would put the shell
/// in charge of a value only the destination can compute. This keeps the direction the same as every
/// other piece of state in the app: the destination writes, the shell watches.
///
/// ## Why the destination decides
///
/// Only a destination that draws *behind* the bar needs the layer, and only while something is
/// actually behind it. Home is the one such destination today: its hero carries its own scrim, so the
/// layer would be redundant — and visibly wrong — over the first section, and necessary over every
/// section below it. `spec/home.md` states exactly that rule, and it is Home's to state.
///
/// Auto-dispose, so leaving the shell resets it. A destination that never asks gets `false`.
final class TopBarReadabilityProvider
    extends $NotifierProvider<TopBarReadability, bool> {
  /// Whether the current destination is asking for the top-bar readability layer.
  ///
  /// ## Why a provider and not a callback
  ///
  /// The top bar lives in the browsing shell; the content that scrolls under it lives in a routed
  /// destination. They are siblings under a `ShellRoute`, not parent and child, so there is no prop to
  /// pass — the shell composes `child`, and go_router owns what that child is.
  ///
  /// The alternative, an `InheritedWidget` published by the shell, would work and would put the shell
  /// in charge of a value only the destination can compute. This keeps the direction the same as every
  /// other piece of state in the app: the destination writes, the shell watches.
  ///
  /// ## Why the destination decides
  ///
  /// Only a destination that draws *behind* the bar needs the layer, and only while something is
  /// actually behind it. Home is the one such destination today: its hero carries its own scrim, so the
  /// layer would be redundant — and visibly wrong — over the first section, and necessary over every
  /// section below it. `spec/home.md` states exactly that rule, and it is Home's to state.
  ///
  /// Auto-dispose, so leaving the shell resets it. A destination that never asks gets `false`.
  TopBarReadabilityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'topBarReadabilityProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$topBarReadabilityHash();

  @$internal
  @override
  TopBarReadability create() => TopBarReadability();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$topBarReadabilityHash() => r'21436005234ec63f2970ee5c6e9965e092f20d56';

/// Whether the current destination is asking for the top-bar readability layer.
///
/// ## Why a provider and not a callback
///
/// The top bar lives in the browsing shell; the content that scrolls under it lives in a routed
/// destination. They are siblings under a `ShellRoute`, not parent and child, so there is no prop to
/// pass — the shell composes `child`, and go_router owns what that child is.
///
/// The alternative, an `InheritedWidget` published by the shell, would work and would put the shell
/// in charge of a value only the destination can compute. This keeps the direction the same as every
/// other piece of state in the app: the destination writes, the shell watches.
///
/// ## Why the destination decides
///
/// Only a destination that draws *behind* the bar needs the layer, and only while something is
/// actually behind it. Home is the one such destination today: its hero carries its own scrim, so the
/// layer would be redundant — and visibly wrong — over the first section, and necessary over every
/// section below it. `spec/home.md` states exactly that rule, and it is Home's to state.
///
/// Auto-dispose, so leaving the shell resets it. A destination that never asks gets `false`.

abstract class _$TopBarReadability extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
