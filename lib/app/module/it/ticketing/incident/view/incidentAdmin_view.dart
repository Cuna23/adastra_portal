import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/incident_model.dart';
import '../view model/incident_vm.dart';
import 'Staff/widget/incDetailDialog.dart';


class IncidentAdminView extends StatefulWidget {
  final String token;
  final String role;

  const IncidentAdminView({
    super.key,
    required this.token,
    required this.role,
  });

  @override
  State<IncidentAdminView> createState() => _IncidentAdminViewState();
}

class _IncidentAdminViewState extends State<IncidentAdminView> {
  static const _brandBlue = Color(0xFF185FA5);
  static const _textPrimary = Color(0xFF1B1E28);
  static const _textSecondary = Color(0xFF6B7280);
  static const _textMuted = Color(0xFF9CA3AF);
  static const _borderColor = Color(0xFFE5E7EB);

  int? _selectedId;

  final TextEditingController _searchCtrl =
      TextEditingController();

  String _search = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IncidentVM>().fetchIncidents(widget.token);
    });
  }

  void _openDetail(int id) {
    context.read<IncidentVM>().selectIncident(
          widget.token,
          id,
        );

    setState(() => _selectedId = id);
  }

  void _closeDetail() {
    context.read<IncidentVM>().clearSelected();

    setState(() {
      _selectedId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<IncidentVM>(
      builder: (context, vm, _) {
        if (_selectedId != null) {
          return IncDetailPage(
            token: widget.token,
            onBack: _closeDetail,
          );
        }

        final incidents = vm.incidents.where((inc) {
          if (_search.isEmpty) return true;

          final q = _search.toLowerCase();

          return inc.ticketNo.toLowerCase().contains(q) ||
              inc.subject.toLowerCase().contains(q);
        }).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  24, 24, 24, 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildFilterTabs(vm),
                  ),

                  const SizedBox(width: 16),

                  SizedBox(
                    width: 320,
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (value) {
                        setState(() {
                          _search = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText:
                            'Search ticket or subject',
                        prefixIcon:
                            const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                        isDense: true,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download),
                    label: const Text('Export'),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(
                        24, 0, 24, 24),
                child: vm.isLoading
                    ? const Center(
                        child:
                            CircularProgressIndicator())
                    : _buildTable(incidents),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTable(
      List<IncidentModel> incidents) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: _borderColor,
          width: 0.5,
        ),
      ),
      
      child: SizedBox(
      height: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
        child: DataTable(
          headingRowHeight: 48,
          dataRowMinHeight: 50,
          dataRowMaxHeight: 80,
          columns: const [
            DataColumn(
                label: Text('Ticket No')),
            DataColumn(
                label: Text('Subject')),
            DataColumn(
                label: Text('Reporter')),
            DataColumn(
                label: Text('Category')),
            DataColumn(
                label: Text('Priority')),
            DataColumn(
                label: Text('Status')),
            DataColumn(
                label: Text('Assigned To')),
            DataColumn(
                label: Text('Date')),
            DataColumn(
                label: Text('Action')),
          ],
          rows: incidents.map((inc) {
            return DataRow(
              cells: [
                DataCell(
                  Text(inc.ticketNo),
                ),

                DataCell(
                  SizedBox(
                    width: 220,
                    child: Text(
                      inc.subject,
                      overflow:
                          TextOverflow.ellipsis,
                    ),
                  ),
                ),

                DataCell(
                  Text(
                    inc.user?.name ?? '-',
                  ),
                ),

                DataCell(
                  Text(inc.category),
                ),

                DataCell(
                  _priorityChip(
                      inc.priority),
                ),

                DataCell(
                  _statusChip(
                      inc.status),
                ),

                DataCell(
                  Text(
                    _assignedLabel(
                        inc),
                  ),
                ),

                DataCell(
                  Text(
                    _formatDate(
                        inc.createdAt),
                  ),
                ),

                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.visibility_outlined),
                      onPressed: () => _openDetail(inc.id),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildFilterTabs(
      IncidentVM vm) {
    final filters = [
      ('All', vm.countAll),
      ('Open', vm.countOpen),
      (
        'In Progress',
        vm.countInProgress
      ),
      (
        'Resolved',
        vm.countResolved
      ),
    ];

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection:
            Axis.horizontal,
        children: filters.map((f) {
          final active =
              vm.filterStatus == f.$1;

          return GestureDetector(
            onTap: () =>
                vm.setFilter(f.$1),
            child: Container(
              margin:
                  const EdgeInsets.only(
                      right: 6),
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 14,
              ),
              decoration:
                  BoxDecoration(
                color: active
                    ? _brandBlue
                    : Colors.white,
                borderRadius:
                    BorderRadius
                        .circular(10),
                border: Border.all(
                  color: active
                      ? _brandBlue
                      : _borderColor,
                ),
              ),
              alignment:
                  Alignment.center,
              child: Text(
                '${f.$1} (${f.$2})',
                style: TextStyle(
                  fontSize: 13,
                  color: active
                      ? Colors.white
                      : _textPrimary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _priorityChip(
      String priority) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: priority == 'High'
            ? const Color(
                0xFFFCEBEB)
            : priority == 'Medium'
                ? const Color(
                    0xFFFAEEDA)
                : const Color(
                    0xFFEAF3DE),
        borderRadius:
            BorderRadius.circular(
                20),
      ),
      child: Text(priority),
    );
  }

  Widget _statusChip(
      String status) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: status == 'Open'
            ? const Color(
                0xFFE6F1FB)
            : status ==
                    'In Progress'
                ? const Color(
                    0xFFFAEEDA)
                : const Color(
                    0xFFEAF3DE),
        borderRadius:
            BorderRadius.circular(
                20),
      ),
      child: Text(status),
    );
  }

  String _assignedLabel(
      IncidentModel inc) {
    final u = inc.assignedUser;

    if (u == null) {
      return 'Pending';
    }

    if (u.role ==
        'super_admin') {
      return 'IT';
    }

    return u.name;
  }

  String _formatDate(
      String iso) {
    try {
      final dt =
          DateTime.parse(iso);

      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return iso;
    }
  }
}