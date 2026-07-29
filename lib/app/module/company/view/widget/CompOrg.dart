import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  const DirectorInfo({
    required this.name,
    required this.position,
    required this.bio,
    required this.color,
    required this.bg,
  });
}

const List<DirectorInfo> _hardcodedDirectors = [
  DirectorInfo(
    name: 'Ahmad Zaki',
    position: 'Managing Director',
    bio: 'Leads overall strategy and operations for Adastra IP.',
    color: Color(0xFF185FA5),
    bg: Color(0xFFE6F1FB),
  ),
  DirectorInfo(
    name: 'Sarah Lim',
    position: 'Co-founder',
    bio: 'Oversees client relations and business development.',
    color: Color(0xFF0F6E56),
    bg: Color(0xFFE1F5EE),
  ),
  DirectorInfo(
    name: 'Rajesh Kumar',
    position: 'Head of IP Practice',
    bio: 'Heads the trademark and patent practice groups.',
    color: Color(0xFF854F0B),
    bg: Color(0xFFFAEEDA),
  ),
];

class OrgChartView extends StatefulWidget {
  final String role;
  final String token;
  const OrgChartView({super.key, required this.role, required this.token});

  @override
  State<OrgChartView> createState() => _OrgChartViewState();
}

class _OrgChartViewState extends State<OrgChartView> {
  static const _brand = Color(0xFF185FA5);
  bool get _isAdminOrSuper => widget.role == 'admin' || widget.role == 'super_admin';
  bool get _isSuperAdmin => widget.role == 'super_admin';

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CompanyViewModel>();
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF1B1E28),
        title: const Text('Organizational chart', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        actions: [
          if (_isAdminOrSuper)
            CompMenu(
              onEdit: () => _orgChartMenu(vm),
              onDelete: vm.orgChart != null ? () => _deleteOrgChart(vm) : null,
              deleteEnabled: _isSuperAdmin, // [NEW] admin: grayed out
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (vm.isLoading)
              const Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Center(child: CircularProgressIndicator()))
            else if (vm.orgChart == null || vm.orgChart!.imageUrl == null)
              _emptyState(isMobile: isMobile, onAdd: _isAdminOrSuper ? () => _pickAndUploadOrgChart(vm) : null)
            else
              GestureDetector(
                onTap: () => ImageViewerPage.show(context, vm.orgChart!.imageUrl!),
                child: MouseRegion(
                  cursor: SystemMouseCursors.zoomIn,
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxHeight: 320),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E9F0))),
                    padding: const EdgeInsets.all(10),
                    child: Image.network(vm.orgChart!.imageUrl!, fit: BoxFit.contain),
                  ),
                ),
              ),

            const SizedBox(height: 28),
            const Text('Leadership', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1B1E28))),
            const SizedBox(height: 4),
            const Text('Tap a director to view their profile.', style: TextStyle(fontSize: 12, color: Color(0xFF9AA5B1))),
            const SizedBox(height: 14),

            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: _hardcodedDirectors.map((d) => _directorAvatar(d)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _directorAvatar(DirectorInfo d) {
    return InkWell(
      onTap: () => _showDirectorBio(d),
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 100,
        child: Column(
          children: [
            CircleAvatar(radius: 30, backgroundColor: d.bg, child: Icon(Icons.person_rounded, size: 28, color: d.color)),
            const SizedBox(height: 8),
            Text(d.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1B1E28))),
            Text(d.position, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: Color(0xFF9AA5B1))),
          ],
        ),
      ),
    );
  }

  void _showDirectorBio(DirectorInfo d) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Padding(
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
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState({required bool isMobile, VoidCallback? onAdd}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E9F0))),
      padding: EdgeInsets.symmetric(vertical: isMobile ? 32 : 44),
      child: Column(
        children: [
          const Icon(Icons.account_tree_outlined, size: 40, color: Color(0xFFB9C1CC)),
          const SizedBox(height: 10),
          const Text('No organizational chart uploaded yet.', style: TextStyle(color: Color(0xFF9AA5B1), fontSize: 13)),
          if (onAdd != null) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.upload_rounded, size: 15),
              label: const Text('Upload', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(foregroundColor: _brand, side: const BorderSide(color: Color(0xFFCBD5E1))),
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
    // sama logic macam sebelum ni — guna image_picker + vm.uploadOrgChart
  }

  Future<void> _editOrgChartTitle(CompanyViewModel vm) async {
    // sama logic macam sebelum ni — StyledDialogs.textPrompt + vm.updateTitle
  }

  Future<void> _deleteOrgChart(CompanyViewModel vm) async {
    final confirmed = await StyledDialogs.confirmDelete(context, itemLabel: 'chart', message: 'This will remove the organizational chart for everyone.');
    if (confirmed != true || !mounted) return;
    await vm.deleteItem(vm.orgChart!.id, widget.token, isOrgChart: true);
  }
}