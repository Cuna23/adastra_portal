import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../view model/comp_vm.dart';
import 'CompDialog.dart';
import 'CompImage.dart';
import 'CompMenu.dart';

// [HARDCODED] — TODO: ganti dengan data dari backend bila table `directors` dah siap
class DirectorInfo {
  final String name;
  final String position;
  final String bio;
  final Color color;
  final Color bg;

  const DirectorInfo({required this.name, required this.position, required this.bio, required this.color, required this.bg});
}

const List<DirectorInfo> _hardcodedDirectors = [
  DirectorInfo(name: 'Ahmad Zaki', position: 'Managing Director', bio: 'Leads overall strategy and operations for Adastra IP.', color: Color(0xFF185FA5), bg: Color(0xFFE6F1FB)),
  DirectorInfo(name: 'Sarah Lim', position: 'Co-founder', bio: 'Oversees client relations and business development.', color: Color(0xFF0F6E56), bg: Color(0xFFE1F5EE)),
  DirectorInfo(name: 'Rajesh Kumar', position: 'Head of IP Practice', bio: 'Heads the trademark and patent practice groups.', color: Color(0xFF854F0B), bg: Color(0xFFFAEEDA)),
];

// [CHANGED] StatelessWidget content-only — bukan page lagi
class OrgChartContent extends StatelessWidget {
  final String role;
  final String token;
  const OrgChartContent({super.key, required this.role, required this.token});

  bool get _isAdminOrSuper => role == 'admin' || role == 'super_admin';
  bool get _isSuperAdmin => role == 'super_admin';

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CompanyViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.account_tree_rounded, size: 22, color: Color(0xFF185FA5)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(vm.orgChart?.title ?? 'Organizational chart', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1B1E28))),
            ),
            if (_isAdminOrSuper)
              CompMenu(
                onEdit: () => _orgChartMenu(context, vm),
                onDelete: vm.orgChart != null ? () => _deleteOrgChart(context, vm) : null,
                deleteEnabled: _isSuperAdmin,
              ),
          ],
        ),
        const SizedBox(height: 14),

        if (vm.orgChart == null || vm.orgChart!.imageUrl == null)
          _emptyState(context, vm)
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

        const SizedBox(height: 20),
        const Text('Leadership', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1B1E28))),
        const SizedBox(height: 4),
        const Text('Tap a director to view their profile.', style: TextStyle(fontSize: 12, color: Color(0xFF9AA5B1))),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: _hardcodedDirectors.map((d) => _directorAvatar(context, d)).toList(),
        ),
      ],
    );
  }

  Widget _directorAvatar(BuildContext context, DirectorInfo d) {
    return InkWell(
      onTap: () => _showDirectorBio(context, d),
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 90,
        child: Column(
          children: [
            CircleAvatar(radius: 26, backgroundColor: d.bg, child: Icon(Icons.person_rounded, size: 24, color: d.color)),
            const SizedBox(height: 6),
            Text(d.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1B1E28))),
            Text(d.position, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: Color(0xFF9AA5B1))),
          ],
        ),
      ),
    );
  }

  void _showDirectorBio(BuildContext context, DirectorInfo d) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(radius: 28, backgroundColor: d.bg, child: Icon(Icons.person_rounded, size: 26, color: d.color)),
                const SizedBox(height: 12),
                Text(d.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1B1E28))),
                Text(d.position, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: d.color)),
                const SizedBox(height: 10),
                Text(d.bio, style: const TextStyle(fontSize: 13, height: 1.6, color: Color(0xFF4B5563))),
                const SizedBox(height: 16),
                Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context, CompanyViewModel vm) {
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
              onPressed: () => _pickAndUploadOrgChart(context, vm),
              icon: const Icon(Icons.upload_rounded, size: 15),
              label: const Text('Upload', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF185FA5), side: const BorderSide(color: Color(0xFFCBD5E1))),
            ),
          ],
        ],
      ),
    );
  }

  void _orgChartMenu(BuildContext context, CompanyViewModel vm) async {
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
    if (choice == 'title') await _editOrgChartTitle(context, vm);
    if (choice == 'upload') await _pickAndUploadOrgChart(context, vm);
  }

  Future<void> _pickAndUploadOrgChart(BuildContext context, CompanyViewModel vm) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (image == null) return;
    final ok = await vm.uploadOrgChart(image, token);
    if (!context.mounted) return;
    _showSnack(context, ok ? 'Organizational chart uploaded.' : 'Upload failed. Please try again.', success: ok);
  }

  Future<void> _editOrgChartTitle(BuildContext context, CompanyViewModel vm) async {
    final title = await StyledDialogs.textPrompt(context, title: 'Chart title', subtitle: 'Rename the organizational chart', icon: Icons.edit_outlined, hint: 'e.g. Company structure', initial: vm.orgChart?.title);
    if (title == null || title.trim().isEmpty) return;
    final ok = await vm.updateTitle(vm.orgChart!.id, title.trim(), token, isOrgChart: true);
    if (!context.mounted) return;
    _showSnack(context, ok ? 'Title updated.' : 'Update failed. Please try again.', success: ok);
  }

  Future<void> _deleteOrgChart(BuildContext context, CompanyViewModel vm) async {
    final confirmed = await StyledDialogs.confirmDelete(context, itemLabel: 'chart', message: 'This will remove the organizational chart for everyone.');
    if (confirmed != true || !context.mounted) return;
    final ok = await vm.deleteItem(vm.orgChart!.id, token, isOrgChart: true);
    if (!context.mounted) return;
    _showSnack(context, ok ? 'Deleted successfully.' : 'Delete failed. Please try again.', success: ok);
  }

  void _showSnack(BuildContext context, String message, {required bool success}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: success ? const Color(0xFF2E7D52) : const Color(0xFFD64545), behavior: SnackBarBehavior.floating),
    );
  }
}