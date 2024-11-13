  // ignore_for_file: avoid_print
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:push_app/domain/entities/push_message.dart';
import 'package:push_app/firebase_options.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  int pushNumberId = 0;

  final Future<void> Function()? requestPermissionsLocalNotifications;
  
  final void Function({
    required int id,
    String? title,
    String? body,
    String? data,
  })? showLocalNotification;

  NotificationsBloc({
    this.requestPermissionsLocalNotifications,
    this.showLocalNotification
  }) : super(const NotificationsState()) {
    on<NotificationStatusChanged>((event, emit) {
      emit(
        state.copyWith(
          status: event.status
        )
      );

      _getFCMToken();
    });

    on<NotificationReceived>(_onPushMessageReceived);

    // Verify notifications status
    _initializeStatusCheck();

    // Foreground notifications listener
    _onForegroundMessage();
  }

  // Initialize Firebase Cloud Messaging
  static Future<void> initializeFCM() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  void _getFCMToken() async {
    if(state.status != AuthorizationStatus.authorized) return;

    final token = await messaging.getToken();
    print(token);
  }

  void requestPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    // Request permissions to local notifications
    if(requestPermissionsLocalNotifications != null) {
      await requestPermissionsLocalNotifications!();
    }

    add(NotificationStatusChanged(settings.authorizationStatus));
  }

  void _initializeStatusCheck() async {
    final settings = await messaging.getNotificationSettings();
    add(NotificationStatusChanged(settings.authorizationStatus));
  }

  void _onForegroundMessage() {
    FirebaseMessaging.onMessage.listen(handleRemoteMessage);
  }

  void handleRemoteMessage(RemoteMessage message) {
    if (message.notification == null) return;

    final PushMessage notification = PushMessage(
      messageId: message.messageId?.replaceAll(':', '').replaceAll('%', '') ?? '', 
      title: message.notification!.title ?? '', 
      body: message.notification!.body ?? '', 
      sentDate: message.sentTime ?? DateTime.now(),
      data: message.data,
      imageUrl: Platform.isAndroid
        ? message.notification!.android?.imageUrl
        : message.notification!.apple?.imageUrl
    );

    print(notification);

    if(showLocalNotification != null) {
      showLocalNotification!(
        id: ++pushNumberId,
        title: notification.title,
        body: notification.body,
        data: notification.messageId
        // data: notification.data.toString()
      );
    }
    
    add(NotificationReceived(notification));
  }

  // Event handlers
  void _onPushMessageReceived(NotificationReceived event, Emitter<NotificationsState> emit) {
    emit(
      state.copyWith(
        notifications: [event.notification, ...state.notifications ]
      )
    );
  }

  PushMessage? getMessageById(String pushMessageId) {
    final exists = state.notifications.any((element) => element.messageId == pushMessageId);
    if(!exists) return null;

    return state.notifications.firstWhere((element) => element.messageId == pushMessageId);
  }
}
