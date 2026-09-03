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
import '../../profile/presentation/profile_view.dart';
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
      appBar: AppBar(title: Text(_displayTitle(grant.value))),
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
    return renderer.build(
      uri: uri,
      controller: _pdfController,
      onReady: _onPdfReady,
      onLoadFailed: _onPdfLoadFailed,
      onRetry: _requestFreshLink,
    );
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
