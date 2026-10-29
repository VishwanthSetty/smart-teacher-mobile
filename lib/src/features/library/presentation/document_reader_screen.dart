import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../../core/errors/app_error.dart';
import '../../../core/session/school_suspension_controller.dart';
import '../../../core/widgets/error_retry_view.dart';
import '../../../core/widgets/not_found_view.dart';
import '../../../core/widgets/school_suspended_view.dart';
import '../../activity/domain/resource_activity_entity.dart';
import '../../activity/presentation/document_reading_controller.dart';
import '../../profile/presentation/profile_view.dart';
import '../../saved/presentation/widgets/bookmark_button.dart';
import 'document_download_controller.dart';
import 'document_pdf_renderer.dart';

/// Whole-file PDF reader backed by the existing presigned download endpoint.
///
/// There is deliberately no capture protection on this route. Text selection
/// remains enabled, while Save/Share/Open-in stays out of the toolbar until the
/// product team makes the explicit affordance decision called out in the PRD.
class DocumentReaderScreen extends ConsumerStatefulWidget {
  const DocumentReaderScreen({required this.documentId, this.title, super.key});

  final String documentId;
  final String? title;

  @override
  ConsumerState<DocumentReaderScreen> createState() =>
      _DocumentReaderScreenState();
}

class _DocumentReaderScreenState extends ConsumerState<DocumentReaderScreen>
    with WidgetsBindingObserver {
  final PdfViewerController _pdfController = PdfViewerController();

  int _automaticRefreshAttempts = 0;

  /// The document's real length, learned from the rendered file.
  ///
  /// Sent alongside the page so the server can store a snapshot even while
  /// `Document.pageCount` is unpopulated at ingest (backend plan §10.3) — it
  /// prefers its own value when it has one, so this can only fill a gap, never
  /// overwrite the authority.
  int? _pageCount;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(
        ref
            .read(
              documentDownloadControllerProvider(widget.documentId).notifier,
            )
            .refreshIfStale(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<DocumentDownloadGrant> grant = ref.watch(
      documentDownloadControllerProvider(widget.documentId),
    );
    final bool suspended = ref.watch(schoolSuspensionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_displayTitle(grant.value)),
        actions: <Widget>[
          if (!suspended) ...<Widget>[
            BookmarkButton(
              resourceId: widget.documentId,
              resourceType: ActivityResourceType.document,
              title: _displayTitle(grant.value),
            ),
            _MarkAsReadAction(documentId: widget.documentId),
          ],
        ],
      ),
      body: SafeArea(
        child: suspended
            ? SchoolSuspendedView(onSignOut: () => signOut(ref))
            : grant.when(
                data: _buildReader,
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (Object error, StackTrace _) =>
                    _buildDownloadError(context, error),
              ),
      ),
    );
  }

  String _displayTitle(DocumentDownloadGrant? grant) {
    final String handedOver = widget.title?.trim() ?? '';
    if (handedOver.isNotEmpty) {
      return handedOver;
    }
    final String fileName = grant?.download.fileName.trim() ?? '';
    return fileName.isEmpty ? 'Document' : fileName;
  }

  Widget _buildReader(DocumentDownloadGrant grant) {
    final Uri? uri = Uri.tryParse(grant.download.url);
    if (uri == null || !uri.hasScheme) {
      return ErrorRetryView(
        error: const UnknownError(message: 'The document link is invalid.'),
        onRetry: _requestFreshLink,
      );
    }

    final DocumentPdfRenderer renderer = ref.watch(documentPdfRendererProvider);
    // Read, not watch: this is where to *reopen*, captured once. Watching it
    // would rebuild the viewer — and so re-seek it — on every page report.
    final int? resumePage = ref
        .read(documentReadingControllerProvider(widget.documentId))
        .value
        ?.lastPage;

    return renderer.build(
      uri: uri,
      controller: _pdfController,
      onReady: _onPdfReady,
      onLoadFailed: _onPdfLoadFailed,
      onRetry: _requestFreshLink,
      onPageChanged: _onPageChanged,
      initialPage: resumePage,
    );
  }

  void _onPageChanged(int pageNumber) {
    ref
        .read(documentReadingControllerProvider(widget.documentId).notifier)
        .onPageChanged(pageNumber, pageCount: _pageCount);
  }

  Widget _buildDownloadError(BuildContext context, Object error) {
    final AppError appError = AppError.from(error);
    if (appError is NotFoundError) {
      return NotFoundView(
        message: 'This content is no longer available.',
        onBack: context.canPop() ? context.pop : null,
        backLabel: 'Back to curriculum',
      );
    }
    return ErrorRetryView(error: appError, onRetry: _requestFreshLink);
  }

  void _onPdfReady(int pageCount, int currentPage) {
    _automaticRefreshAttempts = 0;
    _pageCount = pageCount > 0 ? pageCount : null;
  }

  void _onPdfLoadFailed(Object error) {
    if (_automaticRefreshAttempts > 0) {
      return;
    }
    _automaticRefreshAttempts++;
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (mounted) {
        _requestFreshLink();
      }
    });
  }

  void _requestFreshLink() {
    if (!mounted) {
      return;
    }
    unawaited(
      ref
          .read(documentDownloadControllerProvider(widget.documentId).notifier)
          .refresh(),
    );
  }
}

/// **Mark as read** — the only way a document reaches `COMPLETED`
/// (mobile plan §4, backend plan §3.2).
///
/// Deliberately an explicit control and deliberately worded as an assertion.
/// Reaching the last page does not complete a document, because opening a PDF
/// is not reading it, and nothing in this UI may imply otherwise. Un-marking
/// lives on the same control, since students change their minds and the
/// teacher's report has to reflect reality.
class _MarkAsReadAction extends ConsumerWidget {
  const _MarkAsReadAction({required this.documentId});

  final String documentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<DocumentReadingState> reading = ref.watch(
      documentReadingControllerProvider(documentId),
    );
    // While the cache read is in flight there is no honest answer to "is this
    // marked?", and a control that flipped once it resolved would be worse
    // than one that appears a frame later.
    final DocumentReadingState? state = reading.value;
    if (state == null) {
      return const SizedBox.shrink();
    }

    return IconButton(
      tooltip: state.isComplete ? 'Mark as unread' : 'Mark as read',
      icon: Icon(
        state.isComplete
            ? Icons.check_circle
            : Icons.check_circle_outline,
        color: state.isComplete
            ? Theme.of(context).colorScheme.primary
            : null,
      ),
      onPressed: () => unawaited(
        ref
            .read(documentReadingControllerProvider(documentId).notifier)
            .setComplete(isComplete: !state.isComplete),
      ),
    );
  }
}
