import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/user_model.dart';
import '../../view model/user_vm.dart';

class CloneUDialog extends StatefulWidget {
  final String token;
  final UserModel user;

  const CloneUDialog({
    super.key,
    required this.token,
    required this.user,
  });

  @override
  State<CloneUDialog> createState() => _CloneUDialogState();
}

class _CloneUDialogState extends State<CloneUDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController emailController;
  final passwordController = TextEditingController();

  late String role;
  late String status;
  int? departmentId;

  bool _obscurePassword = true;
  String? _emailServerError; // [NEW] stores backend duplicate email error

  static const _allowedDomains = ['@adastra.com.my', '@adastraip.com'];

  // ── Design tokens ──
  static const _brandBlue   = Color(0xFF185FA5);
  static const _brandBlueBg = Color(0xFFE6F1FB);
  static const _textPrimary = Color(0xFF1B1E28);
  static const _textMuted   = Color(0xFF9CA3AF);
  static const _borderColor = Color(0xFFE5E7EB);
  static const _errorRed    = Color(0xFFD92D20);

  @override
  void initState() {
    super.initState();
    nameController  = TextEditingController(text: widget.user.name);
    emailController = TextEditingController(text: widget.user.email);
    role            = widget.user.role;
    status          = widget.user.status;
    departmentId    = widget.user.departmentId;

    // [NEW] Clear server error bila user mula taip email baru
    emailController.addListener(() {
      if (_emailServerError != null) {
        setState(() => _emailServerError = null);
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ── Reusable InputDecoration ──
  InputDecoration _fieldDecoration(String label, {IconData? icon, String? helperText}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 13, color: _textMuted),
      prefixIcon: icon != null ? Icon(icon, size: 18, color: _textMuted) : null,
      // [NEW] helper text shown below field as grey hint
      helperText: helperText,
      helperStyle: const TextStyle(fontSize: 11, color: _textMuted),
      helperMaxLines: 2,
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
        borderSide: const BorderSide(color: _errorRed, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _errorRed, width: 1.5),
      ),
      errorMaxLines: 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<UserViewModel>();

    return Dialog(
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
                    child: const Icon(Icons.copy_outlined,
                        color: _brandBlue, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Clone User',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                        ),
                      ),
                      // [NEW] subtitle hint in header
                      Text(
                        'Cloning from: ${widget.user.name}',
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

                    // ── Name ──
                    TextFormField(
                      controller: nameController,
                      style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                      decoration: _fieldDecoration('Full Name',
                          icon: Icons.person_outline),
                      validator: (v) =>
                          v!.isEmpty ? 'Nam e is required' : null,
                    ),

                    const SizedBox(height: 14),

                    // ── Email ──
                    // [NEW] helperText + _emailServerError as inline field error
                    TextFormField(
                      controller: emailController,
                      style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                      decoration: _fieldDecoration(
                        'Email Address',
                        icon: Icons.email_outlined,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Email is required';
                        final lower = v.toLowerCase();
                        final valid = _allowedDomains.any((d) => lower.endsWith(d));
                        if (!valid) {
                          return 'Email must use @adastra.com.my or @adastraip.com';
                        }
                        // tempat keluar merah mcm error
                        if (v.trim().toLowerCase() ==
                            widget.user.email.trim().toLowerCase()) {
                          return 'This email is already registered';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    // ── Password ──
                    TextFormField(
                      controller: passwordController,
                      style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                      obscureText: _obscurePassword,
                      decoration: _fieldDecoration('New Password',
                              icon: Icons.lock_outline)
                          .copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 18,
                            color: _textMuted,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.length < 6) {
                          return 'Minimum 6 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    // ── Role ──
                    DropdownButtonFormField<String>(
                      iconEnabledColor: _textMuted,
                      style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                      value: role,
                      decoration: _fieldDecoration('Role',
                          icon: Icons.badge_outlined),
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      items: const [
                        DropdownMenuItem(
                            value: "super_admin",
                            child: Text("Super Admin")),
                        DropdownMenuItem(
                            value: "admin", child: Text("Admin")),
                        DropdownMenuItem(
                            value: "staff", child: Text("Staff")),
                      ],
                      onChanged: (v) => setState(() => role = v!),
                    ),

                    const SizedBox(height: 14),

                    // ── Status ──
                    DropdownButtonFormField<String>(
                      iconEnabledColor: _textMuted,
                      style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
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

                    // ── Buttons ──
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
                              // Clear previous server error before retry
                              setState(() => _emailServerError = null);

                              if (_formKey.currentState!.validate()) {
                                final clonedUser = UserModel(
                                  id: 0,
                                  name: nameController.text,
                                  email: emailController.text,
                                  role: role,
                                  status: status,
                                  departmentId: departmentId,
                                );

                                try {
                                  // [NEW] try/catch to catch backend duplicate email error
                                  await vm.addUser(
                                    clonedUser,
                                    passwordController.text,
                                    widget.token,
                                  );
                                  if (context.mounted) Navigator.pop(context);
                                } catch (e) {
                                  // [NEW] detect duplicate/existing email error from backend
                                  final msg = e.toString().toLowerCase();
                                  if (msg.contains('email') &&
                                      (msg.contains('exist') ||
                                          msg.contains('taken') ||
                                          msg.contains('duplicate') ||
                                          msg.contains('already'))) {
                                    setState(() {
                                      _emailServerError =
                                          'This email is already registered. Please use a different email.';
                                    });
                                  } else {
                                    // other errors — show snackbar
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Failed to clone user: ${e.toString()}'),
                                          backgroundColor: _errorRed,
                                        ),
                                      );
                                    }
                                  }
                                }
                              }
                            },
                            child: const Text('Clone',
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
  }
}