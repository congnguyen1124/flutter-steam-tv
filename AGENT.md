# Flutter StreamTV Engineering Rules

## Source of truth

- Treat this project's `spec/` as the product contract. Read the matching spec before changing a
  screen or interaction.
- Use `../android_stream_tv/spec/` only as upstream reference when the Flutter spec has not yet
  described a behavior, then record the chosen Flutter behavior in this project's spec.
- Use the Android Compose project as a behavior and visual reference, not as a line-by-line template.
- Keep all user-facing copy, accessibility labels, preview fixtures, and dummy data in English.

## Architecture

- Organize code feature-first: `features/<feature>/{data,domain,presentation}`.
- Keep the dependency direction `View -> ViewModel -> Repository -> DataSource`.
- ViewModels call domain repository interfaces directly. Do not add a UseCase layer unless logic
  coordinates multiple repositories or is reused by multiple ViewModels.
- Domain code must not import Flutter, Dio, DTOs, or data-layer implementations.
- DataSources own I/O and transport models. Repositories map data models to immutable domain models.
- Keep Riverpod wiring in `<feature>_providers.dart` at the feature root so data implementations stay
  framework-agnostic and ViewModels consume domain-typed providers.
- Put code in `core/` only after it has a genuine cross-feature consumer.

## Riverpod state

- Use generated providers with `riverpod_annotation`; never edit generated files.
- Model feature ViewModels as generated `Notifier` or `AsyncNotifier` classes with public action
  methods. Do not expose mutable public fields.
- Use `AsyncValue<T>` as the LCE state for asynchronous screens. Do not duplicate it with booleans
  such as `isLoading` plus nullable `data` and `error`.
- Use `ref.watch` for reactive dependencies, `ref.read` in event callbacks, and `ref.listen` for
  one-shot UI side effects.
- Generated providers are auto-dispose by default. Use `keepAlive` only for app-lifetime
  infrastructure or an explicitly documented cache requirement.
- Override providers at test/preview boundaries. Do not add production `isTest` switches.

## TV presentation

- Separate a Riverpod-aware `Route` from pure `Screen` and small presentation widgets by default.
  Home is the explicit exception: `HomeScreen` is its feature boundary and there is no `HomeRoute`.
- Split a widget when it owns more than one layout responsibility or its state/focus behavior can be
  tested independently. Keep screen files orchestration-focused; avoid large private-widget piles.
- Every new or materially changed screen/widget needs deterministic `@Preview` coverage. Screen
  previews must include Loading, Content, and Error when the screen uses LCE.
- Preview code must not use network access, real players, `dart:io`, FFI, or native-only plugins.
- Use 1280x720 as the default TV preview size and add 1920x1080 for breakpoint-sensitive layouts.
- Make D-pad focus explicit and deterministic. Remote Select must invoke the same action as tap/click.
- Keep focus borders inside stable widget dimensions so focus does not shift surrounding layout.
- Use dot shorthand when the context type is obvious (`.dark`, `.video`, `const .loading()`). Do not
  force shorthand where it obscures the resolved type.
- Use Roboto through the app theme. Reuse icons from `assets/icons` before adding new icon sources.

## Assets

- Put raster images in `assets/images`, SVG icons in `assets/icons`, and fonts in `assets/fonts`.
- Convert Android VectorDrawable files with:

  `python3 tools/android_vector_to_svg.py ../android_stream_tv/app/src/main/res/drawable assets/icons --overwrite`

- Commit source assets and generated SVG assets. Do not commit generated preview caches.
- Register every asset directory and font family in `pubspec.yaml`.

## Generated code and validation

- After changing `@riverpod`, `@freezed`, or JSON models, run:

  `dart run build_runner build`

- Before handing off any Dart change, run in this order:

  `dart format .`

  `flutter analyze`

  `flutter test`

- Run `flutter pub get` after dependency or asset changes.
- Fix analyzer findings instead of suppressing them. A suppression needs a short reason next to the
  narrowest possible line.
- Never edit `*.g.dart` or `*.freezed.dart` by hand.
- Do not commit or push unless the user explicitly asks in the current task.

## Dependency compatibility

- `riverpod_lint` is configured as an `analysis_server_plugin` in `analysis_options.yaml`; it is not
  a `custom_lint` plugin on Riverpod 3.x.
- Do not add `custom_lint` or force analyzer overrides until its analyzer range is compatible with
  `riverpod_generator`. Re-run pub resolution before changing this decision.
