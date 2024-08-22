// ignore_for_file: avoid_print, must_be_immutable, prefer_is_empty
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:lecle_flutter_link_preview/lecle_flutter_link_preview.dart';
import 'package:meyaoo_new/Models/add_star_model.dart';
import 'package:meyaoo_new/Models/all_starred_msg_list.dart';
import 'package:meyaoo_new/controller/all_star_msg_controller.dart';
import 'package:meyaoo_new/controller/audio_controller.dart';
import 'package:meyaoo_new/controller/reply_msg_controller.dart';
import 'package:meyaoo_new/controller/user_chatlist_controller.dart';
import 'package:meyaoo_new/src/global/api_helper.dart';
import 'package:meyaoo_new/src/global/global.dart';
import 'package:meyaoo_new/src/global/pdf.dart';
import 'package:meyaoo_new/src/global/strings.dart';
import 'package:meyaoo_new/src/screens/Onlichat/ChatOnline.dart';
import 'package:meyaoo_new/src/screens/chat/FileView.dart';
import 'package:meyaoo_new/src/screens/chat/chatvideo.dart';
import 'package:meyaoo_new/src/screens/chat/group_chat_temp.dart';
import 'package:meyaoo_new/src/screens/chat/imageView.dart';
import 'package:meyaoo_new/src/screens/chat/single_chat.dart';
import 'package:page_transition/page_transition.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:http/http.dart' as http;

final ApiHelper apiHelper = ApiHelper();

class AllStarredMsgList extends StatefulWidget {
  int? index;
  String? conversationid;
  bool? isPersonal;
  AllStarredMsgList(
      {super.key, this.index, this.conversationid, this.isPersonal});

  @override
  State<AllStarredMsgList> createState() => _AllStarredMsgListState();
}

class _AllStarredMsgListState extends State<AllStarredMsgList> {
  AllStaredMsgController allStaredMsgController = Get.find();
  AudioPlayer audioPlayer = AudioPlayer();
  AudioController audioController = Get.put(AudioController());
  ChatListController chatListController = Get.find();
  ReplyMsgController replyMsgController = Get.put(ReplyMsgController());

  @override
  void initState() {
    allStaredMsgController.getAllStarMsg(widget.conversationid);
    chatListController.forChatList();
    initlizedcontroller();
    super.initState();
  }

  bool isScroll = true;
  final scrollDirection = Axis.vertical;
  int? gotoindex;
  AutoScrollController? listScrollController;
  List<List<int>>? randomList;

  _scrollToIndex(index, {Function? callback}) async {
    await listScrollController?.scrollToIndex(index,
        preferPosition: AutoScrollPosition.begin);
    if (callback != null) {
      callback();
    }
  }

  initlizedcontroller() async {
    listScrollController = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: scrollDirection);
    listScrollController?.addListener(hideKeyboard);
    if (widget.index != null && widget.index != 0) {
      await listScrollController?.scrollToIndex(widget.index!,
          preferPosition: AutoScrollPosition.begin);
    }
  }

  hideKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  List chatID = [];
  String isSelectedmessage = "0";
  String localmsgid = "";
  List starId = [];

  String isIdMatch(String id) {
    for (var i = 0;
        i < chatListController.userChatListModel.value!.chatList!.length;
        i++) {
      if (id ==
          chatListController
              .userChatListModel.value!.chatList![i].conversationId
              .toString()) {
        return chatListController.userChatListModel.value!.chatList![i].userName
            .toString();
      }
    }
    return "";
  }

  String isPicMatch(String id) {
    for (var i = 0;
        i < chatListController.userChatListModel.value!.chatList!.length;
        i++) {
      if (id ==
          chatListController
              .userChatListModel.value!.chatList![i].conversationId
              .toString()) {
        return chatListController
            .userChatListModel.value!.chatList![i].profileImage
            .toString();
      }
    }
    return "";
  }

  bool isBlockMatch(String id) {
    for (var i = 0;
        i < chatListController.userChatListModel.value!.chatList!.length;
        i++) {
      if (id ==
          chatListController
              .userChatListModel.value!.chatList![i].conversationId
              .toString()) {
        return chatListController
            .userChatListModel.value!.chatList![i].isBlock!;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromRGBO(250, 250, 250, 1),
        appBar: AppBar(
          shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.grey.shade300)),
          scrolledUnderElevation: 0,
          backgroundColor: Colors.white,
          elevation: 0,
          leadingWidth: 50,
          titleSpacing: -10,
          leading: InkWell(
            onTap: () {
              Get.back();
            },
            child: const Icon(Icons.arrow_back_ios, size: 20, color: chatColor),
          ),
          title: Text(
            widget.isPersonal == true ? "Starred Messages" : 'Starred Messages',
            style: const TextStyle(
                fontWeight: FontWeight.w500, fontSize: 19, color: chatColor),
          ),
          actions: [
            containerWidget(
                    onTap: () {
                      setState(() {
                        isSelectedmessage = "1";
                        starId.add(0);
                      });
                    },
                    title: "Edit")
                .paddingOnly(right: 10)
          ],
        ),
        bottomNavigationBar: starId.isEmpty
            ? null
            : BottomAppBar(
                height: 70,
                elevation: 0,
                color: Colors.white,
                child: Row(
                  children: [
                    InkWell(
                        onTap: () {
                          setState(() {
                            isSelectedmessage = "0";
                            starId = [];
                          });
                        },
                        child: Image.asset("assets/images/star-slash.png",
                            height: 25))
                  ],
                ),
              ),
        body: Obx(() {
          return allStaredMsgController.isLoading.value &&
                  allStaredMsgController.allStarred.isEmpty
              ? loader(context)
              : Column(
                  children: [
                    Flexible(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: allStaredMsgController.allStarred.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 25),
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: MediaQuery.sizeOf(context)
                                                  .height *
                                              0.3,
                                        ),
                                        Image.asset(
                                            "assets/images/starfill.png",
                                            color: chatColor,
                                            height: 28),
                                        const SizedBox(height: 25),
                                        const Text(
                                          "No starred Messages",
                                          style: TextStyle(
                                              color: chatColor,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        const SizedBox(height: 10),
                                        const Text(
                                          "Tap and hold on any message to star it, so you can easily find it later.",
                                          textAlign: TextAlign.center,
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              : ListView(children: [
                                  ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.vertical,
                                    controller: listScrollController,
                                    // physics:
                                    //     const BouncingScrollPhysics(),
                                    itemCount: allStaredMsgController
                                        .allStarred.length,
                                    itemBuilder: (context, index) {
                                      for (int i = 0;
                                          i <
                                              allStaredMsgController
                                                  .allStarred.length;
                                          i++) {
                                        if (isScroll == true) {
                                          gotoindex = i;
                                          _scrollToIndex(gotoindex);
                                          isScroll = false;
                                        }
                                      }

                                      return AutoScrollTag(
                                          key: ValueKey(index),
                                          controller: listScrollController!,
                                          index: index,
                                          child: buildItem(
                                              index,
                                              allStaredMsgController
                                                  .allStarred[index]));
                                    },
                                  ),
                                ]),
                        ),
                      ),
                    )
                  ],
                );
        }));
  }

  Widget buildItem(int index, StarMessageList data) {
    switch (data.chat!.messageType) {
      case 'text':
        return data.chat!.replyId == 0
            ? getTextMessageWidget(index, data)
            : getReplyMessage(index, data);
      case 'image':
        return data.chat!.replyId == 0
            ? getImgMessageWidget(index, data)
            : getReplyMessage(index, data);
      case 'location':
        return data.chat!.replyId == 0
            ? getLocationMessageWidget(index, data)
            : getReplyMessage(index, data);
      case 'video':
        return data.chat!.replyId == 0
            ? getVideoMessageWidget(index, data)
            : getReplyMessage(index, data);
      case 'document':
        return data.chat!.replyId == 0
            ? getDocMessageWidget(index, data)
            : getReplyMessage(index, data);
      case 'audio':
        return data.chat!.replyId == 0
            ? getVoiceMessageWidget(index, data)
            : getReplyMessage(index, data);
      case 'gif':
        return data.chat!.replyId == 0
            ? getGifMessage(index, data)
            : getReplyMessage(index, data);
      case 'link':
        return data.chat!.replyId == 0
            ? getHttpLinkMessage(index, data)
            : getReplyMessage(index, data);
      case 'contact':
        return data.chat!.replyId == 0
            ? getContactMessage(index, data)
            : getReplyMessage(index, data);
      // case 'date':
      //   return getDateWidget(index, data);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget getTextMessageWidget(index, StarMessageList data) {
    return InkWell(
      onTap: () {
        if (isSelectedmessage == "1") {
          setState(() {
            starId.contains(data.chat!.messageId.toString())
                ? starId.remove(data.chat!.messageId.toString())
                : starId.add(data.chat!.messageId.toString());
          });
        } else {
          data.chat!.conversation!.isGroup == false
              ? Get.to(() => SingleChatMsg(
                  conversationID: data.chat!.conversationId.toString(),
                  username: isIdMatch(data.chat!.conversationId.toString()),
                  userPic: isPicMatch(data.chat!.conversationId.toString()),
                  index: 0,
                  searchText: "",
                  searchTime: "",
                  mobileNum: "",
                  isBlock: isBlockMatch(data.chat!.conversationId.toString()),
                  messageId: data.chat!.messageId.toString(),
                  isMsgHighLight: true,
                  userID: data.otherUserId.toString()))
              : Get.to(() => GroupChatMsg(
                    conversationID:
                        data.chat!.conversation!.conversationId.toString(),
                    gPusername: data.chat!.conversation!.groupName,
                    gPPic: data.chat!.conversation!.groupProfileImage,
                    index: 0,
                    searchText: "",
                    searchTime: "",
                    messageid: data.chat!.messageId.toString(),
                    isMsgHighLight: true,
                  ));
        }
      },
      child: Container(
        color: const Color(0xffFFFFFF),
        decoration: BoxDecoration(),
        child: Stack(
          children: [
            isSelectedmessage == "1"
                ? Positioned(
                    left: 10,
                    top: 60,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          starId.contains(data.chat!.messageId)
                              ? starId.remove(data.chat!.messageId)
                              : starId.add(data.chat!.messageId);
                        });
                        print("STARID:$starId");
                      },
                      child: starId.length == 0
                          ? const SizedBox()
                          : Transform.scale(
                              scale: 1.1,
                              child: starId
                                      .contains(data.chat!.messageId.toString())
                                  ? checkContainer()
                                  : removeCheckContainer(),
                            ),
                    ),
                  )
                : const SizedBox.shrink(),
            Padding(
              padding: EdgeInsets.only(
                  top: 5,
                  bottom: 5,
                  left: starId.isNotEmpty ? 34 : 28,
                  right: 28),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            data.chat!.user!.userId ==
                                    Hive.box(userdata).get(userId)
                                ? "You"
                                : data.chat!.user!.firstName! +
                                    data.chat!.user!.lastName!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                          ),
                          const Icon(Icons.arrow_right_rounded, size: 30),
                          data.chat!.conversation!.isGroup == false
                              ? Text(
                                  data.otherUserDetails![0].userId ==
                                          data.chat!.user!.userId
                                      ? "You"
                                      : data.otherUserDetails![0].firstName! +
                                          data.otherUserDetails![0].lastName!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 11,
                                  ),
                                )
                              : Text(
                                  data.chat!.conversation!.groupName!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 11,
                                  ),
                                ),
                        ],
                      ),
                      Text(
                        date(convertToLocalDate(data.updatedAt!)),
                        style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade500),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: data.chat!.user!.userId ==
                                      Hive.box(userdata).get(userId)
                                  ? null
                                  : Colors.grey.shade200,
                              gradient: data.chat!.user!.userId ==
                                      Hive.box(userdata).get(userId)
                                  ? LinearGradient(
                                      colors: [yellow1Color, yellow2Color],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter)
                                  : null),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 10,
                              ),
                              child: Container(
                                constraints: const BoxConstraints(
                                  minHeight: 20.0,
                                  minWidth: 10.0,
                                  maxWidth: 230,
                                ),
                                child: Text(
                                  data.chat!.message.toString(),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 15,
                        color: Colors.grey.shade500,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        convertUTCTimeTo12HourFormat(data.createdAt!),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
          ],
        ),
      ),
    ).paddingOnly(bottom: 10);
  }

  Widget getImgMessageWidget(index, StarMessageList data) {
    return InkWell(
      onTap: () {
        if (isSelectedmessage == "1") {
          setState(() {
            starId.contains(data.chat!.messageId.toString())
                ? starId.remove(data.chat!.messageId.toString())
                : starId.add(data.chat!.messageId.toString());
          });
        } else {
          data.chat!.conversation!.isGroup == false
              ? Get.to(() => SingleChatMsg(
                  conversationID: data.chat!.conversationId.toString(),
                  username: isIdMatch(data.chat!.conversationId.toString()),
                  userPic: isPicMatch(data.chat!.conversationId.toString()),
                  index: 0,
                  searchText: "",
                  searchTime: "",
                  mobileNum: "",
                  isBlock: isBlockMatch(data.chat!.conversationId.toString()),
                  messageId: data.chat!.messageId.toString(),
                  isMsgHighLight: true,
                  userID: data.otherUserId.toString()))
              : Get.to(() => GroupChatMsg(
                    conversationID:
                        data.chat!.conversation!.conversationId.toString(),
                    gPusername: data.chat!.conversation!.groupName,
                    gPPic: data.chat!.conversation!.groupProfileImage,
                    index: 0,
                    searchText: "",
                    searchTime: "",
                    messageid: data.chat!.messageId.toString(),
                    isMsgHighLight: true,
                  ));
        }
      },
      child: Container(
        color: const Color(0xffFFFFFF),
        child: Stack(
          children: [
            isSelectedmessage == "1"
                ? Positioned(
                    left: 10,
                    top: 95,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          starId.contains(data.chat!.messageId.toString())
                              ? starId.remove(data.chat!.messageId.toString())
                              : starId.add(data.chat!.messageId.toString());
                        });
                        print("STARID:$starId");
                      },
                      child: starId.length == 0
                          ? const SizedBox()
                          : Transform.scale(
                              scale: 1.1,
                              child: starId
                                      .contains(data.chat!.messageId.toString())
                                  ? checkContainer()
                                  : removeCheckContainer(),
                            ),
                    ),
                  )
                : const SizedBox.shrink(),
            Padding(
              padding: EdgeInsets.only(
                  top: 5,
                  bottom: 5,
                  left: starId.isNotEmpty ? 34 : 28,
                  right: 28),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            data.chat!.user!.userId ==
                                    Hive.box(userdata).get(userId)
                                ? "You"
                                : data.chat!.user!.firstName! +
                                    data.chat!.user!.lastName!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                          ),
                          const Icon(Icons.arrow_right_rounded, size: 30),
                          data.chat!.conversation!.isGroup == false
                              ? Text(
                                  data.otherUserDetails![0].userId ==
                                          data.chat!.user!.userId
                                      ? "You"
                                      : data.otherUserDetails![0].firstName! +
                                          data.otherUserDetails![0].lastName!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 11,
                                  ),
                                )
                              : Text(
                                  data.chat!.conversation!.groupName!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 11,
                                  ),
                                ),
                        ],
                      ),
                      Text(
                        date(convertToLocalDate(data.updatedAt!)),
                        style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade500),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                  curve: Curves.linear,
                                  type: PageTransitionType.rightToLeft,
                                  child: ImageView(
                                    image: data.chat!.url!,
                                    userimg: "",
                                  )),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: data.chat!.user!.userId ==
                                      Hive.box(userdata).get(userId)
                                  ? yellow1Color
                                  : Colors.grey.shade200,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Container(
                                  height: 120,
                                  width: 120,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10)),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      data.chat!.url!,
                                      fit: BoxFit.cover,
                                    ),
                                  )),
                            ),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 15,
                        color: Colors.grey.shade500,
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        convertUTCTimeTo12HourFormat(data.createdAt!),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
          ],
        ),
      ),
    ).paddingOnly(bottom: 10);
  }

  Widget getLocationMessageWidget(index, StarMessageList data) {
    return InkWell(
      onTap: () {
        if (isSelectedmessage == "1") {
          setState(() {
            starId.contains(data.chat!.messageId.toString())
                ? starId.remove(data.chat!.messageId.toString())
                : starId.add(data.chat!.messageId.toString());
          });
        } else {
          data.chat!.conversation!.isGroup == false
              ? Get.to(() => SingleChatMsg(
                  conversationID: data.chat!.conversationId.toString(),
                  username: isIdMatch(data.chat!.conversationId.toString()),
                  userPic: isPicMatch(data.chat!.conversationId.toString()),
                  index: 0,
                  searchText: "",
                  searchTime: "",
                  mobileNum: "",
                  isBlock: isBlockMatch(data.chat!.conversationId.toString()),
                  messageId: data.chat!.messageId.toString(),
                  isMsgHighLight: true,
                  userID: data.otherUserId.toString()))
              : Get.to(() => GroupChatMsg(
                    conversationID:
                        data.chat!.conversation!.conversationId.toString(),
                    gPusername: data.chat!.conversation!.groupName,
                    gPPic: data.chat!.conversation!.groupProfileImage,
                    index: 0,
                    searchText: "",
                    searchTime: "",
                    messageid: data.chat!.messageId.toString(),
                    isMsgHighLight: true,
                  ));
        }
      },
      child: Container(
        color: const Color(0xffFFFFFF),
        child: Stack(
          children: [
            isSelectedmessage == "1"
                ? Positioned(
                    left: 10,
                    top: 105,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          starId.contains(data.chat!.messageId.toString())
                              ? starId.remove(data.chat!.messageId.toString())
                              : starId.add(data.chat!.messageId.toString());
                        });
                        print("STARID:$starId");
                      },
                      child: starId.length == 0
                          ? const SizedBox()
                          : Transform.scale(
                              scale: 1.1,
                              child: starId
                                      .contains(data.chat!.messageId.toString())
                                  ? checkContainer()
                                  : removeCheckContainer(),
                            ),
                    ),
                  )
                : const SizedBox.shrink(),
            Padding(
              padding: EdgeInsets.only(
                  top: 5,
                  bottom: 5,
                  left: starId.isNotEmpty ? 34 : 28,
                  right: 28),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            data.chat!.user!.userId ==
                                    Hive.box(userdata).get(userId)
                                ? "You"
                                : data.chat!.user!.firstName! +
                                    data.chat!.user!.lastName!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                          ),
                          const Icon(Icons.arrow_right_rounded, size: 30),
                          data.chat!.conversation!.isGroup == false
                              ? Text(
                                  data.otherUserDetails![0].userId ==
                                          data.chat!.user!.userId
                                      ? "You"
                                      : data.otherUserDetails![0].firstName! +
                                          data.otherUserDetails![0].lastName!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 11,
                                  ),
                                )
                              : Text(
                                  data.chat!.conversation!.groupName!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 11,
                                  ),
                                ),
                        ],
                      ),
                      Text(
                        date(convertToLocalDate(data.updatedAt!)),
                        style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade500),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: data.chat!.user!.userId ==
                                    Hive.box(userdata).get(userId)
                                ? yellow1Color
                                : Colors.grey.shade200,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                constraints: const BoxConstraints(
                                    minHeight: 10.0,
                                    minWidth: 10.0,
                                    maxWidth: 250),
                                child: InkWell(
                                  onTap: () {
                                    MapUtils.openMap(
                                        double.parse(data.chat!.latitude!),
                                        double.parse(data.chat!.longitude!));
                                  },
                                  child: Container(
                                    height: 130,
                                    width: 250,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: data.chat!.latitude.toString() ==
                                                  "" ||
                                              data.chat!.longitude.toString() ==
                                                  ""
                                          ? Container(
                                              decoration: const BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  10),
                                                          topRight:
                                                              Radius.circular(
                                                                  10)),
                                                  image: DecorationImage(
                                                      image: AssetImage(
                                                          "assets/images/map_Blurr.png"),
                                                      fit: BoxFit.cover)),
                                              child: Icon(
                                                Icons.error_outline,
                                                color: chatownColor
                                                    .withOpacity(0.6),
                                                size: 50,
                                              ),
                                            )
                                          : GoogleMap(
                                              zoomControlsEnabled: false,
                                              zoomGesturesEnabled: false,
                                              initialCameraPosition:
                                                  CameraPosition(
                                                      target: LatLng(
                                                          double.parse(data
                                                              .chat!.latitude!),
                                                          double.parse(data
                                                              .chat!
                                                              .longitude!)),
                                                      zoom: 15),
                                              mapType: MapType.normal,
                                              onMapCreated: (GoogleMapController
                                                  controller111) {
                                                // controller.complete();
                                              },
                                            ),
                                    ),
                                  ),
                                )),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 15,
                        color: Colors.grey.shade500,
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        convertUTCTimeTo12HourFormat(data.createdAt!),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
          ],
        ),
      ),
    ).paddingOnly(bottom: 10);
  }

  Widget getVideoMessageWidget(index, StarMessageList data) {
    return InkWell(
      onTap: () {
        if (isSelectedmessage == "1") {
          setState(() {
            starId.contains(data.chat!.messageId.toString())
                ? starId.remove(data.chat!.messageId.toString())
                : starId.add(data.chat!.messageId.toString());
          });
        } else {
          data.chat!.conversation!.isGroup == false
              ? Get.to(() => SingleChatMsg(
                  conversationID: data.chat!.conversationId.toString(),
                  username: isIdMatch(data.chat!.conversationId.toString()),
                  userPic: isPicMatch(data.chat!.conversationId.toString()),
                  index: 0,
                  searchText: "",
                  searchTime: "",
                  mobileNum: "",
                  isBlock: isBlockMatch(data.chat!.conversationId.toString()),
                  messageId: data.chat!.messageId.toString(),
                  isMsgHighLight: true,
                  userID: data.otherUserId.toString()))
              : Get.to(() => GroupChatMsg(
                    conversationID:
                        data.chat!.conversation!.conversationId.toString(),
                    gPusername: data.chat!.conversation!.groupName,
                    gPPic: data.chat!.conversation!.groupProfileImage,
                    index: 0,
                    searchText: "",
                    searchTime: "",
                    messageid: data.chat!.messageId.toString(),
                    isMsgHighLight: true,
                  ));
        }
      },
      child: Container(
        color: const Color(0xffFFFFFF),
        child: Stack(
          children: [
            isSelectedmessage == "1"
                ? Positioned(
                    left: 10,
                    top: 95,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          starId.contains(data.chat!.messageId.toString())
                              ? starId.remove(data.chat!.messageId.toString())
                              : starId.add(data.chat!.messageId.toString());
                        });
                        print("STARID:$starId");
                      },
                      child: starId.length == 0
                          ? const SizedBox()
                          : Transform.scale(
                              scale: 1.1,
                              child: starId
                                      .contains(data.chat!.messageId.toString())
                                  ? checkContainer()
                                  : removeCheckContainer(),
                            ),
                    ),
                  )
                : const SizedBox.shrink(),
            Padding(
              padding: EdgeInsets.only(
                  top: 5,
                  bottom: 5,
                  left: starId.isNotEmpty ? 34 : 28,
                  right: 28),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            data.chat!.user!.userId ==
                                    Hive.box(userdata).get(userId)
                                ? "You"
                                : data.chat!.user!.firstName! +
                                    data.chat!.user!.lastName!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                          ),
                          const Icon(Icons.arrow_right_rounded, size: 30),
                          data.chat!.conversation!.isGroup == false
                              ? Text(
                                  data.otherUserDetails![0].userId ==
                                          data.chat!.user!.userId
                                      ? "You"
                                      : data.otherUserDetails![0].firstName! +
                                          data.otherUserDetails![0].lastName!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 11,
                                  ),
                                )
                              : Text(
                                  data.chat!.conversation!.groupName!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 11,
                                  ),
                                ),
                        ],
                      ),
                      Text(
                        date(convertToLocalDate(data.updatedAt!)),
                        style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade500),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: data.chat!.user!.userId ==
                                        Hive.box(userdata).get(userId)
                                    ? yellow1Color
                                    : Colors.grey.shade200,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Container(
                                    height: 120,
                                    width: 120,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        data.chat!.thumbnail!,
                                        fit: BoxFit.cover,
                                      ),
                                    )),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VideoViewFix(
                                          username: "",
                                          //"${capitalizeFirstLetter(data.senderData!.firstName!)} ${capitalizeFirstLetter(data.senderData!.lastName!)}",
                                          url: data.chat!.url!,
                                          play: true,
                                          mute: false,
                                          date: ""
                                          // convertUTCTimeTo12HourFormat(
                                          //     data.createdAt!),
                                          ),
                                    ));
                              },
                              child: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.grey.shade300,
                                  foregroundColor: chatownColor,
                                  child: Image.asset("assets/images/play1.png",
                                      color: chatColor, height: 15)),
                            )
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 15,
                        color: Colors.grey.shade500,
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        convertUTCTimeTo12HourFormat(data.createdAt!),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
          ],
        ),
      ),
    ).paddingOnly(bottom: 10);
  }

  Widget getDocMessageWidget(index, StarMessageList data) {
    return InkWell(
      onTap: () {
        if (isSelectedmessage == "1") {
          setState(() {
            starId.contains(data.chat!.messageId.toString())
                ? starId.remove(data.chat!.messageId.toString())
                : starId.add(data.chat!.messageId.toString());
          });
        } else {
          data.chat!.conversation!.isGroup == false
              ? Get.to(() => SingleChatMsg(
                  conversationID: data.chat!.conversationId.toString(),
                  username: isIdMatch(data.chat!.conversationId.toString()),
                  userPic: isPicMatch(data.chat!.conversationId.toString()),
                  index: 0,
                  searchText: "",
                  searchTime: "",
                  mobileNum: "",
                  isBlock: isBlockMatch(data.chat!.conversationId.toString()),
                  messageId: data.chat!.messageId.toString(),
                  isMsgHighLight: true,
                  userID: data.otherUserId.toString()))
              : Get.to(() => GroupChatMsg(
                    conversationID:
                        data.chat!.conversation!.conversationId.toString(),
                    gPusername: data.chat!.conversation!.groupName,
                    gPPic: data.chat!.conversation!.groupProfileImage,
                    index: 0,
                    searchText: "",
                    searchTime: "",
                    messageid: data.chat!.messageId.toString(),
                    isMsgHighLight: true,
                  ));
        }
      },
      child: Container(
        color: const Color(0xffFFFFFF),
        child: Stack(
          children: [
            isSelectedmessage == "1"
                ? Positioned(
                    left: 10,
                    top: 65,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          starId.contains(data.chat!.messageId.toString())
                              ? starId.remove(data.chat!.messageId.toString())
                              : starId.add(data.chat!.messageId.toString());
                        });
                        print("STARID:$starId");
                      },
                      child: starId.length == 0
                          ? const SizedBox()
                          : Transform.scale(
                              scale: 1.1,
                              child: starId
                                      .contains(data.chat!.messageId.toString())
                                  ? checkContainer()
                                  : removeCheckContainer(),
                            ),
                    ),
                  )
                : const SizedBox.shrink(),
            Padding(
              padding: EdgeInsets.only(
                  top: 5,
                  bottom: 5,
                  left: starId.isNotEmpty ? 34 : 28,
                  right: 28),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            data.chat!.user!.userId ==
                                    Hive.box(userdata).get(userId)
                                ? "You"
                                : data.chat!.user!.firstName! +
                                    data.chat!.user!.lastName!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                          ),
                          const Icon(Icons.arrow_right_rounded, size: 30),
                          data.chat!.conversation!.isGroup == false
                              ? Text(
                                  data.otherUserDetails![0].userId ==
                                          data.chat!.user!.userId
                                      ? "You"
                                      : data.otherUserDetails![0].firstName! +
                                          data.otherUserDetails![0].lastName!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 11,
                                  ),
                                )
                              : Text(
                                  data.chat!.conversation!.groupName!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 11,
                                  ),
                                ),
                        ],
                      ),
                      Text(
                        date(convertToLocalDate(data.updatedAt!)),
                        style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade500),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                PageTransition(
                                  curve: Curves.linear,
                                  type: PageTransitionType.rightToLeft,
                                  child: FileView(file: "${data.chat!.url}"),
                                ));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: data.chat!.user!.userId ==
                                      Hive.box(userdata).get(userId)
                                  ? yellow1Color
                                  : Colors.grey.shade200,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 5, bottom: 5, left: 5, right: 5),
                              child: Container(
                                width: Get.width * 0.50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  child: Row(
                                    children: [
                                      const Image(
                                        height: 30,
                                        image:
                                            AssetImage('assets/images/pdf.png'),
                                      ),
                                      FutureBuilder<Map<String, dynamic>>(
                                        future: getPdfInfo(data.chat!.url!),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  extractFilename(
                                                          data.chat!.url!)
                                                      .toString()
                                                      .split("-")
                                                      .last,
                                                  style: const TextStyle(
                                                    color: chatColor,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const Text(
                                                  '0 Page - 0 KB',
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                )
                                              ],
                                            ).paddingOnly(left: 12);
                                          } else if (snapshot.hasError) {
                                            return const Text('');
                                          } else if (snapshot.hasData) {
                                            final int pageCount =
                                                snapshot.data!['pageCount'];
                                            final String fileSize =
                                                snapshot.data!['fileSize'];
                                            return Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 11),
                                                  child: Text(
                                                    extractFilename(
                                                            data.chat!.url!)
                                                        .toString()
                                                        .split("-")
                                                        .last,
                                                    style: const TextStyle(
                                                      color: chatColor,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  '$pageCount Page - $fileSize',
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ).paddingOnly(left: 12),
                                              ],
                                            );
                                          } else {
                                            return const Text(
                                                'No PDF info available');
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 15,
                        color: Colors.grey.shade500,
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        convertUTCTimeTo12HourFormat(data.createdAt!),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
          ],
        ),
      ),
    ).paddingOnly(bottom: 10);
  }

  Widget getVoiceMessageWidget(index, StarMessageList data) {
    return InkWell(
      onTap: () {
        if (isSelectedmessage == "1") {
          setState(() {
            starId.contains(data.chat!.messageId.toString())
                ? starId.remove(data.chat!.messageId.toString())
                : starId.add(data.chat!.messageId.toString());
          });
        } else {
          data.chat!.conversation!.isGroup == false
              ? Get.to(() => SingleChatMsg(
                  conversationID: data.chat!.conversationId.toString(),
                  username: isIdMatch(data.chat!.conversationId.toString()),
                  userPic: isPicMatch(data.chat!.conversationId.toString()),
                  index: 0,
                  searchText: "",
                  searchTime: "",
                  mobileNum: "",
                  isBlock: isBlockMatch(data.chat!.conversationId.toString()),
                  messageId: data.chat!.messageId.toString(),
                  isMsgHighLight: true,
                  userID: data.otherUserId.toString()))
              : Get.to(() => GroupChatMsg(
                    conversationID:
                        data.chat!.conversation!.conversationId.toString(),
                    gPusername: data.chat!.conversation!.groupName,
                    gPPic: data.chat!.conversation!.groupProfileImage,
                    index: 0,
                    searchText: "",
                    searchTime: "",
                    messageid: data.chat!.messageId.toString(),
                    isMsgHighLight: true,
                  ));
        }
      },
      child: Container(
        color: const Color(0xffFFFFFF),
        child: Stack(
          children: [
            isSelectedmessage == "1"
                ? Positioned(
                    left: 10,
                    top: 70,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          starId.contains(data.chat!.messageId.toString())
                              ? starId.remove(data.chat!.messageId.toString())
                              : starId.add(data.chat!.messageId.toString());
                        });
                        print("STARID:$starId");
                      },
                      child: starId.length == 0
                          ? const SizedBox()
                          : Transform.scale(
                              scale: 1.1,
                              child: starId
                                      .contains(data.chat!.messageId.toString())
                                  ? checkContainer()
                                  : removeCheckContainer(),
                            ),
                    ),
                  )
                : const SizedBox.shrink(),
            Padding(
              padding: EdgeInsets.only(
                  top: 5,
                  bottom: 5,
                  left: starId.isNotEmpty ? 34 : 28,
                  right: 28),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            data.chat!.user!.userId ==
                                    Hive.box(userdata).get(userId)
                                ? "You"
                                : data.chat!.user!.firstName! +
                                    data.chat!.user!.lastName!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                          ),
                          const Icon(Icons.arrow_right_rounded, size: 30),
                          data.chat!.conversation!.isGroup == false
                              ? Text(
                                  data.otherUserDetails![0].userId ==
                                          data.chat!.user!.userId
                                      ? "You"
                                      : data.otherUserDetails![0].firstName! +
                                          data.otherUserDetails![0].lastName!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 11,
                                  ),
                                )
                              : Text(
                                  data.chat!.conversation!.groupName!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 11,
                                  ),
                                ),
                        ],
                      ),
                      Text(
                        date(convertToLocalDate(data.updatedAt!)),
                        style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade500),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _audio(
                              message: data.chat!.url!,
                              index: index,
                              duration: data.chat!.audioTime!,
                              data: data),
                        ],
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 15,
                        color: Colors.grey.shade500,
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        convertUTCTimeTo12HourFormat(data.createdAt!),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
          ],
        ),
      ),
    ).paddingOnly(bottom: 10);
  }

  Widget getGifMessage(index, StarMessageList data) {
    return InkWell(
      onTap: () {
        if (isSelectedmessage == "1") {
          setState(() {
            starId.contains(data.chat!.messageId.toString())
                ? starId.remove(data.chat!.messageId.toString())
                : starId.add(data.chat!.messageId.toString());
          });
        } else {
          data.chat!.conversation!.isGroup == false
              ? Get.to(() => SingleChatMsg(
                  conversationID: data.chat!.conversationId.toString(),
                  username: isIdMatch(data.chat!.conversationId.toString()),
                  userPic: isPicMatch(data.chat!.conversationId.toString()),
                  index: 0,
                  searchText: "",
                  searchTime: "",
                  mobileNum: "",
                  isBlock: isBlockMatch(data.chat!.conversationId.toString()),
                  messageId: data.chat!.messageId.toString(),
                  isMsgHighLight: true,
                  userID: data.otherUserId.toString()))
              : Get.to(() => GroupChatMsg(
                    conversationID:
                        data.chat!.conversation!.conversationId.toString(),
                    gPusername: data.chat!.conversation!.groupName,
                    gPPic: data.chat!.conversation!.groupProfileImage,
                    index: 0,
                    searchText: "",
                    searchTime: "",
                    messageid: data.chat!.messageId.toString(),
                    isMsgHighLight: true,
                  ));
        }
      },
      child: Container(
        color: const Color(0xffFFFFFF),
        child: Stack(
          children: [
            isSelectedmessage == "1"
                ? Positioned(
                    left: 10,
                    top: 95,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          starId.contains(data.chat!.messageId.toString())
                              ? starId.remove(data.chat!.messageId.toString())
                              : starId.add(data.chat!.messageId.toString());
                        });
                        print("STARID:$starId");
                      },
                      child: starId.length == 0
                          ? const SizedBox()
                          : Transform.scale(
                              scale: 1.1,
                              child: starId
                                      .contains(data.chat!.messageId.toString())
                                  ? checkContainer()
                                  : removeCheckContainer(),
                            ),
                    ),
                  )
                : const SizedBox.shrink(),
            Padding(
              padding: EdgeInsets.only(
                  top: 5,
                  bottom: 5,
                  left: starId.isNotEmpty ? 34 : 28,
                  right: 28),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            data.chat!.user!.userId ==
                                    Hive.box(userdata).get(userId)
                                ? "You"
                                : data.chat!.user!.firstName! +
                                    data.chat!.user!.lastName!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                          ),
                          const Icon(Icons.arrow_right_rounded, size: 30),
                          data.chat!.conversation!.isGroup == false
                              ? Text(
                                  data.otherUserDetails![0].userId ==
                                          data.chat!.user!.userId
                                      ? "You"
                                      : data.otherUserDetails![0].firstName! +
                                          data.otherUserDetails![0].lastName!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 11,
                                  ),
                                )
                              : Text(
                                  data.chat!.conversation!.groupName!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 11,
                                  ),
                                ),
                        ],
                      ),
                      Text(
                        date(convertToLocalDate(data.updatedAt!)),
                        style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade500),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                  curve: Curves.linear,
                                  type: PageTransitionType.rightToLeft,
                                  child: ImageView(
                                    image: data.chat!.url!,
                                    userimg: "",
                                  )),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: data.chat!.user!.userId ==
                                      Hive.box(userdata).get(userId)
                                  ? yellow1Color
                                  : Colors.grey.shade200,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Container(
                                  height: 120,
                                  width: 120,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10)),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      data.chat!.url!,
                                      fit: BoxFit.cover,
                                    ),
                                  )),
                            ),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 15,
                        color: Colors.grey.shade500,
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        convertUTCTimeTo12HourFormat(data.createdAt!),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
          ],
        ),
      ),
    ).paddingOnly(bottom: 10);
  }

  Widget getHttpLinkMessage(index, StarMessageList data) {
    return InkWell(
      onTap: () {
        if (isSelectedmessage == "1") {
          setState(() {
            starId.contains(data.chat!.messageId.toString())
                ? starId.remove(data.chat!.messageId.toString())
                : starId.add(data.chat!.messageId.toString());
          });
        } else {
          data.chat!.conversation!.isGroup == false
              ? Get.to(() => SingleChatMsg(
                  conversationID: data.chat!.conversationId.toString(),
                  username: isIdMatch(data.chat!.conversationId.toString()),
                  userPic: isPicMatch(data.chat!.conversationId.toString()),
                  index: 0,
                  searchText: "",
                  searchTime: "",
                  mobileNum: "",
                  isBlock: isBlockMatch(data.chat!.conversationId.toString()),
                  messageId: data.chat!.messageId.toString(),
                  isMsgHighLight: true,
                  userID: data.otherUserId.toString()))
              : Get.to(() => GroupChatMsg(
                    conversationID:
                        data.chat!.conversation!.conversationId.toString(),
                    gPusername: data.chat!.conversation!.groupName,
                    gPPic: data.chat!.conversation!.groupProfileImage,
                    index: 0,
                    searchText: "",
                    searchTime: "",
                    messageid: data.chat!.messageId.toString(),
                    isMsgHighLight: true,
                  ));
        }
      },
      child: Container(
        color: const Color(0xffFFFFFF),
        child: Stack(
          children: [
            isSelectedmessage == "1"
                ? Positioned(
                    left: 10,
                    top: 80,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          starId.contains(data.chat!.messageId.toString())
                              ? starId.remove(data.chat!.messageId.toString())
                              : starId.add(data.chat!.messageId.toString());
                        });
                        print("STARID:$starId");
                      },
                      child: starId.length == 0
                          ? const SizedBox()
                          : Transform.scale(
                              scale: 1.1,
                              child: starId
                                      .contains(data.chat!.messageId.toString())
                                  ? checkContainer()
                                  : removeCheckContainer(),
                            ),
                    ),
                  )
                : const SizedBox.shrink(),
            Padding(
              padding: EdgeInsets.only(
                  top: 5,
                  bottom: 5,
                  left: starId.isNotEmpty ? 34 : 28,
                  right: 28),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            data.chat!.user!.userId ==
                                    Hive.box(userdata).get(userId)
                                ? "You"
                                : data.chat!.user!.firstName! +
                                    data.chat!.user!.lastName!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                          ),
                          const Icon(Icons.arrow_right_rounded, size: 30),
                          data.chat!.conversation!.isGroup == false
                              ? Text(
                                  data.otherUserDetails![0].userId ==
                                          data.chat!.user!.userId
                                      ? "You"
                                      : data.otherUserDetails![0].firstName! +
                                          data.otherUserDetails![0].lastName!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 11,
                                  ),
                                )
                              : Text(
                                  data.chat!.conversation!.groupName!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 11,
                                  ),
                                ),
                        ],
                      ),
                      Text(
                        date(convertToLocalDate(data.updatedAt!)),
                        style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade500),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: data.chat!.user!.userId ==
                                    Hive.box(userdata).get(userId)
                                ? yellow1Color
                                : Colors.grey.shade200,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 3, left: 3, right: 3),
                            child: Container(
                              constraints: BoxConstraints(
                                  maxHeight:
                                      MediaQuery.of(context).size.height / 8.3,
                                  maxWidth:
                                      MediaQuery.of(context).size.width * .7),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade200),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: InkWell(
                                onTap: () {
                                  launchURL(data.chat!.message!);
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(
                                          left: 5, right: 5, top: 5, bottom: 5),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: FlutterLinkPreview(
                                        url: data.chat!.message!,
                                        builder: (info) {
                                          if (info is WebInfo) {
                                            return info.title == null &&
                                                    info.description == null
                                                ? Text(
                                                    data.chat!.message!,
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Colors.white),
                                                  )
                                                : Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      if (info.image != null)
                                                        Container(
                                                          height: 50,
                                                          width: 50,
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            child:
                                                                Image.network(
                                                                    info.image!,
                                                                    fit: BoxFit
                                                                        .cover),
                                                          ),
                                                        ),
                                                      const SizedBox(width: 5),
                                                      Expanded(
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            if (info.title !=
                                                                null)
                                                              Text(
                                                                info.title!,
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ).paddingAll(2),
                                                            info.image == null
                                                                ? const SizedBox(
                                                                    height: 5)
                                                                : const SizedBox
                                                                    .shrink(),
                                                            if (info.description !=
                                                                null)
                                                              Text(
                                                                info.description!,
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: const TextStyle(
                                                                    color: Color
                                                                        .fromRGBO(
                                                                            68,
                                                                            68,
                                                                            68,
                                                                            1),
                                                                    fontSize: 9,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                          }
                                          return const CircularProgressIndicator();
                                        },
                                        titleStyle: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      data.chat!.message!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: linkColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w400),
                                    ).paddingOnly(left: 10)
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 15,
                        color: Colors.grey.shade500,
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        convertUTCTimeTo12HourFormat(data.createdAt!),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
          ],
        ),
      ),
    ).paddingOnly(bottom: 10);
  }

  Widget getContactMessage(index, StarMessageList data) {
    return InkWell(
      onTap: () {
        if (isSelectedmessage == "1") {
          setState(() {
            starId.contains(data.chat!.messageId.toString())
                ? starId.remove(data.chat!.messageId.toString())
                : starId.add(data.chat!.messageId.toString());
          });
        } else {
          data.chat!.conversation!.isGroup == false
              ? Get.to(() => SingleChatMsg(
                  conversationID: data.chat!.conversationId.toString(),
                  username: isIdMatch(data.chat!.conversationId.toString()),
                  userPic: isPicMatch(data.chat!.conversationId.toString()),
                  index: 0,
                  searchText: "",
                  searchTime: "",
                  mobileNum: "",
                  isBlock: isBlockMatch(data.chat!.conversationId.toString()),
                  messageId: data.chat!.messageId.toString(),
                  isMsgHighLight: true,
                  userID: data.otherUserId.toString()))
              : Get.to(() => GroupChatMsg(
                    conversationID:
                        data.chat!.conversation!.conversationId.toString(),
                    gPusername: data.chat!.conversation!.groupName,
                    gPPic: data.chat!.conversation!.groupProfileImage,
                    index: 0,
                    searchText: "",
                    searchTime: "",
                    messageid: data.chat!.messageId.toString(),
                    isMsgHighLight: true,
                  ));
        }
      },
      child: Container(
        color: const Color(0xffFFFFFF),
        child: Stack(
          children: [
            isSelectedmessage == "1"
                ? Positioned(
                    left: 10,
                    top: 80,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          starId.contains(data.chat!.messageId.toString())
                              ? starId.remove(data.chat!.messageId.toString())
                              : starId.add(data.chat!.messageId.toString());
                        });
                        print("STARID:$starId");
                      },
                      child: starId.length == 0
                          ? const SizedBox()
                          : Transform.scale(
                              scale: 1.1,
                              child: starId
                                      .contains(data.chat!.messageId.toString())
                                  ? checkContainer()
                                  : removeCheckContainer(),
                            ),
                    ),
                  )
                : const SizedBox.shrink(),
            Padding(
              padding: EdgeInsets.only(
                  top: 5,
                  bottom: 5,
                  left: starId.isNotEmpty ? 34 : 28,
                  right: 28),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            data.chat!.user!.userId ==
                                    Hive.box(userdata).get(userId)
                                ? "You"
                                : data.chat!.user!.firstName! +
                                    data.chat!.user!.lastName!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                          ),
                          const Icon(Icons.arrow_right_rounded, size: 30),
                          data.chat!.conversation!.isGroup == false
                              ? Text(
                                  data.otherUserDetails![0].userId ==
                                          data.chat!.user!.userId
                                      ? "You"
                                      : data.otherUserDetails![0].firstName! +
                                          data.otherUserDetails![0].lastName!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 11,
                                  ),
                                )
                              : Text(
                                  data.chat!.conversation!.groupName!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 11,
                                  ),
                                ),
                        ],
                      ),
                      Text(
                        date(convertToLocalDate(data.updatedAt!)),
                        style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade500),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * .6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: data.chat!.user!.userId ==
                                  Hive.box(userdata).get(userId)
                              ? yellow1Color
                              : Colors.grey.shade200,
                        ),
                        padding: const EdgeInsets.all(3),
                        child: Column(
                          children: [
                            Container(
                              height: 50,
                              width: 200,
                              decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10)),
                                  color: Colors.white),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 30,
                                    width: 30,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(35)),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(35),
                                      child: CustomCachedNetworkImage(
                                          imageUrl: data
                                              .chat!.sharedContactProfileImage!,
                                          placeholderColor: chatownColor,
                                          errorWidgeticon: const Icon(
                                            Icons.groups,
                                            size: 30,
                                          )),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        capitalizeFirstLetter(
                                            data.chat!.sharedContactName!),
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: chatColor),
                                      ),
                                      Text(
                                        capitalizeFirstLetter(
                                            data.chat!.sharedContactNumber!),
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: chatColor),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 3),
                            Container(
                              height: 30,
                              width: 200,
                              decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10)),
                                  color: Colors.white),
                              child: const Column(
                                children: [
                                  SizedBox(height: 3),
                                  Text(
                                    "Message",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: chatColor),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 15,
                        color: Colors.grey.shade500,
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        convertUTCTimeTo12HourFormat(data.createdAt!),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
          ],
        ),
      ),
    ).paddingOnly(bottom: 10);
  }

  Widget getReplyMessage(index, StarMessageList data) {
    return InkWell(
      onTap: () {
        if (chatID.isNotEmpty) {
          setState(() {
            chatID.contains(data.messageId)
                ? chatID.remove(data.messageId)
                : chatID.add(data.messageId);
          });
        }
        print("ONTAPMSGID:$chatID");
      },
      child: replyMSGWidget(index, data),
    );
  }

  //=============================================================                      =======================================================================
//============================================================= REPLY MESSAGE DESIGN =======================================================================
//=============================================================                      =======================================================================

  // String isUserMatch(String msgID, int userID) {
  //   for (var i = 0; i < allStaredMsgController.allStarred.length; i++) {
  //     if (allStaredMsgController.allStarred[i].messageId == int.parse(msgID)) {
  //       if (allStaredMsgController.allStarred[i].chat!.user!.userId == userID) {
  //         if ("${allStaredMsgController.allStarred[i].chat!.user!.firstName!} ${allStaredMsgController.allStarred[i].chat!.user!.lastName!}" ==
  //             "${Hive.box(userdata).get(firstName)} ${Hive.box(userdata).get(lastName)}") {
  //           return 'You';
  //         } else {
  //           return "${allStaredMsgController.allStarred[i].chat!.user!.firstName!} ${allStaredMsgController.allStarred[i].chat!.user!.lastName!}";
  //         }
  //       } else {
  //         if ("${allStaredMsgController.allStarred[i].chat!.user!.firstName!} ${allStaredMsgController.allStarred[i].chat!.user!.lastName!}" ==
  //             "${Hive.box(userdata).get(firstName)} ${Hive.box(userdata).get(lastName)}") {
  //           return 'You';
  //         } else {
  //           return "${allStaredMsgController.allStarred[i].chat!.user!.firstName!} ${allStaredMsgController.allStarred[i].chat!.user!.lastName!}";
  //         }
  //       }
  //     }
  //   }
  //   return "You"; // This return might be a default case if no match is found
  // }

  Widget replyMSGWidget(int index, StarMessageList data) {
    String isMatching(String msgID) {
      if (data.resData!.messageType == "text") {
        return data.resData!.message!;
      } else if (data.resData!.messageType == "image") {
        return "📷 Photo";
      } else if (data.resData!.messageType == "location") {
        return "📌 Location";
      } else if (data.resData!.messageType == "document") {
        return "📄 Document";
      } else if (data.resData!.messageType == "video") {
        return "🎥 Video";
      } else if (data.resData!.messageType == "audio") {
        return "🔊 Audio";
      } else if (data.resData!.messageType == "link") {
        return data.resData!.message!;
      } else if (data.resData!.messageType == "gif") {
        return "GIF";
      } else if (data.resData!.messageType == "contact") {
        return "Contact";
      }
      return "message removed";
    }

    return InkWell(
      onTap: () {
        if (isSelectedmessage == "1") {
          setState(() {
            starId.contains(data.chat!.messageId.toString())
                ? starId.remove(data.chat!.messageId.toString())
                : starId.add(data.chat!.messageId.toString());
          });
        } else {
          data.chat!.conversation!.isGroup == false
              ? Get.to(() => SingleChatMsg(
                  conversationID: data.chat!.conversationId.toString(),
                  username: isIdMatch(data.chat!.conversationId.toString()),
                  userPic: isPicMatch(data.chat!.conversationId.toString()),
                  index: 0,
                  searchText: "",
                  searchTime: "",
                  mobileNum: "",
                  isBlock: isBlockMatch(data.chat!.conversationId.toString()),
                  messageId: data.chat!.messageId.toString(),
                  isMsgHighLight: true,
                  userID: data.otherUserId.toString()))
              : Get.to(() => GroupChatMsg(
                    conversationID:
                        data.chat!.conversation!.conversationId.toString(),
                    gPusername: data.chat!.conversation!.groupName,
                    gPPic: data.chat!.conversation!.groupProfileImage,
                    index: 0,
                    searchText: "",
                    searchTime: "",
                    messageid: data.chat!.messageId.toString(),
                    isMsgHighLight: true,
                  ));
        }
      },
      child: Container(
        color: const Color(0xffFFFFFF),
        child: Stack(
          children: [
            isSelectedmessage == "1"
                ? Positioned(
                    left: 10,
                    top: data.chat!.messageType == "text"
                        ? 85
                        : data.chat!.messageType == "document"
                            ? 90
                            : data.chat!.messageType == "image"
                                ? 130
                                : data.chat!.messageType == "video"
                                    ? 130
                                    : data.chat!.messageType == "location"
                                        ? 140
                                        : data.chat!.messageType == "audio"
                                            ? 90
                                            : data.chat!.messageType == "link"
                                                ? 120
                                                : data.chat!.messageType ==
                                                        "gif"
                                                    ? 120
                                                    : data.chat!.messageType ==
                                                            "contact"
                                                        ? 120
                                                        : 85,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          starId.contains(data.chat!.messageId.toString())
                              ? starId.remove(data.chat!.messageId.toString())
                              : starId.add(data.chat!.messageId.toString());
                        });
                        print("STARID:$starId");
                      },
                      child: starId.length == 0
                          ? const SizedBox()
                          : Transform.scale(
                              scale: 1.1,
                              child: starId
                                      .contains(data.chat!.messageId.toString())
                                  ? checkContainer()
                                  : removeCheckContainer(),
                            ),
                    ),
                  )
                : const SizedBox.shrink(),
            Padding(
              padding: EdgeInsets.only(
                  top: 5,
                  bottom: 5,
                  left: starId.isNotEmpty ? 34 : 28,
                  right: 28),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            data.chat!.user!.userId ==
                                    Hive.box(userdata).get(userId)
                                ? "You"
                                : data.chat!.user!.firstName! +
                                    data.chat!.user!.lastName!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                          ),
                          const Icon(Icons.arrow_right_rounded, size: 30),
                          data.chat!.conversation!.isGroup == false
                              ? Text(
                                  data.otherUserDetails![0].userId ==
                                          data.chat!.user!.userId
                                      ? "You"
                                      : data.otherUserDetails![0].firstName! +
                                          data.otherUserDetails![0].lastName!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 11,
                                  ),
                                )
                              : Text(
                                  data.chat!.conversation!.groupName!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 11,
                                  ),
                                ),
                        ],
                      ),
                      Text(
                        date(convertToLocalDate(data.updatedAt!)),
                        style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade500),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              constraints: BoxConstraints(
                                  maxWidth: data.chat!.messageType == "link"
                                      ? MediaQuery.of(context).size.width * .7
                                      : data.chat!.messageType == "audio"
                                          ? MediaQuery.of(context).size.width *
                                              0.7
                                          : data.chat!.messageType == "location"
                                              ? 250
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .6),
                              padding: const EdgeInsets.only(
                                  left: 7, right: 7, top: 0, bottom: 0),
                              decoration: BoxDecoration(
                                  color: data.chat!.user!.userId ==
                                          Hive.box(userdata).get(userId)
                                      ? yellow1Color
                                      : Colors.grey.shade200,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10))),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 5, top: 10),
                                    child: Container(
                                      width: double.infinity,
                                      decoration: const BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8))),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 15,
                                            top: 8,
                                            bottom: 8,
                                            right: 15),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${data.resData!.senderData!.firstName} ${data.resData!.senderData!.lastName!}",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              isMatching(data.resData!.messageId
                                                  .toString()),
                                              maxLines: 1,
                                              style: TextStyle(
                                                  color: Colors.grey[700],
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: data.chat!.messageType == "text"
                                        ? Text(data.chat!.message!)
                                        : data.chat!.messageType == "document"
                                            ? InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      PageTransition(
                                                        curve: Curves.linear,
                                                        type: PageTransitionType
                                                            .rightToLeft,
                                                        child: FileView(
                                                            file:
                                                                "${data.chat!.url}"),
                                                      ));
                                                },
                                                child: SizedBox(
                                                  width: Get.width * 0.50,
                                                  child: Row(
                                                    children: [
                                                      const Image(
                                                        height: 30,
                                                        image: AssetImage(
                                                            'assets/images/pdf.png'),
                                                      ),
                                                      FutureBuilder<
                                                          Map<String, dynamic>>(
                                                        future: getPdfInfo(
                                                            data.chat!.url!),
                                                        builder: (context,
                                                            snapshot) {
                                                          if (snapshot
                                                                  .connectionState ==
                                                              ConnectionState
                                                                  .waiting) {
                                                            return Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  extractFilename(data
                                                                          .chat!
                                                                          .url!)
                                                                      .toString()
                                                                      .split(
                                                                          "-")
                                                                      .last,
                                                                  style:
                                                                      const TextStyle(
                                                                    color:
                                                                        chatColor,
                                                                    fontSize:
                                                                        13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                ),
                                                                const Text(
                                                                  '0 Page - 0 KB',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontSize:
                                                                        10,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                  ),
                                                                )
                                                              ],
                                                            ).paddingOnly(
                                                                left: 12);
                                                          } else if (snapshot
                                                              .hasError) {
                                                            return const Text(
                                                                '');
                                                          } else if (snapshot
                                                              .hasData) {
                                                            final int
                                                                pageCount =
                                                                snapshot.data![
                                                                    'pageCount'];
                                                            final String
                                                                fileSize =
                                                                snapshot.data![
                                                                    'fileSize'];
                                                            return Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Container(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              11),
                                                                  child: Text(
                                                                    extractFilename(data
                                                                            .chat!
                                                                            .url!)
                                                                        .toString()
                                                                        .split(
                                                                            "-")
                                                                        .last,
                                                                    style:
                                                                        const TextStyle(
                                                                      color:
                                                                          chatColor,
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Text(
                                                                  '$pageCount Page - $fileSize',
                                                                  style:
                                                                      const TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontSize:
                                                                        10,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                  ),
                                                                ).paddingOnly(
                                                                    left: 12),
                                                              ],
                                                            );
                                                          } else {
                                                            return const Text(
                                                                'No PDF info available');
                                                          }
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : data.chat!.messageType == "image"
                                                ? InkWell(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        PageTransition(
                                                            curve:
                                                                Curves.linear,
                                                            type:
                                                                PageTransitionType
                                                                    .rightToLeft,
                                                            child: ImageView(
                                                              image: data
                                                                  .chat!.url!,
                                                              userimg: "",
                                                            )),
                                                      );
                                                    },
                                                    child: Container(
                                                        height: 120,
                                                        width: double.maxFinite,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          child: Image.network(
                                                            data.chat!.url!,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        )),
                                                  )
                                                : data.chat!.messageType ==
                                                        "video"
                                                    ? Stack(
                                                        alignment:
                                                            Alignment.center,
                                                        children: [
                                                          SizedBox(
                                                            height: 120,
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              child:
                                                                  CachedNetworkImage(
                                                                imageUrl: data
                                                                    .chat!
                                                                    .thumbnail!,
                                                                imageBuilder:
                                                                    (context,
                                                                            imageProvider) =>
                                                                        Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    image:
                                                                        DecorationImage(
                                                                      image:
                                                                          imageProvider,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                  ),
                                                                ),
                                                                placeholder: (context,
                                                                        url) =>
                                                                    const Center(
                                                                  child:
                                                                      CupertinoActivityIndicator(),
                                                                ),
                                                                errorWidget: (context,
                                                                        url,
                                                                        error) =>
                                                                    const Center(
                                                                  child: Icon(
                                                                      Icons
                                                                          .error),
                                                                ),
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          ),
                                                          InkWell(
                                                            onTap: () {
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder: (context) => VideoViewFix(
                                                                        username: "",
                                                                        //"${capitalizeFirstLetter(data.senderData!.firstName!)} ${capitalizeFirstLetter(data.senderData!.lastName!)}",
                                                                        url: data.chat!.url!,
                                                                        play: true,
                                                                        mute: false,
                                                                        date: ""
                                                                        // convertUTCTimeTo12HourFormat(
                                                                        //     data.createdAt!),
                                                                        ),
                                                                  ));
                                                            },
                                                            child: CircleAvatar(
                                                                radius: 18,
                                                                backgroundColor:
                                                                    Colors.grey
                                                                        .shade300,
                                                                foregroundColor:
                                                                    chatownColor,
                                                                child: Image.asset(
                                                                    "assets/images/play1.png",
                                                                    color:
                                                                        chatColor,
                                                                    height:
                                                                        15)),
                                                          )
                                                        ],
                                                      )
                                                    : data.chat!.messageType ==
                                                            "location"
                                                        ? Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                            constraints:
                                                                const BoxConstraints(
                                                                    minHeight:
                                                                        10.0,
                                                                    minWidth:
                                                                        10.0,
                                                                    maxWidth:
                                                                        250),
                                                            child: InkWell(
                                                              onTap: () {
                                                                MapUtils.openMap(
                                                                    double.parse(data
                                                                        .chat!
                                                                        .latitude!),
                                                                    double.parse(data
                                                                        .chat!
                                                                        .longitude!));
                                                              },
                                                              child: Container(
                                                                height: 130,
                                                                width: 250,
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10)),
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                  child: data.chat!.latitude.toString() ==
                                                                              "" ||
                                                                          data.chat!.longitude.toString() ==
                                                                              ""
                                                                      ? Container(
                                                                          decoration: const BoxDecoration(
                                                                              borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                                                                              image: DecorationImage(image: AssetImage("assets/images/map_Blurr.png"), fit: BoxFit.cover)),
                                                                          child:
                                                                              Icon(
                                                                            Icons.error_outline,
                                                                            color:
                                                                                chatownColor.withOpacity(0.6),
                                                                            size:
                                                                                50,
                                                                          ),
                                                                        )
                                                                      : GoogleMap(
                                                                          zoomControlsEnabled:
                                                                              false,
                                                                          zoomGesturesEnabled:
                                                                              false,
                                                                          initialCameraPosition: CameraPosition(
                                                                              target: LatLng(double.parse(data.chat!.latitude!), double.parse(data.chat!.longitude!)),
                                                                              zoom: 15),
                                                                          mapType:
                                                                              MapType.normal,
                                                                          onMapCreated:
                                                                              (GoogleMapController controller111) {
                                                                            // controller.complete();
                                                                          },
                                                                        ),
                                                                ),
                                                              ),
                                                            ))
                                                        : data.chat!.messageType ==
                                                                "audio"
                                                            ? _audioReply(
                                                                message: data
                                                                    .chat!.url!,
                                                                index: index,
                                                                duration: data
                                                                    .chat!
                                                                    .audioTime!)
                                                            : data.chat!.messageType ==
                                                                    "link"
                                                                ? Container(
                                                                    constraints: BoxConstraints(
                                                                        maxHeight:
                                                                            MediaQuery.of(context).size.height /
                                                                                9.3,
                                                                        maxWidth:
                                                                            MediaQuery.of(context).size.width *
                                                                                .7),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      border: Border.all(
                                                                          color: Colors
                                                                              .grey
                                                                              .shade200),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                    ),
                                                                    child:
                                                                        InkWell(
                                                                      onTap:
                                                                          () {
                                                                        launchURL(data
                                                                            .chat!
                                                                            .message!);
                                                                      },
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Container(
                                                                            padding: const EdgeInsets.only(
                                                                                left: 5,
                                                                                right: 5,
                                                                                top: 5,
                                                                                bottom: 5),
                                                                            decoration:
                                                                                BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                                                                            child:
                                                                                FlutterLinkPreview(
                                                                              url: data.chat!.message!,
                                                                              builder: (info) {
                                                                                if (info is WebInfo) {
                                                                                  return info.title == null && info.description == null
                                                                                      ? Text(
                                                                                          data.chat!.message!,
                                                                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white),
                                                                                        )
                                                                                      : Row(
                                                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                                                          children: [
                                                                                            if (info.image != null)
                                                                                              Container(
                                                                                                height: 50,
                                                                                                width: 50,
                                                                                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                                                                                                child: ClipRRect(
                                                                                                  borderRadius: BorderRadius.circular(10),
                                                                                                  child: Image.network(info.image!, fit: BoxFit.cover),
                                                                                                ),
                                                                                              ),
                                                                                            const SizedBox(width: 5),
                                                                                            Expanded(
                                                                                              child: Column(
                                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                children: [
                                                                                                  if (info.title != null)
                                                                                                    Text(
                                                                                                      info.title!,
                                                                                                      maxLines: 1,
                                                                                                      overflow: TextOverflow.ellipsis,
                                                                                                      style: const TextStyle(
                                                                                                        fontSize: 14,
                                                                                                        fontWeight: FontWeight.w600,
                                                                                                      ),
                                                                                                    ).paddingAll(2),
                                                                                                  info.image == null ? const SizedBox(height: 5) : const SizedBox.shrink(),
                                                                                                  if (info.description != null)
                                                                                                    Text(
                                                                                                      info.description!,
                                                                                                      maxLines: 2,
                                                                                                      overflow: TextOverflow.ellipsis,
                                                                                                      style: const TextStyle(color: Color.fromRGBO(68, 68, 68, 1), fontSize: 9, fontWeight: FontWeight.w400),
                                                                                                    ),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        );
                                                                                }
                                                                                return const CircularProgressIndicator();
                                                                              },
                                                                              titleStyle: const TextStyle(
                                                                                color: Colors.black,
                                                                                fontWeight: FontWeight.bold,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                              height: 3),
                                                                          Text(
                                                                            data.chat!.message!,
                                                                            maxLines:
                                                                                1,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            style: TextStyle(
                                                                                color: linkColor,
                                                                                fontSize: 10,
                                                                                fontWeight: FontWeight.w400),
                                                                          ).paddingOnly(
                                                                              left: 10)
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  )
                                                                : data.chat!.messageType ==
                                                                        "gif"
                                                                    ? InkWell(
                                                                        onTap:
                                                                            () {
                                                                          Navigator
                                                                              .push(
                                                                            context,
                                                                            PageTransition(
                                                                                curve: Curves.linear,
                                                                                type: PageTransitionType.rightToLeft,
                                                                                child: ImageView(
                                                                                  image: data.chat!.url!,
                                                                                  userimg: "",
                                                                                )),
                                                                          );
                                                                        },
                                                                        child: Container(
                                                                            height: 120,
                                                                            width: double.maxFinite,
                                                                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                                                                            child: ClipRRect(
                                                                              borderRadius: BorderRadius.circular(10),
                                                                              child: Image.network(
                                                                                data.chat!.url!,
                                                                                fit: BoxFit.cover,
                                                                              ),
                                                                            )),
                                                                      )
                                                                    : data.chat!.messageType ==
                                                                            "contact"
                                                                        ? Column(
                                                                            children: [
                                                                              Container(
                                                                                height: 50,
                                                                                width: 200,
                                                                                decoration: const BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)), color: Colors.white),
                                                                                child: Row(
                                                                                  children: [
                                                                                    const SizedBox(width: 20),
                                                                                    Container(
                                                                                      height: 30,
                                                                                      width: 30,
                                                                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(35)),
                                                                                      child: ClipRRect(
                                                                                        borderRadius: BorderRadius.circular(35),
                                                                                        child: CustomCachedNetworkImage(
                                                                                            imageUrl: data.chat!.sharedContactProfileImage!,
                                                                                            placeholderColor: chatownColor,
                                                                                            errorWidgeticon: const Icon(
                                                                                              Icons.groups,
                                                                                              size: 30,
                                                                                            )),
                                                                                      ),
                                                                                    ),
                                                                                    const SizedBox(width: 10),
                                                                                    Column(
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                      children: [
                                                                                        Text(
                                                                                          capitalizeFirstLetter(data.chat!.sharedContactName!),
                                                                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: chatColor),
                                                                                        ),
                                                                                        Text(
                                                                                          capitalizeFirstLetter(data.chat!.sharedContactNumber!),
                                                                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: chatColor),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              const SizedBox(height: 3),
                                                                              Container(
                                                                                height: 30,
                                                                                width: 200,
                                                                                decoration: const BoxDecoration(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)), color: Colors.white),
                                                                                child: const Column(
                                                                                  children: [
                                                                                    SizedBox(height: 3),
                                                                                    Text(
                                                                                      "Message",
                                                                                      textAlign: TextAlign.center,
                                                                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: chatColor),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              )
                                                                            ],
                                                                          )
                                                                        : const SizedBox(),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 15,
                        color: Colors.grey.shade500,
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        convertUTCTimeTo12HourFormat(data.createdAt!),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
          ],
        ),
      ),
    ).paddingOnly(bottom: 10);
  }

  Widget myVoiceWidget(String audiourl, int index, String audioduration,
      messageSeen, timestamp, isStarted, StarMessageList data) {
    return Container(
      padding: const EdgeInsets.only(right: 12, top: 0, bottom: 0),
      child: Column(
        children: [
          Column(
            children: [
              _audio(
                  message: audiourl,
                  index: index,
                  duration: audioduration.toString(),
                  data: data),
              Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: SizedBox(
                    child: timestpa(messageSeen!, timestamp!, isStarted!),
                  ))
            ],
          ),
          const SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }

  Widget _audio(
      {required String message,
      required int index,
      required String duration,
      required StarMessageList data}) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      height: 65,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: data.chat!.user!.userId == Hive.box(userdata).get(userId)
            ? yellow1Color
            : Colors.grey.shade200,
      ),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: Colors.white),
        child: Row(
          children: [
            const SizedBox(width: 5),
            GestureDetector(
              onTap: () {
                setState(() {
                  audioController.onPressedPlayButton(index, message);
                });
              },
              onSecondaryTap: () {
                audioPlayer.stop();
              },
              child: Obx(
                () => (audioController.isRecordPlaying &&
                        audioController.currentId == index)
                    ? Icon(
                        CupertinoIcons.pause_circle_fill,
                        color: data.chat!.user!.userId ==
                                Hive.box(userdata).get(userId)
                            ? yellow1Color
                            : grey1Color,
                      )
                    : Icon(
                        CupertinoIcons.play_circle_fill,
                        color: data.chat!.user!.userId ==
                                Hive.box(userdata).get(userId)
                            ? yellow1Color
                            : grey1Color,
                      ),
              ),
            ),
            const SizedBox(width: 5),
            Obx(
              () => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      LinearProgressIndicator(
                        minHeight: 5,
                        backgroundColor: Colors.grey,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.black),
                        value: (audioController.isRecordPlaying &&
                                audioController.currentId == index)
                            ? (audioController.totalDuration.value > 0
                                ? audioController.completedPercentage.value
                                : 0.0)
                            : 0.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              duration,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey),
            ),
            const SizedBox(width: 10)
          ],
        ),
      ),
    );
  }

  Widget _audioReply({
    required String message,
    required int index,
    required String duration,
  }) {
    return Row(
      children: [
        const SizedBox(width: 5),
        GestureDetector(
          onTap: () {
            setState(() {
              audioController.onPressedPlayButton(index, message);
            });
          },
          onSecondaryTap: () {
            audioPlayer.stop();
          },
          child: Obx(
            () => (audioController.isRecordPlaying &&
                    audioController.currentId == index)
                ? const Icon(
                    CupertinoIcons.pause_circle_fill,
                    color: appColorBlack,
                  )
                : const Icon(
                    CupertinoIcons.play_circle_fill,
                    color: appColorBlack,
                  ),
          ),
        ),
        const SizedBox(width: 5),
        Obx(
          () => Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  LinearProgressIndicator(
                    minHeight: 5,
                    backgroundColor: Colors.grey,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.black),
                    value: (audioController.isRecordPlaying &&
                            audioController.currentId == index)
                        ? (audioController.totalDuration.value > 0
                            ? audioController.completedPercentage.value
                            : 0.0)
                        : 0.0,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          duration,
          style: const TextStyle(
              fontSize: 10, fontWeight: FontWeight.w400, color: Colors.grey),
        ),
        const SizedBox(width: 10)
      ],
    ).paddingOnly(top: 5);
  }

  bool isStar = false;
  AddStarMsgModel starModel = AddStarMsgModel();
  removeStarApi(iD, StarMessageList data) async {
    setState(() {
      isStar = true;
    });
    try {
      var uri = Uri.parse(apiHelper.addStar);
      var request = http.MultipartRequest("POST", uri);
      Map<String, String> headers = {
        'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
        "Accept": "application/json",
      };

      //add headers
      request.headers.addAll(headers);
      request.fields['message_id'] = iD.toString();
      request.fields['remove_from_star'] = true.toString();
      var response = await request.send();

      String responseData =
          await response.stream.transform(utf8.decoder).join();
      var useData = json.decode(responseData);

      starModel = AddStarMsgModel.fromJson(useData);

      if (starModel.success == true) {
        allStaredMsgController.allStarred.remove(data);
        setState(() {
          isStar = false;
        });
        showCustomToast(starModel.message!);
      } else {
        setState(() {
          isStar = false;
        });
      }
    } catch (e) {
      print(e.toString());
      showCustomToast(e.toString());
      setState(() {
        isStar = false;
      });
    } finally {
      setState(() {
        isStar = false;
      });
    }
  }
}
