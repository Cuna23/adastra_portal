import 'package:flutter/material.dart';
import '../model/calendar_model.dart';
import '../services/calendar_service.dart';

class CalendarViewModel extends ChangeNotifier {
  final CalendarService _service = CalendarService();

  DateTime focusedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  List<CalendarEvent> events = [];
  bool isLoading = false;

  Future<void> fetchEvents(String token) async {
    isLoading = true;
    notifyListeners();
    try {
      events = await _service.getEvents(token, focusedMonth.month, focusedMonth.year);
    } catch (e) {
      debugPrint('fetchEvents error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void nextMonth(String token) {
    focusedMonth = DateTime(focusedMonth.year, focusedMonth.month + 1, 1);
    fetchEvents(token);
  }

  void previousMonth(String token) {
    focusedMonth = DateTime(focusedMonth.year, focusedMonth.month - 1, 1);
    fetchEvents(token);
  }

  List<CalendarEvent> eventsOn(DateTime day) {
    return events.where((e) => e.date.year == day.year && e.date.month == day.month && e.date.day == day.day).toList();
  }

  Future<bool> addReminder(String token, String title, String? note, DateTime date) async {
    final ok = await _service.addReminder(token, title, note, date);
    if (ok) await fetchEvents(token);
    return ok;
  }

  Future<bool> deleteReminder(String token, int id) async {
    final ok = await _service.deleteReminder(token, id);
    if (ok) await fetchEvents(token);
    return ok;
  }
}