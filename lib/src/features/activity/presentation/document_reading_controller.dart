import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

import '../../../core/sync/local_activity.dart';
import 'activity_sync_controller.dart';

/// How long the page must sit still before it is reported (mobile plan §4).
///
/// Reporting on every swipe would queue a write per page of a flick through a
/// thirty-page PDF, all but the last of which is immediately superseded. The
/// outbox would coalesce them, but the cheapest write is the one never made.
const Duration documentPageSettleDelay = Duration(milliseconds: 1500);

/// What the reader needs to know about its own document.
@immutable
class DocumentReadingState {
  const DocumentReadingState({
    this.lastPage,
    this.pageCount,
    this.isComplete = false,
  });

  /// Where to reopen at.
  ///
  /// Restored **directly, with no chooser** — unlike a video position. A page
  /// is cheap to correct with one swipe; a video position is not (mobile
  /// plan §4).
  final int? lastPage;

  /// `null` until `Document.pageCount` is populated at ingest. The reader shows
  /// a bare "page 7" rather than guessing a denominator.
  final int? pageCount;

  /// Learner-asserted completion, and **the only way a document is complete**.
  /// Reaching the last page does not set this, and the UI must never imply it
  /// does.
  final bool isComplete;

  @override
  bool operator ==(Object other) =>
      other is DocumentReadingState &&
      other.lastPage == lastPage &&
      other.pageCount == pageCount &&
      other.isComplete == isComplete;

  @override
  int get hashCode => Object.hash(lastPage, pageCount, isComplete);
}

/// Backs the reader's position reporting and its **Mark as read** control.
///
/// Reads the local cache rather than the network on open: the cache is written
/// optimistically on every page settle, so it is both faster and more current
/// than a fetch would be. Anything the server knows that the cache does not
/// arrives via the outbox worker writing the flush response back.
class DocumentReadingController
    extends AsyncNotifier<DocumentReadingState> {
  DocumentReadingController(this.documentId);

  final String documentId;

  /// Captured in [build] rather than read on demand.
  ///
  /// The dispose callback below needs it, and Riverpod forbids touching `ref`
  /// inside a lifecycle callback — by then the element is already tearing
  /// down. Holding the reference is what lets the final page settle survive
  /// the reader closing.
  late final ActivitySyncController _sync;

  Timer? _settleTimer;
  int? _pendingPage;
  int? _pendingPageCount;

  @override
  Future<DocumentReadingState> build() async {
    _sync = ref.read(activitySyncControllerProvider);

    ref.onDispose(() {
      // A page settling right as the reader closes must not be lost to the
      // debounce window, so the timer is flushed rather than simply cancelled.
      _settleTimer?.cancel();
      final int? page = _pendingPage;
      if (page != null) {
        unawaited(_send(page, _pendingPageCount));
      }
    });

    final LocalActivity? cached = await _sync.cachedActivity(documentId);

    return DocumentReadingState(
      lastPage: cached?.lastPage,
      pageCount: cached?.pageCount,
      isComplete: cached?.status == 'COMPLETED',
    );
  }

  /// Called on every page change. Only the last one within
  /// [documentPageSettleDelay] is reported.
  void onPageChanged(int page, {int? pageCount}) {
    if (page < 1) {
      return;
    }
    _pendingPage = page;
    _pendingPageCount = pageCount ?? _pendingPageCount;

    // The visible page number updates immediately; only the *write* is
    // debounced. A reader whose page label lagged 1.5s behind the swipe would
    // feel broken.
    final DocumentReadingState? current = state.value;
    if (current != null) {
      state = AsyncData<DocumentReadingState>(
        DocumentReadingState(
          lastPage: page,
          pageCount: pageCount ?? current.pageCount,
          isComplete: current.isComplete,
        ),
      );
    }

    _settleTimer?.cancel();
    _settleTimer = Timer(documentPageSettleDelay, () {
      final int? settled = _pendingPage;
      if (settled != null) {
        unawaited(_send(settled, _pendingPageCount));
      }
    });
  }

  /// The explicit **Mark as read** toggle, and its undo.
  ///
  /// Optimistic: the control flips at once and the write goes through the
  /// outbox. Unlike a video's completion — which the server derives from
  /// coverage against its own threshold — this one is the learner's assertion,
  /// so the client is entitled to show it before the round trip.
  Future<void> setComplete({required bool isComplete}) async {
    final DocumentReadingState current =
        state.value ?? const DocumentReadingState();
    state = AsyncData<DocumentReadingState>(
      DocumentReadingState(
        lastPage: current.lastPage,
        pageCount: current.pageCount,
        isComplete: isComplete,
      ),
    );

    await _sync.setDocumentComplete(
      documentId: documentId,
      isComplete: isComplete,
    );
  }

  Future<void> _send(int page, int? pageCount) async {
    _pendingPage = null;
    _pendingPageCount = null;
    await _sync.recordDocumentPage(
      documentId: documentId,
      lastPage: page,
      pageCount: pageCount,
    );
  }
}

final AsyncNotifierProviderFamily<
  DocumentReadingController,
  DocumentReadingState,
  String
>
documentReadingControllerProvider = AsyncNotifierProvider.autoDispose
    .family<DocumentReadingController, DocumentReadingState, String>(
      DocumentReadingController.new,
      retry: (int retryCount, Object error) => null,
    );
