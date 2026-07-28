import 'package:flutter/material.dart';

class StyledDialogs {
  static const _brandBlue = Color(0xFF185FA5);
  static const _brandBlueBg = Color(0xFFE6F1FB);
  static const _textPrimary = Color(0xFF1B1E28);
  static const _textMuted = Color(0xFF9CA3AF);
  static const _borderColor = Color(0xFFE5E7EB);
  static const _errorRed = Color(0xFFD92D20);

  static InputDecoration _fieldDecoration(String? hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: _textMuted),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _brandBlue, width: 1.5),
        ),
      );

  static Widget _shell({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget content,
    required Widget primaryAction,
  }) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: _brandBlueBg, borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, color: _brandBlue, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _textPrimary)),
                      Text(subtitle, style: const TextStyle(fontSize: 12, color: _textMuted)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 18, color: _textMuted),
                  splashRadius: 18,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: _borderColor, height: 1),
            const SizedBox(height: 16),
            content,
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(foregroundColor: _textPrimary),
                  child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),
                primaryAction,
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Future<String?> textPrompt(
    BuildContext context, {
    required String title,
    required String subtitle,
    IconData icon = Icons.edit_outlined,
    String? hint,
    String? initial,
    bool multiline = false,
  }) {
    final controller = TextEditingController(text: initial ?? '');
    return showDialog<String>(
      context: context,
      builder: (ctx) => _shell(
        context: ctx,
        icon: icon,
        title: title,
        subtitle: subtitle,
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: multiline ? 4 : 1,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _textPrimary),
          decoration: _fieldDecoration(hint),
        ),
        primaryAction: ElevatedButton(
          onPressed: () => Navigator.pop(ctx, controller.text),
          style: ElevatedButton.styleFrom(
            backgroundColor: _brandBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  static Future<Map<String, String>?> visionMissionPrompt(
    BuildContext context, {
    required String vision,
    required String mission,
  }) {
    final visionCtrl = TextEditingController(text: vision);
    final missionCtrl = TextEditingController(text: mission);
    return showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => _shell(
        context: ctx,
        icon: Icons.flag_rounded,
        title: 'Vision and mission',
        subtitle: 'Update the company vision and mission',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Vision', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textPrimary)),
            const SizedBox(height: 6),
            TextField(
              controller: visionCtrl,
              maxLines: 2,
              style: const TextStyle(fontSize: 14, color: _textPrimary),
              decoration: _fieldDecoration('Our vision...'),
            ),
            const SizedBox(height: 14),
            const Text('Mission', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textPrimary)),
            const SizedBox(height: 6),
            TextField(
              controller: missionCtrl,
              maxLines: 2,
              style: const TextStyle(fontSize: 14, color: _textPrimary),
              decoration: _fieldDecoration('Our mission...'),
            ),
          ],
        ),
        primaryAction: ElevatedButton(
          onPressed: () => Navigator.pop(ctx, {'vision': visionCtrl.text, 'mission': missionCtrl.text}),
          style: ElevatedButton.styleFrom(
            backgroundColor: _brandBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  static Future<bool?> confirmDelete(
    BuildContext context, {
    required String itemLabel,
    required String message,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 380,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: const Color(0xFFFDEDED), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.delete_outline_rounded, color: _errorRed, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Delete $itemLabel?',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textPrimary)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(message, style: const TextStyle(fontSize: 13, color: _textMuted, height: 1.5)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    style: TextButton.styleFrom(foregroundColor: _textPrimary),
                    child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _errorRed,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}