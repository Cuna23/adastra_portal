import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view model/user_vm.dart';
import '../model/user_model.dart';
import 'widget/cloneU_dialog.dart';
import 'widget/createU_dialog.dart';
import 'widget/tableU.dart';

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
  final Set<int> _selectedIds = {};
  final ScrollController _scrollController = ScrollController();

  static const _brandBlue       = Color(0xFF185FA5);
  static const _brandBlueBg     = Color(0xFFE6F1FB);
  static const _brandBlueBorder = Color(0xFF85B7EB);
  static const _textPrimary     = Color(0xFF1B1E28);
  static const _textSecondary   = Color(0xFF6B7280);
  static const _borderColor     = Color(0xFFE5E7EB);

  bool get _hasSelection => _selectedIds.isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (widget.role == 'super_admin' || widget.role == 'admin') {
      Future.microtask(() {
        context.read<UserViewModel>().fetchUsers(widget.token);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ── Selection ──
  void _toggleAll(List<UserModel> users, bool? value) {
    setState(() {
      if (value == true) {
        _selectedIds.addAll(users.map((u) => u.id));
      } else {
        _selectedIds.clear();
      }
    });
  }

  void _toggleRow(int id, bool? value) {
    setState(() {
      value == true ? _selectedIds.add(id) : _selectedIds.remove(id);
    });
  }

  // ── Dialogs ──
  void _openCreateDialog() {
    showDialog(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<UserViewModel>(),
        child: CreateUDialog(token: widget.token),
      ),
    );
  }

  void _confirmDelete(UserModel user, UserViewModel vm) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Delete User',
          style: TextStyle(color: _textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete "${user.name}"?',
          style: const TextStyle(color: _textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: TextButton.styleFrom(foregroundColor: _brandBlue),
            child: const Text('Cancel',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () async {
              // Pop dialog guna dialogContext — bukan page context, elak
              // ter-pop shell Navigator (go_router) yang buat page jadi putih
              Navigator.pop(dialogContext);

              try {
                await vm.removeUser(user.id, widget.token);
                if (!mounted) return;
                setState(() => _selectedIds.remove(user.id));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${user.name} deleted successfully.'),
                    backgroundColor: const Color(0xFF2E7D52),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to delete user. Please try again.'),
                    backgroundColor: Color(0xFFD64545),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Delete',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _onClone(List<UserModel> users) {
    final selectedUsers =
        users.where((u) => _selectedIds.contains(u.id)).toList();

    if (selectedUsers.length != 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select exactly 1 user to clone'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<UserViewModel>(),
        child: CloneUDialog(
          token: widget.token,
          user: selectedUsers.first,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.role != 'super_admin' && widget.role != 'admin') {
      return const Center(child: Text('Access Denied'));
    }

    return Consumer<UserViewModel>(
      builder: (context, vm, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                children: [
                  if (_hasSelection) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: _brandBlueBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_selectedIds.length} selected',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _brandBlue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ], 
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed:
                        _hasSelection ? () => _onClone(vm.users) : null,
                    icon: const Icon(Icons.copy_outlined, size: 16),
                    label: const Text('Clone'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _brandBlueBg,
                      foregroundColor: _brandBlue,
                      disabledBackgroundColor: const Color(0xFFF1EFE8),
                      disabledForegroundColor: _textSecondary,
                      elevation: 0,
                      side: BorderSide(
                        color: _hasSelection
                            ? _brandBlueBorder
                            : _borderColor,
                        width: 0.5,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: _openCreateDialog,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add User'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _brandBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),

            // ── Table (extracted to tableU.dart) ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: UserTable(
                  role: widget.role,
                  token: widget.token,
                  selectedIds: _selectedIds,
                  scrollController: _scrollController,
                  onToggleAll: _toggleAll,
                  onToggleRow: _toggleRow,
                  onDelete: (user) => _confirmDelete(user, vm),
                ),
              ),
            ),

          ],
        );
      },
    );
  }
}