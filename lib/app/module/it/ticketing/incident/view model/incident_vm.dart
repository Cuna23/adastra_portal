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
  String _search = ''; 
  List<IncidentDailyCount> _weeklyStats = [];
  bool _isLoadingStats = false;

  // ── Getters ───────────────────────────────────────────────────────────────
  List<IncidentModel> get incidents {
    Iterable<IncidentModel> list;

    if (_filterStatus == 'All') {
      list = _incidents;
    } else if (_filterStatus == 'Unresolved') {
      list = _incidents.where((i) => i.status != 'Resolved');
    } else if (_filterStatus == 'Unassigned') {
      list = _incidents.where((i) => i.assignedUser == null);
    } else {
      list = _incidents.where(
          (i) => i.status.toLowerCase() == _filterStatus.toLowerCase());
    }

    if (_search.trim().isNotEmpty) {
      final q = _search.trim().toLowerCase();
      list = list.where((i) =>
        i.ticketNo.toLowerCase().contains(q) ||
        i.subject.toLowerCase().contains(q),
      );
    }

    return list.toList();
  }

  List<IncidentDailyCount> get weeklyStats => _weeklyStats;
  bool get isLoadingStats => _isLoadingStats;

  IncidentModel? get selected => _selected;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  String get filterStatus => _filterStatus;

  int get countAll => _incidents.length;
  int get countUnresolved =>
      _incidents.where((i) => i.status != 'Resolved').length;
  int get countOpen => _incidents.where((i) => i.status == 'Open').length;
  int get countInPending =>
      _incidents.where((i) => i.status == 'In Pending').length;
  int get countResolved =>
      _incidents.where((i) => i.status == 'Resolved').length;
  int get countReview => _incidents.where((i) => i.status == 'Review').length;
  int get countUnassigned =>
      _incidents.where((i) => i.assignedUser == null).length;

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
    List<int>? attachmentFile,
    String? filename,
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
        filename: filename,
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

  // ── Update existing note ──────────────────────────────────────────────────
  Future<bool> updateNote({
    required String token,
    required int incidentId,
    required int logId,
    required String note,
  }) async {
    try {
      _selected = await _service.updateNote(
        incidentId: incidentId,
        logId: logId,
        note: note,
        token: token,
      );
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Delete a note ─────────────────────────────────────────────────────────
  Future<bool> deleteNote({
    required String token,
    required int incidentId,
    required int logId,
  }) async {
    try {
      _selected = await _service.deleteNote(
        incidentId: incidentId,
        logId: logId,
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

  // [ADDED] Search — used by table search bar in admin/superadmin view
  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  void clearSelected() {
    _selected = null;
    notifyListeners();
  }

  // ── Update Incident Fields (Admin Only) ──────────────────────────────────
  Future<bool> updateIncidentFields({
    required String token,
    required int id,
    required String category,
    required String priority,
    required String status,
    required int? assignedTo,
    required String? resolution,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      _selected = await _service.updateIncidentAdmin(
        id: id,
        token: token,
        category: category,
        priority: priority,
        status: status,
        assignedTo: assignedTo,
        resolution: resolution,
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

  Future<void> fetchWeeklyStats(String token) async {
    _isLoadingStats = true;
    notifyListeners();

    try {
      _weeklyStats = await _service.getWeeklyStats(token);
    } catch (_) {
      _weeklyStats = [];
    }

    _isLoadingStats = false;
    notifyListeners();
  }
}