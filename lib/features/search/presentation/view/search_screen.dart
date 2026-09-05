import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_colors.dart';
import 'package:flutter_steam_tv/core/widgets/list_content_view/list_content_view.dart';
import 'package:flutter_steam_tv/features/home/domain/model/home_item.dart';
import 'package:flutter_steam_tv/features/home/domain/model/home_section.dart';
import 'package:flutter_steam_tv/features/home/home_providers.dart';
import 'package:flutter_steam_tv/features/home/presentation/widget/home_content_card.dart';

final class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({required this.onItemPressed, super.key});

  final ValueChanged<HomeItem> onItemPressed;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

final class _SearchScreenState extends ConsumerState<SearchScreen> {
  static const List<String> _curatedSearches = [
    'Japanese culture',
    'Live sports',
    'Tiger documentary',
    'Lunar New Year',
    'Festival colors',
    'Football moments',
  ];

  final ScrollController _resultsController = ScrollController();
  final FocusNode _firstKeyboardKeyFocusNode = FocusNode(
    debugLabel: 'search-first-key',
  );
  final FocusNode _searchKeyFocusNode = FocusNode(debugLabel: 'search-submit');
  final FocusNode _firstSuggestionFocusNode = FocusNode(
    debugLabel: 'search-first-suggestion',
  );
  final FocusNode _videosRowFocusNode = FocusNode(debugLabel: 'search-videos');
  final FocusNode _shortsRowFocusNode = FocusNode(debugLabel: 'search-shorts');
  Timer? _caretTimer;
  List<HomeItem> _catalog = const [];
  List<HomeItem> _videos = const [];
  List<HomeItem> _shorts = const [];
  List<String> _recentSearches = const [];
  String _query = '';
  int _cursorPosition = 0;
  bool _keyboardVisible = true;
  bool _isLoading = true;
  bool _isSearching = false;
  bool _caretVisible = true;
  String? _submittedQuery;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _caretTimer = Timer.periodic(const Duration(milliseconds: 620), (_) {
      if (mounted) {
        setState(() => _caretVisible = !_caretVisible);
      }
    });
    unawaited(_loadRecommendations());
  }

  @override
  void dispose() {
    _caretTimer?.cancel();
    _resultsController.dispose();
    _firstKeyboardKeyFocusNode.dispose();
    _searchKeyFocusNode.dispose();
    _firstSuggestionFocusNode.dispose();
    _videosRowFocusNode.dispose();
    _shortsRowFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sections = _resultSections;

    return Focus(
      canRequestFocus: false,
      onKeyEvent: _handleScreenKeyEvent,
      child: ColoredBox(
        key: const ValueKey('search-screen'),
        color: StreamTvColors.background,
        child: Padding(
          padding: const EdgeInsets.only(
            left: 48,
            top: 12,
            right: 24,
            bottom: 18,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: _keyboardVisible
                    ? _SearchWorkspace(
                        key: const ValueKey('search-workspace-visible'),
                        query: _query,
                        cursorPosition: _cursorPosition,
                        showCaret: _caretVisible,
                        suggestions: _suggestions,
                        firstSuggestionFocusNode: _firstSuggestionFocusNode,
                        firstKeyboardKeyFocusNode: _firstKeyboardKeyFocusNode,
                        searchKeyFocusNode: _searchKeyFocusNode,
                        onSuggestionPressed: _selectSuggestion,
                        onKeyPressed: _insert,
                        onBackspace: _backspace,
                        onClear: _clear,
                        onCursorLeft: _moveCursorLeft,
                        onCursorRight: _moveCursorRight,
                        onSearch: _submitSearch,
                        onMoveToResults: _moveToResults,
                      )
                    : const SizedBox(
                        key: ValueKey('search-workspace-hidden'),
                        height: 0,
                      ),
              ),
              SizedBox(height: _keyboardVisible ? 10 : 18),
              Expanded(
                child: _SearchResults(
                  controller: _resultsController,
                  sections: sections,
                  submittedQuery: _submittedQuery,
                  isLoading: _isLoading,
                  isSearching: _isSearching,
                  errorMessage: _errorMessage,
                  onFirstRowUp: _showKeyboardFromResults,
                  onItemPressed: widget.onItemPressed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadRecommendations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final sections = await ref.read(homeRepositoryProvider).getHomeSections();
      final catalog = _uniquePlayableCatalog(sections);
      if (!mounted) {
        return;
      }
      setState(() {
        _catalog = catalog;
        _videos = catalog
            .where((item) => item.kind == HomeItemKind.video)
            .toList(growable: false);
        _shorts = catalog
            .where((item) => item.kind == HomeItemKind.short)
            .toList(growable: false);
        _isLoading = false;
      });
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _errorMessage = error is StateError
            ? error.message
            : 'Search is temporarily unavailable';
      });
    }
  }

  List<_SearchSection> get _resultSections {
    final videos = _submittedQuery == null ? _videos : _matchingItems(_videos);
    final shorts = _submittedQuery == null ? _shorts : _matchingItems(_shorts);
    return [
      if (videos.isNotEmpty)
        _SearchSection(
          id: 'search-videos',
          title: 'Videos',
          style: HomeContentCardStyle.video,
          items: videos,
          focusNode: _videosRowFocusNode,
        ),
      if (shorts.isNotEmpty)
        _SearchSection(
          id: 'search-shorts',
          title: 'Shorts',
          style: HomeContentCardStyle.short,
          items: shorts,
          focusNode: _shortsRowFocusNode,
        ),
    ];
  }

  List<HomeItem> _matchingItems(List<HomeItem> items) {
    final query = _submittedQuery;
    if (query == null) {
      return items;
    }
    final tokens = _tokens(query);
    final matches = items
        .where((item) {
          final haystack = '${item.title} ${item.description}'.toLowerCase();
          return tokens.every(haystack.contains);
        })
        .toList(growable: false);
    if (matches.isNotEmpty) {
      return matches;
    }
    return _rotatedFallback(items, query);
  }

  List<String> get _suggestions {
    final lowerQuery = _query.trim().toLowerCase();
    final seen = <String>{};
    final output = <String>[];
    for (final candidate in [
      ..._recentSearches,
      ..._curatedSearches,
      ..._catalog.map((item) => item.title),
    ]) {
      final key = candidate.toLowerCase();
      if (seen.contains(key) ||
          (lowerQuery.isNotEmpty && !key.contains(lowerQuery))) {
        continue;
      }
      seen.add(key);
      output.add(candidate);
      if (output.length == 6) {
        break;
      }
    }
    return output;
  }

  void _insert(String input) {
    final at = _cursorPosition.clamp(0, _query.length);
    setState(() {
      _query = _query.substring(0, at) + input + _query.substring(at);
      _cursorPosition = at + input.length;
      _errorMessage = null;
    });
  }

  void _backspace() {
    final at = _cursorPosition.clamp(0, _query.length);
    if (at == 0) {
      return;
    }
    setState(() {
      _query = _query.replaceRange(at - 1, at, '');
      _cursorPosition = at - 1;
      _errorMessage = null;
    });
  }

  void _clear() {
    setState(() {
      _query = '';
      _cursorPosition = 0;
      _errorMessage = null;
    });
  }

  void _moveCursorLeft() {
    setState(() => _cursorPosition = math.max(_cursorPosition - 1, 0));
  }

  void _moveCursorRight() {
    setState(() {
      _cursorPosition = math.min(_cursorPosition + 1, _query.length);
    });
  }

  void _selectSuggestion(String suggestion) {
    setState(() {
      _query = suggestion;
      _cursorPosition = suggestion.length;
    });
    unawaited(_submitSearch());
  }

  Future<void> _submitSearch() async {
    final trimmedQuery = _query.trim();
    if (trimmedQuery.isEmpty || _isSearching) {
      return;
    }
    setState(() {
      _query = trimmedQuery;
      _cursorPosition = trimmedQuery.length;
      _keyboardVisible = false;
      _isSearching = true;
      _errorMessage = null;
      _recentSearches = [
        trimmedQuery,
        ..._recentSearches.where(
          (recent) => recent.toLowerCase() != trimmedQuery.toLowerCase(),
        ),
      ].take(6).toList(growable: false);
    });

    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (!mounted) {
      return;
    }
    setState(() {
      _submittedQuery = trimmedQuery;
      _isSearching = false;
    });
    await _moveToResults();
  }

  Future<void> _moveToResults() async {
    if (_resultSections.isEmpty || _isSearching) {
      return;
    }
    setState(() => _keyboardVisible = false);
    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (!mounted) {
      return;
    }
    if (_resultsController.hasClients) {
      _resultsController.jumpTo(0);
    }
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) {
      return;
    }
    _resultSections.first.focusNode.requestFocus();
  }

  Future<void> _showKeyboardFromResults() async {
    setState(() => _keyboardVisible = true);
    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (!mounted) {
      return;
    }
    _searchKeyFocusNode.requestFocus();
  }

  KeyEventResult _handleScreenKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (!_keyboardVisible ||
        (event.logicalKey != LogicalKeyboardKey.escape &&
            event.logicalKey != LogicalKeyboardKey.goBack)) {
      return KeyEventResult.ignored;
    }

    unawaited(_moveToResults());
    return KeyEventResult.handled;
  }

  List<HomeItem> _uniquePlayableCatalog(List<HomeSection> sections) {
    final seen = <String>{};
    final items = <HomeItem>[];
    for (final section in sections) {
      for (final item in section.items) {
        if ((item.kind != HomeItemKind.video &&
                item.kind != HomeItemKind.short) ||
            !seen.add(item.id)) {
          continue;
        }
        items.add(item);
      }
    }
    return items;
  }

  List<String> _tokens(String query) {
    return query
        .trim()
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty)
        .toList(growable: false);
  }

  List<HomeItem> _rotatedFallback(List<HomeItem> items, String query) {
    if (items.length < 2) {
      return items;
    }
    final offset = query.codeUnits.fold<int>(
      0,
      (value, codeUnit) => (value + codeUnit) % items.length,
    );
    return [...items.skip(offset), ...items.take(offset)];
  }
}

final class _SearchWorkspace extends StatelessWidget {
  const _SearchWorkspace({
    required this.query,
    required this.cursorPosition,
    required this.showCaret,
    required this.suggestions,
    required this.firstSuggestionFocusNode,
    required this.firstKeyboardKeyFocusNode,
    required this.searchKeyFocusNode,
    required this.onSuggestionPressed,
    required this.onKeyPressed,
    required this.onBackspace,
    required this.onClear,
    required this.onCursorLeft,
    required this.onCursorRight,
    required this.onSearch,
    required this.onMoveToResults,
    super.key,
  });

  final String query;
  final int cursorPosition;
  final bool showCaret;
  final List<String> suggestions;
  final FocusNode firstSuggestionFocusNode;
  final FocusNode firstKeyboardKeyFocusNode;
  final FocusNode searchKeyFocusNode;
  final ValueChanged<String> onSuggestionPressed;
  final ValueChanged<String> onKeyPressed;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final VoidCallback onCursorLeft;
  final VoidCallback onCursorRight;
  final VoidCallback onSearch;
  final Future<void> Function() onMoveToResults;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 500,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SearchQuerySurface(
                  query: query,
                  cursorPosition: cursorPosition,
                  showCaret: showCaret,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 340,
                  child: Column(
                    children: [
                      for (final indexed in suggestions.indexed)
                        _SearchSuggestionTile(
                          label: indexed.$2,
                          focusNode: indexed.$1 == 0
                              ? firstSuggestionFocusNode
                              : null,
                          onPressed: () => onSuggestionPressed(indexed.$2),
                          onMoveDown: indexed.$1 == suggestions.length - 1
                              ? onMoveToResults
                              : null,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 364),
              child: _SearchVirtualKeyboard(
                firstKeyFocusNode: firstKeyboardKeyFocusNode,
                searchKeyFocusNode: searchKeyFocusNode,
                onKeyPressed: onKeyPressed,
                onBackspace: onBackspace,
                onClear: onClear,
                onCursorLeft: onCursorLeft,
                onCursorRight: onCursorRight,
                onSearch: onSearch,
                onMoveToResults: onMoveToResults,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final class _SearchQuerySurface extends StatelessWidget {
  const _SearchQuerySurface({
    required this.query,
    required this.cursorPosition,
    required this.showCaret,
  });

  final String query;
  final int cursorPosition;
  final bool showCaret;

  @override
  Widget build(BuildContext context) {
    final at = cursorPosition.clamp(0, query.length);
    final beforeCaret = query.substring(0, at);
    final afterCaret = query.substring(at);

    return ExcludeFocus(
      child: Container(
        width: 500,
        height: 36,
        decoration: BoxDecoration(
          color: StreamTvColors.surfaceContainer,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          children: [
            const Icon(
              Icons.search,
              color: StreamTvColors.onSurfaceMuted,
              size: 21,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: query.isEmpty
                  ? const Text(
                'Search movies, series, channels and shorts',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: StreamTvColors.onSurfaceMuted,
                  fontSize: 16,
                ),
              )
                  : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    beforeCaret,
                    style: const TextStyle(
                      color: StreamTvColors.onSurface,
                      fontSize: 17,
                    ),
                  ),
                  AnimatedOpacity(
                    opacity: showCaret ? 1 : 0.22,
                    duration: const Duration(milliseconds: 110),
                    child: Container(
                      width: 2,
                      height: 20,
                      color: StreamTvColors.primary,
                    ),
                  ),
                  Text(
                    afterCaret,
                    style: const TextStyle(
                      color: StreamTvColors.onSurface,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _SearchSuggestionTile extends StatefulWidget {
  const _SearchSuggestionTile({
    required this.label,
    required this.onPressed,
    this.focusNode,
    this.onMoveDown,
  });

  final String label;
  final VoidCallback onPressed;
  final FocusNode? focusNode;
  final Future<void> Function()? onMoveDown;

  @override
  State<_SearchSuggestionTile> createState() => _SearchSuggestionTileState();
}

final class _SearchSuggestionTileState extends State<_SearchSuggestionTile> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: widget.focusNode,
      onFocusChange: (focused) => setState(() => _focused = focused),
      onKeyEvent: _handleKeyEvent,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onPressed,
        child: SizedBox(
          height: 24,
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                width: 3,
                height: 18,
                decoration: BoxDecoration(
                  color: _focused ? StreamTvColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: _focused
                      ? StreamTvColors.primary
                      : Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.history,
                  size: 12,
                  color: _focused
                      ? StreamTvColors.onPrimary
                      : StreamTvColors.onSurfaceMuted,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _focused
                        ? StreamTvColors.onSurface
                        : StreamTvColors.onSurfaceMuted,
                    fontSize: 13,
                    fontWeight: _focused ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown &&
        widget.onMoveDown != null) {
      unawaited(widget.onMoveDown!());
      return KeyEventResult.handled;
    }
    return switch (event.logicalKey) {
      LogicalKeyboardKey.enter ||
      LogicalKeyboardKey.select ||
      LogicalKeyboardKey.numpadEnter => _press(),
      _ => KeyEventResult.ignored,
    };
  }

  KeyEventResult _press() {
    widget.onPressed();
    return KeyEventResult.handled;
  }
}

final class _SearchVirtualKeyboard extends StatefulWidget {
  const _SearchVirtualKeyboard({
    required this.firstKeyFocusNode,
    required this.searchKeyFocusNode,
    required this.onKeyPressed,
    required this.onBackspace,
    required this.onClear,
    required this.onCursorLeft,
    required this.onCursorRight,
    required this.onSearch,
    required this.onMoveToResults,
  });

  final FocusNode firstKeyFocusNode;
  final FocusNode searchKeyFocusNode;
  final ValueChanged<String> onKeyPressed;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final VoidCallback onCursorLeft;
  final VoidCallback onCursorRight;
  final VoidCallback onSearch;
  final Future<void> Function() onMoveToResults;

  @override
  State<_SearchVirtualKeyboard> createState() => _SearchVirtualKeyboardState();
}

final class _SearchVirtualKeyboardState extends State<_SearchVirtualKeyboard> {
  static const int _columns = 7;
  static const double _gap = 4;
  static const List<String> _symbolKeys = [
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '.',
    ',',
    '/',
    ':',
    ';',
    '-',
    '_',
    '~',
    '?',
    '!',
    '=',
    '+',
    '&',
    '@',
    '%',
    '#',
    '*',
    '|',
  ];

  bool _uppercase = false;
  bool _symbols = false;

  @override
  Widget build(BuildContext context) {
    final characterKeys = _symbols
        ? _symbolKeys
        : List.generate(26, (index) => String.fromCharCode(97 + index));

    return LayoutBuilder(
      builder: (context, constraints) {
        const rows = 4;
        final keySizeByHeight = (constraints.maxHeight - _gap * rows) / 5;
        final keySizeByWidth = (constraints.maxWidth - _gap * _columns) / 8.5;
        final keySize = math
            .min(keySizeByHeight, keySizeByWidth)
            .clamp(24.0, 60.0);
        final gridWidth = keySize * _columns + _gap * (_columns - 1);
        final gridHeight = keySize * rows + _gap * (rows - 1);
        final functionWidth = keySize * 1.5;
        final functionHeight = (gridHeight - _gap * 2) / 3;
        final keyboardWidth = gridWidth + _gap + functionWidth;

        return SizedBox(
          width: keyboardWidth,
          height: constraints.maxHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: gridWidth,
                    height: gridHeight,
                    child: Wrap(
                      spacing: _gap,
                      runSpacing: _gap,
                      children: [
                        for (final indexed in characterKeys.indexed)
                          _KeyboardKey(
                            width: keySize,
                            height: keySize,
                            focusNode: indexed.$1 == 0
                                ? widget.firstKeyFocusNode
                                : null,
                            label: _labelFor(indexed.$2),
                            onPressed: () =>
                                widget.onKeyPressed(_labelFor(indexed.$2)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: _gap),
                  SizedBox(
                    width: functionWidth,
                    child: Column(
                      children: [
                        _KeyboardKey(
                          width: functionWidth,
                          height: functionHeight,
                          label: _symbols ? 'ABC' : '?123',
                          functionKey: true,
                          onPressed: () {
                            setState(() => _symbols = !_symbols);
                          },
                        ),
                        const SizedBox(height: _gap),
                        _KeyboardKey(
                          width: functionWidth,
                          height: functionHeight,
                          icon: Icons.keyboard_arrow_up,
                          selected: _uppercase && !_symbols,
                          functionKey: true,
                          onPressed: () {
                            if (!_symbols) {
                              setState(() => _uppercase = !_uppercase);
                            }
                          },
                        ),
                        const SizedBox(height: _gap),
                        _KeyboardKey(
                          width: functionWidth,
                          height: functionHeight,
                          icon: Icons.backspace_outlined,
                          functionKey: true,
                          onPressed: widget.onBackspace,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: _gap),
              Row(
                children: [
                  _KeyboardKey(
                    width: keySize * 2.05,
                    height: keySize,
                    label: 'Space',
                    functionKey: true,
                    onPressed: () => widget.onKeyPressed(' '),
                    onMoveDown: widget.onMoveToResults,
                  ),
                  const SizedBox(width: _gap),
                  _KeyboardKey(
                    width: keySize,
                    height: keySize,
                    icon: Icons.arrow_back,
                    functionKey: true,
                    onPressed: widget.onCursorLeft,
                    onMoveDown: widget.onMoveToResults,
                  ),
                  const SizedBox(width: _gap),
                  _KeyboardKey(
                    width: keySize,
                    height: keySize,
                    icon: Icons.arrow_forward,
                    functionKey: true,
                    onPressed: widget.onCursorRight,
                    onMoveDown: widget.onMoveToResults,
                  ),
                  const SizedBox(width: _gap),
                  _KeyboardKey(
                    width: keySize * 1.35,
                    height: keySize,
                    label: 'Clear',
                    functionKey: true,
                    onPressed: widget.onClear,
                    onMoveDown: widget.onMoveToResults,
                  ),
                  const SizedBox(width: _gap),
                  _KeyboardKey(
                    width: keySize * 2.05,
                    height: keySize,
                    focusNode: widget.searchKeyFocusNode,
                    label: 'Search',
                    icon: Icons.search,
                    selected: true,
                    onPressed: widget.onSearch,
                    onMoveDown: widget.onMoveToResults,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _labelFor(String value) {
    return _uppercase && !_symbols ? value.toUpperCase() : value;
  }
}

final class _KeyboardKey extends StatefulWidget {
  const _KeyboardKey({
    required this.width,
    required this.height,
    required this.onPressed,
    this.label,
    this.icon,
    this.focusNode,
    this.functionKey = false,
    this.selected = false,
    this.onMoveDown,
  });

  final double width;
  final double height;
  final String? label;
  final IconData? icon;
  final FocusNode? focusNode;
  final bool functionKey;
  final bool selected;
  final VoidCallback onPressed;
  final Future<void> Function()? onMoveDown;

  @override
  State<_KeyboardKey> createState() => _KeyboardKeyState();
}

final class _KeyboardKeyState extends State<_KeyboardKey> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final focusedOrSelected = _focused || widget.selected;
    final background = focusedOrSelected
        ? StreamTvColors.primary
        : widget.functionKey
        ? Colors.white.withValues(alpha: 0.10)
        : StreamTvColors.surface;
    final foreground = focusedOrSelected
        ? StreamTvColors.onPrimary
        : StreamTvColors.onSurface;

    return Focus(
      focusNode: widget.focusNode,
      onFocusChange: (focused) => setState(() => _focused = focused),
      onKeyEvent: _handleKeyEvent,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 110),
          width: widget.width,
          height: widget.height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(10),
          ),
          child: widget.icon == null
              ? Text(
                  widget.label ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.icon, color: foreground, size: 18),
                    if (widget.label != null) ...[
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          widget.label!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: foreground,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown &&
        widget.onMoveDown != null) {
      unawaited(widget.onMoveDown!());
      return KeyEventResult.handled;
    }
    return switch (event.logicalKey) {
      LogicalKeyboardKey.enter ||
      LogicalKeyboardKey.select ||
      LogicalKeyboardKey.numpadEnter => _press(),
      _ => KeyEventResult.ignored,
    };
  }

  KeyEventResult _press() {
    widget.onPressed();
    return KeyEventResult.handled;
  }
}

final class _SearchResults extends StatelessWidget {
  const _SearchResults({
    required this.controller,
    required this.sections,
    required this.submittedQuery,
    required this.isLoading,
    required this.isSearching,
    required this.errorMessage,
    required this.onFirstRowUp,
    required this.onItemPressed,
  });

  final ScrollController controller;
  final List<_SearchSection> sections;
  final String? submittedQuery;
  final bool isLoading;
  final bool isSearching;
  final String? errorMessage;
  final Future<void> Function() onFirstRowUp;
  final ValueChanged<HomeItem> onItemPressed;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: controller,
      padding: EdgeInsets.zero,
      itemCount: _itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: 18),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Text(
            submittedQuery == null
                ? 'Recommended for you'
                : 'Search results for "$submittedQuery"',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: StreamTvColors.onSurface,
              fontWeight: FontWeight.w500,
            ),
          );
        }
        if (isLoading || isSearching || errorMessage != null) {
          return Text(
            isSearching
                ? 'Searching...'
                : isLoading
                ? 'Loading recommendations...'
                : errorMessage ?? 'Search is temporarily unavailable',
            style: const TextStyle(
              color: StreamTvColors.onSurfaceMuted,
              fontSize: 16,
            ),
          );
        }

        final section = sections[index - 1];
        return Focus(
          canRequestFocus: false,
          onKeyEvent: (node, event) {
            if (index == 1 &&
                (event is KeyDownEvent || event is KeyRepeatEvent) &&
                event.logicalKey == LogicalKeyboardKey.arrowUp) {
              unawaited(onFirstRowUp());
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: _SearchSectionRow(
            section: section,
            onItemPressed: onItemPressed,
          ),
        );
      },
    );
  }

  int get _itemCount {
    if (isLoading || isSearching || errorMessage != null) {
      return 2;
    }
    return sections.length + 1;
  }
}

final class _SearchSectionRow extends StatelessWidget {
  const _SearchSectionRow({required this.section, required this.onItemPressed});

  final _SearchSection section;
  final ValueChanged<HomeItem> onItemPressed;

  @override
  Widget build(BuildContext context) {
    final itemWidth = switch (section.style) {
      HomeContentCardStyle.short => 112.0,
      _ => 190.0,
    };
    final metrics = HomeContentCardMetrics.fromItemWidth(
      style: section.style,
      itemWidth: itemWidth,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: StreamTvColors.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        ListContentView.separated(
          key: ValueKey('search-results-${section.id}'),
          itemCount: section.items.length,
          focusNode: section.focusNode,
          itemWidth: metrics.itemWidth,
          itemHeight: metrics.itemHeight,
          selectionWidth: metrics.cardWidth,
          selectionHeight: metrics.thumbnailHeight,
          contentPadding: EdgeInsets.zero,
          separatorExtent: 16,
          separatorBuilder: (_, _) => const SizedBox.shrink(),
          loopingEnabled: section.items.length > 5,
          semanticLabelBuilder: (index) => section.items[index].title,
          onSelectedItemPressed: (index) => onItemPressed(section.items[index]),
          itemBuilder: (context, index, isSelected) {
            return HomeContentCard(
              item: section.items[index],
              style: section.style,
              metrics: metrics,
              isSelected: isSelected,
            );
          },
        ),
      ],
    );
  }
}

final class _SearchSection {
  const _SearchSection({
    required this.id,
    required this.title,
    required this.style,
    required this.items,
    required this.focusNode,
  });

  final String id;
  final String title;
  final HomeContentCardStyle style;
  final List<HomeItem> items;
  final FocusNode focusNode;
}
