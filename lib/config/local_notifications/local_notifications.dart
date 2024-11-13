import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:push_app/config/router/app_router.dart';

class LocalNotifications {

  static Future<void> requestPermissionsLocalNotifications() async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    
    await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> initializeLocalNotifications() async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const initializationSettingsAndroid = AndroidInitializationSettings('app_icon');

    // Todo: initializationSettingsIOS

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      // Todo: initializationSettingsIOS
    );

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse
    );
  }

  static void showLocalNotification({
    required int id,
    String? title,
    String? body,
    String? data
  }) {

    const androidDetails = AndroidNotificationDetails(
      'channelId', 
      'channelName',
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification'),
      importance: Importance.max,
      priority: Priority.high
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      // Todo: iosDetails
    );

    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    flutterLocalNotificationsPlugin.show(id, title, body, notificationDetails, payload: data);
  }

  static void onDidReceiveNotificationResponse(NotificationResponse response) {
    appRouter.push('/push-details/${response.payload}');
  }
}