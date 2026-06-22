import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view model/incident_vm.dart';
import 'widget/incChart.dart';
import 'widget/incDetailDialog.dart';
import 'widget/tabBar_Inc.dart';
import 'widget/tableInc.dart';

class IncidentAdminView extends StatefulWidget {
  final String token;
  final String role;
  final int currentUserId;

  const IncidentAdminView({
    super.key,
    required this.token,
    required this.role,
    required this.currentUserId,
  });

  @override
  State<IncidentAdminView> createState() => _IncidentAdminViewState();
}

class _IncidentAdminViewState extends State<IncidentAdminView> {
  static const _textPrimary = Color(0xFF1B1E28);
  static const _borderColor = Color(0xFFE5E7EB);

  int? _selectedId;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IncidentVM>().fetchIncidents(widget.token);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchCtrl.dispose();
    super.dispose();
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

  // ── Shared widgets — same pattern as AssetView ───────────────────────────

  Widget _searchField(IncidentVM vm) => TextField(
        controller: _searchCtrl,
        style: const TextStyle(
          color: _textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Search ticket or subject',
          prefixIcon: const Icon(Icons.search),
          isDense: true,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _borderColor),
          ),
        ),
        onChanged: (value) => vm.setSearch(value),
      );

  Widget _exportBtn() => ElevatedButton.icon(
        onPressed: () {
        },
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

  // ── Desktop toolbar (single row) — same layout as AssetView ─────────────

  Widget _buildDesktopToolbar(IncidentVM vm) {
    return Row(
      children: [
        SizedBox(width: 320, child: _searchField(vm)),
        const Spacer(),
        const SizedBox(width: 10),
        _exportBtn(),
      ],
    );
  }

  // ── Mobile toolbar (two rows) — same layout as AssetView ────────────────

  Widget _buildMobileToolbar(IncidentVM vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _searchField(vm),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [_exportBtn()],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<IncidentVM>(
      builder: (context, vm, _) {
        if (_selectedId != null) {
          return IncDetailPage(
            token: widget.token,
            role: widget.role,
            currentUserId: widget.currentUserId,
            onBack: _closeDetail,
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Search + Export — now ABOVE tab bar ─────────────────
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                    child: isMobile
                        ? _buildMobileToolbar(vm)
                        : _buildDesktopToolbar(vm),
                  );
                },
              ),

              // ── Status filter tab bar ────────────────────────────────
              StatusTabBarInc(
                selected: vm.filterStatus,
                countAll: vm.countAll,
                countUnresolved: vm.countUnresolved,
                countOpen: vm.countOpen,
                countInPending: vm.countInPending,
                countResolved: vm.countResolved,
                countReview: vm.countReview,
                countUnassigned: vm.countUnassigned,
                onSelect: vm.setFilter,
              ),

              // ── Charts section ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: IncChartsSection(token: widget.token),
              ),

              const SizedBox(height: 16),

              // ── Table — shrinkWrap so it joins the page scroll ───────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: IncidentTable(
                  role: widget.role,
                  token: widget.token,
                  scrollController: _scrollController,
                  onView: _openDetail,
                  shrinkWrap: true,       // ← new param
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}