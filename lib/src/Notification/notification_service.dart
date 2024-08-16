// ignore_for_file: deprecated_member_use, file_names, depend_on_referenced_packages, use_key_in_widget_constructors, library_private_types_in_public_api, avoid_print, unnecessary_new, prefer_const_constructors, sort_child_properties_last, prefer_final_fields, prefer_typing_uninitialized_variables, use_build_context_synchronously, sized_box_for_whitespace, unnecessary_string_escapes, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, prefer_is_empty, no_leading_underscores_for_local_identifiers, prefer_interpolation_to_compose_strings, duplicate_ignore, use_super_parameters, prefer_if_null_operators, curly_braces_in_flow_control_structures, unnecessary_const, unnecessary_this, must_be_immutable, no_logic_in_create_state, avoid_function_literals_in_foreach_calls, unnecessary_string_interpolations, avoid_single_cascade_in_expression_statements, prefer_const_declarations, unnecessary_null_comparison, prefer_const_constructors_in_immutables, await_only_futures
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:meyaoo_new/controller/call_controller.dart/get_roomId_controller.dart';
import 'package:meyaoo_new/src/screens/call/web_rtc/audio_call_screen.dart';
import 'package:meyaoo_new/src/screens/call/web_rtc/incoming_call_screen.dart';
import 'package:meyaoo_new/src/screens/call/web_rtc/video_call_screen.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final RoomIdController roomIdController = Get.put(RoomIdController());

  createanddisplaynotification(RemoteMessage message) async {
    try {
      print("display_notifcation");
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      NotificationDetails notificationDetails = NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentSound: true,
          presentAlert: true,
          presentBadge: true,
        ),
        android: (message.data['call_type'] == 'video_call' &&
                    message.data['missed_call'] == "false") ||
                (message.data['call_type'] == 'audio_call' &&
                    message.data['missed_call'] == "false")
            ? AndroidNotificationDetails(
                "meyaooapp",
                "meyaoochannel",
                importance: Importance.max,
                priority: Priority.high,
                icon: "@mipmap/ic_launcher",
                playSound: true,
                enableVibration: true,
                showWhen: true,
                sound: RawResourceAndroidNotificationSound('calling'),
                audioAttributesUsage: AudioAttributesUsage.notificationRingtone,
                category: AndroidNotificationCategory.call,
                actions: [
                  AndroidNotificationAction(
                    "accept",
                    '📞 Accept',
                    cancelNotification: false,
                    allowGeneratedReplies: true,
                    showsUserInterface: true,
                    titleColor: Colors.green,
                  ),
                  const AndroidNotificationAction(
                    "decline",
                    '🚫 Decline',
                    cancelNotification: false,
                    allowGeneratedReplies: true,
                    showsUserInterface: true,
                    titleColor: Colors.red,
                  ),
                ],
              )
            : AndroidNotificationDetails(
                "meyaooapp",
                "meyaoochannel",
                importance: Importance.max,
                priority: Priority.high,
                icon: "@mipmap/ic_launcher",
                playSound: true,
                category: AndroidNotificationCategory.social,
              ),
      );
      await notificationsPlugin.show(
        id,
        message.notification!.title,
        message.notification!.body,
        notificationDetails,
        payload: json.encode(message.data),
      );

      InitializationSettings initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings("@mipmap/ic_launcher"),
        iOS: DarwinInitializationSettings(
          onDidReceiveLocalNotification: (id, title, body, payload) {
            return;
          },
        ),
      );

      notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveBackgroundNotificationResponse: (details) async {
          Map data = json.decode(details.payload!);
          if (details.actionId == 'accept') {
            print("accept");
            if (data['call_type'] == 'video_call') {
              print("FirebaseMessaging.service 1 video call");
              // Navigate to the desired screen based on the payload'
              Get.off(VideoCallScreen(
                roomID: data['room_id'],
                conversation_id: data['conversation_id'],
              ));
            } else if (data['call_type'] == 'audio_call') {
              print("FirebaseMessaging.service 1 video call");
              // Navigate to the desired screen based on the payload'
              Get.off(AudioCallScreen(
                roomID: data['room_id'],
                conversation_id: data['conversation_id'],
                receiverImage: data["sender_profile_image"],
                receiverUserName: data["senderName"],
              ));
            }
          } else if (details.actionId == 'decline') {
            print("☺☺☺☺☺☺☺☺☺☺☺☺☺☺decline_background");
            if (data['call_type'] == 'video_call') {
              roomIdController.callCutByReceiver(
                conversationID: data['conversation_id'],
                message_id: data['message_id'],
                caller_id: data['senderId'],
              );
            } else if (data['call_type'] == 'audio_call') {
              roomIdController.callCutByReceiver(
                conversationID: data['conversation_id'],
                message_id: data['message_id'],
                caller_id: data['senderId'],
              );
            }
          } else {
            if (data['call_type'] == 'video_call') {
              Get.to(IncomingCallScrenn(
                roomID: data['room_id'],
                callerImage: data['sender_profile_image'],
                senderName: data['senderName'],
                conversation_id: data['conversation_id'],
                message_id: data['message_id'],
                caller_id: data['senderId'],
              ));
            } else if (data['call_type'] == 'audio_call') {
              Get.to(IncomingCallScrenn(
                roomID: data['room_id'],
                callerImage: data['sender_profile_image'],
                senderName: data['senderName'],
                conversation_id: data['conversation_id'],
                message_id: data['message_id'],
                caller_id: data['senderId'],
                forVideoCall: false,
                receiverImage: data['receiver_profile_image'],
              ));
            }
          }
          LocalNotificationService.notificationsPlugin.cancelAll();
        },
        onDidReceiveNotificationResponse: (details) {
          Map data = json.decode(details.payload!);
          if (details.actionId == 'accept') {
            print("accept");
            if (data['call_type'] == 'video_call') {
              print("FirebaseMessaging.service 2 video call");
              Get.off(VideoCallScreen(
                roomID: data['room_id'],
                conversation_id: data['conversation_id'],
              ));
            } else if (data['call_type'] == 'audio_call') {
              print("FirebaseMessaging.service 1 video call");
              // Navigate to the desired screen based on the payload'
              Get.off(AudioCallScreen(
                roomID: data['room_id'],
                conversation_id: data['conversation_id'],
                receiverImage: data["sender_profile_image"],
                receiverUserName: data["senderName"],
              ));
            }
          } else if (details.actionId == 'decline') {
            print("☺☺☺☺☺☺☺☺☺☺☺☺☺☺decline_insideapp");
            if (data['call_type'] == 'video_call') {
              roomIdController.callCutByReceiver(
                conversationID: data['conversation_id'],
                message_id: data['message_id'],
                caller_id: data['senderId'],
              );
            } else if (data['call_type'] == 'audio_call') {
              roomIdController.callCutByReceiver(
                conversationID: data['conversation_id'],
                message_id: data['message_id'],
                caller_id: data['senderId'],
              );
            }
          } else {
            if (data['call_type'] == 'video_call') {
              Get.to(IncomingCallScrenn(
                roomID: data['room_id'],
                callerImage: data['sender_profile_image'],
                senderName: data['senderName'],
                conversation_id: data['conversation_id'],
                message_id: data['message_id'],
                caller_id: data['senderId'],
              ));
            } else if (data['call_type'] == 'audio_call') {
              Get.to(IncomingCallScrenn(
                roomID: data['room_id'],
                callerImage: data['sender_profile_image'],
                senderName: data['senderName'],
                conversation_id: data['conversation_id'],
                message_id: data['message_id'],
                caller_id: data['senderId'],
                forVideoCall: false,
                receiverImage: data['receiver_profile_image'],
              ));
            }
          }
          LocalNotificationService.notificationsPlugin.cancelAll();
          // }
        },
      );

      ///NORMAL NOTIFICATION
    } on Exception catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  // static void initialize() {
  //   InitializationSettings initializationSettings = InitializationSettings(
  //     android: AndroidInitializationSettings("@mipmap/ic_launcher"),
  //     iOS: DarwinInitializationSettings(
  //       onDidReceiveLocalNotification: (id, title, body, payload) {
  //         return;
  //       },
  //     ),
  //   );

  //   notificationsPlugin.initialize(
  //     initializationSettings,
  //     onDidReceiveBackgroundNotificationResponse: (details) async {
  //       Map data = json.decode(details.payload!);
  //       if (details.actionId == 'accept') {
  //         print("accept");
  //         if (data['call_type'] == 'video_call') {
  //           print("FirebaseMessaging.service 1 video call");
  //           // Navigate to the desired screen based on the payload'
  //           Get.to(VideoCallScreen(
  //             roomID: data['room_id'],
  //           ));
  //         }
  //       } else if (details.actionId == 'decline') {
  //         print("☺☺☺☺☺☺☺☺☺☺☺☺☺☺decline_background");
  //       } else {}
  //     },
  //     onDidReceiveNotificationResponse: (details) {
  //       Map data = json.decode(details.payload!);
  //       if (details.actionId == 'accept') {
  //         print("accept");
  //         if (data['call_type'] == 'video_call') {
  //           print("FirebaseMessaging.service 2 video call");
  //           Get.to(VideoCallScreen(
  //             roomID: data['room_id'],
  //           ));
  //         }
  //       } else if (details.actionId == 'decline') {
  //         print("☺☺☺☺☺☺☺☺☺☺☺☺☺☺decline_insideapp");
  //       } else {}
  //       // }
  //     },
  //   );
  // }
}
