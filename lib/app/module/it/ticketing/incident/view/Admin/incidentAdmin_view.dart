import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view model/incident_vm.dart';
import 'widget/tableInc.dart';

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

  // ── Exact same brand tokens as AssetView ──────────────────────────────
  static const _brandBlue      = Color(0xFF185FA5);
  static const _brandBlueBg    = Color(0xFFE6F1FB);
  static const _textPrimary    = Color(0xFF1B1E28);
  static const _textSecondary  = Color(0xFF6B7280);
  static const _textMuted      = Color(0xFF9CA3AF);
  static const _borderColor    = Color(0xFFE5E7EB);

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  int? _selectedId;

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
    _searchController.dispose();
    super.dispose();
  }

  void _openDetail(int id) {
    context.read<IncidentVM>().selectIncident(widget.token, id);
    setState(() => _selectedId = id);
  }

  void _closeDetail() {
    context.read<IncidentVM>().clearSelected();
    setState(() => _selectedId = null);
  }

  // ── Search field — identical style to AssetView._searchField ───────────

  Widget _searchField(IncidentVM vm) => TextField(
        controller: _searchController,
        style: const TextStyle(
          color: _textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Search ticket or subject...',
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

  // ── Export button — identical style to AssetView._exportBtn ────────────

  Widget _exportBtn(IncidentVM vm) => ElevatedButton.icon(
        onPressed: () {}, // TODO: implement export
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

  // ── Desktop toolbar (single row) — identical layout to AssetView ───────

  Widget _buildDesktopToolbar(IncidentVM vm) {
    return Row(
      children: [
        SizedBox(width: 320, child: _searchField(vm)),
        const Spacer(),
        const SizedBox(width: 10),
        _exportBtn(vm),
      ],
    );
  }

  // ── Mobile toolbar (two rows) — identical layout to AssetView ──────────

  Widget _buildMobileToolbar(IncidentVM vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _searchField(vm),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _exportBtn(vm),
          ],
        ),
      ],
    );
  }

  // ── Filter tabs — same visual language as CategoryTabBarA ──────────────

  Widget _buildFilterTabs(IncidentVM vm) {
    final filters = [
      ('All',         vm.countAll,         Icons.widgets_outlined),
      ('Open',        vm.countOpen,        Icons.radio_button_unchecked),
      ('In Progress', vm.countInProgress,  Icons.autorenew),
      ('Resolved',    vm.countResolved,    Icons.check_circle_outline),
    ];

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: filters.map((f) {
          final active = vm.filterStatus == f.$1;
          return GestureDetector(
            onTap: () => vm.setFilter(f.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 6, bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: active ? _brandBlue : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: active ? _brandBlue : _borderColor,
                  width: 0.5,
                ),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    f.$3,
                    size: 14,
                    color: active ? Colors.white : _textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    f.$1,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                      color: active ? Colors.white : _textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: active
                          ? Colors.white.withOpacity(0.2)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${f.$2}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: active ? Colors.white : _textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.role != 'admin' && widget.role != 'super_admin') {
      return const Center(child: Text('Access Denied'));
    }

    return Consumer<IncidentVM>(
      builder: (context, vm, _) {

        // ── Detail page ───────────────────────────────────────────────
        // if (_selectedId != null) {
        //   return IncAdminDetailPage(
        //     token: widget.token,
        //     role: widget.role,
        //     onBack: _closeDetail,
        //     onRefresh: () => vm.fetchIncidents(widget.token),
        //   );
        // }

        // ── List page ─────────────────────────────────────────────────
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Filter tab bar — same position/style as CategoryTabBarA ─
            _buildFilterTabs(vm),

            // ── Toolbar row — responsive, identical to AssetView ────────
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                  child: isMobile
                      ? _buildMobileToolbar(vm)
                      : _buildDesktopToolbar(vm),
                );
              },
            ),

            // ── Table ─────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: IncidentTable(
                  role: widget.role,
                  token: widget.token,
                  scrollController: _scrollController,
                  onView: _openDetail,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}