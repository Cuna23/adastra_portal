import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/incident_model.dart';
import '../../view model/incident_vm.dart';

class IncActivityPanel extends StatefulWidget {
  final String token;
  final IncidentModel inc;
  final IncidentVM vm;

  const IncActivityPanel({
    super.key,
    required this.token,
    required this.inc,
    required this.vm,
  });

  @override
  State<IncActivityPanel> createState() => _IncActivityPanelState();
}

class _IncActivityPanelState extends State<IncActivityPanel> {
  static const _brandBlue      = Color(0xFF185FA5);
  static const _brandBlueBg    = Color(0xFFE6F1FB);
  static const _textPrimary    = Color(0xFF1B1E28);
  static const _textSecondary  = Color(0xFF6B7280);
  static const _textMuted      = Color(0xFF9CA3AF);
  static const _borderColor    = Color(0xFFE5E7EB);
  static const _bgLight        = Color(0xFFF9FAFB);

  final _noteCtrl       = TextEditingController();
  final _activityScroll = ScrollController();
  bool  _sendingNote    = false;
  int?  _editingLogId;
  int?  _savingLogId;
  final Map<int, TextEditingController> _editCtrl = {};

  @override
  void dispose() {
    _noteCtrl.dispose();
    _activityScroll.dispose();
    for (final c in _editCtrl.values) c.dispose();
    super.dispose();
  }

  Future<void> _sendNote() async {
    final note = _noteCtrl.text.trim();
    if (note.isEmpty) return;
    setState(() => _sendingNote = true);
    final ok = await widget.vm.addNote(
      token: widget.token,
      id:    widget.inc.id,
      note:  note,
    );
    if (ok && mounted) {
      _noteCtrl.clear();
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
    final inc      = widget.inc;
    final isClosed = inc.status == 'Resolved' || inc.status == 'Closed';

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

          // Header
          Row(
            children: [
              const Icon(Icons.timeline_outlined, size: 16, color: _textSecondary),
              const SizedBox(width: 8),
              const Text('Activity',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600, color: _textSecondary)),
              const Spacer(),
              Text(
                '${inc.logs.length} ${inc.logs.length == 1 ? 'entry' : 'entries'}',
                style: const TextStyle(fontSize: 11, color: _textMuted),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 0.5, thickness: 0.5, color: _borderColor),
          const SizedBox(height: 12),

          // Log list
          Expanded(
            child: inc.logs.isEmpty
                ? const Center(
                    child: Text('No activity yet.',
                        style: TextStyle(fontSize: 13, color: _textMuted)))
                : ListView.builder(
                    controller: _activityScroll,
                    itemCount: inc.logs.length,
                    itemBuilder: (_, i) => _timelineItem(inc.logs[i]),
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
                  style: const TextStyle(fontSize: 13, color: _textPrimary),
                  decoration: InputDecoration(
                    labelText: isClosed
                        ? 'Ticket closed — no more notes'
                        : 'Add a note or additional information...',
                    labelStyle: const TextStyle(fontSize: 12, color: _textMuted),
                    prefixIcon: const Icon(Icons.notes_outlined, size: 16, color: _textMuted),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: isClosed || _sendingNote ? null : _sendNote,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandBlue,
                    disabledBackgroundColor: _brandBlue.withOpacity(0.4),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: _sendingNote
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Timeline item ─────────────────────────────────────────────────────────

  Widget _timelineItem(IncidentLog log) {
    final inc       = widget.inc;
    final isOwnNote = log.userId == inc.userId && log.action == 'Note';
    final isEditing = _editingLogId == log.id;
    final dotColor  = log.userId == inc.userId ? _brandBlue : _textMuted;

    if (isOwnNote && !_editCtrl.containsKey(log.id)) {
      _editCtrl[log.id] = TextEditingController(text: log.description);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(children: [
            const SizedBox(height: 5),
            Container(
              width: 7, height: 7,
              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
          ]),
          const SizedBox(width: 10),
          Expanded(
            child: isEditing
                ? _buildEditMode(log)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                    fontSize: 13, color: _textSecondary, height: 1.5),
                                children: [
                                  if (log.user != null)
                                    TextSpan(
                                      text: '${log.user!.name}: ',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600, color: _textPrimary),
                                    ),
                                  TextSpan(text: log.description),
                                ],
                              ),
                            ),
                          ),
                          if (isOwnNote)
                            SizedBox(
                              width: 28, height: 28,
                              child: PopupMenuButton<String>(
                                color: const Color(0xFFF8FAFC),
                                icon: const Icon(Icons.more_vert, size: 16, color: _textMuted),
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                elevation: 2,
                                onSelected: (val) {
                                  if (val == 'edit') {
                                    _editCtrl[log.id]?.text = log.description;
                                    setState(() => _editingLogId = log.id);
                                  } else if (val == 'delete') {
                                    _confirmDelete(log);
                                  }
                                },
                                itemBuilder: (_) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    height: 38,
                                    child: Row(children: [
                                      Icon(Icons.edit_outlined, size: 15, color: _textSecondary),
                                      SizedBox(width: 8),
                                      Text('Edit', style: TextStyle(fontSize: 13, color: _textPrimary)),
                                    ]),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    height: 38,
                                    child: Row(children: [
                                      Icon(Icons.delete_outline, size: 15, color: Color(0xFFA32D2D)),
                                      SizedBox(width: 8),
                                      Text('Delete', style: TextStyle(fontSize: 13, color: Color(0xFFA32D2D))),
                                    ]),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(_formatDate(log.createdAt),
                          style: const TextStyle(fontSize: 11, color: _textMuted)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ── Edit mode ─────────────────────────────────────────────────────────────

  Widget _buildEditMode(IncidentLog log) {
    final ctrl     = _editCtrl[log.id]!;
    final isSaving = _savingLogId == log.id;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _bgLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _brandBlue, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
                color: _brandBlueBg, borderRadius: BorderRadius.circular(6)),
            child: const Text('Editing',
                style: TextStyle(
                    fontSize: 11, color: _brandBlue, fontWeight: FontWeight.w600)),
          ),
          TextField(
            controller: ctrl,
            maxLines: 3,
            minLines: 1,
            autofocus: true,
            style: const TextStyle(fontSize: 13, color: _textPrimary),
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _borderColor)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _brandBlue, width: 0.5)),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: isSaving ? null : () => setState(() => _editingLogId = null),
                style: TextButton.styleFrom(
                  foregroundColor: _textSecondary,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Cancel', style: TextStyle(fontSize: 13)),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 34,
                child: ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final newNote = ctrl.text.trim();
                          if (newNote.isEmpty) return;
                          setState(() => _savingLogId = log.id);
                          final ok = await widget.vm.updateNote(
                            token:      widget.token,
                            incidentId: widget.inc.id,
                            logId:      log.id,
                            note:       newNote,
                          );
                          if (mounted) {
                            setState(() {
                              _savingLogId = null;
                              if (ok) _editingLogId = null;
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandBlue,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 14, height: 14,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Save',
                          style: TextStyle(fontSize: 13, color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Confirm delete ────────────────────────────────────────────────────────

  void _confirmDelete(IncidentLog log) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFF8FAFC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Delete note?',
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600, color: _textPrimary)),
        content: const Text('This note will be permanently removed.',
            style: TextStyle(fontSize: 13, color: _textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: _textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await widget.vm.deleteNote(
                token:      widget.token,
                incidentId: widget.inc.id,
                logId:      log.id,
              );
            },
            child: const Text('Delete',
                style: TextStyle(color: Color(0xFFA32D2D))),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '${dt.day} ${months[dt.month]} ${dt.year} · $h:$m';
    } catch (_) { return iso; }
  }
}