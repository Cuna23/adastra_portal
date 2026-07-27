import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../model/comp_model.dart';


class CompanyService {
  final String baseUrl = "http://127.0.0.1:8000/api";

  Future<CompanyModel?> getOrgChart(String token) async {
    final res = await http.get(
      Uri.parse('$baseUrl/org-chart'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    if (res.statusCode != 200 || res.body == 'null') return null;
    return CompanyModel.fromJson(jsonDecode(res.body));
  }

  Future<List<CompanyModel>> getFloorMaps(String token) async {
    final res = await http.get(
      Uri.parse('$baseUrl/floor-maps'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    final data = jsonDecode(res.body) as List;
    return data.map((e) => CompanyModel.fromJson(e)).toList();
  }

  // [NEW] XFile from image_picker works on web & mobile (unlike dart:io File)
  Future<bool> uploadOrgChart(XFile image, String token) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/org-chart'));
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';
    final bytes = await image.readAsBytes();
    request.files.add(http.MultipartFile.fromBytes('image', bytes, filename: image.name));
    final streamed = await request.send();
    return streamed.statusCode == 201;
  }

  Future<bool> uploadFloorMap(XFile image, String title, String token) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/floor-maps'));
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';
    request.fields['title'] = title;
    final bytes = await image.readAsBytes();
    request.files.add(http.MultipartFile.fromBytes('image', bytes, filename: image.name));
    final streamed = await request.send();
    return streamed.statusCode == 201;
  }

  Future<bool> deleteCompanyItem(int id, String token) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/company/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return res.statusCode == 200;
  }
}