import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../view model/login_vm.dart';

class AuthSuccessScreen extends StatefulWidget {
  final String? token;

  const AuthSuccessScreen({super.key, required this.token});

  @override
  State<AuthSuccessScreen> createState() => _AuthSuccessScreenState();
}

class _AuthSuccessScreenState extends State<AuthSuccessScreen> {
  String? _error;

  @override
  void initState() {
    super.initState();
    // Guna addPostFrameCallback supaya context/provider dah ready sebelum kita akses
    WidgetsBinding.instance.addPostFrameCallback((_) => _process());
  }

  Future<void> _process() async {
    if (widget.token == null || widget.token!.isEmpty) {
      setState(() => _error = 'Token tak dijumpai. Cuba login semula.');
      return;
    }

    final vm = context.read<AuthViewModel>();
    final success = await vm.loginWithToken(widget.token!);

    if (!mounted) return;

    if (success) {
      context.go('/dashboard');
    } else {
      setState(() => _error = vm.errorMessage ?? 'Login gagal. Cuba lagi.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _error != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.red, size: 40),
                  const SizedBox(height: 16),
                  Text(_error!, style: const TextStyle(fontSize: 15)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Balik ke Login'),
                  ),
                ],
              )
            : const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Signing you in...'),
                ],
              ),
      ),
    );
  }
}