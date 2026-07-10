import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view model/sr_vm.dart';
import 'widget/createSR_dialog.dart';
import 'widget/tableSR.dart';

class ServiceRequestStaffView extends StatefulWidget {
  final String token;
  final String role;
  final int currentUserId;

  const ServiceRequestStaffView({
    super.key,
    required this.token,
    required this.role,
    required this.currentUserId,
  });

  @override
  State<ServiceRequestStaffView> createState() => _ServiceRequestStaffViewState();
}

class _ServiceRequestStaffViewState extends State<ServiceRequestStaffView> {
  static const _brandBlue = Color(0xFF185FA5);

  int? _selectedId;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceRequestViewModel>().fetchRequests(widget.token);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _openCreateDialog() {
    showDialog(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<ServiceRequestViewModel>(),
        child: CreateSRDialog(token: widget.token),
      ),
    );
  }

  void _openDetail(int id) {
    context.read<ServiceRequestViewModel>().selectRequest(widget.token, id);
    setState(() => _selectedId = id);
  }

  void _closeDetail() {
    context.read<ServiceRequestViewModel>().clearSelected();
    setState(() => _selectedId = null);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.role != 'staff' &&
        widget.role != 'admin' &&
        widget.role != 'super_admin' &&
        widget.role != 'hod') {
      return const Center(child: Text('Access Denied'));
    }

    return Consumer<ServiceRequestViewModel>(
      builder: (context, vm, _) {
        // TODO: detail page — dibuat lepas ni (SRDetailPage)
        if (_selectedId != null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Detail view for request #$_selectedId — coming soon'),
                TextButton(onPressed: _closeDetail, child: const Text('Back')),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                children: [
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _openCreateDialog,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Service Request'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _brandBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SRTable(
                  role: widget.role, 
                  token: widget.token,
                  scrollController: _scrollController,
                  onView: _openDetail,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}