class CalendarEvent {
  final int id;
  final String type; // 'deadline' | 'reminder'
  final String title;
  final String? subtitle;
  final DateTime date;
  final bool overdue;

  CalendarEvent({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    required this.date,
    required this.overdue,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) => CalendarEvent(
        id: json['id'],
        type: json['type'],
        title: json['title'] ?? '',
        subtitle: json['subtitle'],
        date: DateTime.parse(json['date']),
        overdue: json['overdue'] ?? false,
      );
}