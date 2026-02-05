/// Represents a notification in the app
class AppNotification {
  final int? id;
  final String title;
  final String body;
  final int? machineId; // null for test notifications
  final DateTime createdAt;
  final bool isRead;

  AppNotification({
    this.id,
    required this.title,
    required this.body,
    this.machineId,
    required this.createdAt,
    this.isRead = false,
  });

  /// Convert AppNotification to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'machineId': machineId,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead ? 1 : 0,
    };
  }

  /// Create AppNotification from Map (database record)
  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'] as int?,
      title: map['title'] as String,
      body: map['body'] as String,
      machineId: map['machineId'] as int?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      isRead: (map['isRead'] as int) == 1,
    );
  }

  /// Create a copy with updated fields
  AppNotification copyWith({
    int? id,
    String? title,
    String? body,
    int? machineId,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      machineId: machineId ?? this.machineId,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
