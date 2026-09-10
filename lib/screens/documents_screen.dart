import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/auth_service.dart';
import '../models/document_model.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class DocumentsScreen extends StatefulWidget {
  final String? statusFilter;
  final String emptyStateLabel;
  final String? searchQuery;

  const DocumentsScreen({
    super.key,
    this.statusFilter,
    this.emptyStateLabel = 'Documents',
    this.searchQuery,
  });

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final List<DocumentModel> _documents = [];
  final ScrollController _scrollController = ScrollController();

  int _currentPage = 0;
  bool _isLoadingFirstPage = true;
  bool _isLoadingMore = false;
  bool _hasReachedEnd = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPage(0);
    _scrollController.addListener(_onScroll);
  }

  Future<void> _refresh() async {
    setState(() {
      _documents.clear();
      _currentPage = 0;
      _hasReachedEnd = false;
      _isLoadingFirstPage = true;
    });
    await _loadPage(0);
  }

  Future<void> _handleDeleteTap(DocumentModel doc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.pageBackground,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Confirm Delete',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
            ),
            SizedBox(height: 12),
            Divider(height: 1, thickness: 1),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this document?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.textSecondary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text(
                      'No',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.textSecondary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text(
                      'Yes',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await AuthService.deleteDocument(doc.workflowId!.toInt());
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Document Deleted')));
        }
        await _refresh();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
        }
      }
    }
  }

  Future<void> _handleRenameTap(DocumentModel doc) async {
    final controller = TextEditingController(text: doc.name ?? '');

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.pageBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        actionsPadding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Document Rename',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 12),
            Divider(height: 1, thickness: 1),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Document Name',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              autofocus: true,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.accent,
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.accent,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: 85,
                height: 38,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFBDBDBD)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 85,
                height: 38,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () =>
                      Navigator.of(context).pop(controller.text.trim()),
                  child: const Text(
                    'Save',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty) {
      try {
        await AuthService.renameDocument(doc.workflowId!.toInt(), newName);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Document Renamed')));
        }
        await _refresh();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Rename failed: $e')));
        }
      }
    }
  }

  Future<void> _handleDownloadTap(DocumentModel doc) async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Downloading...')));

    try {
      final bytes = await AuthService.downloadDocument(doc.workflowId!.toInt());
      final dir = await getApplicationCacheDirectory();
      final filePath = '${dir.path}/${doc.name}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Downloaded Successfully')),
        );
      }
      await OpenFile.open(filePath);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Download failed: $e')));
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadNextPageIfNeeded();
    }
  }

  Future<void> _loadPage(int page) async {
    try {
      final response = await AuthService.fetchDocuments(
        page: page,
        status: widget.statusFilter,
        query: widget.searchQuery,
      );
      final content = response['content'] as List<dynamic>? ?? [];
      final isLast = response['last'] as bool? ?? true;

      final newDocs = content
          .map((json) => DocumentModel.fromJson(json as Map<String, dynamic>))
          .toList();

      if (mounted) {
        setState(() {
          _documents.addAll(newDocs);
          _currentPage = page;
          _hasReachedEnd = isLast;
          _isLoadingFirstPage = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoadingMore = false;
          _isLoadingFirstPage = false;
        });
      }
    }
  }

  Future<void> _loadNextPageIfNeeded() async {
    if (_isLoadingMore || _hasReachedEnd) return;

    setState(() => _isLoadingMore = true);
    await _loadPage(_currentPage + 1);
  }

  IconData _iconForStatus(String status) {
    switch (status.toUpperCase()) {
      case 'DRAFT':
        return Icons.insert_drive_file_outlined;
      case 'PENDING':
        return Icons.access_time;
      case 'SENT':
        return Icons.send_outlined;
      case 'VOID':
        return Icons.cancel_outlined;
      case 'SIGNED':
        return Icons.edit_outlined;
      case 'COMPLETED':
        return Icons.check_circle_outline;
      default:
        return Icons.description_outlined;
    }
  }

  String _formatData(String dateString) {
    final date = DateTime.tryParse(dateString);
    if (date == null) return dateString;

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingFirstPage) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null && _documents.isEmpty) {
      return Center(child: Text(_errorMessage!));
    }

    if (_documents.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.pageBackground,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/empty_documents.png', height: 150),
              const SizedBox(height: 16),
              Text(
                (widget.searchQuery != null && widget.searchQuery!.isNotEmpty)
                    ? 'No results for "${widget.searchQuery}"'
                    : 'Nothing in ${widget.emptyStateLabel}',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        bottom: false,
        child: ListView.separated(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: _documents.length + (_isLoadingMore ? 1 : 0),
          separatorBuilder: (context, index) =>
              const Divider(height: 1, indent: 20, endIndent: 20),
          itemBuilder: (context, index) {
            if (index >= _documents.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            }
            final doc = _documents[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 4,
              ),
              leading: Icon(_iconForStatus(doc.status ?? ''), size: 22),
              title: Text(
                doc.name ?? '',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                '${doc.ownerName}, documents (${doc.documentCount}) | ${_formatData(doc.updatedOn ?? '')}',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: PopupMenuButton<String>(
                color: AppColors.pageBackground,
                borderRadius: BorderRadius.circular(15),
                icon: const Icon(Icons.more_vert),
                onSelected: (action) {
                  switch (action) {
                    case 'download':
                      _handleDownloadTap(doc);
                      break;
                    case 'rename':
                      _handleRenameTap(doc);
                      break;
                    case 'delete':
                      _handleDeleteTap(doc);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'download',
                    child: Row(
                      children: [
                        Icon(Icons.download_outlined, size: 18),
                        SizedBox(width: 10),
                        Text('Download'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'rename',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18),
                        SizedBox(width: 10),
                        Text('Rename'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: AppColors.error,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Delete',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
