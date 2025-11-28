class NotificationItem {
  final String id;
  final String title;
  final String body;
  final bool isRead;
  final DateTime? createdAt;
  final DateTime? readAt;
  final String? type;
  final Map<String, dynamic> data;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    this.createdAt,
    this.readAt,
    this.type,
    Map<String, dynamic>? data,
  }) : data = data ?? const {};

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['_id']?.toString() ?? '',
      title: json['title'] ?? 'Notification',
      body: json['body'] ?? '',
      isRead: json['isRead'] ?? false,
      type: json['type']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      readAt: json['readAt'] != null ? DateTime.tryParse(json['readAt']) : null,
      data: json['data'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['data'] as Map)
          : const {},
    );
  }

  NotificationItem copyWith({bool? isRead, DateTime? readAt}) {
    return NotificationItem(
      id: id,
      title: title,
      body: body,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      readAt: readAt ?? this.readAt,
      type: type,
      data: data,
    );
  }
}

class NotificationPagination {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  NotificationPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory NotificationPagination.fromJson(Map<String, dynamic> json) {
    return NotificationPagination(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
      totalPages: json['totalPages'] ?? 1,
    );
  }
}

class NotificationsResult {
  final List<NotificationItem> notifications;
  final NotificationPagination? pagination;

  NotificationsResult({required this.notifications, this.pagination});
}

