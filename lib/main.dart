// ignore_for_file: avoid_print
//flutter version 3.19.6
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meyaoo_new/app.dart';
import 'package:meyaoo_new/src/global/global.dart';
import 'package:meyaoo_new/src/global/socket_initiallize.dart';
import 'package:meyaoo_new/src/global/strings.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

@pragma('vm:entry-point')
Future<void> _firebasebackgroundmessagehendler(RemoteMessage message) async {
  print("BackgroundDATA:${message.data.toString()}");
  print("BackgroundTITLE:${message.notification!.title}");
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // LocalNotificationService.initialize();
  await Firebase.initializeApp();
  // dynamicLinkIsPending();
  FirebaseMessaging.onBackgroundMessage(_firebasebackgroundmessagehendler);
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("fa0d2111-1ab5-49d7-ad5d-976b8d9d66a4");
  OneSignal.Notifications.requestPermission(true);
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

// dynamicLinkIsPending() async {
//   print("deepLinking");
//   final initialLink = await FirebaseDynamicLinks.instance.getInitialLink();

//   print("initialLink 1 $initialLink");
//   if (initialLink != null) {
//     final Uri deepLink = initialLink.link;
//     print("deepLink 1 $deepLink");
//   }

//   FirebaseDynamicLinks.instance.onLink.listen(
//     (pendingDynamicLinkData) {
//       print("FirebaseDynamicLinks cheking");
//       final Uri deepLink = pendingDynamicLinkData.link;
//       log("deepLink 2 $deepLink");
//       if (deepLink.path == "/incoming_video_call") {
//         print("NAVIGAT TO VIDEO CALL SCREEN");
//         Get.to(VideoCallScreen());
//       }
//     },
//   );
// }

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
  if (Hive.box(userdata).get(authToken) != '' &&
      Hive.box(userdata).get(authToken) != null) {
    await socketIntilized.initlizedsocket();
  }
}
