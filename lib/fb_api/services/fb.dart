import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_wubbachat/firebase_options.dart';

class Fb {
  Future<void> init({
    required void Function(RemoteMessage message) onForegroundMessage,
    required Future<void> Function(RemoteMessage message) onBackgroundMessage,
  }) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    /// TODO(nesquikm): puth this thing into config
    FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);

    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(
        // alert: true,
        // announcement: false,
        // badge: true,
        // carPlay: false,
        // criticalAlert: false,
        // provisional: false,
        // sound: true,
        );

    print('User granted permission: ${settings.authorizationStatus}');

    FirebaseMessaging.onMessage.listen(onForegroundMessage);

    FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleNotificationClick(
        onForegroundMessage: onForegroundMessage,
        remoteMessage: initialMessage,
      );
    }

    FirebaseMessaging.onMessageOpenedApp.listen(
      (remoteMessage) => _handleNotificationClick(
        onForegroundMessage: onForegroundMessage,
        remoteMessage: remoteMessage,
      ),
    );
  }

  void _handleNotificationClick({
    required void Function(RemoteMessage message) onForegroundMessage,
    required RemoteMessage remoteMessage,
  }) {
    onForegroundMessage(remoteMessage);
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

    print({...fields, 'topic': topic});
    return callable.call<Map<String, dynamic>>({...fields, 'topic': topic});
  }
}
