// ignore_for_file: avoid_print

import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:get/get.dart';
import 'package:meyaoo_new/controller/call_controller.dart/get_roomId_controller.dart';
import 'package:meyaoo_new/src/screens/call/web_rtc/audio_call_screen.dart';
import 'package:meyaoo_new/src/screens/call/web_rtc/incoming_call_screen.dart';
import 'package:meyaoo_new/src/screens/call/web_rtc/video_call_screen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class OnesignalService {
  final RoomIdController roomIdController = Get.put(RoomIdController());

  initialize() {
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize("fa0d2111-1ab5-49d7-ad5d-976b8d9d66a4");
    OneSignal.Notifications.requestPermission(true);
  }

  onNotifiacation() {
    OneSignal.Notifications.removeClickListener((event) {
      FlutterRingtonePlayer().playRingtone();
    });

    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      print("event body ${event.notification.additionalData}");
      if (event.notification.additionalData!['call_type'].toString() ==
          'video_call') {
        print("video call");
        if (event.notification.additionalData!['missed_call'].toString() ==
            'true') {
          OneSignal.Notifications.clearAll();
          FlutterRingtonePlayer().stop();
          Get.back();
        } else {
          Get.to(IncomingCallScrenn(
            roomID: event.notification.additionalData!['room_id'].toString(),
            callerImage: event
                .notification.additionalData!['sender_profile_image']
                .toString(),
            senderName:
                event.notification.additionalData!['senderName'].toString(),
            conversation_id: event
                .notification.additionalData!['conversation_id']
                .toString(),
            message_id:
                event.notification.additionalData!['message_id'].toString(),
            caller_id:
                event.notification.additionalData!['senderId'].toString(),
            isGroupCall:
                event.notification.additionalData!['is_group'].toString(),
          ));
          FlutterRingtonePlayer().playRingtone();
        }
      } else if (event.notification.additionalData!['call_type'].toString() ==
          'audio_call') {
        print("audio call");
        if (event.notification.additionalData!['missed_call'].toString() ==
            "true") {
          Get.back();
        } else {
          Get.to(IncomingCallScrenn(
            roomID: event.notification.additionalData!['room_id'].toString(),
            callerImage: event
                .notification.additionalData!['sender_profile_image']
                .toString(),
            senderName:
                event.notification.additionalData!['senderName'].toString(),
            conversation_id: event
                .notification.additionalData!['conversation_id']
                .toString(),
            message_id:
                event.notification.additionalData!['message_id'].toString(),
            caller_id:
                event.notification.additionalData!['senderId'].toString(),
            forVideoCall: false,
            receiverImage: event
                .notification.additionalData!['receiver_profile_image']
                .toString(),
            isGroupCall:
                event.notification.additionalData!['is_group'].toString(),
          ));
        }
      }
    });
  }

  onNotificationClick() {
    OneSignal.Notifications.addClickListener((event) {
      if (event.result.actionId == "accept") {
        print("actionId accept");
        if (event.notification.additionalData!['call_type'].toString() ==
            'video_call') {
          print("video call");
          OneSignal.Notifications.clearAll();
          FlutterRingtonePlayer().stop();
          Get.off(VideoCallScreen(
            roomID: event.notification.additionalData!['room_id'].toString(),
            conversation_id: event
                .notification.additionalData!['conversation_id']
                .toString(),
          ));
        } else if (event.notification.additionalData!['call_type'].toString() ==
            'audio_call') {
          print("audio call");
          // Navigate to the desired screen based on the payload'
          Get.off(AudioCallScreen(
            roomID: event.notification.additionalData!['room_id'].toString(),
            conversation_id: event
                .notification.additionalData!['conversation_id']
                .toString(),
            receiverImage: event
                .notification.additionalData!["sender_profile_image"]
                .toString(),
            receiverUserName:
                event.notification.additionalData!["senderName"].toString(),
          ));
        }
      } else if (event.result.actionId == "decline") {
        print("actionId decline");
        if (event.notification.additionalData!['call_type'].toString() ==
            'video_call') {
          OneSignal.Notifications.clearAll();
          FlutterRingtonePlayer().stop();
          if (event.notification.additionalData!['is_group'].toString() ==
              "true") {
            Get.back();
          } else {
            roomIdController.callCutByReceiver(
              conversationID: event
                  .notification.additionalData!['conversation_id']
                  .toString(),
              message_id:
                  event.notification.additionalData!['message_id'].toString(),
              caller_id:
                  event.notification.additionalData!['senderId'].toString(),
            );
          }
        } else if (event.notification.additionalData!['call_type'].toString() ==
            'audio_call') {
          if (event.notification.additionalData!['is_group'].toString() ==
              "true") {
            Get.back();
          } else {
            roomIdController.callCutByReceiver(
              conversationID: event
                  .notification.additionalData!['conversation_id']
                  .toString(),
              message_id:
                  event.notification.additionalData!['message_id'].toString(),
              caller_id:
                  event.notification.additionalData!['senderId'].toString(),
            );
          }
        }
      } else {
        if (event.notification.additionalData!['call_type'].toString() ==
            'video_call') {
          OneSignal.Notifications.clearAll();
          FlutterRingtonePlayer().stop();
          Get.to(IncomingCallScrenn(
            roomID: event.notification.additionalData!['room_id'].toString(),
            callerImage: event
                .notification.additionalData!['sender_profile_image']
                .toString(),
            senderName:
                event.notification.additionalData!['senderName'].toString(),
            conversation_id: event
                .notification.additionalData!['conversation_id']
                .toString(),
            message_id:
                event.notification.additionalData!['message_id'].toString(),
            caller_id:
                event.notification.additionalData!['senderId'].toString(),
            isGroupCall:
                event.notification.additionalData!['is_group'].toString(),
          ));
        } else if (event.notification.additionalData!['call_type'].toString() ==
            'audio_call') {
          Get.to(IncomingCallScrenn(
            roomID: event.notification.additionalData!['room_id'].toString(),
            callerImage: event
                .notification.additionalData!['sender_profile_image']
                .toString(),
            senderName:
                event.notification.additionalData!['senderName'].toString(),
            conversation_id: event
                .notification.additionalData!['conversation_id']
                .toString(),
            message_id:
                event.notification.additionalData!['message_id'].toString(),
            caller_id:
                event.notification.additionalData!['senderId'].toString(),
            forVideoCall: false,
            receiverImage: event
                .notification.additionalData!['receiver_profile_image']
                .toString(),
            isGroupCall:
                event.notification.additionalData!['is_group'].toString(),
          ));
        }
      }
    });
  }
}
