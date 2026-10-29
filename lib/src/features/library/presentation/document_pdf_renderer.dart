import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';

typedef DocumentPdfReady = void Function(int pageCount, int currentPage);
typedef DocumentPdfLoadFailed = void Function(Object error);

/// Fired when the visible page changes, including once on open.
typedef DocumentPdfPageChanged = void Function(int pageNumber);

/// Keeps native PDFium/network work replaceable in widget tests.
abstract interface class DocumentPdfRenderer {
  Widget build({
    required Uri uri,
    required PdfViewerController controller,
    required DocumentPdfReady onReady,
    required DocumentPdfLoadFailed onLoadFailed,
    required VoidCallback onRetry,
    DocumentPdfPageChanged? onPageChanged,

    /// Where to reopen — the `lastPage` from the activity cache.
    ///
    /// Restored silently, with no chooser: a page is one swipe to correct,
    /// which is why documents get the simple treatment and video positions do
    /// not (mobile plan §4).
    int? initialPage,
  });
}

class PdfrxDocumentPdfRenderer implements DocumentPdfRenderer {
  const PdfrxDocumentPdfRenderer();

  @override
  Widget build({
    required Uri uri,
    required PdfViewerController controller,
    required DocumentPdfReady onReady,
    required DocumentPdfLoadFailed onLoadFailed,
    required VoidCallback onRetry,
    DocumentPdfPageChanged? onPageChanged,
    int? initialPage,
  }) {
    return PdfViewer.uri(
      uri,
      key: ValueKey<String>(uri.toString()),
      controller: controller,
      // The endpoint returns a URL to the whole PDF. The cancelled range/file
      // endpoints are intentionally not part of this client.
      preferRangeAccess: false,
      params: PdfViewerParams(
        textSelectionParams: const PdfTextSelectionParams(enabled: true),
        onViewerReady: (PdfDocument document, PdfViewerController viewer) {
          final int pageCount = document.pages.length;
          // Clamped, because `lastPage` is a snapshot: a document re-uploaded
          // shorter would otherwise seek past its own end.
          final int? resume = initialPage?.clamp(
            1,
            pageCount < 1 ? 1 : pageCount,
          );
          if (resume != null && resume > 1 && resume != viewer.pageNumber) {
            viewer.goToPage(pageNumber: resume);
          }
          onReady(pageCount, resume ?? viewer.pageNumber ?? 1);
        },
        onPageChanged: onPageChanged == null
            ? null
            : (int? pageNumber) {
                if (pageNumber != null) {
                  onPageChanged(pageNumber);
                }
              },
        onDocumentLoadFinished:
            (PdfDocumentRef documentRef, bool loadSucceeded) {
              if (!loadSucceeded) {
                final PdfDocumentListenable listenable = documentRef
                    .resolveListenable();
                onLoadFailed(
                  listenable.error ??
                      StateError('The PDF could not be loaded.'),
                );
              }
            },
        errorBannerBuilder:
            (
              BuildContext context,
              Object error,
              StackTrace? stackTrace,
              PdfDocumentRef documentRef,
            ) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(Icons.picture_as_pdf_outlined, size: 48),
                    const SizedBox(height: 12),
                    const Text(
                      'The PDF could not be loaded.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: onRetry,
                      child: const Text('Request a new link'),
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }
}

final Provider<DocumentPdfRenderer> documentPdfRendererProvider =
    Provider<DocumentPdfRenderer>(
      (Ref ref) => const PdfrxDocumentPdfRenderer(),
    );
