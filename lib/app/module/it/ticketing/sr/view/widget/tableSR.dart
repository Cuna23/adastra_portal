import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/sr_model.dart';
import '../../view model/sr_vm.dart';

class SRTable extends StatefulWidget {
  final String role;
  final String token;
  final ScrollController scrollController;
  final void Function(int id) onView;
  final bool shrinkWrap;

  const SRTable({
    super.key,
    required this.role,
    required this.token,
    required this.scrollController,
    required this.onView,
    this.shrinkWrap = false,
  });

  @override
  State<SRTable> createState() => _SRTableState();
}

class _SRTableState extends State<SRTable> {
  // ── Design tokens — identical to IncidentTable ─────────────────────────
  static const _brandBlue     = Color(0xFF185FA5);
  static const _textPrimary   = Color(0xFF1B1E28);
  static const _textSecondary = Color(0xFF6B7280);
  static const _textMuted     = Color(0xFF9CA3AF);
  static const _borderColor   = Color(0xFFE5E7EB);

  // Status pill colours
  static const _pendAmber   = Color(0xFF854F0B);
  static const _pendAmberBg = Color(0xFFFAEEDA);
  static const _appGreen    = Color(0xFF3B6D11);
  static const _appGreenBg  = Color(0xFFEAF3DE);
  static const _rejRed      = Color(0xFFA32D2D);
  static const _rejRedBg    = Color(0xFFFCEBEB);

  // Priority pill colours
  static const _highRed     = Color(0xFFA32D2D);
  static const _highRedBg   = Color(0xFFFCEBEB);
  static const _medAmber    = Color(0xFF854F0B);
  static const _medAmberBg  = Color(0xFFFAEEDA);
  static const _lowGreen    = Color(0xFF3B6D11);
  static const _lowGreenBg  = Color(0xFFEAF3DE);

  // Fixed column widths
  static const double _wNo     = 44.0;
  static const double _wSr     = 130.0;
  static const double _wTitle  = 220.0;
  static const double _wType   = 170.0;
  static const double _wCategory = 140.0;
  static const double _wQty      = 60.0;
  static const double _wPrio   = 100.0;
  static const double _wStatus = 110.0;
  static const double _wDate   = 110.0;
  static const double _wNeeded   = 110.0;

  double get _minWidth =>
      _wNo + _wSr + _wTitle + _wType + _wCategory + _wQty + _wPrio + _wStatus + _wDate + _wNeeded + 32.0;

  final ScrollController _hScrollController = ScrollController();

  String get role  => widget.role;
  String get token => widget.token;
  ScrollController get scrollController => widget.scrollController;
  void Function(int) get onView => widget.onView;

  @override
  void dispose() {
    _hScrollController.dispose();
    super.dispose();
  }

  static const _typeLabels = {
    'asset_request': 'Asset request',
    'software_installation': 'Software installation',
    'account_access': 'Account access',
    'other': 'Other',
  };

  String _typeLabel(String type) => _typeLabels[type] ?? type;

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }

  String _priorityLabel(String p) {
    switch (p) {
      case 'high':
        return 'High';
      case 'medium':
        return 'Medium';
      default:
        return 'Low';
    }
  }

  ({Color bg, Color fg}) _statusColors(String status) {
    switch (status) {
      case 'approved':
        return (bg: _appGreenBg, fg: _appGreen);
      case 'rejected':
        return (bg: _rejRedBg, fg: _rejRed);
      default:
        return (bg: _pendAmberBg, fg: _pendAmber);
    }
  }

  ({Color bg, Color fg}) _prioColors(String p) {
    switch (p) {
      case 'high':
        return (bg: _highRedBg, fg: _highRed);
      case 'medium':
        return (bg: _medAmberBg, fg: _medAmber);
      default:
        return (bg: _lowGreenBg, fg: _lowGreen);
    }
  }

  String _formatDate(DateTime dt) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceRequestViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final rows = vm.requests;

        Widget buildEmptyState() => Container(
              height: 160,
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.assignment_outlined, size: 32, color: _textMuted),
                  SizedBox(height: 8),
                  Text('No service requests found.',
                      style: TextStyle(color: _textSecondary, fontSize: 13)),
                ],
              ),
            );

        final tableBody = Scrollbar(
          controller: _hScrollController,
          thumbVisibility: true,
          notificationPredicate: (n) => n.depth == 0,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final tableWidth = _minWidth > constraints.maxWidth
                  ? _minWidth
                  : constraints.maxWidth;

              final rowsArea = rows.isEmpty
                  ? buildEmptyState()
                  : ListView.separated(
                      controller: widget.shrinkWrap ? null : scrollController,
                      shrinkWrap: widget.shrinkWrap,
                      physics: widget.shrinkWrap
                          ? const NeverScrollableScrollPhysics()
                          : null,
                      itemCount: rows.length,
                      separatorBuilder: (_, __) => const Divider(
                          height: 0.5, thickness: 0.5, color: _borderColor),
                      itemBuilder: (context, i) =>
                          _buildRow(context, rows[i], tableWidth, i + 1),
                    );

              return SingleChildScrollView(
                controller: _hScrollController,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: tableWidth,
                  child: Column(
                    mainAxisSize:
                        widget.shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
                    children: [
                      _buildHeader(tableWidth),
                      const Divider(
                          height: 0.5, thickness: 0.5, color: _borderColor),
                      widget.shrinkWrap ? rowsArea : Expanded(child: rowsArea),
                    ],
                  ),
                ),
              );
            },
          ),
        );

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _borderColor),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Column(
              mainAxisSize:
                  widget.shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
              children: [
                widget.shrinkWrap ? tableBody : Expanded(child: tableBody),
                const Divider(height: 0.5, thickness: 0.5, color: _borderColor),
                _buildFooter(rows),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Header row ───────────────────────────────────────────────────────────

  Widget _buildHeader(double width) {
    return Container(
      width: width,
      color: const Color(0xFFF8F9FB),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _hLabel('NO', _wNo),
          _hLabel('SR NUMBER', _wSr),
          _hLabel('TITLE', _wTitle),
          _hLabel('TYPE', _wType),
          _hLabel('CATEGORY', _wCategory),
          _hLabel('QTY', _wQty),
          _hLabel('PRIORITY', _wPrio),
          _hLabel('STATUS', _wStatus),
          _hLabel('SUBMITTED', _wDate),
          _hLabel('NEEDED BY', _wNeeded),
        ],
      ),
    );
  }

  Widget _hLabel(String text, double width) => SizedBox(
        width: width,
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

  // ── Data row ─────────────────────────────────────────────────────────────

  Widget _buildRow(
      BuildContext context, ServiceRequestModel sr, double width, int rowNo) {
    final sc = _statusColors(sr.status);
    final pc = _prioColors(sr.priority);

    return InkWell(
      onTap: () => onView(sr.id),
      child: SizedBox(
        width: width,
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              SizedBox(
                width: _wNo,
                child: Text('$rowNo',
                    style: const TextStyle(fontSize: 13, color: _textSecondary)),
              ),
              SizedBox(
                width: _wSr,
                child: Text(
                  sr.srNumber,
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: _brandBlue,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                width: _wTitle,
                child: Text(
                  sr.requestTitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                width: _wType,
                child: Text(
                  _typeLabel(sr.requestType),
                  style: const TextStyle(fontSize: 13, color: _textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                width: _wCategory,
                child: Text(
                  sr.category,
                  style: const TextStyle(fontSize: 13, color: _textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                width: _wQty,
                child: Text(
                  '${sr.quantity}',
                  style: const TextStyle(fontSize: 13, color: _textSecondary),
                ),
              ),
              SizedBox(
                width: _wPrio,
                child: _pill(_priorityLabel(sr.priority), bg: pc.bg, fg: pc.fg),
              ),
              SizedBox(
                width: _wStatus,
                child: _pill(_statusLabel(sr.status), bg: sc.bg, fg: sc.fg),
              ),
              SizedBox(
                width: _wDate,
                child: Text(
                  _formatDate(sr.createdAt),
                  style: const TextStyle(fontSize: 13, color: _textMuted),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                width: _wNeeded,
                child: Text(
                  _formatDate(sr.neededByDate),
                  style: const TextStyle(fontSize: 13, color: _textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Footer ───────────────────────────────────────────────────────────────

  Widget _buildFooter(List<ServiceRequestModel> rows) {
    final total = rows.length;
    final pending = rows.where((r) => r.status == 'pending').length;
    final approved = rows.where((r) => r.status == 'approved').length;
    final rejected = rows.where((r) => r.status == 'rejected').length;

    return Container(
      color: const Color(0xFFF8F9FB),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.assignment_outlined, size: 14, color: _textMuted),
          const SizedBox(width: 6),
          Text(
            'Total requests: $total',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _textSecondary,
            ),
          ),
          const Spacer(),
          if (pending > 0) ...[
            Text('$pending pending',
                style: const TextStyle(
                    fontSize: 11, color: _pendAmber, fontWeight: FontWeight.w500)),
            const SizedBox(width: 12),
          ],
          if (approved > 0) ...[
            Text('$approved approved',
                style: const TextStyle(
                    fontSize: 11, color: _appGreen, fontWeight: FontWeight.w500)),
            const SizedBox(width: 12),
          ],
          if (rejected > 0)
            Text('$rejected rejected',
                style: const TextStyle(
                    fontSize: 11, color: _rejRed, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ── Shared widgets ───────────────────────────────────────────────────────

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
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}