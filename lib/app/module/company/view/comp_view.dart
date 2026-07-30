import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view model/comp_vm.dart';
import 'widget/CompFloor.dart';
import 'widget/CompMenu.dart';
import 'widget/CompDialog.dart';
import 'widget/CompOrg.dart';

enum CompanyTab { about, vision, org, floor }

class CompanyHomeView extends StatefulWidget {
  final String role;
  final String token;
  const CompanyHomeView({super.key, required this.role, required this.token});

  @override
  State<CompanyHomeView> createState() => _CompanyHomeViewState();
}

class _CompanyHomeViewState extends State<CompanyHomeView> {
  static const _brand = Color(0xFF185FA5);

  CompanyTab _selectedTab = CompanyTab.about; // [NEW] About us default

  bool get _isAdminOrSuper => widget.role == 'admin' || widget.role == 'super_admin';
  bool get _isSuperAdmin => widget.role == 'super_admin';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompanyViewModel>().fetchAll(widget.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CompanyViewModel>();
    final isMobile = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
          top: 12, 
          bottom: 20, 
          left: isMobile ? 16 : 32, 
          right: isMobile ? 16 : 32,
        ),
        child: Column(
          children: [
            Image.asset(
              'assets/images/adastraip_logo2.webp', 
              height: 170,
              fit: BoxFit.contain,
            ),

          // ── Tab bar ──
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _tabPill(
                'About us', 
                CompanyTab.about,
                bg: const Color(0xFFE6F1FB),
                color: const Color(0xFF185FA5),
              ),
              _tabPill(
                'Vision and mission', 
                CompanyTab.vision,
                bg: const Color(0xFFE1F5EE),
                color: const Color(0xFF0F6E56),
              ),
              _tabPill(
                'Organizational chart', 
                CompanyTab.org,
                bg: const Color(0xFFEEF2FF),
                color: const Color(0xFF4F46E5),
              ),
              _tabPill(
                'Floor mapping', 
                CompanyTab.floor,
                bg: const Color(0xFFFEF3E2),
                color: const Color(0xFFB45309),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Content box ──
          Container(
            //width: double.infinity,
            constraints: const BoxConstraints(minHeight: 200, maxWidth: 1000),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E9F0)),
            ),
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            child: vm.isLoading
                ? const Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Center(child: CircularProgressIndicator()))
                : _buildContent(vm, isMobile),
          ),
        ],
      ),
    );
  }

  Widget _tabPill(
    String label, 
    CompanyTab tab, {
    required Color bg, 
    required Color color,
  }) {
    final isSelected = _selectedTab == tab;

    return GestureDetector(
      onTap: () => setState(() => _selectedTab = tab),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8.5),
        decoration: BoxDecoration(
          // KEKAL WARNA ASAL DARIPADA AWAL
          color: bg, 
          borderRadius: BorderRadius.circular(10), // [Bentuk Tab SR]
          border: Border.all(
            // Bila active: border lebih tebal & gelap mengikut warna tema
            // Bila tak active: border lembut/lutsinar
            color: isSelected ? color : color.withOpacity(0.3),
            width: isSelected ? 1.5 : 0.8,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            // Bila active: teks lebih tebal
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: color, // Teks terus guna warna tema dari awal lagi
          ),
        ),
      ),
    );
  }

  Widget _buildContent(CompanyViewModel vm, bool isMobile) {
    switch (_selectedTab) {
      case CompanyTab.about:
        return _aboutContent(vm, isMobile);
      case CompanyTab.vision:
        return _visionMissionContent(vm, isMobile);
      case CompanyTab.org:
        return OrgChartContent(role: widget.role, token: widget.token); // [CHANGED] content-only widget
      case CompanyTab.floor:
        return FloorMapContent(role: widget.role, token: widget.token); // [CHANGED] content-only widget
    }
  }

  // ── About content ──
  Widget _aboutContent(CompanyViewModel vm, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Besarkan ikon dari 16 ke 22
            const Icon(Icons.apartment_rounded, size: 22, color: Color(0xFF185FA5)),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'About us',
                style: TextStyle(
                  fontSize: 16, // [UBAH DI SINI] Besarkan dari 12 ke 16
                  fontWeight: FontWeight.w700, // Tebalkan fon
                  color: Color(0xFF1B1E28),    // Tukar ke warna gelap
                ),
              ),
            ),
            if (_isAdminOrSuper)
              CompMenu(
                onEdit: () => _editAbout(vm),
                onDelete: () => _deleteAbout(vm),
                deleteEnabled: _isSuperAdmin,
              ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE5E7EB))),
          padding: const EdgeInsets.all(16),
          child: Text(
            (vm.about?.content?.isNotEmpty ?? false) ? vm.about!.content! : 'No description yet.',
            style: const TextStyle(fontSize: 14, height: 1.6, color: Color(0xFF374151)), // Besarkan sedikit teks perenggan
          ),
        ),
      ],
    );
  }

  // ── Vision & Mission content ──
  Widget _visionMissionContent(CompanyViewModel vm, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.flag_rounded, size: 22, color: Color(0xFF0F6E56)),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Vision and mission',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B1E28),
                ),
              ),
            ),
            if (_isAdminOrSuper)
              CompMenu(
                onEdit: () => _editVisionMission(vm),
                onDelete: () => _deleteVisionMission(vm),
                deleteEnabled: _isSuperAdmin,
              ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE5E7EB))),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Vision', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F6E56))),
              const SizedBox(height: 4),
              Text(vm.visionText.isNotEmpty ? vm.visionText : 'Not set yet.', style: const TextStyle(fontSize: 14, height: 1.6, color: Color(0xFF374151))),
              const SizedBox(height: 16),
              const Text('Mission', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F6E56))),
              const SizedBox(height: 4),
              Text(vm.missionText.isNotEmpty ? vm.missionText : 'Not set yet.', style: const TextStyle(fontSize: 14, height: 1.6, color: Color(0xFF374151))),
            ],
          ),
        ),
      ],
    );
  }

  // ── Actions ──
  Future<void> _editAbout(CompanyViewModel vm) async {
    final content = await StyledDialogs.textPrompt(context, title: 'About us', subtitle: 'Describe the company', icon: Icons.apartment_rounded, hint: 'Describe the company', initial: vm.about?.content, multiline: true);
    if (content == null || content.trim().isEmpty) return;
    final ok = await vm.updateAbout(content.trim(), widget.token);
    if (!mounted) return;
    _showSnack(ok ? 'About us updated.' : 'Update failed. Please try again.', success: ok);
  }

  Future<void> _deleteAbout(CompanyViewModel vm) async {
    final confirmed = await StyledDialogs.confirmDelete(context, itemLabel: 'About us', message: 'This will remove the About us description for everyone.');
    if (confirmed != true || !mounted) return;
    final ok = await vm.deleteAbout(widget.token);
    if (!mounted) return;
    _showSnack(ok ? 'Deleted successfully.' : 'Delete failed. Please try again.', success: ok);
  }

  Future<void> _editVisionMission(CompanyViewModel vm) async {
    final result = await StyledDialogs.visionMissionPrompt(context, vision: vm.visionText, mission: vm.missionText);
    if (result == null || !mounted) return;
    final ok = await vm.updateVisionMission(result['vision']!.trim(), result['mission']!.trim(), widget.token);
    if (!mounted) return;
    _showSnack(ok ? 'Vision and mission updated.' : 'Update failed. Please try again.', success: ok);
  }

  Future<void> _deleteVisionMission(CompanyViewModel vm) async {
    final confirmed = await StyledDialogs.confirmDelete(context, itemLabel: 'Vision and mission', message: 'This will remove vision and mission for everyone.');
    if (confirmed != true || !mounted) return;
    final ok = await vm.deleteVisionMission(widget.token);
    if (!mounted) return;
    _showSnack(ok ? 'Deleted successfully.' : 'Delete failed. Please try again.', success: ok);
  }

  void _showSnack(String message, {required bool success}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? const Color(0xFF2E7D52) : const Color(0xFFD64545),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}