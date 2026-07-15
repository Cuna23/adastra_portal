import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/sr_model.dart';

class ServiceRequestService {
  final String baseUrl = "http://localhost:8000/api";

  Future<List<ServiceRequestModel>> getServiceRequests(
    String token, {
    String? status,
    String? search,
  }) async {
    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status;
    if (search != null) queryParams['search'] = search;

    final uri = Uri.parse('$baseUrl/service-requests')
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

  Future<bool> createServiceRequest({
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
    final uri = Uri.parse('$baseUrl/service-requests');
    final request = http.MultipartRequest('POST', uri);

    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    request.fields['request_title'] = requestTitle;
    request.fields['request_type'] = requestType;
    request.fields['category'] = category;
    request.fields['quantity'] = quantity.toString();
    request.fields['priority'] = priority;
    request.fields['description'] = description;
    request.fields['needed_by_date'] =
        neededByDate.toIso8601String().split('T').first;

    if (attachmentBytes != null && filename != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'attachment',
        attachmentBytes,
        filename: filename,
      ));
    }

    final streamedResponse = await request.send();
    return streamedResponse.statusCode == 201;
  }

  Future<bool> updateServiceRequest({
    required int id,
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
    final uri = Uri.parse('$baseUrl/service-requests/$id');
    final request = http.MultipartRequest('POST', uri);
    request.fields['_method'] = 'PUT';

    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    request.fields['request_title'] = requestTitle;
    request.fields['request_type'] = requestType;
    request.fields['category'] = category;
    request.fields['quantity'] = quantity.toString();
    request.fields['priority'] = priority;
    request.fields['description'] = description;
    request.fields['needed_by_date'] =
        neededByDate.toIso8601String().split('T').first;

    if (attachmentBytes != null && filename != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'attachment',
        attachmentBytes,
        filename: filename,
      ));
    }

    final streamedResponse = await request.send();
    return streamedResponse.statusCode == 200;
  }

  Future<Map<String, dynamic>> approveServiceRequest(int id, String token) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/service-requests/$id/approve'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return {
        'success': true,
        'data': ServiceRequestModel.fromJson(jsonDecode(response.body)),
      };
    }

    final body = jsonDecode(response.body);
    return {
      'success': false,
      'message': body['message'] ?? 'Failed to approve request',
    };
  }

  Future<Map<String, dynamic>> rejectServiceRequest(
    int id, String token, String reason) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/service-requests/$id/reject'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'rejection_reason': reason}),
    );

    if (response.statusCode == 200) {
      return {
        'success': true,
        'data': ServiceRequestModel.fromJson(jsonDecode(response.body)),
      };
    }

    final body = jsonDecode(response.body);
    return {
      'success': false,
      'message': body['message'] ?? 'Failed to reject request',
    };
  }

  Future<Map<String, dynamic>> addNote(int id, String token, String note) async {
    final response = await http.put(
      Uri.parse('$baseUrl/service-requests/$id/note'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'note': note}),
    );

    if (response.statusCode == 200) {
      return {
        'success': true,
        'data': ServiceRequestModel.fromJson(jsonDecode(response.body)),
      };
    }

    final body = jsonDecode(response.body);
    return {
      'success': false,
      'message': body['message'] ?? 'Failed to add note',
    };
  }

  Future<Map<String, dynamic>> editApproval({
    required int id,
    required String token,
    required String status,
    String? rejectionReason,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/service-requests/$id/edit-approval'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'status': status,
        if (rejectionReason != null) 'rejection_reason': rejectionReason,
      }),
    );

    if (response.statusCode == 200) {
      return {
        'success': true,
        'data': ServiceRequestModel.fromJson(jsonDecode(response.body)),
      };
    }

    final body = jsonDecode(response.body);
    return {
      'success': false,
      'message': body['message'] ?? 'Failed to edit approval',
    };
  }

  Future<Map<String, dynamic>> deleteServiceRequest(int id, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/service-requests/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return {'success': true};
    }

    final body = jsonDecode(response.body);
    return {
      'success': false,
      'message': body['message'] ?? 'Failed to delete request',
    };
  }
}