import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../model/incident_model.dart';

class IncidentService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  Map<String, String> _headers(String token) => {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // ── Fetch all incidents (backend filters by current user for staff) ────────
  Future<List<IncidentModel>> getIncidents(String token) async {
    final res = await http.get(
      Uri.parse('$baseUrl/incidents'),
      headers: _headers(token),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return (data['data'] as List)
          .map((j) => IncidentModel.fromJson(j))
          .toList();
    }
    throw Exception('Failed to load incidents');
  }

  // ── Fetch single incident with logs ───────────────────────────────────────
  Future<IncidentModel> getIncident(int id, String token) async {
    final res = await http.get(
      Uri.parse('$baseUrl/incidents/$id'),
      headers: _headers(token),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return IncidentModel.fromJson(data['data']);
    }
    throw Exception('Failed to load incident');
  }

  // ── Create new incident (with optional attachment) ────────────────────────
  Future<IncidentModel> createIncident({
    required String token,
    required String subject,
    required String description,
    required String category,
    required String priority,
    File? attachment,
  }) async {
    final req = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/incidents'),
    )
      ..headers.addAll(_headers(token))
      ..fields['subject'] = subject
      ..fields['description'] = description
      ..fields['category'] = category
      ..fields['priority'] = priority;

    if (attachment != null) {
      final ext = attachment.path.split('.').last.toLowerCase();
      req.files.add(await http.MultipartFile.fromPath(
        'attachment',
        attachment.path,
        contentType: MediaType(
          ext == 'pdf' ? 'application' : 'image',
          ext == 'pdf' ? 'pdf' : ext,
        ),
      ));
    }

    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode == 201) {
      final data = jsonDecode(res.body);
      return IncidentModel.fromJson(data['data']);
    }
    final body = jsonDecode(res.body);
    throw Exception(body['message'] ?? 'Failed to create incident');
  }

  // ── Add note — staff ONLY allowed action after submit ─────────────────────
  // Sends as a log entry via PUT description field.
  // Backend logs this as 'Updated' action in incident_logs.
  Future<IncidentModel> addNote({
    required int id,
    required String note,
    required String token,
  }) async {
    final res = await http.put(
      Uri.parse('$baseUrl/incidents/$id'),
      headers: {
        ..._headers(token),
        'Content-Type': 'application/json',
      },

      body: jsonEncode({'description': note}),
    );

    if (res.statusCode == 200) {
      // Re-fetch with logs after adding note
      return await getIncident(id, token);
    }
    final body = jsonDecode(res.body);
    throw Exception(body['message'] ?? 'Failed to add note');
  }
}