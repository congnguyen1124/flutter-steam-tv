import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'top_bar_readability_view_model.g.dart';

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
@riverpod
final class TopBarReadability extends _$TopBarReadability {
  @override
  bool build() => false;

  /// Requests or releases the layer. Idempotent, so a destination may call it on every focus change.
  void request({required bool isRequested}) {
    if (state != isRequested) {
      state = isRequested;
    }
  }
}
