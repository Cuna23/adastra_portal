import 'package:adastra_portal/app/module/user/model/user_model.dart';
import 'package:adastra_portal/app/module/user/services/user_services.dart';
import 'package:flutter/material.dart';


class UserViewModel extends ChangeNotifier {
  final UserService _service = UserService();

  List<UserModel> users = [];
  bool isLoading = false;

  Future<void> fetchUsers(String token) async {
    isLoading = true;
    notifyListeners();

    users = await _service.getUsers(token);

    isLoading = false;
    notifyListeners();
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