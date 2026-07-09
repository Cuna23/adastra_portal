import 'package:flutter/material.dart';
import '../model/sr_model.dart';
import '../services/sr_service.dart';


class ServiceRequestViewModel extends ChangeNotifier {
  final ServiceRequestService _service = ServiceRequestService();

  List<ServiceRequestModel> requests = [];
  bool isLoading = false;

  Future<void> fetchRequests(String token, {String? status}) async {
    isLoading = true;
    notifyListeners();

    requests = await _service.getServiceRequests(token, status: status);

    isLoading = false;
    notifyListeners();
  }

  Future<ServiceRequestModel> fetchDetail(int id, String token) async {
    return await _service.getServiceRequestDetail(id, token);
  }

  Future<void> submitRequest(
    ServiceRequestModel request,
    String token, {
    String? attachmentPath,
  }) async {
    await _service.createServiceRequest(request, token,
        attachmentPath: attachmentPath);
    await fetchRequests(token);
  }

  Future<void> editRequest(
    int id,
    ServiceRequestModel request,
    String token, {
    String? attachmentPath,
  }) async {
    await _service.updateServiceRequest(id, request, token,
        attachmentPath: attachmentPath);
    await fetchRequests(token);
  }
}