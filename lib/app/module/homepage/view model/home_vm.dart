import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  // ── Navigation state ──
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  final List<String> pageTitles = [
    'Dashboard',
    'User Management',
    'Terra',
    'Zoho',
    'Autocount',
    'Assets Inventory',
    'Ticketing System',
    'Incident Report',    
    'Service Request', 
  ];

  String get currentPageTitle => pageTitles[_selectedIndex];

  // ── Called by View when user taps a sidebar item ──
  void selectPage(int index) {
    if (_selectedIndex == index) return; 
    _selectedIndex = index;
    notifyListeners();
  }
}