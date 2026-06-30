import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/user_model.dart';
import '../../view model/user_vm.dart';
import 'editU_dialog.dart';
import 'viewU_dialog.dart';

class UserTable extends StatelessWidget {
  final String role;
  final String token;
  final Set<int> selectedIds;
  final ScrollController scrollController;
  final void Function(List<UserModel> users, bool? value) onToggleAll;
  final void Function(int id, bool? value) onToggleRow;
  final void Function(UserModel user) onDelete;

  static const _brandBlue      = Color(0xFF185FA5);
  static const _brandBlueBg    = Color(0xFFE6F1FB);
  static const _textPrimary    = Color(0xFF1B1E28);
  static const _textSecondary  = Color(0xFF6B7280);
  static const _textMuted      = Color(0xFF9CA3AF);
  static const _borderColor    = Color(0xFFE5E7EB);
  static const _activeGreen    = Color(0xFF3B6D11);
  static const _activeGreenBg  = Color(0xFFEAF3DE);
  static const _inactiveGray   = Color(0xFF5F5E5A);
  static const _inactiveGrayBg = Color(0xFFF1EFE8);

  const UserTable({
    super.key,
    required this.role,
    required this.token,
    required this.selectedIds,
    required this.scrollController,
    required this.onToggleAll,
    required this.onToggleRow,
    required this.onDelete,
  });

  // ── Helpers ──
  String _roleLabel(String r) {
    switch (r) {
      case 'super_admin': return 'Super Admin';
      case 'admin':       return 'Admin';
      default:            return r;
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (vm.users.isEmpty) {
          return const Center(child: Text('No users found.'));
        }

        final allSelected =
            vm.users.isNotEmpty && selectedIds.length == vm.users.length;
        final someSelected =
            selectedIds.isNotEmpty && selectedIds.length < vm.users.length;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _borderColor),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Column(
              children: [
                // Sticky header
                _buildHeader(
                  allSelected: allSelected,
                  someSelected: someSelected,
                  users: vm.users,
                ),
                const Divider(height: 0.5, thickness: 0.5, color: _borderColor),

                // Scrollable rows
                Expanded(
                  child: Scrollbar(
                    controller: scrollController,
                    thumbVisibility: true,
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: vm.users.length,
                      separatorBuilder: (_, __) => const Divider(
                          height: 0.5, thickness: 0.5, color: _borderColor),
                      itemBuilder: (context, index) =>
                          _buildRow(context, vm.users[index], vm),
                    ),
                  ),
                ),

                // Footer
                const Divider(height: 0.5, thickness: 0.5, color: _borderColor),
                _buildFooter(vm.users),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Header row ──
  Widget _buildHeader({
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
                  onToggleAll(users, someSelected || allSelected ? false : true),
            ),
          ),
          const SizedBox(width: 8),
          _headerLabel('USER', flex: 5),
          _headerLabel('ROLE', flex: 2),
          _headerLabel('DEPARTMENT', flex: 2),
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

  // ── Single row ──
  Widget _buildRow(BuildContext context, UserModel user, UserViewModel vm) {
    final isSelected = selectedIds.contains(user.id);

    return InkWell(
      onTap: () => showDialog(
        context: context,
        builder: (_) => ViewUDialog(user: user),
      ),
      child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      color: isSelected ? _brandBlueBg.withOpacity(0.5) : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Checkbox(
              value: isSelected,
              activeColor: _brandBlue,
              onChanged: (v) => onToggleRow(user.id, v),
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
                            fontSize: 11, color: _textSecondary),
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

          // Department
          Expanded(
            flex: 2,
            child: Text(
              user.departmentName ?? '—',
              style: const TextStyle(fontSize: 12, color: _textSecondary),
              overflow: TextOverflow.ellipsis,
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
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => ChangeNotifierProvider.value(
                      value: context.read<UserViewModel>(),
                      child: EditUDialog(token: token, user: user),
                    ),
                  ),
                  tooltip: 'Edit',
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    size: 17,
                    color: role == 'super_admin'
                        ? Colors.red
                        : Colors.red.withOpacity(0.3),
                  ),
                  onPressed: role == 'super_admin'
                      ? () => onDelete(user)
                      : null,
                  tooltip: role == 'super_admin' ? 'Delete' : 'Restricted',
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }

  // ── Footer ──
  Widget _buildFooter(List<UserModel> users) {
    return Container(
      color: const Color(0xFFF8F9FB),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.people_outline, size: 14, color: _textMuted),
          const SizedBox(width: 6),
          Text(
            'Total Users: ${users.length}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            '${users.where((u) => u.status == "active").length} active',
            style: const TextStyle(
              fontSize: 11,
              color: _activeGreen,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${users.where((u) => u.status == "inactive").length} inactive',
            style: const TextStyle(
              fontSize: 11,
              color: _inactiveGray,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}