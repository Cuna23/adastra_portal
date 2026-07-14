class ServiceRequestModel {
  final int id;
  final String srNumber;
  final String requestTitle;
  final String requestType;
  final String category;
  final int quantity;
  final String priority;
  final String description;
  final DateTime neededByDate;
  final String? attachment;
  final String? attachmentName;
  final String status;
  final int requesterId;
  final String? requesterName;
  final String? requesterEmail;
  final String? requesterEmpId;
  final String? requesterDepartment;
  final int? approverId;
  final String? approverName;
  final DateTime? reviewedAt;
  final String? rejectionReason;
  final DateTime createdAt;
  final List<ServiceRequestLogModel> logs;

  ServiceRequestModel({
    required this.id,
    required this.srNumber,
    required this.requestTitle,
    required this.requestType,
    required this.category,
    required this.quantity,
    required this.priority,
    required this.description,
    required this.neededByDate,
    this.attachment,
    this.attachmentName,
    required this.status,
    required this.requesterId,
    this.requesterName,
    this.requesterEmail,
    this.requesterEmpId,
    this.requesterDepartment,
    this.approverId,
    this.approverName,
    this.reviewedAt,
    this.rejectionReason,
    required this.createdAt,
    this.logs = const [],
  });

  factory ServiceRequestModel.fromJson(Map<String, dynamic> json) {
    return ServiceRequestModel(
      id: json['id'],
      srNumber: json['sr_number'],
      requestTitle: json['request_title'],
      requestType: json['request_type'],
      category: json['category'],
      quantity: json['quantity'],
      priority: json['priority'],
      description: json['description'],
      neededByDate: DateTime.parse(json['needed_by_date']),
      attachment: json['attachment'],
      attachmentName: json['attachment_name'],
      status: json['status'],
      requesterId: json['requester_id'],
      requesterName: json['requester']?['name'],
      requesterEmail: json['requester']?['email'],
      requesterEmpId: json['requester']?['emp_id'],
      requesterDepartment: json['requester']?['department']?['department_name'],
      approverId: json['approver_id'],
      approverName: json['approver']?['name'],
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'])
          : null,
      rejectionReason: json['rejection_reason'],
      createdAt: DateTime.parse(json['created_at']),
      logs: json['logs'] != null
            ? (json['logs'] as List)
                .map((e) => ServiceRequestLogModel.fromJson(e))
                .toList()
            : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'request_title': requestTitle,
      'request_type': requestType,
      'category': category,
      'quantity': quantity,
      'priority': priority,
      'description': description,
      'needed_by_date': neededByDate.toIso8601String().split('T').first,
    };
  }
}

class ServiceRequestLogModel {
  final int id;
  final String action;
  final String description;
  final int userId;
  final String? userName;
  final DateTime createdAt;

  ServiceRequestLogModel({
    required this.id,
    required this.action,
    required this.description,
    required this.userId,
    this.userName,
    required this.createdAt,
  });

  factory ServiceRequestLogModel.fromJson(Map<String, dynamic> json) {
    return ServiceRequestLogModel(
      id: json['id'],
      action: json['action'],
      description: json['description'],
      userId: json['user_id'],
      userName: json['user']?['name'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}