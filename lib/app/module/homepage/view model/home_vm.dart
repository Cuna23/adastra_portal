import 'package:flutter/material.dart';

// [NEW] Route -> Title map, replaces fixed-index pageTitles/pageRoutes
class HomeViewModel extends ChangeNotifier {
  static const Map<String, String> routeTitles = {
    '/company': 'Company Hub',
    '/dashboard': 'Dashboard',
    '/users': 'User Management',
    '/terra': 'Terra',
    '/zoho': 'Zoho',
    '/autocount': 'Autocount',
    '/assets': 'Assets Inventory',
    '/incident': 'Incident Report',
    '/service-request': 'Service Request',
  };

  String _currentPath = '/dashboard';
  String get currentPath => _currentPath;

  String get currentPageTitle => routeTitles[_currentPath] ?? '—';

  // [CHANGED] no more index lookup — just store the matched path directly
  void selectPageFromRoute(String path) {
    if (path != _currentPath) {
      _currentPath = path;
      Future.microtask(notifyListeners);
    }
  }
}