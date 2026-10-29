import 'local_activity.dart';
import 'outbox_entry.dart';
import 'outbox_worker.dart';

/// Routes each [OutboxKind] to the transport that knows its endpoint.
///
/// The outbox is one queue by design — coalescing, backoff and the `4xx`
/// discard rule are the same whatever the write is about — but the endpoints
/// belong to different features, and `core/` may not import either. So the
/// worker keeps talking to one [OutboxTransport] and this dispatches behind it.
///
/// A kind with no entry is **not** silently dropped: it throws, which surfaces
/// as a retry and then a discard rather than as a queued write that quietly
/// never sends. Registering every kind is the caller's job, and the exhaustive
/// switches in the feature transports are what make omitting one an analyzer
/// error upstream.
class CompositeOutboxTransport implements OutboxTransport {
  const CompositeOutboxTransport(this._routes);

  final Map<OutboxKind, OutboxTransport> _routes;

  @override
  Future<LocalActivity?> send(OutboxEntry entry) {
    final OutboxTransport? transport = _routes[entry.kind];
    if (transport == null) {
      throw StateError('No outbox transport registered for ${entry.kind}');
    }
    return transport.send(entry);
  }
}
