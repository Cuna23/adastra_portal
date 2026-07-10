import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../view model/sr_vm.dart';

class CreateSRDialog extends StatefulWidget {
  final String token;

  const CreateSRDialog({super.key, required this.token});

  @override
  State<CreateSRDialog> createState() => _CreateSRDialogState();
}

class _CreateSRDialogState extends State<CreateSRDialog> {
  static const _brandBlue   = Color(0xFF185FA5);
  static const _brandBlueBg = Color(0xFFE6F1FB);
  static const _textPrimary = Color(0xFF1B1E28);
  static const _textMuted   = Color(0xFF9CA3AF);
  static const _borderColor = Color(0xFFE5E7EB);

  final _formKey     = GlobalKey<FormState>();
  final _titleCtrl    = TextEditingController();
  final _descCtrl     = TextEditingController();

  String  _requestType = 'asset_request';
  String? _category;
  int     _quantity = 1;
  String  _priority = 'low';
  DateTime? _neededByDate;

  String? _attachmentName;
  List<int>? _attachmentBytes;

  static const _requestTypes = {
    'asset_request': 'Asset request',
    'software_installation': 'Software installation',
    'account_access': 'Account access',
    'other': 'Other',
  };

  static const _priorities = {
    'low': 'Low',
    'medium': 'Medium',
    'high': 'High',
  };

  static const Map<String, List<String>> _categoryOptions = {
    'asset_request': [
      'Laptop', 'Desktop', 'Monitor', 'Keyboard', 'Mouse',
      'Docking station', 'Laptop bag', 'Webcam', 'LAN cable',
      'Power cord', 'Power adapter',
    ],
    'software_installation': [
      'MS Office', 'Adobe', 'AutoCAD', 'Other',
    ],
    'account_access': [
      'Email account', 'System/application access',
      'VPN access', 'Shared drive access',
    ],
    'other': ['Other'],
  };

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 13, color: _textMuted),
      prefixIcon: icon != null ? Icon(icon, size: 18, color: _textMuted) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
        borderSide: const BorderSide(color: Color(0xFFD92D20), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD92D20), width: 1.5),
      ),
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;

    if (file.size > 5 * 1024 * 1024) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File exceeds 5MB limit')),
        );
      }
      return;
    }

    setState(() {
      _attachmentName = file.name;
      _attachmentBytes = file.bytes;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 3)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _neededByDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    if (_neededByDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select needed by date')),
      );
      return;
    }

    final vm = context.read<ServiceRequestViewModel>();
    final ok = await vm.createRequest(
      token: widget.token,
      requestTitle: _titleCtrl.text.trim(),
      requestType: _requestType,
      category: _category!,
      quantity: _quantity,
      priority: _priority,
      description: _descCtrl.text.trim(),
      neededByDate: _neededByDate!,
      attachmentBytes: _attachmentBytes,
      filename: _attachmentName,
    );

    if (!mounted) return;

    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Service request submitted successfully'),
          backgroundColor: Color(0xFF3B6D11),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.error ?? 'Failed to submit service request'),
          backgroundColor: const Color(0xFFA32D2D),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryOptions = _categoryOptions[_requestType] ?? [];

    return Consumer<ServiceRequestViewModel>(
      builder: (context, vm, _) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 560),
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

                  // ── Header ──
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _brandBlueBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.add_circle_outline,
                            color: _brandBlue, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'New service request',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: _textPrimary,
                            ),
                          ),
                          Text(
                            'Submit a request for an asset, software, or access',
                            style: TextStyle(fontSize: 12, color: _textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [

                        // Request title
                        TextFormField(
                          controller: _titleCtrl,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500, color: _textPrimary),
                          decoration: _fieldDecoration('Request title', icon: Icons.title_outlined),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                        ),

                        const SizedBox(height: 14),

                        // Request type
                        DropdownButtonFormField<String>(
                          value: _requestType,
                          iconEnabledColor: _textMuted,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500, color: _textPrimary),
                          decoration: _fieldDecoration('Request type', icon: Icons.apps_outlined),
                          dropdownColor: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          items: _requestTypes.entries
                              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                              .toList(),
                          onChanged: (v) => setState(() {
                            _requestType = v!;
                            _category = null; // reset category bila type berubah
                          }),
                        ),

                        const SizedBox(height: 14),

                        // Category (depends on request type)
                        DropdownButtonFormField<String>(
                          value: _category,
                          iconEnabledColor: _textMuted,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500, color: _textPrimary),
                          decoration: _fieldDecoration('Category', icon: Icons.category_outlined),
                          dropdownColor: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          hint: const Text('Select category', style: TextStyle(fontSize: 14)),
                          items: categoryOptions
                              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (v) => setState(() => _category = v),
                        ),

                        const SizedBox(height: 14),

                        // Quantity + Priority
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9FAFB),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: _borderColor),
                                ),
                                height: 52,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Quantity',
                                        style: TextStyle(fontSize: 13, color: _textMuted)),
                                    Row(
                                      children: [
                                        _stepperBtn(Icons.remove, () {
                                          if (_quantity > 1) setState(() => _quantity--);
                                        }),
                                        SizedBox(
                                          width: 28,
                                          child: Text('$_quantity',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  color: _textPrimary)),
                                        ),
                                        _stepperBtn(Icons.add, () {
                                          if (_quantity < 10) setState(() => _quantity++);
                                        }),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _priority,
                                iconEnabledColor: _textMuted,
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w500, color: _textPrimary),
                                decoration: _fieldDecoration('Priority', icon: Icons.flag_outlined),
                                dropdownColor: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                items: _priorities.entries
                                    .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                                    .toList(),
                                onChanged: (v) => setState(() => _priority = v!),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Description
                        TextFormField(
                          controller: _descCtrl,
                          maxLines: 3,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500, color: _textPrimary),
                          decoration: _fieldDecoration('Description', icon: Icons.notes_outlined)
                              .copyWith(
                            hintText: 'Describe what you need and why',
                            hintStyle: const TextStyle(fontSize: 13, color: _textMuted),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                        ),

                        const SizedBox(height: 14),

                        // Needed by date
                        GestureDetector(
                          onTap: _pickDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: _borderColor),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_outlined,
                                    size: 18, color: _textMuted),
                                const SizedBox(width: 10),
                                Text(
                                  _neededByDate == null
                                      ? 'Needed by date'
                                      : '${_neededByDate!.day}/${_neededByDate!.month}/${_neededByDate!.year}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _neededByDate == null ? _textMuted : _textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Attachment (optional)
                        GestureDetector(
                          onTap: _pickFile,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: _borderColor, width: 1),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.attach_file, size: 18, color: _textMuted),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _attachmentName ??
                                        'Attachment (optional) — jpg, png, pdf, max 5MB',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: _attachmentName != null ? _textPrimary : _textMuted,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (_attachmentName != null)
                                  GestureDetector(
                                    onTap: () => setState(() {
                                      _attachmentBytes = null;
                                      _attachmentName = null;
                                    }),
                                    child: const Icon(Icons.close, size: 16, color: _textMuted),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Cancel + Submit
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _textPrimary,
                                  side: const BorderSide(color: _borderColor),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                ),
                                onPressed: vm.isSubmitting ? null : () => Navigator.pop(context),
                                child: const Text('Cancel',
                                    style: TextStyle(fontWeight: FontWeight.w600)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _brandBlue,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                ),
                                onPressed: vm.isSubmitting ? null : _submit,
                                child: vm.isSubmitting
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2, color: Colors.white),
                                      )
                                    : const Text('Submit request',
                                        style: TextStyle(fontWeight: FontWeight.w600)),
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

  Widget _stepperBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: _brandBlueBg,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 14, color: _brandBlue),
      ),
    );
  }
}