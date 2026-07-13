import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view model/sr_vm.dart';
import 'widget/export_excelSR.dart';
import 'widget/srDetail_view.dart';
import 'widget/tableSR.dart';
import 'widget/tabBar_sr.dart';

class ServiceRequestAdminView extends StatefulWidget {
  final String token;
  final String role;
  final int currentUserId;

  const ServiceRequestAdminView({
    super.key,
    required this.token,
    required this.role,
    required this.currentUserId,
  });

  @override
  State<ServiceRequestAdminView> createState() => _ServiceRequestAdminViewState();
}

class _ServiceRequestAdminViewState extends State<ServiceRequestAdminView> {
  static const _textPrimary = Color(0xFF1B1E28);
  static const _borderColor = Color(0xFFE5E7EB);

  int? _selectedId;
  String _selectedTab = 'Pending';
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceRequestViewModel>().fetchRequests(widget.token);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openDetail(int id) {
    context.read<ServiceRequestViewModel>().selectRequest(widget.token, id);
    setState(() => _selectedId = id);
  }

  void _closeDetail() {
    context.read<ServiceRequestViewModel>().clearSelected();
    setState(() => _selectedId = null);
    context.read<ServiceRequestViewModel>().fetchRequests(widget.token);
  }

  void _onSelectTab(String status) => setState(() => _selectedTab = status);

  Widget _searchField() => TextField(
    controller: _searchCtrl,
    style: const TextStyle(color: _textPrimary, fontSize: 15, fontWeight: FontWeight.w500),
    decoration: InputDecoration(
      hintText: 'Search SR number or title',
      prefixIcon: const Icon(Icons.search),
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _borderColor)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _borderColor)),
    ),
    onChanged: (_) => setState(() {}),
  );

  Widget _exportBtn(List requests) => ElevatedButton.icon(
    onPressed: () => exportServiceRequestsToExcel(requests.cast()),
    icon: const Icon(Icons.download_outlined, size: 16),
    label: const Text('Export Excel'),
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFEAF3DE),
      foregroundColor: const Color(0xFF3B6D11),
      elevation: 0,
      side: const BorderSide(color: Color(0xFFB8D8A0), width: 0.5),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (widget.role != 'admin' && widget.role != 'super_admin' && widget.role != 'hod') {
      return const Center(child: Text('Access Denied'));
    }

    return Consumer<ServiceRequestViewModel>(
      builder: (context, vm, _) {
        if (_selectedId != null) {
        return SRDetailPage(
          token: widget.token,
          role: widget.role,
          onBack: _closeDetail,
        );
        }

        var filtered = _selectedTab == 'All'
            ? vm.requests
            : vm.requests.where((r) => r.status == _selectedTab.toLowerCase()).toList();

        if (_searchCtrl.text.trim().isNotEmpty) {
          final q = _searchCtrl.text.trim().toLowerCase();
          filtered = filtered.where((r) =>
              r.srNumber.toLowerCase().contains(q) ||
              r.requestTitle.toLowerCase().contains(q)).toList();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                  child: isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _searchField(),
                            const SizedBox(height: 10),
                            _exportBtn(filtered),
                          ],
                        )
                      : Row(
                          children: [
                            SizedBox(width: 320, child: _searchField()),
                            const Spacer(),
                            _exportBtn(filtered),
                          ],
                        ),
                );
              },
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: StatusTabBarSR(
                selected: _selectedTab,
                countAll: vm.countAll,
                countPending: vm.countPending,
                countApproved: vm.countApproved,
                countRejected: vm.countRejected,
                onSelect: _onSelectTab,
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SRTable(
                  role: widget.role,
                  token: widget.token,
                  scrollController: _scrollController,
                  onView: _openDetail,
                  showEmployeeColumns: true,
                  requestsOverride: filtered,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}