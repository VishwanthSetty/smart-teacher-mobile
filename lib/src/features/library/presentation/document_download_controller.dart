import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

import '../../../core/errors/app_error.dart';
import '../../../core/session/school_suspension_controller.dart';
import '../data/document_download_repository.dart';
import '../domain/document_download_entity.dart';

const Duration documentDownloadExpirySkew = Duration(seconds: 5);

typedef DocumentClock = DateTime Function();

final Provider<DocumentClock> documentClockProvider = Provider<DocumentClock>(
  (Ref ref) => DateTime.now,
);

/// One presigned URL plus the client time at which the API returned it.
final class DocumentDownloadGrant {
  const DocumentDownloadGrant({
    required this.download,
    required this.receivedAt,
  });

  final DocumentDownloadEntity download;
  final DateTime receivedAt;

  DateTime get expiresAt =>
      receivedAt.add(Duration(seconds: download.expiresInSecs));

  bool isStaleAt(DateTime now) {
    final DateTime refreshAt = expiresAt.subtract(documentDownloadExpirySkew);
    return !now.isBefore(refreshAt);
  }
}

/// Owns the short-lived URL, not the PDF bytes. A stale or failed URL is
/// replaced by calling the API again; the expired S3 URL is never retried.
class DocumentDownloadController extends AsyncNotifier<DocumentDownloadGrant> {
  DocumentDownloadController(this.documentId);

  final String documentId;
  bool _refreshing = false;

  @override
  Future<DocumentDownloadGrant> build() => _fetch();

  Future<void> refresh() async {
    if (_refreshing) {
      return;
    }
    _refreshing = true;
    state = const AsyncLoading<DocumentDownloadGrant>();

    try {
      final AsyncValue<DocumentDownloadGrant> next = await AsyncValue.guard(
        _fetch,
      );
      if (ref.mounted) {
        state = next;
      }
    } finally {
      _refreshing = false;
    }
  }

  Future<void> refreshIfStale() async {
    final DocumentDownloadGrant? current = state.value;
    final DateTime now = ref.read(documentClockProvider)();
    if (current == null || current.isStaleAt(now)) {
      await refresh();
    }
  }

  Future<DocumentDownloadGrant> _fetch() async {
    try {
      final DocumentDownloadEntity download = await ref
          .read(documentDownloadRepositoryProvider)
          .fetchDownload(documentId);
      return DocumentDownloadGrant(
        download: download,
        receivedAt: ref.read(documentClockProvider)(),
      );
    } on ForbiddenError catch (error) {
      if (error.isSchoolSuspended && ref.mounted) {
        ref.read(schoolSuspensionProvider.notifier).confirm();
      }
      rethrow;
    }
  }
}

final AsyncNotifierProviderFamily<
  DocumentDownloadController,
  DocumentDownloadGrant,
  String
>
documentDownloadControllerProvider = AsyncNotifierProvider.autoDispose
    .family<DocumentDownloadController, DocumentDownloadGrant, String>(
      DocumentDownloadController.new,
      retry: (int retryCount, Object error) => null,
    );
