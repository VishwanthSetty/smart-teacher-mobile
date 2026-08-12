import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/student_entity.dart';

/// What the roster is currently asking `GET /students` for, minus the page
/// number (PRD §5.5.2).
///
/// Held apart from the paged rows on purpose: the filters survive a failed
/// fetch, an empty result and a full reload, and changing any of them means
/// "start again from page one" rather than "append". Keeping them in their own
/// notifier makes that the only possible reading — `RosterController.build`
/// watches this, so a new query rebuilds the list from scratch by construction
/// rather than by remembering to reset a counter.
///
/// Value equality matters: it is what stops a keystroke that leaves the query
/// unchanged (trailing whitespace, say) from re-issuing the request.
@immutable
class RosterQuery {
  const RosterQuery({
    this.search = '',
    this.sectionId,
    this.status,
  });

  /// Raw, as typed. [term] is what actually goes on the wire.
  final String search;

  /// The opaque `sectionId` from `GET /sections` (§5.5.3) — `null` is "all
  /// sections", the default. The app never parses this value.
  final String? sectionId;

  /// Supported by the endpoint and modelled end to end, but **not exposed on
  /// the screen**: §5.5.2 asks for search and a section filter, and a status
  /// filter a teacher can't act on (every write route is SCHOOL_ADMIN-only)
  /// would be three more taps for a distinction the row badge already makes.
  /// It is here so adding the control is a widget, not a data-layer change.
  final StudentStatus? status;

  /// The search term as sent, or `null` when there is nothing to search for.
  String? get term {
    final String trimmed = search.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  /// Whether anything is narrowing the list — the difference between "this
  /// school has no students" and "nothing matched", which the empty state has
  /// to tell apart (§6.4).
  bool get isFiltered => term != null || sectionId != null || status != null;

  RosterQuery withSearch(String value) => RosterQuery(
        search: value,
        sectionId: sectionId,
        status: status,
      );

  /// `null` clears the filter — hence a method per field rather than a
  /// `copyWith`, which cannot express "set this back to null".
  RosterQuery withSection(String? value) => RosterQuery(
        search: search,
        sectionId: value,
        status: status,
      );

  RosterQuery withStatus(StudentStatus? value) => RosterQuery(
        search: search,
        sectionId: sectionId,
        status: value,
      );

  @override
  bool operator ==(Object other) {
    // On the *trimmed* term, not the raw text: typing a trailing space must not
    // cost a request for a query the server would answer identically.
    return other is RosterQuery &&
        other.term == term &&
        other.sectionId == sectionId &&
        other.status == status;
  }

  @override
  int get hashCode => Object.hash(term, sectionId, status);

  @override
  String toString() =>
      'RosterQuery(search: $term, sectionId: $sectionId, status: $status)';
}

/// The roster's filter state.
///
/// Not auto-disposing, and separate from the list controller, so switching to
/// another tab and back leaves the teacher's search and section exactly as they
/// left them — the roster lives in the shell's `IndexedStack` (§5.7), and a
/// filter that silently resets itself reads as a bug.
class RosterQueryController extends Notifier<RosterQuery> {
  @override
  RosterQuery build() => const RosterQuery();

  /// Debouncing belongs to the text field, not here: this notifier is the
  /// committed query, and every change to it is meant to hit the network.
  void setSearch(String value) => state = state.withSearch(value);

  void setSection(String? sectionId) => state = state.withSection(sectionId);

  void setStatus(StudentStatus? status) => state = state.withStatus(status);

  void clear() => state = const RosterQuery();
}

final NotifierProvider<RosterQueryController, RosterQuery> rosterQueryProvider =
    NotifierProvider<RosterQueryController, RosterQuery>(
  RosterQueryController.new,
);
