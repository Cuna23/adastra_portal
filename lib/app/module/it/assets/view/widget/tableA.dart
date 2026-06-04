import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/asset_model.dart';
import '../../view model/asset_vm.dart';

class AssetTable extends StatelessWidget {
  
  final String role;
  final String token;
  final Set<int> selectedIds;
  final ScrollController scrollController;
  final void Function(List<AssetModel> assets, bool? value) onToggleAll;
  final void Function(int id, bool? value) onToggleRow;
  final void Function(AssetModel asset) onDelete;

  // ── Exact same tokens as tableU.dart ──────────────────────────────────────
  static const _brandBlue      = Color(0xFF185FA5);
  static const _brandBlueBg    = Color(0xFFE6F1FB);
  static const _textPrimary    = Color(0xFF1B1E28);
  static const _textSecondary  = Color(0xFF6B7280);
  static const _textMuted      = Color(0xFF9CA3AF);
  static const _borderColor    = Color(0xFFE5E7EB);

  // Status pill colours
  static const _availGreen     = Color(0xFF3B6D11);
  static const _availGreenBg   = Color(0xFFEAF3DE);
  static const _assignBlue     = Color(0xFF185FA5);
  static const _assignBlueBg   = Color(0xFFE6F1FB);
  static const _maintAmber     = Color(0xFF854F0B);
  static const _maintAmberBg   = Color(0xFFFAEEDA);
  static const _dispGray       = Color(0xFF5F5E5A);
  static const _dispGrayBg     = Color(0xFFF1EFE8);

  // Fixed column widths — triggers horizontal scroll when screen is narrow
  static const double _wCheck   = 44.0;
  static const double _wAsset   = 200.0;
  static const double _wSerial  = 150.0;
  static const double _wCat     = 140.0;
  static const double _wStatus  = 120.0;
  static const double _wAssign  = 160.0;
  static const double _wDept    = 140.0;
  static const double _wEmpId     = 120.0;
  static const double _wPurchase  = 180.0;
  static const double _wRemark    = 250.0;
  static const double _wActions = 96.0;

  static const double _minWidth =
      _wCheck + _wAsset + _wSerial + _wCat + _wStatus + _wAssign + _wDept + _wEmpId + _wPurchase + _wRemark + _wActions;

  const AssetTable({
    super.key,
    required this.role,
    required this.token,
    required this.selectedIds,
    required this.scrollController,
    required this.onToggleAll,
    required this.onToggleRow,
    required this.onDelete,
  });

  // ── Helpers ──────────────────────────────────────────────────────────────

  String _statusLabel(String? s) => s ?? '—';

({Color bg, Color fg}) _statusColors(String? status) {
  switch (status) {
    case 'Pending':
      return (
        bg: Color(0xFFE6F1FB),
        fg: Color(0xFF185FA5)
      );

    case 'Available':
      return (
        bg: _availGreenBg,
        fg: _availGreen
      );

    case 'Maintenance':
      return (
        bg: _maintAmberBg,
        fg: _maintAmber
      );

    case 'Dispose':
      return (
        bg: _dispGrayBg,
        fg: _dispGray
      );

    default:
      return (
        bg: _dispGrayBg,
        fg: _dispGray
      );
  }
}

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Consumer<AssetViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final allSelected =
            vm.assets.isNotEmpty && selectedIds.length == vm.assets.length;
        final someSelected =
            selectedIds.isNotEmpty && selectedIds.length < vm.assets.length;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _borderColor),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Column(
              children: [
                // Sticky header
                _buildHeader(
                  allSelected: allSelected,
                  someSelected: someSelected,
                  assets: vm.assets,
                ),
                const Divider(height: 0.5, thickness: 0.5, color: _borderColor),

                // Scrollable rows
                Expanded(
                  child: vm.assets.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.inventory_2_outlined,
                                  size: 32, color: _textMuted),
                              SizedBox(height: 8),
                              Text('No assets found.',
                                  style: TextStyle(
                                      color: _textSecondary, fontSize: 13)),
                            ],
                          ),
                        )
                      : Scrollbar(
                          controller: scrollController,
                          thumbVisibility: true,
                          child: ListView.separated(
                            controller: scrollController,
                            itemCount: vm.assets.length,
                            separatorBuilder: (_, __) => const Divider(
                                height: 0.5,
                                thickness: 0.5,
                                color: _borderColor),
                            itemBuilder: (context, i) =>
                                _buildRow(context, vm.assets[i], vm),
                          ),
                        ),
                ),

                // Footer
                const Divider(height: 0.5, thickness: 0.5, color: _borderColor),
                _buildFooter(vm),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Scroll wrapper — horizontal scroll when viewport < minWidth ──────────

  Widget _hscroll(Widget child) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: _minWidth),
        child: child,
      ),
    );
  }

  // ── Header row ───────────────────────────────────────────────────────────

  Widget _buildHeader({
    required bool allSelected,
    required bool someSelected,
    required List<AssetModel> assets,
  }) {
    return Container(
      color: const Color(0xFFF8F9FB),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: _hscroll(
        Row(
          children: [
            SizedBox(
              width: _wCheck,
              child: Checkbox(
                value: allSelected ? true : (someSelected ? null : false),
                tristate: true,
                activeColor: _brandBlue,
                onChanged: (v) =>
                    onToggleAll(assets, someSelected || allSelected ? false : true),
              ),
            ),
            _hLabel('ASSET TAG',   _wAsset),
            _hLabel('SERIAL',      _wSerial),
            _hLabel('CATEGORY',    _wCat),
            _hLabel('STATUS',      _wStatus),
            _hLabel('ASSIGNED TO', _wAssign),
            _hLabel('DEPARTMENT',  _wDept),
            _hLabel('PURCHASED BY', _wPurchase),
            _hLabel('REMARK', _wRemark),
            SizedBox(
              width: _wActions,
              child: const Text(
                'ACTIONS',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _textMuted,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hLabel(String text, double width) => SizedBox(
        width: width,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _textMuted,
            letterSpacing: 0.5,
          ),
        ),
      );

  // ── Data row ─────────────────────────────────────────────────────────────

  Widget _buildRow(BuildContext context, AssetModel asset, AssetViewModel vm) {
    final isSelected = selectedIds.contains(asset.id);
    final sc = _statusColors(asset.status);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      color: isSelected ? _brandBlueBg.withOpacity(0.5) : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: _hscroll(
        Row(
          children: [
            // Checkbox
            SizedBox(
              width: _wCheck,
              child: Checkbox(
                value: isSelected,
                activeColor: _brandBlue,
                onChanged: (v) => onToggleRow(asset.id, v),
              ),
            ),

            // Asset tag + brand/model stacked (mirrors user name+email)
            SizedBox(
              width: _wAsset,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${asset.brand ?? ''} ${asset.model ?? ''}'.trim().isEmpty
                        ? '—'
                        : '${asset.brand ?? ''} ${asset.model ?? ''}'.trim(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    asset.assetTag,
                    style: const TextStyle(
                        fontSize: 11, color: _textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Serial
            SizedBox(
              width: _wSerial,
              child: Text(
                asset.serialNumber ?? '—',
                style: const TextStyle(
                    fontSize: 13, color: _textSecondary),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Category — same badge style as role pill in tableU
            SizedBox(
              width: _wCat,
              child: asset.categoryName != null
                  ? _pill(
                      asset.categoryName!,
                      bg: _brandBlueBg,
                      fg: _brandBlue,
                    )
                  : const Text('—',
                      style: TextStyle(fontSize: 13, color: _textMuted)),
            ),

            // Status pill — same badge style as status pill in tableU
            SizedBox(
              width: _wStatus,
              child: _pill(
                _statusLabel(asset.status),
                bg: sc.bg,
                fg: sc.fg,
              ),
            ),

            // Assigned to
            SizedBox(
              width: _wAssign,
              child: Text(
                asset.assignedTo ?? '—',
                style: const TextStyle(fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Department
            SizedBox(
              width: _wDept,
              child: Text(
                asset.department ?? '—',
                style: const TextStyle(
                    fontSize: 13, color: _textSecondary),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            SizedBox(
              width: _wEmpId,
              child: Text(
                asset.empId ?? '—',
                overflow: TextOverflow.ellipsis,
              ),
            ),

            SizedBox(
              width: _wPurchase,
              child: Text(
                asset.purchasedBy ?? '—',
                overflow: TextOverflow.ellipsis,
              ),
            ),

            SizedBox(
              width: _wRemark,
              child: Text(
                asset.remark ?? '—',
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Edit + Delete — mirrors tableU action buttons exactly
            SizedBox(
              width: _wActions,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Edit
                  IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        size: 17, color: _textSecondary),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => ChangeNotifierProvider.value(
                        value: context.read<AssetViewModel>(),
                        //child: EditADialog(token: token, asset: asset),
                      ),
                    ),
                    tooltip: 'Edit',
                    visualDensity: VisualDensity.compact,
                  ),
                  // Delete
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      size: 17,
                      color: role == 'super_admin' || role == 'admin'
                          ? Colors.red
                          : Colors.red.withOpacity(0.3),
                    ),
                    onPressed: role == 'super_admin' || role == 'admin'
                        ? () => onDelete(asset)
                        : null,
                    tooltip: role == 'super_admin' || role == 'admin'
                        ? 'Delete'
                        : 'Restricted',
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Footer ───────────────────────────────────────────────────────────────

  Widget _buildFooter(AssetViewModel vm) {
  final pending =
    vm.assets.where(
      (a) => a.status == 'Pending'
    ).length;

  final available =
      vm.assets.where(
        (a) => a.status == 'Available'
      ).length;

  final maintenance =
      vm.assets.where(
        (a) => a.status == 'Maintenance'
      ).length;

  final dispose =
      vm.assets.where(
        (a) => a.status == 'Dispose'
      ).length;

    return Container(
      color: const Color(0xFFF8F9FB),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.inventory_2_outlined, size: 14, color: _textMuted),
          const SizedBox(width: 6),
          Text(
            'Total Assets: ${vm.total > 0 ? vm.total : vm.assets.length}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _textSecondary,
            ),
          ),
          const Spacer(),
          if (available > 0) ...[
            Text('$available available',
                style: const TextStyle(
                    fontSize: 11, color: _availGreen, fontWeight: FontWeight.w500)),
            const SizedBox(width: 12),
          ],
          if (maintenance > 0)
            Text('$maintenance maintenance',
                style: const TextStyle(
                    fontSize: 11, color: _maintAmber, fontWeight: FontWeight.w500)),
          if (dispose > 0)
            Text('$dispose disposed',
                style: const TextStyle(
                    fontSize: 11, color: _dispGray, fontWeight: FontWeight.w500)),

          // Pagination
          if (vm.lastPage > 1) ...[
            const SizedBox(width: 16),
            _PaginationRow(vm: vm, token: token),
          ],
        ],
      ),
    );
  }

  // ── Shared pill widget (same as role/status pills in tableU) ─────────────

  Widget _pill(String text, {required Color bg, required Color fg}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: fg,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Pagination row (shown in footer)
// ═══════════════════════════════════════════════════════════════════════════════

class _PaginationRow extends StatelessWidget {
  final AssetViewModel vm;
  final String token;

  static const _brandBlue   = Color(0xFF185FA5);
  static const _borderColor = Color(0xFFE5E7EB);
  static const _textMuted   = Color(0xFF9CA3AF);
  static const _textPrimary = Color(0xFF1B1E28);

  const _PaginationRow({required this.vm, required this.token});

  @override
  Widget build(BuildContext context) {
    final cur  = vm.currentPage;
    final last = vm.lastPage;
    final from = vm.total == 0 ? 0 : (cur - 1) * vm.perPage + 1;
    final to   = (cur * vm.perPage).clamp(0, vm.total);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$from–$to of ${vm.total}',
            style: const TextStyle(fontSize: 11, color: _textMuted)),
        const SizedBox(width: 8),
        _pageBtn(
          icon: Icons.chevron_left,
          enabled: cur > 1,
          onTap: () => vm.fetchAssets(token, page: cur - 1),
        ),
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _brandBlue,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text('$cur',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 4),
        _pageBtn(
          icon: Icons.chevron_right,
          enabled: cur < last,
          onTap: () => vm.fetchAssets(token, page: cur + 1),
        ),
      ],
    );
  }

  Widget _pageBtn({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: _borderColor, width: 0.5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon,
            size: 16,
            color: enabled ? const Color(0xFF1B1E28) : _textMuted),
      ),
    );
  }
}