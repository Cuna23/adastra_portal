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
        const SizedBox(height: 20),

        if (vm.teamMembers.isEmpty)
          const Text('No team members added yet.', style: TextStyle(fontSize: 12, color: Color(0xFF9AA5B1)))
        else
          Center(child: _buildOrgTree(vm)),
      ],
    );
  }

  // ── Tree: root (Director/s) → connector → department cards ──
  Widget _buildOrgTree(CompanyViewModel vm) {
    final roots = _rootMembers(vm.teamMembers);
    final grouped = _groupedByDepartment(vm.teamMembers);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Root row (Director/s) — full-size avatar with photo
        if (roots.isNotEmpty) ...[
          Wrap(
            spacing: 16,
            alignment: WrapAlignment.center,
            children: roots.map((m) => TeamMemberAvatar(member: m, onTap: () => _openBio(vm, m))).toList(),
          ),
          if (grouped.isNotEmpty) ...[
            Container(width: 1, height: 20, color: const Color(0xFFE5E7EB)),
            Container(
              constraints: const BoxConstraints(maxWidth: 900),
              height: 1,
              color: const Color(0xFFE5E7EB),
            ),
          ],
        ],

        if (grouped.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 0),
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: grouped.entries.map((entry) => _buildDeptCard(vm, entry.key, entry.value)).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildDeptCard(CompanyViewModel vm, String deptName, List<TeamMember> members) {
    return Column(
      children: [
        Container(width: 1, height: 16, color: const Color(0xFFE5E7EB)),
        Container(
          width: 160,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                deptName,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF9AA5B1), letterSpacing: 0.3),
              ),
              const SizedBox(height: 10),
              Column(
                children: members.map((m) => _CompactMemberRow(member: m, onTap: () => _openBio(vm, m))).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openBio(CompanyViewModel vm, TeamMember m) {
    showTeamMemberBio(
      context,
      m,
      onEdit: _isAdminOrSuper ? () => _editMember(vm, m) : null,
      onDelete: _isAdminOrSuper ? () => _deleteMember(vm, m) : null,
      deleteEnabled: _isSuperAdmin,
    );
  }

  // Director check by position title (case-insensitive substring match)
  bool _isDirector(TeamMember m) => m.position.toLowerCase().contains('director');

  List<TeamMember> _rootMembers(List<TeamMember> members) => members.where(_isDirector).toList();

  // Group non-director members by department, sorted alphabetically
  Map<String, List<TeamMember>> _groupedByDepartment(List<TeamMember> members) {
    final Map<String, List<TeamMember>> grouped = {};
    for (final m in members) {
      if (_isDirector(m)) continue;
      grouped.putIfAbsent(m.departmentName, () => []).add(m);
    }
    final sortedKeys = grouped.keys.toList()..sort();
    return {for (final k in sortedKeys) k: grouped[k]!};
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

// ── Compact member row for department cards (photo + name, tighter than TeamMemberAvatar) ──
class _CompactMemberRow extends StatelessWidget {
  final TeamMember member;
  final VoidCallback onTap;

  const _CompactMemberRow({required this.member, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            CircleAvatar(
              radius: 13,
              backgroundColor: member.bg,
              backgroundImage: member.photoUrl != null ? NetworkImage(member.photoUrl!) : null,
              child: member.photoUrl == null ? Icon(Icons.person_rounded, size: 13, color: member.color) : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1B1E28)),
                  ),
                  Text(
                    member.position,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10, color: Color(0xFF9AA5B1)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}