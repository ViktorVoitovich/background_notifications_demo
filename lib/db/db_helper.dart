import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/notification_model.dart';

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  static SharedPreferences? _prefs;
  static const String _notificationsKey = 'notifications';

  factory DbHelper() => _instance;

  DbHelper._internal();

  Future<SharedPreferences> get prefs async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<int> insertNotification(NotificationModel notification) async {
    final db = await prefs;
    List<NotificationModel> notifications = await getNotifications();

    notifications.add(notification);

    // Save the updated list
    await db.setString(
      _notificationsKey,
      jsonEncode(notifications.map((e) => e.toJson()).toList()),
    );

    return notification.id;
  }

  Future<List<NotificationModel>> getNotifications() async {
    final db = await prefs;

    await db.reload();

    final String? notificationsJson = db.getString(_notificationsKey);

    if (notificationsJson == null) return [];

    List<dynamic> decoded = jsonDecode(notificationsJson);
    return decoded.map((item) => NotificationModel.fromJson(item)).toList();
  }

  Future<bool> deleteNotification(int id) async {
    final db = await prefs;
    List<NotificationModel> notifications = await getNotifications();

    notifications.removeWhere((notification) => notification.id == id);

    return await db.setString(
      _notificationsKey,
      jsonEncode(notifications.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> deleteAllNotifications() async {
    final db = await prefs;
    await db.remove(_notificationsKey);
  }
}
