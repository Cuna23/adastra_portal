// incDetailDialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/incident_model.dart';
import '../../view model/incident_vm.dart';

class IncDetailDialog extends StatefulWidget {
  final String token;
  final int incidentId;

  const IncDetailDialog({
    super.key,
    required this.token,
    required this.incidentId,
  });

  @override
  State<IncDetailDialog> createState() => _IncDetailDialogState();
}

class _IncDetailDialogState extends State<IncDetailDialog> {
  // ── Design tokens (same as createA_dialog / createIncident_dialog) ────────
  static const _brandBlue     = Color(0xFF185FA5);
  static const _brandBlueBg   = Color(0xFFE6F1FB);
  static const _textPrimary   = Color(0xFF1B1E28);
  static const _textSecondary = Color(0xFF6B7280);
  static const _textMuted     = Color(0xFF9CA3AF);
  static const _borderColor   = Color(0xFFE5E7EB);
  static const _bgLight       = Color(0xFFF9FAFB);  // matches createA fillColor

  final _noteCtrl   = TextEditingController();
  bool _sendingNote = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<IncidentVM>()
          .selectIncident(widget.token, widget.incidentId);
    });
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  // ── Color helpers ─────────────────────────────────────────────────────────
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

  // ── Note field decoration (matches _fieldDecoration in createA_dialog) ────
  InputDecoration _noteDecoration(bool isClosed) {
    return InputDecoration(
      labelText: isClosed
          ? 'Ticket is closed — notes can no longer be added'
          : 'Add a note or additional information...',
      labelStyle: const TextStyle(fontSize: 13, color: _textMuted),
      prefixIcon: const Icon(Icons.notes_outlined,
          size: 18, color: _textMuted),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      filled: true,
      fillColor: isClosed ? _bgLight : Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _brandBlue, width: 1.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _borderColor, width: 1),
      ),
    );
  }

  // ── Send note ─────────────────────────────────────────────────────────────
  Future<void> _sendNote(IncidentVM vm) async {
    final note = _noteCtrl.text.trim();
    if (note.isEmpty) return;

    setState(() => _sendingNote = true);
    final ok = await vm.addNote(
      token: widget.token,
      id:    widget.incidentId,
      note:  note,
    );
    if (ok && mounted) {
      _noteCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note added'),
          backgroundColor: Color(0xFF3B6D11),
          duration: Duration(seconds: 2),
        ),
      );
    }
    if (mounted) setState(() => _sendingNote = false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<IncidentVM>(
      builder: (context, vm, _) {
        final inc = vm.selected;

        // ── Outer container matches createA_dialog exactly ────────────────
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 700),
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: inc == null
                ? const SizedBox(
                    height: 160,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // ── Header (same structure as createA_dialog) ─────
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _brandBlueBg,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                  Icons.confirmation_number_outlined,
                                  color: _brandBlue,
                                  size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    inc.subject,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: _textPrimary,
                                    ),
                                  ),
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
                            const SizedBox(width: 12),
                            _pill(inc.status,
                                bg: _statusColors(inc.status).bg,
                                fg: _statusColors(inc.status).fg),
                            const SizedBox(width: 6),
                            _pill(inc.priority,
                                bg: _prioColors(inc.priority).bg,
                                fg: _prioColors(inc.priority).fg),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.close,
                                  size: 18, color: _textSecondary),
                              onPressed: () {
                                context
                                    .read<IncidentVM>()
                                    .clearSelected();
                                Navigator.pop(context);
                              },
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // ── Detail grid — 2 columns using _fieldRow ───────
                        _fieldRow(
                          context,
                          _readonlyField(
                            label: 'Category',
                            value: inc.category,
                            icon: Icons.category_outlined,
                          ),
                          _readonlyField(
                            label: 'Priority',
                            value: inc.priority,
                            icon: Icons.flag_outlined,
                          ),
                        ),

                        const SizedBox(height: 14),

                        _fieldRow(
                          context,
                          _readonlyField(
                            label: 'Reported by',
                            value: inc.user?.name ?? '—',
                            icon: Icons.person_outline,
                          ),
                          _readonlyField(
                            label: 'Assigned to',
                            value: inc.assignedUser?.name ?? 'Pending',
                            icon: Icons.support_agent_outlined,
                          ),
                        ),

                        const SizedBox(height: 14),

                        _fieldRow(
                          context,
                          _readonlyField(
                            label: 'Submitted',
                            value: _formatDate(inc.createdAt),
                            icon: Icons.calendar_today_outlined,
                          ),
                          _readonlyField(
                            label: 'Last updated',
                            value: _formatDate(inc.updatedAt),
                            icon: Icons.update_outlined,
                          ),
                        ),

                        const SizedBox(height: 14),

                        // ── Description ───────────────────────────────────
                        _readonlyField(
                          label: 'Description',
                          value: inc.description,
                          icon: Icons.notes_outlined,
                          maxLines: 4,
                          fullWidth: true,
                        ),

                        // ── Attachment ────────────────────────────────────
                        if (inc.attachment != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: _bgLight,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: _borderColor, width: 1),
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
                                        fontSize: 13,
                                        color: _brandBlue),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),

                        // ── Activity section ──────────────────────────────
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _bgLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: _borderColor, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Activity',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _textSecondary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (inc.logs.isEmpty)
                                const Text(
                                  'No activity yet.',
                                  style: TextStyle(
                                      fontSize: 13, color: _textMuted),
                                )
                              else
                                ...inc.logs
                                    .map((log) => _timelineItem(log, inc)),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── Note input ────────────────────────────────────
                        _buildNoteInput(vm, inc),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  // ── Readonly field — same visual as createA_dialog text fields ────────────
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

  // ── Note input section ────────────────────────────────────────────────────
  Widget _buildNoteInput(IncidentVM vm, IncidentModel inc) {
    final isClosed =
        inc.status == 'Resolved' || inc.status == 'Closed';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextField(
            controller: _noteCtrl,
            enabled: !isClosed,
            maxLines: 2,
            minLines: 1,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: _textPrimary,
            ),
            decoration: _noteDecoration(isClosed),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed:
                isClosed || _sendingNote ? null : () => _sendNote(vm),
            style: ElevatedButton.styleFrom(
              backgroundColor: _brandBlue,
              disabledBackgroundColor: _brandBlue.withOpacity(0.4),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: _sendingNote
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.send,
                    size: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }

  // ── _fieldRow — responsive 2-col layout (same as createA_dialog) ──────────
  Widget _fieldRow(BuildContext context, Widget a, Widget b) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 500) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [a, const SizedBox(height: 14), b],
          );
        }
        return Row(
          children: [
            Expanded(child: a),
            const SizedBox(width: 12),
            Expanded(child: b),
          ],
        );
      },
    );
  }

  // ── Timeline item ─────────────────────────────────────────────────────────
  Widget _timelineItem(IncidentLog log, IncidentModel inc) {
    final isStaff = log.userId == inc.userId;
    final dotColor = isStaff ? _brandBlue : _textMuted;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              const SizedBox(height: 5),
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
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
  Widget _pill(String text,
      {required Color bg, required Color fg}) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600, color: fg),
      ),
    );
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