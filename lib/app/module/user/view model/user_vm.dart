import 'dart:convert';
import 'package:adastra_portal/app/module/user/model/user_model.dart';
import 'package:adastra_portal/app/module/user/services/user_services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/department_model.dart';



class UserViewModel extends ChangeNotifier {
  final UserService _service = UserService();

  static const String _base = 'https://adastra-api.onrender.com/api';

  List<UserModel> users = [];
  List<DepartmentModel> departments = [];
  bool isLoading = false;

  Future<void> fetchUsers(String token) async {
    isLoading = true;
    notifyListeners();

    users = await _service.getUsers(token);

    isLoading = false;
    notifyListeners();
  }

  Future<void> fetchDepartments(String token) async {
    final res = await http.get(
      Uri.parse('$_base/departments'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      departments = data.map((e) => DepartmentModel.fromJson(e)).toList();
      notifyListeners();
    }
  }

  Future<void> addUser(UserModel user, String password, String token) async {
    await _service.createUser(user, password, token);
    await fetchUsers(token);
  }

  Future<void> editUser(int id, UserModel user, String token) async {
    await _service.updateUser(id, user, token);
    await fetchUsers(token);
  }

  Future<void> removeUser(int id, String token) async {
    await _service.deleteUser(id, token);
    await fetchUsers(token);
  }
}