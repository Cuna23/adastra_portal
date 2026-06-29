import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/asset_model.dart';
import '../../view model/asset_vm.dart';

class CloneADialog extends StatefulWidget {
  final String token;
  final AssetModel asset;

  const CloneADialog({
    super.key,
    required this.token,
    required this.asset,
  });

  @override
  State<CloneADialog> createState() => _CloneADialogState();
}

class _CloneADialogState extends State<CloneADialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController assetTagController;
  late final TextEditingController serialController;
  late final TextEditingController brandController;
  late final TextEditingController modelController;
  late final TextEditingController empIdController;
  late final TextEditingController remarkController;

  int?    categoryId;
  late String  status;
  String? selectedDepartment;
  String? selectedAssignedTo;
  String? selectedApprovedBy;
  String? selectedPurchasedBy;

  String? _assetTagServerError; // backend duplicate asset_tag error

  static const _brandBlue   = Color(0xFF185FA5);
  static const _brandBlueBg = Color(0xFFE6F1FB);
  static const _textPrimary = Color(0xFF1B1E28);
  static const _textMuted   = Color(0xFF9CA3AF);
  static const _borderColor = Color(0xFFE5E7EB);
  static const _errorRed    = Color(0xFFD92D20);

  @override
  void initState() {
    super.initState();

    // Pre-fill dari asset asal — user kena tukar Asset Tag (must be unique)
    assetTagController = TextEditingController(text: '');
    serialController   = TextEditingController(text: widget.asset.serialNumber ?? '');
    brandController    = TextEditingController(text: widget.asset.brand ?? '');
    modelController    = TextEditingController(text: widget.asset.model ?? '');
    empIdController    = TextEditingController(text: widget.asset.empId ?? '');
    remarkController   = TextEditingController(text: widget.asset.remark ?? '');

    categoryId          = widget.asset.categoryId;
    status              = widget.asset.status ?? 'Pending';
    selectedDepartment  = widget.asset.department;
    selectedAssignedTo  = widget.asset.assignedTo;
    selectedApprovedBy  = widget.asset.approvedBy;
    selectedPurchasedBy = widget.asset.purchasedBy;

    // Clear server error bila user mula taip asset tag baru
    assetTagController.addListener(() {
      if (_assetTagServerError != null) {
        setState(() => _assetTagServerError = null);
      }
    });

    Future.microtask(() {
      final vm = context.read<AssetViewModel>();
      vm.fetchUsers(widget.token);
      vm.fetchDepartments(widget.token);
    });
  }

  @override
  void dispose() {
    assetTagController.dispose();
    serialController.dispose();
    brandController.dispose();
    modelController.dispose();
    empIdController.dispose();
    remarkController.dispose();
    super.dispose();
  }

  // ── Field decoration ──────────────────────────────────────────────────────

  InputDecoration _fieldDecoration(String label, {IconData? icon, String? helperText}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 13, color: _textMuted),
      prefixIcon: icon != null
          ? Icon(icon, size: 18, color: _textMuted)
          : null,
      helperText: helperText,
      helperStyle: const TextStyle(fontSize: 11, color: _textMuted),
      helperMaxLines: 2,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _brandBlue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _errorRed, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _errorRed, width: 1.5),
      ),
      errorMaxLines: 2,
    );
  }

  // ── Responsive row helper ─────────────────────────────────────────────────
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

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Consumer<AssetViewModel>(
      builder: (context, vm, _) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
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
                  // ── Header ───────────────────────────────────────────
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _brandBlueBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                            Icons.copy_outlined,
                            color: _brandBlue,
                            size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Clone Asset',
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: _textPrimary)),
                          Text(
                            'Cloning from: ${widget.asset.assetTag}',
                            style: const TextStyle(
                                fontSize: 12, color: _textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Asset Tag (kosong — user kena isi baru) + Category
                        _fieldRow(
                          context,
                          TextFormField(
                            controller: assetTagController,
                            style: const TextStyle(
                              color: _textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: _fieldDecoration(
                              'Asset Tag',
                              icon: Icons.qr_code,
                              helperText: 'Must be unique — enter a new tag',
                            ).copyWith(
                              errorText: _assetTagServerError,
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.center_focus_strong),
                                tooltip: 'Scan Barcode',
                                onPressed: () {},
                              ),
                            ),
                            validator: (v) =>
                                v!.isEmpty ? 'Asset Tag is required' : null,
                          ),
                          DropdownButtonFormField<int>(
                            value: categoryId,
                            iconEnabledColor: _textMuted,
                            style: const TextStyle(
                                color: _textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w500),
                            decoration: _fieldDecoration('Category',
                                icon: Icons.category_outlined),
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            items: [
                              ...vm.categories.map((c) => DropdownMenuItem<int>(
                                    value: c.id,
                                    child: Text(c.name),
                                  )),
                            ],
                            validator: (v) =>
                                v == null ? 'Select category' : null,
                            onChanged: (v) async {
                              setState(() => categoryId = v);
                            },
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Brand + Model
                        _fieldRow(
                          context,
                          TextFormField(
                            controller: brandController,
                            style: const TextStyle(
                              color: _textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: _fieldDecoration('Brand',
                                icon: Icons.business_outlined),
                          ),
                          TextFormField(
                            controller: modelController,
                            style: const TextStyle(
                              color: _textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration:
                                _fieldDecoration('Model', icon: Icons.devices_outlined)
                                    .copyWith(
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.center_focus_strong),
                                tooltip: 'Scan Barcode',
                                onPressed: () {},
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Serial + Status
                        _fieldRow(
                          context,
                          TextFormField(
                            controller: serialController,
                            style: const TextStyle(
                              color: _textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: _fieldDecoration('Serial Number',
                                    icon: Icons.confirmation_number_outlined)
                                .copyWith(
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.center_focus_strong),
                                tooltip: 'Scan Barcode',
                                onPressed: () {},
                              ),
                            ),
                          ),
                          DropdownButtonFormField<String>(
                            value: status,
                            iconEnabledColor: _textMuted,
                            style: const TextStyle(
                                color: _textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w500),
                            decoration: _fieldDecoration('Status',
                                icon: Icons.toggle_on_outlined),
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            items: const [
                              DropdownMenuItem(
                                  value: 'Pending', child: Text('Pending')),
                              DropdownMenuItem(
                                  value: 'Available', child: Text('Available')),
                              DropdownMenuItem(
                                  value: 'Maintenance',
                                  child: Text('Maintenance')),
                              DropdownMenuItem(
                                  value: 'Disposed', child: Text('Disposed')),
                            ],
                            onChanged: (v) => setState(() => status = v!),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Employee ID + Department
                        _fieldRow(
                          context,
                          TextFormField(
                            controller: empIdController,
                            style: const TextStyle(
                              color: _textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: _fieldDecoration('Employee ID',
                                icon: Icons.badge_outlined),
                          ),
                          DropdownButtonFormField<String>(
                            value: selectedDepartment,
                            iconEnabledColor: _textMuted,
                            style: const TextStyle(
                                color: _textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w500),
                            decoration: _fieldDecoration('Department',
                                icon: Icons.apartment_outlined),
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            items: vm.departments.map((dept) {
                              return DropdownMenuItem<String>(
                                value: dept.departmentName,
                                child: Text(dept.departmentName),
                              );
                            }).toList(),
                            onChanged: (v) =>
                                setState(() => selectedDepartment = v),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Assigned To + Approved By
                        _fieldRow(
                          context,
                          DropdownButtonFormField<String>(
                            value: selectedAssignedTo,
                            iconEnabledColor: _textMuted,
                            style: const TextStyle(
                                color: _textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w500),
                            decoration: _fieldDecoration('Assigned To',
                                icon: Icons.person_outline),
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            items: vm.users.map((user) {
                              return DropdownMenuItem<String>(
                                  value: user.name,
                                  child: Text(user.name));
                            }).toList(),
                            onChanged: (v) =>
                                setState(() => selectedAssignedTo = v),
                          ),
                          DropdownButtonFormField<String>(
                            value: selectedApprovedBy,
                            iconEnabledColor: _textMuted,
                            style: const TextStyle(
                                color: _textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w500),
                            decoration: _fieldDecoration('Approved By',
                                icon: Icons.verified_user_outlined),
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            items: vm.users.map((user) {
                              return DropdownMenuItem<String>(
                                  value: user.name,
                                  child: Text(user.name));
                            }).toList(),
                            onChanged: (v) =>
                                setState(() => selectedApprovedBy = v),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Purchased By — full width
                        DropdownButtonFormField<String>(
                          value: selectedPurchasedBy,
                          iconEnabledColor: _textMuted,
                          style: const TextStyle(
                              color: _textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w500),
                          decoration: _fieldDecoration('Purchased By',
                              icon: Icons.shopping_cart_outlined),
                          dropdownColor: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          items: vm.users.map((user) {
                            return DropdownMenuItem<String>(
                                value: user.name, child: Text(user.name));
                          }).toList(),
                          onChanged: (v) =>
                              setState(() => selectedPurchasedBy = v),
                        ),

                        const SizedBox(height: 14),

                        // Remark
                        TextFormField(
                          controller: remarkController,
                          style: const TextStyle(
                            color: _textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 3,
                          decoration: _fieldDecoration('Remark',
                              icon: Icons.notes_outlined),
                        ),

                        const SizedBox(height: 24),

                        // Cancel + Clone
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _textPrimary,
                                  side: const BorderSide(color: _borderColor),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 13),
                                ),
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _brandBlue,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 13),
                                ),
                                onPressed: () async {
                                  setState(() => _assetTagServerError = null);

                                  if (!_formKey.currentState!.validate()) return;

                                  try {
                                    await vm.createAsset(
                                      widget.token,
                                      {
                                        'asset_tag':     assetTagController.text,
                                        'serial_number': serialController.text,
                                        'brand':         brandController.text,
                                        'model':         modelController.text,
                                        'category_id':   categoryId,
                                        'status':        status,
                                        'emp_id':        empIdController.text,
                                        'department':    selectedDepartment,
                                        'assigned_to':   selectedAssignedTo,
                                        'approved_by':   selectedApprovedBy,
                                        'purchased_by':  selectedPurchasedBy,
                                        'remark':        remarkController.text,
                                      },
                                    );

                                    if (context.mounted) Navigator.pop(context);
                                  } catch (e) {
                                    final msg = e.toString().toLowerCase();
                                    if (msg.contains('asset_tag') ||
                                        msg.contains('asset tag') ||
                                        msg.contains('duplicate') ||
                                        msg.contains('already')) {
                                      setState(() {
                                        _assetTagServerError =
                                            'This Asset Tag already exists. Please use a different tag.';
                                      });
                                    } else {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Failed to clone asset: ${e.toString()}'),
                                            backgroundColor: _errorRed,
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                                child: const Text('Clone',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}