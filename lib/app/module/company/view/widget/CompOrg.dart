import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../view model/comp_vm.dart';
import 'CompDialog.dart';
import 'CompImage.dart';
import 'CompMenu.dart';
import 'CompTeam.dart';

// [CHANGED] StatefulWidget — perlu simpan local team members state
class OrgChartContent extends StatefulWidget {
  final String role;
  final String token;
  const OrgChartContent({super.key, required this.role, required this.token});

  @override
  State<OrgChartContent> createState() => _OrgChartContentState();
}

class _OrgChartContentState extends State<OrgChartContent> {
  // [HARDCODED] — TODO: ganti dengan fetch dari CompanyViewModel bila backend siap
  List<TeamMember> _members = hardcodedTeamMembers();

  bool get _isAdminOrSuper => widget.role == 'admin' || widget.role == 'super_admin';
  bool get _isSuperAdmin => widget.role == 'super_admin';

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CompanyViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Org chart image ──
        Row(
          children: [
            const Icon(Icons.account_tree_rounded, size: 22, color: Color(0xFF185FA5)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(vm.orgChart?.title ?? 'Organizational chart', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1B1E28))),
            ),
            if (_isAdminOrSuper)
              CompMenu(
                onEdit: () => _orgChartMenu(vm),
                onDelete: vm.orgChart != null ? () => _deleteOrgChart(vm) : null,
                deleteEnabled: _isSuperAdmin,
              ),
          ],
        ),
        const SizedBox(height: 14),

        if (vm.orgChart == null || vm.orgChart!.imageUrl == null)
          _emptyChartState(vm)
        else
          GestureDetector(
            onTap: () => ImageViewerPage.show(context, vm.orgChart!.imageUrl!),
            child: MouseRegion(
              cursor: SystemMouseCursors.zoomIn,
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 260),
                decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE5E7EB))),
                padding: const EdgeInsets.all(10),
                child: Image.network(vm.orgChart!.imageUrl!, fit: BoxFit.contain),
              ),
            ),
          ),

        const SizedBox(height: 24),

        // ── Teams & leadership ──
        Row(
          children: [
            const Expanded(
              child: Text('Teams and leadership', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1B1E28))),
            ),
            if (_isAdminOrSuper)
              TextButton.icon(
                onPressed: _addMember,
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Add member', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                style: TextButton.styleFrom(foregroundColor: const Color(0xFF185FA5), padding: const EdgeInsets.symmetric(horizontal: 8)),
              ),
          ],
        ),
        const SizedBox(height: 4),
        const Text('Tap a member to view their profile.', style: TextStyle(fontSize: 12, color: Color(0xFF9AA5B1))),
        const SizedBox(height: 14),

        if (_members.isEmpty)
          const Text('No team members added yet.', style: TextStyle(fontSize: 12, color: Color(0xFF9AA5B1)))
        else
          Column(
            children: TeamCategory.values.map((team) {
              final teamMembers = _members.where((m) => m.team == team).toList();
              if (teamMembers.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      team.label,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF9AA5B1), letterSpacing: 0.3),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: teamMembers
                          .map((m) => TeamMemberAvatar(
                                member: m,
                                onTap: () => showTeamMemberBio(context, m),
                                onEdit: _isAdminOrSuper ? () => _editMember(m) : null,
                                onDelete: _isAdminOrSuper ? () => _deleteMember(m) : null,
                                deleteEnabled: _isSuperAdmin,
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

  // ── Team member actions (local state only) ──
  Future<void> _addMember() async {
    final result = await showTeamMemberForm(context);
    if (result == null) return;
    setState(() => _members = [..._members, result]);
  }

  Future<void> _editMember(TeamMember m) async {
    final result = await showTeamMemberForm(context, existing: m);
    if (result == null) return;
    setState(() => _members = _members.map((x) => x.id == m.id ? result : x).toList());
  }

  Future<void> _deleteMember(TeamMember m) async {
    final confirmed = await StyledDialogs.confirmDelete(context, itemLabel: m.name, message: 'This will remove ${m.name} from the team list.');
    if (confirmed != true || !mounted) return;
    setState(() => _members = _members.where((x) => x.id != m.id).toList());
  }

  // ── Org chart image actions ──
  Widget _emptyChartState(CompanyViewModel vm) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE5E7EB))),
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          const Icon(Icons.account_tree_outlined, size: 36, color: Color(0xFFB9C1CC)),
          const SizedBox(height: 8),
          const Text('No organizational chart uploaded yet.', style: TextStyle(color: Color(0xFF9AA5B1), fontSize: 12)),
          if (_isAdminOrSuper) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => _pickAndUploadOrgChart(vm),
              icon: const Icon(Icons.upload_rounded, size: 15),
              label: const Text('Upload', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF185FA5), side: const BorderSide(color: Color(0xFFCBD5E1))),
            ),
          ],
        ],
      ),
    );
  }

  void _orgChartMenu(CompanyViewModel vm) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Icon(Icons.edit_outlined), title: const Text('Edit title'), onTap: () => Navigator.pop(ctx, 'title')),
            ListTile(leading: const Icon(Icons.upload_rounded), title: Text(vm.orgChart == null ? 'Upload chart' : 'Replace chart'), onTap: () => Navigator.pop(ctx, 'upload')),
          ],
        ),
      ),
    );
    if (choice == 'title') await _editOrgChartTitle(vm);
    if (choice == 'upload') await _pickAndUploadOrgChart(vm);
  }

  Future<void> _pickAndUploadOrgChart(CompanyViewModel vm) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (image == null) return;
    final ok = await vm.uploadOrgChart(image, widget.token);
    if (!mounted) return;
    _showSnack(ok ? 'Organizational chart uploaded.' : 'Upload failed. Please try again.', success: ok);
  }

  Future<void> _editOrgChartTitle(CompanyViewModel vm) async {
    final title = await StyledDialogs.textPrompt(context, title: 'Chart title', subtitle: 'Rename the organizational chart', icon: Icons.edit_outlined, hint: 'e.g. Company structure', initial: vm.orgChart?.title);
    if (title == null || title.trim().isEmpty) return;
    final ok = await vm.updateTitle(vm.orgChart!.id, title.trim(), widget.token, isOrgChart: true);
    if (!mounted) return;
    _showSnack(ok ? 'Title updated.' : 'Update failed. Please try again.', success: ok);
  }

  Future<void> _deleteOrgChart(CompanyViewModel vm) async {
    final confirmed = await StyledDialogs.confirmDelete(context, itemLabel: 'chart', message: 'This will remove the organizational chart for everyone.');
    if (confirmed != true || !mounted) return;
    final ok = await vm.deleteItem(vm.orgChart!.id, widget.token, isOrgChart: true);
    if (!mounted) return;
    _showSnack(ok ? 'Deleted successfully.' : 'Delete failed. Please try again.', success: ok);
  }

  void _showSnack(String message, {required bool success}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: success ? const Color(0xFF2E7D52) : const Color(0xFFD64545), behavior: SnackBarBehavior.floating),
    );
  }
}