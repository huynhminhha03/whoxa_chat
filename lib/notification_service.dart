// ignore_for_file: deprecated_member_use, file_names, depend_on_referenced_packages, use_key_in_widget_constructors, library_private_types_in_public_api, avoid_print, unnecessary_new, prefer_const_constructors, sort_child_properties_last, prefer_final_fields, prefer_typing_uninitialized_variables, use_build_context_synchronously, sized_box_for_whitespace, unnecessary_string_escapes, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, prefer_is_empty, no_leading_underscores_for_local_identifiers, prefer_interpolation_to_compose_strings, duplicate_ignore, use_super_parameters, prefer_if_null_operators, curly_braces_in_flow_control_structures, unnecessary_const, unnecessary_this, must_be_immutable, no_logic_in_create_state, avoid_function_literals_in_foreach_calls, unnecessary_string_interpolations, avoid_single_cascade_in_expression_statements, prefer_const_declarations, unnecessary_null_comparison, prefer_const_constructors_in_immutables, await_only_futures
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static createanddisplaynotification(RemoteMessage message) async {
    try {
      print("display_notifcation");
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      NotificationDetails notificationDetails = NotificationDetails(
        iOS: DarwinNotificationDetails(),
        android: message.data['title'] == 'Video call' ||
                message.data['title'] == 'Audio call' ||
                message.data['title'] == 'Group Audio call' ||
                message.data['title'] == 'Group Video call'
            ? AndroidNotificationDetails("meyaooapp", "meyaoochannel",
                importance: Importance.max,
                priority: Priority.high,
                icon: "@mipmap/ic_launcher",
                playSound: true,
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
                  ])
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

      ///NORMAL NOTIFICATION

      await notificationsPlugin.show(
        id,
        // message.notification!.title,
        message.notification!.title,
        message.notification!.body,
        notificationDetails,
        // payload: message.data['title'] == "Video call"
        //     ? "Video call"
        //     : message.data['title'] == "Audio call"
        //         ? "Audio call "
        //         : message.data['title'] == "Group Audio call"
        //             ? "Group Audio call"
        //             : message.data['title'] == "Group Video call"
        //                 ? "Group Video call"
        //                 : message.data['_id'],
      );
    } on Exception catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  static void initialize() {
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
    );
  }
}
