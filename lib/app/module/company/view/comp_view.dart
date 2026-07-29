import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view model/comp_vm.dart';
import 'widget/CompFloor.dart';
import 'widget/CompMenu.dart';
import 'widget/CompDialog.dart';
import 'widget/CompOrg.dart';


class CompanyHomeView extends StatefulWidget {
  final String role;
  final String token;
  const CompanyHomeView({super.key, required this.role, required this.token});

  @override
  State<CompanyHomeView> createState() => _CompanyHomeViewState();
}

class _CompanyHomeViewState extends State<CompanyHomeView> {
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
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      child: Column(
        children: [
          Image.asset('assets/images/adastraip_logo.jpg', width: 160, height: 160, fit: BoxFit.contain),
          const SizedBox(height: 12),
          const Text('Adastra IP', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1B1E28))),
          const Text('Company Hub', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
          const SizedBox(height: 24),

          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(
                width: 200, // [FIX] fixed size — kecikkan angka ni untuk lagi kecik
                height: 200,
                child: _navCard(
                  icon: Icons.apartment_rounded,
                  cardColor: const Color(0xFFE6F1FB),
                  iconColor: const Color(0xFF185FA5),
                  title: 'About us',
                  onTap: () => _showAboutPopup(vm),
                ),
              ),
              SizedBox(
                width: 200,
                height: 200,
                child: _navCard(
                  icon: Icons.flag_rounded,
                  cardColor: const Color(0xFFE1F5EE),
                  iconColor: const Color(0xFF0F6E56),
                  title: 'Vision and mission',
                  onTap: () => _showVisionMissionPopup(vm),
                ),
              ),
              SizedBox(
                width: 200,
                height: 200,
                child: _navCard(
                  icon: Icons.account_tree_rounded,
                  cardColor: const Color(0xFFEEF2FF),
                  iconColor: const Color(0xFF4F46E5),
                  title: 'Organizational chart',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider.value(
                        value: vm,
                        child: OrgChartView(role: widget.role, token: widget.token),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 200,
                height: 200,
                child: _navCard(
                  icon: Icons.map_rounded,
                  cardColor: const Color(0xFFFEF3E2),
                  iconColor: const Color(0xFFB45309),
                  title: 'Floor mapping',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider.value(
                        value: vm,
                        child: FloorMapView(role: widget.role, token: widget.token),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

Widget _navCard({
    required IconData icon,
    required Color cardColor,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E9F0)),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, size: 28, color: iconColor), // [FIX] icon lebih besar
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF1B1E28)),
            ),
          ],
        ),
      ),
    );
  }

  // ── About popup ──
  void _showAboutPopup(CompanyViewModel vm) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container( 
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(color: const Color(0xFFE6F1FB), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.apartment_rounded, size: 18, color: Color(0xFF185FA5)),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text('About us', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1B1E28))),
                    ),
                    if (_isAdminOrSuper)
                      CompMenu(
                        onEdit: () {
                          Navigator.pop(ctx);
                          _editAbout(vm);
                        },
                        onDelete: () {
                          Navigator.pop(ctx);
                          _deleteAbout(vm);
                        },
                        deleteEnabled: _isSuperAdmin, // [NEW] admin: grayed out
                      ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close, size: 18, color: Color(0xFF9CA3AF)),
                      splashRadius: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  (vm.about?.content?.isNotEmpty ?? false) ? vm.about!.content! : 'No description yet.',
                  style: const TextStyle(fontSize: 13, height: 1.6, color: Color(0xFF4B5563)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Vision & Mission popup ──
  void _showVisionMissionPopup(CompanyViewModel vm) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container( // [FIX] tambah background putih eksplisit
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(color: const Color(0xFFE1F5EE), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.flag_rounded, size: 18, color: Color(0xFF0F6E56)),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text('Vision and mission', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1B1E28))),
                    ),
                    if (_isAdminOrSuper)
                      CompMenu(
                        onEdit: () {
                          Navigator.pop(ctx);
                          _editVisionMission(vm);
                        },
                        onDelete: () {
                          Navigator.pop(ctx);
                          _deleteVisionMission(vm);
                        },
                        deleteEnabled: _isSuperAdmin, // [NEW] admin: grayed out
                      ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close, size: 18, color: Color(0xFF9CA3AF)),
                      splashRadius: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Vision', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF0F6E56))),
                const SizedBox(height: 2),
                Text(vm.visionText.isNotEmpty ? vm.visionText : 'Not set yet.',
                    style: const TextStyle(fontSize: 13, height: 1.6, color: Color(0xFF4B5563))),
                const SizedBox(height: 10),
                Text('Mission', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF0F6E56))),
                const SizedBox(height: 2),
                Text(vm.missionText.isNotEmpty ? vm.missionText : 'Not set yet.',
                    style: const TextStyle(fontSize: 13, height: 1.6, color: Color(0xFF4B5563))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Actions ──
  Future<void> _editAbout(CompanyViewModel vm) async {
    final content = await StyledDialogs.textPrompt(
      context,
      title: 'About us',
      subtitle: 'Describe the company',
      icon: Icons.apartment_rounded,
      hint: 'Describe the company',
      initial: vm.about?.content,
      multiline: true,
    );
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