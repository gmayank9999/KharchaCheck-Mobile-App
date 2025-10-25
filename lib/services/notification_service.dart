import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/app_constants.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Initialize notifications
  static Future<void> initialize() async {
    // Request permissions
    await _requestPermissions();

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Configure Firebase messaging
    await _configureFirebaseMessaging();
  }

  // Request notification permissions
  static Future<void> _requestPermissions() async {
    final status = await Permission.notification.request();
    if (status != PermissionStatus.granted) {
      throw Exception('Notification permission denied');
    }
  }

  // Initialize local notifications
  static Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  // Configure Firebase messaging
  static Future<void> _configureFirebaseMessaging() async {
    // Request permission for iOS
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get FCM token
    final token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  // Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    print('Notification tapped: ${response.payload}');
  }

  // Handle foreground messages
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Received foreground message: ${message.notification?.title}');

    // Show local notification for foreground messages
    await showLocalNotification(
      title: message.notification?.title ?? 'Budget Alert',
      body: message.notification?.body ?? 'You have a budget notification',
    );
  }

  // Show local notification
  static Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      AppConstants.budgetAlertChannelId,
      AppConstants.budgetAlertChannelName,
      channelDescription: AppConstants.budgetAlertChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  // Show budget threshold alert
  static Future<void> showBudgetThresholdAlert({
    required double currentSpending,
    required double budget,
    required double threshold,
  }) async {
    final percentage = (currentSpending / budget * 100).toStringAsFixed(1);
    final remaining = budget - currentSpending;

    await showLocalNotification(
      title: '🚨 Budget Alert',
      body:
          'You\'ve spent $percentage% of your budget (₹${currentSpending.toStringAsFixed(0)}/₹${budget.toStringAsFixed(0)}). ₹${remaining.toStringAsFixed(0)} remaining.',
      payload: 'budget_alert',
    );
  }

  // Show budget exceeded alert
  static Future<void> showBudgetExceededAlert({
    required double currentSpending,
    required double budget,
  }) async {
    final overAmount = currentSpending - budget;

    await showLocalNotification(
      title: '⚠️ Budget Exceeded',
      body:
          'You\'ve exceeded your budget by ₹${overAmount.toStringAsFixed(0)}. Total spent: ₹${currentSpending.toStringAsFixed(0)}',
      payload: 'budget_exceeded',
    );
  }

  // Schedule recurring budget check
  static Future<void> scheduleBudgetCheck() async {
    // This would typically be handled by a backend service
    // For now, we'll just show a notification
    await showLocalNotification(
      title: '📊 Budget Check',
      body: 'Time to review your monthly spending!',
      payload: 'budget_check',
    );
  }

  // Get FCM token
  static Future<String?> getFCMToken() async {
    return await _firebaseMessaging.getToken();
  }

  // Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  // Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }
}

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
}
