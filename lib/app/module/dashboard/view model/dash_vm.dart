import 'package:flutter/material.dart';
import '../model/dash_model.dart';
import '../services/dash_service.dart';

class DashboardViewModel extends ChangeNotifier {
  final DashboardService _service = DashboardService();

  AdminDashboardStats? adminStats;
  StaffDashboardStats? staffStats;
  bool isLoading = false;

  Future<void> fetchAdmin(String token) async {
    isLoading = true;
    notifyListeners();
    try {
      adminStats = await _service.getAdminStats(token);
    } catch (e) {
      debugPrint('fetchAdmin dashboard error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchStaff(String token) async {
    isLoading = true;
    notifyListeners();
    try {
      staffStats = await _service.getStaffStats(token);
    } catch (e) {
      debugPrint('fetchStaff dashboard error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}