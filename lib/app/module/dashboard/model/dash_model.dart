class NeedsAttentionItem {
  final String type;
  final int id;
  final String title;
  final String subtitle;
  final String priority;
  final String? assignee;
  final String dueLabel;
  final bool overdue;

  NeedsAttentionItem({
    required this.type,
    required this.id,
    required this.title,
    required this.subtitle,
    required this.priority,
    this.assignee,
    required this.dueLabel,
    required this.overdue,
  });

  factory NeedsAttentionItem.fromJson(Map<String, dynamic> json) => NeedsAttentionItem(
        type: json['type'],
        id: json['id'],
        title: json['title'] ?? '',
        subtitle: json['subtitle'] ?? '',
        priority: json['priority'] ?? 'low',
        assignee: json['assignee'],
        dueLabel: json['due_label'] ?? '',
        overdue: json['overdue'] ?? false,
      );
}

class RecentTicketItem {
  final String type;
  final int id;
  final String title;
  final String status;

  RecentTicketItem({required this.type, required this.id, required this.title, required this.status});

  factory RecentTicketItem.fromJson(Map<String, dynamic> json) => RecentTicketItem(
        type: json['type'],
        id: json['id'],
        title: json['title'] ?? '',
        status: json['status'] ?? '',
      );
}

class AdminDashboardStats {
  final int openIncidents;
  final int pendingRequests;
  final int totalAssets;
  final int activeStaff;
  final Map<String, int> incidentsByStatus;
  final List<NeedsAttentionItem> needsAttention;
  final int needsAttentionTotal;

  AdminDashboardStats({
    required this.openIncidents,
    required this.pendingRequests,
    required this.totalAssets,
    required this.activeStaff,
    required this.incidentsByStatus,
    required this.needsAttention,
    required this.needsAttentionTotal,
  });

  factory AdminDashboardStats.fromJson(Map<String, dynamic> json) {
    final metrics = json['metrics'] as Map<String, dynamic>;
    final byStatus = <String, int>{
      for (final row in (json['incidents_by_status'] as List)) row['label']: row['count'] ?? 0,
    };
    return AdminDashboardStats(
      openIncidents: metrics['open_incidents'] ?? 0,
      pendingRequests: metrics['pending_requests'] ?? 0,
      totalAssets: metrics['total_assets'] ?? 0,
      activeStaff: metrics['active_staff'] ?? 0,
      incidentsByStatus: byStatus,
      needsAttention: (json['needs_attention'] as List).map((e) => NeedsAttentionItem.fromJson(e)).toList(),
      needsAttentionTotal: json['needs_attention_total'] ?? 0,
    );
  }
}

class StaffDashboardStats {
  final int myOpenIncidents;
  final int myPendingRequests;
  final int myAssets;
  final List<RecentTicketItem> recentTickets;

  StaffDashboardStats({
    required this.myOpenIncidents,
    required this.myPendingRequests,
    required this.myAssets,
    required this.recentTickets,
  });

  factory StaffDashboardStats.fromJson(Map<String, dynamic> json) {
    final metrics = json['metrics'] as Map<String, dynamic>;
    return StaffDashboardStats(
      myOpenIncidents: metrics['my_open_incidents'] ?? 0,
      myPendingRequests: metrics['my_pending_requests'] ?? 0,
      myAssets: metrics['my_assets'] ?? 0,
      recentTickets: (json['recent_tickets'] as List).map((e) => RecentTicketItem.fromJson(e)).toList(),
    );
  }
}