// ignore_for_file: file_names, library_prefixes

import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:meyaoo_new/controller/online_controller.dart';
import 'package:meyaoo_new/src/global/global.dart';
import 'package:meyaoo_new/src/global/strings.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketIntilized {
  // OnlineUserData onlineUsersModel =
  //     OnlineUserData(); // For user is online or not
  OnlineOfflineController controller = Get.put(OnlineOfflineController());
  IO.Socket? socket;
  initlizedsocket() async {
    socket = IO.io(
        '${socketBaseUrl()}/?token=${Hive.box(userdata).get(authToken).toString()}',
        <String, dynamic>{
          'transports': ['websocket'],
        });
    log('${socketBaseUrl()}/?user_id=${Hive.box(userdata).get(authToken).toString()} USER ID ');
    if (kDebugMode) {
      print("Socket Activated");
    }
    controller.forData();
    controller.offlineUser();
    controller.isTyping();
    // forData();
    // offlineUser();
  }

  // forData() {
  //   socket!.on("onlineUsers", (data) {
  //     if (kDebugMode) {
  //       print("ONLINE DATA  $data");
  //     }
  //     if (onlineUserModel.onlineUserList == null) {
  //       if (kDebugMode) {
  //         print('online users null');
  //       }
  //       var respo = OnlineUsersModel.fromJson(data);
  //       onlineUserModel = respo; // Update the value property
  //       log("ONLINE USER LIST ${onlineUserModel.onlineUserList}");
  //     } else {
  //       if (kDebugMode) {
  //         print('Online users not null');
  //       }
  //       if (kDebugMode) {
  //         print("ONLINE DATA $data");
  //       }
  //       var res = OnlineUsersModel.fromJson(data);
  //       onlineUserModel = res; // Update the value property
  //       log("${onlineUserModel.onlineUserList}");

  //       // No need to call update() here
  //     }
  //   });
  // }

  // offlineUser() {
  //   socket!.on("userLastSeenList", (data) {
  //     if (kDebugMode) {
  //       print("OFFLINE DATA  $data");
  //     }
  //     if (lastSeenModel.lastSeenUserList == null) {
  //       if (kDebugMode) {
  //         print('offline users null');
  //       }
  //       var respo = LastSeenModel.fromJson(data);
  //       lastSeenModel = respo; // Update the value property
  //       log("OFFLINE USER LIST ${lastSeenModel.lastSeenUserList}");
  //     } else {
  //       if (kDebugMode) {
  //         print('Offline users not null');
  //       }
  //       if (kDebugMode) {
  //         print("OFFLINE DATA $data");
  //       }
  //       var res = LastSeenModel.fromJson(data);
  //       lastSeenModel = res; // Update the value property
  //       log("${lastSeenModel.lastSeenUserList}");

  //       // No need to call update() here
  //     }
  //   });
  // }
}
