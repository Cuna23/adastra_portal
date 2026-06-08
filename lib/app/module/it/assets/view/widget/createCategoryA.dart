// create_category_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view model/asset_vm.dart';

class CreateCategoryDialog extends StatefulWidget {
  final String token;
  const CreateCategoryDialog({super.key, required this.token});

  @override
  State<CreateCategoryDialog> createState() => _CreateCategoryDialogState();
}

class _CreateCategoryDialogState extends State<CreateCategoryDialog> {
  final _controller = TextEditingController();
  bool _loading = false;

  static const _brandBlue    = Color(0xFF185FA5);
  static const _brandBlueBg  = Color(0xFFE6F1FB);
  static const _textPrimary  = Color(0xFF1B1E28);
  static const _textMuted    = Color(0xFF9CA3AF);
  static const _borderColor  = Color(0xFFE5E7EB);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 380,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _brandBlueBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.category_outlined,
                      color: _brandBlue, size: 18),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('New Category',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _textPrimary)),
                    Text('Add to asset categories',
                        style: TextStyle(fontSize: 11, color: _textMuted)),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Input
            TextField(
              controller: _controller,
              autofocus: true,
              style: const TextStyle(
                color: _textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                labelText: 'Category Name',
                labelStyle:
                    const TextStyle(fontSize: 13, color: _textMuted),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: _borderColor, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: _brandBlue, width: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _textPrimary,
                      side: const BorderSide(color: _borderColor),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding:
                          const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _brandBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding:
                          const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _loading
                        ? null
                        : () async {
                            final name = _controller.text.trim();
                            if (name.isEmpty) return;

                            setState(() => _loading = true);

                            final vm = context.read<AssetViewModel>();
                            final newId = await vm.createCategory(
                                widget.token, name);

                            if (context.mounted) {
                              Navigator.pop(context, newId); // return id
                            }
                          },
                    child: _loading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white),
                          )
                        : const Text('Create',
                            style:
                                TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}