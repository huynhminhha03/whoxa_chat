import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:meyaoo_new/Models/last_seen_model.dart';
import 'package:meyaoo_new/Models/typing_user_model.dart';
import 'package:meyaoo_new/controller/online_user_controller.dart';
import 'package:meyaoo_new/main.dart';

class OnlineOfflineController extends GetxController {
  Rx<OnlineUsersModel> onlineUserModel = OnlineUsersModel().obs;
  RxList<String> allOnline = <String>[].obs;

  Rx<LastSeenModel> lastSeenModel = LastSeenModel().obs;
  RxList<LastSeenUserList> allOffline = <LastSeenUserList>[].obs;

  bool typingloder = true;
  Rx<TypingUserModel?> typingUserListModel = TypingUserModel().obs;
  RxList<TypingUserList> typingList = <TypingUserList>[].obs;

  forData() {
    socketIntilized.socket!.on("onlineUsers", (data) {
      if (kDebugMode) {
        print("ONLINE DATA  $data");
      }
      if (onlineUserModel.value.onlineUserList == null) {
        if (kDebugMode) {
          print('online users null');
        }
        var respo = OnlineUsersModel.fromJson(data);
        onlineUserModel.value = respo; // Update the
        allOnline.value = OnlineUsersModel.fromJson(data).onlineUserList!;

        log("ONLINE USER LIST ${onlineUserModel.value.onlineUserList}");
      } else {
        if (kDebugMode) {
          print('Online users not null');
        }
        if (kDebugMode) {
          print("ONLINE DATA $data");
        }
        var res = OnlineUsersModel.fromJson(data);
        onlineUserModel.value = res; // Update the value property
        allOnline.value = OnlineUsersModel.fromJson(data).onlineUserList!;
        log("${onlineUserModel.value.onlineUserList}");

        // No need to call update() here
      }
    });
  }

  offlineUser() {
    socketIntilized.socket!.on("userLastSeenList", (data) {
      if (kDebugMode) {
        print("OFFLINE DATA  $data");
      }
      if (lastSeenModel.value.lastSeenUserList == null) {
        if (kDebugMode) {
          print('offline users null');
        }
        var respo = LastSeenModel.fromJson(data);
        lastSeenModel.value = respo; // Update the value property
        allOffline.value = LastSeenModel.fromJson(data).lastSeenUserList!;
        log("OFFLINE USER LIST ${lastSeenModel.value.lastSeenUserList}");
      } else {
        if (kDebugMode) {
          print('Offline users not null');
        }
        if (kDebugMode) {
          print("OFFLINE DATA $data");
        }
        var res = LastSeenModel.fromJson(data);
        lastSeenModel.value = res; // Update the value property
        allOffline.value = LastSeenModel.fromJson(data).lastSeenUserList!;
        log("${lastSeenModel.value.lastSeenUserList}");

        // No need to call update() here
      }
    });
  }

  isTyping() {
    socketIntilized.socket!.on('isTyping', (data) {
      if (typingUserListModel.value!.typingUserList == null) {
        log(data.toString());
        var respo = TypingUserModel.fromJson(data);
        typingUserListModel.value = respo; // Update the value property
        typingList.value = TypingUserModel.fromJson(data).typingUserList!;
        typingloder = false;
      } else {
        log(data.toString());
        var respo = TypingUserModel.fromJson(data);
        typingUserListModel.value = respo; // Update the value property
        typingList.value = TypingUserModel.fromJson(data).typingUserList!;
        typingloder = false;
      }
    });
  }
}
