import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../login/view model/login_vm.dart';
import '../../login/view/login_view.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, vm, _) {
        final user = vm.currentUser;

        return Scaffold(
          backgroundColor: const Color(0xFF0F1117),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1A1D27),
            elevation: 0,
            title: const Text(
              'Dashboard',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_outlined, color: Color(0xFF8A8FA8)),
                onPressed: () async {
                  await vm.logout();
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  }
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Success banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D2A1A),
                    border: Border.all(color: const Color(0xFF1A6B3A)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: Color(0xFF4CAF50), size: 20),
                      const SizedBox(width: 10),
                      const Text(
                        'Backend connected successfully!',
                        style: TextStyle(color: Color(0xFF4CAF50), fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                const Text(
                  'Logged in as',
                  style: TextStyle(color: Color(0xFF8A8FA8), fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.name ?? '—',
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 24),

                // Info cards
                _infoCard('Email', user?.email ?? '—', Icons.mail_outline),
                const SizedBox(height: 12),
                _infoCard('Role', user?.role ?? '—', Icons.badge_outlined),
                const SizedBox(height: 12),
                _infoCard('Token (truncated)', _truncate(vm.token), Icons.key_outlined),
              ],
            ),
          ),
        );
      },
    );
  }

  String _truncate(String? token) {
    if (token == null) return '—';
    return token.length > 30 ? '${token.substring(0, 30)}…' : token;
  }

  Widget _infoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D27),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2C2F42)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4F6EF7), size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Color(0xFF8A8FA8), fontSize: 12)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}