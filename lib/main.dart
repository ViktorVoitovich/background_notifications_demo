import 'package:background_notifications_demo_app/db/db_helper.dart';
import 'package:background_notifications_demo_app/firebase_options.dart';
import 'package:background_notifications_demo_app/models/notification_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.notification != null) {
    print('Message title: ${message.notification?.title}');
    print('Message body: ${message.notification?.body}');
    print('Message timestamp: ${message.sentTime?.millisecondsSinceEpoch}');

    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch,
      title: 'background: ' + (message.notification?.title ?? ''),
      body: message.notification?.body,
      timestamp: message.sentTime?.millisecondsSinceEpoch,
    );

    DbHelper().insertNotification(notification);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final notificationSettings = await FirebaseMessaging.instance.requestPermission();

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      print('Message title: ${message.notification?.title}');
      print('Message body: ${message.notification?.body}');
      print('Message timestamp: ${message.sentTime?.millisecondsSinceEpoch}');

      final notification = NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch,
        title: message.notification?.title,
        body: message.notification?.body,
        timestamp: message.sentTime?.millisecondsSinceEpoch,
      );

      DbHelper().insertNotification(notification);
    }
  });

  runApp(const WidgetApp());
}

class WidgetApp extends StatelessWidget {
  const WidgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.purple.shade100,
          foregroundColor: Colors.purple.shade900,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Notifications Demo'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FutureBuilder<String?>(
                future: FirebaseMessaging.instance.getToken(),
                builder: (context, snapshot) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(snapshot.data ?? 'No token'),
                      const SizedBox(height: 10.0),
                      ElevatedButton(
                        onPressed: () {
                          if (snapshot.hasData) {
                            Clipboard.setData(ClipboardData(text: snapshot.data ?? ''));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Token copied to clipboard')),
                            );
                          }
                        },
                        child: const Text('Copy Token'),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 30.0),
              const NotificationsView(),
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  final DbHelper _dbHelper = DbHelper();
  final List<NotificationModel> notifications = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshNotifications();
    });
  }

  Future<void> _refreshNotifications() async {
    final data = await _dbHelper.getNotifications();

    setState(() {
      notifications.clear();
      notifications.addAll(data);
    });
  }

  Future<void> _deleteAllNotifications() async {
    await _dbHelper.deleteAllNotifications();
    _refreshNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            ElevatedButton(
              onPressed: _refreshNotifications,
              child: const Text('Refresh'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _deleteAllNotifications,
              child: const Text('Delete all notifications'),
            ),
          ],
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final timestamp = notifications[index].timestamp;

            return ListTile(
              title: Text(notifications[index].title ?? ''),
              subtitle: Text(notifications[index].body ?? ''),
              trailing: timestamp != null
                  ? Text(DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.fromMillisecondsSinceEpoch(timestamp)))
                  : null,
            );
          },
        ),
      ],
    );
  }
}
