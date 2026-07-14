import 'package:flutter/material.dart';
import '../model/sr_model.dart';
import '../services/sr_service.dart';

class ServiceRequestViewModel extends ChangeNotifier {
  final ServiceRequestService _service = ServiceRequestService();

  List<ServiceRequestModel> requests = [];
  ServiceRequestModel? selected;
  bool isLoading = false;
  bool isSubmitting = false;
  String? error;

  
  // ── Status counts (based on currently fetched requests) ──
  int get countAll => requests.length;
  int get countPending => requests.where((r) => r.status == 'pending').length;
  int get countApproved => requests.where((r) => r.status == 'approved').length;
  int get countRejected => requests.where((r) => r.status == 'rejected').length;

  Future<void> fetchRequests(String token, {String? status}) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      requests = await _service.getServiceRequests(token, status: status);
    } catch (e) {
      error = 'Failed to load service requests: $e';
      requests = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectRequest(String token, int id) async {
    selected = await _service.getServiceRequestDetail(id, token);
    notifyListeners();
  }

  void clearSelected() {
    selected = null;
    notifyListeners();
  }

  Future<bool> createRequest({
    required String token,
    required String requestTitle,
    required String requestType,
    required String category,
    required int quantity,
    required String priority,
    required String description,
    required DateTime neededByDate,
    List<int>? attachmentBytes,
    String? filename,
  }) async {
    isSubmitting = true;
    error = null;
    notifyListeners();

    final ok = await _service.createServiceRequest(
      token: token,
      requestTitle: requestTitle,
      requestType: requestType,
      category: category,
      quantity: quantity,
      priority: priority,
      description: description,
      neededByDate: neededByDate,
      attachmentBytes: attachmentBytes,
      filename: filename,
    );

    if (ok) {
      await fetchRequests(token);
    } else {
      error = 'Failed to submit service request';
    }

    isSubmitting = false;
    notifyListeners();
    return ok;
  }

  Future<bool> approveRequest(String token, int id) async {
    final result = await _service.approveServiceRequest(id, token);

    if (result['success'] == true) {
      selected = result['data'];
      await fetchRequests(token);
      notifyListeners();
      return true;
    } else {
      error = result['message'];
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectRequest(String token, int id, String reason) async {
    final result = await _service.rejectServiceRequest(id, token, reason);

    if (result['success'] == true) {
      selected = result['data'];
      await fetchRequests(token);
      notifyListeners();
      return true;
    } else {
      error = result['message'];
      notifyListeners();
      return false;
    }
  }

  Future<bool> addNote(String token, int id, String note) async {
    final result = await _service.addNote(id, token, note);

    if (result['success'] == true) {
      selected = result['data'];
      notifyListeners();
      return true;
    } else {
      error = result['message'];
      notifyListeners();
      return false;
    }
  }
}