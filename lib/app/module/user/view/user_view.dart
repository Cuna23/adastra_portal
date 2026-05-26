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
  final Set<int> _selectedIds = {};

  static const _brandBlue       = Color(0xFF185FA5);
  static const _brandBlueBg     = Color(0xFFE6F1FB);
  static const _brandBlueBorder = Color(0xFF85B7EB);
  static const _textPrimary     = Color(0xFF1B1E28);
  static const _textSecondary   = Color(0xFF6B7280);
  static const _textMuted       = Color(0xFF9CA3AF);
  static const _borderColor     = Color(0xFFE5E7EB);
  static const _activeGreen     = Color(0xFF3B6D11);
  static const _activeGreenBg   = Color(0xFFEAF3DE);
  static const _inactiveGray    = Color(0xFF5F5E5A);
  static const _inactiveGrayBg  = Color(0xFFF1EFE8);

  bool get _hasSelection => _selectedIds.isNotEmpty;

final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.role == 'super_admin') {
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

  void _openEditDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<UserViewModel>(),
        child: EditUDialog(token: widget.token, user: user),
      ),
    );
  }

  void _confirmDelete(UserModel user, UserViewModel vm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Delete User',
          style: TextStyle(
            color: _textPrimary,
          ),
        ),
        content: Text('Are you sure you want to delete "${user.name}"?',
          style: const TextStyle(
            color: _textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: _brandBlue),
            child: const Text('Cancel',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              setState(() => _selectedIds.remove(user.id));
              vm.removeUser(user.id, widget.token);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _onClone(List<UserModel> users) {
    final selected = users.where((u) => _selectedIds.contains(u.id)).toList();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clone Users'),
        content: Text(
          'Clone ${selected.length} user(s):\n'
          '${selected.map((u) => u.name).join(', ')}\n\n'
          'Functionality coming soon.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──
  String _roleLabel(String role) {
    switch (role) {
      case 'super_admin': return 'Super Admin';
      case 'admin':       return 'Admin';
      default:            return role;
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.role != 'super_admin') {
      return const Center(child: Text('Access Denied'));
    }

    return Consumer<UserViewModel>(
      builder: (context, vm, _) {
        final allSelected =
            vm.users.isNotEmpty && _selectedIds.length == vm.users.length;
        final someSelected =
            _selectedIds.isNotEmpty && _selectedIds.length < vm.users.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                children: [
                  const Text(
                    'User Management',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                  if (_hasSelection) ...[
                    const SizedBox(width: 10),
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
                        color: _hasSelection ? _brandBlueBorder : _borderColor,
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

            // ── Table ──
            Expanded(
              child: Padding(
                // [CHANGED] bottom padding reduced to 0 to allow footer inside container
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: vm.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : vm.users.isEmpty
                        ? const Center(child: Text('No users found.'))
                        : Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: _borderColor),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Column(
                                children: [
                                  // Sticky column headers
                                  _buildTableHeader(
                                    allSelected: allSelected,
                                    someSelected: someSelected,
                                    users: vm.users,
                                  ),
                                  const Divider(
                                      height: 0.5,
                                      thickness: 0.5,
                                      color: _borderColor),
 
                                  // with Scrollbar for visual scroll indicator
                                  Expanded(
                                    child: Scrollbar(
                                      controller: _scrollController,
                                      thumbVisibility: true,
                                      child: PrimaryScrollController(
                                        controller: _scrollController,
                                        child: ListView.separated(
                                          controller: _scrollController,
                                        itemCount: vm.users.length,
                                        separatorBuilder: (_, __) =>
                                            const Divider(
                                                height: 0.5,
                                                thickness: 0.5,
                                                color: _borderColor),
                                        itemBuilder: (context, index) {
                                          final user = vm.users[index];
                                          return _buildRow(user, vm);
                                        },
                                        )
                                      ),
                                    ),
                                  ),
 
                                  // [NEW] Total user count footer bar
                                  const Divider(
                                      height: 0.5,
                                      thickness: 0.5,
                                      color: _borderColor),
                                  Container(
                                    color: const Color(0xFFF8F9FB),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.people_outline,
                                            size: 14, color: _textMuted),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Total Users: ${vm.users.length}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: _textSecondary,
                                          ),
                                        ),
                                        const Spacer(),
                                        // [NEW] show active count as well
                                        Text(
                                          '${vm.users.where((u) => u.status == "active").length} active',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: _activeGreen,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          '${vm.users.where((u) => u.status == "inactive").length} inactive',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: _inactiveGray,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Table column header row ──
  Widget _buildTableHeader({
    required bool allSelected,
    required bool someSelected,
    required List<UserModel> users,
  }) {
    return Container(
      color: const Color(0xFFF8F9FB),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Checkbox(
              value: allSelected ? true : (someSelected ? null : false),
              tristate: true,
              activeColor: _brandBlue,
              onChanged: (v) =>
                  _toggleAll(users, someSelected || allSelected ? false : true),
            ),
          ),
          const SizedBox(width: 8),
          _headerLabel('USER', flex: 5),
          _headerLabel('ROLE', flex: 2),
          _headerLabel('STATUS', flex: 2),
          const SizedBox(
            width: 88,
            child: Text(
              'ACTIONS',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _textMuted,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerLabel(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _textMuted,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ── Single user row ──
  Widget _buildRow(UserModel user, UserViewModel vm) {
    final isSelected = _selectedIds.contains(user.id);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      color: isSelected ? _brandBlueBg.withOpacity(0.5) : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Checkbox
          SizedBox(
            width: 36,
            child: Checkbox(
              value: isSelected,
              activeColor: _brandBlue,
              onChanged: (v) => _toggleRow(user.id, v),
            ),
          ),
          const SizedBox(width: 8),

          // Avatar + name + email
          Expanded(
            flex: 5,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: _brandBlueBg,
                  child: Text(
                    _initials(user.name),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _brandBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: 11,
                          color: _textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Role badge
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _brandBlueBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _roleLabel(user.role),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _brandBlue,
                  ),
                ),
              ),
            ),
          ),

          // Status badge
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: user.status == 'active'
                      ? _activeGreenBg
                      : _inactiveGrayBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  user.status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: user.status == 'active'
                        ? _activeGreen
                        : _inactiveGray,
                  ),
                ),
              ),
            ),
          ),

          // Edit + Delete
          SizedBox(
            width: 88,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      size: 17, color: _textSecondary),
                  onPressed: () => _openEditDialog(user),
                  tooltip: 'Edit',
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 17, color: Colors.red),
                  onPressed: () => _confirmDelete(user, vm),
                  tooltip: 'Delete',
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}