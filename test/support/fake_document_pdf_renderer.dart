import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:smart_teacher_mobile/src/features/library/presentation/document_pdf_renderer.dart';

class FakeDocumentPdfRenderer implements DocumentPdfRenderer {
  FakeDocumentPdfRenderer({
    this.pageCount = 12,
    this.currentPage = 1,
    this.failedLoads = 0,
  });

  final int pageCount;
  final int currentPage;
  int failedLoads;
  final List<Uri> uris = <Uri>[];

  @override
  Widget build({
    required Uri uri,
    required PdfViewerController controller,
    required DocumentPdfReady onReady,
    required DocumentPdfLoadFailed onLoadFailed,
    required VoidCallback onRetry,
  }) {
    uris.add(uri);
    final bool shouldFail = failedLoads > 0;
    if (shouldFail) {
      failedLoads--;
    }
    return _FakePdfSurface(
      key: ValueKey<String>(uri.toString()),
      pageCount: pageCount,
      currentPage: currentPage,
      shouldFail: shouldFail,
      onReady: onReady,
      onLoadFailed: onLoadFailed,
    );
  }
}

class _FakePdfSurface extends StatefulWidget {
  const _FakePdfSurface({
    required this.pageCount,
    required this.currentPage,
    required this.shouldFail,
    required this.onReady,
    required this.onLoadFailed,
    super.key,
  });

  final int pageCount;
  final int currentPage;
  final bool shouldFail;
  final DocumentPdfReady onReady;
  final DocumentPdfLoadFailed onLoadFailed;

  @override
  State<_FakePdfSurface> createState() => _FakePdfSurfaceState();
}

class _FakePdfSurfaceState extends State<_FakePdfSurface> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (!mounted) {
        return;
      }
      if (widget.shouldFail) {
        widget.onLoadFailed(StateError('Presigned URL expired'));
      } else {
        widget.onReady(widget.pageCount, widget.currentPage);
      }
    });
  }

  @override
  Widget build(BuildContext context) =>
      const ColoredBox(key: Key('fake-pdf-surface'), color: Colors.white);
}
