// ignore_for_file: avoid_print

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:meyaoo_new/src/Notification/notification_service.dart';
import 'package:meyaoo_new/src/screens/call/web_rtc/incoming_call_screen.dart';

class FirebaseMessagingService {
  void setUpFirebase() {
    FirebaseMessaging.instance.getInitialMessage().then(
      (message) {
        print("FirebaseMessaging.instance.getInitialMessage");
        if (message != null) {
          print("New Notification");
          print("FirebaseMessaging.onMessageOpenedApp.listen");
          print('data--->> ${message.data}');
          print('title-----> ${message.notification!.title}');
          print(message.data['message']);

          if (message.data['call_type'] == 'video_call') {
            print("onMessageOpenedApp 1 video call");
            // launchURL("https://meyaoo.page.link/incoming_video_call");
            // // _currentUuid = _uuid.v4();
            // // // showInCommingCall(_currentUuid!, message);
            Get.to(IncomingCallScrenn(
              roomID: message.data['room_id'],
              callerImage: message.data['sender_profile_image'],
              senderName: message.data['senderName'],
              conversation_id: message.data['conversation_id'],
              message_id: message.data['senderId'],
              caller_id: message.data['message_id'],
            ));
          }
          // else {
          if (message.data['call_type'] == 'video_call') {
            print("onMessageOpenedApp video call screen");
            // launchURL("https://meyaoo.page.link/incoming_video_call");
            // Get.to(VideoCallScreen(
            //   roomID: message.data['room_id'],
            // ));
            Get.to(IncomingCallScrenn(
              roomID: message.data['room_id'],
              callerImage: message.data['sender_profile_image'],
              senderName: message.data['senderName'],
              conversation_id: message.data['conversation_id'],
              message_id: message.data['senderId'],
              caller_id: message.data['message_id'],
            ));
          }
          // }
        }
      },
    );
    FirebaseMessaging.onMessage.listen(
      (message) async {
        print("FirebaseMessaging.onMessage.listen");
        if (message.notification != null) {
          print(message.notification!.title);
          print(message.data['message']);
          print("NOTIFICATION:::: ${message.data}");

          LocalNotificationService.notificationsPlugin.cancelAll();
          LocalNotificationService().createanddisplaynotification(message);

          // FlutterCallkitIncoming.endAllCalls();

          if (message.data['call_type'] == 'video_call') {
            print("FirebaseMessaging.onMessage video call");
            // launchURL("https://meyaoo.page.link/incoming_video_call");
            // Get.to(VideoCallScreen(
            //   roomID: message.data['room_id'],
            // ));
            Get.to(IncomingCallScrenn(
              roomID: message.data['room_id'],
              callerImage: message.data['sender_profile_image'],
              senderName: message.data['senderName'],
              conversation_id: message.data['conversation_id'],
              message_id: message.data['senderId'],
              caller_id: message.data['message_id'],
            ));
          }
        }
      },
    );

    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) async {
        print("FirebaseMessaging.onMessageOpenedApp.listen");
        if (message.notification != null) {
          print('title-----> ${message.notification!.title}');
          print(message.data['message']);
          print('data--->> ${message.data}');

          // FlutterCallkitIncoming.endAllCalls();

          if (message.data['call_type'] == 'video_call') {
            print("FirebaseMessaging.onMessageOpenedApp 1 video call");
            // launchURL("https://meyaoo.page.link/incoming_video_call");
            // Get.to(VideoCallScreen(
            //   roomID: message.data['room_id'],
            // ));
            Get.to(IncomingCallScrenn(
              roomID: message.data['room_id'],
              callerImage: message.data['sender_profile_image'],
              senderName: message.data['senderName'],
              conversation_id: message.data['conversation_id'],
              message_id: message.data['senderId'],
              caller_id: message.data['message_id'],
            ));
          }
        }
      },
    );

    // FirebaseMessaging.onBackgroundMessage((message) async {
    //   print("FirebaseMessaging.onBackgroundMessage.listen");

    //   if (message.notification != null) {
    //     print('title-----> ${message.notification!.title}');
    //     print(message.data['message']);
    //     print('data--->> ${message.data}');
    //     print("message.data ${message.data}");
    //     print("NOTIFICATION:::: ${message.data}");

    //     LocalNotificationService.notificationsPlugin.cancelAll();
    //     LocalNotificationService.createanddisplaynotification(message);
    //     if (message.data['call_type'] == 'video_call') {
    //       print("FirebaseMessaging.onBackgroundMessage 1 video call");
    //       // launchURL("https://meyaoo.page.link/incoming_video_call");
    //       // Get.to(VideoCallScreen(
    //       //   roomID: message.data['room_id'],
    //       // ));
    //       Get.to(IncomingCallScrenn(
    //         roomID: message.data['room_id'],
    //         callerImage: message.data['sender_profile_image'],
    //         senderName: message.data['senderName'],
    //       ));
    //     }
    //     // else {
    //     if (message.data['call_type'] == 'video_call') {
    //       print("FirebaseMessaging.onBackgroundMessage 2 video call");
    //       // launchURL("https://meyaoo.page.link/incoming_video_call");
    //       // Get.to(VideoCallScreen(
    //       //   roomID: message.data['room_id'],
    //       // ));
    //       Get.to(IncomingCallScrenn(
    //         roomID: message.data['room_id'],
    //         callerImage: message.data['sender_profile_image'],
    //         senderName: message.data['senderName'],
    //       ));
    //     }
    //     // }
    //   }
    // });
  }
}
