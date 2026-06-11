class IncidentModel {
  final int id;
  final String ticketNo;
  final String subject;
  final String category;
  final String priority;
  final String status;
  final String? attachment;
  final DateTime createdAt;

  IncidentModel({
    required this.id,
    required this.ticketNo,
    required this.subject,
    required this.category,
    required this.priority,
    required this.status,
    this.attachment,
    required this.createdAt,
  });

  factory IncidentModel.fromJson(Map<String, dynamic> json) {
    return IncidentModel(
      id: json['id'],
      ticketNo: json['ticket_no'] ?? '',
      subject: json['subject'] ?? '',
      category: json['category'] ?? '',
      priority: json['priority'] ?? '',
      status: json['status'] ?? '',
      attachment: json['attachment'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}