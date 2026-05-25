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

  // ── All valid role values matching backend ──
  static const _roles = [
    DropdownMenuItem(value: "super_admin",         child: Text("Super Admin")),
    DropdownMenuItem(value: "admin",               child: Text("Admin")),
    DropdownMenuItem(value: "trademark_executive", child: Text("TM Executive")),
    DropdownMenuItem(value: "patent_executive",    child: Text("Patent Executive")),
    DropdownMenuItem(value: "staff",               child: Text("Staff")),
  ];

  @override
  void initState() {
    super.initState();
    nameController  = TextEditingController(text: widget.user.name);
    emailController = TextEditingController(text: widget.user.email);
    // ── FIXED: ensure current role is one of the valid values ──
    role   = widget.user.role;
    status = widget.user.status;
    departmentId = widget.user.departmentId;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<UserViewModel>();

    return AlertDialog(
      title: const Text("Edit User"),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: role,
                items: _roles,
                onChanged: (v) => setState(() => role = v!),
                decoration: const InputDecoration(labelText: "Role"),
              ),
              DropdownButtonFormField<String>(
                value: status,
                items: const [
                  DropdownMenuItem(value: "active",   child: Text("Active")),
                  DropdownMenuItem(value: "inactive", child: Text("Inactive")),
                ],
                onChanged: (v) => setState(() => status = v!),
                decoration: const InputDecoration(labelText: "Status"),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
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
              await vm.editUser(widget.user.id, updatedUser, widget.token);
              if (context.mounted) Navigator.pop(context);
            }
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}