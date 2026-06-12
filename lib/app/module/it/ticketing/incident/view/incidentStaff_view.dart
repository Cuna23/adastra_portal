// incidentStaff_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view model/incident_vm.dart';
import '../model/incident_model.dart';
import 'widget/createIncident_dialog.dart';
import 'widget/incDetailDialog.dart';

class IncidentStaffView extends StatefulWidget {
  final String token;
  final String role;

  const IncidentStaffView({
    super.key,
    required this.token,
    required this.role,
  });

  @override
  State<IncidentStaffView> createState() => _IncidentStaffViewState();
}

class _IncidentStaffViewState extends State<IncidentStaffView> {

  
  static const _brandBlue     = Color(0xFF185FA5);
  static const _brandBlueBg   = Color(0xFFE6F1FB);
  static const _textPrimary   = Color(0xFF1B1E28);
  static const _textSecondary = Color(0xFF6B7280);
  static const _textMuted     = Color(0xFF9CA3AF);
  static const _borderColor   = Color(0xFFE5E7EB);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IncidentVM>().fetchIncidents(widget.token);
    });
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

  void _openDetailDialog(int id) {
    showDialog(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<IncidentVM>(),
        child: IncDetailDialog(token: widget.token, incidentId: id),
      ),
    );
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Header row (mirrors user_view.dart) ──────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                children: [
                  // Filter tabs live here, left-aligned
                  Expanded(
                    child: _buildFilterTabs(vm),
                  ),
                  const Spacer(),
                  // Report incident button — same style as Add User
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

            // ── Table ─────────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: vm.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : vm.error != null
                        ? _buildError(vm)
                        : vm.incidents.isEmpty
                            ? _buildEmpty()
                            : _buildTable(vm),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Filter tabs (inline, no separate Container/white bg) ─────────────────

  Widget _buildFilterTabs(IncidentVM vm) {
    final filters = [
      ('All', vm.countAll),
      ('Open', vm.countOpen),
      ('In Progress', vm.countInProgress),
      ('Resolved', vm.countResolved),
    ];

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: filters.map((f) {
          final active = vm.filterStatus == f.$1;

          return GestureDetector(
            onTap: () => vm.setFilter(f.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 0,
              ),
              decoration: BoxDecoration(
                color: active ? _brandBlue : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: active ? _brandBlue : _borderColor,
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 6),

                  Text(
                    f.$1,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          active ? FontWeight.w600 : FontWeight.w400,
                      color:
                          active ? Colors.white : _textPrimary,
                    ),
                  ),

                  const SizedBox(width: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: active
                          ? Colors.white.withOpacity(0.2)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${f.$2}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: active
                            ? Colors.white
                            : _textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Table (standardized with tableU.dart pattern) ────────────────────────

  Widget _buildTable(IncidentVM vm) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          children: [
            _buildTableHeader(),
            const Divider(height: 0.5, thickness: 0.5, color: _borderColor),
            Expanded(
              child: ListView.separated(
                itemCount: vm.incidents.length,
                separatorBuilder: (_, __) => const Divider(
                    height: 0.5, thickness: 0.5, color: _borderColor),
                itemBuilder: (_, i) => _buildRow(vm.incidents[i]),
              ),
            ),
            const Divider(height: 0.5, thickness: 0.5, color: _borderColor),
            _buildFooter(vm),
          ],
        ),
      ),
    );
  }

  // Header — uses Expanded + flex exactly like tableU.dart
  Widget _buildTableHeader() {
    return Container(
      color: const Color(0xFFF8F9FB),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _headerLabel('TICKET',      flex: 4),
          _headerLabel('CATEGORY',    flex: 2),
          _headerLabel('PRIORITY',    flex: 2),
          _headerLabel('STATUS',      flex: 2),
          _headerLabel('ASSIGNED TO', flex: 3),
          _headerLabel('DATE',        flex: 2),
        ],
      ),
    );
  }

  Widget _headerLabel(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _textMuted,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // Row — uses Expanded + flex, mirrors _buildRow in tableU.dart
  Widget _buildRow(IncidentModel inc) {
    final sc = _statusColors(inc.status);
    final pc = _prioColors(inc.priority);

    return InkWell(
      onTap: () => _openDetailDialog(inc.id),
      hoverColor: const Color(0xFFF8F9FB),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Ticket subject + ticket no
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    inc.subject,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    inc.ticketNo,
                    style: const TextStyle(fontSize: 11, color: _textMuted),
                  ),
                ],
              ),
            ),

            // Category
            Expanded(
              flex: 2,
              child: Text(
                inc.category,
                style: const TextStyle(fontSize: 13, color: _textSecondary),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Priority badge
            Expanded(
              flex: 2,
              child: _pill(inc.priority, bg: pc.bg, fg: pc.fg),
            ),

            // Status badge
            Expanded(
              flex: 2,
              child: _pill(inc.status, bg: sc.bg, fg: sc.fg),
            ),

            // Assigned to
            Expanded(
              flex: 3,
              child: Text(
                inc.assignedUser?.name ?? '—',
                style: const TextStyle(fontSize: 13, color: _textSecondary),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Date
            Expanded(
              flex: 2,
              child: Text(
                _formatDate(inc.createdAt),
                style: const TextStyle(fontSize: 12, color: _textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Footer — mirrors _buildFooter in tableU.dart
  Widget _buildFooter(IncidentVM vm) {
    return Container(
      color: const Color(0xFFF8F9FB),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.confirmation_number_outlined,
              size: 14, color: _textMuted),
          const SizedBox(width: 6),
          Text(
            'Total tickets: ${vm.countAll}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _textSecondary,
            ),
          ),
          const Spacer(),
          if (vm.countOpen > 0)
            _footerStat('${vm.countOpen} open', _brandBlue),
          if (vm.countInProgress > 0) ...[
            const SizedBox(width: 12),
            _footerStat(
                '${vm.countInProgress} in progress', const Color(0xFF854F0B)),
          ],
          if (vm.countResolved > 0) ...[
            const SizedBox(width: 12),
            _footerStat(
                '${vm.countResolved} resolved', const Color(0xFF3B6D11)),
          ],
        ],
      ),
    );
  }

  // ── Empty / Error states ──────────────────────────────────────────────────

  Widget _buildEmpty() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.confirmation_number_outlined,
                size: 36, color: _textMuted),
            SizedBox(height: 10),
            Text('No incidents found.',
                style: TextStyle(fontSize: 13, color: _textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildError(IncidentVM vm) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline,
              size: 32, color: Color(0xFFE24B4A)),
          const SizedBox(height: 8),
          Text(vm.error ?? 'Error',
              style: const TextStyle(fontSize: 13, color: _textSecondary)),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => vm.fetchIncidents(widget.token),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  ({Color bg, Color fg}) _statusColors(String status) {
    switch (status) {
      case 'Open':
        return (bg: const Color(0xFFE6F1FB), fg: const Color(0xFF185FA5));
      case 'In Progress':
        return (bg: const Color(0xFFFAEEDA), fg: const Color(0xFF854F0B));
      case 'Resolved':
        return (bg: const Color(0xFFEAF3DE), fg: const Color(0xFF3B6D11));
      default:
        return (bg: const Color(0xFFF1EFE8), fg: const Color(0xFF5F5E5A));
    }
  }

  ({Color bg, Color fg}) _prioColors(String p) {
    switch (p) {
      case 'High':
        return (bg: const Color(0xFFFCEBEB), fg: const Color(0xFFA32D2D));
      case 'Medium':
        return (bg: const Color(0xFFFAEEDA), fg: const Color(0xFF854F0B));
      default:
        return (bg: const Color(0xFFEAF3DE), fg: const Color(0xFF3B6D11));
    }
  }

  Widget _pill(String text, {required Color bg, required Color fg}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: fg),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _footerStat(String text, Color color) {
    return Text(text,
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w500, color: color));
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      const months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${dt.day} ${months[dt.month]} ${dt.year}';
    } catch (_) {
      return iso;
    }
  }
} 