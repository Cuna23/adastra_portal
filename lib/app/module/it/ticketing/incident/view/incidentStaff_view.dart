import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view model/incident_vm.dart';
import 'widget/createIncident_dialog.dart';
import 'widget/incDetailDialog.dart';
import 'widget/tableInc.dart';

class IncidentStaffView extends StatefulWidget {
  final String token;
  final String role;
  final int currentUserId;

  const IncidentStaffView({
    super.key,
    required this.token,
    required this.role,
    required this.currentUserId,
  });

  @override
  State<IncidentStaffView> createState() => _IncidentStaffViewState();
}

class _IncidentStaffViewState extends State<IncidentStaffView> {

  static const _brandBlue     = Color(0xFF185FA5);

  // ── Detail view state — null = list, non-null = detail ───────────────────
  int? _selectedId;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IncidentVM>().fetchIncidents(widget.token);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _openReportDialog() {
    showDialog(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<IncidentVM>(),
        child: CreateIncidentDialog(token: widget.token),
      ),
    );
  }

  void _openDetail(int id) {
    context.read<IncidentVM>().selectIncident(widget.token, id);
    setState(() => _selectedId = id);
  }

  void _closeDetail() {
    context.read<IncidentVM>().clearSelected();
    setState(() => _selectedId = null);
  }


  @override
  Widget build(BuildContext context) {
    if (widget.role != 'staff' &&
        widget.role != 'admin' &&
        widget.role != 'super_admin') {
      return const Center(child: Text('Access Denied'));
    }

    return Consumer<IncidentVM>(
      builder: (context, vm, _) {
        // ── Detail page ───────────────────────────────────────────────────
        if (_selectedId != null) {
          return IncDetailPage(
            token: widget.token,
            role: widget.role,
            onBack: _closeDetail,
            currentUserId: widget.currentUserId,
          );
        }

        // ── List page ─────────────────────────────────────────────────────
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Header row — UNCHANGED ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                children: [
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _openReportDialog,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Report Incident'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _brandBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),

            // ── Table list ─────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: IncidentTable(
                  role: widget.role,
                  token: widget.token,
                  scrollController: _scrollController,
                  onView: _openDetail,
                  showIssuerColumn: false,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}