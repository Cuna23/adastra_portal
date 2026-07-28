import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../model/comp_model.dart';
import '../view model/comp_vm.dart';
import 'widget/CompDialog.dart';
import 'widget/CompImage.dart';
import 'widget/CompMenu.dart';


class CompanyView extends StatefulWidget {
  final String role;
  final String token;

  const CompanyView({super.key, required this.role, required this.token});

  @override
  State<CompanyView> createState() => _CompanyViewState();
}

class _CompanyViewState extends State<CompanyView> {
  static const _brand = Color(0xFF185FA5);
  static const _breakpoint = 700.0;

  bool get _isAdminOrSuper => widget.role == 'admin' || widget.role == 'super_admin';
  bool get _isSuperAdmin => widget.role == 'super_admin';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompanyViewModel>().fetchAll(widget.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CompanyViewModel>();
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final isNarrow = width < _breakpoint;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = isNarrow ? 1 : 2;
          final cardWidth = columns == 1
              ? constraints.maxWidth
              : (constraints.maxWidth - 14) / 2;

          return Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              SizedBox(width: cardWidth, child: _aboutCard(vm, isMobile)),
              SizedBox(width: cardWidth, child: _visionMissionCard(vm, isMobile)),
              SizedBox(width: cardWidth, child: _orgChartCard(vm, isMobile)),
              SizedBox(width: cardWidth, child: _floorMapCard(vm, isMobile, isNarrow)),
            ],
          );
        },
      ),
    );
  }

  // ── Uniform section shell ──
  Widget _sectionCard({
    required Color accentColor,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required bool isMobile,
    required Widget child,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E9F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isMobile ? 14 : 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
                      child: Icon(icon, size: 17, color: iconColor),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(title, style: TextStyle(fontSize: isMobile ? 13 : 14, fontWeight: FontWeight.w700, color: const Color(0xFF1B1E28))),
                    ),
                    if (onEdit != null || onDelete != null)
                      CompMenu(onEdit: onEdit, onDelete: onDelete),
                  ],
                ),
                const SizedBox(height: 10),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── About ──
  Widget _aboutCard(CompanyViewModel vm, bool isMobile) {
    return _sectionCard(
      accentColor: const Color(0xFF378ADD),
      icon: Icons.apartment_rounded,
      iconBg: const Color(0xFFE6F1FB),
      iconColor: const Color(0xFF185FA5),
      title: 'About us',
      isMobile: isMobile,
      onEdit: _isAdminOrSuper ? () => _editAbout(vm) : null,
      child: Text(
        (vm.about?.content?.isNotEmpty ?? false) ? vm.about!.content! : 'No description yet. Tap edit to add one.',
        style: TextStyle(fontSize: isMobile ? 12 : 13, height: 1.6, color: const Color(0xFF4B5563)),
      ),
    );
  }

  // ── Vision & Mission ──
  Widget _visionMissionCard(CompanyViewModel vm, bool isMobile) {
    return _sectionCard(
      accentColor: const Color(0xFF1D9E75),
      icon: Icons.flag_rounded,
      iconBg: const Color(0xFFE1F5EE),
      iconColor: const Color(0xFF0F6E56),
      title: 'Vision and mission',
      isMobile: isMobile,
      onEdit: _isAdminOrSuper ? () => _editVisionMission(vm) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Vision', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF0F6E56))),
          const SizedBox(height: 2),
          Text(
            vm.visionText.isNotEmpty ? vm.visionText : 'Not set yet.',
            style: TextStyle(fontSize: isMobile ? 12 : 13, height: 1.6, color: const Color(0xFF4B5563)),
          ),
          const SizedBox(height: 8),
          Text('Mission', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF0F6E56))),
          const SizedBox(height: 2),
          Text(
            vm.missionText.isNotEmpty ? vm.missionText : 'Not set yet.',
            style: TextStyle(fontSize: isMobile ? 12 : 13, height: 1.6, color: const Color(0xFF4B5563)),
          ),
        ],
      ),
    );
  }

  // ── Org chart ──
  Widget _orgChartCard(CompanyViewModel vm, bool isMobile) {
    return _sectionCard(
      accentColor: const Color(0xFFCBD5E1),
      icon: Icons.account_tree_rounded,
      iconBg: const Color(0xFFF4F7FC),
      iconColor: _brand,
      title: vm.orgChart?.title ?? 'Organizational chart',
      isMobile: isMobile,
      onEdit: _isAdminOrSuper ? () => _orgChartMenu(vm) : null,
      onDelete: _isSuperAdmin && vm.orgChart != null ? () => _deleteOrgChart(vm) : null,
      child: vm.isLoading
          ? const Padding(padding: EdgeInsets.symmetric(vertical: 30), child: Center(child: CircularProgressIndicator()))
          : (vm.orgChart == null || vm.orgChart!.imageUrl == null)
              ? _emptyState(icon: Icons.account_tree_outlined, message: 'No organizational chart uploaded yet.', isMobile: isMobile, onAdd: _isAdminOrSuper ? () => _pickAndUploadOrgChart(vm) : null)
              : _imageThumb(url: vm.orgChart!.imageUrl!),
    );
  }

  // ── Floor mapping ──
  Widget _floorMapCard(CompanyViewModel vm, bool isMobile, bool isNarrow) {
    return _sectionCard(
      accentColor: const Color(0xFFCBD5E1),
      icon: Icons.map_rounded,
      iconBg: const Color(0xFFF4F7FC),
      iconColor: _brand,
      title: 'Floor mapping',
      isMobile: isMobile,
      onEdit: _isAdminOrSuper ? () => _pickAndUploadFloorMap(vm) : null,
      child: vm.isLoading
          ? const Padding(padding: EdgeInsets.symmetric(vertical: 30), child: Center(child: CircularProgressIndicator()))
          : vm.floorMaps.isEmpty
              ? _emptyState(icon: Icons.map_outlined, message: 'No floor maps uploaded yet.', isMobile: isMobile, onAdd: _isAdminOrSuper ? () => _pickAndUploadFloorMap(vm) : null)
              : Column(
                  children: vm.floorMaps.map((floor) => _floorMapItem(vm, floor, isMobile)).toList(),
                ),
    );
  }

  Widget _floorMapItem(CompanyViewModel vm, CompanyModel floor, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(floor.title ?? 'Untitled floor',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1B1E28)), overflow: TextOverflow.ellipsis),
              ),
              if (_isAdminOrSuper || _isSuperAdmin)
                CompMenu(
                  onEdit: _isAdminOrSuper ? () => _editFloorTitle(vm, floor) : null,
                  onDelete: _isSuperAdmin ? () => _deleteFloorMap(vm, floor) : null,
                ),
            ],
          ),
          const SizedBox(height: 6),
          if (floor.imageUrl != null) _imageThumb(url: floor.imageUrl!),
        ],
      ),
    );
  }

  // ── Image thumb — tap to zoom fullscreen ──
  Widget _imageThumb({required String url}) {
    return GestureDetector(
      onTap: () => ImageViewerPage.show(context, url),
      child: MouseRegion(
        cursor: SystemMouseCursors.zoomIn,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxHeight: 220),
          decoration: BoxDecoration(color: const Color(0xFFF4F7FC), borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.all(8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              url,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, progress) => progress == null ? child : const Center(child: CircularProgressIndicator()),
              errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image_outlined, color: Color(0xFFB9C1CC), size: 32)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState({required IconData icon, required String message, required bool isMobile, VoidCallback? onAdd}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 24 : 32),
      child: Column(
        children: [
          Icon(icon, size: isMobile ? 32 : 38, color: const Color(0xFFB9C1CC)),
          const SizedBox(height: 8),
          Text(message, style: TextStyle(color: const Color(0xFF9AA5B1), fontSize: isMobile ? 12 : 13)),
          if (onAdd != null) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.upload_rounded, size: 15),
              label: const Text('Upload', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: _brand,
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Actions ──
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

  Future<void> _pickAndUploadFloorMap(CompanyViewModel vm) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (image == null) return;
    if (!mounted) return;
    final title = await StyledDialogs.textPrompt(context, title: 'Add floor', subtitle: 'Name this floor plan', icon: Icons.map_outlined, hint: 'e.g. Level 3');
    if (title == null || title.trim().isEmpty) return;
    final ok = await vm.uploadFloorMap(image, title.trim(), widget.token);
    if (!mounted) return;
    _showSnack(ok ? 'Floor map uploaded.' : 'Upload failed. Please try again.', success: ok);
  }

  Future<void> _editOrgChartTitle(CompanyViewModel vm) async {
    final title = await StyledDialogs.textPrompt(context, title: 'Chart title', subtitle: 'Rename the organizational chart', icon: Icons.edit_outlined, hint: 'e.g. Company structure', initial: vm.orgChart?.title);
    if (title == null || title.trim().isEmpty) return;
    final ok = await vm.updateTitle(vm.orgChart!.id, title.trim(), widget.token, isOrgChart: true);
    if (!mounted) return;
    _showSnack(ok ? 'Title updated.' : 'Update failed. Please try again.', success: ok);
  }

  Future<void> _editFloorTitle(CompanyViewModel vm, CompanyModel floor) async {
    final title = await StyledDialogs.textPrompt(context, title: 'Floor name', subtitle: 'Rename this floor plan', icon: Icons.edit_outlined, hint: 'e.g. Level 3', initial: floor.title);
    if (title == null || title.trim().isEmpty) return;
    final ok = await vm.updateTitle(floor.id, title.trim(), widget.token, isOrgChart: false);
    if (!mounted) return;
    _showSnack(ok ? 'Title updated.' : 'Update failed. Please try again.', success: ok);
  }

  Future<void> _editAbout(CompanyViewModel vm) async {
    final content = await StyledDialogs.textPrompt(context, title: 'About us', subtitle: 'Describe the company', icon: Icons.apartment_rounded, hint: 'Describe the company', initial: vm.about?.content, multiline: true);
    if (content == null || content.trim().isEmpty) return;
    final ok = await vm.updateAbout(content.trim(), widget.token);
    if (!mounted) return;
    _showSnack(ok ? 'About us updated.' : 'Update failed. Please try again.', success: ok);
  }

  Future<void> _editVisionMission(CompanyViewModel vm) async {
    final result = await StyledDialogs.visionMissionPrompt(context, vision: vm.visionText, mission: vm.missionText);
    if (result == null || !mounted) return;
    final ok = await vm.updateVisionMission(result['vision']!.trim(), result['mission']!.trim(), widget.token);
    if (!mounted) return;
    _showSnack(ok ? 'Vision and mission updated.' : 'Update failed. Please try again.', success: ok);
  }

  Future<void> _deleteOrgChart(CompanyViewModel vm) async {
    final confirmed = await StyledDialogs.confirmDelete(context, itemLabel: 'chart', message: 'This will remove the organizational chart for everyone.');
    if (confirmed != true || !mounted) return;
    final ok = await vm.deleteItem(vm.orgChart!.id, widget.token, isOrgChart: true);
    if (!mounted) return;
    _showSnack(ok ? 'Deleted successfully.' : 'Delete failed. Please try again.', success: ok);
  }

  Future<void> _deleteFloorMap(CompanyViewModel vm, CompanyModel floor) async {
    final confirmed = await StyledDialogs.confirmDelete(context, itemLabel: 'floor map', message: 'This will remove this floor map for everyone.');
    if (confirmed != true || !mounted) return;
    final ok = await vm.deleteItem(floor.id, widget.token, isOrgChart: false);
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