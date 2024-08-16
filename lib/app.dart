// ignore_for_file: avoid_print, empty_catches, unused_local_variable, use_build_context_synchronously, depend_on_referenced_packages, unused_import, unused_field

import 'dart:developer';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
// import 'package:meyaoo_new/controller/call_history_controller.dart';
import 'package:meyaoo_new/controller/get_delete_story.dart';
import 'package:meyaoo_new/main.dart';
import 'package:meyaoo_new/src/Notification/notifiactions_handler.dart';
import 'package:meyaoo_new/src/Notification/notification_service.dart';
import 'package:meyaoo_new/src/global/global.dart';
import 'package:meyaoo_new/src/global/strings.dart';
import 'package:meyaoo_new/src/screens/call/web_rtc/video_call_screen.dart';
import 'package:meyaoo_new/src/screens/user/create_profile.dart';
import 'package:meyaoo_new/welcome.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import 'src/screens/layout/bottombar.dart';

class AppScreen extends StatefulWidget {
  const AppScreen({super.key});

  @override
  State<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> with WidgetsBindingObserver {
  //CallHistoryController callController = Get.put(CallHistoryController());
  GetDeleteStroy deleteStroy = Get.put(GetDeleteStroy());
  String? _currentUuid;
  late final Uuid _uuid;

  asknotificationpermmision() async {
    await FlutterCallkitIncoming.requestNotificationPermission({
      "rationaleMessagePermission":
          "Notification permission is required, to show notification.",
      "postNotificationMessageRequired":
          "Notification permission is required, Please allow notification permission from setting."
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // asknotificationpermmision();
    requestPermissions();
    _checkPermissions();
    FirebaseMessagingService()
        .setUpFirebase(); // Initialize Firebase messaging service

    deleteStroy.getDelete();
    log("AuthToken: ${Hive.box(userdata).get(authToken)}");
  }

  Future<void> _checkPermissions() async {
    if (await Permission.contacts.request().isGranted) {
      // You can access the contacts
      getContactsFromGloble();
    } else {
      // You can show a message to the user asking them to grant the permission
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Contacts permission is required to use this feature')),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _handleCurrentScreen();
  }

  Widget _handleCurrentScreen() {
    var box = Hive.box(userdata);
    if (box.get(userId) != null &&
        box.get(authToken) != null &&
        box.get(lastName) != null &&
        box.get(lastName)!.isNotEmpty &&
        box.get(firstName) != null &&
        box.get(firstName)!.isNotEmpty) {
      return TabbarScreen();
    } else if (box.get(userId) == null &&
        box.get(authToken) == null &&
        box.get(lastName) == null &&
        box.get(firstName) == null) {
      return const Welcome();
    } else {
      return AddPersonaDetails(isRought: false, isback: false);
    }
  }

  Future<void> requestPermissions() async {
    // Request notification permission
    await Permission.notification.request();

    // Request location permission
    await Permission.location.request();

    // Request camera permission
    await Permission.camera.request();

    // Request microphone permission
    await Permission.microphone.request();

    // Request storage permission
    await Permission.storage.request();

    // Request photo library permission
    await Permission.photos.request();
  }
}
