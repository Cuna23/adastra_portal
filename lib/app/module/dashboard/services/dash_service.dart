import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/dash_model.dart';

class DashboardService {
  final String baseUrl = "https://adastra-api.onrender.com/api";

  Future<Map<String, dynamic>> _fetchRaw(String token) async {
    final res = await http.get(
      Uri.parse('$baseUrl/dashboard/stats'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    return jsonDecode(res.body);
  }

  Future<AdminDashboardStats> getAdminStats(String token) async {
    final json = await _fetchRaw(token);
    return AdminDashboardStats.fromJson(json);
  }

  Future<StaffDashboardStats> getStaffStats(String token) async {
    final json = await _fetchRaw(token);
    return StaffDashboardStats.fromJson(json);
  }
}