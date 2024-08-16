// ignore_for_file: avoid_print, prefer_conditional_assignment, unrelated_type_equality_checks, unnecessary_null_comparison

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:meyaoo_new/Models/add_star_model.dart';
import 'package:meyaoo_new/Models/clear_all_chat_model.dart';
import 'package:meyaoo_new/Models/send_msg_model.dart';
// import 'package:meyaoo_new/controller/reply_msg_controller.dart';
import 'package:meyaoo_new/controller/user_chatlist_controller.dart';
import 'package:meyaoo_new/main.dart';
import 'package:meyaoo_new/model/chatdetails/single_chat_list_model.dart';
import 'package:meyaoo_new/src/global/api_helper.dart';
import 'package:meyaoo_new/src/global/global.dart';
import 'package:meyaoo_new/src/global/strings.dart';

final ApiHelper apiHelper = ApiHelper();

class SingleChatContorller extends GetxController {
  RxBool isSendMsg = false.obs;
  RxBool isLoading = false.obs;
  Rx<SingleChatListModel?> userdetailschattModel = SingleChatListModel().obs;
  //RxList<MessageList> chatList = <MessageList>[].obs;

  Rx<SendMsgModel?> sendMsgModel = SendMsgModel().obs;

  RxBool isStar = false.obs;
  Rx<AddStarMsgModel?> starModel = AddStarMsgModel().obs;

  RxBool isClear = false.obs;
  Rx<ClearAllChatModel?> clearChatModel = ClearAllChatModel().obs;

  // get message list
  getdetailschat(conversationID) async {
    try {
      isLoading(true);

      // Emit the initial request for messages
      socketIntilized.socket!.emit("messageReceived", {
        "conversation_id": conversationID,
        "user_timezone": Hive.box(userdata).get(utcLocaName)
      });
      print("SingleChat Emitted");

      // Remove any existing listeners to prevent duplicates
      socketIntilized.socket!.off("messageReceived");

      // Listen for messages
      socketIntilized.socket!.on("messageReceived", (data) {
        if (data['MessageList'] != null && data['MessageList'].isNotEmpty) {
          print("DATA1:::::$data");

          // If this is the initial fetch, set the message list
          if (userdetailschattModel.value == null ||
              userdetailschattModel.value!.messageList == null) {
            userdetailschattModel.value = SingleChatListModel.fromJson(data);
            // Reverse the initial message list
            userdetailschattModel.value!.messageList =
                userdetailschattModel.value!.messageList!.reversed.toList();

            // print(
            //     "DATA 1:::::${userdetailschattModel.value!.messageList![0].message}");
          } else {
            // Reverse the new messages before adding them to the existing list
            List<MessageList> reversedNewMessages = data['MessageList']
                .map<MessageList>(
                    (newMessage) => MessageList.fromJson(newMessage))
                .toList()
                .reversed
                .toList();

            // Add reversed new messages to the existing list
            userdetailschattModel.value!.messageList!
                .addAll(reversedNewMessages);
          }
          userdetailschattModel.value!.messageList!.insert(
              userdetailschattModel.value!.messageList!.length,
              MessageList.fromJson(data));
          print("MESSAGE LIST : ${userdetailschattModel.value!.messageList}");
        } else {
          print("List Emitted 222");
          print("Data2: ${userdetailschattModel.value!.messageList}");

          if (userdetailschattModel.value == null) {
            userdetailschattModel.value = SingleChatListModel(messageList: []);
          }

          if (userdetailschattModel.value!.messageList == null) {
            userdetailschattModel.value!.messageList = [];
          }

          // userdetailschattModel.value!.messageList!
          //     .add(MessageList.fromJson(data));
          // if (userdetailschattModel.value!.messageList!.first.message == null) {
          userdetailschattModel.value!.messageList!
              .insert(0, MessageList.fromJson(data));
          // }

          // print(
          // "@@@@@@@@@:${userdetailschattModel.value!.messageList!.last.message}");
        }

        isLoading(false);
        userdetailschattModel.refresh();
      });
    } catch (e) {
      log("Error ${e.toString()}");
    } finally {
      print("Finally Called");
    }
  }

  // getdetailschat(conversationID) async {
  //   try {
  //     isLoading(true);
  //     // chat emit
  //     socketIntilized.socket!.emit("messageReceived", {
  //       "conversation_id": conversationID,
  //       "user_timezone": Hive.box(userdata).get(utcLocaName)
  //     });
  //     print("SingleChat Emitted");

  //     // Listen single Chat
  //     socketIntilized.socket!.on("messageReceived", (data) {
  //       if (data['MessageList'] != null && data['MessageList'].isNotEmpty) {
  //         print("DATA1:::::$data");
  //         userdetailschattModel.value = SingleChatListModel.fromJson(data);
  //         print("MESSAGE LIST : ${userdetailschattModel.value!.messageList}");
  //       } else {
  //         print("List Emitted 222");
  //         print("Data2: $data");

  //         if (userdetailschattModel.value == null) {
  //           userdetailschattModel.value = SingleChatListModel(messageList: []);
  //         }

  //         if (userdetailschattModel.value!.messageList == null) {
  //           userdetailschattModel.value!.messageList = [];
  //         }

  //         userdetailschattModel.value!.messageList!
  //             .add(MessageList.fromJson(data));

  //         print(
  //             "@@@@@@@@@:${userdetailschattModel.value!.messageList!.last.message}");
  //       }
  //       isLoading(false);
  //       userdetailschattModel.refresh();
  //     });
  //   } catch (e) {
  //     log("Error ${e.toString()}");
  //   } finally {
  //     print("Finally Called");
  //   }
  // }

  // getdetailschat(conversationID) async {
  //   try {
  //     isLoading(true);
  //     // chat emit
  //     socketIntilized.socket!.emit("messageReceived", {
  //       "conversation_id": conversationID,
  //       "user_timezone": Hive.box(userdata).get(utcLocaName)
  //     });
  //     print("SingleChat Emitted");

  //     // Listen single Chat
  //     socketIntilized.socket!.on("messageReceived", (data) {
  //       final newMessage = MessageList.fromJson(data);
  //       //print("Received Data: $data");
  //       if (data['MessageList'] != null && data['MessageList'] != null) {
  //         print("DATA1:::::$data");
  //         print("Both data and message list are null, adding default message");
  //         // Add a default message
  //         userdetailschattModel.value = SingleChatListModel.fromJson(data);
  //         // chatList.value = userdetailschattModel.value!.messageList!;
  //         print("MESSAGE LIST : ${userdetailschattModel.value!.messageList}");
  //       } else {
  //         print("List Emitted 222");
  //         print("Data2: $data");
  //         //userdetailschattModel.value = SingleChatListModel.fromJson(data);
  //         //final repos = MessageList.fromJson(data);
  //         userdetailschattModel.value = SingleChatListModel(messageList: data['MessageList']);
  //         // userdetailschattModel.value = SingleChatListModel.fromJson(data);
  //         // chatList.value = userdetailschattModel.value!.messageList!;
  //         print(
  //             "@@@@@@@@@:${userdetailschattModel.value!.messageList!.last.message}");
  //       }
  //       isLoading(false);
  //       userdetailschattModel.refresh();
  //       // chatList.refresh();
  //     });
  //   } catch (e) {
  //     log("Error ${e.toString()}");
  //   } finally {
  //     print("Finally Called");
  //   }
  // }

  //================== send DOC message api ==================================
  sendMessageIMGDoc(conversationID, msgtype, filePath, String mobileNum,
      String forwardid, String replyid, bool isforwardUrl) async {
    print("PATH:$filePath");
    isSendMsg(true);
    var uri = Uri.parse(apiHelper.sendChatMsg);

    var request = http.MultipartRequest("POST", uri);

    Map<String, String> headers = {
      'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
      "Accept": "application/json",
    };

    //add headers
    request.headers.addAll(headers);
    //adding params
    request.fields['message_type'] = msgtype;
    request.fields['conversation_id'] = conversationID;
    request.fields['phone_number'] = mobileNum;
    request.fields['forward_id'] = forwardid;
    request.fields['reply_id'] = replyid;
    if (isforwardUrl == true) {
      request.fields['url'] = filePath;
    } else {
      request.files.add(await http.MultipartFile.fromPath('files', filePath));
    }

    // send
    var response = await request.send();

    String responseData = await response.stream.transform(utf8.decoder).join();
    var useData = json.decode(responseData);

    sendMsgModel.value = SendMsgModel.fromJson(useData);
    print("IMAGE-FILEDS: ${request.fields}");
    print(responseData);
    isSendMsg(false);
    // final respo = MessageList.fromJson(useData);
    // userdetailschattModel.value!.messageList!.add(respo);
    final newMessage = MessageList.fromJson(useData);

    if (userdetailschattModel.value?.messageList == null) {
      userdetailschattModel.value =
          SingleChatListModel(messageList: [newMessage]);
    } else {
      print("check.......");
      userdetailschattModel.value!.messageList!.insert(0, newMessage);
    }
    userdetailschattModel.refresh();
    Get.find<ChatListController>().forChatList();
    print("LLIISSTT:${userdetailschattModel.value!.messageList!.length}");
  }

  //======================= send text message api ==============================
  sendMessageText(String message, String conversationID, String msgtype,
      String mobileNum, String forwardid, String replyid) async {
    print(message);
    print(conversationID);
    print(msgtype);
    print(mobileNum);
    var uri = Uri.parse(apiHelper.sendChatMsg);
    var request = http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
      "Accept": "application/json",
    };

    //add headers
    request.headers.addAll(headers);

    //adding params
    request.fields['message'] = message;
    request.fields['message_type'] = msgtype;
    request.fields['conversation_id'] = conversationID;
    request.fields['phone_number'] = mobileNum;
    request.fields['forward_id'] = forwardid;
    request.fields['reply_id'] = replyid;

    print(request.fields);
    // send
    var response = await request.send();

    String responseData = await response.stream.transform(utf8.decoder).join();
    var useData = json.decode(responseData);

    sendMsgModel.value = SendMsgModel.fromJson(useData);
    print("object: ${request.fields}");
    print(responseData);
    final newMessage = MessageList.fromJson(useData);

    if (userdetailschattModel.value?.messageList == null) {
      userdetailschattModel.value =
          SingleChatListModel(messageList: [newMessage]);
    } else {
      print("check.......");
      userdetailschattModel.value!.messageList!.insert(0, newMessage);
    }
    userdetailschattModel.refresh();
    // final respo = MessageList.fromJson(useData);
    // userdetailschattModel.value!.messageList!.add(respo);
    Get.find<ChatListController>().forChatList();
    print("LLIISSTT:${userdetailschattModel.value!.messageList!.length}");

    // getdetailschat(conversationID);
  }

  //======================= Send Location message Api ==========================
  sendMessageLocation(String conversationID, String msgtype, String lat,
      String long, String mobileNum, String forwardid, String replyid) async {
    isSendMsg(true);
    var uri = Uri.parse(apiHelper.sendChatMsg);

    var request = http.MultipartRequest("POST", uri);

    Map<String, String> headers = {
      'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
      "Accept": "application/json",
    };

    //add headers
    request.headers.addAll(headers);

    //adding params
    request.fields['message_type'] = msgtype;
    request.fields['conversation_id'] = conversationID;
    request.fields['latitude'] = lat;
    request.fields['longitude'] = long;
    request.fields['phone_number'] = mobileNum;
    request.fields['forward_id'] = forwardid;
    request.fields['reply_id'] = replyid;
    // send
    var response = await request.send();

    String responseData = await response.stream.transform(utf8.decoder).join();
    var useData = json.decode(responseData);

    sendMsgModel.value = SendMsgModel.fromJson(useData);
    print("object: ${request.fields}");
    print(responseData);

    isSendMsg(false);
    // final respo = MessageList.fromJson(useData);
    // userdetailschattModel.value!.messageList!.add(respo);
    final newMessage = MessageList.fromJson(useData);

    if (userdetailschattModel.value?.messageList == null) {
      userdetailschattModel.value =
          SingleChatListModel(messageList: [newMessage]);
    } else {
      print("check.......");
      userdetailschattModel.value!.messageList!.insert(0, newMessage);
    }
    userdetailschattModel.refresh();
    Get.find<ChatListController>().forChatList();
    print("LLIISSTT:${userdetailschattModel.value!.messageList!.length}");
  }

  //====================== send GIF message =========================================
  sendMessageGIF(conversationID, msgtype, Uint8List? bytes, String forwardurl,
      String mobileNum, String forwardid, String replyid) async {
    isSendMsg(true);
    var uri = Uri.parse(apiHelper.sendChatMsg);

    var request = http.MultipartRequest("POST", uri);

    Map<String, String> headers = {
      'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
      "Accept": "application/json",
    };

    //add headers
    request.headers.addAll(headers);
    //adding params
    request.fields['message_type'] = msgtype;
    request.fields['conversation_id'] = conversationID;
    request.fields['phone_number'] = mobileNum;
    request.fields['forward_id'] = forwardid;
    request.fields['reply_id'] = replyid;
    request.fields['url'] = forwardurl;
    request.files.add(http.MultipartFile.fromBytes(
      'files',
      bytes!,
      filename: 'giphy.gif',
    ));

    // send
    var response = await request.send();

    String responseData = await response.stream.transform(utf8.decoder).join();
    var useData = json.decode(responseData);

    sendMsgModel.value = SendMsgModel.fromJson(useData);
    isSendMsg(false);
    print("object: ${request.fields}");
    print(responseData);

    // final respo = MessageList.fromJson(useData);
    // userdetailschattModel.value!.messageList!.add(respo);
    final newMessage = MessageList.fromJson(useData);

    if (userdetailschattModel.value?.messageList == null) {
      userdetailschattModel.value =
          SingleChatListModel(messageList: [newMessage]);
    } else {
      print("check.......");
      userdetailschattModel.value!.messageList!.insert(0, newMessage);
    }
    userdetailschattModel.refresh();
    Get.find<ChatListController>().forChatList();
    print("LLIISSTT:${userdetailschattModel.value!.messageList!.length}");
  }

//================================ send Voice message ===============================
  sendMessageVoice(
      String conversationID,
      String msgtype,
      File filePath,
      forwardurl,
      String duration,
      String mobileNum,
      String forwardid,
      String replyid) async {
    isSendMsg(true);
    var uri = Uri.parse(apiHelper.sendChatMsg);

    var request = http.MultipartRequest("POST", uri);

    Map<String, String> headers = {
      'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
      "Accept": "application/json",
    };

    //add headers
    request.headers.addAll(headers);
    //adding params
    request.fields['message_type'] = msgtype;
    request.fields['conversation_id'] = conversationID;
    request.fields['audio_time'] = duration;
    request.fields['phone_number'] = mobileNum;
    request.fields['forward_id'] = forwardid;
    request.fields['reply_id'] = replyid;

    if (filePath == File) {
      request.files
          .add(await http.MultipartFile.fromPath('files', filePath.path));
    } else {
      request.fields['url'] = forwardurl;
    }

    // send
    var response = await request.send();

    String responseData = await response.stream.transform(utf8.decoder).join();
    var useData = json.decode(responseData);

    sendMsgModel.value = SendMsgModel.fromJson(useData);
    isSendMsg(false);
    print("object: ${request.fields}");
    print(responseData);

    // final respo = MessageList.fromJson(useData);
    // userdetailschattModel.value!.messageList!.add(respo);
    if (duration != null) {
      final newMessage = MessageList.fromJson(useData);

      if (userdetailschattModel.value?.messageList == null) {
        userdetailschattModel.value =
            SingleChatListModel(messageList: [newMessage]);
      } else {
        print("check.......");
        userdetailschattModel.value!.messageList!.insert(0, newMessage);
      }
    }
    userdetailschattModel.refresh();
    Get.find<ChatListController>().forChatList();
    print("LLIISSTT:${userdetailschattModel.value!.messageList!.length}");
  }

  //================================ Send Video Message ===================================
  sendMessageVideo(conversationID, msgtype, filePath, String mobileNum,
      String forwardid, String replyid, bool isforwardUrl) async {
    print("RESPONSE:$filePath");
    isSendMsg(true);
    var uri = Uri.parse(apiHelper.sendChatMsg);

    var request = http.MultipartRequest("POST", uri);

    Map<String, String> headers = {
      'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
      "Accept": "application/json",
    };
    //add headers
    request.headers.addAll(headers);
    //adding params
    request.fields['message_type'] = msgtype;
    request.fields['conversation_id'] = conversationID;
    request.fields['phone_number'] = mobileNum;
    request.fields['forward_id'] = forwardid;
    request.fields['reply_id'] = replyid;
    if (isforwardUrl == true) {
      request.fields['url'] = filePath;
    } else {
      for (String data in filePath) {
        request.files.add(await http.MultipartFile.fromPath('files', data));
      }
    }
    print("VIDEO-FILES:${request.fields}");
    print("VIDEO-FILES:${request.files}");
    // send
    var response = await request.send();

    String responseData = await response.stream.transform(utf8.decoder).join();
    var useData = json.decode(responseData);

    sendMsgModel.value = SendMsgModel.fromJson(useData);
    isSendMsg(false);
    print("object: ${request.fields}");
    print("object: ${request.files}");
    print("RESPONSE: $responseData");

    // final respo = MessageList.fromJson(useData);
    // userdetailschattModel.value!.messageList!.add(respo);
    final newMessage = MessageList.fromJson(useData);

    if (userdetailschattModel.value?.messageList == null) {
      userdetailschattModel.value =
          SingleChatListModel(messageList: [newMessage]);
    } else {
      print("check.......");
      userdetailschattModel.value!.messageList!.insert(0, newMessage);
    }
    userdetailschattModel.refresh();
    Get.find<ChatListController>().forChatList();
    print("LLIISSTT:${userdetailschattModel.value!.messageList!.length}");
  }

  //========================= send contact message ==============================
  sendMessageContact(conversationID, msgtype, contactName, contactNumber,
      String mobileNum, image, String forwardid, String replyid) async {
    var uri = Uri.parse(apiHelper.sendChatMsg);

    var request = http.MultipartRequest("POST", uri);

    Map<String, String> headers = {
      'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
      "Accept": "application/json",
    };
    //add headers
    request.headers.addAll(headers);
    //adding params
    request.fields['message_type'] = msgtype;
    request.fields['conversation_id'] = conversationID;
    request.fields['shared_contact_name'] = contactName;
    request.fields['shared_contact_number'] = contactNumber;
    request.fields['shared_contact_profile_image'] = image;
    request.fields['phone_number'] = mobileNum;
    request.fields['forward_id'] = forwardid;
    request.fields['reply_id'] = replyid;

    // send
    var response = await request.send();

    String responseData = await response.stream.transform(utf8.decoder).join();
    var useData = json.decode(responseData);

    sendMsgModel.value = SendMsgModel.fromJson(useData);
    Get.back();
    print("object: ${request.fields}");
    print("object: ${request.files}");
    print("RESPONSE: $responseData");

    // final respo = MessageList.fromJson(useData);
    // userdetailschattModel.value!.messageList!.add(respo);
    final newMessage = MessageList.fromJson(useData);

    if (userdetailschattModel.value?.messageList == null) {
      userdetailschattModel.value =
          SingleChatListModel(messageList: [newMessage]);
    } else {
      print("check.......");
      userdetailschattModel.value!.messageList!.insert(0, newMessage);
    }
    userdetailschattModel.refresh();
    Get.find<ChatListController>().forChatList();
    print("LLIISSTT:${userdetailschattModel.value!.messageList!.length}");
  }

  deleteChatApi(chatID, bool deleteFrom, String mobileNum) async {
    isSendMsg(true);
    var uri = Uri.parse(apiHelper.deleteChatMsg);

    var request = http.MultipartRequest("POST", uri);

    Map<String, String> headers = {
      'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
      "Accept": "application/json",
    };

    //add headers
    request.headers.addAll(headers);
    //adding params
    request.fields['message_id_list'] = chatID
        .toString()
        .replaceAll('[', '')
        .replaceAll(']', '')
        .removeAllWhitespace;
    request.fields['delete_from_every_one'] = deleteFrom.toString();
    request.fields['phone_number'] = mobileNum;

    // send
    var response = await request.send();

    String responseData = await response.stream.transform(utf8.decoder).join();
    var useData = json.decode(responseData);

    isSendMsg(false);
    print("object: ${request.fields}");
    print("object: $useData");
    print(responseData);

    userdetailschattModel.value!.messageList!
        .removeWhere((message) => chatID.contains(message.messageId));

    userdetailschattModel.refresh();
    Get.find<ChatListController>().forChatList();
    print("LLIISSTT:${userdetailschattModel.value!.messageList!.length}");
  }

  addStarApi(chatID) async {
    print(chatID);
    isStar(true);
    try {
      var uri = Uri.parse(apiHelper.addStar);
      var request = http.MultipartRequest("POST", uri);
      Map<String, String> headers = {
        'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
        "Accept": "application/json",
      };

      //add headers
      request.headers.addAll(headers);
      request.fields['message_id'] = chatID;
      var response = await request.send();
      print("chatid:${request.fields}");

      String responseData =
          await response.stream.transform(utf8.decoder).join();
      var useData = json.decode(responseData);

      starModel.value = AddStarMsgModel.fromJson(useData);

      if (starModel.value!.success == true) {
        for (var i = 0;
            i < userdetailschattModel.value!.messageList!.length;
            i++) {
          debugPrint(
              "chatList[i].messageId ${userdetailschattModel.value!.messageList![i].messageId}");
          debugPrint("chatList[i].chatID $chatID");
          if (userdetailschattModel.value!.messageList![i].messageId
                  .toString() ==
              chatID.toString()) {
            debugPrint(
                "chatList[i].messageId 1 ${userdetailschattModel.value!.messageList![i].messageId}");
            debugPrint("chatList[i].chatID 1 $chatID");
            userdetailschattModel.value!.messageList![i].isStarMessage =
                true; // Update message's star status
            userdetailschattModel.refresh();
            //chatList.refresh();
          }
        }
        isStar(false);
        // Find and update message list
        // chatList.firstWhere(
        //   (msg) {
        //     if (msg.messageId == chatID) {
        //       msg.isStarMessage = true; // Update message's star status
        //       chatList.refresh();
        //     }
        //   },
        //   orElse: () => MessageList(), // Return a default MessageList object
        // );
        // if (message != null) {}
        Get.find<ChatListController>().forChatList();
        showCustomToast(starModel.value!.message!);
      } else {
        isStar(false);
      }
    } catch (e) {
      isStar(false);
      showCustomToast(e.toString());
    } finally {
      isStar(false);
    }
  }

  removeStarApi(chatID) async {
    print(chatID);
    isStar(true);
    try {
      var uri = Uri.parse(apiHelper.addStar);
      var request = http.MultipartRequest("POST", uri);
      Map<String, String> headers = {
        'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
        "Accept": "application/json",
      };

      //add headers
      request.headers.addAll(headers);
      request.fields['message_id'] = chatID;
      request.fields['remove_from_star'] = true.toString();
      var response = await request.send();

      String responseData =
          await response.stream.transform(utf8.decoder).join();
      var useData = json.decode(responseData);

      starModel.value = AddStarMsgModel.fromJson(useData);

      if (starModel.value!.success == true) {
        for (var i = 0;
            i < userdetailschattModel.value!.messageList!.length;
            i++) {
          debugPrint(
              "chatList[i].messageId ${userdetailschattModel.value!.messageList![i].messageId}");
          debugPrint("chatList[i].chatID $chatID");
          if (userdetailschattModel.value!.messageList![i].messageId
                  .toString() ==
              chatID.toString()) {
            debugPrint(
                "chatList[i].messageId 1 ${userdetailschattModel.value!.messageList![i].messageId}");
            debugPrint("chatList[i].chatID 1 $chatID");
            userdetailschattModel.value!.messageList![i].isStarMessage =
                false; // Update message's star status
            userdetailschattModel.refresh();
            // chatList.refresh();
          }
        }
        isStar(false);
        userdetailschattModel.refresh();
        Get.find<ChatListController>().forChatList();
        showCustomToast(starModel.value!.message!);
      } else {
        isStar(false);
      }
    } catch (e) {
      print(e.toString());
      showCustomToast(e.toString());
      isStar(false);
    } finally {
      isStar(false);
    }
  }

  clearAllChatApi(
      {required String conversationid, required String messageID}) async {
    isClear(true);
    try {
      var uri = Uri.parse(apiHelper.clearChatUrl);
      var request = http.MultipartRequest("POST", uri);
      Map<String, String> headers = {
        'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
        "Accept": "application/json",
      };

      //add headers
      request.headers.addAll(headers);
      request.fields['conversation_id'] = conversationid;
      request.fields['message_id'] = messageID;

      var response = await request.send();

      String responseData =
          await response.stream.transform(utf8.decoder).join();
      var useData = json.decode(responseData);

      clearChatModel.value = ClearAllChatModel.fromJson(useData);

      if (clearChatModel.value!.success == true) {
        userdetailschattModel.refresh();
        isClear(false);
        showCustomToast("Clear all chat");
      } else {
        isClear(false);
        showCustomToast(clearChatModel.value!.message!);
      }
    } catch (e) {
      isClear(false);
      print(e.toString());
    } finally {
      isClear(false);
    }
  }

  isTypingApi(cID, istyping) {
    print("IS_TYPING_CONVERSATION:$cID");
    print("IS-TYPING:$istyping");
    socketIntilized.socket!.emit("isTyping",
        {"conversation_id": cID.toString(), "is_typing": istyping.toString()});
    userdetailschattModel.refresh();
    print("isTyping Emitted");
  }

  @override
  void onClose() {
    super.onClose();
    userdetailschattModel.value?.messageList?.clear();
    userdetailschattModel.value = null;
  }
}
