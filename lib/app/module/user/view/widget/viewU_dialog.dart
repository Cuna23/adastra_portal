import 'package:flutter/material.dart';
import '../../model/user_model.dart';
 
class ViewUDialog extends StatelessWidget {
  final UserModel user;
 
  const ViewUDialog({super.key, required this.user});
 
  static const _brandBlue     = Color(0xFF185FA5);
  static const _brandBlueBg   = Color(0xFFE6F1FB);
  static const _textPrimary   = Color(0xFF1B1E28);
  static const _textMuted     = Color(0xFF9CA3AF);
  static const _borderColor   = Color(0xFFE5E7EB);
  static const _activeGreen   = Color(0xFF3B6D11);
  static const _activeGreenBg = Color(0xFFEAF3DE);
  static const _inactiveGray  = Color(0xFF5F5E5A);
  static const _inactiveGrayBg = Color(0xFFF1EFE8);
 
  String _roleLabel(String r) {
    switch (r) {
      case 'super_admin':
        return 'Super Admin';
      case 'admin':
        return 'Admin';
      default:
        return 'Staff';
    }
  }
 
  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
 
  // ── Readonly field box — mirrors editU_dialog's TextFormField look ───────
  Widget _readonlyField(String label, String? value, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _borderColor, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: _textMuted),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: _textMuted)),
                const SizedBox(height: 2),
                Text(
                  (value == null || value.trim().isEmpty) ? '—' : value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: _textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
 
  // ── Field box with pill value (role/status) ───────────────────────────────
  Widget _pillField(String label, String text,
      {required Color bg, required Color fg, IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _borderColor, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: _textMuted),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: _textMuted)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    text,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
 
  Widget _fieldRow(BuildContext context, Widget a, Widget b) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 480) {
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
 
  @override
  Widget build(BuildContext context) {
    final isActive = user.status == 'active';
 
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: _brandBlueBg,
                    child: Text(
                      _initials(user.name),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _brandBlue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('User Detail',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: _textPrimary)),
                        Text(user.name,
                            style: const TextStyle(fontSize: 12, color: _textMuted),
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: _textMuted),
                    onPressed: () => Navigator.pop(context),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
 
              const SizedBox(height: 24),
 
              // Full Name + Email
              _readonlyField('Full Name', user.name, icon: Icons.person_outline),
              const SizedBox(height: 14),
              _readonlyField('Email Address', user.email, icon: Icons.email_outlined),
              const SizedBox(height: 14),
 
              // Role + Status
              _fieldRow(
                context,
                _pillField('Role', _roleLabel(user.role),
                    bg: _brandBlueBg, fg: _brandBlue, icon: Icons.badge_outlined),
                _pillField(
                  'Status',
                  isActive ? 'Active' : 'Inactive',
                  bg: isActive ? _activeGreenBg : _inactiveGrayBg,
                  fg: isActive ? _activeGreen : _inactiveGray,
                  icon: Icons.toggle_on_outlined,
                ),
              ),
              const SizedBox(height: 14),
 
              // Department — full width
              _readonlyField('Department', user.departmentName,
                  icon: Icons.apartment_outlined),
 
              const SizedBox(height: 24),
 
              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}