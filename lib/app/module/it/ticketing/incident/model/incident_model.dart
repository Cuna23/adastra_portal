class IncidentModel {
  final int id;
  final String ticketNo;
  final int userId;
  final String subject;
  final String description;
  final String category;
  final String priority;
  final String status;
  final String? attachment;
  final int? assignedTo;
  final String? resolution;
  final String? resolvedAt;
  final String? closedAt;
  final String createdAt;
  final String updatedAt;
  final UserMini? user;
  final UserMini? assignedUser;
  final List<IncidentLog> logs;

  IncidentModel({
    required this.id,
    required this.ticketNo,
    required this.userId,
    required this.subject,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    this.attachment,
    this.assignedTo,
    this.resolution,
    this.resolvedAt,
    this.closedAt,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.assignedUser,
    this.logs = const [],
  });

  factory IncidentModel.fromJson(Map<String, dynamic> j) => IncidentModel(
        id: j['id'],
        ticketNo: j['ticket_no'] ?? '',
        userId: j['user_id'],
        subject: j['subject'],
        description: j['description'],
        category: j['category'],
        priority: j['priority'],
        status: j['status'],
        attachment: j['attachment'],
        assignedTo: j['assigned_to'],
        resolution: j['resolution'],
        resolvedAt: j['resolved_at'],
        closedAt: j['closed_at'],
        createdAt: j['created_at'],
        updatedAt: j['updated_at'],
        user: j['user'] != null ? UserMini.fromJson(j['user']) : null,
        assignedUser: j['assigned_user'] != null
            ? UserMini.fromJson(j['assigned_user'])
            : null,
        logs: j['logs'] != null
            ? (j['logs'] as List).map((l) => IncidentLog.fromJson(l)).toList()
            : [],
      );
}

class UserMini {
  final int id;
  final String name;
  final String? role;

  UserMini({required this.id, required this.name, this.role});

  factory UserMini.fromJson(Map<String, dynamic> j) =>
      UserMini(id: j['id'], name: j['name'], role: j['role']);
}

class IncidentLog {
  final int id;
  final int incidentId;
  final int userId;
  final String action;
  final String description;
  final String createdAt;
  final UserMini? user;

  IncidentLog({
    required this.id,
    required this.incidentId,
    required this.userId,
    required this.action,
    required this.description,
    required this.createdAt,
    this.user,
  });

  factory IncidentLog.fromJson(Map<String, dynamic> j) => IncidentLog(
        id: j['id'],
        incidentId: j['incident_id'],
        userId: j['user_id'],
        action: j['action'],
        description: j['description'],
        createdAt: j['created_at'],
        user: j['user'] != null ? UserMini.fromJson(j['user']) : null,
      );
}

class IncidentDailyCount {
  final String label;
  final String date;
  final int count;

  IncidentDailyCount({required this.label, required this.date, required this.count});

  factory IncidentDailyCount.fromJson(Map<String, dynamic> j) => IncidentDailyCount(
        label: j['label'],
        date: j['date'],
        count: j['count'],
      );
}