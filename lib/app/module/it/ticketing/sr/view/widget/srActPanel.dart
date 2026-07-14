import 'package:flutter/material.dart';
import '../../model/sr_model.dart';
import '../../view model/sr_vm.dart';

class SRActivityPanel extends StatefulWidget {
  final String token;
  final ServiceRequestModel sr;
  final ServiceRequestViewModel vm;
  final int currentUserId;

  const SRActivityPanel({
    super.key,
    required this.token,
    required this.sr,
    required this.vm,
    required this.currentUserId,
  });

  @override
  State<SRActivityPanel> createState() => _SRActivityPanelState();
}

class _SRActivityPanelState extends State<SRActivityPanel> {
  static const _brandBlue     = Color(0xFF185FA5);
  static const _textPrimary   = Color(0xFF1B1E28);
  static const _textSecondary = Color(0xFF6B7280);
  static const _textMuted     = Color(0xFF9CA3AF);
  static const _borderColor   = Color(0xFFE5E7EB);
  static const _bgLight       = Color(0xFFF9FAFB);

  static const _ownBubbleBg     = Color(0xFFE6F0FA);
  static const _ownBubbleText   = Color(0xFF1E3A8A);
  static const _otherBubbleBg   = Color(0xFFE4E6EA);
  static const _otherBubbleText = Color(0xFF1F2937);

  final _noteCtrl       = TextEditingController();
  final _activityScroll = ScrollController();
  bool  _sendingNote    = false;

  @override
  void dispose() {
    _noteCtrl.dispose();
    _activityScroll.dispose();
    super.dispose();
  }

  Future<void> _sendNote() async {
    final note = _noteCtrl.text.trim();
    if (note.isEmpty) return;
    setState(() => _sendingNote = true);
    final ok = await widget.vm.addNote(widget.token, widget.sr.id, note);
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
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.vm.error ?? 'Failed to send note')),
      );
    }
    if (mounted) setState(() => _sendingNote = false);
  }

  bool _isSystemLog(ServiceRequestLogModel log) => log.action != 'Note';

  @override
  Widget build(BuildContext context) {
    final sr = widget.sr;
    final isClosed = sr.status == 'approved' || sr.status == 'rejected';

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
          Row(
            children: [
              const Icon(Icons.forum_outlined, size: 16, color: _textSecondary),
              const SizedBox(width: 8),
              const Text('Activity',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textSecondary)),
              const Spacer(),
              Text(
                '${sr.logs.length} ${sr.logs.length == 1 ? 'entry' : 'entries'}',
                style: const TextStyle(fontSize: 11, color: _textMuted),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 0.5, thickness: 0.5, color: _borderColor),
          const SizedBox(height: 12),

          Expanded(
            child: sr.logs.isEmpty
                ? const Center(
                    child: Text('No activity yet.', style: TextStyle(fontSize: 13, color: _textMuted)))
                : ListView.builder(
                    controller: _activityScroll,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: sr.logs.length,
                    itemBuilder: (_, i) => _logEntry(sr.logs[i]),
                  ),
          ),

          const SizedBox(height: 12),
          const Divider(height: 0.5, thickness: 0.5, color: _borderColor),
          const SizedBox(height: 12),

          LayoutBuilder(
            builder: (context, constraints) {
              final field = TextField(
                controller: _noteCtrl,
                enabled: !isClosed,
                maxLines: 3,
                minLines: 1,
                style: const TextStyle(fontSize: 13, color: _textPrimary),
                decoration: InputDecoration(
                  labelText: isClosed ? 'Request closed — no more notes' : 'Add a note...',
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
              );

              final sendBtn = SizedBox(
                height: 48,
                width: constraints.maxWidth < 360 ? double.infinity : null,
                child: ElevatedButton(
                  onPressed: isClosed || _sendingNote ? null : _sendNote,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandBlue,
                    disabledBackgroundColor: _ownBubbleText.withOpacity(0.4),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: _sendingNote
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : (constraints.maxWidth < 360
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.send, size: 16, color: Colors.white),
                                SizedBox(width: 6),
                                Text('Send', style: TextStyle(color: Colors.white, fontSize: 13)),
                              ],
                            )
                          : const Icon(Icons.send, size: 16, color: Colors.white)),
                ),
              );

              if (constraints.maxWidth < 360) {
                return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [field, const SizedBox(height: 10), sendBtn]);
              }

              return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [Expanded(child: field), const SizedBox(width: 10), sendBtn]);
            },
          ),
        ],
      ),
    );
  }

  Widget _logEntry(ServiceRequestLogModel log) {
    if (_isSystemLog(log)) return _systemBanner(log);
    return _noteBubble(log);
  }

  Widget _systemBanner(ServiceRequestLogModel log) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Expanded(child: Divider(thickness: 0.5, color: _borderColor)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(log.description, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: _textPrimary)),
                const SizedBox(width: 4),
                Text('· ${_formatTime(log.createdAt)}', style: const TextStyle(fontSize: 10, color: _textSecondary)),
              ],
            ),
          ),
          const Expanded(child: Divider(thickness: 0.5, color: _borderColor)),
        ],
      ),
    );
  }

  Widget _noteBubble(ServiceRequestLogModel log) {
    final isMine = log.userId == widget.currentUserId;
    final bubbleBg = isMine ? _ownBubbleBg : _otherBubbleBg;
    final bubbleText = isMine ? _ownBubbleText : _otherBubbleText;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxBubbleWidth = constraints.maxWidth * 0.78;
          return Row(
            mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Container(
                  constraints: BoxConstraints(maxWidth: maxBubbleWidth),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: bubbleBg,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft: Radius.circular(isMine ? 12 : 2),
                      bottomRight: Radius.circular(isMine ? 2 : 12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isMine && log.userName != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(log.userName!,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: bubbleText.withOpacity(0.8))),
                        ),
                      Text(log.description, style: TextStyle(fontSize: 13, color: bubbleText, height: 1.4)),
                      const SizedBox(height: 3),
                      Text(_formatTime(log.createdAt), style: TextStyle(fontSize: 10, color: bubbleText.withOpacity(0.55))),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}