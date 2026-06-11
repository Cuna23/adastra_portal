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
  // ── Design tokens ─────────────────────────────────────────────────────────
  static const _brandBlue     = Color(0xFF185FA5);
  static const _brandBlueBg   = Color(0xFFE6F1FB);
  static const _textPrimary   = Color(0xFF1B1E28);
  static const _textSecondary = Color(0xFF6B7280);
  static const _textMuted     = Color(0xFF9CA3AF);
  static const _borderColor   = Color(0xFFE5E7EB);
  static const _bgLight       = Color(0xFFF8F9FB);

  final _noteCtrl = TextEditingController();
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

  // ── Colors ────────────────────────────────────────────────────────────────
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

  // ── Send note ─────────────────────────────────────────────────────────────
  Future<void> _sendNote(IncidentVM vm) async {
    final note = _noteCtrl.text.trim();
    if (note.isEmpty) return;

    setState(() => _sendingNote = true);
    final ok = await vm.addNote(
      token: widget.token,
      id: widget.incidentId,
      note: note,
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

        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          child: SizedBox(
            width: 660,
            height: 560,
            child: inc == null
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      _buildHeader(inc),
                      const Divider(
                          height: 0.5,
                          thickness: 0.5,
                          color: _borderColor),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _detailGrid(inc),
                              const SizedBox(height: 14),
                              _divider(),
                              const SizedBox(height: 14),
                              _descriptionBlock(inc),
                              const SizedBox(height: 14),
                              _divider(),
                              const SizedBox(height: 14),
                              _activitySection(inc),
                            ],
                          ),
                        ),
                      ),
                      const Divider(
                          height: 0.5,
                          thickness: 0.5,
                          color: _borderColor),
                      _noteInput(vm, inc),
                    ],
                  ),
          ),
        );
      },
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(IncidentModel inc) {
    final sc = _statusColors(inc.status);
    final pc = _prioColors(inc.priority);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  inc.ticketNo,
                  style: const TextStyle(
                      fontSize: 11,
                      color: _textMuted,
                      fontFamily: 'monospace'),
                ),
                const SizedBox(height: 2),
                Text(
                  inc.subject,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _pill(inc.status, bg: sc.bg, fg: sc.fg),
          const SizedBox(width: 6),
          _pill(inc.priority, bg: pc.bg, fg: pc.fg),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.close,
                size: 18, color: _textSecondary),
            onPressed: () {
              context.read<IncidentVM>().clearSelected();
              Navigator.pop(context);
            },
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  // ── Detail grid ───────────────────────────────────────────────────────────
  Widget _detailGrid(IncidentModel inc) {
    final fields = [
      ('Category',     inc.category),
      ('Priority',     inc.priority),
      ('Reported by',  inc.user?.name ?? '—'),
      ('Assigned to',  inc.assignedUser?.name ?? 'Pending'),
      ('Submitted',    _formatDate(inc.createdAt)),
      ('Last updated', _formatDate(inc.updatedAt)),
    ];

    return Wrap(
      spacing: 20,
      runSpacing: 12,
      children: fields.map((f) {
        return SizedBox(
          width: 280,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(f.$1,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _textSecondary)),
              const SizedBox(height: 2),
              Text(f.$2,
                  style: const TextStyle(
                      fontSize: 13, color: _textPrimary)),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── Description (readonly) ────────────────────────────────────────────────
  Widget _descriptionBlock(IncidentModel inc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Description',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _textSecondary)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _bgLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _borderColor, width: 0.5),
          ),
          child: Text(
            inc.description,
            style: const TextStyle(
                fontSize: 13, color: _textPrimary, height: 1.6),
          ),
        ),
        // Attachment link if present
        if (inc.attachment != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.attach_file,
                  size: 14, color: _textSecondary),
              const SizedBox(width: 4),
              Text(
                inc.attachment!.split('/').last,
                style: const TextStyle(
                    fontSize: 12, color: _brandBlue),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // ── Activity timeline ─────────────────────────────────────────────────────
  Widget _activitySection(IncidentModel inc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Activity',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _textSecondary)),
        const SizedBox(height: 12),
        if (inc.logs.isEmpty)
          const Text('No activity yet.',
              style: TextStyle(fontSize: 12, color: _textMuted))
        else
          ...inc.logs.map((log) => _timelineItem(log, inc)),
      ],
    );
  }

  Widget _timelineItem(IncidentLog log, IncidentModel inc) {
    // Staff dot = brand blue, IT/admin dot = gray
    final isStaff = log.userId == inc.userId;
    final dotColor =
        isStaff ? _brandBlue : _textMuted;

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
                        fontSize: 12,
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
                      TextSpan(
                        text: log.description,
                      ),
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

  // ── Note input — only editable section for staff ──────────────────────────
  Widget _noteInput(IncidentVM vm, IncidentModel inc) {
    final isClosed =
        inc.status == 'Resolved' || inc.status == 'Closed';

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lock indicator
          Row(
            children: const [
              Icon(Icons.lock_outline, size: 12, color: _textMuted),
              SizedBox(width: 4),
              Text(
                'Notes only — form locked selepas submit',
                style: TextStyle(fontSize: 11, color: _textMuted),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _noteCtrl,
                  enabled: !isClosed,
                  maxLines: 2,
                  minLines: 1,
                  style: const TextStyle(
                      fontSize: 13, color: _textPrimary),
                  decoration: InputDecoration(
                    hintText: isClosed
                        ? 'Ticket dah closed — notes tidak boleh ditambah'
                        : 'Tambah nota atau maklumat tambahan...',
                    hintStyle: const TextStyle(
                        fontSize: 12, color: _textMuted),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                          color: _borderColor, width: 0.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                          color: _borderColor, width: 0.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                          color: _brandBlue, width: 1),
                    ),
                    filled: true,
                    fillColor:
                        isClosed ? _bgLight : Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 42,
                child: ElevatedButton(
                  onPressed: isClosed || _sendingNote
                      ? null
                      : () => _sendNote(vm),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandBlue,
                    disabledBackgroundColor:
                        _brandBlue.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14),
                  ),
                  child: _sendingNote
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white),
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
      child: Text(text,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: fg)),
    );
  }

  Widget _divider() =>
      const Divider(height: 0.5, thickness: 0.5, color: _borderColor);

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