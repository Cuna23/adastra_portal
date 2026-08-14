import 'dart:convert';
import 'package:adastra_portal/app/module/user/model/user_model.dart';
import 'package:http/http.dart' as http;

class UserService {
  final String baseUrl = "https://adastra-api.onrender.com/api";

  Future<List<UserModel>> getUsers(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load users (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as List;

    return data.map((e) => UserModel.fromJson(e)).toList();
  }

  Future<void> createUser(UserModel user, String password, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: jsonEncode({
        ...user.toJson(),
        'password': password,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(_extractMessage(response.body, fallback: 'Failed to create user (${response.statusCode})'));
    }
  }

  Future<void> updateUser(int id, UserModel user, String token) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception(_extractMessage(response.body, fallback: 'Failed to update user (${response.statusCode})'));
    }
  }

  Future<void> deleteUser(int id, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/users/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(_extractMessage(response.body, fallback: 'Failed to delete user (${response.statusCode})'));
    }
  }

  // Try to pull Laravel's {"message": "..."} error body; fall back to a generic message
  // if body isn't JSON or doesn't have that shape (e.g. network/HTML error page).
  String _extractMessage(String body, {required String fallback}) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['message'] != null) {
        return decoded['message'].toString();
      }
    } catch (_) {
      // body wasn't JSON — ignore and use fallback
    }
    return fallback;
  }
}