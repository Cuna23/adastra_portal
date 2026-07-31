import 'package:flutter/material.dart';
import '../../model/calendar_model.dart';

class ReminderDialogs {
  static const _brand = Color(0xFF185FA5);

  // Tambah reminder untuk tarikh yang dipilih
  static Future<Map<String, String>?> addReminderForm(BuildContext context, DateTime date) {
    final titleCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    return showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 380,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add reminder', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1B1E28))),
              Text('${date.day}/${date.month}/${date.year}', style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
              const SizedBox(height: 16),
              const Text('Title', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: titleCtrl,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1B1E28)),
                decoration: _decoration('e.g. Submit report'),
              ),
              const SizedBox(height: 14),
              const Text('Note (optional)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: noteCtrl,
                maxLines: 2,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1B1E28)),
                decoration: _decoration('Additional details...'),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (titleCtrl.text.trim().isEmpty) return;
                      Navigator.pop(ctx, {'title': titleCtrl.text.trim(), 'note': noteCtrl.text.trim()});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _brand,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Senarai event untuk satu tarikh (tap tarikh yang ada dot)
  static void showDayEvents(BuildContext context, DateTime date, List<CalendarEvent> events, {required Future<void> Function(int id) onDeleteReminder}) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 380,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${date.day}/${date.month}/${date.year}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1B1E28))),
              const SizedBox(height: 12),
              ...events.map((e) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: e.type == 'deadline' ? (e.overdue ? const Color(0xFFFDECEC) : const Color(0xFFE6F1FB)) : const Color(0xFFF4F7FC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(e.type == 'deadline' ? Icons.assignment_outlined : Icons.notifications_outlined,
                            size: 16, color: e.type == 'deadline' ? (e.overdue ? const Color(0xFFD64545) : _brand) : const Color(0xFF6B7280)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1B1E28))),
                              if (e.subtitle != null && e.subtitle!.isNotEmpty)
                                Text(e.subtitle!, style: const TextStyle(fontSize: 10, color: Color(0xFF9AA5B1))),
                            ],
                          ),
                        ),
                        if (e.type == 'reminder')
                          IconButton(
                            onPressed: () async {
                              await onDeleteReminder(e.id);
                              if (ctx.mounted) Navigator.pop(ctx);
                            },
                            icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFD64545)),
                            splashRadius: 16,
                          ),
                      ],
                    ),
                  )),
              Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))),
            ],
          ),
        ),
      ),
    );
  }
}

InputDecoration _decoration(String? hint) => InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF185FA5), width: 1.5)),
    );