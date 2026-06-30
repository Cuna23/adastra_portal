import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/user_model.dart';
import '../../view model/user_vm.dart';

class EditUDialog extends StatefulWidget {
  final String token;
  final UserModel user;

  const EditUDialog({super.key, required this.token, required this.user});

  @override
  State<EditUDialog> createState() => _EditUDialogState();
}

class _EditUDialogState extends State<EditUDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController emailController;
  late String role;
  late String status;
  int? departmentId;

  // [NEW] Allowed email domains (same as Create dialog)
  static const _allowedDomains = ['@adastra.com.my', '@adastraip.com'];

  // ── Design tokens ──
  static const _brandBlue   = Color(0xFF185FA5);
  static const _brandBlueBg = Color(0xFFE6F1FB);
  static const _textPrimary = Color(0xFF1B1E28);
  static const _textMuted   = Color(0xFF9CA3AF);
  static const _borderColor = Color(0xFFE5E7EB);

  static const _roles = [
    DropdownMenuItem(value: "super_admin", child: Text("Super Admin")),
    DropdownMenuItem(value: "admin",       child: Text("Admin")),
    DropdownMenuItem(value: "staff",       child: Text("Staff")),
  ];

  @override
  void initState() {
    super.initState();
    nameController  = TextEditingController(text: widget.user.name);
    emailController = TextEditingController(text: widget.user.email);
    role            = widget.user.role;
    status          = widget.user.status;
    departmentId    = widget.user.departmentId;

    Future.microtask(() {
      context.read<UserViewModel>().fetchDepartments(widget.token);
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  // [NEW] Reusable modern input decoration
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
        borderSide: const BorderSide(color: Color(0xFFD92D20), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD92D20), width: 1.5),
      ),
    );
  }

@override
  Widget build(BuildContext context) {
    return Consumer<UserViewModel>(
      builder: (context, vm, _) {
        return Dialog(
      // [CHANGED] Replaced AlertDialog with styled Dialog
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 420,
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
              // [NEW] Header with avatar + user info
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _brandBlueBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.edit_outlined,
                        color: _brandBlue, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Edit User',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                        ),
                      ),
                      Text(
                        'Editing: ${widget.user.name}',
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
                    // [CHANGED] Styled name field
                    TextFormField(
                      controller: nameController,
                          style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                      ),
                      decoration: _fieldDecoration('Full Name',
                          icon: Icons.person_outline),
                      validator: (v) =>
                          v!.isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: emailController,
                      style: const TextStyle(
                        color: _textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: _fieldDecoration('Email Address',
                          icon: Icons.email_outlined),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Email is required';
                        final lower = v.toLowerCase();
                        // [NEW] Validate email ends with allowed domain
                        final valid = _allowedDomains
                            .any((d) => lower.endsWith(d));
                        if (!valid) {
                          return 'Email must use @adastra.com.my or @adastraip.com';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // [CHANGED] Role dropdown styled
                    DropdownButtonFormField<String>(
                      style: const TextStyle(
                      color: _textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                      value: role,
                      decoration: _fieldDecoration('Role',
                          icon: Icons.badge_outlined),
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      items: _roles,
                      onChanged: (v) => setState(() => role = v!),
                    ),
                    const SizedBox(height: 14),

                    DropdownButtonFormField<int>(
                      style: const TextStyle(
                        color: _textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      value: departmentId,
                      decoration: _fieldDecoration('Department',
                          icon: Icons.apartment_outlined),
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      items: vm.departments.map((dept) {
                        return DropdownMenuItem<int>(
                          value: dept.id,
                          child: Text(dept.departmentName),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => departmentId = v),
                    ),
                    const SizedBox(height: 24),

                    // [CHANGED] Status dropdown styled
                    DropdownButtonFormField<String>(
                      style: const TextStyle(
                        color: _textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      value: status,
                      decoration: _fieldDecoration('Status',
                          icon: Icons.toggle_on_outlined),
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      items: const [
                        DropdownMenuItem(
                            value: "active", child: Text("Active")),
                        DropdownMenuItem(
                            value: "inactive", child: Text("Inactive")),
                      ],
                      onChanged: (v) => setState(() => status = v!),
                    ),
                    const SizedBox(height: 24),

                    // [CHANGED] Action buttons — full width, styled
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
                                  const EdgeInsets.symmetric(vertical: 13),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel',
                                style:
                                    TextStyle(fontWeight: FontWeight.w600)),
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
                              padding:
                                  const EdgeInsets.symmetric(vertical: 13),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                final updatedUser = UserModel(
                                  id: widget.user.id,
                                  name: nameController.text,
                                  email: emailController.text,
                                  role: role,
                                  status: status,
                                  departmentId: departmentId,
                                );
                                await vm.editUser(
                                    widget.user.id, updatedUser, widget.token);
                                if (context.mounted) Navigator.pop(context);
                              }
                            },
                            child: const Text('Save Changes',
                                style:
                                    TextStyle(fontWeight: FontWeight.w600)),
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