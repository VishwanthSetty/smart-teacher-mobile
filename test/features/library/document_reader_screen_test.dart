import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_teacher_mobile/src/core/errors/app_error.dart';
import 'package:smart_teacher_mobile/src/features/library/data/document_download_repository.dart';
import 'package:smart_teacher_mobile/src/features/library/domain/document_download_entity.dart';
import 'package:smart_teacher_mobile/src/features/library/presentation/document_download_controller.dart';
import 'package:smart_teacher_mobile/src/features/library/presentation/document_pdf_renderer.dart';
import 'package:smart_teacher_mobile/src/features/library/presentation/document_reader_screen.dart';

import '../../support/fake_document_download_repository.dart';
import '../../support/fake_document_pdf_renderer.dart';

void main() {
  testWidgets('a download-mint 404 uses non-leaking unavailable copy', (
    WidgetTester tester,
  ) async {
    final FakeDocumentDownloadRepository downloads =
        FakeDocumentDownloadRepository(
          error: const NotFoundError(message: 'Not found'),
        );

    await _pumpReader(
      tester,
      downloads: downloads,
      renderer: FakeDocumentPdfRenderer(),
    );

    expect(find.text('This content is no longer available.'), findsOneWidget);
    expect(find.textContaining('permission'), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Try again'), findsNothing);
  });

  testWidgets('renders the whole-file URL without page-jump controls', (
    WidgetTester tester,
  ) async {
    final FakeDocumentDownloadRepository downloads =
        FakeDocumentDownloadRepository();
    final FakeDocumentPdfRenderer renderer = FakeDocumentPdfRenderer(
      pageCount: 12,
      currentPage: 2,
    );

    await _pumpReader(tester, downloads: downloads, renderer: renderer);

    expect(downloads.requestedDocumentIds, <String>['document-1']);
    expect(
      renderer.uris.map((Uri uri) => uri.toString()),
      everyElement(downloads.downloads.single.url),
    );
    expect(find.byKey(const Key('fake-pdf-surface')), findsOneWidget);
    expect(find.textContaining('Page 2 of 12'), findsNothing);
    expect(find.text('Jump to page'), findsNothing);
    expect(find.byIcon(Icons.find_in_page_outlined), findsNothing);

    expect(find.byIcon(Icons.share_outlined), findsNothing);
    expect(find.byIcon(Icons.download_outlined), findsNothing);
    expect(find.textContaining('Save PDF'), findsNothing);
  });

  testWidgets('a PDF fetch failure requests one fresh presigned URL', (
    WidgetTester tester,
  ) async {
    final FakeDocumentDownloadRepository downloads =
        FakeDocumentDownloadRepository(
          downloads: <DocumentDownloadEntity>[
            buildDownload(
              url: 'https://s3.example.test/file.pdf?signature=expired',
            ),
            buildDownload(
              url: 'https://s3.example.test/file.pdf?signature=fresh',
            ),
          ],
        );
    final FakeDocumentPdfRenderer renderer = FakeDocumentPdfRenderer(
      failedLoads: 1,
    );

    await _pumpReader(tester, downloads: downloads, renderer: renderer);

    expect(downloads.callCount, 2);
    expect(renderer.uris.last.queryParameters['signature'], 'fresh');
    expect(find.byKey(const Key('fake-pdf-surface')), findsOneWidget);
  });

  testWidgets('returning to a stale reader requests a fresh URL', (
    WidgetTester tester,
  ) async {
    DateTime now = DateTime.utc(2026, 8, 15, 10);
    final FakeDocumentDownloadRepository
    downloads = FakeDocumentDownloadRepository(
      downloads: <DocumentDownloadEntity>[
        buildDownload(url: 'https://s3.example.test/file.pdf?signature=first'),
        buildDownload(url: 'https://s3.example.test/file.pdf?signature=second'),
      ],
    );
    final FakeDocumentPdfRenderer renderer = FakeDocumentPdfRenderer();
    await _pumpReader(
      tester,
      downloads: downloads,
      renderer: renderer,
      clock: () => now,
    );

    now = now.add(const Duration(seconds: 295));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(downloads.callCount, 2);
    expect(renderer.uris.last.queryParameters['signature'], 'second');
  });
}

Future<void> _pumpReader(
  WidgetTester tester, {
  required FakeDocumentDownloadRepository downloads,
  required FakeDocumentPdfRenderer renderer,
  DocumentClock? clock,
}) async {
  final GoRouter router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) =>
            const DocumentReaderScreen(
              documentId: 'document-1',
              title: 'Worksheet',
            ),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        documentDownloadRepositoryProvider.overrideWithValue(downloads),
        documentPdfRendererProvider.overrideWithValue(renderer),
        if (clock != null) documentClockProvider.overrideWithValue(clock),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}
