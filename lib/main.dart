import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:user/login.dart';




FirebaseMessaging messaging = FirebaseMessaging.instance;


main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (Platform.isAndroid) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDlYdtMLbjARDAdAnMkFwLig-CWHqtFtR0",
        appId: "1:352807101487:android:35c44c943b2b6f3d10d2da",
        messagingSenderId: "352807101487",
        storageBucket: "dbgtb-9c4f8.appspot.com",
        projectId: "dbgtb-9c4f8",
      ),
    );
  } else {
    await Firebase.initializeApp();
  } 
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    String? token = await messaging.getToken();
  print("FCM Token: $token");

  // Listen for foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Message received: ${message.notification?.title}, ${message.notification?.body}');
    // Show notification using a local notification package or update the UI
  });

  // Listen for when the app is opened from a background state
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('Message clicked!');
    // Navigate to a specific screen or handle the message
  });


  runApp(const MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // This method is called when the app is in the background or terminated
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const Login());
  }
}
