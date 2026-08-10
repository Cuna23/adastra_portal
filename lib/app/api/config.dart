import 'dart:convert';

import 'package:adastra_portal/app/module/login/model/login_model.dart';
import 'package:http/http.dart' as http;


class ApiService {
  static const String baseUrl = 'https://adastra-api.onrender.com/api';
  // Login
  Future<AuthResponse> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);
    return AuthResponse.fromJson(data);
  }

  // Logout
  Future<bool> logout(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    final data = jsonDecode(response.body);
    return data['success'] ?? false;
  }

  // Get current user
  Future<User?> getMe(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/me'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      return User.fromJson(data['user']);
    }
    return null;
  }
}