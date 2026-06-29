import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/incident_model.dart';
import '../../view model/incident_vm.dart';


class IncidentTable extends StatefulWidget {
  final String role;
  final String token;
  final ScrollController scrollController;
  final void Function(int id) onView;
  final bool showIssuerColumn;
  final bool shrinkWrap; 

  const IncidentTable({
    super.key,
    required this.role,
    required this.token,
    required this.scrollController,
    required this.onView,
    this.showIssuerColumn = true,
    this.shrinkWrap = false, 
  });

  @override
  State<IncidentTable> createState() => _IncidentTableState();
}

class _IncidentTableState extends State<IncidentTable> {

  // ── Design tokens — identical to AssetTable ─────────────────────────────
  static const _brandBlue     = Color(0xFF185FA5);
  static const _brandBlueBg   = Color(0xFFE6F1FB);
  static const _textPrimary   = Color(0xFF1B1E28);
  static const _textSecondary = Color(0xFF6B7280);
  static const _textMuted     = Color(0xFF9CA3AF);
  static const _borderColor   = Color(0xFFE5E7EB);

  // Status / priority pill colours
  static const _openBlue      = Color(0xFF185FA5);
  static const _openBlueBg    = Color(0xFFE6F1FB);
  static const _progAmber     = Color(0xFF854F0B);
  static const _progAmberBg   = Color(0xFFFAEEDA);
  static const _resGreen      = Color(0xFF3B6D11);
  static const _resGreenBg    = Color(0xFFEAF3DE);
  static const _highRed       = Color(0xFFA32D2D);
  static const _highRedBg     = Color(0xFFFCEBEB);
  static const _pendGray      = Color(0xFF5F5E5A);
  static const _pendGrayBg    = Color(0xFFF1EFE8);
  static const _reviewPurple   = Color(0xFF6B3FA0);
  static const _reviewPurpleBg = Color(0xFFEFE6F8);

  // Fixed column widths — triggers horizontal scroll when screen is narrow
  static const double _wNo       = 44.0;
  static const double _wTicket   = 140.0;
  static const double _wSubject  = 220.0;
  static const double _wIssuer = 150.0;
  static const double _wCat      = 130.0;
  static const double _wPrio     = 100.0;
  static const double _wStatus   = 120.0;
  static const double _wAssign   = 150.0;
  static const double _wDate     = 110.0;

  double get _minWidth =>
        _wNo + _wTicket + _wSubject + (showIssuerColumn ? _wIssuer : 0) + _wCat + _wPrio +
        _wStatus + _wAssign + _wDate + 120 + 32.0;

  // Shared horizontal ScrollController — header + all rows move together
  final ScrollController _hScrollController = ScrollController();

  bool get showIssuerColumn => widget.showIssuerColumn;
  String get role  => widget.role;
  String get token => widget.token;
  ScrollController get scrollController => widget.scrollController;
  void Function(int) get onView => widget.onView;

  @override
  void dispose() {
    _hScrollController.dispose();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  String _assignedLabel(IncidentModel inc) {
    final u = inc.assignedUser;
    if (u == null) return 'Pending';
    if (u.role == 'super_admin') return 'IT';
    return u.name;
  }

  ({Color bg, Color fg}) _statusColors(String status) {
    switch (status) {
      case 'Open':
        return (bg: _openBlueBg, fg: _openBlue);
      case 'In Pending':
        return (bg: _pendGrayBg, fg: _pendGray);
      case 'Resolved':
        return (bg: _resGreenBg, fg: _resGreen);
      case 'Review':
        return (bg: _reviewPurpleBg, fg: _reviewPurple);
      default:
        return (bg: _pendGrayBg, fg: _pendGray);
    }
  }

  ({Color bg, Color fg}) _prioColors(String p) {
    switch (p) {
      case 'High':
        return (bg: _highRedBg, fg: _highRed);
      case 'Medium':
        return (bg: _progAmberBg, fg: _progAmber);
      default:
        return (bg: _resGreenBg, fg: _resGreen);
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

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Consumer<IncidentVM>(
      builder: (context, vm, _) {
        if (vm.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (vm.error != null) {
          return _buildError(vm);
        }

        final rows = vm.incidents;

        Widget buildEmptyState() => Container(
              height: 160,
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.confirmation_number_outlined,
                      size: 32, color: _textMuted),
                  SizedBox(height: 8),
                  Text('No incidents found.',
                      style: TextStyle(color: _textSecondary, fontSize: 13)),
                ],
              ),
            );

        // Widget buildList({required bool shrink}) => ListView.separated(
        //       controller: shrink ? null : scrollController,
        //       shrinkWrap: shrink,
        //       physics: shrink ? const NeverScrollableScrollPhysics() : null,
        //       itemCount: rows.length,
        //       separatorBuilder: (_, __) =>
        //           const Divider(height: 0.5, thickness: 0.5, color: _borderColor),
        //       itemBuilder: (context, i) => _buildRow(context, rows[i], 0), // width set below via SizedBox parent
        //     );

        // ── Header + rows share ONE horizontal scroll ──────────────────────
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
                      widget.shrinkWrap
                          ? rowsArea
                          : Expanded(child: rowsArea), // ← KEY FIX
                    ],
                  ),
                ),
              );
            },
          ),
        );

        // ── Outer card — Expanded only when NOT shrinkWrap ─────────────────
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
                _buildFooter(vm),
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
          _hLabel('NO',          _wNo),
          _hLabel('TICKET NO',   _wTicket),
          _hLabel('SUBJECT',     _wSubject),
          if (showIssuerColumn) _hLabel('ISSUER', _wIssuer),
          _hLabel('CATEGORY',    _wCat),
          _hLabel('PRIORITY',    _wPrio),
          _hLabel('STATUS',      _wStatus),
          _hLabel('ASSIGNED TO', _wAssign),
          _hLabel('DATE',        _wDate),
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

  Widget _buildRow(BuildContext context, IncidentModel inc, double width, int rowNo) {
      final sc = _statusColors(inc.status);
      final pc = _prioColors(inc.priority);
      final assignedLabel = _assignedLabel(inc);
      final isIT      = inc.assignedUser?.role == 'super_admin';
      final isPending = inc.assignedUser == null;

      return InkWell(
        onTap: () => onView(inc.id),
        child: SizedBox(
          width: width,
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // No.
                SizedBox(
                  width: _wNo,
                  child: Text(
                    '$rowNo',
                    style: const TextStyle(fontSize: 13, color: _textSecondary),
                  ),
                ),

                // Ticket No
                SizedBox(
                  width: _wTicket,
                child: Text(
                  inc.ticketNo,
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: _textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Subject
              SizedBox(
                width: _wSubject,
                child: Text(
                  inc.subject,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Issuer
              if (showIssuerColumn)
                SizedBox(
                  width: _wIssuer,
                  child: Row(
                    children: [
                      _avatarCircle(inc.user?.name ?? '?'),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          inc.user?.name ?? '—',
                          style: const TextStyle(
                              fontSize: 13, color: _textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

              // Category
              SizedBox(
                width: _wCat,
                child: Text(
                  inc.category,
                  style: const TextStyle(
                      fontSize: 13, color: _textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Priority pill
              SizedBox(
                width: _wPrio,
                child: _pill(inc.priority, bg: pc.bg, fg: pc.fg),
              ),

              // Status pill
              SizedBox(
                width: _wStatus,
                child: _pill(inc.status, bg: sc.bg, fg: sc.fg),
              ),

              // Assigned to
              SizedBox(
                width: _wAssign,
                child: isPending
                    ? _pill('Pending', bg: _pendGrayBg, fg: _pendGray)
                    : Row(
                        children: [
                          if (isIT)
                            const Icon(Icons.support_agent_outlined,
                                size: 14, color: _brandBlue)
                          else
                            _avatarCircle(assignedLabel),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              assignedLabel,
                              style: TextStyle(
                                fontSize: 13,
                                color: isIT ? _brandBlue : _textSecondary,
                                fontWeight:
                                    isIT ? FontWeight.w600 : FontWeight.w400,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
              ),

              // Date
              SizedBox(
                width: _wDate,
                child: Text(
                  _formatDate(inc.createdAt),
                  style: const TextStyle(fontSize: 13, color: _textMuted),
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
          if (vm.countOpen > 0) ...[
            Text('${vm.countOpen} open',
                style: const TextStyle(
                    fontSize: 11, color: _openBlue, fontWeight: FontWeight.w500)),
            const SizedBox(width: 12),
          ],
          if (vm.countInPending > 0) ...[
            Text('${vm.countInPending} in pending',
                style: const TextStyle(
                    fontSize: 11, color: _pendGray, fontWeight: FontWeight.w500)),
            const SizedBox(width: 12),
          ],
          if (vm.countResolved > 0)
            Text('${vm.countResolved} resolved',
                style: const TextStyle(
                    fontSize: 11, color: _resGreen, fontWeight: FontWeight.w500)),
        ],
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
            onPressed: () => vm.fetchIncidents(token),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
  // ── Shared widgets ───────────────────────────────────────────────────────

  Widget _avatarCircle(String name) {
    final initials =
        name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    return Container(
      width: 22, height: 22,
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
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: fg,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}