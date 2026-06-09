import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/assetCategory_model.dart';
import '../../view model/asset_vm.dart';

class CreateCategoryDialog extends StatefulWidget {
  final String token;

  /// true  → dipanggil dari dropdown asset form; terus close & return id selepas add
  /// false → dipanggil dari toolbar; stay open, boleh add/edit/delete
  final bool returnOnCreate;

  const CreateCategoryDialog({
    super.key,
    required this.token,
    this.returnOnCreate = false,
  });

  @override
  State<CreateCategoryDialog> createState() => _CreateCategoryDialogState();
}

class _CreateCategoryDialogState extends State<CreateCategoryDialog> {
  final _addController  = TextEditingController();
  bool  _addLoading     = false;
  int?  _editingId;
  final _editController = TextEditingController();

  static const _brandBlue   = Color(0xFF185FA5);
  static const _brandBlueBg = Color(0xFFE6F1FB);
  static const _textPrimary = Color(0xFF1B1E28);
  static const _textMuted   = Color(0xFF9CA3AF);
  static const _borderColor = Color(0xFFE5E7EB);
  static const _errorRed    = Color(0xFFD92D20);

  @override
  void dispose() {
    _addController.dispose();
    _editController.dispose();
    super.dispose();
  }

  // ── Add ───────────────────────────────────────────────────────────────────
  Future<void> _onAdd(AssetViewModel vm) async {
    final name = _addController.text.trim();
    if (name.isEmpty) return;

    setState(() => _addLoading = true);
    final newId = await vm.createCategory(widget.token, name);
    _addController.clear();
    setState(() => _addLoading = false);

    if (widget.returnOnCreate && newId != null && mounted) {
      Navigator.pop(context, newId);
    }
  }

  // ── Edit inline ───────────────────────────────────────────────────────────
  void _startEdit(AssetCategoryModel cat) {
    setState(() {
      _editingId = cat.id;
      _editController.text = cat.name;
    });
  }

  Future<void> _saveEdit(AssetViewModel vm) async {
    final name = _editController.text.trim();
    if (name.isEmpty || _editingId == null) return;
    await vm.updateCategory(widget.token, _editingId!, name);
    setState(() => _editingId = null);
  }

  // ── Delete confirm ────────────────────────────────────────────────────────
  void _confirmDelete(
      BuildContext context, AssetViewModel vm, AssetCategoryModel cat) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Category',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _textPrimary)),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 13, color: _textMuted),
            children: [
              const TextSpan(text: 'Delete '),
              TextSpan(
                text: '"${cat.name}"',
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: _textPrimary),
              ),
              const TextSpan(
                  text: '? Assets under this category will lose their category.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: _textPrimary),
            child: const Text('Cancel',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _errorRed,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            onPressed: () {
              Navigator.pop(context);
              vm.deleteCategory(widget.token, cat.id);
            },
            child: const Text('Delete',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ── 3-dot popup menu ──────────────────────────────────────────────────────
  void _showPopupMenu(
      BuildContext context, AssetViewModel vm, AssetCategoryModel cat) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
            button.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      items: [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: const [
              Icon(Icons.edit_outlined, size: 15, color: Color(0xFF185FA5)),
              SizedBox(width: 8),
              Text('Edit',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1B1E28))),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: const [
              Icon(Icons.delete_outline, size: 15, color: Color(0xFFD92D20)),
              SizedBox(width: 8),
              Text('Delete',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFD92D20))),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 'edit') _startEdit(cat);
      if (value == 'delete') _confirmDelete(context, vm, cat);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AssetViewModel>(
      builder: (context, vm, _) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 420,
            constraints: const BoxConstraints(maxHeight: 560),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ─────────────────────────────────────────────
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _brandBlueBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.category_outlined,
                          color: _brandBlue, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Asset Categories',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: _textPrimary)),
                        Text('Add, edit or remove categories',
                            style:
                                TextStyle(fontSize: 12, color: _textMuted)),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close,
                          size: 18, color: _textMuted),
                      splashRadius: 18,
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(color: _borderColor, height: 1),
                const SizedBox(height: 12),

                // ── Add new category ────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _addController,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Category name...',
                          hintStyle: const TextStyle(
                              fontSize: 13, color: _textMuted),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: _borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: _brandBlue, width: 1.5),
                          ),
                        ),
                        onSubmitted: (_) => _onAdd(vm),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _addLoading ? null : () => _onAdd(vm),
                      icon: _addLoading
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.add, size: 16),
                      label: const Text('Add',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _brandBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(color: _borderColor, height: 1),
                const SizedBox(height: 4),

                // ── Category list ───────────────────────────────────────
                Flexible(
                  child: vm.categories.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text('No categories yet.',
                                style: TextStyle(
                                    color: _textMuted, fontSize: 13)),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: vm.categories.length,
                          separatorBuilder: (_, __) =>
                              const Divider(color: _borderColor, height: 1),
                          itemBuilder: (context, i) {
                            final cat = vm.categories[i];
                            final isEditing = _editingId == cat.id;

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  // Icon
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: _brandBlueBg,
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                        Icons.label_outline,
                                        size: 14,
                                        color: _brandBlue),
                                  ),
                                  const SizedBox(width: 10),

                                  // Name / inline edit
                                  Expanded(
                                    child: isEditing
                                        ? TextField(
                                            controller: _editController,
                                            autofocus: true,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: _textPrimary,
                                            ),
                                            decoration: InputDecoration(
                                              isDense: true,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 8),
                                              filled: true,
                                              fillColor:
                                                  const Color(0xFFF9FAFB),
                                              enabledBorder:
                                                  OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: const BorderSide(
                                                    color: _borderColor),
                                              ),
                                              focusedBorder:
                                                  OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: const BorderSide(
                                                    color: _brandBlue,
                                                    width: 1.5),
                                              ),
                                            ),
                                            onSubmitted: (_) =>
                                                _saveEdit(vm),
                                          )
                                        : Text(
                                            cat.name,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: _textPrimary,
                                            ),
                                          ),
                                  ),

                                  // Save/cancel bila editing, 3-dot bila tidak
                                  if (isEditing) ...[
                                    IconButton(
                                      onPressed: () => _saveEdit(vm),
                                      icon: const Icon(Icons.check,
                                          size: 18,
                                          color: Color(0xFF3B6D11)),
                                      splashRadius: 18,
                                      tooltip: 'Save',
                                    ),
                                    IconButton(
                                      onPressed: () => setState(
                                          () => _editingId = null),
                                      icon: const Icon(Icons.close,
                                          size: 18, color: _textMuted),
                                      splashRadius: 18,
                                      tooltip: 'Cancel',
                                    ),
                                  ] else
                                    // ── 3-dot button ──
                                    Builder(
                                      builder: (btnContext) =>
                                          IconButton(
                                        onPressed: () => _showPopupMenu(
                                            btnContext, vm, cat),
                                        icon: const Icon(
                                            Icons.more_vert,
                                            size: 18,
                                            color: _textMuted),
                                        splashRadius: 18,
                                        tooltip: 'Options',
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}