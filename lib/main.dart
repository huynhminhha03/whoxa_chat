// ignore_for_file: avoid_print
//flutter version 3.19.6
import 'dart:developer';
import 'dart:io';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meyaoo_new/app.dart';
import 'package:meyaoo_new/src/Notification/notification_service.dart';
import 'package:meyaoo_new/src/global/global.dart';
import 'package:meyaoo_new/src/global/socket_initiallize.dart';
import 'package:meyaoo_new/src/global/strings.dart';
import 'package:meyaoo_new/src/screens/call/web_rtc/video_call_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// Future<void> _firebasebackgroundmessagehendler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print("BackgroundDATA:${message.data.toString()}");
//   print("BackgroundTITLE:${message.notification!.title}");

//   // if (message.data['call_type'] == 'video_call') {
//   //   print("background video call");
//   //   // launchURL("https://meyaoo.page.link/incoming_video_call");
//   //   Uri.parse("https://meyaoo.page.link/incoming_video_call");

//   //   // // _currentUuid = _uuid.v4();
//   //   // // // showInCommingCall(_currentUuid!, message);
//   //   // Get.to(VideoCallScreen(
//   //   //   roomID: message.data['room_id'],
//   //   // ));
//   // } else {
//   if (message.notification != null) {
//     print(message.notification!.title);

//     print(message.data['message']);

//     print("message.data ${message.data}");
//     if (message.data['title'] == 'Call Decline') {
//       Get.to(TabbarScreen());
//     }

//     ///SIMPLE NOTIFICATION
//     InitializationSettings initializationSettings =
//         const InitializationSettings(
//       android: AndroidInitializationSettings("@mipmap/ic_launcher"),
//     );

//     LocalNotificationService.notificationsPlugin.initialize(
//       initializationSettings,
//       //-----------------------------------------------------------------------------
//       //--------------------------- WHEN APP BACKGROUND -----------------------------
//       //-----------------------------------------------------------------------------
//       onDidReceiveBackgroundNotificationResponse: (details) {
//         if (details.actionId == 'accept') {
//           print("accept 1");
//           if (message.data['call_type'] == 'video_call') {
//             // Navigate to the desired screen based on the payload'
//             // Get.to(VideoCallScreen(
//             //   roomID: message.data['room_id'],
//             // ));
//             print("tap on accept buttn");
//             launchURL("https://meyaoo.page.link/incoming_video_call");
//           } else if (message.data['title'] == 'Audio call') {
//             // navigate to screen
//           } else if (message.data['title'] == 'Group Audio call') {
//             // navigate to screen
//           } else if (message.data['title'] == 'Group Video call') {
//             //navigate to screen
//           }
//         } else if (details.actionId == 'decline') {
//           print("☺☺☺☺☺☺☺☺☺☺☺☺☺☺decline_background");
//         } else {
//           // if (message.data['call_type'] == 'video_call') {
//           //   Get.to(VideoCallScreen(
//           //     roomID: message.data['room_id'],
//           //   ));
//           //   // Get.to(VideoCallPage(
//           //   //   callerImage: message.data['caller_profile_pic'],
//           //   //   callerName: message.data['caller_name'],
//           //   //   reciverImage: message.data['receiver_profile_pic'],
//           //   //   reciverName: message.data['receiver_name'],
//           //   //   isCaller: false,
//           //   //   isReciverWait: true,
//           //   //   waitChannelId: message.data['channel'],
//           //   //   waitToken: message.data['token'],
//           //   //   callerId: message.data['my_id'],
//           //   //   reciverId: message.data['toUser'],
//           //   // ));
//           // }
//           // else
//           if (message.data['title'] == 'Audio call') {
//             //navigate to screen
//           } else if (message.data['title'] == 'Group Audio call') {
//             //navigate to screen
//           } else if (message.data['title'] == 'Group video call') {
//             //navigate to screen
//           } else if (message.data['title_done'] == 'Message') {
//             print("ID::::::");
//             // single chat message notification through navigate specific single_chat
//             // Get.to(() => SingelChatDetailsScreenTemp(
//             //       index: 0,
//             //       seconduserID: message.data['second_user_id'],
//             //       secondUsername: capitalizeFirstLetter(getContact1(
//             //           getMobile(message.data['mobile']),
//             //           message.data['second_username'])),
//             //       groupID: "",
//             //       groupName: "",
//             //       myID: message.data['my_id'],
//             //       isBlocked: "0",
//             //       seconduserpic: message.data['profile_image'],
//             //       phoneNumber: message.data['mobile'],
//             //       userStatus: "",
//             //       lastSeen: "",
//             //     ));
//           } else if (message.data['title_done'] == 'group_message') {
//             print("GROUP::::");
//             // group chat message notification through navigate specific group_chat
//             // Get.to(() => GroupchatScreenTemp(
//             //       groupID: message.data['group_id'],
//             //       groupName: message.data['group_name'],
//             //       myID: Hive.box(userdata).get(userId),
//             //       seconduserpic: message.data['group_profile_image'],
//             //     ));
//           }
//         }
//         // }
//       },
//       //-----------------------------------------------------------------------------------------------------------
//       //------------------------------------------------- WEHN APP IS ALREADY OPEN THEN RECEIVED NOTIFI------------
//       //-----------------------------------------------------------------------------------------------------------
//       onDidReceiveNotificationResponse: (details) {
//         if (details.actionId == 'accept') {
//           print("accept");
//           if (message.data['call_type'] == 'video_call') {
//             Get.to(VideoCallScreen(
//               roomID: message.data['room_id'],
//             ));
//             // Navigate to the desired screen based on the payload'
//             // Get.to(VideoCallPage(
//             //   fromChannelId: message.data['channel'],
//             //   fromToken: message.data['token'],
//             //   isCaller: false,
//             //   callerImage: message.data['caller_profile_pic'],
//             //   callerName: message.data['caller_name'],
//             //   isReciverWait: false,
//             // ));
//           } else if (message.data['title'] == 'Audio call') {
//             //navigate to screen
//           } else if (message.data['title'] == 'Group Audio call') {
//             //navigate to screen
//           } else if (message.data['title'] == 'Group Video call') {
//             //navigate to screen
//           }
//         } else if (details.actionId == 'decline') {
//           print("☺☺☺☺☺☺☺☺☺☺☺☺☺☺decline_insideapp");
//         } else {
//           if (message.data['call_type'] == 'video_call') {
//             Get.to(VideoCallScreen(
//               roomID: message.data['room_id'],
//             ));
//             // Get.to(VideoCallPage(
//             //   callerImage: message.data['caller_profile_pic'],
//             //   callerName: message.data['caller_name'],
//             //   reciverImage: message.data['receiver_profile_pic'],
//             //   reciverName: message.data['receiver_name'],
//             //   isCaller: false,
//             //   isReciverWait: true,
//             //   waitChannelId: message.data['channel'],
//             //   waitToken: message.data['token'],
//             //   callerId: message.data['my_id'],
//             //   reciverId: message.data['toUser'],
//             // ));
//           } else if (message.data['title'] == 'Audio call') {
//             //navigate to screen
//           } else if (message.data['title'] == 'Group Audio call') {
//             //navigate to screen
//           } else if (message.data['title'] == 'Group Video call') {
//             //navigate to screen
//           } else if (message.data['title_done'] == 'Message') {
//             print("ID::::::");
//             // single chat message notification through navigate specific single_chat
//             // Get.to(() => SingelChatDetailsScreenTemp(
//             //       index: 0,
//             //       seconduserID: message.data['second_user_id'],
//             //       secondUsername: capitalizeFirstLetter(getContact1(
//             //           getMobile(message.data['mobile']),
//             //           message.data['second_username'])),
//             //       groupID: "",
//             //       groupName: "",
//             //       myID: message.data['my_id'],
//             //       isBlocked: "0",
//             //       seconduserpic: message.data['profile_image'],
//             //       phoneNumber: message.data['mobile'],
//             //       userStatus: "",
//             //       lastSeen: "",
//             //     ));
//           } else if (message.data['title_done'] == 'group_message') {
//             print("GROUP::::");
//             // group chat message notification through navigate specific group_chat
//             // Get.to(() => GroupchatScreenTemp(
//             //       groupID: message.data['group_id'],
//             //       groupName: message.data['group_name'],
//             //       myID: Hive.box(userdata).get(userId),
//             //       seconduserpic: message.data['group_profile_image'],
//             //     ));
//           }
//         }
//         // }
//       },
//     );
//     LocalNotificationService.createanddisplaynotification(message);
//   }
//   // }
//   //
// }
// Future<void> _firebasebackgroundmessagehendler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print("BackgroundDATA:${message.data.toString()}");
//   print("BackgroundTITLE:${message.notification!.title}");

//   // if (message.data['call_type'] == 'video_call') {
//   //   print("background video call");
//   //   // launchURL("https://meyaoo.page.link/incoming_video_call");
//   //   Uri.parse("https://meyaoo.page.link/incoming_video_call");

//   //   // // _currentUuid = _uuid.v4();
//   //   // // // showInCommingCall(_currentUuid!, message);
//   //   // Get.to(VideoCallScreen(
//   //   //   roomID: message.data['room_id'],
//   //   // ));
//   // } else {
//   if (message.notification != null) {
//     print(message.notification!.title);

//     print(message.data['message']);

//     print("message.data ${message.data}");

//     ///SIMPLE NOTIFICATION
//     InitializationSettings initializationSettings =
//         const InitializationSettings(
//       android: AndroidInitializationSettings("@mipmap/ic_launcher"),
//     );

//     LocalNotificationService.notificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveBackgroundNotificationResponse: (details) {
//         if (details.actionId == 'accept') {
//           print("accept 1");
//           if (message.data['call_type'] == 'video_call') {
//             // Navigate to the desired screen based on the payload'
//             // Get.to(VideoCallScreen(
//             //   roomID: message.data['room_id'],
//             // ));
//             print("tap on accept buttn");
//             launchURL("https://meyaoo.page.link/incoming_video_call");
//           }
//         } else if (details.actionId == 'decline') {
//           print("☺☺☺☺☺☺☺☺☺☺☺☺☺☺decline_background");
//         } else {}
//         // }
//       },
//       onDidReceiveNotificationResponse: (details) {
//         if (details.actionId == 'accept') {
//           print("accept 2");
//           if (message.data['call_type'] == 'video_call') {
//             // Navigate to the desired screen based on the payload'
//             // Get.to(VideoCallScreen(
//             //   roomID: message.data['room_id'],
//             // ));
//             print("tap on accept buttn");
//             launchURL("https://meyaoo.page.link/incoming_video_call");
//           }
//         } else if (details.actionId == 'decline') {
//           print("☺☺☺☺☺☺☺☺☺☺☺☺☺☺decline_background");
//         } else {}
//       },
//     );
//   }
//   // }
//   // LocalNotificationService.createanddisplaynotification(message);
// }

Future<void> _firebasebackgroundmessagehendler(RemoteMessage message) async {
//   await Firebase.initializeApp();
  print("BackgroundDATA:${message.data.toString()}");
  print("BackgroundTITLE:${message.notification!.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(_firebasebackgroundmessagehendler);

  await Firebase.initializeApp();
  dynamicLinkIsPending();
  LocalNotificationService.initialize();
  Directory directory = await getApplicationDocumentsDirectory();
  await Permission.location.request();
  // Initialize the time zone data
  tz.initializeTimeZones();

  Hive.init(directory.path);

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await Hive.initFlutter(appName);
  } else {
    await Hive.initFlutter();
  }
  await openHiveBox(userdata);

  await openHiveBox(catchData);
  // await openHiveBox(contactBox);
  await openHiveBox(allMsgCache);

  // await Hive.box(userdata)
  //     .put(utcLocaName, "${place.country}/${place.locality}");

  runApp(
      //  MultiProvider(
      // providers: [
      //   ChangeNotifierProvider.value(
      //     value: CreateProfileProvider(),
      //   ),
      //   ChangeNotifierProvider.value(
      //     value: GetChatListProvider(),
      //   ),
      //   ChangeNotifierProvider.value(
      //     value: GetChatProvider(),
      //   ),
      //   ChangeNotifierProvider.value(
      //     value: SendMessageProvider(),
      //   ),
      // ],
      GetMaterialApp(
    onInit: () {
      if (Hive.box(userdata).get(userId) == null ||
          Hive.box(userdata).get(userId) == "") {
        if (kDebugMode) {
          print("NO USER ID AVAILABLE");
        }
      } else {
        initSocket();
      }
    },
    debugShowCheckedModeBanner: false,
    title: appName,
    color: Colors.white,
    theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Poppins'),
    home: const AppScreen(),
  ));
}

dynamicLinkIsPending() async {
  print("deepLinking");
  final initialLink = await FirebaseDynamicLinks.instance.getInitialLink();

  print("initialLink 1 $initialLink");
  if (initialLink != null) {
    final Uri deepLink = initialLink.link;
    print("deepLink 1 $deepLink");
  }

  FirebaseDynamicLinks.instance.onLink.listen(
    (pendingDynamicLinkData) {
      print("FirebaseDynamicLinks cheking");
      final Uri deepLink = pendingDynamicLinkData.link;
      log("deepLink 2 $deepLink");
      if (deepLink.path == "/incoming_video_call") {
        print("NAVIGAT TO VIDEO CALL SCREEN");
        Get.to(VideoCallScreen());
      }
    },
  );
}

Future<void> openHiveBox(String boxName) async {
  final box = await Hive.openBox(boxName).onError((error, stackTrace) async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final String dirPath = dir.path;

    File dbFile = File('$dirPath/$boxName.hive');
    File lockFile = File('$dirPath/$boxName.lock');
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      dbFile = File('$dirPath/$appName/$boxName.hive');
      lockFile = File('$dirPath/$appName/$boxName.lock');
    }
    await dbFile.delete();
    await lockFile.delete();
    await Hive.openBox(boxName);
    throw 'Failed to open $boxName Box\nError: $error';
  });
  // clear box if it grows large
  if (box.length > 500) {
    box.clear();
  }
}

SocketIntilized socketIntilized = SocketIntilized();

Future<void> initSocket() async {
  await socketIntilized.initlizedsocket();
}
