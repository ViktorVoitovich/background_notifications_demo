import 'package:background_notifications_demo_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final notificationSettings = await FirebaseMessaging.instance.requestPermission();

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
            ],
          ),
        ),
      ),
    );
  }
}
