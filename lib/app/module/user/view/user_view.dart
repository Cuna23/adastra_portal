import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view model/user_vm.dart';
import '../model/user_model.dart';
import 'widget/createU_dialog.dart';
import 'widget/editU_dialog.dart';

class UserManagementPage extends StatefulWidget {
  final String role;
  final String token;

  const UserManagementPage({
    super.key,
    required this.role,
    required this.token,
  });

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  @override
  void initState() {
    super.initState();
    if (widget.role == "super_admin") {
      Future.microtask(() {
        context.read<UserViewModel>().fetchUsers(widget.token);
      });
    }
  }

  void _openCreateDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => ChangeNotifierProvider.value(
        value: context.read<UserViewModel>(),
        child: CreateUDialog(token: widget.token),
      ),
    );
  }

  void _openEditDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (dialogContext) => ChangeNotifierProvider.value(
        value: context.read<UserViewModel>(),
        child: EditUDialog(
          token: widget.token,
          user: user,
        ),
      ),
    );
  }

  void _confirmDelete(UserModel user, UserViewModel vm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Delete "${user.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              vm.removeUser(user.id, widget.token);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Role string → readable label ──
  String _roleLabel(String role) {
    switch (role) {
      case 'super_admin': return 'Super Admin';
      case 'admin':       return 'Admin';
      case 'trademark_executive': return 'TM Executive';
      case 'patent_executive':    return 'Patent Executive';
      default: return role;
    }
  }

  // ── Status chip color ──
  Color _statusColor(String status) =>
      status == 'active' ? const Color(0xFF2E7D52) : const Color(0xFF9E9E9E);

  @override
  Widget build(BuildContext context) {
    if (widget.role != "super_admin") {
      return const Center(child: Text("Access Denied"));
    }

    return Consumer<UserViewModel>(
      builder: (context, vm, _) {
        return Stack(
          children: [
            // ── Main content ──
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header row ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Row(
                    children: [
                      const Text(
                        'User Management',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1B1E28),
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: _openCreateDialog,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add User'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF005BAC),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── User list ──
                Expanded(
                  child: vm.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : vm.users.isEmpty
                          ? const Center(child: Text('No users found.'))
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                              itemCount: vm.users.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final user = vm.users[index];
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: const Color(0xFFE5E7EB)),
                                  ),
                                  child: Row(
                                    children: [
                                      // Avatar
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor:
                                            const Color(0xFF005BAC)
                                                .withOpacity(0.1),
                                        child: Text(
                                          user.name[0].toUpperCase(),
                                          style: const TextStyle(
                                            color: Color(0xFF005BAC),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),

                                      // Name + email
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              user.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                color: Color(0xFF1B1E28),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              user.email,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF6B7280),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Role badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF005BAC)
                                              .withOpacity(0.08),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          _roleLabel(user.role),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF005BAC),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),

                                      // Status badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _statusColor(user.status)
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          user.status,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: _statusColor(user.status),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),

                                      // Edit + Delete
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined,
                                            size: 18,
                                            color: Color(0xFF6B7280)),
                                        onPressed: () =>
                                            _openEditDialog(user),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline,
                                            size: 18, color: Colors.red),
                                        onPressed: () =>
                                            _confirmDelete(user, vm),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}