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

    final data = jsonDecode(response.body) as List;

    return data.map((e) => UserModel.fromJson(e)).toList();
  }

  Future<void> createUser(UserModel user, String password, String token) async {
    await http.post(
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
  }

  Future<void> updateUser(int id, UserModel user, String token) async {
    await http.put(
      Uri.parse('$baseUrl/users/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(user.toJson()),
    );
  }

  Future<void> deleteUser(int id, String token) async {
    await http.delete(
      Uri.parse('$baseUrl/users/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }
}