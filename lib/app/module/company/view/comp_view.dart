import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../model/comp_model.dart';
import '../view model/comp_vm.dart';

class CompanyView extends StatefulWidget {
  final String role;
  final String token;

  const CompanyView({super.key, required this.role, required this.token});

  @override
  State<CompanyView> createState() => _CompanyViewState();
}

class _CompanyViewState extends State<CompanyView> {
  bool get _isAdminOrSuper => widget.role == 'admin' || widget.role == 'super_admin';
  bool get _isSuperAdmin => widget.role == 'super_admin';

  @override
  void initState() {
    super.initState();
    // [NEW] fetch both sections on page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<CompanyViewModel>();
      vm.fetchOrgChart(widget.token);
      vm.fetchFloorMaps(widget.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CompanyViewModel>();
    final isMobile = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section 1: Organizational Chart ──
          _sectionHeader(
            icon: Icons.account_tree_rounded,
            title: 'Organizational Chart',
            isMobile: isMobile,
          ),
          const SizedBox(height: 12),
          _orgChartSection(vm, isMobile),

          SizedBox(height: isMobile ? 32 : 40),

          // ── Section 2: Floor Mapping ──
          _sectionHeader(
            icon: Icons.map_rounded,
            title: 'Floor Mapping',
            isMobile: isMobile,
          ),
          const SizedBox(height: 12),
          _floorMapSection(vm, isMobile),

          SizedBox(height: isMobile ? 32 : 40),

          // ── Coming soon placeholders ──
          _comingSoonCard(icon: Icons.info_outline_rounded, title: 'About', isMobile: isMobile),
          const SizedBox(height: 12),
          _comingSoonCard(icon: Icons.flag_outlined, title: 'Vision & Mission', isMobile: isMobile),
        ],
      ),
    );
  }

  Widget _sectionHeader({required IconData icon, required String title, required bool isMobile}) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF185FA5), size: isMobile ? 20 : 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B1E28),
          ),
        ),
      ],
    );
  }

  // ── Org Chart section ──
  Widget _orgChartSection(CompanyViewModel vm, bool isMobile) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E9F0)),
      ),
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isAdminOrSuper)
            Align(
              alignment: Alignment.centerRight,
              child: _uploadButton(
                label: vm.orgChart == null ? 'Upload Chart' : 'Replace Chart',
                onTap: () => _pickAndUploadOrgChart(vm),
              ),
            ),
          if (_isAdminOrSuper) const SizedBox(height: 12),

          if (vm.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (vm.orgChart == null || vm.orgChart!.imageUrl == null)
            _emptyState(
              icon: Icons.account_tree_outlined,
              message: 'No organizational chart uploaded yet.',
              isMobile: isMobile,
            )
          else
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4,
                    child: Image.network(
                      vm.orgChart!.imageUrl!,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 60),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder: (_, __, ___) => _emptyState(
                        icon: Icons.broken_image_outlined,
                        message: 'Failed to load image.',
                        isMobile: isMobile,
                      ),
                    ),
                  ),
                ),
                if (_isSuperAdmin)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _deleteButton(
                      onTap: () => _confirmDelete(
                        id: vm.orgChart!.id,
                        isOrgChart: true,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  // ── Floor Map section ──
  Widget _floorMapSection(CompanyViewModel vm, bool isMobile) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E9F0)),
      ),
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isAdminOrSuper)
            Align(
              alignment: Alignment.centerRight,
              child: _uploadButton(
                label: 'Add Floor',
                onTap: () => _pickAndUploadFloorMap(vm),
              ),
            ),
          if (_isAdminOrSuper) const SizedBox(height: 12),

          if (vm.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (vm.floorMaps.isEmpty)
            _emptyState(
              icon: Icons.map_outlined,
              message: 'No floor maps uploaded yet.',
              isMobile: isMobile,
            )
          else
            Column(
              children: vm.floorMaps.map((floor) => _floorMapCard(floor, isMobile)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _floorMapCard(CompanyModel floor, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  floor.title ?? 'Untitled Floor',
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1B1E28),
                  ),
                ),
              ),
              if (_isSuperAdmin)
                _deleteButton(
                  compact: true,
                  onTap: () => _confirmDelete(id: floor.id, isOrgChart: false),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (floor.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4,
                child: Image.network(
                  floor.imageUrl!,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => _emptyState(
                    icon: Icons.broken_image_outlined,
                    message: 'Failed to load image.',
                    isMobile: isMobile,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _comingSoonCard({required IconData icon, required String title, required bool isMobile}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E9F0), style: BorderStyle.solid),
      ),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: isMobile ? 14 : 18),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF9AA5B1), size: isMobile ? 18 : 20),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 13 : 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFE5E9F0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Soon', style: TextStyle(color: Color(0xFF6B7280), fontSize: 10, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _emptyState({required IconData icon, required String message, required bool isMobile}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 32 : 44),
      child: Column(
        children: [
          Icon(icon, size: isMobile ? 36 : 44, color: const Color(0xFFB9C1CC)),
          const SizedBox(height: 10),
          Text(message, style: TextStyle(color: const Color(0xFF9AA5B1), fontSize: isMobile ? 12 : 13)),
        ],
      ),
    );
  }

  Widget _uploadButton({required String label, required VoidCallback onTap}) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.upload_rounded, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF185FA5),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
    );
  }

  Widget _deleteButton({required VoidCallback onTap, bool compact = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.all(compact ? 6 : 8),
        decoration: BoxDecoration(
          color: compact ? const Color(0xFFFDEDED) : Colors.black.withOpacity(0.45),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.delete_outline_rounded,
          size: compact ? 16 : 18,
          color: compact ? const Color(0xFFD64545) : Colors.white,
        ),
      ),
    );
  }

  Future<void> _pickAndUploadOrgChart(CompanyViewModel vm) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (image == null) return;

    final ok = await vm.uploadOrgChart(image, widget.token);
    if (!mounted) return;
    _showSnack(ok ? 'Organizational chart uploaded.' : 'Upload failed. Please try again.', success: ok);
  }

  Future<void> _pickAndUploadFloorMap(CompanyViewModel vm) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (image == null) return;

    if (!mounted) return;
    final title = await _askFloorTitle();
    if (title == null || title.trim().isEmpty) return;

    final ok = await vm.uploadFloorMap(image, title.trim(), widget.token);
    if (!mounted) return;
    _showSnack(ok ? 'Floor map uploaded.' : 'Upload failed. Please try again.', success: ok);
  }

  Future<String?> _askFloorTitle() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Floor Name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. Level 3'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete({required int id, required bool isOrgChart}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this?'),
        content: Text(
          isOrgChart
              ? 'This will remove the organizational chart for everyone.'
              : 'This will remove this floor map for everyone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD64545)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final vm = context.read<CompanyViewModel>();
    final ok = await vm.deleteItem(id, widget.token, isOrgChart: isOrgChart);
    if (!mounted) return;
    _showSnack(ok ? 'Deleted successfully.' : 'Delete failed. Please try again.', success: ok);
  }

  void _showSnack(String message, {required bool success}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? const Color(0xFF2E7D52) : const Color(0xFFD64545),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}