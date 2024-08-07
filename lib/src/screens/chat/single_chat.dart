// ignore_for_file: must_be_immutable, avoid_print, non_constant_identifier_names, unused_field

import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:enough_giphy_flutter/enough_giphy_flutter.dart';
import 'package:enough_giphy_flutter/enough_giphy_widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lecle_flutter_link_preview/lecle_flutter_link_preview.dart';
import 'package:lottie/lottie.dart';
import 'package:meyaoo_new/controller/audio_controller.dart';
import 'package:meyaoo_new/controller/call_controller.dart/get_roomId_controller.dart';
import 'package:meyaoo_new/controller/online_controller.dart';
import 'package:meyaoo_new/controller/single_chat_controller.dart';
import 'package:meyaoo_new/controller/user_chatlist_controller.dart';
import 'package:meyaoo_new/src/global/global.dart';
import 'package:meyaoo_new/src/global/strings.dart';
import 'package:meyaoo_new/src/screens/Onlichat/ChatOnline.dart';
import 'package:meyaoo_new/src/screens/call/web_rtc/audio_call_screen.dart';
import 'package:meyaoo_new/src/screens/call/web_rtc/video_call_screen.dart';
import 'package:meyaoo_new/src/screens/chat/ChatProfile.dart';
import 'package:meyaoo_new/src/screens/chat/FileView.dart';
import 'package:meyaoo_new/src/screens/chat/chatvideo.dart';
import 'package:meyaoo_new/src/screens/chat/contact_send.dart';
import 'package:meyaoo_new/src/screens/chat/imageView.dart';
import 'package:meyaoo_new/src/screens/forward_message/forward_message_list.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:place_picker/place_picker.dart';
import 'package:record_mp3/record_mp3.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:meyaoo_new/model/chatdetails/single_chat_list_model.dart';
import 'package:light_compressor/light_compressor.dart';
import 'package:path/path.dart' as path;
import 'package:video_thumbnail/video_thumbnail.dart';

class SingleChatMsg extends StatefulWidget {
  String? conversationID;
  String? mobileNum;
  String? username;
  String? userPic;
  int? index;
  String? searchText;
  String? searchTime;
  bool? isBlock;
  String? messageId;
  bool? isMsgHighLight;
  String? userID;
  SingleChatMsg(
      {super.key,
      this.conversationID,
      this.mobileNum,
      this.username,
      this.userPic,
      this.index,
      this.searchText,
      this.searchTime,
      this.isBlock,
      this.messageId,
      this.isMsgHighLight,
      this.userID});

  @override
  State<SingleChatMsg> createState() => _SingleChatMsgState();
}

class _SingleChatMsgState extends State<SingleChatMsg> {
  Timer? timer;
  OnlineOfflineController controller = Get.find();
  SingleChatContorller chatContorller = Get.put(SingleChatContorller());
  RoomIdController getRoomController = Get.put(RoomIdController());
  ChatListController chatListController = Get.put(ChatListController());
  ValueNotifier<bool> isLast = ValueNotifier(false);

  @override
  void initState() {
    print("ID:${widget.conversationID}");
    print("MOBILE:${widget.mobileNum}");
    print("NAME:${widget.username}");
    print("PIC:${widget.userPic}");
    print("INDEX:${widget.index}");
    print("BLOCK:${widget.isBlock}");
    print("MSGID:${widget.messageId}");
    print("HIGHLIGHT:${widget.isMsgHighLight}");
    print("USERID:${widget.userID}");
    initlizedcontroller();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      chatContorller.getdetailschat(widget.conversationID);
      if (widget.messageId != null) {
        for (int i = 0;
            i < chatContorller.userdetailschattModel.value!.messageList!.length;
            i++) {
          if (widget.messageId.toString() ==
              chatContorller
                  .userdetailschattModel.value!.messageList![i].messageId
                  .toString()) {
            gotoindex = i;
            print("GOTOINDEX1:$gotoindex");
            _scrollToIndex(gotoindex, callback: () {
              setState(() {
                highlightedIndex = gotoindex;
                widget.isMsgHighLight = true;
              });
              Timer(const Duration(seconds: 2), () {
                setState(() {
                  widget.isMsgHighLight = false;
                });
              });
            });
            print("GOTOINDEX: $gotoindex");
          }
        }
      }
      // else {
      //   scrollController.addListener(() {
      //     // you can try _controller.position.atEdge
      //     if (scrollController.position.pixels >=
      //         scrollController.position.maxScrollExtent - 100) {
      //       //100 is item height
      //       isLast.value = true;
      //     } else {
      //       isLast.value = false;
      //     }
      //   });
      // SchedulerBinding.instance.addPostFrameCallback((_) {
      //   scrollController.jumpTo(scrollController.position.maxScrollExtent);
      // });
      // }
      // if (widget.messageId != null) {
      //   int? messageIndex = chatContorller
      //       .userdetailschattModel.value!.messageList!
      //       .indexWhere((message) =>
      //           message.messageId.toString() ==
      //           widget.messageId
      //               .toString()); // Adjust this condition based on your message model
      //   print("MATCHINDEX:$messageIndex");
      //   if (messageIndex != -1) {
      //     gotoindex = messageIndex;
      //     _scrollToIndex(gotoindex, callback: () {
      //       setState(() {
      //         highlightedIndex = gotoindex;
      //         widget.isMsgHighLight = true;
      //         print(widget.isMsgHighLight = true);
      //       });
      //       Timer(const Duration(seconds: 2), () {
      //         setState(() {
      //           widget.isMsgHighLight = false;
      //         });
      //       });
      //     });
      //   }
      // }
    });
    super.initState();
  }

  List? chatMsgList;

  List chatID = [];
  final TextEditingController _searchController = TextEditingController();
  TextEditingController messagecontroller = TextEditingController();
  AudioPlayer audioPlayer = AudioPlayer();
  AudioController audioController = Get.put(AudioController());
  bool isKeyboard = false;
  String isSelectedmessage = "0";
  String isSearchSelect = "0";
  String isTextFieldHide = '0';
  bool isSendbutton = false;
  bool isHttpSendbutton = false;

  // After sending a new message, scroll to the last message
  //SCROLL TO SPECIFIC INDEX
  bool isScroll = true;
  final scrollDirection = Axis.vertical;
  int? gotoindex;
  AutoScrollController? listScrollController;
  List<List<int>>? randomList;

  _scrollToIndex(index, {Function? callback}) async {
    if (index == 0) {
      // SchedulerBinding.instance.addPostFrameCallback((_) {
      //   scrollController.jumpTo(scrollController.position.maxScrollExtent);
      // });

      // await listScrollController?.scrollToIndex(
      //     chatContorller.userdetailschattModel.value!.messageList!.length - 1,
      //     duration: const Duration(milliseconds: 50),
      //     preferPosition: AutoScrollPosition.end);
      // if (callback != null) {
      //   callback();
      // }
    } else {
      await listScrollController?.scrollToIndex(index,
          duration: const Duration(milliseconds: 50),
          preferPosition: AutoScrollPosition.begin);
      if (callback != null) {
        callback();
      }
    }
  }

  initlizedcontroller() async {
    listScrollController = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: scrollDirection);
    listScrollController?.addListener(hideKeyboard);

    // Scroll to the end of the list if widget.index is 0
    // if (widget.index == 0) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     listScrollController?.scrollToIndex(
    //         chatContorller.userdetailschattModel.value!.messageList!.length,
    //         preferPosition: AutoScrollPosition.end);
    //   });
    // } else if (widget.index != null) {
    if (widget.index != 0) {
      await listScrollController?.scrollToIndex(
          chatContorller.userdetailschattModel.value!.messageList!.length,
          preferPosition: AutoScrollPosition.end);
    }
  }

  hideKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  double HEIGHT = 96;
  final ValueNotifier<double> notifier = ValueNotifier(0);

  String? banner;

  bool isMsgHighLight = false;
  int? highlightedIndex;

  String chatdate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  // Create a ValueNotifier to hold the date string
  ValueNotifier<String> dateNotifier = ValueNotifier<String>("");

  bool isKeyboardOpen() {
    return MediaQuery.of(context).viewInsets.bottom != 0;
  }

  String isUserOnline(String userID) {
    for (var i = 0; i < controller.allOffline.length; i++) {
      if (userID == controller.allOffline[i].userId.toString()) {
        return formatLastSeen(controller.allOffline[i].updatedAt!);
      }
    }
    return '0';
  }

  @override
  void dispose() {
    timer?.cancel();
    // chatContorller.userdetailschattModel.value!.messageList = null;
    // chatContorller.userdetailschattModel.value!.messageList!.clear();
    // chatContorller.userdetailschattModel = SingleChatListModel().obs;
    chatContorller.onClose();
    super.dispose();
  }

  String typingstart = "0";
  Timer? typingTimer;
  void resetTypingStatus() {
    setState(() {
      typingstart = "0";
    });
  }

  void startTypingTimer() {
    print("START-TYPING");
    typingTimer = Timer(const Duration(seconds: 3), () {
      chatContorller.isTypingApi(widget.conversationID!, "0");
      controller.isTyping();
      resetTypingStatus();
    });
  }

  final ScrollController scrollController = ScrollController();
  int inx = 0;

  @override
  Widget build(BuildContext context) {
    bool isKeyboard = isKeyboardOpen();
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: isSelectedmessage == "0"
            ? (isSearchSelect == "0"
                ? _appbar(context)
                : _appbarSearch(context))
            : _appbar1(context),
        body: Obx(() {
          return chatContorller.isLoading.value
              ? loader(context)
              :
              // chatContorller.userdetailschattModel.value?.messageList ==
              //             null ||
              Column(
                  children: [
                    Flexible(
                        child: Stack(
                      children: [
                        NotificationListener<ScrollNotification>(
                            onNotification: (n) {
                              if (n.metrics.pixels <= HEIGHT) {
                                notifier.value = n.metrics.pixels;

                                // Calculate the index of the first visible message
                                int firstVisibleIndex = (n.metrics.pixels /
                                        (HEIGHT /
                                            chatContorller.userdetailschattModel
                                                .value!.messageList!.length))
                                    .floor();
                                if (firstVisibleIndex <
                                    chatContorller.userdetailschattModel.value!
                                        .messageList!.length) {
                                  String formattedDate = chatContorller
                                              .userdetailschattModel
                                              .value!
                                              .messageList![firstVisibleIndex]
                                              .messageType ==
                                          'date'
                                      ? formatDate(convertToLocalDate(
                                          chatContorller
                                              .userdetailschattModel
                                              .value!
                                              .messageList![firstVisibleIndex]
                                              .message))
                                      : "";
                                  dateNotifier.value = formattedDate;
                                }
                              }
                              return false;
                            },
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: chatContorller.userdetailschattModel.value!
                                          .messageList!.isEmpty ||
                                      chatContorller
                                              .userdetailschattModel
                                              .value!
                                              .messageList!
                                              .first
                                              .message ==
                                          null
                                  ? Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15),
                                        child: Column(
                                          children: [
                                            SizedBox(
                                                height: isKeyboard
                                                    ? MediaQuery.sizeOf(context)
                                                            .height *
                                                        0.3
                                                    : MediaQuery.sizeOf(context)
                                                            .height *
                                                        0.4),
                                            InkWell(
                                              onTap: () {
                                                //sendApiBydefult();
                                                widget.isBlock == true
                                                    ? showCustomToast(
                                                        "User bloked")
                                                    : widget.mobileNum ==
                                                                null &&
                                                            widget.mobileNum ==
                                                                ""
                                                        ? chatContorller
                                                            .sendMessageText(
                                                                "Hi",
                                                                widget
                                                                    .conversationID!,
                                                                "text",
                                                                widget.mobileNum
                                                                    .toString())
                                                        : chatContorller
                                                            .sendMessageText(
                                                                "Hi",
                                                                widget
                                                                    .conversationID!,
                                                                "text",
                                                                "");
                                              },
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    1.5,
                                                decoration: BoxDecoration(
                                                    color: const Color.fromARGB(
                                                        255, 238, 234, 234),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      15.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      RichText(
                                                          text: const TextSpan(
                                                              children: [
                                                            TextSpan(
                                                                text:
                                                                    "To Start Message Say  ",
                                                                style: TextStyle(
                                                                    color:
                                                                        chatColor,
                                                                    fontSize:
                                                                        13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w200)),
                                                            TextSpan(
                                                                text: "Hi!",
                                                                style: TextStyle(
                                                                    color:
                                                                        chatColor,
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500))
                                                          ]))
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  //____________ ALL MESSAGES _____________________

                                  : Padding(
                                      padding: const EdgeInsets.only(top: 5),
                                      child: _searchResult.isNotEmpty ||
                                              _searchController.text
                                                  .toLowerCase()
                                                  .isNotEmpty
                                          ? ListView.builder(
                                              shrinkWrap: true,
                                              reverse: true,
                                              controller: listScrollController,
                                              // physics:
                                              //     const BouncingScrollPhysics(),
                                              itemCount: _searchResult.length,
                                              itemBuilder: (context, index) {
                                                return buildItem(index,
                                                    _searchResult[index]);
                                              })
                                          : ListView.builder(
                                              shrinkWrap: true,
                                              reverse: true,
                                              scrollDirection: Axis.vertical,
                                              controller: listScrollController,
                                              // physics:
                                              //     const BouncingScrollPhysics(),
                                              itemCount: chatContorller
                                                  .userdetailschattModel
                                                  .value!
                                                  .messageList!
                                                  .length,
                                              itemBuilder: (context, index) {
                                                print(
                                                    "LISTTTTTT:${chatContorller.userdetailschattModel.value!.messageList!.length}");
                                                for (int i = 0;
                                                    i <
                                                        chatContorller
                                                            .userdetailschattModel
                                                            .value!
                                                            .messageList!
                                                            .length;
                                                    i++) {
                                                  if (isScroll == true) {
                                                    gotoindex = i;
                                                    _scrollToIndex(gotoindex);
                                                    isScroll = false;
                                                  }
                                                }
                                                return AutoScrollTag(
                                                    key: ValueKey(index),
                                                    controller:
                                                        listScrollController!,
                                                    index: index,
                                                    child: buildItem(
                                                        index,
                                                        chatContorller
                                                            .userdetailschattModel
                                                            .value!
                                                            .messageList![index]));
                                              },
                                            ),
                                    ),
                            )),
                        // sticky date
                        // Padding(
                        //   padding: const EdgeInsets.only(top: 100),
                        //   child: ValueListenableBuilder<double>(
                        //     valueListenable: notifier,
                        //     builder: (context, value, child) {
                        //       return Transform.translate(
                        //         offset: Offset(0, value - HEIGHT),
                        //         child: Row(
                        //           mainAxisAlignment: MainAxisAlignment.center,
                        //           children: [
                        //             Container(
                        //               decoration: BoxDecoration(
                        //                   color: Colors.grey[300],
                        //                   borderRadius: const BorderRadius.all(
                        //                       Radius.circular(20))),
                        //               height: 35,
                        //               // width: 120,
                        //               child: Padding(
                        //                 padding: const EdgeInsets.only(
                        //                     left: 10, right: 10),
                        //                 child: Row(
                        //                   mainAxisAlignment:
                        //                       MainAxisAlignment.center,
                        //                   crossAxisAlignment:
                        //                       CrossAxisAlignment.center,
                        //                   children: [
                        //                     Padding(
                        //                       padding:
                        //                           const EdgeInsets.only(top: 0),
                        //                       child: ValueListenableBuilder<
                        //                           String>(
                        //                         valueListenable: dateNotifier,
                        //                         builder:
                        //                             (context, date, child) {
                        //                           print("DATETIME: $date");
                        //                           return Text(
                        //                             date,
                        //                             style: const TextStyle(
                        //                               color: Colors.black,
                        //                               fontSize: 12,
                        //                               fontWeight:
                        //                                   FontWeight.bold,
                        //                             ),
                        //                           );
                        //                         },
                        //                       ),
                        //                     )
                        //                   ],
                        //                 ),
                        //               ),
                        //             )
                        //           ],
                        //         ),
                        //       );
                        //     },
                        //   ),
                        // ),
                        // arrow down button
                        Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: ValueListenableBuilder<double>(
                            valueListenable: notifier,
                            builder: (context, value, child) {
                              return Transform.translate(
                                  offset: const Offset(0, 0),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 0, right: 0),
                                    child: value < 1
                                        ? Container()
                                        : Align(
                                            alignment: Alignment.bottomCenter,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.grey[200],
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(40))),
                                              height: 40,
                                              width: 40,
                                              child: IconButton(
                                                onPressed: () {
                                                  // _animateToIndex(20);
                                                  listScrollController!.jumpTo(
                                                      listScrollController!
                                                          .position
                                                          .minScrollExtent);
                                                },
                                                icon: const Icon(
                                                    Icons.arrow_circle_down),
                                              ),
                                            ),
                                          ),
                                  ));
                            },
                          ),
                        ),

                        //========================= for reply design
                        //========================= for reply design
                        SelectedreplyText
                            ? Positioned(
                                bottom: 0,
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.99,
                                  // height: 73,
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(00.0),
                                          topLeft: Radius.circular(00.0))),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Divider(
                                        height: 1,
                                        thickness: 1,
                                        color: Colors.grey[200],
                                      ),
                                      Container(
                                        color: bg1,
                                        child: Row(
                                          children: [
                                            Container(
                                              height: 60,
                                              width: 8,
                                              decoration: const BoxDecoration(
                                                  color: chatownColor,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topRight:
                                                              Radius.circular(
                                                                  10.0),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  10.0))),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Container(
                                              height: 51,
                                              width: MediaQuery.sizeOf(context)
                                                      .width *
                                                  0.85,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(USERTEXT),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    capitalizeFirstLetter(
                                                        replyText),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: chatColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  SelectedreplyText = false;
                                                  print(SelectedreplyText);
                                                });
                                              },
                                              child: Container(
                                                height: 30,
                                                width: 30,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      color: appColorBlack),
                                                  // color: Colors.blue,
                                                ),
                                                child: const Icon(Icons.close,
                                                    color: appColorBlack),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : const SizedBox(),
                      ],
                    )),
                    chatContorller.isSendMsg.value
                        ? SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 40,
                            child: loader(context),
                          )
                        : const SizedBox(),
                    SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: chatListController.blockModel.value!.isBlock ==
                                true
                            ? Column(
                                children: [
                                  Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: Colors.grey[200],
                                  ),
                                  const SizedBox(height: 15),
                                  const Text(
                                    "User Blocked",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 17),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              )
                            : isTextFieldHide == "0"
                                ? (
                                    // widget.isBlocked == "1"
                                    //   ? const Text(
                                    //       "You Have Blocked This user",
                                    //       textAlign: TextAlign.center,
                                    //     )
                                    //   :
                                    isSelectedmessage == "0"
                                        ? floatbutton()
                                        // when isSelectedmessage == "1" then forward option show
                                        : floatbutton1())
                                : const SizedBox.shrink())
                  ],
                );
        }));
  }

  Widget buildItem(int index, MessageList data) {
    switch (data.messageType) {
      case 'text':
        return data.replyId == 0
            ? getTextMessageWidget(index, data)
            : getReplyMessage(index, data);
      case 'image':
        return data.replyId == 0
            ? getImgMessageWidget(index, data)
            : getReplyMessage(index, data);
      case 'location':
        return data.replyId == 0
            ? getLocationMessageWidget(index, data)
            : getReplyMessage(index, data);
      case 'video':
        return data.replyId == 0
            ? getVideoMessageWidget(index, data)
            : getReplyMessage(index, data);
      case 'document':
        return data.replyId == 0
            ? getDocMessageWidget(index, data)
            : getReplyMessage(index, data);
      case 'audio':
        return data.replyId == 0
            ? getVoiceMessageWidget(index, data)
            : getReplyMessage(index, data);
      case 'gif':
        return data.replyId == 0
            ? getGifMessage(index, data)
            : getReplyMessage(index, data);
      case 'link':
        return data.replyId == 0
            ? getHttpLinkMessage(index, data)
            : getReplyMessage(index, data);
      case 'contact':
        return data.replyId == 0
            ? getContactMessage(index, data)
            : getReplyMessage(index, data);
      case 'date':
        return getDateWidget(index, data);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget getDateWidget(index, MessageList data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Stack(
        children: [
          Column(
            children: [
              Align(
                alignment: (Alignment.topCenter),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * .6),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.grey.shade200),
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            formatDate(convertToLocalDate(data.message!)),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget getTextMessageWidget(index, MessageList data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onLongPress: () {
          msgDailogShow(
              //message
              data.message!,
              // chat id
              data.messageId.toString(),
              // chat user id
              data.conversationId.toString(),
              data.messageType!,
              "0",
              // snapshot
              //     .data!
              //     .messageList![index1]
              //     .messages![index]
              //     .isStarted!,
              data.isStarMessage!,
              index,
              data.myMessage!,
              data.senderData!);
        },
        onTap: () {
          if (chatID.isNotEmpty) {
            setState(() {
              chatID.contains(data.messageId.toString())
                  ? chatID.remove(data.messageId.toString())
                  : chatID.add(data.messageId.toString());
            });
          }
          print("ONTAPMSGID:$chatID");
        },
        child: Stack(
          children: [
            isSelectedmessage == "1"
                ? Positioned(
                    left: 10,
                    bottom: 35,
                    child: GestureDetector(
                        onTap: () {
                          // Handle checkbox state change if needed
                          setState(() {
                            chatID.contains(data.messageId.toString())
                                ? chatID.remove(data.messageId.toString())
                                : chatID.add(data.messageId.toString());
                          });
                          print("ONTAPMSGID:$chatID");
                        },
                        child: chatID.isEmpty
                            ? const SizedBox()
                            : Transform.scale(
                                scale: 1.1,
                                child: GestureDetector(
                                  child: Container(
                                      width: 20.0,
                                      height: 20.0,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          border: Border.all(color: bg1),
                                          color: chatID.contains(
                                                  data.messageId.toString())
                                              ? bg1
                                              : bg1),
                                      child: chatID.contains(
                                              data.messageId.toString())
                                          ? const Icon(
                                              Icons.check,
                                              size: 15.0,
                                              color: Colors.black,
                                            )
                                          : const SizedBox(
                                              height: 10,
                                            )),
                                ))),
                  )
                : const SizedBox(
                    height: 10,
                  ),
            Container(
                padding: EdgeInsets.only(
                    left: chatID.isNotEmpty
                        ? data.myMessage == false
                            ? 40
                            : 12
                        : 12,
                    right: 12,
                    top: 0,
                    bottom: 0),
                color: highlightedIndex == index &&
                        (isMsgHighLight == false
                            ? widget.isMsgHighLight!
                            : isMsgHighLight)
                    ? chatStrokeColor // for when reply msg scoll then
                    : Colors.transparent,
                child: Column(
                  children: [
                    Align(
                      alignment: (data.myMessage == false
                          ? Alignment.topLeft
                          : Alignment.topRight),
                      child: Column(
                        crossAxisAlignment: data.myMessage == false
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.end,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width * .6),
                                decoration: BoxDecoration(
                                  borderRadius: data.myMessage == false
                                      ? BorderRadius.circular(15)
                                      : BorderRadius.circular(15),
                                  color: data.myMessage == false
                                      ? Colors.grey.shade200
                                      : chatownColor,
                                ),
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  capitalizeFirstLetter(data.message!),
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: chatColor),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: SizedBox(
                                child: timestpa(data.messageRead.toString(),
                                    data.createdAt!, data.isStarMessage!),
                              ))
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget getImgMessageWidget(index, MessageList data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onLongPress: () {
          msgDailogShow(
              //message
              data.message!,
              // chat id
              data.messageId.toString(),
              // chat user id
              data.conversationId.toString(),
              data.messageType!,
              "0",
              // snapshot
              //     .data!
              //     .messageList![index1]
              //     .messages![index]
              //     .isStarted!,
              data.isStarMessage!,
              index,
              data.myMessage!,
              data.senderData!);
        },
        onTap: () {
          if (chatID.isNotEmpty) {
            setState(() {
              chatID.contains(data.messageId.toString())
                  ? chatID.remove(data.messageId.toString())
                  : chatID.add(data.messageId.toString());
            });
          }
        },
        child: Stack(
          children: [
            isSelectedmessage == "1"
                ? Positioned(
                    left: 10,
                    bottom: 35,
                    child: GestureDetector(
                        onTap: () {
                          // Handle checkbox state change if needed
                          setState(() {
                            chatID.contains(data.messageId.toString())
                                ? chatID.remove(data.messageId.toString())
                                : chatID.add(data.messageId.toString());
                          });
                          print("ONTAPMSGID:$chatID");
                        },
                        child: chatID.isEmpty
                            ? const SizedBox()
                            : Transform.scale(
                                scale: 1.1,
                                child: GestureDetector(
                                  child: Container(
                                      width: 20.0,
                                      height: 20.0,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          border: Border.all(color: bg1),
                                          color: chatID.contains(
                                                  data.messageId.toString())
                                              ? bg1
                                              : bg1),
                                      child: chatID.contains(
                                              data.messageId.toString())
                                          ? const Icon(
                                              Icons.check,
                                              size: 15.0,
                                              color: Colors.black,
                                            )
                                          : const SizedBox(
                                              height: 10,
                                            )),
                                ))),
                  )
                : const SizedBox(height: 10),
            Container(
              padding: EdgeInsets.only(
                  left: chatID.isNotEmpty
                      ? data.myMessage == false
                          ? 40
                          : 12
                      : 12,
                  right: 12,
                  top: 0,
                  bottom: 0),
              color: highlightedIndex == index &&
                      (isMsgHighLight == false
                          ? widget.isMsgHighLight!
                          : isMsgHighLight)
                  ? chatStrokeColor // for when reply msg scoll then
                  : Colors.transparent,
              child: Align(
                alignment: data.myMessage == false
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: data.myMessage == false
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageTransition(
                              curve: Curves.linear,
                              type: PageTransitionType.rightToLeft,
                              child: ImageView(
                                image: data.url!,
                                userimg: "",
                              )),
                        );
                      },
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: data.myMessage == false
                              ? BorderRadius.circular(15)
                              : BorderRadius.circular(15),
                          color: data.myMessage == false
                              ? Colors.grey.shade200
                              : chatownColor,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: CachedNetworkImage(
                              imageUrl: data.url!,
                              imageBuilder: (context, imageProvider) => Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              placeholder: (context, url) => const Center(
                                child: CupertinoActivityIndicator(),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: SizedBox(
                          child: timestpa(data.messageRead.toString(),
                              data.createdAt!, data.isStarMessage!),
                        ))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getLocationMessageWidget(index, MessageList data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onLongPress: () {
          msgDailogShow(
              //message
              data.message!,
              // chat id
              data.messageId.toString(),
              // chat user id
              data.conversationId.toString(),
              data.messageType!,
              "0",
              // snapshot
              //     .data!
              //     .messageList![index1]
              //     .messages![index]
              //     .isStarted!,
              data.isStarMessage!,
              index,
              data.myMessage!,
              data.senderData!);
        },
        onTap: () {
          if (chatID.isNotEmpty) {
            setState(() {
              chatID.contains(data.messageId.toString())
                  ? chatID.remove(data.messageId.toString())
                  : chatID.add(data.messageId.toString());
            });
          }
        },
        child: Stack(
          children: [
            isSelectedmessage == "1"
                ? Positioned(
                    left: 10,
                    bottom: 35,
                    child: GestureDetector(
                        onTap: () {
                          // Handle checkbox state change if needed
                          setState(() {
                            chatID.contains(data.messageId.toString())
                                ? chatID.remove(data.messageId.toString())
                                : chatID.add(data.messageId.toString());
                          });
                          print("ONTAPMSGID:$chatID");
                        },
                        child: chatID.isEmpty
                            ? const SizedBox()
                            : Transform.scale(
                                scale: 1.1,
                                child: GestureDetector(
                                  child: Container(
                                      width: 20.0,
                                      height: 20.0,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          border: Border.all(color: bg1),
                                          color: chatID.contains(
                                                  data.messageId.toString())
                                              ? bg1
                                              : bg1),
                                      child: chatID.contains(
                                              data.messageId.toString())
                                          ? const Icon(
                                              Icons.check,
                                              size: 15.0,
                                              color: Colors.black,
                                            )
                                          : const SizedBox(
                                              height: 10,
                                            )),
                                ))),
                  )
                : const SizedBox(height: 10),
            Container(
              color: highlightedIndex == index &&
                      (isMsgHighLight == false
                          ? widget.isMsgHighLight!
                          : isMsgHighLight)
                  ? chatStrokeColor // for when reply msg scoll then
                  : Colors.transparent,
              child: Align(
                alignment: data.myMessage == false
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(
                      left: chatID.isNotEmpty
                          ? data.myMessage == false
                              ? 40
                              : 12
                          : 12,
                      right: 12,
                      top: 0,
                      bottom: 0),
                  child: InkWell(
                    onTap: () {},
                    child: Stack(
                      alignment: data.myMessage == false
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      children: [
                        Column(
                          crossAxisAlignment: data.myMessage == false
                              ? CrossAxisAlignment.start
                              : CrossAxisAlignment.end,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: data.myMessage == false
                                    ? Colors.grey.shade200
                                    : chatownColor,
                              ),
                              constraints: const BoxConstraints(
                                  minHeight: 10.0,
                                  minWidth: 10.0,
                                  maxWidth: 250),
                              child: Container(
                                height: 180,
                                width: 180,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10)),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10)),
                                  child: data.latitude.toString() == "" ||
                                          data.longitude.toString() == ""
                                      ? Container(
                                          decoration: const BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  topRight:
                                                      Radius.circular(10)),
                                              image: DecorationImage(
                                                  image: AssetImage(
                                                      "assets/images/map_Blurr.png"),
                                                  fit: BoxFit.cover)),
                                          child: Icon(
                                            Icons.error_outline,
                                            color:
                                                chatownColor.withOpacity(0.6),
                                            size: 50,
                                          ),
                                        )
                                      : GoogleMap(
                                          zoomControlsEnabled: false,
                                          zoomGesturesEnabled: false,
                                          initialCameraPosition: CameraPosition(
                                              target: LatLng(
                                                  double.parse(data.latitude!),
                                                  double.parse(
                                                      data.longitude!)),
                                              zoom: 15),
                                          mapType: MapType.normal,
                                          onMapCreated: (GoogleMapController
                                              controller111) {
                                            // controller.complete();
                                          },
                                        ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                MapUtils.openMap(double.parse(data.latitude!),
                                    double.parse(data.longitude!));
                              },
                              child: Stack(
                                children: [
                                  Container(
                                    height: 40,
                                    width: 180,
                                    decoration: BoxDecoration(
                                        color: data.myMessage == false
                                            ? Colors.grey.shade200
                                            : chatownColor,
                                        borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10))),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text("View Location",
                                              style: TextStyle(
                                                color: chatColor,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                              )),
                                          data.messageType!
                                                      .contains(".started") ==
                                                  true
                                              ? const Padding(
                                                  padding:
                                                      EdgeInsets.only(right: 5),
                                                  child: Icon(
                                                      CupertinoIcons.star_fill,
                                                      size: 12,
                                                      color: Colors.black),
                                                )
                                              : const SizedBox(),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: SizedBox(
                                  child: timestpa(data.messageRead.toString(),
                                      data.createdAt!, data.isStarMessage!),
                                ))
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getVideoMessageWidget(index, MessageList data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onLongPress: () {
          msgDailogShow(
              //message
              data.message!,
              // chat id
              data.messageId.toString(),
              // chat user id
              data.conversationId.toString(),
              data.messageType!,
              "0",
              // snapshot
              //     .data!
              //     .messageList![index1]
              //     .messages![index]
              //     .isStarted!,
              data.isStarMessage!,
              index,
              data.myMessage!,
              data.senderData!);
        },
        onTap: () {
          if (chatID.isNotEmpty) {
            setState(() {
              chatID.contains(data.messageId.toString())
                  ? chatID.remove(data.messageId.toString())
                  : chatID.add(data.messageId.toString());
            });
          }
        },
        child: Stack(
          children: [
            isSelectedmessage == "1"
                ? Positioned(
                    left: 10,
                    bottom: 35,
                    child: GestureDetector(
                        onTap: () {
                          // Handle checkbox state change if needed
                          setState(() {
                            chatID.contains(data.messageId.toString())
                                ? chatID.remove(data.messageId.toString())
                                : chatID.add(data.messageId.toString());
                          });
                          print("ONTAPMSGID:$chatID");
                        },
                        child: chatID.isEmpty
                            ? const SizedBox()
                            : Transform.scale(
                                scale: 1.1,
                                child: GestureDetector(
                                  child: Container(
                                      width: 20.0,
                                      height: 20.0,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          border: Border.all(color: bg1),
                                          color: chatID.contains(
                                                  data.messageId.toString())
                                              ? bg1
                                              : bg1),
                                      child: chatID.contains(
                                              data.messageId.toString())
                                          ? const Icon(
                                              Icons.check,
                                              size: 15.0,
                                              color: Colors.black,
                                            )
                                          : const SizedBox(
                                              height: 10,
                                            )),
                                ))),
                  )
                : const SizedBox(height: 10),
            Container(
              padding: EdgeInsets.only(
                  left: chatID.isNotEmpty
                      ? data.myMessage == false
                          ? 40
                          : 12
                      : 12,
                  right: 12,
                  top: 0,
                  bottom: 0),
              color: highlightedIndex == index &&
                      (isMsgHighLight == false
                          ? widget.isMsgHighLight!
                          : isMsgHighLight)
                  ? chatStrokeColor // for when reply msg scoll then
                  : Colors.transparent,
              child: Align(
                alignment: data.myMessage == false
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoViewFix(
                            username:
                                "${capitalizeFirstLetter(data.senderData!.firstName!)} ${capitalizeFirstLetter(data.senderData!.lastName!)}",
                            url: data.url!,
                            play: true,
                            mute: false,
                            date: convertUTCTimeTo12HourFormat(data.createdAt!),
                          ),
                        ));
                  },
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: data.myMessage == false
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.end,
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 240,
                                height: 280,
                                decoration: BoxDecoration(
                                  borderRadius: data.myMessage == false
                                      ? BorderRadius.circular(15)
                                      : BorderRadius.circular(15),
                                  color: data.myMessage == false
                                      ? Colors.grey.shade200
                                      : chatownColor,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child:
                                        // video thumbnail generater
                                        //getUrlWidget(data.url!)
                                        CachedNetworkImage(
                                      imageUrl: data.thumbnail!,
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      placeholder: (context, url) =>
                                          const Center(
                                        child: CupertinoActivityIndicator(),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: SizedBox(
                                child: timestpa(data.messageRead.toString(),
                                    data.createdAt!, data.isStarMessage!),
                              ))
                        ],
                      ),
                      Positioned(
                          top: 100,
                          left: 84,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VideoViewFix(
                                      username:
                                          "${capitalizeFirstLetter(data.senderData!.firstName!)} ${capitalizeFirstLetter(data.senderData!.lastName!)}",
                                      url: data.url!,
                                      play: true,
                                      mute: false,
                                      date: convertUTCTimeTo12HourFormat(
                                          data.createdAt!),
                                    ),
                                  ));
                            },
                            child: CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.grey.shade300,
                                foregroundColor: chatownColor,
                                child: Image.asset("assets/images/play1.png",
                                    color: chatColor, height: 18)),
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getDocMessageWidget(index, MessageList data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, right: 10, left: 10),
      child: InkWell(
        onLongPress: () {
          msgDailogShow(
              //message
              data.message!,
              // chat id
              data.messageId.toString(),
              // chat user id
              data.conversationId.toString(),
              data.messageType!,
              "0",
              // snapshot
              //     .data!
              //     .messageList![index1]
              //     .messages![index]
              //     .isStarted!,
              data.isStarMessage!,
              index,
              data.myMessage!,
              data.senderData!);
        },
        onTap: () {
          if (chatID.isNotEmpty) {
            setState(() {
              chatID.contains(data.messageId.toString())
                  ? chatID.remove(data.messageId.toString())
                  : chatID.add(data.messageId.toString());
            });
          }
        },
        child: Stack(
          children: [
            isSelectedmessage == "1"
                ? Positioned(
                    left: 10,
                    bottom: 35,
                    child: GestureDetector(
                        onTap: () {
                          // Handle checkbox state change if needed
                          setState(() {
                            chatID.contains(data.messageId.toString())
                                ? chatID.remove(data.messageId.toString())
                                : chatID.add(data.messageId.toString());
                          });
                          print("ONTAPMSGID:$chatID");
                        },
                        child: chatID.isEmpty
                            ? const SizedBox()
                            : Transform.scale(
                                scale: 1.1,
                                child: GestureDetector(
                                  child: Container(
                                      width: 20.0,
                                      height: 20.0,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          border: Border.all(color: bg1),
                                          color: chatID.contains(
                                                  data.messageId.toString())
                                              ? bg1
                                              : bg1),
                                      child: chatID.contains(
                                              data.messageId.toString())
                                          ? const Icon(
                                              Icons.check,
                                              size: 15.0,
                                              color: Colors.black,
                                            )
                                          : const SizedBox(
                                              height: 10,
                                            )),
                                ))),
                  )
                : const SizedBox(height: 10),
            Container(
              color: highlightedIndex == index &&
                      (isMsgHighLight == false
                          ? widget.isMsgHighLight!
                          : isMsgHighLight)
                  ? chatStrokeColor // for when reply msg scoll then
                  : Colors.transparent,
              child: Align(
                  alignment: data.myMessage == false
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: data.myMessage == false
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: EdgeInsets.only(
                            left: chatID.isNotEmpty
                                ? data.myMessage == false
                                    ? 35
                                    : 10
                                : 5,
                            right: 12,
                            top: 0,
                            bottom: 0),
                        margin: const EdgeInsets.only(bottom: 5),
                        decoration: BoxDecoration(
                          borderRadius: data.myMessage == false
                              ? BorderRadius.circular(15)
                              : BorderRadius.circular(15),
                          color: data.myMessage == false
                              ? Colors.grey.shade200
                              : chatownColor,
                        ),
                        constraints: const BoxConstraints(
                            minHeight: 20.0, minWidth: 10.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    PageTransition(
                                      curve: Curves.linear,
                                      type: PageTransitionType.rightToLeft,
                                      child: FileView(file: "${data.url}"),
                                    ));
                              },
                              child: Container(
                                width: Get.width * 0.50,
                                padding: const EdgeInsets.all(5.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topRight: const Radius.circular(8.0),
                                    bottomRight: data.myMessage == false
                                        ? const Radius.circular(8)
                                        : const Radius.circular(0.0),
                                    topLeft: const Radius.circular(8.0),
                                    bottomLeft: data.myMessage == false
                                        ? const Radius.circular(0)
                                        : const Radius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Row(
                                      children: [
                                        Container(
                                            height: 35,
                                            width: 30,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: const Color(0xffCCCCCC),
                                            ),
                                            child: const Padding(
                                              padding: EdgeInsets.all(3.0),
                                              child: Image(
                                                image: AssetImage(
                                                    'assets/images/doc.png'),
                                              ),
                                            )),
                                        Container(
                                          padding:
                                              const EdgeInsets.only(left: 11),
                                          child: Text(
                                            extractFilename(data.url!)
                                                .toString()
                                                .split("-")
                                                .last,
                                            style: const TextStyle(
                                              color: chatColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 15)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      data.myMessage == false
                          ? SizedBox(
                              child: timestpa(data.messageRead.toString(),
                                  data.createdAt!, data.isStarMessage!),
                            )
                          : SizedBox(
                              child: timestpa(data.messageRead.toString(),
                                  data.createdAt!, data.isStarMessage!),
                            )
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget getVoiceMessageWidget(index, MessageList data) {
    return InkWell(
      onLongPress: () {
        msgDailogShow(
            //message
            data.message!,
            // chat id
            data.messageId.toString(),
            // chat user id
            data.conversationId.toString(),
            data.messageType!,
            "0",
            // snapshot
            //     .data!
            //     .messageList![index1]
            //     .messages![index]
            //     .isStarted!,
            data.isStarMessage!,
            index,
            data.myMessage!,
            data.senderData!);
      },
      onTap: () {
        if (chatID.isNotEmpty) {
          setState(() {
            chatID.contains(data.messageId.toString())
                ? chatID.remove(data.messageId.toString())
                : chatID.add(data.messageId.toString());
          });
        }
      },
      child: Stack(
        children: [
          isSelectedmessage == "1"
              ? Positioned(
                  left: 10,
                  bottom: 35,
                  child: GestureDetector(
                      onTap: () {
                        // Handle checkbox state change if needed
                        setState(() {
                          chatID.contains(data.messageId.toString())
                              ? chatID.remove(data.messageId.toString())
                              : chatID.add(data.messageId.toString());
                        });
                        print("ONTAPMSGID:$chatID");
                      },
                      child: chatID.isEmpty
                          ? const SizedBox()
                          : Transform.scale(
                              scale: 1.1,
                              child: GestureDetector(
                                child: Container(
                                    width: 20.0,
                                    height: 20.0,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(25),
                                        border: Border.all(color: bg1),
                                        color: chatID.contains(
                                                data.messageId.toString())
                                            ? bg1
                                            : bg1),
                                    child: chatID
                                            .contains(data.messageId.toString())
                                        ? const Icon(
                                            Icons.check,
                                            size: 15.0,
                                            color: Colors.black,
                                          )
                                        : const SizedBox(
                                            height: 10,
                                          )),
                              ))),
                )
              : const SizedBox(height: 10),
          Container(
            padding: EdgeInsets.only(
                left: chatID.isNotEmpty
                    ? data.myMessage == false
                        ? 40
                        : 0
                    : 10,
                right: 0,
                top: 0,
                bottom: 0),
            color: highlightedIndex == index &&
                    (isMsgHighLight == false
                        ? widget.isMsgHighLight!
                        : isMsgHighLight)
                ? chatStrokeColor // for when reply msg scoll then
                : Colors.transparent,
            child: myVoiceWidget(
                data.myMessage!,
                data.url!,
                index,
                data.audioTime!,
                data.messageRead.toString(),
                data.createdAt,
                data.isStarMessage!),
          ),
        ],
      ),
    );
  }

  Widget getGifMessage(index, MessageList data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onLongPress: () {
          msgDailogShow(
              //message
              data.message!,
              // chat id
              data.messageId.toString(),
              // chat user id
              data.conversationId.toString(),
              data.messageType!,
              "0",
              // snapshot
              //     .data!
              //     .messageList![index1]
              //     .messages![index]
              //     .isStarted!,
              data.isStarMessage!,
              index,
              data.myMessage!,
              data.senderData!);
        },
        onTap: () {
          if (chatID.isNotEmpty) {
            setState(() {
              chatID.contains(data.messageId.toString())
                  ? chatID.remove(data.messageId.toString())
                  : chatID.add(data.messageId.toString());
            });
          }
          Navigator.push(
            context,
            PageTransition(
                curve: Curves.linear,
                type: PageTransitionType.rightToLeft,
                child: ImageView(
                  image: data.url!,
                  userimg: "",
                )),
          );
        },
        child: Stack(
          children: [
            isSelectedmessage == "1"
                ? Positioned(
                    left: 10,
                    bottom: 35,
                    child: GestureDetector(
                        onTap: () {
                          // Handle checkbox state change if needed
                          setState(() {
                            chatID.contains(data.messageId.toString())
                                ? chatID.remove(data.messageId.toString())
                                : chatID.add(data.messageId.toString());
                          });
                          print("ONTAPMSGID:$chatID");
                        },
                        child: chatID.isEmpty
                            ? const SizedBox()
                            : Transform.scale(
                                scale: 1.1,
                                child: GestureDetector(
                                  child: Container(
                                      width: 20.0,
                                      height: 20.0,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          border: Border.all(color: bg1),
                                          color: chatID.contains(
                                                  data.messageId.toString())
                                              ? bg1
                                              : bg1),
                                      child: chatID.contains(
                                              data.messageId.toString())
                                          ? const Icon(
                                              Icons.check,
                                              size: 15.0,
                                              color: Colors.black,
                                            )
                                          : const SizedBox(
                                              height: 10,
                                            )),
                                ))),
                  )
                : const SizedBox(height: 10),
            Container(
              padding: EdgeInsets.only(
                  left: chatID.isNotEmpty
                      ? data.myMessage == false
                          ? 40
                          : 12
                      : 12,
                  right: 12,
                  top: 0,
                  bottom: 0),
              color: highlightedIndex == index &&
                      (isMsgHighLight == false
                          ? widget.isMsgHighLight!
                          : isMsgHighLight)
                  ? chatStrokeColor // for when reply msg scoll then
                  : Colors.transparent,
              child: Align(
                alignment: data.myMessage == false
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: data.myMessage == false
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: data.myMessage == false
                            ? BorderRadius.circular(15)
                            : BorderRadius.circular(15),
                        color: data.myMessage == false
                            ? Colors.grey.shade200
                            : chatownColor,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: CachedNetworkImage(
                            imageUrl: data.url!,
                            imageBuilder: (context, imageProvider) => Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            placeholder: (context, url) => const Center(
                              child: CupertinoActivityIndicator(),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: SizedBox(
                          child: timestpa(data.messageRead.toString(),
                              data.createdAt!, data.isStarMessage!),
                        ))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getHttpLinkMessage(index, MessageList data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onLongPress: () {
          msgDailogShow(
              //message
              data.message!,
              // chat id
              data.messageId.toString(),
              // chat user id
              data.conversationId.toString(),
              data.messageType!,
              "0",
              // snapshot
              //     .data!
              //     .messageList![index1]
              //     .messages![index]
              //     .isStarted!,
              data.isStarMessage!,
              index,
              data.myMessage!,
              data.senderData!);
        },
        onTap: () {
          if (chatID.isNotEmpty) {
            setState(() {
              chatID.contains(data.messageId.toString())
                  ? chatID.remove(data.messageId.toString())
                  : chatID.add(data.messageId.toString());
            });
          }
          launchURL(data.message!);
          print(data.message!);
        },
        child: Stack(
          children: [
            isSelectedmessage == "1"
                ? Positioned(
                    left: 10,
                    bottom: 35,
                    child: GestureDetector(
                        onTap: () {
                          // Handle checkbox state change if needed
                          setState(() {
                            chatID.contains(data.messageId.toString())
                                ? chatID.remove(data.messageId.toString())
                                : chatID.add(data.messageId.toString());
                          });
                          print("ONTAPMSGID:$chatID");
                        },
                        child: chatID.isEmpty
                            ? const SizedBox()
                            : Transform.scale(
                                scale: 1.1,
                                child: GestureDetector(
                                  child: Container(
                                      width: 20.0,
                                      height: 20.0,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          border: Border.all(color: bg1),
                                          color: chatID.contains(
                                                  data.messageId.toString())
                                              ? bg1
                                              : bg1),
                                      child: chatID.contains(
                                              data.messageId.toString())
                                          ? const Icon(
                                              Icons.check,
                                              size: 15.0,
                                              color: Colors.black,
                                            )
                                          : const SizedBox(
                                              height: 10,
                                            )),
                                ))),
                  )
                : const SizedBox(height: 10),
            Container(
                padding: EdgeInsets.only(
                    left: chatID.isNotEmpty
                        ? data.myMessage == false
                            ? 40
                            : 12
                        : 12,
                    right: 12,
                    top: 0,
                    bottom: 0),
                color: highlightedIndex == index &&
                        (isMsgHighLight == false
                            ? widget.isMsgHighLight!
                            : isMsgHighLight)
                    ? chatStrokeColor // for when reply msg scoll then
                    : Colors.transparent,
                child: Column(
                  children: [
                    Align(
                      alignment: (data.myMessage == false
                          ? Alignment.topLeft
                          : Alignment.topRight),
                      child: Column(
                        crossAxisAlignment: data.myMessage == false
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.end,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width * .6),
                                decoration: BoxDecoration(
                                    borderRadius: data.myMessage == false
                                        ? const BorderRadius.only(
                                            topLeft: Radius.circular(7),
                                            topRight: Radius.circular(7),
                                            bottomRight: Radius.circular(7))
                                        : const BorderRadius.only(
                                            topLeft: Radius.circular(7),
                                            topRight: Radius.circular(7),
                                            bottomLeft: Radius.circular(7)),
                                    color: data.myMessage == false
                                        ? Colors.grey.shade300
                                        : chatownColor),
                                padding: const EdgeInsets.all(10),
                                child: FlutterLinkPreview(
                                  url: data.message!,
                                  builder: (info) {
                                    if (info is WebInfo) {
                                      return info.title == null &&
                                              info.description == null
                                          ? Text(
                                              data.message!,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: data.myMessage == false
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                            )
                                          : Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                if (info.image != null)
                                                  Image.network(info.image!,
                                                      fit: BoxFit.cover),
                                                if (info.title != null)
                                                  Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors.black12,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(7)),
                                                    child: Text(
                                                      info.title!,
                                                      style: TextStyle(
                                                        color: data.myMessage ==
                                                                false
                                                            ? Colors.white
                                                            : Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ).paddingAll(2),
                                                  ).paddingOnly(top: 5),
                                                if (info.description != null)
                                                  Text(
                                                    info.description!,
                                                    maxLines: 3,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: data.myMessage ==
                                                              false
                                                          ? Colors.white
                                                          : Colors.black,
                                                    ),
                                                  ),
                                              ],
                                            );
                                    }
                                    return const CircularProgressIndicator();
                                  },
                                  titleStyle: TextStyle(
                                    color: data.myMessage == false
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: SizedBox(
                                child: timestpa(data.messageRead.toString(),
                                    data.createdAt!, data.isStarMessage!),
                              ))
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget getContactMessage(index, MessageList data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, right: 10, left: 10),
      child: InkWell(
        onLongPress: () {
          msgDailogShow(
              //message
              data.message!,
              // chat id
              data.messageId.toString(),
              // chat user id
              data.conversationId.toString(),
              data.messageType!,
              "0",
              // snapshot
              //     .data!
              //     .messageList![index1]
              //     .messages![index]
              //     .isStarted!,
              data.isStarMessage!,
              index,
              data.myMessage!,
              data.senderData!);
        },
        onTap: () {
          if (chatID.isNotEmpty) {
            setState(() {
              chatID.contains(data.messageId.toString())
                  ? chatID.remove(data.messageId.toString())
                  : chatID.add(data.messageId.toString());
            });
          }
        },
        child: Stack(
          children: [
            isSelectedmessage == "1"
                ? Positioned(
                    left: 10,
                    bottom: 35,
                    child: GestureDetector(
                        onTap: () {
                          // Handle checkbox state change if needed
                          setState(() {
                            chatID.contains(data.messageId.toString())
                                ? chatID.remove(data.messageId.toString())
                                : chatID.add(data.messageId.toString());
                          });
                          print("ONTAPMSGID:$chatID");
                        },
                        child: chatID.isEmpty
                            ? const SizedBox()
                            : Transform.scale(
                                scale: 1.1,
                                child: GestureDetector(
                                  child: Container(
                                      width: 20.0,
                                      height: 20.0,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          border: Border.all(color: bg1),
                                          color: chatID.contains(
                                                  data.messageId.toString())
                                              ? bg1
                                              : bg1),
                                      child: chatID.contains(
                                              data.messageId.toString())
                                          ? const Icon(
                                              Icons.check,
                                              size: 15.0,
                                              color: Colors.black,
                                            )
                                          : const SizedBox(
                                              height: 10,
                                            )),
                                ))),
                  )
                : const SizedBox(height: 10),
            Container(
              color: highlightedIndex == index &&
                      (isMsgHighLight == false
                          ? widget.isMsgHighLight!
                          : isMsgHighLight)
                  ? chatStrokeColor // for when reply msg scoll then
                  : Colors.transparent,
              child: Align(
                  alignment: data.myMessage == false
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: data.myMessage == false
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: EdgeInsets.only(
                            left: chatID.isNotEmpty
                                ? data.myMessage == false
                                    ? 40
                                    : 12
                                : 12,
                            right: 12,
                            top: 0,
                            bottom: 0),
                        margin: const EdgeInsets.only(bottom: 5),
                        decoration: BoxDecoration(
                          borderRadius: data.myMessage == false
                              ? BorderRadius.circular(15)
                              : BorderRadius.circular(15),
                          color: data.myMessage == false
                              ? Colors.grey.shade200
                              : chatownColor,
                        ),
                        constraints: const BoxConstraints(
                            minHeight: 20.0, minWidth: 10.0),
                        child: Container(
                          padding: const EdgeInsets.all(5.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              topRight: const Radius.circular(8.0),
                              bottomRight: data.myMessage == false
                                  ? const Radius.circular(8)
                                  : const Radius.circular(0.0),
                              topLeft: const Radius.circular(8.0),
                              bottomLeft: data.myMessage == false
                                  ? const Radius.circular(0)
                                  : const Radius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(data.sharedContactName!),
                                  Text(data.sharedContactNumber!),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      data.myMessage == false
                          ? SizedBox(
                              child: timestpa(data.messageRead.toString(),
                                  data.createdAt!, data.isStarMessage!),
                            )
                          : SizedBox(
                              child: timestpa(data.messageRead.toString(),
                                  data.createdAt!, data.isStarMessage!),
                            )
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget getReplyMessage(index, MessageList data) {
    return InkWell(
      onLongPress: () {
        setState(() {
          msgDailogShow(
              //message
              data.message!,
              // chat id
              data.messageId.toString(),
              // chat user id
              data.conversationId.toString(),
              data.messageType!,
              "0",
              data.isStarMessage!,
              index,
              data.myMessage!,
              data.senderData!);
        });
      },
      onTap: () {
        if (chatID.isNotEmpty) {
          setState(() {
            chatID.contains(data.messageId.toString())
                ? chatID.remove(data.messageId.toString())
                : chatID.add(data.messageId.toString());
          });
        }
        print("ONTAPMSGID:$chatID");
      },
      child: replyMSGWidget(
          data.myMessage!,
          //replyTime
          data.replyId!,
          //text message
          data.message!,
          // msg id
          data.messageId.toString(),
          //msg type
          data.messageType!,
          // msg time
          data.createdAt!,
          // url doc,image, video, audio
          data.url!,
          // user image
          data.senderData!.profileImage!,
          // video thumbnail
          data.thumbnail!,
          // location lat
          data.latitude!,
          // location lat
          data.longitude!,
          // msg list index
          index,
          // audio string
          data.audioTime!,
          data.sharedContactName!,
          data.sharedContactNumber!,
          data.senderData!,
          data.isStarMessage!,
          data.messageRead.toString()),
    );
  }
//================================================================= KEYBOARD =================================================================================

  bool click = false;

  Widget floatbutton() {
    return Column(
      children: [
        Divider(
          height: 1,
          thickness: 1,
          color: Colors.grey[200],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: InkWell(
                onTap: () {
                  // if (widget.isBlocked == "1") {
                  //   openBlockSheet(context);
                  // } else {
                  //   setState(() {
                  //     click = !click;
                  //   });
                  // }
                  setState(() {
                    click = !click;
                    closekeyboard();
                  });
                },
                child: CircleAvatar(
                    backgroundColor: chatownColor,
                    radius: 20,
                    child: Center(
                        child: Icon(click ? Icons.remove : Icons.add,
                            color: chatColor))),
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.grey.shade200),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    onTap: () {
                      isKeyboard = true;
                    },
                    maxLines: 4,
                    minLines: 1, // Minimum lines to show initially
                    cursorColor: Colors.black,
                    textCapitalization: TextCapitalization.sentences,
                    style: TextStyle(
                        color: isURL(messagecontroller.text.trim())
                            ? const Color.fromARGB(255, 6, 6, 252)
                            : Colors.black),
                    controller: messagecontroller,
                    decoration: const InputDecoration(
                        alignLabelWithHint: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                        border: InputBorder.none,
                        hintText: "New Chat",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                        isDense: true),
                    onChanged: (value) {
                      setState(() {
                        if (value.trim().isEmpty) {
                          // If only whitespace characters are entered
                          isSendbutton = false;
                          isHttpSendbutton = false;
                        } else if (isURL(value)) {
                          // If it's a URL
                          isSendbutton = true;
                          isHttpSendbutton = true;
                        } else {
                          // If it's not a URL
                          isSendbutton = true; // Adjusted condition
                          isHttpSendbutton = false;
                        }
                        if (value.isNotEmpty &&
                            isSendbutton &&
                            typingstart == '0') {
                          print("START-TYPING-1");
                          typingstart = "1";
                          chatContorller.isTypingApi(
                              widget.conversationID!, "1");
                          controller.isTyping();
                        }
                        typingTimer?.cancel();
                        startTypingTimer();
                        if (value.isNotEmpty &&
                            isSendbutton &&
                            typingstart == '0') {
                          print("START-TYPING-1");
                          typingstart = '1';
                          chatContorller.isTypingApi(
                              widget.conversationID!, "1");
                          controller.isTyping();
                        }
                      });
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: InkWell(
                  onTap: () {
                    //--------- reply text api call -----------------//
                    if (messagecontroller.text.isNotEmpty && isSendbutton) {
                      if (SelectedreplyText == true) {
                        try {
                          chatContorller.isSendMsg.value = true;
                          chatContorller.sendMessageReplyText(
                              messagecontroller.text.trim(),
                              widget.conversationID.toString(),
                              'text',
                              reply_chatID,
                              widget.mobileNum.toString());
                          chatContorller.isSendMsg.value = false;
                          SelectedreplyText = false;
                          chatContorller.isTypingApi(
                              widget.conversationID!, "0");
                          controller.isTyping();
                          typingstart = "0";
                        } catch (e) {
                          chatContorller.isSendMsg.value = false;
                          print(e);
                          showCustomToast("Something Error2");
                        }
                        messagecontroller.clear();
                      } else {
                        //================ text api call =============//
                        try {
                          chatContorller.isSendMsg.value = true;
                          print(messagecontroller.text.trim());
                          print(widget.conversationID);
                          print('text');
                          print(widget.mobileNum);
                          chatContorller.sendMessageText(
                              messagecontroller.text.trim(),
                              widget.conversationID.toString(),
                              'text',
                              widget.mobileNum.toString());
                          chatContorller.isTypingApi(
                              widget.conversationID!, "0");
                          controller.isTyping();
                          typingstart = "0";
                          chatContorller.isSendMsg.value = false;
                        } catch (e) {
                          chatContorller.isSendMsg.value = false;
                          print(e);
                          showCustomToast("Something Error1");
                        }
                        messagecontroller.clear();
                      }
                    } else {
                      checkPermission();
                      bottoSheet();
                      closekeyboard();
                    }
                  },
                  child: CircleAvatar(
                      backgroundColor: chatownColor,
                      radius: 20,
                      child: messagecontroller.text.isNotEmpty && isSendbutton
                          ? const Icon(
                              Icons.send,
                              color: chatColor,
                            )
                          : Image.asset("assets/images/microphone-2.png",
                              height: 20, color: chatColor))),
            )
          ],
        ),
        Platform.isIOS
            ? const SizedBox(height: 30)
            : const SizedBox(height: 10),
        click
            ? Container(
                height: 370,
                width: MediaQuery.of(context).size.width * 0.99,
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.grey[200],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              getDocsFromLocal();
                              setState(() {
                                click = !click;
                              });
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                  color: Colors.transparent),
                              child: Column(
                                children: [
                                  Container(
                                      height: 50,
                                      width: 50,
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle, color: bg1),
                                      child: const Padding(
                                        padding: EdgeInsets.all(12),
                                        child: Image(
                                          image: AssetImage(
                                            'assets/images/paperclip-2.png',
                                          ),
                                          color: chatColor,
                                        ),
                                      )),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  const Text('File',
                                      style: TextStyle(
                                          color: chatColor,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14))
                                ],
                              ),
                            ),
                          ),
                          Container(
                            decoration:
                                const BoxDecoration(color: Colors.transparent),
                            child: Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    print("rplyType:$SelectedreplyText");
                                    getImageFromGallery1();
                                    setState(() {
                                      click = !click;
                                    });
                                  },
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle, color: bg1),
                                    child: const Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: Image(
                                        image: AssetImage(
                                          'assets/images/gallery.png',
                                        ),
                                        color: chatColor,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                const Text('Photo',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14))
                              ],
                            ),
                          ),
                          Container(
                            decoration:
                                const BoxDecoration(color: Colors.transparent),
                            child: Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    getImageFromCamera();
                                    setState(() {
                                      click = !click;
                                    });
                                  },
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle, color: bg1),
                                    child: const Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: Image(
                                        image: AssetImage(
                                          'assets/images/camera.png',
                                        ),
                                        color: chatColor,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                const Text('Camera',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14))
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              getImageFromGallery2();
                              setState(() {
                                click = !click;
                              });
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                  color: Colors.transparent),
                              child: Column(
                                children: [
                                  Container(
                                    height: 50,
                                    width: 50,
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        // border: Border.all(
                                        //     color: Colors.grey
                                        //         .shade200),
                                        color: bg1),
                                    child: const Padding(
                                      padding: EdgeInsets.all(13.0),
                                      child: Image(
                                          image: AssetImage(
                                            'assets/images/video.png',
                                          ),
                                          color: chatColor),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  const Text('Video',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14))
                                ],
                              ),
                            ),
                          ),
                          Container(
                            decoration:
                                const BoxDecoration(color: Colors.transparent),
                            child: Column(
                              children: [
                                InkWell(
                                  onTap: () async {
                                    _selectGif();
                                    setState(() {
                                      click = !click;
                                    });
                                  },
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle, color: bg1),
                                    child: const Center(
                                        child: Text(
                                      'GIF',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: chatColor),
                                    )),
                                  ),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                const Text('Gif',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14))
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              //Navigator.pop(context);
                              showPlacePicker();
                              setState(() {
                                click = !click;
                              });
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                  color: Colors.transparent),
                              child: Column(
                                children: [
                                  Container(
                                    height: 50,
                                    width: 50,
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle, color: bg1),
                                    child: const Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: Image(
                                        image: AssetImage(
                                          'assets/images/location.png',
                                        ),
                                        color: chatColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  const Text('Location',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14))
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            click = !click;
                          });
                          Get.to(
                              () => ContactSend(
                                    conversationID: widget.conversationID!,
                                    mobileNum: widget.mobileNum.toString(),
                                  ),
                              transition: Transition.leftToRight);
                        },
                        child: Container(
                          decoration:
                              const BoxDecoration(color: Colors.transparent),
                          child: Column(
                            children: [
                              Container(
                                  height: 50,
                                  width: 50,
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle, color: bg1),
                                  child: const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Image(
                                      image: AssetImage(
                                        'assets/icons/profile_outline.png',
                                      ),
                                      color: chatColor,
                                    ),
                                  )),
                              const SizedBox(
                                height: 8,
                              ),
                              const Text('Contact',
                                  style: TextStyle(
                                      color: chatColor,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14))
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )
            : const SizedBox.shrink()
      ],
    );
  }

//================================= FORWARD MESSAGE DESIGN ==========================================
  Widget floatbutton1() {
    return chatID.isEmpty
        ? floatbutton()
        : Padding(
            padding: const EdgeInsets.only(bottom: 35),
            child: Column(
              children: [
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey[200],
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(left: 18.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                PageTransition(
                                  curve: Curves.linear,
                                  type: PageTransitionType.bottomToTop,
                                  child: ForwardMessage(
                                    chatid: chatID
                                        .toString()
                                        .removeAllWhitespace
                                        .replaceAll(']', '')
                                        .replaceAll('[', ''),
                                    isMsgType: true,
                                  ),
                                ));
                          },
                          child: Image.asset("assets/images/forward.png",
                              height: 20, color: chatColor),
                        )),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          chatID.length.toString(),
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, color: Colors.black),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        const Text(
                          'Selected',
                          style: TextStyle(
                              fontWeight: FontWeight.w500, color: Colors.black),
                        ),
                      ],
                    )),
                    const SizedBox(
                      width: 5,
                    ),
                    Padding(
                        padding: const EdgeInsets.only(right: 18.0),
                        child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isSelectedmessage = "0";
                                chatID = [];
                              });
                            },
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: Colors.blue),
                            )))
                  ],
                ),
              ],
            ),
          );
  }

//============================================================= AUDIO PLAYER VOICE MESSAGE ===============================================================
//============================================================= AUDIO PLAYER VOICE MESSAGE ===============================================================
//============================================================= AUDIO PLAYER VOICE MESSAGE ===============================================================
  String recordFilePath = '';
  Future<bool> checkPermission() async {
    if (!await Permission.microphone.isGranted) {
      PermissionStatus status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  int i = 0;
  Future<String> getFilePath() async {
    Directory storageDirectory = await getApplicationDocumentsDirectory();
    String sdPath =
        "${storageDirectory.path}/record${DateTime.now().microsecondsSinceEpoch}.acc";
    var d = Directory(sdPath);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }
    return "$sdPath/test_${i++}.mp3";
  }

  void startRecord() async {
    recordFilePath = '';
    bool hasPermission = await checkPermission();
    if (hasPermission) {
      recordFilePath = await getFilePath();
      RecordMp3.instance.start(recordFilePath, (type) {
        setState(() {});
      });
    } else {
      showCustomToast("No microphone permission");
    }
    setState(() {});
  }

  void stopRecord() async {
    bool stop = RecordMp3.instance.stop();
    audioController.end.value = DateTime.now();
    audioController.calcDuration();
    var ap = AudioPlayer();
    await ap.play(AssetSource("audio/notification.mp3"));
    ap.onPlayerComplete.listen((a) {});
    print("ADUIOOOO:$recordFilePath");
    if (stop) {
      audioController.isRecording.value = false;
      audioController.isSending.value = true;
      print("DURATION:::${audioController.total}");
      // await selectedreplyText == true
      //     ? uploadAudioReply(
      //         File(recordFilePath), "voicemessage", audioController.total)
      //     : uploadAudio(
      //         File(recordFilePath), "voicemessage", audioController.total);
      chatContorller.sendMessageVoice(
          widget.conversationID,
          "audio",
          File(recordFilePath),
          audioController.total,
          widget.mobileNum.toString());
    }
  }

  void stopTimer() {
    seconds = 0;
    newtimer?.cancel();
  }

  bool button = false;

  _cancle() async {
    record = false;
    setState(() {
      button = false;
      record = false;
      record = false;
    });
  }

  bool record = false;
  int seconds = 0;
  Timer? newtimer;

  Future bottoSheet() {
    return showModalBottomSheet(
        backgroundColor: Colors.white,
        elevation: 0,
        isScrollControlled: true,
        context: context,
        isDismissible: false,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15), topRight: Radius.circular(15))),
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState1) {
            void startTimer() {
              const oneSec = Duration(seconds: 1);
              newtimer = Timer.periodic(
                oneSec,
                (Timer timer) => setState(
                  () {
                    setState1(() {
                      seconds += 1;
                    });
                  },
                ),
              );
            }

            String formatTime(int seconds) {
              int minutes = seconds ~/ 60;
              int remainingSeconds = seconds % 60;
              return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
            }

            return SizedBox(
              width: Get.width,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      formatTime(
                        seconds,
                      ),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                  // record == true
                  //     ? const SizedBox.shrink()
                  //     : const SizedBox(
                  //         height: 10,
                  //       ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      record == true
                          ? Lottie.asset(
                              'assets/Lottie ANIMATION/voice_record_animation.json',
                              height: 120,
                              width: 120,
                              fit: BoxFit.cover,
                            )
                          // ignore: prefer_const_constructors
                          : SizedBox(
                              height: 120,
                              width: 120,
                            ),
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(150),
                            color: chatColor),
                        child: Center(
                            child: Image.asset("assets/images/microphone-2.png",
                                height: 40, color: Colors.white)),
                      ),
                    ],
                  ),
                  // record == true
                  //     ? const SizedBox.shrink()
                  //     : const SizedBox(
                  //         height: 40,
                  //       ),
                  InkWell(
                    onTap: () async {
                      if (record) {
                        setState1(() {
                          record = false;
                        });
                        stopTimer();
                        stopRecord();
                        Navigator.pop(context);
                        print("44444");
                      } else {
                        var audioPlayer = AudioPlayer();
                        await audioPlayer
                            .play(AssetSource("audio/notification.mp3"));
                        audioPlayer.onPlayerComplete.listen((a) {
                          setState1(() {
                            record = true;
                          });
                          audioController.start.value = DateTime.now();

                          startTimer();
                          startRecord();
                          audioController.isRecording.value = true;
                        });
                      }
                    },
                    child: Container(
                      width: 110,
                      height: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: chatownColor),
                      child: Center(
                        child: Text(
                          record ? "Send" : "Start",
                          style: const TextStyle(color: chatColor),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  InkWell(
                    onTap: () async {
                      RecordMp3.instance.stop();
                      stopRecord();
                      stopTimer();
                      _cancle();
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 110,
                      height: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: chatownColor),
                      child: const Center(
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: chatColor),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            );
          });
        });
  }

  Widget myVoiceWidget(bool myMessage, String audiourl, int index,
      String audioduration, messageSeen, timestamp, isStarted) {
    return Container(
      padding: const EdgeInsets.only(right: 12, top: 0, bottom: 0),
      child: Column(
        children: [
          Align(
            alignment:
                (myMessage == false ? Alignment.topLeft : Alignment.topRight),
            child: Column(
              crossAxisAlignment: myMessage == false
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                _audio(
                    message: audiourl,
                    isCurrentUser: myMessage == false,
                    index: index,
                    duration: audioduration.toString()),
                Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: SizedBox(
                      child: timestpa(messageSeen!, timestamp!, isStarted!),
                    ))
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }

  Widget _audio({
    required String message,
    required bool isCurrentUser,
    required int index,
    required String duration,
  }) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.6,
      ),
      height: 65,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isCurrentUser ? Colors.grey.shade200 : chatownColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
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
                      Icons.pause,
                      color: chatColor,
                    )
                  : const Icon(
                      Icons.play_arrow,
                      color: chatColor,
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
          const SizedBox(
            width: 10,
          ),
          Text(
            duration,
            style: const TextStyle(fontSize: 12, color: chatColor),
          ),
        ],
      ),
    );
  }

//================================================================== IMAGE SELECT FROM CAMERA =============================================
//================================================================== IMAGE SELECT FROM CAMERA =============================================
//================================================================== IMAGE SELECT FROM CAMERA =============================================
  final picker = ImagePicker();
  Future getImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() async {
      if (pickedFile != null) {
        File image = File(pickedFile.path);
        final dir = await getTemporaryDirectory();
        final targetPath =
            "${dir.absolute.path}/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
        return FlutterImageCompress.compressAndGetFile(
          image.absolute.path,
          targetPath,
          quality: 50,
        ).then((value) {
          if (SelectedreplyText == true) {
            chatContorller.sendMessageRpltIMGDoc(widget.conversationID, 'image',
                value!.path, reply_chatID, widget.mobileNum.toString());
            SelectedreplyText = false;
          } else {
            chatContorller.sendMessageIMGDoc(widget.conversationID, 'image',
                value!.path, widget.mobileNum.toString());
          }
        });
      } else {}
    });
  }

//================================================================== IMAGE SELECT FROM GALLERY ============================================
  Future getImageFromGallery1() async {
    FilePickerResult? pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowCompression: true,
      allowMultiple: false,
    );
    //SelectedreplyText = false;
    if (pickedFile != null) {
      File image = File(pickedFile.files.single.path!);
      if (image.lengthSync() > 10 * 1024 * 1024) {
        showCustomToast("Selected image file size should be less than 10MB");
        return;
      } else {
        final dir = await getTemporaryDirectory();
        final targetPath =
            "${dir.absolute.path}/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
        return FlutterImageCompress.compressAndGetFile(
          image.absolute.path,
          targetPath,
          quality: 50,
        ).then((value) async {
          print("Compressed");
          print("RPLY:$SelectedreplyText");
          print(reply_chatID);
          if (SelectedreplyText == true) {
            chatContorller.sendMessageRpltIMGDoc(
                widget.conversationID.toString(),
                'image',
                value!.path,
                reply_chatID,
                widget.mobileNum.toString());
            SelectedreplyText = false;
          } else {
            chatContorller.sendMessageIMGDoc(widget.conversationID, 'image',
                value!.path, widget.mobileNum.toString());
          }
        });
      }

      // Check if the picked file is a video
    }
  }

//=================================================================== DOC SELECT FROM GALLERY =============================================
  File? doc;
  Future getDocsFromLocal() async {
    FilePickerResult? pickedFile = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ["pdf", "doc", "docx"],
        allowCompression: true,
        allowMultiple: false);
    // final pickedFileV = await picker.getVideo(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        doc = File(pickedFile.files.single.path!);

        // print('file type =============== > file $image');

        if (SelectedreplyText == true) {
          chatContorller.sendMessageRpltIMGDoc(widget.conversationID,
              'document', doc!.path, reply_chatID, widget.mobileNum.toString());
          SelectedreplyText = false;
        } else {
          chatContorller.sendMessageIMGDoc(widget.conversationID, 'document',
              doc!.path, widget.mobileNum.toString());
        }

        // print('Api Complete');
      } else {
        // print('No image selected.');
      }
    });
  }

//============================================================= VIDEO SELECT FROM GALLERY ==============================================
  File? video;
  String? filePath;
  String compressedVideoPath = '';

  compressVideo() async {
    // Get the file size in bytes
    int fileSizeInBytes = video!.lengthSync();

    // Convert bytes to megabytes
    double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

    print('File Size: $fileSizeInMB MB');

    if (fileSizeInMB > 20.0) {
      // await VideoCompress.setLogLevel(0);
      // snackBar('video compressing');
      print("¸ $filePath");

      final LightCompressor lightCompressor = LightCompressor();
      final Result response = await lightCompressor.compressVideo(
        path: filePath!,
        // destinationPath: _destinationPath,
        videoQuality: VideoQuality.low,
        // fileSizeInMB > 50.0 ? VideoQuality.very_low : VideoQuality.low,
        isMinBitrateCheckEnabled: false,
        video: Video(videoName: path.basename(filePath!)),
        android: AndroidConfig(isSharedStorage: false, saveAt: SaveAt.Movies),
        ios: IOSConfig(saveInGallery: false),
      );

      if (response is OnSuccess) {
        final String outputFile = response.destinationPath;
        compressedVideoPath = outputFile;

        // use the file
        print('SUCESS');
        print("Response is Success");
      } else if (response is OnFailure) {
        // failure message
        print("FAILURE ${response.message}");
        compressedVideoPath = video!.absolute.path;
        print("Response is Failure");
      } else if (response is OnCancelled) {
        print("CANCELLED ${response.isCancelled}");
        print("Response is Cancelled");
      }
      print('RESPONS IS $response');

      // compressedVideoPath = response;

      print("compressedVideoPath $compressedVideoPath");
      setState(() {});

      // snackBar('video comprresed');
      // print("pathcompress--->${compressedVideo.path}");
    } else {
      compressedVideoPath = video!.absolute.path;
      print("else pathcompress--->$compressedVideoPath");
    }
  }

  List compressedVideos = [];

  Future<void> getImageFromGallery2() async {
    FilePickerResult? pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowCompression: true,
      allowMultiple: false,
    );

    if (pickedFile != null) {
      File image = File(pickedFile.files.single.path!);
      // Check if the picked file is a video
      if (image.path.toLowerCase().endsWith(".mp4") ||
          image.path.toLowerCase().endsWith(".mov") ||
          image.path.toLowerCase().endsWith(".wmv") ||
          image.path.toLowerCase().endsWith(".avi") ||
          image.path.toLowerCase().endsWith(".mkv") ||
          image.path.toLowerCase().endsWith(".h.264") ||
          image.path.toLowerCase().endsWith(".hevc")) {
        // Get video duration using FFmpeg
        // final duration = await getVideoDuration(image.path);
        // if (duration != null) {
        //   print('Video Duration is:: $duration');
        // }

        // Check if the video size is greater than 10MB
        if (image.lengthSync() > 10 * 1024 * 1024) {
          showCustomToast("Selected video file size should be less than 10MB");
          return;
        } else {
          // Modify the file name by appending "-isvideo" before the extension
          // String newFilePath = modifyFileName(image.path);
          // image = image.renameSync(newFilePath);

          // If the video size is within limits, proceed with sending video
          filePath = image.path;
          video = image;

          // Call the compressVideo method to handle video compression
          await compressVideo();

          final value = await VideoThumbnail.thumbnailFile(
                  video: filePath!, imageFormat: ImageFormat.PNG, quality: 100)
              .then((value) => value);
          print('Thumbnail Value is $value');

          // Add compressed video path and thumbnail value to list
          compressedVideos = [compressedVideoPath, value];

          if (SelectedreplyText == true) {
            chatContorller.sendMessageVideoRply(widget.conversationID, "video",
                compressedVideos, reply_chatID, widget.mobileNum.toString());
            SelectedreplyText = false;
          } else {
            chatContorller.sendMessageVideo(widget.conversationID, "video",
                compressedVideos, widget.mobileNum.toString());
          }
        }
      } else {
        // If the picked file is not a supported video format
        print("Selected file is not a supported video format");
      }
    }
  }

  // String modifyFileName(String originalPath) {
  //   String newFileName =
  //       "${path.basenameWithoutExtension(originalPath)}-isvideo${path.extension(originalPath)}";
  //   return path.join(path.dirname(originalPath), newFileName);
  // }

//============================================ GIF SELECT =============================================================
  void _selectGif() async {
    const giphyApiKey = 'M74S0wxPj9sOl30judPKMjTU6GkmmjpC';
    // let the user select the gif:
    final gif = await Giphy.getGif(
        context: context,
        apiKey: giphyApiKey, //  your API key
        type: GiphyType.gifs, // choose between gifs, stickers and emoji
        rating: GiphyRating.g, // general audience / all ages
        lang: GiphyLanguage.english, // 'en'
        keepState: true, // remember type and search query
        showPreview: true, // shows a preview before returning the GIF
        searchHintText: "search",
        usePlatformBottomSheet: true,
        gridSpacing: 4.0,
        gridType: GridType.squareFixedColumns);
    // process the gif:
    if (gif != null) {
      chatContorller.isSendMsg.value = true;
      setState(() {
        downloadAndSaveGif(gif.images.original!.url);
        print("SELECTED_GIF:_${gif.images.original!.url}");
      });
      WidgetsBinding.instance.addPostFrameCallback((duration) {
        // _scrollToLastMessage();
      });
    }
  }

  void downloadAndSaveGif(String gifUrl) async {
    try {
      http.Response response = await http.get(Uri.parse(gifUrl));

      if (response.statusCode == 200) {
        Uint8List bytes = response.bodyBytes;
        if (SelectedreplyText == true) {
          chatContorller.sendMessageGIFRply(widget.conversationID, 'gif', bytes,
              reply_chatID, widget.mobileNum.toString());
          SelectedreplyText = false;
        } else {
          chatContorller.sendMessageGIF(
              widget.conversationID, 'gif', bytes, widget.mobileNum.toString());
        }

        print(bytes.toString());
      } else {
        print('Error downloading GIF: ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading or saving GIF: $e');
    }
  }

//=============================================== LOCATION SELECT FROM GOOGLE =================================================================
  String? _address;
  String? _placeLat;
  String? _placeLong;

  void showPlacePicker() async {
    LocationResult result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PlacePicker(
          "AIzaSyAMZ4GbRFYSevy7tMaiH5s0JmMBBXc0qBA",
          //  displayLocation: customLocation,
        ),
      ),
    );

    setState(() {
      _address = result.formattedAddress.toString();
      _placeLat = result.latLng!.latitude.toString();
      _placeLong = result.latLng!.longitude.toString();
    });
    if (SelectedreplyText == true) {
      chatContorller.sendMessageLocationRply(widget.conversationID!, "location",
          _placeLat!, _placeLong!, reply_chatID, widget.mobileNum.toString());
      SelectedreplyText = false;
    } else {
      chatContorller.sendMessageLocation(widget.conversationID!, "location",
          _placeLat!, _placeLong!, widget.mobileNum.toString());
    }

    // Handle the result in your way
  }

//===========================================================                   ====================================================================================
//=========================================================== LONG PRESS DAILOG ====================================================================================
//===========================================================                   ====================================================================================
  String replyText = '';
  String reply_chatID = '';
  String USERTEXT = '';
  bool SelectedreplyText = false;
  String rplyTime = '';
  Future msgDailogShow(String msg, String msgID, String userID, String msgType,
      String time, bool isStar, int index, bool myMessage, SenderData users) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          title: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: bg1,
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                msgType == "location"
                    ? capitalizeFirstLetter("📌 Location")
                    : msgType == "video"
                        ? capitalizeFirstLetter("🎥 Video")
                        : msgType == "image"
                            ? capitalizeFirstLetter("📷 Photo")
                            : msgType == "document"
                                ? capitalizeFirstLetter("📄 Documenet")
                                : msgType == "audio"
                                    ? capitalizeFirstLetter("🔊 Voice message")
                                    : msgType == "link"
                                        ? capitalizeFirstLetter(msg)
                                        : msgType == "gif"
                                            ? "GIF"
                                            : capitalizeFirstLetter(msg),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: chatColor,
                ),
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              msgType != "location" &&
                      msgType != "image" &&
                      msgType != "video" &&
                      msgType != "document" &&
                      msgType != "audio" &&
                      msgType != "gif"
                  ? SizedBox(
                      height: 45,
                      child: ListTile(
                        leading: const Text(
                          'Copy',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        trailing: Image.asset("assets/images/copy.png",
                            height: 18, color: chatColor),
                        onTap: () {
                          setState(() {
                            // chatID.add(msgID);
                            // isSelectedmessage = "1";
                          });
                          Navigator.pop(context);
                          Clipboard.setData(ClipboardData(text: msg));
                          showCustomToast("Message copied");
                          // Add your copy functionality here
                        },
                      ),
                    )
                  : const SizedBox.shrink(),
              // Add SizedBox between Copy and Forward
              msgType != "location" &&
                      msgType != "image" &&
                      msgType != "video" &&
                      msgType != "docdocument" &&
                      msgType != "audio" &&
                      msgType != "gif"
                  ? Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.grey[200],
                    )
                  : const SizedBox.shrink(),
              SizedBox(
                height: 45,
                child: ListTile(
                  leading: const Text(
                    'Reply',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.replay_10,
                    size: 16,
                    color: Colors.black,
                  ),
                  onTap: () {
                    print("INDEX:$index");
                    Navigator.pop(context);
                    setState(() {
                      SelectedreplyText = !SelectedreplyText;
                      USERTEXT = myMessage == false
                          ? "${users.firstName} ${users.lastName!}"
                          : "You";
                      replyText = msgType == "text"
                          ? msg
                          : msgType == "location"
                              ? "📌 Location"
                              : msgType == "image"
                                  ? "📷 Photo"
                                  : msgType == "video"
                                      ? "🎥 Video"
                                      : msgType == "docdocument"
                                          ? "📄 Documenet"
                                          : msgType == "audio"
                                              ? "🔊 Voice message"
                                              : msgType == "gif"
                                                  ? "GIF"
                                                  : msg;
                      reply_chatID = msgID;
                      rplyTime = time;
                      print("TEXT:$replyText");
                      print("RPLYTIME:$rplyTime");
                      print("RPLY$SelectedreplyText");
                      print("SELECT_MSG_ID:$reply_chatID");
                    });
                  },
                ),
              ),

              Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey[200],
              ),
              // Add your forward functionality here
              SizedBox(
                height: 45,
                child: ListTile(
                  leading: const Text(
                    'Forward',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  trailing: Image.asset("assets/images/forward.png",
                      height: 12, color: chatColor),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      chatID.add(msgID);
                      isSelectedmessage = "1";
                      print("MSGID:$msgID");
                    });
                    // Add your forward functionality here
                  },
                ),
              ),

              Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey[200],
              ),
              SizedBox(
                height: 45,
                child: ListTile(
                  leading: const Text(
                    'Delete',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ), //trash
                  trailing: Image.asset("assets/images/trash.png",
                      height: 18, color: chatColor),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      chatID.add(msgID);
                      isSelectedmessage = "1";
                      print("MSGID:$msgID");
                    });
                  },
                ),
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey[200],
              ),
              SizedBox(
                height: 45,
                child: ListTile(
                  leading: Text(
                    isStar != false ? 'Unstarted' : 'Started',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  trailing: isStar != false
                      ? Image.asset("assets/images/starfill.png",
                          color: chatColor, height: 18) //starUnfill
                      : Image.asset("assets/images/starUnfill.png",
                          color: chatColor, height: 18),
                  onTap: () {
                    Navigator.pop(context);
                    if (isStar != false) {
                      print("******");
                      chatContorller.removeStarApi(msgID);
                    } else {
                      chatContorller.addStarApi(msgID);
                      print("+++++++");
                    }
                    // starchat(msgID);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

//=============================================================                      =======================================================================
//============================================================= REPLY MESSAGE DESIGN =======================================================================
//=============================================================                      =======================================================================
  String isMatching(String msgID) {
    for (int i = 0;
        i < chatContorller.userdetailschattModel.value!.messageList!.length;
        i++) {
      if (chatContorller
              .userdetailschattModel.value!.messageList![i].messageId ==
          int.parse(msgID)) {
        if (chatContorller
                .userdetailschattModel.value!.messageList![i].messageType ==
            "text") {
          return chatContorller
              .userdetailschattModel.value!.messageList![i].message!;
        } else if (chatContorller
                .userdetailschattModel.value!.messageList![i].messageType ==
            "image") {
          return "📷 Photo";
        } else if (chatContorller
                .userdetailschattModel.value!.messageList![i].messageType ==
            "location") {
          return "📌 Location";
        } else if (chatContorller
                .userdetailschattModel.value!.messageList![i].messageType ==
            "document") {
          return "📄 Document";
        } else if (chatContorller
                .userdetailschattModel.value!.messageList![i].messageType ==
            "video") {
          return "🎥 Video";
        } else if (chatContorller
                .userdetailschattModel.value!.messageList![i].messageType ==
            "audio") {
          return "🔊 Audio";
        } else if (chatContorller
                .userdetailschattModel.value!.messageList![i].messageType ==
            "link") {
          return chatContorller
              .userdetailschattModel.value!.messageList![i].message!;
        } else if (chatContorller
                .userdetailschattModel.value!.messageList![i].messageType ==
            "gif") {
          return "GIF";
        } else if (chatContorller
                .userdetailschattModel.value!.messageList![i].messageType ==
            "contact") {
          return "Contact";
        }
      }
    }
    return "message removed";
  }

  String isUserMatch(String msgID, int userID) {
    for (var i = 0;
        i < chatContorller.userdetailschattModel.value!.messageList!.length;
        i++) {
      if (chatContorller
              .userdetailschattModel.value!.messageList![i].messageId ==
          int.parse(msgID)) {
        if (chatContorller.userdetailschattModel.value!.messageList![i]
                .senderData!.userId ==
            userID) {
          if ("${chatContorller.userdetailschattModel.value!.messageList![i].senderData!.firstName!} ${chatContorller.userdetailschattModel.value!.messageList![i].senderData!.lastName!}" ==
              "${Hive.box(userdata).get(firstName)} ${Hive.box(userdata).get(lastName)}") {
            return 'You';
          } else {
            return "${chatContorller.userdetailschattModel.value!.messageList![i].senderData!.firstName!} ${chatContorller.userdetailschattModel.value!.messageList![i].senderData!.lastName!}";
          }
        } else {
          if ("${chatContorller.userdetailschattModel.value!.messageList![i].senderData!.firstName!} ${chatContorller.userdetailschattModel.value!.messageList![i].senderData!.lastName!}" ==
              "${Hive.box(userdata).get(firstName)} ${Hive.box(userdata).get(lastName)}") {
            return 'You';
          } else {
            return "${chatContorller.userdetailschattModel.value!.messageList![i].senderData!.firstName!} ${chatContorller.userdetailschattModel.value!.messageList![i].senderData!.lastName!}";
          }
        }
      }
    }
    return "You"; // This return might be a default case if no match is found
  }

  Widget replyMSGWidget(
      bool myMessage,
      int rplyID,
      String msg,
      String msgID,
      String messageType,
      String timeStemp,
      String url,
      String userProfile,
      String videoThumb,
      String lat,
      String lon,
      int index,
      String audioduration,
      String contactName,
      String contactNumber,
      SenderData users,
      bool isStarred,
      String messageRead) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Stack(
        children: [
          isSelectedmessage == "1"
              ? Positioned(
                  left: 10,
                  bottom: 35,
                  child: InkWell(
                      onTap: () {
                        // Handle checkbox state change if needed
                        setState(() {
                          chatID.contains(msgID.toString())
                              ? chatID.remove(msgID.toString())
                              : chatID.add(msgID.toString());
                        });
                        print("ONTAPMSGID:$chatID");
                      },
                      child: chatID.isEmpty
                          ? const SizedBox()
                          : Transform.scale(
                              scale: 1.1,
                              child: GestureDetector(
                                child: Container(
                                    width: 20.0,
                                    height: 20.0,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(25),
                                        border: Border.all(color: bg1),
                                        color: chatID.contains(msgID.toString())
                                            ? bg1
                                            : bg1),
                                    child: chatID.contains(msgID.toString())
                                        ? const Icon(
                                            Icons.check,
                                            size: 15.0,
                                            color: Colors.black,
                                          )
                                        : const SizedBox(
                                            height: 10,
                                          )),
                              ))),
                )
              : const SizedBox(height: 10),
          Container(
            padding: EdgeInsets.only(
                left: chatID.isNotEmpty
                    ? myMessage == false
                        ? 40
                        : 12
                    : 12,
                right: 12,
                top: 0,
                bottom: 0),
            color: highlightedIndex == index &&
                    (isMsgHighLight == false
                        ? widget.isMsgHighLight!
                        : isMsgHighLight)
                ? chatStrokeColor // for when reply msg scoll then
                : Colors.transparent,
            child: Column(
              children: [
                Align(
                  alignment: (myMessage == false
                      ? Alignment.topLeft
                      : Alignment.topRight),
                  child: Column(
                    crossAxisAlignment: myMessage == false
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.end,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * .6),
                            padding: const EdgeInsets.only(
                                left: 12, right: 12, top: 0, bottom: 0),
                            decoration: BoxDecoration(
                                color: myMessage == false
                                    ? Colors.grey.shade200
                                    : chatownColor,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(15))),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () {
                                    for (int i = 0;
                                        i <
                                            chatContorller.userdetailschattModel
                                                .value!.messageList!.length;
                                        i++) {
                                      if (chatContorller
                                              .userdetailschattModel
                                              .value!
                                              .messageList![i]
                                              .messageId ==
                                          rplyID) {
                                        gotoindex = i;
                                        _scrollToIndex(gotoindex, callback: () {
                                          setState(() {
                                            highlightedIndex = gotoindex;
                                            isMsgHighLight = true;
                                          });
                                          Timer(const Duration(seconds: 2), () {
                                            setState(() {
                                              isMsgHighLight = false;
                                            });
                                          });
                                        });
                                        print("GOTOINDEX: $gotoindex");
                                      }
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 5, top: 10),
                                    child: Container(
                                      width: double.infinity,
                                      decoration: const BoxDecoration(
                                          color: Colors.black12,
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
                                            RichText(
                                                textAlign: TextAlign.start,
                                                text: TextSpan(children: [
                                                  TextSpan(
                                                    text: isUserMatch(
                                                        rplyID.toString(),
                                                        users.userId!),
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Colors.black),
                                                  )
                                                ])),
                                            const SizedBox(height: 5),
                                            Text(
                                              isMatching(rplyID.toString()),
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
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: messageType == "text"
                                      ? Text(msg)
                                      : messageType == "document"
                                          ? InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    PageTransition(
                                                      curve: Curves.linear,
                                                      type: PageTransitionType
                                                          .rightToLeft,
                                                      child:
                                                          FileView(file: url),
                                                    ));
                                              },
                                              child: Row(
                                                children: [
                                                  Container(
                                                      height: 35,
                                                      width: 35,
                                                      decoration: BoxDecoration(
                                                        shape:
                                                            BoxShape.rectangle,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        color: const Color(
                                                            0xffCCCCCC),
                                                      ),
                                                      child: const Padding(
                                                        padding:
                                                            EdgeInsets.all(3.0),
                                                        child: Image(
                                                          image: AssetImage(
                                                              'assets/images/doc.png'),
                                                        ),
                                                      )),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 11),
                                                    child: Text(
                                                      extractFilename(url)
                                                          .toString()
                                                          .split("-")
                                                          .last,
                                                      style: const TextStyle(
                                                        color: chatColor,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 15)
                                                ],
                                              ),
                                            )
                                          : messageType == "image"
                                              ? InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      PageTransition(
                                                          curve: Curves.linear,
                                                          type:
                                                              PageTransitionType
                                                                  .rightToLeft,
                                                          child: ImageView(
                                                            image: url,
                                                            userimg:
                                                                userProfile,
                                                          )),
                                                    );
                                                  },
                                                  child: SizedBox(
                                                    height: 200,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      child: CachedNetworkImage(
                                                        imageUrl: url,
                                                        imageBuilder: (context,
                                                                imageProvider) =>
                                                            Stack(
                                                          children: [
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
                                                          ],
                                                        ),
                                                        placeholder:
                                                            (context, url) =>
                                                                const Center(
                                                          child:
                                                              CupertinoActivityIndicator(),
                                                        ),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            const Icon(
                                                                Icons.error),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : messageType == "video"
                                                  ? Stack(
                                                      children: [
                                                        SizedBox(
                                                          height: 200,
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15),
                                                            child:
                                                                CachedNetworkImage(
                                                              imageUrl:
                                                                  videoThumb,
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
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                        Positioned(
                                                            top: 80,
                                                            left: 74,
                                                            child: InkWell(
                                                              onTap: () {
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              VideoViewFix(
                                                                        username:
                                                                            "${capitalizeFirstLetter(users.firstName!)} ${capitalizeFirstLetter(users.lastName!)}",
                                                                        url:
                                                                            url,
                                                                        play:
                                                                            true,
                                                                        mute:
                                                                            false,
                                                                        date: convertUTCTimeTo12HourFormat(
                                                                            timeStemp),
                                                                      ),
                                                                    ));
                                                              },
                                                              child: CircleAvatar(
                                                                  radius: 20,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .grey
                                                                          .shade300,
                                                                  foregroundColor:
                                                                      chatownColor,
                                                                  child: Image.asset(
                                                                      "assets/images/play1.png",
                                                                      color:
                                                                          chatColor,
                                                                      height:
                                                                          18)),
                                                            ))
                                                      ],
                                                    )
                                                  : messageType == "location"
                                                      ? Column(
                                                          children: [
                                                            Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15),
                                                              ),
                                                              constraints:
                                                                  const BoxConstraints(
                                                                      minHeight:
                                                                          10.0,
                                                                      minWidth:
                                                                          10.0,
                                                                      maxWidth:
                                                                          250),
                                                              child: Container(
                                                                height: 180,
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
                                                                  child: lat ==
                                                                              "" ||
                                                                          lon ==
                                                                              ""
                                                                      ? Container(
                                                                          decoration:
                                                                              const BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/map_Blurr.png"), fit: BoxFit.cover)),
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
                                                                              target: LatLng(double.parse(lat), double.parse(lon)),
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
                                                            ),
                                                            const SizedBox(
                                                                height: 5),
                                                            InkWell(
                                                              onTap: () {
                                                                MapUtils.openMap(
                                                                    double.parse(
                                                                        lat),
                                                                    double.parse(
                                                                        lon));
                                                              },
                                                              child: Stack(
                                                                children: [
                                                                  Container(
                                                                    height: 30,
                                                                    decoration: const BoxDecoration(
                                                                        borderRadius: BorderRadius.only(
                                                                            bottomLeft:
                                                                                Radius.circular(10),
                                                                            bottomRight: Radius.circular(10))),
                                                                    child:
                                                                        const Center(
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Text(
                                                                              "View Location",
                                                                              style: TextStyle(
                                                                                color: chatColor,
                                                                                fontSize: 15,
                                                                                fontWeight: FontWeight.w500,
                                                                              )),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      : messageType == "audio"
                                                          ? myVoiceWidget(
                                                              myMessage,
                                                              url,
                                                              index,
                                                              audioduration,
                                                              messageRead,
                                                              timeStemp,
                                                              0)
                                                          : messageType ==
                                                                  "link"
                                                              ? FlutterLinkPreview(
                                                                  url: msg,
                                                                  builder:
                                                                      (info) {
                                                                    if (info
                                                                        is WebInfo) {
                                                                      return info.title == null &&
                                                                              info.description == null
                                                                          ? Text(
                                                                              msg,
                                                                              style: TextStyle(
                                                                                fontSize: 14,
                                                                                fontWeight: FontWeight.w400,
                                                                                color: myMessage == false ? Colors.white : Colors.black,
                                                                              ),
                                                                            )
                                                                          : Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                if (info.image != null) Image.network(info.image!, fit: BoxFit.cover),
                                                                                if (info.title != null)
                                                                                  Container(
                                                                                    decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(7)),
                                                                                    child: Text(
                                                                                      info.title!,
                                                                                      style: TextStyle(
                                                                                        color: myMessage == false ? Colors.white : Colors.black,
                                                                                        fontWeight: FontWeight.bold,
                                                                                      ),
                                                                                    ).paddingAll(2),
                                                                                  ).paddingOnly(top: 5),
                                                                                if (info.description != null)
                                                                                  Text(
                                                                                    info.description!,
                                                                                    maxLines: 3,
                                                                                    overflow: TextOverflow.ellipsis,
                                                                                    style: TextStyle(
                                                                                      color: myMessage == false ? Colors.white : Colors.black,
                                                                                    ),
                                                                                  ),
                                                                              ],
                                                                            );
                                                                    }
                                                                    return const CircularProgressIndicator();
                                                                  },
                                                                  titleStyle:
                                                                      TextStyle(
                                                                    color: myMessage ==
                                                                            false
                                                                        ? Colors
                                                                            .white
                                                                        : Colors
                                                                            .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                )
                                                              : messageType ==
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
                                                                                image: url,
                                                                                userimg: userProfile,
                                                                              )),
                                                                        );
                                                                      },
                                                                      child:
                                                                          SizedBox(
                                                                        height:
                                                                            150,
                                                                        child:
                                                                            ClipRRect(
                                                                          borderRadius:
                                                                              BorderRadius.circular(15),
                                                                          child:
                                                                              CachedNetworkImage(
                                                                            imageUrl:
                                                                                url,
                                                                            imageBuilder: (context, imageProvider) =>
                                                                                Stack(
                                                                              children: [
                                                                                Container(
                                                                                  decoration: BoxDecoration(
                                                                                    image: DecorationImage(
                                                                                      image: imageProvider,
                                                                                      fit: BoxFit.cover,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            placeholder: (context, url) =>
                                                                                const Center(
                                                                              child: CupertinoActivityIndicator(),
                                                                            ),
                                                                            errorWidget: (context, url, error) =>
                                                                                const Icon(Icons.error),
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    )
                                                                  : messageType ==
                                                                          "contact"
                                                                      ? Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text(contactName),
                                                                            Text(contactNumber),
                                                                          ],
                                                                        )
                                                                      : const SizedBox(),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: SizedBox(
                            child: timestpa(
                                messageRead.toString(), timeStemp, isStarred),
                          ))
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

//==========================================================================================================================================================
//================================================================ APP BAR =================================================================================
//==========================================================================================================================================================
  AppBar _appbar(BuildContext context) {
    return AppBar(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      surfaceTintColor: Colors.white,
      backgroundColor: Colors.white,
      scrolledUnderElevation: 0,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          InkWell(
            onTap: () {
              Navigator.pop(context);
              chatContorller.userdetailschattModel.value!.messageList!.clear();
              chatContorller.onClose();
              print(
                  "xxxxxx:${chatContorller.userdetailschattModel.value!.messageList!.clear}");
            },
            child: Image.asset(
              "assets/images/arrow-left.png",
              height: 22,
              color: chatColor,
            ),
          ),
          const SizedBox(width: 5),
          InkWell(
            onTap: () {
              Get.to(() => ChatProfile(
                        fullName: widget.username,
                        profileimg: widget.userPic == ""
                            ? "https://efl.lk/wp-content/uploads/2020/09/dummy-image.jpg"
                            : widget.userPic,
                        peeid: widget.conversationID,
                        phnnum: widget.mobileNum,
                        // status: status,
                      ))!
                  .then((value) {
                if (value == "1") {
                  setState(() {
                    isSearchSelect =
                        "1"; // Update isSearchSelect to "1" when returning from the ChatProfile screen
                    isTextFieldHide = "1";
                  });
                }
                chatListController.userChatListModel.refresh();
              });
            },
            child: Row(
              children: [
                Container(
                  height: 35,
                  width: 35,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade200,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: CachedNetworkImage(
                      imageUrl: widget.userPic!,
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(
                          color: chatownColor,
                        ),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.person,
                        color: Color(0xffBFBFBF),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width *
                          0.4, // Adjust width based on screen size
                      child: Text(
                        capitalizeFirstLetter(widget.username!),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: chatColor,
                          fontWeight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Obx(() {
                      return controller.allOnline.contains(widget.userID)
                          ? const Text(
                              "Online",
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: "Poppins"),
                            )
                          : Text(
                              isUserOnline(widget.userID!),
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.grey),
                            );
                    })
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Obx(() {
          return chatListController.blockModel.value!.isBlock == true
              ? const SizedBox.shrink()
              : InkWell(
                  onTap: () {
                    Get.to(() => VideoCallScreen(
                        roomID: 'cdecb4c5-f6ff-4076-9322-3f91ea143fd9',
                        conversation_id: ''));
                    // getRoomController.getRoomModelApi(
                    //     conversationID: widget.conversationID,
                    //     callType: "video_call");
                  },
                  child: Image.asset(
                    "assets/images/video_1.png",
                    color: chatColor,
                    height: MediaQuery.of(context).size.height * 0.027,
                  ),
                );
        }),
        const SizedBox(width: 12),
        Obx(() {
          return chatListController.blockModel.value!.isBlock == true
              ? const SizedBox.shrink()
              : InkWell(
                  onTap: () {
                    Get.to(
                      () => const AudioCallScreen(),
                    );
                    // getRoomController.getRoomModelApi(
                    //     conversationID: widget.conversationID,
                    //     callType: "voice_call");
                  },
                  child: Image.asset(
                    "assets/images/call_1.png",
                    color: chatColor,
                    height: MediaQuery.of(context).size.height * 0.027,
                  ),
                );
        }),
        _popMenu(context),
      ],
    );
  }

  AppBar _appbarSearch(BuildContext context) {
    return AppBar(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
          side: BorderSide(color: Colors.grey.shade200)),
      surfaceTintColor: Colors.white,
      backgroundColor: Colors.white,
      scrolledUnderElevation: 0,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Container(
        height: 50,
        width: MediaQuery.of(context).size.width * 0.8,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            color: Colors.grey.shade200),
        child: TextField(
          controller: _searchController,
          onChanged: (String searchText) {
            if (searchText.isEmpty) {
              Get.find<SingleChatContorller>()
                  .getdetailschat(widget.conversationID);
              _searchResult.clear();
              _searchController.clear();
            } else {
              onSearchTextChanged(searchText);
            }
          },
          decoration: const InputDecoration(
            suffixIcon: Padding(
              padding: EdgeInsets.all(17),
              child: Image(
                image: AssetImage('assets/icons/search.png'),
              ),
            ),
            hintText: '  What are you looking for?',
            hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
            filled: true,
            fillColor: Colors.transparent,
            border: OutlineInputBorder(borderSide: BorderSide.none),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 15),
          child: InkWell(
              onTap: () {
                setState(() {
                  isSearchSelect = '0';
                  isTextFieldHide = '0';
                  Get.find<SingleChatContorller>()
                      .getdetailschat(widget.conversationID);
                  _searchResult.clear();
                  _searchController.clear();
                });
              },
              child: const Icon(Icons.close, color: chatColor, size: 25)),
        )
      ],
    );
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    for (var userDetail
        in chatContorller.userdetailschattModel.value!.messageList!) {
      if (userDetail.message
          .toString()
          .toLowerCase()
          .contains(text.toLowerCase())) {
        _searchResult.add(userDetail);
      }
    }

    setState(() {});
  }

  AppBar _appbar1(BuildContext context) {
    return AppBar(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
          side: BorderSide(color: Colors.grey.shade200)),
      surfaceTintColor: Colors.white,
      backgroundColor: Colors.white,
      scrolledUnderElevation: 0,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          InkWell(
            onTap: () {
              Navigator.pop(context);
              chatContorller.userdetailschattModel.value!.messageList!.clear();
              print(
                  "xxxxxx:${chatContorller.userdetailschattModel.value!.messageList!.clear}");
            },
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: chatColor,
              size: 18,
            ),
          ),
          InkWell(
            onTap: () {
              Get.to(() => ChatProfile(
                        fullName: widget.username,
                        profileimg: widget.userPic == ""
                            ? "https://efl.lk/wp-content/uploads/2020/09/dummy-image.jpg"
                            : widget.userPic,
                        peeid: widget.conversationID,
                        phnnum: widget.mobileNum,
                        // status: status,
                      ))!
                  .then((value) {
                if (value == "1") {
                  setState(() {
                    isSearchSelect =
                        "1"; // Update isSearchSelect to "1" when returning from the ChatProfile screen
                    isTextFieldHide = "1";
                  });
                }
                chatListController.userChatListModel.refresh();
              });
            },
            child: Row(
              children: [
                const SizedBox(
                  width: 10,
                ),
                Container(
                  height: 35,
                  width: 35,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: checkForNull(widget.conversationID) != null
                        ? CachedNetworkImage(
                            imageUrl: widget.userPic!,
                            imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(
                              color: chatownColor,
                            )),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.person),
                          )
                        : Container(
                            height: 50,
                            width: 50,
                            decoration: const BoxDecoration(
                                color: chatColor, shape: BoxShape.circle),
                            child: const Icon(
                              Icons.person,
                              size: 25,
                              color: chatColor,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 142,
                      child: Text(
                        capitalizeFirstLetter(widget.username!),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: chatColor,
                            fontWeight: FontWeight.w500,
                            overflow: TextOverflow.ellipsis,
                            fontSize: 16),
                      ),
                    ),
                    Obx(() {
                      return controller.allOnline.contains(widget.userID)
                          ? const Text(
                              "Online",
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: "Poppins"),
                            )
                          : Text(
                              isUserOnline(widget.userID!),
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.grey),
                            );
                    })
                  ],
                )
              ],
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 13.0),
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  try {
                    chatContorller.isSendMsg.value = true;
                    chatContorller.deleteChatApi(
                        chatID, false, widget.mobileNum.toString());
                    setState(() {
                      isSelectedmessage = "0";
                      chatID = [];
                    });
                    chatContorller.isSendMsg.value = false;
                  } catch (e) {
                    setState(() {
                      isSelectedmessage = "0";
                      chatID = [];
                    });
                    chatContorller.isSendMsg.value = false;
                  }
                },
                child: Image.asset("assets/images/trash.png",
                    height: 24, color: chatColor),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _popMenu(BuildContext context) {
    return PopupMenuButton(
      padding: EdgeInsets.zero,
      shadowColor: Colors.grey,
      color: Colors.white,
      elevation: 0.8,
      icon: const Icon(
        Icons.more_vert,
        color: chatColor,
        size: 24,
      ),
      itemBuilder: (BuildContext context) => <PopupMenuEntry>[
        PopupMenuItem(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Container(
                    decoration:
                        BoxDecoration(color: Colors.white.withOpacity(0.4)),
                    child: AlertDialog(
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                      ),
                      content: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.90,
                        height: 330,
                        child: Column(
                          children: [
                            Obx(() {
                              return Text(
                                chatListController.blockModel.value!.isBlock ==
                                        true
                                    ? "Unblock"
                                    : "Block",
                                style: const TextStyle(
                                    color: chatColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 22),
                              );
                            }),
                            const SizedBox(
                              height: 5,
                            ),
                            Container(
                              height: 80,
                              width: 80,
                              decoration:
                                  const BoxDecoration(shape: BoxShape.circle),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: checkForNull(widget.conversationID) !=
                                        null
                                    ? CachedNetworkImage(
                                        imageUrl: widget.userPic!,
                                        imageBuilder:
                                            (context, imageProvider) =>
                                                Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        placeholder: (context, url) =>
                                            const Center(
                                                child:
                                                    CircularProgressIndicator(
                                          color: chatownColor,
                                        )),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.person),
                                      )
                                    : Container(
                                        height: 50,
                                        width: 50,
                                        decoration: const BoxDecoration(
                                            color: chatColor,
                                            shape: BoxShape.circle),
                                        child: const Icon(
                                          Icons.person,
                                          size: 25,
                                          color: chatColor,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              capitalizeFirstLetter(widget.username!),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 19),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "widget.phoneNumber",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: appgrey2,
                                  fontSize: 13),
                            ),
                            const SizedBox(height: 15),
                            Obx(() {
                              return Text(
                                chatListController.blockModel.value!.isBlock ==
                                        true
                                    ? "Unblock this users will be able to chat with you"
                                    : "Once blocked this users will not be able chat with you",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: appgrey2,
                                    fontSize: 12),
                              );
                            }),
                            const SizedBox(height: 25),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    height: 40,
                                    width: MediaQuery.of(context).size.width *
                                        0.30,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: chatColor, width: 1),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: const Center(
                                        child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: chatColor),
                                    )),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {});
                                    chatListController
                                        .blockUserApi(widget.conversationID);
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    height: 40,
                                    width: MediaQuery.of(context).size.width *
                                        0.30,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: chatColor),
                                    child: const Center(
                                        child: Text(
                                      'Confirm',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white),
                                    )),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            child: Text(chatListController.blockModel.value!.isBlock == true
                ? "UnBlock Contact"
                : 'Block Contact')),
        PopupMenuItem(
            onTap: () {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Get.to(() => ChatProfile(
                          fullName: widget.username,
                          profileimg: widget.userPic == ""
                              ? "https://efl.lk/wp-content/uploads/2020/09/dummy-image.jpg"
                              : widget.userPic,
                          peeid: widget.conversationID,
                          phnnum: widget.mobileNum,
                          // status: status,
                        ))!
                    .then((value) {
                  if (value == "1") {
                    setState(() {
                      isSearchSelect =
                          "1"; // Update isSearchSelect to "1" when returning from the ChatProfile screen
                      isTextFieldHide = "1";
                    });
                  }
                  chatListController.userChatListModel.refresh();
                });
              });
            },
            child: const Text('View contact')),
        PopupMenuItem(
            onTap: () {
              if (chatContorller.userdetailschattModel.value != null &&
                  chatContorller.userdetailschattModel.value!.messageList !=
                      null &&
                  chatContorller
                      .userdetailschattModel.value!.messageList!.isNotEmpty) {
                var lastMessage = chatContorller
                    .userdetailschattModel.value!.messageList!.reversed.last;
                print("LAST_MSGID:${lastMessage.messageId}");
                chatContorller.clearAllChatApi(
                    conversationid: widget.conversationID!,
                    messageID: lastMessage.messageId.toString());
                chatContorller.userdetailschattModel.value?.messageList
                    ?.clear();
              }
              //deleteMsgDialog();
            },
            child: const Text('Clear chat')),
        PopupMenuItem(
            onTap: () {
              setState(() {
                isSearchSelect = "1";
                isTextFieldHide = "1";
              });
            },
            child: const Text('Search chat')),
      ],
    );
  }
}

List _searchResult = [];
