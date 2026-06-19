import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../model/incident_model.dart';

class IncidentService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  Map<String, String> _headers(String token) => {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // ── Fetch all incidents ───────────────────────────────────────────────────
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

  // ── Create new incident ───────────────────────────────────────────────────
  Future<IncidentModel> createIncident({
    required String token,
    required String subject,
    required String description,
    required String category,
    required String priority,
    List<int>? attachment,
    String? filename,
  }) async {
    final req = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/incidents'),
    )
      ..headers.addAll(_headers(token))
      ..fields['subject']     = subject
      ..fields['description'] = description
      ..fields['category']    = category
      ..fields['priority']    = priority;

  if (attachment != null && filename != null) {
    final ext = filename.split('.').last.toLowerCase();
    final mime = switch (ext) {
      'jpg' || 'jpeg' => MediaType('image', 'jpeg'),
      'png'           => MediaType('image', 'png'),
      'pdf'           => MediaType('application', 'pdf'),
      _               => MediaType('application', 'octet-stream'),
    };

    req.files.add(
      http.MultipartFile.fromBytes(
        'attachment',
        attachment,
        filename: filename,
        contentType: mime,
      ),
    );
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

  // ── Add note — sends 'note' field, NEVER touches description ─────────────
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
      body: jsonEncode({'note': note}),  // 'note' not 'description'
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return IncidentModel.fromJson(data['data']);
    }
    final body = jsonDecode(res.body);
    throw Exception(body['message'] ?? 'Failed to add note');
  }

  // ── Update existing note ──────────────────────────────────────────────────
  Future<IncidentModel> updateNote({
    required String token,
    required int incidentId,
    required int logId,
    required String note,
  }) async {
    final res = await http.put(
      Uri.parse('$baseUrl/incidents/$incidentId/logs/$logId'),
      headers: {
        ..._headers(token),
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'note': note}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return IncidentModel.fromJson(data['data']);
    }
    final body = jsonDecode(res.body);
    throw Exception(body['message'] ?? 'Failed to update note');
  }

  // ── Delete a note ─────────────────────────────────────────────────────────
  Future<IncidentModel> deleteNote({
    required String token,
    required int incidentId,
    required int logId,
  }) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/incidents/$incidentId/logs/$logId'),
      headers: _headers(token),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return IncidentModel.fromJson(data['data']);
    }
    final body = jsonDecode(res.body);
    throw Exception(body['message'] ?? 'Failed to delete note');
  }

  // ── Update Incident Admin Fields ─────────────────────────────────────────
  Future<IncidentModel> updateIncidentAdmin({
    required int id,
    required String token,
    required String category,
    required String priority,
    required String status,
    required int? assignedTo,
    required String? resolution,
  }) async {
    final res = await http.put(
      Uri.parse('$baseUrl/incidents/$id'),
      headers: {
        ..._headers(token),
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'category': category,
        'priority': priority,
        'status': status,
        'assigned_to': assignedTo,
        'resolution': resolution,
      }),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return IncidentModel.fromJson(data['data']);
    }
    final body = jsonDecode(res.body);
    throw Exception(body['message'] ?? 'Failed to update incident');
  }
}