import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../model/comp_model.dart';
import '../../view model/comp_vm.dart';
import 'CompDialog.dart';
import 'CompImage.dart';
import 'CompMenu.dart';

// [CHANGED] StatelessWidget content-only — bukan page lagi
class FloorMapContent extends StatelessWidget {
  final String role;
  final String token;
  const FloorMapContent({super.key, required this.role, required this.token});

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
            const Icon(Icons.map_rounded, size: 22, color: Color(0xFF185FA5)),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Floor mapping',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B1E28),
                ),
              ),
            ),
            // [CHANGED] TextButton -> ElevatedButton, same filled-blue style as "Add User".
            // Also fixed label fontSize (was 16, now 12 to match the rest of the buttons).
            if (_isAdminOrSuper)
              ElevatedButton.icon(
                onPressed: () => _pickAndUploadFloorMap(context, vm),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Add floor', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
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
        const SizedBox(height: 14),

        if (vm.floorMaps.isEmpty)
          _emptyState(context, vm)
        else
          // [NEW] setiap floor bungkus card berasingan — label jelas beza satu sama lain
          Column(
            children: List.generate(vm.floorMaps.length, (i) {
              final floor = vm.floorMaps[i];
              return Padding(
                padding: EdgeInsets.only(bottom: i == vm.floorMaps.length - 1 ? 0 : 16),
                child: _floorCard(context, vm, floor),
              );
            }),
          ),
      ],
    );
  }

  Widget _floorCard(BuildContext context, CompanyViewModel vm, CompanyModel floor) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFFE6F1FB), borderRadius: BorderRadius.circular(6)),
                child: Text(
                  floor.title ?? 'Untitled floor',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF185FA5)),
                ),
              ),
              const Spacer(),
              if (_isAdminOrSuper)
                CompMenu(
                  onEdit: () => _editFloorTitle(context, vm, floor),
                  onDelete: () => _deleteFloorMap(context, vm, floor),
                  deleteEnabled: _isSuperAdmin,
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (floor.imageUrl != null)
            GestureDetector(
              onTap: () => ImageViewerPage.show(context, floor.imageUrl!),
              child: MouseRegion(
                cursor: SystemMouseCursors.zoomIn,
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxHeight: 220),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.all(6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      floor.imageUrl!,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, progress) => progress == null ? child : const Center(child: CircularProgressIndicator()),
                      errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image_outlined, color: Color(0xFFB9C1CC), size: 28)),
                    ),
                  ),
                ),
              ),
            ),
        ],
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
          const Icon(Icons.map_outlined, size: 36, color: Color(0xFFB9C1CC)),
          const SizedBox(height: 8),
          const Text('No floor maps uploaded yet.', style: TextStyle(color: Color(0xFF9AA5B1), fontSize: 12)),
          if (_isAdminOrSuper) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => _pickAndUploadFloorMap(context, vm),
              icon: const Icon(Icons.upload_rounded, size: 15),
              label: const Text('Upload', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF185FA5), side: const BorderSide(color: Color(0xFFCBD5E1))),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickAndUploadFloorMap(BuildContext context, CompanyViewModel vm) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (image == null) return;
    if (!context.mounted) return;
    final title = await StyledDialogs.textPrompt(context, title: 'Add floor', subtitle: 'Name this floor plan', icon: Icons.map_outlined, hint: 'e.g. Level 3');
    if (title == null || title.trim().isEmpty) return;
    final ok = await vm.uploadFloorMap(image, title.trim(), token);
    if (!context.mounted) return;
    _showSnack(context, ok ? 'Floor map uploaded.' : 'Upload failed. Please try again.', success: ok);
  }

  Future<void> _editFloorTitle(BuildContext context, CompanyViewModel vm, CompanyModel floor) async {
    final title = await StyledDialogs.textPrompt(context, title: 'Floor name', subtitle: 'Rename this floor plan', icon: Icons.edit_outlined, hint: 'e.g. Level 3', initial: floor.title);
    if (title == null || title.trim().isEmpty) return;
    final ok = await vm.updateTitle(floor.id, title.trim(), token, isOrgChart: false);
    if (!context.mounted) return;
    _showSnack(context, ok ? 'Title updated.' : 'Update failed. Please try again.', success: ok);
  }

  Future<void> _deleteFloorMap(BuildContext context, CompanyViewModel vm, CompanyModel floor) async {
    final confirmed = await StyledDialogs.confirmDelete(context, itemLabel: 'floor map', message: 'This will remove this floor map for everyone.');
    if (confirmed != true || !context.mounted) return;
    final ok = await vm.deleteItem(floor.id, token, isOrgChart: false);
    if (!context.mounted) return;
    _showSnack(context, ok ? 'Deleted successfully.' : 'Delete failed. Please try again.', success: ok);
  }

  void _showSnack(BuildContext context, String message, {required bool success}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: success ? const Color(0xFF2E7D52) : const Color(0xFFD64545), behavior: SnackBarBehavior.floating),
    );
  }
}