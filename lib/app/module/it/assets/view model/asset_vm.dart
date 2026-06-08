import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../user/model/department_model.dart';
import '../../../user/model/user_model.dart';
import '../model/assetCategory_model.dart';
import '../model/asset_model.dart';

class AssetViewModel extends ChangeNotifier {
  // ── State ─────────────────────────────────────────────────────────────────
  List<AssetModel>         assets     = [];
  List<AssetCategoryModel> categories = [];
  List<UserModel> users = [];
  List<DepartmentModel> departments = [];
  bool    isLoading  = false;
  String? errorMessage;

  // Pagination
  int currentPage = 1;
  int lastPage    = 1;
  int total       = 0;
  int perPage     = 30;

  // Active filters
  int?    selectedCategoryId;
  String? _searchQuery;

  static const String _base = 'http://localhost:8000/api'; // ← replace

  Future<void> fetchUsers(String token) async {
    final res = await http.get(
      Uri.parse('$_base/users'),
      headers: _headers(token),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;

      users = data
          .map((e) => UserModel.fromJson(e))
          .toList();

      notifyListeners();
    }
  }

Future<void> fetchDepartments(String token) async {
  final res = await http.get(
    Uri.parse('$_base/departments'),
    headers: _headers(token),
  );

  print("Department Status: ${res.statusCode}");
  print("Department Response: ${res.body}");

  if (res.statusCode == 200) {
    final data = jsonDecode(res.body) as List;

    departments = data
        .map((e) => DepartmentModel.fromJson(e))
        .toList();

    print("Department Count: ${departments.length}");

    notifyListeners();
  }
}
  // ── Categories ────────────────────────────────────────────────────────────

  Future<void> fetchCategories(String token) async {
    try {
      final res = await http.get(
        Uri.parse('$_base/asset-categories'),
        headers: _headers(token),
      );
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body) as List;
        categories =
            data.map((e) => AssetCategoryModel.fromJson(e as Map<String, dynamic>)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('fetchCategories: $e');
    }
  }

  void selectCategory(int? id, String token) {
    selectedCategoryId = id;
    currentPage = 1;
    fetchAssets(token);
  }

  // ── Assets ────────────────────────────────────────────────────────────────

  Future<void> fetchAssets(
    String token, {
    String? search,
    int page = 1,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    if (search != null) _searchQuery = search.isEmpty ? null : search;

    try {
      final params = <String, String>{
        'page':     page.toString(),
        'per_page': perPage.toString(),
        if (_searchQuery != null) 'search': _searchQuery!,
        if (selectedCategoryId != null)
          'category_id': selectedCategoryId.toString(),
      };

      final uri = Uri.parse('$_base/assets')
          .replace(queryParameters: params);
      final res = await http.get(uri, headers: _headers(token));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        assets = (body['data'] as List)
            .map((e) => AssetModel.fromJson(e as Map<String, dynamic>))
            .toList();
        currentPage = body['current_page'] as int? ?? 1;
        lastPage    = body['last_page']    as int? ?? 1;
        total       = body['total']        as int? ?? 0;
        perPage     = body['per_page']     as int? ?? 30;
        print('Per Page Sent: $perPage');
      } else {
        errorMessage = 'Failed to load assets (${res.statusCode})';
      }
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────

  Future<void> createAsset(String token, Map<String, dynamic> data) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/assets'),
        headers: {..._headers(token), 'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      if (res.statusCode == 201) {
        await fetchAssets(token, page: currentPage);
      } else {
        _setError(res);
      }
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateAsset(
      String token, int id, Map<String, dynamic> data) async {
    try {
      final res = await http.put(
        Uri.parse('$_base/assets/$id'),
        headers: {..._headers(token), 'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      if (res.statusCode == 200) {
        await fetchAssets(token, page: currentPage);
      } else {
        _setError(res);
      }
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Optimistic remove — mirrors UserViewModel.removeUser
  Future<void> removeAsset(int id, String token) async {
    assets.removeWhere((a) => a.id == id);
    if (total > 0) total--;
    notifyListeners();

    try {
      final res = await http.delete(
        Uri.parse('$_base/assets/$id'),
        headers: _headers(token),
      );
      if (res.statusCode != 200) {
        // Rollback — re-fetch on failure
        await fetchAssets(token, page: currentPage);
      }
    } catch (e) {
      await fetchAssets(token, page: currentPage);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Map<String, String> _headers(String token) => {
        'Authorization': 'Bearer $token',
        'Accept':        'application/json',
      };

  void _setError(http.Response res) {
    try {
      errorMessage =
          (jsonDecode(res.body) as Map<String, dynamic>)['message'] as String?
          ?? 'Error ${res.statusCode}';
    } catch (_) {
      errorMessage = 'Error ${res.statusCode}';
    }
    notifyListeners();
  }
}