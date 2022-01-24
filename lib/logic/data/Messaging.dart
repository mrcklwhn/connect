import 'dart:convert';

import 'package:http/http.dart';
import 'package:meta/meta.dart';

class Messaging {
  static final Client client = Client();

  // from 'https://console.firebase.google.com'
  // --> project settings --> cloud messaging --> "Server key"
  static const String serverKey =
      'AAAAD6DnnII:APA91bEOHX311oWvjP-tD69ZgK9uaR3HK7uLXCwpT9sDmOMGUOoM7KXMa_C1aEMW5Vhx0Lrkbx8zqCBdnI8A3OQad3ERfMnITFBJybWuS73tR3__R-BF0xXwnE3ntoBedXCLJL3omMbJ';

  static Future<Response> sendToAll({
    @required String title,
    @required String body,
  }) =>
      sendToTopic(title: title, body: body, topic: 'all');

  static Future<Response> sendToTopic(
      {@required String title,
        @required String body,
        String senderId,
        String type,
        @required String topic}) =>
      sendTo(title: title, body: body, fcmToken: '/topics/$topic',senderId: senderId, type: type);

  static Future<Response> sendTo({
    @required String title,
    @required String body,
    String senderId,

    @required String fcmToken, String type,
  }) =>
      client.post(Uri.parse(
        'https://fcm.googleapis.com/fcm/send'),
        body: json.encode({
          'notification': {'body': '$body', 'title': '$title'},
          'priority': 'high',
          'data': {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'senderId': '$senderId',
            'type': '$type',
          },
          'to': '$fcmToken',
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },


      );
}