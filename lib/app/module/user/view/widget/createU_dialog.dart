import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/user_model.dart';
import '../../view model/user_vm.dart';


class CreateUDialog extends StatefulWidget {
  final String token;

  const CreateUDialog({super.key, required this.token});

  @override
  State<CreateUDialog> createState() => _CreateUDialogState();
}

class _CreateUDialogState extends State<CreateUDialog> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // ── FIXED: match backend role strings (underscore) ──
  String role = "staff";
  String status = "active";
  int? departmentId;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<UserViewModel>();

    return AlertDialog(
      title: const Text("Create User"),
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
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: (v) =>
                    v!.length < 6 ? "Min 6 characters" : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: role,
                // ── FIXED: values match backend exactly ──
                items: const [
                  DropdownMenuItem(value: "super_admin",          child: Text("Super Admin")),
                  DropdownMenuItem(value: "admin",                child: Text("Admin")),
                  DropdownMenuItem(value: "trademark_executive",  child: Text("TM Executive")),
                  DropdownMenuItem(value: "patent_executive",     child: Text("Patent Executive")),
                  DropdownMenuItem(value: "staff",                child: Text("Staff")),
                ],
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
              final user = UserModel(
                id: 0,
                name: nameController.text,
                email: emailController.text,
                role: role,
                status: status,
                departmentId: departmentId,
              );
              await vm.addUser(user, passwordController.text, widget.token);
              if (context.mounted) Navigator.pop(context);
            }
          },
          child: const Text("Create"),
        ),
      ],
    );
  }
}