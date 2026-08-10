import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/calendar_model.dart';

class CalendarService {
  final String baseUrl = "https://adastra-api.onrender.com/api";

  Map<String, String> _headers(String token) => {'Authorization': 'Bearer $token', 'Accept': 'application/json'};

  Future<List<CalendarEvent>> getEvents(String token, int month, int year) async {
    final res = await http.get(Uri.parse('$baseUrl/calendar?month=$month&year=$year'), headers: _headers(token));
    final json = jsonDecode(res.body);
    return (json['events'] as List).map((e) => CalendarEvent.fromJson(e)).toList();
  }

  Future<bool> addReminder(String token, String title, String? note, DateTime date) async {
    final res = await http.post(
      Uri.parse('$baseUrl/reminders'),
      headers: {..._headers(token), 'Content-Type': 'application/json'},
      body: jsonEncode({'title': title, 'note': note, 'date': date.toIso8601String().split('T').first}),
    );
    return res.statusCode == 201;
  }

  Future<bool> deleteReminder(String token, int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/reminders/$id'), headers: _headers(token));
    return res.statusCode == 200;
  }
}