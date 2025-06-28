class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String reportId;
  final String reportName;
  final String oldStatus;
  final String newStatus;
  final DateTime createdAt;
  final bool isRead;
  final String userId;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.reportId,
    required this.reportName,
    required this.oldStatus,
    required this.newStatus,
    required this.createdAt,
    this.isRead = false,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'reportId': reportId,
      'reportName': reportName,
      'oldStatus': oldStatus,
      'newStatus': newStatus,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'userId': userId,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      reportId: json['reportId'] ?? '',
      reportName: json['reportName'] ?? '',
      oldStatus: json['oldStatus'] ?? '',
      newStatus: json['newStatus'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      isRead: json['isRead'] ?? false,
      userId: json['userId'] ?? '',
    );
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? reportId,
    String? reportName,
    String? oldStatus,
    String? newStatus,
    DateTime? createdAt,
    bool? isRead,
    String? userId,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      reportId: reportId ?? this.reportId,
      reportName: reportName ?? this.reportName,
      oldStatus: oldStatus ?? this.oldStatus,
      newStatus: newStatus ?? this.newStatus,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      userId: userId ?? this.userId,
    );
  }
}