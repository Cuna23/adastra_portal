import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../view model/incident_vm.dart';

class CreateIncidentDialog extends StatefulWidget {
  final String token;

  const CreateIncidentDialog({super.key, required this.token});

  @override
  State<CreateIncidentDialog> createState() => _CreateIncidentDialogState();
}

class _CreateIncidentDialogState extends State<CreateIncidentDialog> {
  static const _brandBlue   = Color(0xFF185FA5);
  static const _brandBlueBg = Color(0xFFE6F1FB);
  static const _textPrimary = Color(0xFF1B1E28);
  static const _textMuted   = Color(0xFF9CA3AF);
  static const _borderColor = Color(0xFFE5E7EB);

  final _formKey     = GlobalKey<FormState>();
  final _subjectCtrl = TextEditingController();
  final _descCtrl    = TextEditingController();

  String  _category = 'Network';
  String  _priority = 'Low';
  String? _attachmentName;
  int? _attachmentSize;
  List<int>? _attachmentBytes;

  static const _categories = ['Network', 'Hardware', 'Software', 'Others'];
  static const _priorities = ['Low', 'Medium', 'High'];

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 13, color: _textMuted),
      prefixIcon: icon != null
          ? Icon(icon, size: 18, color: _textMuted)
          : null,
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
        borderSide:
            const BorderSide(color: Color(0xFFD92D20), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:
            const BorderSide(color: Color(0xFFD92D20), width: 1.5),
      ),
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'jpg',
        'jpeg',
        'png',
        'pdf',
      ],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;

    print('Name      : ${file.name}');
    print('Size      : ${file.size}');
    print('Extension : ${file.extension}');

    // Check 5MB limit
    if (file.size > 5 * 1024 * 1024) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File exceeds 5MB limit'),
          ),
        );
      }
      return;
    }

    setState(() {
      _attachmentName = file.name;
      _attachmentSize = file.size;
      _attachmentBytes = file.bytes;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<IncidentVM>();
    final ok = await vm.createIncident(
      token:          widget.token,
      subject:        _subjectCtrl.text.trim(),
      description:    _descCtrl.text.trim(),
      category:       _category,
      priority:       _priority,
      attachmentFile: _attachmentBytes,
    );

    if (!mounted) return;

    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incident submitted successfully'),
          backgroundColor: Color(0xFF3B6D11),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.error ?? 'Failed to submit incident'),
          backgroundColor: const Color(0xFFA32D2D),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<IncidentVM>(
      builder: (context, vm, _) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
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

                  // ── Header ────────────────────────────────────────────
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
                            'Report new incident',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: _textPrimary,
                            ),
                          ),
                          Text(
                            'Fill in the details of the issue you are experiencing',
                            style: TextStyle(fontSize: 12, color: _textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Info note ─────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color: _brandBlueBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 14, color: _brandBlue),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Once submitted, only notes can be added. Subject, category, priority and description cannot be edited.',
                            style: TextStyle(
                                fontSize: 12, color: _brandBlue),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Form ──────────────────────────────────────────────
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [

                        // Subject
                        TextFormField(
                          controller: _subjectCtrl,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: _textPrimary,
                          ),
                          decoration: _fieldDecoration(
                            'Subject',
                            icon: Icons.title_outlined,
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Required'
                              : null,
                        ),

                        const SizedBox(height: 14),

                        // Category + Priority
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _category,
                                iconEnabledColor: _textMuted,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: _textPrimary,
                                ),
                                decoration: _fieldDecoration(
                                  'Category',
                                  icon: Icons.category_outlined,
                                ),
                                dropdownColor: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                items: _categories
                                    .map((c) => DropdownMenuItem(
                                        value: c, child: Text(c)))
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => _category = v!),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _priority,
                                iconEnabledColor: _textMuted,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: _textPrimary,
                                ),
                                decoration: _fieldDecoration(
                                  'Priority',
                                  icon: Icons.flag_outlined,
                                ),
                                dropdownColor: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                items: _priorities
                                    .map((p) => DropdownMenuItem(
                                        value: p, child: Text(p)))
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => _priority = v!),
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
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: _textPrimary,
                          ),
                          decoration: _fieldDecoration(
                            'Description',
                            icon: Icons.notes_outlined,
                          ).copyWith(
                            hintText:
                                'Describe the issue — when it occurred, what was affected, what has been tried...',
                            hintStyle: const TextStyle(
                                fontSize: 13, color: _textMuted),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Required'
                              : null,
                        ),

                        const SizedBox(height: 14),

                        // Attachment
                        GestureDetector(
                          onTap: _pickFile,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: _borderColor, width: 1),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.attach_file,
                                    size: 18, color: _textMuted),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _attachmentName ??
                                        'Attachment (optional) — jpg, png, pdf, max 5MB',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: _attachmentName != null
                                          ? _textPrimary
                                          : _textMuted,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (_attachmentName != null)
                                  GestureDetector(
                                    onTap: () => setState(() {
                                      _attachmentBytes   = null;
                                      _attachmentName = null;
                                    }),
                                    child: const Icon(Icons.close,
                                        size: 16, color: _textMuted),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        if (_attachmentName != null) ...[
                        const SizedBox(height: 8),

                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FB),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _borderColor),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.insert_drive_file_outlined,
                                size: 18,
                              ),

                              const SizedBox(width: 8),

                              Expanded(
                                child: Text(
                                  _attachmentName!,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              IconButton(
                                icon: const Icon(Icons.close, size: 16),
                                onPressed: () {
                                  setState(() {
                                    _attachmentBytes = null;
                                    _attachmentName = null;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],

                        const SizedBox(height: 24),

                        // Cancel + Submit
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _textPrimary,
                                  side: const BorderSide(
                                      color: _borderColor),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 13),
                                ),
                                onPressed: vm.isSubmitting
                                    ? null
                                    : () => Navigator.pop(context),
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
                                      borderRadius:
                                          BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 13),
                                ),
                                onPressed:
                                    vm.isSubmitting ? null : _submit,
                                child: vm.isSubmitting
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white),
                                      )
                                    : const Text('Submit ticket',
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