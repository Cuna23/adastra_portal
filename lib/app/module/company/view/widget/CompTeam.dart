import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// ── Team categories ──
enum TeamCategory {
  director('Director'),
  trademark('Trademark team'),
  patent('Patent team'),
  valuation('Valuation'),
  businessDev('Business development'),
  commercialization('Commercialization team'),
  finance('Finance');

  final String label;
  const TeamCategory(this.label);
}

// ── Local model (session only — belum ada backend) ──
class TeamMember {
  final String id; // local id (timestamp string)
  final String name;
  final String position;
  final TeamCategory team;
  final String background;
  final XFile? photo; // local preview je, belum upload
  final Color color;
  final Color bg;

  TeamMember({
    required this.id,
    required this.name,
    required this.position,
    required this.team,
    required this.background,
    this.photo,
    required this.color,
    required this.bg,
  });

  TeamMember copyWith({
    String? name,
    String? position,
    TeamCategory? team,
    String? background,
    XFile? photo,
  }) {
    return TeamMember(
      id: id,
      name: name ?? this.name,
      position: position ?? this.position,
      team: team ?? this.team,
      background: background ?? this.background,
      photo: photo ?? this.photo,
      color: color,
      bg: bg,
    );
  }
}

// [HARDCODED] — TODO: ganti dengan fetch API bila backend `team_members` siap
List<TeamMember> hardcodedTeamMembers() => [
      TeamMember(
        id: '1',
        name: 'Ahmad Zaki',
        position: 'Managing Director',
        team: TeamCategory.director,
        background: 'Leads overall strategy and operations for Adastra IP.',
        color: const Color(0xFF185FA5),
        bg: const Color(0xFFE6F1FB),
      ),
      TeamMember(
        id: '2',
        name: 'Sarah Lim',
        position: 'Head of Trademark',
        team: TeamCategory.trademark,
        background: 'Oversees the trademark practice group and client relations.',
        color: const Color(0xFF0F6E56),
        bg: const Color(0xFFE1F5EE),
      ),
      TeamMember(
        id: '3',
        name: 'Rajesh Kumar',
        position: 'Head of Patent',
        team: TeamCategory.patent,
        background: 'Heads the patent practice group.',
        color: const Color(0xFF854F0B),
        bg: const Color(0xFFFAEEDA),
      ),
    ];

// ── Avatar (tap-only now — no more external kebab menu / "Show menu" tooltip) ──
// [CHANGED] Removed onEdit/onDelete/deleteEnabled + the CompMenu Positioned overlay.
// Edit/Delete now live inside the bio popup instead (see showTeamMemberBio below).
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
              backgroundImage: member.photo != null ? NetworkImage(member.photo!.path) : null,
              child: member.photo == null ? Icon(Icons.person_rounded, size: 24, color: member.color) : null,
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
// [CHANGED] Now accepts onEdit/onDelete/deleteEnabled to render Edit/Delete
// buttons INSIDE the dialog (was previously an external 3-dot menu on the avatar).
// [CHANGED] Added a close "X" icon top-right (Stack + Positioned).
// [CHANGED] Bottom "Close" button is now a filled blue button, same style as "Add User".
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
                  const SizedBox(height: 12), // room for the close X above
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: m.bg,
                    backgroundImage: m.photo != null ? NetworkImage(m.photo!.path) : null,
                    child: m.photo == null ? Icon(Icons.person_rounded, size: 26, color: m.color) : null,
                  ),
                  const SizedBox(height: 12),
                  Text(m.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1B1E28))),
                  Text(m.position, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: m.color)),
                  const SizedBox(height: 4),
                  Text(m.team.label, style: const TextStyle(fontSize: 11, color: Color(0xFF9AA5B1))),
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

// ── Add / Edit form dialog ──
Future<TeamMember?> showTeamMemberForm(BuildContext context, {TeamMember? existing}) {
  final nameCtrl = TextEditingController(text: existing?.name ?? '');
  final positionCtrl = TextEditingController(text: existing?.position ?? '');
  final bgCtrl = TextEditingController(text: existing?.background ?? '');
  TeamCategory selectedTeam = existing?.team ?? TeamCategory.director;
  XFile? photo = existing?.photo;

  return showDialog<TeamMember>(
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

                const Text('Photo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1B1E28))),
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
                    backgroundImage: photo != null ? NetworkImage(photo!.path) : null,
                    child: photo == null ? const Icon(Icons.add_a_photo_outlined, color: Color(0xFF9CA3AF)) : null,
                  ),
                ),
                const SizedBox(height: 16),

                const Text('Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1B1E28))),
                const SizedBox(height: 6),
                // [CHANGED] added explicit style: darker text color instead of default grey
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

                const Text('Team', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1B1E28))),
                const SizedBox(height: 6),
                DropdownButtonFormField<TeamCategory>(
                  value: selectedTeam,
                  dropdownColor: Colors.white,
                  decoration: _decoration(null),
                  style: const TextStyle(fontSize: 13, color: Color(0xFF1B1E28)),
                  items: TeamCategory.values
                      .map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(t.label, style: const TextStyle(fontSize: 13, color: Color(0xFF1B1E28))),
                          ))
                      .toList(),
                  onChanged: (val) => setDialogState(() => selectedTeam = val ?? selectedTeam),
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
                        if (nameCtrl.text.trim().isEmpty || positionCtrl.text.trim().isEmpty) return;
                        final colors = [
                          (const Color(0xFF185FA5), const Color(0xFFE6F1FB)),
                          (const Color(0xFF0F6E56), const Color(0xFFE1F5EE)),
                          (const Color(0xFF854F0B), const Color(0xFFFAEEDA)),
                          (const Color(0xFF4F46E5), const Color(0xFFEEF2FF)),
                        ];
                        final palette = colors[nameCtrl.text.hashCode.abs() % colors.length];
                        Navigator.pop(
                          ctx,
                          TeamMember(
                            id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                            name: nameCtrl.text.trim(),
                            position: positionCtrl.text.trim(),
                            team: selectedTeam,
                            background: bgCtrl.text.trim(),
                            photo: photo,
                            color: existing?.color ?? palette.$1,
                            bg: existing?.bg ?? palette.$2,
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