import 'package:adastra_portal/app/router.dart'; // [NEW]
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'app/module/login/view model/login_vm.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget { 
  const MyApp({super.key});
 
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthViewModel _authVm;
  late final GoRouter _router; 

  @override
  void initState() {
    super.initState();
    _authVm = AuthViewModel();
    _router = buildRouter(_authVm); 
    _authVm.tryAutoLogin(); 
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _authVm,
      child: Builder(
        builder: (context) {
          final authVm = context.watch<AuthViewModel>();

          if (authVm.isInitializing) { // [NEW] splash while checking saved token
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          return MaterialApp.router(
            title: ' a Portal',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF4F6EF7),
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            routerConfig: _router,
          );
        },
      ),
    );
  }
}