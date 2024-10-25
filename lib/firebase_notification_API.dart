import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class FirebaseNotificationApi {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications(String userId) async {
    // ขออนุญาตการแจ้งเตือน
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // ตรวจสอบสถานะการอนุญาต
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // รับ FCM Token
      final String? fCMToken = await _firebaseMessaging.getToken();
      print('FCM Token: $fCMToken');

      // บันทึก FCM Token ลงในฐานข้อมูล
      if (fCMToken != null) {
        await FirebaseFirestore.instance
            .collection('user')
            .doc(userId)
            .update({'fcmToken': fCMToken});
      }
    } else {
      print("Permission declined for FCM notifications.");
    }
  }

  Future<void> sendNotification(String userId, String title, String body) async {
    // ดึง FCM Token ของผู้ใช้
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('user')
        .doc(userId)
        .get();

    if (userDoc.exists) {
      String? fcmToken = userDoc.get('fcmToken');
      if (fcmToken != null) {
        // ส่งการแจ้งเตือน (ใช้ HTTP POST API ของ FCM)
        await sendPushNotification(fcmToken, title, body);
      }
    }
  }
Future<void> sendPushNotification(String fcmToken, String title, String body) async {
  try {
    final String serverKey = '352807101487'; // เปลี่ยนเป็น Firebase server key ของคุณ
    final String fcmEndpoint = 'https://fcm.googleapis.com/fcm/send';

    final Map<String, dynamic> notification = {
      'to': fcmToken,
      'notification': {
        'title': title,
        'body': body,
        'sound': 'default',
      },
      'priority': 'high',
    };

    final http.Response response = await http.post(
      Uri.parse(fcmEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      },
      body: jsonEncode(notification),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification: ${response.body}');
    }
  } catch (e) {
    print("Error sending push notification: $e");
  }
}
}
