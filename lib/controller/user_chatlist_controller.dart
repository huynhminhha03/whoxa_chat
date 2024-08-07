// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:meyaoo_new/Models/add_archive_model.dart';
import 'package:meyaoo_new/controller/online_user_controller.dart';
import 'package:meyaoo_new/main.dart';
import 'package:meyaoo_new/model/block_user_model.dart';
import 'package:meyaoo_new/model/userchatlist_model/archive_list_model.dart';
import 'package:meyaoo_new/model/userchatlist_model/userchatlist_model.dart';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:meyaoo_new/src/global/api_helper.dart';
import 'package:meyaoo_new/src/global/global.dart';
import 'package:meyaoo_new/src/global/strings.dart';

final ApiHelper apiHelper = ApiHelper();

class ChatListController extends GetxController {
  RxBool isChatListLoading = false.obs;
  Rx<UserChatListModel?> userChatListModel = UserChatListModel().obs;
  //RxList<ChatList> allChats = <ChatList>[].obs;

  RxBool isArchive = false.obs;
  Rx<AddArchiveModel?> archiveModel = AddArchiveModel().obs;

  Rx<UserArchiveListModel?> userArchiveListModel = UserArchiveListModel().obs;

  Rx<OnlineUsersModel?> onlineUserModel = OnlineUsersModel().obs;
  RxList<String> onlineUsers = <String>[].obs;

  RxBool isBlock = false.obs;
  Rx<BlockUserModel?> blockModel = BlockUserModel().obs;

  forChatList() async {
    //await socketIntilized.initlizedsocket();
    isChatListLoading(true);
    try {
      socketIntilized.socket!.emit("ChatList");
      print("Emitted");
      //Listen on ChatList
      socketIntilized.socket!.on("ChatList", (data) {
        userChatListModel.value = UserChatListModel.fromJson(data);
        //userChatListModel = respo.obs;
        // allChats.clear();
        // allChats.value = respo.chatList!;
        log("CHATLIST:$data");
        userChatListModel.refresh();
        //allChats.refresh();
        isChatListLoading(false);
      });
    } catch (e) {
      isChatListLoading(false);
      log("Error ${e.toString()}");
    } finally {
      isChatListLoading(false);
      print("Finally Called");
    }
  }

  // ChatList
  //socketIntilized.socket!.emit("ChatList");
  // OnlineUsers
  //socketIntilized.socket!.emit("onlineUsers");

  //Listen on ChatList
// ============================= Add to archive APi ====================
  addArchveApi(String conversationID, String name) async {
    print(conversationID);
    isArchive(true);
    try {
      var uri = Uri.parse(apiHelper.addArchive);
      var request = http.MultipartRequest("POST", uri);
      Map<String, String> headers = {
        'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
        "Accept": "application/json",
      };

      request.headers.addAll(headers);
      request.fields['conversation_id'] = conversationID.toString();

      print("FILEDS:${request.fields}");

      var response = await request.send();
      String responseData =
          await response.stream.transform(utf8.decoder).join();
      var userData = json.decode(responseData);

      archiveModel.value = AddArchiveModel.fromJson(userData);

      if (archiveModel.value!.success == true) {
        forArchiveChatList();
        isArchive(false);
        showCustomToast("$name" " archived ");
      } else {
        isArchive(false);
        showCustomToast(archiveModel.value!.message!);
      }
    } catch (e) {
      isArchive(false);
      showCustomToast(e.toString());
    } finally {
      isArchive(false);
    }
  }

//=============================================================================================================
  forArchiveChatList() async {
    // await socketIntilized.initlizedsocket();
    isChatListLoading(true);
    try {
      socketIntilized.socket!.emit("ChatList");
      print("Emitted");
      //Listen on ChatList
      socketIntilized.socket!.on("ArchiveList", (data) {
        print("LISTE EMITTEDDDDDDDDDDDDDDDD 111");
        print("data12345678 $data");

        userArchiveListModel.value = UserArchiveListModel.fromJson(data);
        userChatListModel.refresh();
        isChatListLoading(false);
        log("ARCHIV LIST: ${userArchiveListModel.value!.archiveList}");
        // }
        print("DATA $data");
      });
    } catch (e) {
      isChatListLoading(false);
      log("Error ${e.toString()}");
    } finally {
      isChatListLoading(false);
      print("Finally Called");
    }
  }

  blockUserApi(conversationID) async {
    isBlock(true);

    try {
      var uri = Uri.parse(apiHelper.blockUserUrl);
      var request = http.MultipartRequest("POST", uri);
      Map<String, String> headers = {
        'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
        "Accept": "application/json",
      };

      request.headers.addAll(headers);
      request.fields['conversation_id'] = conversationID.toString();

      print("FILEDS:${request.fields}");

      var response = await request.send();
      String responseData =
          await response.stream.transform(utf8.decoder).join();
      var userData = json.decode(responseData);

      blockModel.value = BlockUserModel.fromJson(userData);

      print(responseData);

      if (blockModel.value!.success == true) {
        for (var i = 0; i < userChatListModel.value!.chatList!.length; i++) {
          debugPrint(
              "allChats[i].conversationId ${userChatListModel.value!.chatList![i].conversationId}");
          debugPrint("allChats[i].conversationId $conversationID");
          if (userChatListModel.value!.chatList![i].conversationId.toString() ==
              conversationID.toString()) {
            debugPrint(
                "allChats[i].conversationId 1 ${userChatListModel.value!.chatList![i].conversationId}");
            debugPrint("allChats[i].conversationId 1 $conversationID");
            blockModel.value!.isBlock == false
                ? userChatListModel.value!.chatList![i].isBlock = false
                : userChatListModel.value!.chatList![i].isBlock = true;
            userChatListModel.refresh();
          }
        }
        isBlock(false);
        showCustomToast("User blocked");
      } else {
        isBlock(false);
        showCustomToast(blockModel.value!.message!);
      }
    } catch (e) {
      print(e.toString());
    } finally {
      isBlock(false);
    }
  }
}
