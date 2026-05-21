import 'package:adastra_portal/app/api/config.dart' show ApiService;
import 'package:adastra_portal/app/module/login/model/login_model.dart';
import 'package:flutter/foundation.dart';


enum AuthState { idle, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  AuthState _state = AuthState.idle;
  String? _errorMessage;
  String? _token;
  User? _currentUser;

  // Getters
  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  String? get token => _token;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _token != null;

  Future<bool> login(String email, String password) async {
    _setState(AuthState.loading);
    _errorMessage = null;

    try {
      final response = await _apiService.login(email, password);

      if (response.success && response.token != null) {
        _token = response.token;
        _currentUser = response.user;
        _setState(AuthState.success);
        return true;
      } else {
        _errorMessage = response.message ?? 'Login failed';
        _setState(AuthState.error);
        return false;
      }
    } catch (e) {
      _errorMessage = 'Cannot connect to server. Check your connection.';
      _setState(AuthState.error);
      return false;
    }
  }

  Future<void> logout() async {
    if (_token == null) return;

    _setState(AuthState.loading);
    try {
      await _apiService.logout(_token!);
    } catch (_) {
      // Even if API call fails, clear local state
    }

    _token = null;
    _currentUser = null;
    _setState(AuthState.idle);
  }

  Future<void> fetchMe() async {
    if (_token == null) return;
    try {
      final user = await _apiService.getMe(_token!);
      if (user != null) {
        _currentUser = user;
        notifyListeners();
      }
    } catch (_) {}
  }

  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    _state = AuthState.idle;
    notifyListeners();
  }
}