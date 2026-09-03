import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/features/library/data/document_download_repository.dart';
import 'package:smart_teacher_mobile/src/features/library/domain/document_download_entity.dart';
import 'package:smart_teacher_mobile/src/features/library/presentation/document_download_controller.dart';

import '../../support/fake_document_download_repository.dart';

void main() {
  test('keeps a still-valid presigned URL', () async {
    DateTime now = DateTime.utc(2026, 8, 15, 10);
    final FakeDocumentDownloadRepository repository =
        FakeDocumentDownloadRepository();
    final ProviderContainer container = ProviderContainer(
      overrides: [
        documentDownloadRepositoryProvider.overrideWithValue(repository),
        documentClockProvider.overrideWithValue(() => now),
      ],
    );
    addTearDown(container.dispose);
    final ProviderSubscription<AsyncValue<DocumentDownloadGrant>> subscription =
        container.listen<AsyncValue<DocumentDownloadGrant>>(
          documentDownloadControllerProvider('document-1'),
          (
            AsyncValue<DocumentDownloadGrant>? previous,
            AsyncValue<DocumentDownloadGrant> next,
          ) {},
        );
    addTearDown(subscription.close);

    await container.read(
      documentDownloadControllerProvider('document-1').future,
    );
    now = now.add(const Duration(seconds: 294));
    await container
        .read(documentDownloadControllerProvider('document-1').notifier)
        .refreshIfStale();

    expect(repository.callCount, 1);
  });

  test('re-requests instead of reusing a stale presigned URL', () async {
    DateTime now = DateTime.utc(2026, 8, 15, 10);
    final FakeDocumentDownloadRepository
    repository = FakeDocumentDownloadRepository(
      downloads: <DocumentDownloadEntity>[
        buildDownload(url: 'https://s3.example.test/file.pdf?signature=first'),
        buildDownload(url: 'https://s3.example.test/file.pdf?signature=second'),
      ],
    );
    final ProviderContainer container = ProviderContainer(
      overrides: [
        documentDownloadRepositoryProvider.overrideWithValue(repository),
        documentClockProvider.overrideWithValue(() => now),
      ],
    );
    addTearDown(container.dispose);
    final ProviderSubscription<AsyncValue<DocumentDownloadGrant>> subscription =
        container.listen<AsyncValue<DocumentDownloadGrant>>(
          documentDownloadControllerProvider('document-1'),
          (
            AsyncValue<DocumentDownloadGrant>? previous,
            AsyncValue<DocumentDownloadGrant> next,
          ) {},
        );
    addTearDown(subscription.close);

    await container.read(
      documentDownloadControllerProvider('document-1').future,
    );
    now = now.add(const Duration(seconds: 295));
    await container
        .read(documentDownloadControllerProvider('document-1').notifier)
        .refreshIfStale();

    expect(repository.callCount, 2);
    expect(
      container
          .read(documentDownloadControllerProvider('document-1'))
          .requireValue
          .download
          .url,
      contains('signature=second'),
    );
  });
}
