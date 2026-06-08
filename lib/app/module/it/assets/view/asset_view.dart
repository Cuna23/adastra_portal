import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/assetCategory_model.dart';
import '../view model/asset_vm.dart';
import '../model/asset_model.dart';
import 'widget/createA_dialog.dart';
import 'widget/tableA.dart';

class AssetView extends StatefulWidget {
  final String role;
  final String token;

  const AssetView({
    super.key,
    required this.role,
    required this.token,
  });

  @override
  State<AssetView> createState() => _AssetViewState();
}

class _AssetViewState extends State<AssetView> {
  final Set<int> _selectedIds    = {};
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  // ── Exact same brand tokens as UserManagementPage ──────────────────────
  static const _brandBlue       = Color(0xFF185FA5);
  static const _brandBlueBg     = Color(0xFFE6F1FB);
  static const _brandBlueBorder = Color(0xFF85B7EB);
  static const _textPrimary     = Color(0xFF1B1E28);
  static const _textSecondary   = Color(0xFF6B7280);
  static const _borderColor     = Color(0xFFE5E7EB);

  bool get _hasSelection => _selectedIds.isNotEmpty;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final vm = context.read<AssetViewModel>();
      vm.fetchCategories(widget.token);
      vm.fetchAssets(widget.token);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ── Selection helpers (same pattern as UserManagementPage) ──────────────
  void _toggleAll(List<AssetModel> assets, bool? value) {
    setState(() {
      if (value == true) {
        _selectedIds.addAll(assets.map((a) => a.id));
      } else {
        _selectedIds.clear();
      }
    });
  }

  void _toggleRow(int id, bool? value) {
    setState(() {
      value == true ? _selectedIds.add(id) : _selectedIds.remove(id);
    });
  }

  //── Dialogs ─────────────────────────────────────────────────────────────
  void _openCreateDialog() {
    showDialog(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<AssetViewModel>(),
        child: CreateADialog(token: widget.token),
      ),
    );
  }

  void _confirmDelete(AssetModel asset, AssetViewModel vm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Delete Asset',
          style: TextStyle(color: _textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete '
          '"${asset.brand ?? ''} ${asset.model ?? ''}" (${asset.assetTag})?',
          style: const TextStyle(color: _textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: _brandBlue),
            child: const Text('Cancel',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () {
              Navigator.pop(context);
              setState(() => _selectedIds.remove(asset.id));
              vm.removeAsset(asset.id, widget.token);
            },
            child: const Text('Delete',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _onClone(List<AssetModel> assets) {
    final selected =
        assets.where((a) => _selectedIds.contains(a.id)).toList();

    if (selected.length != 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select exactly 1 asset to clone'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<AssetViewModel>(),
        // child: CloneADialog(
        //   token: widget.token,
        //   asset: selected.first,
        // ),
      ),
    );
  }

  // ── Shared button builders ───────────────────────────────────────────────

  Widget _exportBtn() => ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.download_outlined, size: 16),
        label: const Text('Export Excel'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEAF3DE),
          foregroundColor: const Color(0xFF3B6D11),
          elevation: 0,
          side: const BorderSide(color: Color(0xFFB8D8A0), width: 0.5),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

  Widget _cloneBtn(AssetViewModel vm) => ElevatedButton.icon(
        onPressed: _hasSelection ? () => _onClone(vm.assets) : null,
        icon: const Icon(Icons.copy_outlined, size: 16),
        label: const Text('Clone'),
        style: ElevatedButton.styleFrom(
          backgroundColor: _brandBlueBg,
          foregroundColor: _brandBlue,
          disabledBackgroundColor: const Color(0xFFF1EFE8),
          disabledForegroundColor: _textSecondary,
          elevation: 0,
          side: BorderSide(
            color: _hasSelection ? _brandBlueBorder : _borderColor,
            width: 0.5,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

  Widget _addBtn() => ElevatedButton.icon(
        onPressed: _openCreateDialog,
        icon: const Icon(Icons.add, size: 16),
        label: const Text('Add Asset'),
        style: ElevatedButton.styleFrom(
          backgroundColor: _brandBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

  Widget _searchField(AssetViewModel vm) => TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search assets...',
          prefixIcon: const Icon(Icons.search),
          isDense: true,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _borderColor),
          ),
        ),
        onChanged: (value) => vm.fetchAssets(widget.token, search: value),
      );

  // ── Desktop toolbar (single row) ─────────────────────────────────────────

  Widget _buildDesktopToolbar(AssetViewModel vm) {
    return Row(
      children: [
        if (_hasSelection) ...[
          _selectedBadge(),
          const SizedBox(width: 10),
        ],
        SizedBox(width: 320, child: _searchField(vm)),
        const Spacer(),
        const SizedBox(width: 10),
        _exportBtn(),
        const SizedBox(width: 10),
        _cloneBtn(vm),
        const SizedBox(width: 10),
        _addBtn(),
      ],
    );
  }

  // ── Mobile toolbar (two rows) ─────────────────────────────────────────────

  Widget _buildMobileToolbar(AssetViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Row 1: selected badge + search full width
        Row(
          children: [
            if (_hasSelection) ...[
              _selectedBadge(),
              const SizedBox(width: 8),
            ],
            Expanded(child: _searchField(vm)),
          ],
        ),
        const SizedBox(height: 10),
        // Row 2: action buttons — wrap if needed
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _exportBtn(),
            _cloneBtn(vm),
            _addBtn(),
          ],
        ),
      ],
    );
  }

  Widget _selectedBadge() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: _brandBlueBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '${_selectedIds.length} selected',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _brandBlue,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Consumer<AssetViewModel>(
      builder: (context, vm, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Category tab bar ──────────────────────────────────────────
            if (vm.categories.isNotEmpty)
              _CategoryTabBar(
                categories: vm.categories,
                selectedId: vm.selectedCategoryId,
                onSelect: (id) {
                  setState(() => _selectedIds.clear());
                  vm.selectCategory(id, widget.token);
                },
              ),

            // ── Toolbar row — responsive ──────────────────────────────
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                  child: isMobile
                      ? _buildMobileToolbar(vm)
                      : _buildDesktopToolbar(vm),
                );
              },
            ),

            // ── Table ─────────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: AssetTable(
                  role: widget.role,
                  token: widget.token,
                  selectedIds: _selectedIds,
                  scrollController: _scrollController,
                  onToggleAll: _toggleAll,
                  onToggleRow: _toggleRow,
                  onDelete: (asset) => _confirmDelete(asset, vm), 
                ),
              ),
            ),

          ],
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Category Tab Bar
// ═══════════════════════════════════════════════════════════════════════════════

class _CategoryTabBar extends StatelessWidget {
  final List<AssetCategoryModel> categories;
  final int? selectedId;
  final void Function(int? id) onSelect;

  const _CategoryTabBar({
    required this.categories,
    required this.selectedId,
    required this.onSelect,
  });

  IconData _iconFor(String name) {
    final n = name.toLowerCase();
    if (n.contains('computer') || n.contains('laptop')) return Icons.laptop_mac_outlined;
    if (n.contains('phone') || n.contains('mobile'))    return Icons.smartphone_outlined;
    if (n.contains('network') || n.contains('router'))  return Icons.router_outlined;
    if (n.contains('printer'))                          return Icons.print_outlined;
    if (n.contains('monitor') || n.contains('display')) return Icons.monitor_outlined;
    if (n.contains('software'))                         return Icons.window_outlined;
    return Icons.devices_other_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          _Tab(
            label: 'All',
            icon: Icons.widgets_outlined,
            selected: selectedId == null,
            onTap: () => onSelect(null),
          ),
          ...categories.map(
            (c) => _Tab(
              label: c.name,
              icon: _iconFor(c.name),
              selected: selectedId == c.id,
              onTap: () => onSelect(c.id),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  static const _brandBlue   = Color(0xFF185FA5);
  static const _borderColor = Color(0xFFE5E7EB);
  static const _textPrimary = Color(0xFF1B1E28);
  static const _textMuted   = Color(0xFF9CA3AF);

  const _Tab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 6, bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
        decoration: BoxDecoration(
          color: selected ? _brandBlue : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? _brandBlue : _borderColor,
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: selected ? Colors.white : _textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? Colors.white : _textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}