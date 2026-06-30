import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/incident_model.dart';
import '../../view model/incident_vm.dart';
import 'incActivityPanel.dart';

class IncDetailPage extends StatefulWidget {
  final String token;
  final String role;
  final int currentUserId;
  final VoidCallback onBack;

  const IncDetailPage({
    super.key,
    required this.token,
    required this.role,
    required this.currentUserId,
    required this.onBack,
  });

  @override
  State<IncDetailPage> createState() => _IncDetailPageState();
}

class _IncDetailPageState extends State<IncDetailPage> {
  static const _brandBlue     = Color(0xFF185FA5);
  static const _brandBlueBg   = Color(0xFFE6F1FB);
  static const _textPrimary   = Color(0xFF1B1E28);
  static const _textSecondary = Color(0xFF6B7280);
  static const _textMuted     = Color(0xFF9CA3AF);
  static const _borderColor   = Color(0xFFE5E7EB);
  static const _bgLight       = Color(0xFFF9FAFB);
  static const _bgField       = Color(0xFFF3F4F6);

  final _resolutionCtrl = TextEditingController();
  String? _selectedCategory;
  String? _selectedSubcategory;
  String? _selectedPriority;
  String? _selectedStatus;
  int? _selectedAssignedTo;
  bool _isUpdating = false;

  bool get _isAdmin => widget.role == 'admin' || widget.role == 'super_admin';

  @override
  void initState() {
    super.initState();
    final inc = context.read<IncidentVM>().selected;
    if (inc != null) {
      _resolutionCtrl.text = inc.resolution ?? '';
      _selectedCategory    = inc.category;
      _selectedSubcategory = inc.subcategory;
      _selectedPriority    = inc.priority;
      _selectedStatus      = inc.status;
      _selectedAssignedTo  = inc.assignedTo;
    }
  }

  @override
  void dispose() {
    _resolutionCtrl.dispose();
    super.dispose();
  }

  Future<void> _updateIncidentFields() async {
    final vm  = context.read<IncidentVM>();
    final inc = vm.selected;
    if (inc == null) return;

    setState(() => _isUpdating = true);

    final success = await vm.updateIncidentFields(
      token:       widget.token,
      id:          inc.id,
      category:    _selectedCategory    ?? inc.category,
      subcategory: _selectedSubcategory,
      priority:    _selectedPriority    ?? inc.priority,
      status:      _selectedStatus      ?? inc.status,
      assignedTo:  _selectedAssignedTo,
      resolution:  _resolutionCtrl.text.trim(),
    );

    if (mounted) {
      setState(() => _isUpdating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? '⚡ Ticket updated successfully!'
              : '❌ Update failed: ${vm.error}'),
          backgroundColor:
              success ? const Color(0xFF3B6D11) : const Color(0xFFA32D2D),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<IncidentVM>(
      builder: (context, vm, _) {
        final inc = vm.selected;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Back button ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: GestureDetector(
                onTap: widget.onBack,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.arrow_back_ios_new_rounded,
                        size: 13, color: _brandBlue),
                    SizedBox(width: 6),
                    Text(
                      'Back to Incident Report',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _brandBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            if (inc == null)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 800;
                      if (wide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 7,
                              child: _buildDetailPanel(inc),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 4,
                              child: IncActivityPanel(
                                token:         widget.token,
                                inc:           inc,
                                vm:            vm,
                                currentUserId: widget.currentUserId,
                              ),
                            ),
                          ],
                        );
                      }
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildDetailPanel(inc),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 520,
                              child: IncActivityPanel(
                                token:         widget.token,
                                inc:           inc,
                                vm:            vm,
                                currentUserId: widget.currentUserId,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // ── Detail panel ─────────────────────────────────────────────────────────

  Widget _buildDetailPanel(IncidentModel inc) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor, width: 0.5),
      ),
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Ticket header ────────────────────────────────────────
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 420;

                final iconBox = Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: _brandBlueBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.confirmation_number_outlined,
                      color: _brandBlue, size: 20),
                );

                final titleBlock = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(inc.subject,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _textPrimary)),
                    const SizedBox(height: 2),
                    Text(inc.ticketNo,
                        style: const TextStyle(
                            fontSize: 12,
                            color: _textMuted,
                            fontFamily: 'monospace')),
                  ],
                );

                final pills = Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _pill(inc.status,
                        bg: _statusColors(inc.status).bg,
                        fg: _statusColors(inc.status).fg),
                    _pill(inc.priority,
                        bg: _prioColors(inc.priority).bg,
                        fg: _prioColors(inc.priority).fg),
                  ],
                );

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          iconBox,
                          const SizedBox(width: 12),
                          Expanded(child: titleBlock),
                        ],
                      ),
                      const SizedBox(height: 10),
                      pills,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    iconBox,
                    const SizedBox(width: 12),
                    Expanded(child: titleBlock),
                    const SizedBox(width: 8),
                    pills,
                  ],
                );
              },
            ),

            const SizedBox(height: 20),
            const Divider(height: 0.5, thickness: 0.5, color: _borderColor),
            const SizedBox(height: 20),

            // ── Row 1: Category | Priority ───────────────────────────
            _fieldRow(
              _readonlyField(label: 'Category', value: inc.category, icon: Icons.category_outlined),
              _readonlyField(label: 'Priority',  value: inc.priority,  icon: Icons.flag_outlined),
            ),
            const SizedBox(height: 14),

            // ── Row 2: Subcategory | Assigned to ─────────────────────
            _fieldRow(
              _readonlyField(
                label: 'Subcategory',
                value: (inc.subcategory != null && inc.subcategory!.isNotEmpty)
                    ? inc.subcategory!
                    : '—',
                icon: Icons.label_outline,
              ),
              _readonlyField(
                label: 'Assigned to',
                value: _assignedLabel(inc),
                icon: Icons.support_agent_outlined,
              ),
            ),
            const SizedBox(height: 14),

            // ── Row 3: Requested by (full width) ─────────────────────
            if (_isAdmin) _reportedByCard(inc) else _readonlyField(
              label: 'Requested by',
              value: inc.user?.name ?? '—',
              icon: Icons.person_outline,
              fullWidth: true,
            ),
            const SizedBox(height: 14),

            // ── Row 4: Submitted | Last updated ──────────────────────
            _fieldRow(
              _readonlyField(label: 'Submitted',    value: _formatDate(inc.createdAt), icon: Icons.calendar_today_outlined),
              _readonlyField(label: 'Last updated', value: _formatDate(inc.updatedAt), icon: Icons.update_outlined),
            ),
            const SizedBox(height: 14),

            // ── Row 5: Description (full width) ──────────────────────
            _readonlyField(
              label: 'Description',
              value: inc.description,
              icon: Icons.notes_outlined,
              maxLines: 5,
              fullWidth: true,
            ),

            // ── Attachment ───────────────────────────────────────────
            if (inc.attachment != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: _bgLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _borderColor, width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.attach_file, size: 18, color: _textMuted),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        inc.attachment!.split('/').last,
                        style: const TextStyle(fontSize: 13, color: _brandBlue),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ── Admin Management Action ───────────────────────────────
            if (_isAdmin) ...[
              const SizedBox(height: 24),
              const Divider(height: 0.5, thickness: 0.5, color: _borderColor),
              const SizedBox(height: 20),
              const Text(
                '⚙️ Admin Management Action',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _brandBlue),
              ),
              const SizedBox(height: 16),
              _fieldRow(
                _editableDropdown(
                  label: 'Change Category',
                  value: _selectedCategory,
                  items: ['Hardware', 'Software', 'Network', 'Others'],
                  onChanged: (val) => setState(() => _selectedCategory = val),
                ),
                _editableDropdown(
                  label: 'Change Priority',
                  value: _selectedPriority,
                  items: ['Low', 'Medium', 'High'],
                  onChanged: (val) => setState(() => _selectedPriority = val),
                ),
              ),
              const SizedBox(height: 14),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Change Subcategory',
                      style: TextStyle(
                          fontSize: 12,
                          color: _textSecondary,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  TextFormField(
                    initialValue: _selectedSubcategory,
                    onChanged: (val) => _selectedSubcategory = val,
                    style: const TextStyle(fontSize: 14, color: _textPrimary),
                    decoration: InputDecoration(
                      hintText: 'e.g. WiFi, Printer, VPN...',
                      hintStyle: const TextStyle(fontSize: 13, color: _textMuted),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: _brandBlue, width: 1.2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: _brandBlue, width: 1.5),
                      ),
                      isDense: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              _fieldRow(
                _editableDropdown(
                  label: 'Update Status',
                  value: _selectedStatus,
                  items: ['Open', 'In Pending', 'Resolved'],
                  onChanged: (val) => setState(() => _selectedStatus = val),
                ),
                _editableDropdown(
                  label: 'Assignee Expert',
                  value: _selectedAssignedTo?.toString(),
                  items: [
                    if (inc.assignedUser != null)
                      inc.assignedUser!.id.toString()
                    else
                      '1',
                  ],
                  customLabels: {
                    '1': 'IT Superadmin',
                    if (inc.assignedUser != null)
                      inc.assignedUser!.id.toString(): inc.assignedUser!.name,
                  },
                  onChanged: (val) =>
                      setState(() => _selectedAssignedTo = int.tryParse(val ?? '')),
                ),
              ),
              const SizedBox(height: 14),

              const Text('Resolution Comment',
                  style: TextStyle(
                      fontSize: 12,
                      color: _textSecondary,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _resolutionCtrl,
                maxLines: 3,
                style: const TextStyle(fontSize: 14, color: _textPrimary),
                decoration: InputDecoration(
                  hintText: 'Describe the solution to close this case...',
                  hintStyle: const TextStyle(fontSize: 13, color: _textMuted),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: _brandBlue, width: 1.5),
                  ),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 20),

              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: _isUpdating ? null : _updateIncidentFields,
                  icon: _isUpdating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save_outlined,
                          size: 16, color: Colors.white),
                  label: const Text('Save Ticket Changes',
                      style: TextStyle(fontSize: 13, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandBlue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                ),
              ),
            ] else ...[
              if (inc.resolution != null && inc.resolution!.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Divider(height: 0.5, thickness: 0.5, color: _borderColor),
                const SizedBox(height: 20),
                _readonlyField(
                  label: 'Official Resolution from Admin',
                  value: inc.resolution!,
                  icon: Icons.gavel_outlined,
                  maxLines: 4,
                  fullWidth: true,
                ),
              ]
            ],
          ],
        ),
      ),
    );
  }

  // ── Reported by card ────────────────────────────────────────
  Widget _reportedByCard(IncidentModel inc) {
    final u = inc.user;

    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Requested by',
        labelStyle: const TextStyle(fontSize: 13, color: _textMuted),
        contentPadding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
        filled: true,
        fillColor: _bgField,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _borderColor, width: 1),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _borderColor, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Name | Emp ID
          _fieldRow(
            _miniField(
              icon: Icons.person_outline,
              label: 'Name',
              value: u?.name ?? '—',
            ),
            _miniField(
              icon: Icons.badge_outlined,
              label: 'Employee ID',
              value: (u?.empId != null && u!.empId!.isNotEmpty) ? u.empId! : '—',
            ),
          ),
          const SizedBox(height: 8),
          // Row 2: Email | Department
          _fieldRow(
            _miniField(
              icon: Icons.mail_outline,
              label: 'Email',
              value: (u?.email != null && u!.email!.isNotEmpty) ? u.email! : '—',
            ),
            _miniField(
              icon: Icons.apartment_outlined,
              label: 'Department',
              value: (u?.department != null && u!.department!.isNotEmpty)
                  ? u.department!
                  : '—',
            ),
          ),
        ],
      ),
    );
  }

  // Small inner field used inside the reporter card
  Widget _miniField({
    IconData? icon, 
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _borderColor, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: _textMuted),
              const SizedBox(width: 4),
              Text(label,
                  style: const TextStyle(fontSize: 11, color: _textMuted)),
            ],
          ),
          const SizedBox(height: 3),
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _textPrimary),
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  String _assignedLabel(IncidentModel inc) {
    final u = inc.assignedUser;
    if (u == null) return 'Pending';
    if (u.role == 'super_admin') return 'IT';
    return u.name;
  }

  Widget _readonlyField({
    required String label,
    required String value,
    required IconData icon,
    int maxLines = 1,
    bool fullWidth = false,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: _textMuted),
        prefixIcon: icon != null ? Icon(icon, size: 18, color: _textMuted) : null,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        filled: true,
        fillColor: _bgField,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _borderColor, width: 1),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _borderColor, width: 1),
        ),
      ),
      child: Text(value,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: _textPrimary)),
    );
  }

  Widget _editableDropdown({
    required String label,
    required String? value,
    required List<String> items,
    Map<String, String>? customLabels,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                color: _textSecondary,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: items.contains(value) ? value : null,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          iconEnabledColor: _textMuted,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(customLabels?[item] ?? item,
                  style: const TextStyle(
                      fontSize: 14, color: _textPrimary)),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _brandBlue, width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _brandBlue, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _fieldRow(Widget a, Widget b) {
      return LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 480) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [a, const SizedBox(height: 12), b],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: a),
              const SizedBox(width: 12),
              Expanded(child: b),
            ],
          );
        },
      );
    }

  Widget _pill(String text, {required Color bg, required Color fg}) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Text(text,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
      );

  ({Color bg, Color fg}) _statusColors(String status) {
    switch (status) {
      case 'Open':
        return (bg: const Color(0xFFE6F1FB), fg: const Color(0xFF185FA5));
      case 'In Pending':
        return (bg: const Color(0xFFF1EFE8), fg: const Color(0xFF5F5E5A));
      case 'Resolved':
        return (bg: const Color(0xFFEAF3DE), fg: const Color(0xFF3B6D11));
      default:
        return (bg: const Color(0xFFF1EFE8), fg: const Color(0xFF5F5E5A));
    }
  }

  ({Color bg, Color fg}) _prioColors(String p) {
    switch (p) {
      case 'High':
        return (bg: const Color(0xFFFCEBEB), fg: const Color(0xFFA32D2D));
      case 'Medium':
        return (bg: const Color(0xFFFAEEDA), fg: const Color(0xFF854F0B));
      default:
        return (bg: const Color(0xFFEAF3DE), fg: const Color(0xFF3B6D11));
    }
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      const months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '${dt.day} ${months[dt.month]} ${dt.year} · $h:$m';
    } catch (_) {
      return iso;
    }
  }
}