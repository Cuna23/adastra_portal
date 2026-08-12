import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../view model/comp_vm.dart';
import 'CompDialog.dart';
import 'CompTeam.dart';

class OrgChartContent extends StatefulWidget {
  final String role;
  final String token;
  const OrgChartContent({super.key, required this.role, required this.token});

  @override
  State<OrgChartContent> createState() => _OrgChartContentState();
}

class _OrgChartContentState extends State<OrgChartContent> {
  bool get _isAdminOrSuper => widget.role == 'admin' || widget.role == 'super_admin';
  bool get _isSuperAdmin => widget.role == 'super_admin';

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CompanyViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Teams & leadership ──
        Row(
          children: [
            const Expanded(
              child: Text('Teams and leadership', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1B1E28))),
            ),
            if (_isAdminOrSuper)
              ElevatedButton.icon(
                onPressed: vm.departments.isEmpty ? null : () => _addMember(vm),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Add member', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF185FA5),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        const Text('Tap a member to view their profile.', style: TextStyle(fontSize: 12, color: Color(0xFF9AA5B1))),
        const SizedBox(height: 14),

        if (vm.teamMembers.isEmpty)
          const Text('No team members added yet.', style: TextStyle(fontSize: 12, color: Color(0xFF9AA5B1)))
        else
          Column(
            children: _groupedByDepartment(vm.teamMembers).entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF9AA5B1), letterSpacing: 0.3),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: entry.value
                          .map((m) => TeamMemberAvatar(
                                member: m,
                                onTap: () => showTeamMemberBio(
                                  context,
                                  m,
                                  onEdit: _isAdminOrSuper ? () => _editMember(vm, m) : null,
                                  onDelete: _isAdminOrSuper ? () => _deleteMember(vm, m) : null,
                                  deleteEnabled: _isSuperAdmin,
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  // Group members by department name (preserve order — first appearance)
  Map<String, List<TeamMember>> _groupedByDepartment(List<TeamMember> members) {
    final Map<String, List<TeamMember>> grouped = {};
    for (final m in members) {
      grouped.putIfAbsent(m.departmentName, () => []).add(m);
    }
    return grouped;
  }

  // ── Team member actions (backend-driven) ──
  Future<void> _addMember(CompanyViewModel vm) async {
    final result = await showTeamMemberForm(context, departments: vm.departments);
    if (result == null) return;
    final ok = await vm.addTeamMember(result, widget.token);
    if (!mounted) return;
    _showSnack(ok ? 'Team member added.' : 'Failed to add member. Please try again.', success: ok);
  }

  Future<void> _editMember(CompanyViewModel vm, TeamMember m) async {
    final result = await showTeamMemberForm(context, departments: vm.departments, existing: m);
    if (result == null) return;
    final ok = await vm.editTeamMember(m.id, result, widget.token);
    if (!mounted) return;
    _showSnack(ok ? 'Team member updated.' : 'Update failed. Please try again.', success: ok);
  }

  Future<void> _deleteMember(CompanyViewModel vm, TeamMember m) async {
    final confirmed = await StyledDialogs.confirmDelete(context, itemLabel: m.name, message: 'This will remove ${m.name} from the team list.');
    if (confirmed != true || !mounted) return;
    final ok = await vm.removeTeamMember(m.id, widget.token);
    if (!mounted) return;
    _showSnack(ok ? 'Deleted successfully.' : 'Delete failed. Please try again.', success: ok);
  }

  void _showSnack(String message, {required bool success}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: success ? const Color(0xFF2E7D52) : const Color(0xFFD64545), behavior: SnackBarBehavior.floating),
    );
  }
}