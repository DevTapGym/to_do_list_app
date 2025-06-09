import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// ignore: depend_on_referenced_packages
import 'package:timezone/data/latest.dart' as tz;
// ignore: depend_on_referenced_packages
import 'package:timezone/timezone.dart' as tz;
import 'package:to_do_list_app/models/task.dart';

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();
  factory NotificationService() => _notificationService;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Khởi tạo plugin thông báo và múi giờ
  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('Thông báo được nhấn: ${response.payload}');
      },
    );
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'task_channel',
      'Thông báo công việc',
      description: 'Thông báo nhắc nhở công việc',
      importance: Importance.high,
    );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  /// Yêu cầu quyền thông báo cho Android 13+
  Future<void> requestPermissions() async {
    final androidPlugin =
        flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();
  }

  Future<void> showNotification(String title, String body, {int id = 0}) async {
    final androidPlugin =
        flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    bool? hasNotificationPermission =
        await androidPlugin?.areNotificationsEnabled();
    if (!(hasNotificationPermission ?? false)) {
      await androidPlugin?.requestNotificationsPermission();
      hasNotificationPermission =
          await androidPlugin?.areNotificationsEnabled();
      if (!(hasNotificationPermission ?? false)) {
        return;
      }
    }

    // Hiển thị thông báo với id tùy chỉnh
    await flutterLocalNotificationsPlugin.show(
      id, // Sử dụng id được truyền vào
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_channel',
          'Thông báo công việc',
          channelDescription: 'Thông báo nhắc nhở công việc',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: 'immediate_notification',
    );
  }

  /// Kiểm tra xem thông báo đã được lên lịch cho task chưa
  Future<bool> isNotificationScheduled(int id) async {
    final pendingNotifications =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    return pendingNotifications.any((notification) => notification.id == id);
  }

  /// Hủy thông báo của một task
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  /// Hủy tất cả thông báo của một task
  Future<void> cancelTaskNotifications(Task task) async {
    if (task.id == null) return;
    await cancelNotification(task.id!);
  }

  /// Hủy tất cả thông báo
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
