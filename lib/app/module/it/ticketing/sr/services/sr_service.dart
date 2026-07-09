import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/sr_model.dart';


class ServiceRequestService {
  final String baseUrl = "http://127.0.0.1:8000/api";

  Future<List<ServiceRequestModel>> getServiceRequests(
    String token, {
    String? status,
    String? search,
  }) async {
    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status;
    if (search != null) queryParams['search'] = search;

    final uri = Uri.parse(' $baseUrl/service-requests')
        .replace(queryParameters: queryParams.isEmpty ? null : queryParams);

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    final data = jsonDecode(response.body) as List;
    return data.map((e) => ServiceRequestModel.fromJson(e)).toList();
  }

  Future<ServiceRequestModel> getServiceRequestDetail(
      int id, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/service-requests/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    return ServiceRequestModel.fromJson(jsonDecode(response.body));
  }

  Future<void> createServiceRequest(
    ServiceRequestModel request,
    String token, {
    String? attachmentPath,
  }) async {
    final uri = Uri.parse('$baseUrl/service-requests');
    final multipartRequest = http.MultipartRequest('POST', uri);

    multipartRequest.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    request.toJson().forEach((key, value) {
      multipartRequest.fields[key] = value.toString();
    });

    if (attachmentPath != null) {
      multipartRequest.files
          .add(await http.MultipartFile.fromPath('attachment', attachmentPath));
    }

    await multipartRequest.send();
  }

  Future<void> updateServiceRequest(
    int id,
    ServiceRequestModel request,
    String token, {
    String? attachmentPath,
  }) async {
    final uri = Uri.parse('$baseUrl/service-requests/$id');
    final multipartRequest = http.MultipartRequest('POST', uri);
    multipartRequest.fields['_method'] = 'PUT';

    multipartRequest.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    request.toJson().forEach((key, value) {
      multipartRequest.fields[key] = value.toString();
    });

    if (attachmentPath != null) {
      multipartRequest.files
          .add(await http.MultipartFile.fromPath('attachment', attachmentPath));
    }

    await multipartRequest.send();
  }
}