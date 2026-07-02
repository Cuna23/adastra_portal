import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  final List<String> pageTitles = [
    'Dashboard', 'User Management', 'Terra', 'Zoho', 'Autocount',
    'Assets Inventory', 'Ticketing System', 'Incident Report', 'Service Request',
  ];

  final List<String> pageRoutes = [
    '/dashboard', '/users', '/terra', '/zoho', '/autocount',
    '/assets', '/ticketing', '/incident', '/service-request',
  ];

  String get currentPageTitle => pageTitles[_selectedIndex];

  void selectPageFromRoute(String path) {
    final idx = pageRoutes.indexOf(path);
    if (idx != -1 && idx != _selectedIndex) {
      _selectedIndex = idx;
      Future.microtask(notifyListeners); // [NEW] avoid setState-during-build error
    }
  }
}