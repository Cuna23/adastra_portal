import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/asset_model.dart';

class AssetService {
  static const String baseUrl = 'https://adastra-api.onrender.com/api';

  Future<List<AssetModel>> getAssets(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/assets'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List assets = data['data'];

      return assets
          .map((asset) => AssetModel.fromJson(asset))
          .toList();
    }

    throw Exception('Failed to load assets');
  }

  Future<void> deleteAsset(
    int id,
    String token,
  ) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/assets/$id'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete asset');
    }
  }
}