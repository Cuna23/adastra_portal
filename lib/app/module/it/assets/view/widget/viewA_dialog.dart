import 'package:flutter/material.dart';
import '../../model/asset_model.dart';

class ViewADialog extends StatelessWidget {
  final AssetModel asset;

  const ViewADialog({super.key, required this.asset});

  static const _brandBlue   = Color(0xFF185FA5);
  static const _brandBlueBg = Color(0xFFE6F1FB);
  static const _textPrimary = Color(0xFF1B1E28);
  static const _textMuted   = Color(0xFF9CA3AF);
  static const _borderColor = Color(0xFFE5E7EB);

  static const _availGreen   = Color(0xFF3B6D11);
  static const _availGreenBg = Color(0xFFEAF3DE);
  static const _maintAmber   = Color(0xFF854F0B);
  static const _maintAmberBg = Color(0xFFFAEEDA);
  static const _dispGray     = Color(0xFF5F5E5A);
  static const _dispGrayBg   = Color(0xFFF1EFE8);

  ({Color bg, Color fg}) _statusColors(String? status) {
    switch (status) {
      case 'Pending':
        return (bg: _brandBlueBg, fg: _brandBlue);
      case 'Available':
        return (bg: _availGreenBg, fg: _availGreen);
      case 'Maintenance':
        return (bg: _maintAmberBg, fg: _maintAmber);
      case 'Disposed':
        return (bg: _dispGrayBg, fg: _dispGray);
      default:
        return (bg: _dispGrayBg, fg: _dispGray);
    }
  }

  // ── Readonly field box — mirrors editA_dialog's TextFormField look ───────
  Widget _readonlyField(String label, String? value, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _borderColor, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: _textMuted),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: _textMuted),
                ),
                const SizedBox(height: 2),
                Text(
                  (value == null || value.trim().isEmpty) ? '—' : value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: _textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Readonly field box with pill value (category/status) ─────────────────
  Widget _readonlyPillField(String label, String text,
      {required Color bg, required Color fg, IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _borderColor, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: _textMuted),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: _textMuted),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: fg,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Responsive row helper — identical to editA_dialog's _fieldRow ─────────
  Widget _fieldRow(BuildContext context, Widget a, Widget b) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 500) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [a, const SizedBox(height: 14), b],
          );
        }
        return Row(
          children: [
            Expanded(child: a),
            const SizedBox(width: 12),
            Expanded(child: b),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sc = _statusColors(asset.status);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 900),
        width: MediaQuery.of(context).size.width * 0.85,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _brandBlueBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.inventory_2_outlined,
                        color: _brandBlue, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Asset Detail',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: _textPrimary)),
                        Text(
                          asset.assetTag,
                          style:
                              const TextStyle(fontSize: 12, color: _textMuted),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close,
                        size: 20, color: _textMuted),
                    onPressed: () => Navigator.pop(context),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Field grid — same 2-column pattern as editA_dialog ────
              Column(
                children: [
                  // Asset Tag + Category
                  _fieldRow(
                    context,
                    _readonlyField('Asset Tag', asset.assetTag,
                        icon: Icons.qr_code),
                    asset.categoryName != null
                        ? _readonlyPillField(
                            'Category',
                            asset.categoryName!,
                            bg: _brandBlueBg,
                            fg: _brandBlue,
                            icon: Icons.category_outlined,
                          )
                        : _readonlyField('Category', null,
                            icon: Icons.category_outlined),
                  ),

                  const SizedBox(height: 14),

                  // Brand + Model
                  _fieldRow(
                    context,
                    _readonlyField('Brand', asset.brand,
                        icon: Icons.business_outlined),
                    _readonlyField('Model', asset.model,
                        icon: Icons.devices_outlined),
                  ),

                  const SizedBox(height: 14),

                  // Serial + Status
                  _fieldRow(
                    context,
                    _readonlyField('Serial Number', asset.serialNumber,
                        icon: Icons.confirmation_number_outlined),
                    _readonlyPillField(
                      'Status',
                      asset.status ?? '—',
                      bg: sc.bg,
                      fg: sc.fg,
                      icon: Icons.toggle_on_outlined,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Employee ID + Department
                  _fieldRow(
                    context,
                    _readonlyField('Employee ID', asset.empId,
                        icon: Icons.badge_outlined),
                    _readonlyField('Department', asset.department,
                        icon: Icons.apartment_outlined),
                  ),

                  const SizedBox(height: 14),

                  // Assigned To + Approved By
                  _fieldRow(
                    context,
                    _readonlyField('Assigned To', asset.assignedTo,
                        icon: Icons.person_outline),
                    _readonlyField('Approved By', asset.approvedBy,
                        icon: Icons.verified_user_outlined),
                  ),

                  const SizedBox(height: 14),

                  // Purchased By — full width
                  _readonlyField('Purchased By', asset.purchasedBy,
                      icon: Icons.shopping_cart_outlined),

                  const SizedBox(height: 14),

                  // Remark
                  _readonlyField('Remark', asset.remark,
                      icon: Icons.notes_outlined),

                  const SizedBox(height: 24),

                  // ── Close button — full width ─────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _brandBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}