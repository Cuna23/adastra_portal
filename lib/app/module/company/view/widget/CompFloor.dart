import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../model/comp_model.dart';
import '../../view model/comp_vm.dart';
import 'CompDialog.dart';
import 'CompImage.dart';
import 'CompMenu.dart';


class FloorMapView extends StatefulWidget {
  final String role;
  final String token;
  const FloorMapView({super.key, required this.role, required this.token});

  @override
  State<FloorMapView> createState() => _FloorMapViewState();
}

class _FloorMapViewState extends State<FloorMapView> {
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
        title: const Text('Floor mapping', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        actions: [
          if (_isAdminOrSuper)
            IconButton(
              onPressed: () => _pickAndUploadFloorMap(vm),
              icon: const Icon(Icons.add_rounded),
              tooltip: 'Add floor',
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (vm.isLoading)
              const Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Center(child: CircularProgressIndicator()))
            else if (vm.floorMaps.isEmpty)
              _emptyState(isMobile: isMobile, onAdd: _isAdminOrSuper ? () => _pickAndUploadFloorMap(vm) : null)
            else
              Column(
                children: vm.floorMaps.map((floor) => _floorMapItem(vm, floor, isMobile)).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _floorMapItem(CompanyViewModel vm, CompanyModel floor, bool isMobile) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E9F0))),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  floor.title ?? 'Untitled floor',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1B1E28)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_isAdminOrSuper)
                CompMenu(
                  onEdit: () => _editFloorTitle(vm, floor),
                  onDelete: () => _deleteFloorMap(vm, floor),
                  deleteEnabled: _isSuperAdmin, // [NEW] admin: grayed out
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (floor.imageUrl != null)
            GestureDetector(
              onTap: () => ImageViewerPage.show(context, floor.imageUrl!),
              child: MouseRegion(
                cursor: SystemMouseCursors.zoomIn,
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxHeight: 260),
                  decoration: BoxDecoration(color: const Color(0xFFF4F7FC), borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.all(8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      floor.imageUrl!,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, progress) => progress == null ? child : const Center(child: CircularProgressIndicator()),
                      errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image_outlined, color: Color(0xFFB9C1CC), size: 32)),
                    ),
                  ),
                ),
              ),
            ),
        ],
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
          const Icon(Icons.map_outlined, size: 40, color: Color(0xFFB9C1CC)),
          const SizedBox(height: 10),
          const Text('No floor maps uploaded yet.', style: TextStyle(color: Color(0xFF9AA5B1), fontSize: 13)),
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

  // ── Actions ──
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

  Future<void> _editFloorTitle(CompanyViewModel vm, CompanyModel floor) async {
    final title = await StyledDialogs.textPrompt(context, title: 'Floor name', subtitle: 'Rename this floor plan', icon: Icons.edit_outlined, hint: 'e.g. Level 3', initial: floor.title);
    if (title == null || title.trim().isEmpty) return;
    final ok = await vm.updateTitle(floor.id, title.trim(), widget.token, isOrgChart: false);
    if (!mounted) return;
    _showSnack(ok ? 'Title updated.' : 'Update failed. Please try again.', success: ok);
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