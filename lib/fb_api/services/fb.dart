import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_wubbachat/firebase_options.dart';

class Fb {
  Future<void> init({
    required void Function(RemoteMessage message) onForegroundMessage,
    required Future<void> Function(RemoteMessage message) onBackgroundMessage,
    required void Function(RemoteMessage message) onNotificationClick,
  }) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // TODO(nesquikm): put this thing into config
    // FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);

    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission();

    FirebaseMessaging.onMessage.listen(onForegroundMessage);

    FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleNotificationClick(
        onForegroundMessage: onForegroundMessage,
        remoteMessage: initialMessage,
        onNotificationClick: onNotificationClick,
      );
    }

    FirebaseMessaging.onMessageOpenedApp.listen(
      (remoteMessage) => _handleNotificationClick(
        onForegroundMessage: onForegroundMessage,
        remoteMessage: remoteMessage,
        onNotificationClick: onNotificationClick,
      ),
    );
  }

  void _handleNotificationClick({
    required void Function(RemoteMessage message) onForegroundMessage,
    required RemoteMessage remoteMessage,
    required Function(RemoteMessage message) onNotificationClick,
  }) {
    onForegroundMessage(remoteMessage);
    onNotificationClick(remoteMessage);
  }

  Future<String?> getToken({
    String? vapidKey,
  }) {
    return FirebaseMessaging.instance.getToken(vapidKey: vapidKey);
  }

  Future<void> subscribeToTopic(String topic) {
    return FirebaseMessaging.instance.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) {
    return FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  }

  Future<HttpsCallableResult<T>> call<T>(
    String name, [
    dynamic parameters,
  ]) async {
    final callable = FirebaseFunctions.instance.httpsCallable(name);
    return callable.call<T>(parameters);
  }

  Future<HttpsCallableResult<Map<String, dynamic>>> sendMessageToTopic(
    String topic,
    Map<String, String> fields,
  ) async {
    final callable = FirebaseFunctions.instance.httpsCallable(
      'sendMessageToTopic',
    );

    return callable.call<Map<String, dynamic>>({...fields, 'topic': topic});
  }
}
