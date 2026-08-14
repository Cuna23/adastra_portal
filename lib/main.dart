import 'package:adastra_portal/app/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'app/module/login/view model/login_vm.dart';

void main() {
  usePathUrlStrategy(); 
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
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              scaffoldBackgroundColor: const Color(0xFFF4F7FC), // [NEW] konsisten dengan background sedia ada
              snackBarTheme: const SnackBarThemeData( // [NEW] fix utama — teks snackbar putih & jelas
                contentTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                behavior: SnackBarBehavior.floating,
                actionTextColor: Colors.white,
              ),
            ),
            routerConfig: _router,
          );
        },
      ),
    );
  }
}