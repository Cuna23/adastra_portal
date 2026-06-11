import 'package:flutter/material.dart';
import '../model/incident_model.dart';
import '../services/incident_service.dart';

class IncidentVM extends ChangeNotifier {
  final _service = IncidentService();

  // ── State ─────────────────────────────────────────────────────────────────
  List<IncidentModel> _incidents = [];
  IncidentModel? _selected;
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;
  String _filterStatus = 'All';

  // ── Getters ───────────────────────────────────────────────────────────────
  List<IncidentModel> get incidents => _filterStatus == 'All'
      ? _incidents
      : _incidents
          .where((i) => i.status.toLowerCase() == _filterStatus.toLowerCase())
          .toList();

  IncidentModel? get selected => _selected;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  String get filterStatus => _filterStatus;

  int get countAll => _incidents.length;
  // [FIX] Match exact status strings returned by backend ('Open' not 'open')
  int get countOpen => _incidents.where((i) => i.status == 'Open').length;
  int get countInProgress =>
      _incidents.where((i) => i.status == 'In Progress').length;
  int get countResolved =>
      _incidents.where((i) => i.status == 'Resolved').length;

  // ── Fetch all incidents ───────────────────────────────────────────────────
  Future<void> fetchIncidents(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _incidents = await _service.getIncidents(token);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Fetch single incident with logs ───────────────────────────────────────
  Future<void> selectIncident(String token, int id) async {
    _selected = null;
    notifyListeners();

    try {
      _selected = await _service.getIncident(id, token);
    } catch (e) {
      // Keep selected null — dialog shows loading state
    }

    notifyListeners();
  }

  // ── Create new incident ───────────────────────────────────────────────────
  Future<bool> createIncident({
    required String token,
    required String subject,
    required String description,
    required String category,
    required String priority,
    attachmentFile,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      await _service.createIncident(
        token: token,
        subject: subject,
        description: description,
        category: category,
        priority: priority,
        attachment: attachmentFile,
      );
      await fetchIncidents(token);
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  // ── Add note (only staff-permitted action after submit) ───────────────────
  Future<bool> addNote({
    required String token,
    required int id,
    required String note,
  }) async {
    try {
      _selected = await _service.addNote(
        id: id,
        note: note,
        token: token,
      );
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Filter ────────────────────────────────────────────────────────────────
  void setFilter(String status) {
    _filterStatus = status;
    notifyListeners();
  }

  void clearSelected() {
    _selected = null;
    notifyListeners();
  }
}