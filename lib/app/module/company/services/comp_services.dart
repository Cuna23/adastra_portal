import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../model/comp_model.dart';

class CompanyService {
  final String baseUrl = "https://adastra-api.onrender.com/api";

  Map<String, String> _headers(String token) => {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

  Future<CompanyModel?> getOrgChart(String token) async {
    final res = await http.get(Uri.parse('$baseUrl/org-chart'), headers: _headers(token));
    if (res.statusCode != 200 || res.body == 'null') return null;
    return CompanyModel.fromJson(jsonDecode(res.body));
  }

  Future<List<CompanyModel>> getFloorMaps(String token) async {
    final res = await http.get(Uri.parse('$baseUrl/floor-maps'), headers: _headers(token));
    final data = jsonDecode(res.body) as List;
    return data.map((e) => CompanyModel.fromJson(e)).toList();
  }

  Future<CompanyModel?> getAbout(String token) async {
    final res = await http.get(Uri.parse('$baseUrl/about'), headers: _headers(token));
    if (res.statusCode != 200 || res.body == 'null') return null;
    return CompanyModel.fromJson(jsonDecode(res.body));
  }

  Future<CompanyModel?> getVisionMission(String token) async {
    final res = await http.get(Uri.parse('$baseUrl/vision-mission'), headers: _headers(token));
    if (res.statusCode != 200 || res.body == 'null') return null;
    return CompanyModel.fromJson(jsonDecode(res.body));
  }

  Future<bool> uploadOrgChart(XFile image, String token, {String? title}) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/org-chart'));
    request.headers.addAll(_headers(token));
    if (title != null) request.fields['title'] = title;
    final bytes = await image.readAsBytes();
    request.files.add(http.MultipartFile.fromBytes('image', bytes, filename: image.name));
    final streamed = await request.send();
    return streamed.statusCode == 201;
  }

  Future<bool> uploadFloorMap(XFile image, String title, String token) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/floor-maps'));
    request.headers.addAll(_headers(token));
    request.fields['title'] = title;
    final bytes = await image.readAsBytes();
    request.files.add(http.MultipartFile.fromBytes('image', bytes, filename: image.name));
    final streamed = await request.send();
    return streamed.statusCode == 201;
  }

  Future<bool> updateTitle(int id, String title, String token) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/company/$id/title'),
      headers: {..._headers(token), 'Content-Type': 'application/json'},
      body: jsonEncode({'title': title}),
    );
    return res.statusCode == 200;
  }

  Future<bool> updateAbout(String content, String token) async {
    final res = await http.post(
      Uri.parse('$baseUrl/company/content'),
      headers: {..._headers(token), 'Content-Type': 'application/json'},
      body: jsonEncode({'type': 'about', 'content': content}),
    );
    return res.statusCode == 200;
  }

  Future<bool> updateVisionMission(String vision, String mission, String token) async {
    final res = await http.post(
      Uri.parse('$baseUrl/company/content'),
      headers: {..._headers(token), 'Content-Type': 'application/json'},
      body: jsonEncode({'type': 'vision_mission', 'vision': vision, 'mission': mission}),
    );
    return res.statusCode == 200;
  }

  Future<bool> deleteCompanyItem(int id, String token) async {
    final res = await http.delete(Uri.parse('$baseUrl/company/$id'), headers: _headers(token));
    return res.statusCode == 200;
  }
}