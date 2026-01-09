abstract class NotificationService {
  Future<void> initialize();
  Future<String?> getToken();
  Future<void> requestPermission();
  Stream<Map<String, dynamic>> get onMessageReceived;
  Future<void> handleBackgroundMessage(Map<String, dynamic> message);
}