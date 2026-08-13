import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// ── Model (backend-driven, department-based) ──
class TeamMember {
  final int id;
  final String name;
  final String position;
  final int departmentId;
  final String departmentName;
  final String background;
  final String? photoPath;
  final int sortOrder;

  TeamMember({
    required this.id,
    required this.name,
    required this.position,
    required this.departmentId,
    required this.departmentName,
    required this.background,
    this.photoPath,
    this.sortOrder = 0,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      id: json['id'],
      name: json['name'],
      position: json['position'],
      departmentId: json['department_id'],
      departmentName: json['department_name'] ?? 'Unknown',
      background: json['background'] ?? '',
      photoPath: json['photo_path'],
      sortOrder: json['sort_order'] ?? 0,
    );
  }

  String? get photoUrl => photoPath;

  Color get color => _palette[name.hashCode.abs() % _palette.length].$1;
  Color get bg => _palette[name.hashCode.abs() % _palette.length].$2;

  static const _palette = [
    (Color(0xFF185FA5), Color(0xFFE6F1FB)),
    (Color(0xFF0F6E56), Color(0xFFE1F5EE)),
    (Color(0xFF854F0B), Color(0xFFFAEEDA)),
    (Color(0xFF4F46E5), Color(0xFFEEF2FF)),
  ];
}

// ── Department (untuk dropdown, dari /departments endpoint) ──
class DepartmentOption {
  final int id;
  final String name;

  DepartmentOption({required this.id, required this.name});

  factory DepartmentOption.fromJson(Map<String, dynamic> json) {
    return DepartmentOption(id: json['id'], name: json['department_name']);
  }
}

// ── Avatar ──
class TeamMemberAvatar extends StatelessWidget {
  final TeamMember member;
  final VoidCallback onTap;

  const TeamMemberAvatar({
    super.key,
    required this.member,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: member.bg,
              backgroundImage: member.photoUrl != null ? NetworkImage(member.photoUrl!) : null,
              child: member.photoUrl == null ? Icon(Icons.person_rounded, size: 24, color: member.color) : null,
            ),
            const SizedBox(height: 6),
            Text(member.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1B1E28))),
            Text(member.position, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, color: Color(0xFF9AA5B1))),
          ],
        ),
      ),
    );
  }
}

// ── Bio popup ──
void showTeamMemberBio(
  BuildContext context,
  TeamMember m, {
  VoidCallback? onEdit,
  VoidCallback? onDelete,
  bool deleteEnabled = true,
}) {
  final showActionsRow = onEdit != null || (onDelete != null && deleteEnabled);

  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: m.bg,
                    backgroundImage: m.photoUrl != null ? NetworkImage(m.photoUrl!) : null,
                    child: m.photoUrl == null ? Icon(Icons.person_rounded, size: 26, color: m.color) : null,
                  ),
                  const SizedBox(height: 12),
                  Text(m.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1B1E28))),
                  Text(m.position, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: m.color)),
                  const SizedBox(height: 4),
                  Text(m.departmentName, style: const TextStyle(fontSize: 11, color: Color(0xFF9AA5B1))),
                  const SizedBox(height: 10),
                  Text(
                    m.background.isNotEmpty ? m.background : 'No background info yet.',
                    style: const TextStyle(fontSize: 13, height: 1.6, color: Color(0xFF4B5563)),
                  ),
                  if (showActionsRow) ...[
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        if (onEdit != null)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(ctx);
                                onEdit();
                              },
                              icon: const Icon(Icons.edit_outlined, size: 15, color: Color(0xFF185FA5)),
                              label: const Text('Edit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF185FA5))),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFCBD5E1)),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        if (onEdit != null && onDelete != null && deleteEnabled) const SizedBox(width: 8),
                        if (onDelete != null && deleteEnabled)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(ctx);
                                onDelete();
                              },
                              icon: const Icon(Icons.delete_outline, size: 15, color: Color(0xFFD92D20)),
                              label: const Text('Delete', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFD92D20))),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFF0B4B4)),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF185FA5),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
              Positioned(
                top: -4,
                right: -4,
                child: IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close, size: 18, color: Color(0xFF9CA3AF)),
                  splashRadius: 16,
                  tooltip: 'Close',
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// ── Add/Edit form result ──
class TeamMemberFormResult {
  final String name;
  final String position;
  final int departmentId;
  final String background;
  final XFile? photo;

  TeamMemberFormResult({
    required this.name,
    required this.position,
    required this.departmentId,
    required this.background,
    this.photo,
  });
}

// ── Add / Edit form dialog ──
// departments: list DepartmentOption dari API (kena dah fetch sebelum panggil dialog ni)
Future<TeamMemberFormResult?> showTeamMemberForm(
  BuildContext context, {
  required List<DepartmentOption> departments,
  TeamMember? existing,
}) {
  final nameCtrl = TextEditingController(text: existing?.name ?? '');
  final positionCtrl = TextEditingController(text: existing?.position ?? '');
  final bgCtrl = TextEditingController(text: existing?.background ?? '');
  int? selectedDeptId = existing?.departmentId ?? (departments.isNotEmpty ? departments.first.id : null);
  XFile? photo;

  return showDialog<TeamMemberFormResult>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 420,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(existing == null ? 'Add team member' : 'Edit team member',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1B1E28))),
                const Text('Fill in the member\'s details', style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                const SizedBox(height: 18),

                const Text('Photo (optional)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1B1E28))),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final picker = ImagePicker();
                    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
                    if (picked != null) setDialogState(() => photo = picked);
                  },
                  borderRadius: BorderRadius.circular(32),
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: const Color(0xFFF9FAFB),
                    backgroundImage: photo != null
                        ? NetworkImage(photo!.path)
                        : (existing?.photoUrl != null ? NetworkImage(existing!.photoUrl!) : null),
                    child: (photo == null && existing?.photoUrl == null)
                        ? const Icon(Icons.add_a_photo_outlined, color: Color(0xFF9CA3AF))
                        : null,
                  ),
                ),
                const SizedBox(height: 16),

                const Text('Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1B1E28))),
                const SizedBox(height: 6),
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF1B1E28)),
                  decoration: _decoration('e.g. Ahmad Zaki'),
                ),
                const SizedBox(height: 14),

                const Text('Position', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1B1E28))),
                const SizedBox(height: 6),
                TextField(
                  controller: positionCtrl,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF1B1E28)),
                  decoration: _decoration('e.g. Managing Director'),
                ),
                const SizedBox(height: 14),

                const Text('Department', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1B1E28))),
                const SizedBox(height: 6),
                DropdownButtonFormField<int>(
                  value: selectedDeptId,
                  dropdownColor: Colors.white,
                  decoration: _decoration(null),
                  style: const TextStyle(fontSize: 13, color: Color(0xFF1B1E28)),
                  items: departments
                      .map((d) => DropdownMenuItem(
                            value: d.id,
                            child: Text(d.name, style: const TextStyle(fontSize: 13, color: Color(0xFF1B1E28))),
                          ))
                      .toList(),
                  onChanged: (val) => setDialogState(() => selectedDeptId = val),
                ),
                const SizedBox(height: 14),

                const Text('Background', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1B1E28))),
                const SizedBox(height: 6),
                TextField(
                  controller: bgCtrl,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF1B1E28)),
                  decoration: _decoration('Short bio or background...'),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (nameCtrl.text.trim().isEmpty ||
                            positionCtrl.text.trim().isEmpty ||
                            selectedDeptId == null) return;
                        Navigator.pop(
                          ctx,
                          TeamMemberFormResult(
                            name: nameCtrl.text.trim(),
                            position: positionCtrl.text.trim(),
                            departmentId: selectedDeptId!,
                            background: bgCtrl.text.trim(),
                            photo: photo,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF185FA5),
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
      ),
    ),
  );
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