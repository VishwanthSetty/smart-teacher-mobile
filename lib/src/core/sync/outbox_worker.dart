import '../errors/app_error.dart';
import 'local_activity.dart';
import 'outbox_entry.dart';
import 'outbox_store.dart';

/// Sends one queued write. Implemented in the activity feature over the
/// progress repository — `core/` must not import a feature, so the worker
/// depends on this narrow port instead of on the endpoints themselves.
abstract interface class OutboxTransport {
  /// Throws an [AppError] on failure, never a `DioException`.
  ///
  /// Returns the server's authoritative view of the resource when the endpoint
  /// answers with one, so the worker can overwrite the optimistic cache
  /// (mobile plan §2.3). `null` means the call succeeded but said nothing
  /// worth caching.
  Future<LocalActivity?> send(OutboxEntry entry);
}

/// Receives the server's answer so the local cache can be reconciled.
abstract interface class OutboxSyncSink {
  Future<void> onSynced(LocalActivity activity);
}

/// Why a flush stopped, for the caller and for tests.
enum OutboxFlushOutcome {
  /// Nothing was due.
  idle,

  /// Every due entry was accepted or discarded; the queue is drained.
  drained,

  /// At least one entry is waiting on backoff.
  deferred,

  /// The session is gone. Flushing stopped immediately; entries are kept,
  /// since the sign-out path clears the queue wholesale.
  unauthenticated,
}

class OutboxFlushReport {
  const OutboxFlushReport({
    required this.outcome,
    this.sent = 0,
    this.discarded = 0,
    this.deferred = 0,
  });

  final OutboxFlushOutcome outcome;
  final int sent;
  final int discarded;
  final int deferred;

  @override
  String toString() =>
      'OutboxFlushReport($outcome, sent: $sent, '
      'discarded: $discarded, deferred: $deferred)';
}

/// First backoff step. Doubles per attempt up to [maximumOutboxBackoff].
const Duration baseOutboxBackoff = Duration(seconds: 2);
const Duration maximumOutboxBackoff = Duration(minutes: 5);

/// After this many failures an entry is dropped rather than retried forever.
///
/// A retryable failure that has survived eight escalating attempts is not a
/// blip; keeping it would wedge the head of a FIFO queue behind one poisoned
/// payload, which is worse than losing the beat it carries.
const int maximumOutboxAttempts = 8;

/// Drains the outbox (mobile plan §2.2).
///
/// Deliberately has no timer of its own: *when* to flush is a lifecycle
/// question (foreground, connectivity, player pause, dispose), and mixing that
/// into the same object makes the send rules untestable without pumping real
/// time. [SyncScheduler] owns the triggers; this owns the rules.
class OutboxWorker {
  OutboxWorker({
    required OutboxStore store,
    required OutboxTransport transport,
    OutboxSyncSink? sink,
    DateTime Function() clock = DateTime.now,
  }) : _store = store,
       _transport = transport,
       _sink = sink,
       _clock = clock;

  final OutboxStore _store;
  final OutboxTransport _transport;
  final OutboxSyncSink? _sink;
  final DateTime Function() _clock;

  bool _flushing = false;

  /// Sends every due entry, oldest first.
  ///
  /// Re-entrant calls are collapsed rather than queued: a flush already in
  /// flight will pick up anything enqueued behind it, and two concurrent
  /// drains would send the same entry twice.
  Future<OutboxFlushReport> flush() async {
    if (_flushing) {
      return const OutboxFlushReport(outcome: OutboxFlushOutcome.idle);
    }
    _flushing = true;

    try {
      final List<OutboxEntry> due = await _store.dueEntries(_clock());
      if (due.isEmpty) {
        return const OutboxFlushReport(outcome: OutboxFlushOutcome.idle);
      }

      int sent = 0;
      int discarded = 0;
      int deferred = 0;

      for (final OutboxEntry entry in due) {
        final _SendResult result = await _send(entry);
        switch (result) {
          case _SendResult.sent:
            sent++;
          case _SendResult.discarded:
            discarded++;
          case _SendResult.deferred:
            deferred++;
          case _SendResult.unauthenticated:
            return OutboxFlushReport(
              outcome: OutboxFlushOutcome.unauthenticated,
              sent: sent,
              discarded: discarded,
              deferred: deferred,
            );
        }
      }

      return OutboxFlushReport(
        outcome: deferred > 0
            ? OutboxFlushOutcome.deferred
            : OutboxFlushOutcome.drained,
        sent: sent,
        discarded: discarded,
        deferred: deferred,
      );
    } finally {
      _flushing = false;
    }
  }

  Future<_SendResult> _send(OutboxEntry entry) async {
    try {
      final LocalActivity? synced = await _transport.send(entry);
      await _store.remove(entry.id);
      if (synced != null) {
        await _sink?.onSynced(synced);
      }
      return _SendResult.sent;
    } on AppError catch (error) {
      return _handleFailure(entry, error);
    }
  }

  /// The discard-vs-retry split (mobile plan §2.2).
  ///
  /// A `4xx` that is not `408`/`429` is **discarded, not retried**: a `404`
  /// means the resource left this user's scope, and a `400` means the payload
  /// is one the server will never accept. Replaying either forever wedges the
  /// queue behind an entry that can only fail.
  Future<_SendResult> _handleFailure(OutboxEntry entry, AppError error) async {
    final bool retryable = switch (error) {
      // The interceptor has already tried its one silent refresh by the time
      // this surfaces, so the session really is gone. Stop the drain; the
      // sign-out path clears the queue.
      UnauthorizedError() => false,
      // Throttled, not rejected — and the server may have told us how long.
      RateLimitedError() => true,
      NetworkError() => true,
      // 5xx and anything unmapped.
      UnknownError() => true,
      ForbiddenError() => false,
      NotFoundError() => false,
      ValidationError() => false,
    };

    if (error is UnauthorizedError) {
      return _SendResult.unauthenticated;
    }

    if (!retryable || entry.attempts + 1 >= maximumOutboxAttempts) {
      await _store.remove(entry.id);
      return _SendResult.discarded;
    }

    await _store.reschedule(entry, _clock().add(_backoffFor(entry, error)));
    return _SendResult.deferred;
  }

  Duration _backoffFor(OutboxEntry entry, AppError error) {
    // The server's own `Retry-After` beats our guess whenever it sends one.
    if (error case RateLimitedError(retryAfter: final Duration wait)) {
      return wait > maximumOutboxBackoff ? maximumOutboxBackoff : wait;
    }
    final int multiplier = 1 << entry.attempts.clamp(0, 20);
    final int milliseconds =
        baseOutboxBackoff.inMilliseconds * multiplier;
    return milliseconds >= maximumOutboxBackoff.inMilliseconds
        ? maximumOutboxBackoff
        : Duration(milliseconds: milliseconds);
  }
}

enum _SendResult { sent, discarded, deferred, unauthenticated }
