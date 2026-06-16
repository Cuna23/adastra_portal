import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/incident_model.dart';
import '../../view model/incident_vm.dart';

// ── IncDetailPage — full-page detail view (replaces Dialog) ──────────────────
class IncDetailPage extends StatefulWidget {
  final String token;
  final VoidCallback onBack;

  const IncDetailPage({
    super.key,
    required this.token,
    required this.onBack,
  });

  @override
  State<IncDetailPage> createState() => _IncDetailPageState();
}

class _IncDetailPageState extends State<IncDetailPage> {
  static const _brandBlue     = Color(0xFF185FA5);
  static const _brandBlueBg   = Color(0xFFE6F1FB);
  static const _textPrimary   = Color(0xFF1B1E28);
  static const _textSecondary = Color(0xFF6B7280);
  static const _textMuted     = Color(0xFF9CA3AF);
  static const _borderColor   = Color(0xFFE5E7EB);
  static const _bgLight       = Color(0xFFF9FAFB);

  final _noteCtrl        = TextEditingController();
  final _activityScroll  = ScrollController();
  bool  _sendingNote     = false;

  @override
  void dispose() {
    _noteCtrl.dispose();
    _activityScroll.dispose();
    super.dispose();
  }

  Future<void> _sendNote(IncidentVM vm, IncidentModel inc) async {
    final note = _noteCtrl.text.trim();
    if (note.isEmpty) return;

    setState(() => _sendingNote = true);
    final ok = await vm.addNote(
      token: widget.token,
      id:    inc.id,
      note:  note,
    );
    if (ok && mounted) {
      _noteCtrl.clear();
      // Scroll activity to bottom after note added
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_activityScroll.hasClients) {
          _activityScroll.animateTo(
            _activityScroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
    if (mounted) setState(() => _sendingNote = false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<IncidentVM>(
      builder: (context, vm, _) {
        final inc = vm.selected;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Back button row ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: GestureDetector(
                onTap: widget.onBack,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.arrow_back_ios_new_rounded,
                        size: 13, color: _brandBlue),
                    SizedBox(width: 6),
                    Text(
                      'Back to Incident Report',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _brandBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Loading ───────────────────────────────────────────────────
            if (inc == null)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // 2-panel on wide screens, single column on narrow
                      final wide = constraints.maxWidth >= 700;
                      if (wide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left — ticket details
                            Expanded(
                              flex: 7,
                              child: _buildDetailPanel(inc),
                            ),
                            const SizedBox(width: 16),
                            // Right — activity + note input
                            Expanded(
                              flex: 4,
                              child: _buildActivityPanel(vm, inc),
                            ),
                          ],
                        );
                      }
                      // Narrow — stack vertically, single scroll
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildDetailPanel(inc),
                            const SizedBox(height: 16),
                            _buildActivityPanel(vm, inc),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // ── Left panel: ticket details ────────────────────────────────────────────

  Widget _buildDetailPanel(IncidentModel inc) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor, width: 0.5),
      ),
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Header — icon + subject + ticket no + pills
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: _brandBlueBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.confirmation_number_outlined,
                      color: _brandBlue, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        inc.subject,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        inc.ticketNo,
                        style: const TextStyle(
                            fontSize: 12,
                            color: _textMuted,
                            fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Wrap(
                  spacing: 6,
                  children: [
                    _pill(inc.status,
                        bg: _statusColors(inc.status).bg,
                        fg: _statusColors(inc.status).fg),
                    _pill(inc.priority,
                        bg: _prioColors(inc.priority).bg,
                        fg: _prioColors(inc.priority).fg),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(height: 0.5, thickness: 0.5, color: _borderColor),
            const SizedBox(height: 20),

            // Fields grid
            _fieldRow(
              _readonlyField(label: 'Category',  value: inc.category,                      icon: Icons.category_outlined),
              _readonlyField(label: 'Priority',   value: inc.priority,                      icon: Icons.flag_outlined),
            ),
            const SizedBox(height: 14),
            _fieldRow(
              _readonlyField(label: 'Reported by', value: inc.user?.name ?? '—',            icon: Icons.person_outline),
              _readonlyField(label: 'Assigned to', value: _assignedLabel(inc), icon: Icons.support_agent_outlined),
            ),
            const SizedBox(height: 14),
            _fieldRow(
              _readonlyField(label: 'Submitted',    value: _formatDate(inc.createdAt),      icon: Icons.calendar_today_outlined),
              _readonlyField(label: 'Last updated', value: _formatDate(inc.updatedAt),      icon: Icons.update_outlined),
            ),
            const SizedBox(height: 14),
            _readonlyField(
              label: 'Description',
              value: inc.description,
              icon: Icons.notes_outlined,
              maxLines: 5,
              fullWidth: true,
            ),

            // Attachment
            if (inc.attachment != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: _bgLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _borderColor, width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.attach_file,
                        size: 18, color: _textMuted),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        inc.attachment!.split('/').last,
                        style: const TextStyle(
                            fontSize: 13, color: _brandBlue),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Right panel: activity log + note input ────────────────────────────────

  Widget _buildActivityPanel(IncidentVM vm, IncidentModel inc) {
    final isClosed =
        inc.status == 'Resolved' || inc.status == 'Closed';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor, width: 0.5),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Section title
          Row(
            children: [
              const Icon(Icons.timeline_outlined,
                  size: 16, color: _textSecondary),
              const SizedBox(width: 8),
              const Text(
                'Activity',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                '${inc.logs.length} ${inc.logs.length == 1 ? 'entry' : 'entries'}',
                style: const TextStyle(
                    fontSize: 11, color: _textMuted),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 0.5, thickness: 0.5, color: _borderColor),
          const SizedBox(height: 12),

          // Scrollable log list
          Expanded(
            child: inc.logs.isEmpty
                ? const Center(
                    child: Text('No activity yet.',
                        style: TextStyle(
                            fontSize: 13, color: _textMuted)),
                  )
                : ListView.builder(
                    controller: _activityScroll,
                    itemCount: inc.logs.length,
                    itemBuilder: (_, i) =>
                        _timelineItem(inc.logs[i], inc),
                  ),
          ),

          const SizedBox(height: 12),
          const Divider(height: 0.5, thickness: 0.5, color: _borderColor),
          const SizedBox(height: 12),

          // Note input
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _noteCtrl,
                  enabled: !isClosed,
                  maxLines: 3,
                  minLines: 1,
                  style: const TextStyle(
                    fontSize: 13,
                    color: _textPrimary,
                  ),
                  decoration: InputDecoration(
                    labelText: isClosed
                        ? 'Ticket closed — no more notes'
                        : 'Add a note or additional information...',
                    labelStyle:
                        const TextStyle(fontSize: 12, color: _textMuted),
                    prefixIcon: const Icon(Icons.notes_outlined,
                        size: 16, color: _textMuted),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    filled: true,
                    fillColor: isClosed ? _bgLight : Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: _borderColor, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: _brandBlue, width: 1.5),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: _borderColor, width: 1),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: isClosed || _sendingNote
                      ? null
                      : () => _sendNote(vm, inc),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandBlue,
                    disabledBackgroundColor:
                        _brandBlue.withOpacity(0.4),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: _sendingNote
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.send,
                          size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

    String _assignedLabel(IncidentModel inc) {
    final u = inc.assignedUser;
    if (u == null) return 'Pending';
    if (u.role == 'super_admin') return 'IT';
    return u.name;
  }

  // ── Timeline item ─────────────────────────────────────────────────────────

  Widget _timelineItem(IncidentLog log, IncidentModel inc) {
    final isStaff = log.userId == inc.userId;
    final dotColor = isStaff ? _brandBlue : _textMuted;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              const SizedBox(height: 5),
              Container(
                width: 7, height: 7,
                decoration: BoxDecoration(
                    color: dotColor, shape: BoxShape.circle),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                        fontSize: 13,
                        color: _textSecondary,
                        height: 1.5),
                    children: [
                      if (log.user != null)
                        TextSpan(
                          text: '${log.user!.name}: ',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _textPrimary),
                        ),
                      TextSpan(text: log.description),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(log.createdAt),
                  style: const TextStyle(
                      fontSize: 11, color: _textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _readonlyField({
    required String label,
    required String value,
    required IconData icon,
    int maxLines = 1,
    bool fullWidth = false,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: _textMuted),
        prefixIcon: Icon(icon, size: 18, color: _textMuted),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        filled: true,
        fillColor: _bgLight,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _borderColor, width: 1),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _borderColor, width: 1),
        ),
      ),
      child: Text(
        value,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: _textPrimary,
        ),
      ),
    );
  }

  Widget _fieldRow(Widget a, Widget b) {
    return Row(
      children: [
        Expanded(child: a),
        const SizedBox(width: 12),
        Expanded(child: b),
      ],
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

  ({Color bg, Color fg}) _statusColors(String status) {
    switch (status) {
      case 'Open':
        return (bg: const Color(0xFFE6F1FB), fg: const Color(0xFF185FA5));
      case 'In Progress':
        return (bg: const Color(0xFFFAEEDA), fg: const Color(0xFF854F0B));
      case 'Resolved':
        return (bg: const Color(0xFFEAF3DE), fg: const Color(0xFF3B6D11));
      case 'Closed':
        return (bg: const Color(0xFFF1EFE8), fg: const Color(0xFF5F5E5A));
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
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '${dt.day} ${months[dt.month]} ${dt.year} · $h:$m';
    } catch (_) {
      return iso;
    }
  }
}