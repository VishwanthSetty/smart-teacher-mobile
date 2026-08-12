import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

import '../../../core/errors/app_error.dart';
import '../../../core/session/school_suspension_controller.dart';
import '../data/content_detail_repository.dart';
import '../domain/content_detail_entity.dart';
import '../domain/content_node_entity.dart';

/// The value key for one video or document detail request.
typedef ContentItemDetailRequest = ({String itemId, ContentItemKind kind});

/// Loads the metadata behind a tree leaf while leaving playback and reading
/// out of scope (PRD §5.4.2–§5.4.3).
class ContentItemDetailController extends AsyncNotifier<ContentDetailEntity> {
  ContentItemDetailController(this.request);

  final ContentItemDetailRequest request;
  bool _refreshing = false;

  @override
  Future<ContentDetailEntity> build() => _fetch();

  /// Explicit retry for transient failures. A `404` never offers this action.
  Future<void> refresh() async {
    if (_refreshing) {
      return;
    }
    _refreshing = true;

    try {
      final AsyncValue<ContentDetailEntity> next = await AsyncValue.guard(
        _fetch,
      );
      if (ref.mounted) {
        state = next;
      }
    } finally {
      _refreshing = false;
    }
  }

  Future<ContentDetailEntity> _fetch() async {
    try {
      final ContentDetailRepository repository = ref.read(
        contentDetailRepositoryProvider,
      );
      return switch (request.kind) {
        ContentItemKind.video => await repository.fetchVideo(request.itemId),
        ContentItemKind.document => await repository.fetchDocument(
          request.itemId,
        ),
      };
    } on ForbiddenError catch (error) {
      // These single-item endpoints use 404 for entitlement refusals. A
      // suspension-flavoured 403 therefore has no narrower entitlement cause.
      if (error.isSchoolSuspended && ref.mounted) {
        ref.read(schoolSuspensionProvider.notifier).confirm();
      }
      rethrow;
    }
  }
}

/// Auto-dispose keeps a sequence of opened items from pinning every response
/// for the rest of the session. Automatic retries are disabled so the error UI
/// remains the only source of retry requests.
final AsyncNotifierProviderFamily<
  ContentItemDetailController,
  ContentDetailEntity,
  ContentItemDetailRequest
>
contentItemDetailControllerProvider = AsyncNotifierProvider.autoDispose
    .family<
      ContentItemDetailController,
      ContentDetailEntity,
      ContentItemDetailRequest
    >(
      ContentItemDetailController.new,
      retry: (int retryCount, Object error) => null,
    );
