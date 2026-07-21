import 'package:adastra_portal/app/api/config.dart' show ApiService;
import 'package:adastra_portal/app/module/login/model/login_model.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';


enum AuthState { idle, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  AuthState _state = AuthState.idle;
  String? _errorMessage;
  String? _token;
  User? _currentUser;
  bool _isInitializing = true; //save token state when app is initializing

  // Getters
  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  String? get token => _token;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _token != null;
  bool get isInitializing => _isInitializing;

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('auth_token');

    if (savedToken == null) {
      _isInitializing = false;
      notifyListeners();
      return;
    }

    _token = savedToken;
    try {
      final user = await _apiService.getMe(savedToken);
      if (user != null) {
        _currentUser = user;
        _state = AuthState.success;
      } else {
        // token invalid/expired
        _token = null;
        await prefs.remove('auth_token');
      }
    } catch (_) {
      _token = null;
      await prefs.remove('auth_token');
    }

    _isInitializing = false;
    notifyListeners();
  }
  
  Future<bool> login(String email, String password) async {
    _setState(AuthState.loading);
    _errorMessage = null;

    try {
      final response = await _apiService.login(email, password);

      if (response.success && response.token != null) {
        _token = response.token;
        _currentUser = response.user;

      final prefs = await SharedPreferences.getInstance(); 
      await prefs.setString('auth_token', _token!);    

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

    final prefs = await SharedPreferences.getInstance(); 
    await prefs.remove('auth_token'); 

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

  Future<bool> loginWithToken(String token) async {
    _setState(AuthState.loading);
    _errorMessage = null;

    _token = token;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);

    try {
      final user = await _apiService.getMe(token);
      if (user != null) {
        _currentUser = user;
        _setState(AuthState.success);
        return true;
      } else {
        _errorMessage = 'Failed to fetch user info';
        _setState(AuthState.error);
        return false;
      }
    } catch (e) {
      _errorMessage = 'Cannot connect to server. Check your connection.';
      _setState(AuthState.error);
      return false;
    }
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