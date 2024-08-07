// ignore_for_file: avoid_print, unused_field, must_be_immutable

import 'dart:convert';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:meyaoo_new/controller/user_chatlist_controller.dart';
import 'package:meyaoo_new/src/global/global.dart';
import 'package:meyaoo_new/src/screens/layout/bottombar.dart';
import 'package:meyaoo_new/src/global/strings.dart';
import 'package:meyaoo_new/model/userchatlist_model/userchatlist_model.dart';

class ForwardMessage extends StatefulWidget {
  String chatid;
  bool isMsgType;

  ForwardMessage({super.key, required this.chatid, required this.isMsgType});

  @override
  State<ForwardMessage> createState() => _ForwardMessageState();
}

class _ForwardMessageState extends State<ForwardMessage> {
  ChatListController chatListController = Get.find();
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  bool isview = false;
  TextEditingController controller = TextEditingController();
  List<String> isSelectedusername = [];

  @override
  void initState() {
    super.initState();
    print("chat_ID:${widget.chatid}");
  }

  bool isLoading = false;
  sendfrowardmessage() async {
    setState(() {
      isLoading = true;
    });
    var uri = Uri.parse('${baseUrl()}GroupForwardMsg');
    var request = http.MultipartRequest("POST", uri);

    request.fields['from_user'] = Hive.box(userdata).get(userId);
    request.fields['to_user'] = forwardmessageuser
        .toString()
        .replaceAll('[', '')
        .replaceAll(']', '')
        .removeAllWhitespace;
    request.fields['group_id'] = groupUSERID
        .toString()
        .replaceAll('[', '')
        .replaceAll(']', '')
        .removeAllWhitespace;
    request.fields['chat_id'] = widget.chatid;

    var response = await request.send();

    String responseData = await response.stream.transform(utf8.decoder).join();
    print("SINGLE::::::::${request.fields}");
    log(responseData);
    if (response.statusCode == 200) {
      // ignore: use_build_context_synchronously
      // Navigator.pop(context);
      setState(() {
        isLoading = false;
        isForward = true;
      });
      Get.off(() => TabbarScreen());
    }
    setState(() {
      isLoading = false;
    });
  }

  sendfrowardmessageGroup() async {
    setState(() {
      isLoading = true;
    });
    var uri = Uri.parse('${baseUrl()}GroupForwardMsg');
    var request = http.MultipartRequest("POST", uri);

    request.fields['from_user'] = Hive.box(userdata).get(userId);
    request.fields['to_user'] = forwardmessageuser
        .toString()
        .replaceAll('[', '')
        .replaceAll(']', '')
        .removeAllWhitespace;
    request.fields['group_id'] = groupUSERID
        .toString()
        .replaceAll('[', '')
        .replaceAll(']', '')
        .removeAllWhitespace;
    request.fields['group_chat_id'] = widget.chatid;

    var response = await request.send();

    String responseData = await response.stream.transform(utf8.decoder).join();
    print("::::::::${request.fields}");
    log(responseData);
    if (response.statusCode == 200) {
      // ignore: use_build_context_synchronously
      // Navigator.pop(context);
      setState(() {
        isLoading = false;
        isForward = true;
      });
      Get.off(() => TabbarScreen());
    }
    setState(() {
      isLoading = false;
    });
  }

  List forwardmessageuser = [];
  List groupUSERID = [];

  String username = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        height: 70,
        color: chatownColor,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(0),
            topLeft: Radius.circular(0),
          ),
          child: BottomAppBar(
            color: chatownColor,
            elevation: 0,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(0), color: chatownColor),
              child: Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 20,

                      // width: 0.5,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.63,
                            height: 40,
                            child: ListView.builder(
                                itemCount: isSelectedusername.length,
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return Text(
                                      capitalizeFirstLetter(isSelectedusername[
                                              index] +
                                          (index ==
                                                  isSelectedusername.length - 1
                                              ? ""
                                              : ", ")),
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black));
                                }),
                          ),
                        ],
                      ),
                    ),
                    isLoading
                        ? loader(context)
                        : InkWell(
                            onTap: () {
                              if (widget.isMsgType == true) {
                                forwardmessageuser.isNotEmpty ||
                                        groupUSERID.isNotEmpty
                                    ? sendfrowardmessage()
                                    : Fluttertoast.showToast(
                                        msg:
                                            "Please select whom you want to send message");
                              } else {
                                forwardmessageuser.isNotEmpty ||
                                        groupUSERID.isNotEmpty
                                    ? sendfrowardmessageGroup()
                                    : Fluttertoast.showToast(
                                        msg:
                                            "Please select whom you want to send message");
                              }
                            },
                            child: Container(
                              height: 35,
                              width: 85,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: const Color(0xffF4F5F6)),
                              child: const Center(
                                child: Text(
                                  'Forward',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  appBarWidget(context),
                  chatWidget(context),
                  // searchBarWidget(context),
                  Expanded(
                      child: SingleChildScrollView(child: chatListScreen()))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget chatListScreen() {
    return Container(
        height: MediaQuery.of(context).size.height * 0.9,
        width: MediaQuery.of(context).size.width,
        color: appColorWhite,
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount:
              chatListController.userChatListModel.value!.chatList!.length,
          itemBuilder: (context, index) {
            List<ChatList> chatlist =
                chatListController.userChatListModel.value!.chatList!;

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: InkWell(
                onTap: () {
                  setState(() {
                    isSelectedusername.contains(chatlist[index].userName) ||
                            isSelectedusername
                                .contains(chatlist[index].groupName)
                        ? isSelectedusername.remove(
                            chatlist[index].userName.toString().isEmpty
                                ? chatlist[index].groupName.toString()
                                : chatlist[index].userName.toString())
                        : isSelectedusername.add(
                            chatlist[index].userName.toString().isEmpty
                                ? chatlist[index].groupName.toString()
                                : chatlist[index].userName.toString());
                    //_________________________________________________________________________
                    if (chatlist[index].conversationId != null) {
                      forwardmessageuser
                              .contains(chatlist[index].conversationId)
                          ? forwardmessageuser
                              .remove(chatlist[index].conversationId)
                          : forwardmessageuser
                              .add(chatlist[index].conversationId!);
                      print("TO_USERS:$forwardmessageuser");
                    }
                  });
                  print("USERNAME:$isSelectedusername");
                },
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey,
                        width: 0.5,
                      ),
                    ),
                  ),
                  height: 75,
                  width: MediaQuery.of(context).size.width * 0.90,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(
                        width: 0,
                      ),
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: chatlist[index].profileImage != ""
                              ? CustomCachedNetworkImage(
                                  imageUrl: chatlist[index].profileImage!,
                                  placeholderColor: chatownColor,
                                  errorWidgeticon: const Icon(
                                    Icons.person,
                                    size: 25,
                                  ))
                              : CustomCachedNetworkImage(
                                  imageUrl: chatlist[index].groupProfileImage!,
                                  placeholderColor: chatownColor,
                                  errorWidgeticon: const Icon(
                                    Icons.groups_2,
                                    size: 30,
                                  )),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.60,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 28,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                chatlist[index].userName.toString().isEmpty
                                    ? Text(
                                        capitalizeFirstLetter(
                                            '${chatlist[index].groupName}'),
                                        textAlign: TextAlign.left,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16),
                                      )
                                    : Text(
                                        capitalizeFirstLetter(
                                            chatlist[index].userName!),
                                        textAlign: TextAlign.left,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16),
                                      ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Column(
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      isSelectedusername.contains(chatlist[index].userName) ||
                              isSelectedusername
                                  .contains(chatlist[index].groupName)
                          ? Container(
                              width: 20.0,
                              height: 20.0,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(color: bg1),
                                  color: bg1),
                              child: const Icon(
                                Icons.check,
                                size: 15.0,
                                color: Colors.black,
                              ))
                          : Container(
                              width: 20.0,
                              height: 20.0,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(color: bg1),
                                  color: bg1),
                            ),
                    ],
                  ),
                ),
              ),
            );
          },
        ));
  }

  AppBar appBarWidget(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 5),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              height: 35,
              width: 85,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: const Color(0xffF4F5F6)),
              child: const Center(
                child: Text(
                  'Cancel',
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: Colors.black),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 70,
          ),
          const Text(
            'Send to',
            style: TextStyle(
                fontWeight: FontWeight.w400, fontSize: 16, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget chatWidget(BuildContext context) {
    return Container(
      color: Colors.white,
      child: const Padding(
        padding: EdgeInsets.only(left: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RECENT CHATS',
              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  String convertUTCTimeTo12HourFormat(String utcTimeString) {
    DateTime utcDate = DateTime.parse(utcTimeString);
    String formattedTime = DateFormat('h:mm a').format(utcDate.toLocal());
    return formattedTime;
  }
}
