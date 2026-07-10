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

  Future<void> fetchRequests(String token, {String? status}) async {
    isLoading = true;
    notifyListeners();

    requests = await _service.getServiceRequests(token, status: status);

    isLoading = false;
    notifyListeners();
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
}