
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:OptiWallet/main.dart';
import 'package:shared_preferences/shared_preferences.dart';


Future<void> handleBackgroundNotification(RemoteMessage message) async {
  debugPrint('Notification Title: ${message.notification?.title}');
  debugPrint('Notification Body: ${message.notification?.body}');
  debugPrint('Notification Payload: ${message.data}');
}

class FirebaseMessagingHandler {
  final _firebaseMessaging = FirebaseMessaging.instance;

  final _androidChannel = const AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notification',
      importance: Importance.defaultImportance
  );
  final _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async{
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    debugPrint('Devicce Token: $fCMToken');
    // Obtain shared preferences.
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('token', fCMToken!);
    initPushNotification();
    // initLocalNotification();
  }

  // Future initLocalNotification() async{
  //   const ios = IOSInitializationSettings();
  //   const android = AndroidInitializationSettings('@drawable/ic_launcher');
  //   const settings = InitializationSettings(android: android, iOS: ios);
  //
  //   await _localNotifications.initialize(
  //     settings,
  //     onSelectNotification: (payload) {
  //       final message = RemoteMessage.fromMap(jsonDecode(payload!));
  //       handleMessage(message);
  //     }
  //   );
  //
  //   final platform = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  //   await platform?.createNotificationChannel(_androidChannel);
  // }

  void handleMessage(RemoteMessage? message) {
    if(message==null) return;

    //TODO: Set the push name
    navigator.currentState?.pushNamed('/route', arguments: message);

    //  To get arguments
    //   final message = ModalRoute.of(context)!.settings.arguments;
  }

  Future initPushNotification() async {
    //Useful for IOS
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true, badge: true, sound: true
    );

    _firebaseMessaging.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundNotification);
    FirebaseMessaging.onMessage.listen((event) {
      final notification = event.notification;
      if (notification==null) return;

      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
            android: AndroidNotificationDetails(
              _androidChannel.id,
              _androidChannel.name,
              channelDescription: _androidChannel.description,
              icon: '@drawable/ic_launcher',
            )
        ),
        payload: jsonEncode(event.toMap()),
      );
    });
  }
}