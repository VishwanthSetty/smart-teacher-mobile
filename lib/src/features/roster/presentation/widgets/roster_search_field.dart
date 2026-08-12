import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../roster_query.dart';

/// The roster's search input (PRD §5.5.2) — the `search=` half of
/// `GET /students`.
///
/// **Debouncing lives here**, and only here. `RosterQueryController` holds the
/// *committed* query and every change to it is meant to reach the network;
/// putting the delay in the notifier would make that untrue and would make the
/// controller's tests wait on a timer. So this field keeps the keystrokes local
/// and commits once the typing stops.
///
/// The text is owned by this widget rather than read back from the provider on
/// every build: a rebuild landing mid-word must not move the caret. The
/// provider is listened to only for the case something *else* clears the query
/// — the "Clear filters" action on the empty state — which has to be reflected
/// in the box.
class RosterSearchField extends ConsumerStatefulWidget {
  const RosterSearchField({super.key});

  /// Long enough that an average typist commits once per word rather than once
  /// per letter, short enough that it doesn't feel like a submit button.
  static const Duration debounce = Duration(milliseconds: 350);

  @override
  ConsumerState<RosterSearchField> createState() => _RosterSearchFieldState();
}

class _RosterSearchFieldState extends ConsumerState<RosterSearchField> {
  late final TextEditingController _controller = TextEditingController(
    text: ref.read(rosterQueryProvider).search,
  );
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      RosterSearchField.debounce,
      () => ref.read(rosterQueryProvider.notifier).setSearch(value),
    );
  }

  void _clear() {
    _debounce?.cancel();
    _controller.clear();
    ref.read(rosterQueryProvider.notifier).setSearch('');
  }

  @override
  Widget build(BuildContext context) {
    // Keeps the box honest when the query is cleared from somewhere else.
    ref.listen<RosterQuery>(rosterQueryProvider, (
      RosterQuery? previous,
      RosterQuery next,
    ) {
      if (next.search != _controller.text) {
        _controller.text = next.search;
      }
    });

    // Rebuilt from the controller so the clear button appears with the first
    // keystroke rather than with the debounced commit.
    return ListenableBuilder(
      listenable: _controller,
      builder: (BuildContext context, Widget? _) => TextField(
        controller: _controller,
        onChanged: _onChanged,
        textInputAction: TextInputAction.search,
        // Committing on submit as well as on the timer: a user who types and
        // immediately hits search shouldn't wait out the debounce.
        onSubmitted: (String value) {
          _debounce?.cancel();
          ref.read(rosterQueryProvider.notifier).setSearch(value);
        },
        decoration: InputDecoration(
          hintText: 'Search by name or email',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _controller.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: 'Clear search',
                  onPressed: _clear,
                ),
          isDense: true,
        ),
      ),
    );
  }
}
