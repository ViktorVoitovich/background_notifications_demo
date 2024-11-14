class NotificationModel {
  final int id;
  final String? title;
  final String? body;
  final int? timestamp;

  NotificationModel({
    required this.id,
    this.title,
    this.body,
    this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'timestamp': timestamp,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      title: json['title'] as String?,
      body: json['body'] as String?,
      timestamp: json['timestamp'] as int?,
    );
  }
}
