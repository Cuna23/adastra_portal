import 'package:adastra_portal/app/module/login/view/login_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/module/login/view model/login_vm.dart';


void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthViewModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      title: 'Auth Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F6EF7),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}