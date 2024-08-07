// ignore_for_file: avoid_print
//flutter version 3.19.6
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meyaoo_new/app.dart';
import 'package:meyaoo_new/notification_service.dart';
import 'package:meyaoo_new/src/global/global.dart';
import 'package:meyaoo_new/src/global/socket_initiallize.dart';
import 'package:meyaoo_new/src/global/strings.dart';
import 'package:meyaoo_new/src/screens/layout/bottombar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
Future<void> _firebasebackgroundmessagehendler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("BackgroundDATA:${message.data.toString()}");
  print("BackgroundTITLE:${message.notification!.title}");

  if (message.data['title'] == 'Call Decline') {
    Get.to(() => TabbarScreen());
  }
  //
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebasebackgroundmessagehendler);
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
