import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/incident_model.dart';
import '../../view model/incident_vm.dart';
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
  static const _textPrimary   = Color(0xFF1B1E28);
  static const _textSecondary = Color(0xFF6B7280);
  static const _textMuted     = Color(0xFF9CA3AF);
  static const _borderColor   = Color(0xFFE5E7EB);

  // ── Detail view state — null = list, non-null = detail ───────────────────
  int? _selectedId;

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
            onBack: _closeDetail,
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
                  Expanded(child: _buildFilterTabs(vm)),
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

            // ── Card list ─────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: vm.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : vm.error != null
                        ? _buildError(vm)
                        : vm.incidents.isEmpty
                            ? _buildEmpty()
                            : _buildCardList(vm),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Filter tabs — UNCHANGED ───────────────────────────────────────────────

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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
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
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                      color: active ? Colors.white : _textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
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
                        color: active ? Colors.white : _textMuted,
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

  // ── Card list ─────────────────────────────────────────────────────────────

  Widget _buildCardList(IncidentVM vm) {
    return Column(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: ListView.separated(
                itemCount: vm.incidents.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _buildCard(vm.incidents[i]),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _buildFooter(vm),
      ],
    );
  }

  Widget _buildCard(IncidentModel inc) {
    final sc = _statusColors(inc.status);
    final pc = _prioColors(inc.priority);
    final assignedLabel = _assignedLabel(inc);
    final isIT = inc.assignedUser?.role == 'super_admin';
    final isPending = inc.assignedUser == null;

    return InkWell(
      onTap: () => _openDetail(inc.id),
      borderRadius: BorderRadius.circular(14),
      hoverColor: const Color(0xFFF8F9FB),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _borderColor, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        inc.subject,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        inc.ticketNo,
                        style: const TextStyle(
                          fontSize: 11,
                          color: _textMuted,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Wrap(
                  spacing: 6,
                  children: [
                    _pill(inc.priority, bg: pc.bg, fg: pc.fg),
                    _pill(inc.status,   bg: sc.bg, fg: sc.fg),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 0.5, thickness: 0.5, color: _borderColor),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.label_outline, size: 13, color: _textMuted),
                const SizedBox(width: 4),
                Text(inc.category,
                    style: const TextStyle(
                        fontSize: 12, color: _textSecondary)),
                _metaDivider(),
                if (!isPending) ...[
                  if (isIT)
                    const Icon(Icons.support_agent_outlined, size: 13, color: _textMuted)  // IT icon
                  else
                    _avatarCircle(assignedLabel),
                  const SizedBox(width: 5),
                  Text(assignedLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: isIT ? _brandBlue : _textSecondary,
                        fontWeight: isIT ? FontWeight.w600 : FontWeight.w400,
                      )),
                ] else ...[
                  const Icon(Icons.support_agent_outlined, size: 13, color: _textMuted),
                  const SizedBox(width: 4),
                  const Text('Pending', style: TextStyle(fontSize: 12, color: _textMuted)),
                ],
                _metaDivider(),
                const Icon(Icons.calendar_today_outlined,
                    size: 12, color: _textMuted),
                const SizedBox(width: 4),
                Text(_formatDate(inc.createdAt),
                    style: const TextStyle(
                        fontSize: 12, color: _textMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }

    String _assignedLabel(IncidentModel inc) {
    final u = inc.assignedUser;
    if (u == null) return 'Pending';
    if (u.role == 'super_admin') return 'IT';
    return u.name;
  }
  // ── Footer ────────────────────────────────────────────────────────────────

  Widget _buildFooter(IncidentVM vm) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
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
            _footerStat('${vm.countInProgress} in progress',
                const Color(0xFF854F0B)),
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

  // ── Empty / Error ─────────────────────────────────────────────────────────

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

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _metaDivider() {
    return Container(
      width: 1, height: 12,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: _borderColor,
    );
  }

  Widget _avatarCircle(String name) {
    final initials =
        name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    return Container(
      width: 20, height: 20,
      decoration: const BoxDecoration(
          color: Color(0xFFB5D4F4), shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(initials,
          style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0C447C))),
    );
  }

  Widget _pill(String text, {required Color bg, required Color fg}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(text,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
    );
  }

  Widget _footerStat(String text, Color color) {
    return Text(text,
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w500, color: color));
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