// ignore_for_file: must_be_immutable, avoid_print, non_constant_identifier_names, unused_field, prefer_is_empty

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
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
import 'package:meyaoo_new/controller/get_contact_controller.dart';
import 'package:meyaoo_new/controller/online_controller.dart';
import 'package:meyaoo_new/controller/single_chat_controller.dart';
import 'package:meyaoo_new/controller/user_chatlist_controller.dart';
import 'package:meyaoo_new/src/global/global.dart';
import 'package:meyaoo_new/src/global/pdf.dart';
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
import 'package:meyaoo_new/src/screens/save_contact.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:place_picker/place_picker.dart';
import 'package:record_mp3/record_mp3.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:meyaoo_new/model/chatdetails/single_chat_list_model.dart';
import 'package:light_compressor/light_compressor.dart';
// ignore: depend_on_referenced_packages
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
  GetAllDeviceContact getAllDeviceContact = Get.put(GetAllDeviceContact());

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
    apis();
    super.initState();
  }

  Future<void> apis() async {
    await getContactsFromGloble();
    var contactJson = json.encode(mobileContacts);
    getAllDeviceContact.getAllContactApi(contact: contactJson);
  }

  bool matchContact(String num) {
    for (var i = 0; i < getAllDeviceContact.getList.length; i++) {
      if (num == getAllDeviceContact.getList[i].phoneNumber) {
        return true;
      }
    }
    return false;
  }

  List? chatMsgList;

  List chatID = [];
  List<MessageList> chatMessageList = [];
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
        appBar: isSelectedmessage == "0" ||
                chatID.isEmpty ||
                chatMessageList.isEmpty
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
                        child: Container(
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                              opacity: 0.05,
                              image:
                                  AssetImage("assets/images/chat_back_img.png"),
                              fit: BoxFit.cover)),
                      child: Stack(
                        children: [
                          NotificationListener<ScrollNotification>(
                              onNotification: (n) {
                                if (n.metrics.pixels <= HEIGHT) {
                                  notifier.value = n.metrics.pixels;

                                  // Calculate the index of the first visible message
                                  int firstVisibleIndex = (n.metrics.pixels /
                                          (HEIGHT /
                                              chatContorller
                                                  .userdetailschattModel
                                                  .value!
                                                  .messageList!
                                                  .length))
                                      .floor();
                                  if (firstVisibleIndex <
                                      chatContorller.userdetailschattModel
                                          .value!.messageList!.length) {
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
                                child: chatContorller.userdetailschattModel
                                            .value!.messageList!.isEmpty ||
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
                                                  height: isKeyboard ||
                                                          click == true
                                                      ? MediaQuery.sizeOf(
                                                                  context)
                                                              .height *
                                                          0.1
                                                      : MediaQuery.sizeOf(
                                                                  context)
                                                              .height *
                                                          0.2),
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
                                                                  widget
                                                                      .mobileNum
                                                                      .toString(),
                                                                  '',
                                                                  '')
                                                          : chatContorller
                                                              .sendMessageText(
                                                                  "Hi",
                                                                  widget
                                                                      .conversationID!,
                                                                  "text",
                                                                  "",
                                                                  '',
                                                                  '');
                                                },
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      1.5,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            15.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Image.asset(
                                                            "assets/images/start_conversation.png",
                                                            height: 200)
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
                                                controller:
                                                    listScrollController,
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
                                                controller:
                                                    listScrollController,
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
                                                                  .messageList![
                                                              index]));
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
                          chatContorller.userdetailschattModel.value!
                                      .messageList!.isEmpty ||
                                  chatContorller.userdetailschattModel.value!
                                          .messageList!.first.message ==
                                      null
                              ? const SizedBox.shrink()
                              : Padding(
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
                                                    alignment:
                                                        Alignment.bottomCenter,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          color:
                                                              Colors.grey[200],
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          40))),
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
                                                        icon: const Icon(Icons
                                                            .arrow_circle_down),
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
                                    width: MediaQuery.of(context).size.width *
                                        0.99,
                                    // height: 73,
                                    decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(00.0),
                                            topLeft: Radius.circular(00.0))),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                                    borderRadius: BorderRadius
                                                        .only(
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
                                                width:
                                                    MediaQuery.sizeOf(context)
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
                      ),
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
                                        ? floatbuttonNew()
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
      child: InkWell(
        onLongPress: () {
          if (chatID.isEmpty || chatMessageList.isEmpty) {
            msgDailogShow(data, data.senderData!);
          }
        },
        onTap: () {
          if (chatID.isNotEmpty || chatMessageList.isNotEmpty) {
            setState(() {
              chatID.contains(data.messageId.toString())
                  ? chatID.remove(data.messageId.toString())
                  : chatID.add(data.messageId.toString());
              //forward list
              chatMessageList.contains(data)
                  ? chatMessageList.remove(data)
                  : chatMessageList.add(data);

              print("MESSAGE_LISTTT:${chatMessageList.length}");
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
                    child: InkWell(
                        onTap: () {
                          // Handle checkbox state change if needed
                          setState(() {
                            chatID.contains(data.messageId.toString())
                                ? chatID.remove(data.messageId.toString())
                                : chatID.add(data.messageId.toString());
                            chatMessageList.contains(data)
                                ? chatMessageList.remove(data)
                                : chatMessageList.add(data);
                          });
                          print("ONTAPMSGID:$chatID");
                        },
                        child: chatID.isEmpty || chatMessageList.length == 0
                            ? const SizedBox()
                            : Transform.scale(
                                scale: 1.1,
                                child: chatID.contains(
                                            data.messageId.toString()) ||
                                        chatMessageList.contains(data)
                                    ? Container(
                                        width: 15.0,
                                        height: 15.0,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            color: bg1,
                                            gradient: LinearGradient(
                                                colors: [
                                                  blackColor,
                                                  black1Color
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomCenter)),
                                        child: Image.asset(
                                                "assets/images/right.png")
                                            .paddingAll(3))
                                    : Container(
                                        width: 15.0,
                                        height: 15.0,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            border:
                                                Border.all(color: black1Color),
                                            color: bg1),
                                      ))),
                  )
                : const SizedBox(
                    height: 10,
                  ),
            Container(
                padding: EdgeInsets.only(
                    left: chatID.isNotEmpty || chatMessageList.isNotEmpty
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
                                            topLeft: Radius.circular(15),
                                            topRight: Radius.circular(15),
                                            bottomRight: Radius.circular(15))
                                        : const BorderRadius.only(
                                            topRight: Radius.circular(15),
                                            topLeft: Radius.circular(15),
                                            bottomLeft: Radius.circular(15)),
                                    color: data.myMessage == false
                                        ? grey1Color
                                        : null,
                                    gradient: data.myMessage == false
                                        ? null
                                        : LinearGradient(
                                            colors: [
                                                yellow1Color,
                                                yellow2Color
                                              ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter)),
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
          if (chatID.isEmpty || chatMessageList.isEmpty) {
            msgDailogShow(data, data.senderData!);
          }
        },
        onTap: () {
          if (chatID.isNotEmpty || chatMessageList.isNotEmpty) {
            setState(() {
              chatID.contains(data.messageId.toString())
                  ? chatID.remove(data.messageId.toString())
                  : chatID.add(data.messageId.toString());
              //forward list
              chatMessageList.contains(data)
                  ? chatMessageList.remove(data)
                  : chatMessageList.add(data);

              print("MESSAGE_LISTTT:${chatMessageList.length}");
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
                    child: InkWell(
                        onTap: () {
                          // Handle checkbox state change if needed
                          setState(() {
                            chatID.contains(data.messageId.toString())
                                ? chatID.remove(data.messageId.toString())
                                : chatID.add(data.messageId.toString());
                            chatMessageList.contains(data)
                                ? chatMessageList.remove(data)
                                : chatMessageList.add(data);
                          });
                          print("ONTAPMSGID:$chatID");
                        },
                        child: chatID.length == 0 || chatMessageList.length == 0
                            ? const SizedBox()
                            : Transform.scale(
                                scale: 1.1,
                                child: chatID.contains(
                                            data.messageId.toString()) ||
                                        chatMessageList.contains(data)
                                    ? Container(
                                        width: 15.0,
                                        height: 15.0,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            color: bg1,
                                            gradient: LinearGradient(
                                                colors: [
                                                  blackColor,
                                                  black1Color
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomCenter)),
                                        child: Image.asset(
                                                "assets/images/right.png")
                                            .paddingAll(3))
                                    : Container(
                                        width: 15.0,
                                        height: 15.0,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            border:
                                                Border.all(color: black1Color),
                                            color: bg1),
                                      ))),
                  )
                : const SizedBox(height: 10),
            Container(
              padding: EdgeInsets.only(
                  left: chatID.isNotEmpty || chatMessageList.isNotEmpty
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
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                            borderRadius: data.myMessage == false
                                ? const BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15),
                                    bottomRight: Radius.circular(15))
                                : const BorderRadius.only(
                                    topRight: Radius.circular(15),
                                    topLeft: Radius.circular(15),
                                    bottomLeft: Radius.circular(15)),
                            color: data.myMessage == false ? grey1Color : null,
                            gradient: data.myMessage == false
                                ? null
                                : LinearGradient(
                                    colors: [yellow1Color, yellow2Color],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter)),
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: ClipRRect(
                            borderRadius: data.myMessage == false
                                ? const BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15),
                                    bottomRight: Radius.circular(15))
                                : const BorderRadius.only(
                                    topRight: Radius.circular(15),
                                    topLeft: Radius.circular(15),
                                    bottomLeft: Radius.circular(15)),
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
          if (chatID.isEmpty || chatMessageList.isEmpty) {
            msgDailogShow(data, data.senderData!);
          }
        },
        onTap: () {
          if (chatID.isNotEmpty || chatMessageList.isNotEmpty) {
            setState(() {
              chatID.contains(data.messageId.toString())
                  ? chatID.remove(data.messageId.toString())
                  : chatID.add(data.messageId.toString());
              //forward list
              chatMessageList.contains(data)
                  ? chatMessageList.remove(data)
                  : chatMessageList.add(data);

              print("MESSAGE_LISTTT:${chatMessageList.length}");
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
                    child: InkWell(
                        onTap: () {
                          // Handle checkbox state change if needed
                          setState(() {
                            chatID.contains(data.messageId.toString())
                                ? chatID.remove(data.messageId.toString())
                                : chatID.add(data.messageId.toString());
                            chatMessageList.contains(data)
                                ? chatMessageList.remove(data)
                                : chatMessageList.add(data);
                          });
                          print("ONTAPMSGID:$chatID");
                        },
                        child: chatID.length == 0 || chatMessageList.length == 0
                            ? const SizedBox()
                            : Transform.scale(
                                scale: 1.1,
                                child: chatID.contains(
                                            data.messageId.toString()) ||
                                        chatMessageList.contains(data)
                                    ? Container(
                                        width: 15.0,
                                        height: 15.0,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            color: bg1,
                                            gradient: LinearGradient(
                                                colors: [
                                                  blackColor,
                                                  black1Color
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomCenter)),
                                        child: Image.asset(
                                                "assets/images/right.png")
                                            .paddingAll(3))
                                    : Container(
                                        width: 15.0,
                                        height: 15.0,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            border:
                                                Border.all(color: black1Color),
                                            color: bg1),
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
                      left: chatID.isNotEmpty || chatMessageList.isNotEmpty
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
                                  borderRadius: data.myMessage == false
                                      ? const BorderRadius.only(
                                          topLeft: Radius.circular(15),
                                          topRight: Radius.circular(15),
                                          bottomRight: Radius.circular(15))
                                      : const BorderRadius.only(
                                          topRight: Radius.circular(15),
                                          topLeft: Radius.circular(15),
                                          bottomLeft: Radius.circular(15)),
                                  color: data.myMessage == false
                                      ? grey1Color
                                      : yellow1Color),
                              constraints: const BoxConstraints(
                                  minHeight: 10.0,
                                  minWidth: 10.0,
                                  maxWidth: 250),
                              child: InkWell(
                                onTap: () {
                                  MapUtils.openMap(double.parse(data.latitude!),
                                      double.parse(data.longitude!));
                                },
                                child: Container(
                                  height: 130,
                                  width: 250,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10)),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: data.latitude.toString() == "" ||
                                            data.longitude.toString() == ""
                                        ? Container(
                                            decoration: const BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(10),
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
                                            initialCameraPosition:
                                                CameraPosition(
                                                    target: LatLng(
                                                        double.parse(
                                                            data.latitude!),
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
                              ).paddingOnly(
                                  left: 4, top: 4, right: 4, bottom: 4),
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
          if (chatID.isEmpty || chatMessageList.isEmpty) {
            msgDailogShow(data, data.senderData!);
          }
        },
        onTap: () {
          if (chatID.isNotEmpty || chatMessageList.isNotEmpty) {
            setState(() {
              chatID.contains(data.messageId.toString())
                  ? chatID.remove(data.messageId.toString())
                  : chatID.add(data.messageId.toString());
              //forward list
              chatMessageList.contains(data)
                  ? chatMessageList.remove(data)
                  : chatMessageList.add(data);

              print("MESSAGE_LISTTT:${chatMessageList.length}");
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
                    child: InkWell(
                        onTap: () {
                          // Handle checkbox state change if needed
                          setState(() {
                            chatID.contains(data.messageId.toString())
                                ? chatID.remove(data.messageId.toString())
                                : chatID.add(data.messageId.toString());
                            chatMessageList.contains(data)
                                ? chatMessageList.remove(data)
                                : chatMessageList.add(data);
                          });
                          print("ONTAPMSGID:$chatID");
                        },
                        child: chatID.length == 0 || chatMessageList.length == 0
                            ? const SizedBox()
                            : Transform.scale(
                                scale: 1.1,
                                child: chatID.contains(
                                            data.messageId.toString()) ||
                                        chatMessageList.contains(data)
                                    ? Container(
                                        width: 15.0,
                                        height: 15.0,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            color: bg1,
                                            gradient: LinearGradient(
                                                colors: [
                                                  blackColor,
                                                  black1Color
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomCenter)),
                                        child: Image.asset(
                                                "assets/images/right.png")
                                            .paddingAll(3))
                                    : Container(
                                        width: 15.0,
                                        height: 15.0,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            border:
                                                Border.all(color: black1Color),
                                            color: bg1),
                                      ))),
                  )
                : const SizedBox(height: 10),
            Container(
              padding: EdgeInsets.only(
                  left: chatID.isNotEmpty || chatMessageList.isNotEmpty
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
                            username: data.myMessage == false
                                ? "${capitalizeFirstLetter(data.senderData!.firstName!)} ${capitalizeFirstLetter(data.senderData!.lastName!)}"
                                : "You",
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
                                width: 150,
                                height: 176,
                                decoration: BoxDecoration(
                                    borderRadius: data.myMessage == false
                                        ? const BorderRadius.only(
                                            topLeft: Radius.circular(15),
                                            topRight: Radius.circular(15),
                                            bottomRight: Radius.circular(15))
                                        : const BorderRadius.only(
                                            topRight: Radius.circular(15),
                                            topLeft: Radius.circular(15),
                                            bottomLeft: Radius.circular(15)),
                                    color: data.myMessage == false
                                        ? grey1Color
                                        : yellow1Color),
                                child: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: ClipRRect(
                                    borderRadius: data.myMessage == false
                                        ? const BorderRadius.only(
                                            topLeft: Radius.circular(15),
                                            topRight: Radius.circular(15),
                                            bottomRight: Radius.circular(15))
                                        : const BorderRadius.only(
                                            topRight: Radius.circular(15),
                                            topLeft: Radius.circular(15),
                                            bottomLeft: Radius.circular(15)),
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
                          top: 68,
                          left: 55,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VideoViewFix(
                                      username: data.myMessage == false
                                          ? "${capitalizeFirstLetter(data.senderData!.firstName!)} ${capitalizeFirstLetter(data.senderData!.lastName!)}"
                                          : "You",
                                      url: data.url!,
                                      play: true,
                                      mute: false,
                                      date: convertUTCTimeTo12HourFormat(
                                          data.createdAt!),
                                    ),
                                  ));
                            },
                            child: CircleAvatar(
                                radius: 20,
                                backgroundColor: blurColor,
                                foregroundColor: chatownColor,
                                child: Image.asset("assets/images/play2.png",
                                    height: 12)),
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
          if (chatID.isEmpty || chatMessageList.isEmpty) {
            msgDailogShow(data, data.senderData!);
          }
        },
        onTap: () {
          if (chatID.isNotEmpty || chatMessageList.isNotEmpty) {
            setState(() {
              chatID.contains(data.messageId.toString())
                  ? chatID.remove(data.messageId.toString())
                  : chatID.add(data.messageId.toString());
              //forward list
              chatMessageList.contains(data)
                  ? chatMessageList.remove(data)
                  : chatMessageList.add(data);

              print("MESSAGE_LISTTT:${chatMessageList.length}");
            });
          }
          print("ONTAPMSGID:$chatID");
        },
        child: Stack(
          children: [
            isSelectedmessage == "1"
                ? Positioned(
                    left: 5,
                    bottom: 35,
                    child: InkWell(
                        onTap: () {
                          // Handle checkbox state change if needed
                          setState(() {
                            chatID.contains(data.messageId.toString())
                                ? chatID.remove(data.messageId.toString())
                                : chatID.add(data.messageId.toString());
                            chatMessageList.contains(data)
                                ? chatMessageList.remove(data)
                                : chatMessageList.add(data);
                          });
                          print("ONTAPMSGID:$chatID");
                        },
                        child: chatID.length == 0 || chatMessageList.length == 0
                            ? const SizedBox()
                            : Transform.scale(
                                scale: 1.1,
                                child: chatID.contains(
                                            data.messageId.toString()) ||
                                        chatMessageList.contains(data)
                                    ? Container(
                                        width: 15.0,
                                        height: 15.0,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            color: bg1,
                                            gradient: LinearGradient(
                                                colors: [
                                                  blackColor,
                                                  black1Color
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomCenter)),
                                        child: Image.asset(
                                                "assets/images/right.png")
                                            .paddingAll(3))
                                    : Container(
                                        width: 15.0,
                                        height: 15.0,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            border:
                                                Border.all(color: black1Color),
                                            color: bg1),
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
                        height: 70,
                        width: 250,
                        padding: EdgeInsets.only(
                            left:
                                chatID.isNotEmpty || chatMessageList.isNotEmpty
                                    ? data.myMessage == false
                                        ? 35
                                        : 10
                                    : 3,
                            right: 3,
                            top: 0,
                            bottom: 0),
                        margin: const EdgeInsets.only(bottom: 5),
                        decoration: BoxDecoration(
                            borderRadius: data.myMessage == false
                                ? const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomRight: Radius.circular(10))
                                : const BorderRadius.only(
                                    topRight: Radius.circular(10),
                                    topLeft: Radius.circular(10),
                                    bottomLeft: Radius.circular(10)),
                            color: data.myMessage == false
                                ? grey1Color
                                : yellow1Color),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white),
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
                                child: SizedBox(
                                  width: Get.width * 0.50,
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
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Row(
                                        children: [
                                          const Image(
                                            height: 30,
                                            image: AssetImage(
                                                'assets/images/pdf.png'),
                                          ),
                                          FutureBuilder<Map<String, dynamic>>(
                                            future: getPdfInfo(data.url!),
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
                                                      extractFilename(data.url!)
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
                                                    const Text(
                                                      '0 Page - 0 KB',
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w400,
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
                                                                data.url!)
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
                                                        fontWeight:
                                                            FontWeight.w400,
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
                            ],
                          ),
                        ).paddingOnly(top: 3, bottom: 3),
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
        if (chatID.isEmpty || chatMessageList.isEmpty) {
          msgDailogShow(data, data.senderData!);
        }
      },
      onTap: () {
        if (chatID.isNotEmpty || chatMessageList.isNotEmpty) {
          setState(() {
            chatID.contains(data.messageId.toString())
                ? chatID.remove(data.messageId.toString())
                : chatID.add(data.messageId.toString());
            //forward list
            chatMessageList.contains(data)
                ? chatMessageList.remove(data)
                : chatMessageList.add(data);

            print("MESSAGE_LISTTT:${chatMessageList.length}");
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
                  child: InkWell(
                      onTap: () {
                        // Handle checkbox state change if needed
                        setState(() {
                          chatID.contains(data.messageId.toString())
                              ? chatID.remove(data.messageId.toString())
                              : chatID.add(data.messageId.toString());
                          chatMessageList.contains(data)
                              ? chatMessageList.remove(data)
                              : chatMessageList.add(data);
                        });
                        print("ONTAPMSGID:$chatID");
                      },
                      child: chatID.length == 0 || chatMessageList.length == 0
                          ? const SizedBox()
                          : Transform.scale(
                              scale: 1.1,
                              child: chatID.contains(
                                          data.messageId.toString()) ||
                                      chatMessageList.contains(data)
                                  ? Container(
                                      width: 15.0,
                                      height: 15.0,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          color: bg1,
                                          gradient: LinearGradient(
                                              colors: [blackColor, black1Color],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomCenter)),
                                      child:
                                          Image.asset("assets/images/right.png")
                                              .paddingAll(3))
                                  : Container(
                                      width: 15.0,
                                      height: 15.0,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          border:
                                              Border.all(color: black1Color),
                                          color: bg1),
                                    ))),
                )
              : const SizedBox(height: 10),
          Container(
            padding: EdgeInsets.only(
                left: chatID.isNotEmpty || chatMessageList.isNotEmpty
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
            child: myVoiceWidget(data, index),
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
          if (chatID.isEmpty || chatMessageList.isEmpty) {
            msgDailogShow(data, data.senderData!);
          }
        },
        onTap: () {
          if (chatID.isNotEmpty || chatMessageList.isNotEmpty) {
            setState(() {
              chatID.contains(data.messageId.toString())
                  ? chatID.remove(data.messageId.toString())
                  : chatID.add(data.messageId.toString());
              //forward list
              chatMessageList.contains(data)
                  ? chatMessageList.remove(data)
                  : chatMessageList.add(data);

              print("MESSAGE_LISTTT:${chatMessageList.length}");
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
                    child: InkWell(
                        onTap: () {
                          // Handle checkbox state change if needed
                          setState(() {
                            chatID.contains(data.messageId.toString())
                                ? chatID.remove(data.messageId.toString())
                                : chatID.add(data.messageId.toString());
                            chatMessageList.contains(data)
                                ? chatMessageList.remove(data)
                                : chatMessageList.add(data);
                          });
                          print("ONTAPMSGID:$chatID");
                        },
                        child: chatID.length == 0 || chatMessageList.length == 0
                            ? const SizedBox()
                            : Transform.scale(
                                scale: 1.1,
                                child: chatID.contains(
                                            data.messageId.toString()) ||
                                        chatMessageList.contains(data)
                                    ? Container(
                                        width: 15.0,
                                        height: 15.0,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            color: bg1,
                                            gradient: LinearGradient(
                                                colors: [
                                                  blackColor,
                                                  black1Color
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomCenter)),
                                        child: Image.asset(
                                                "assets/images/right.png")
                                            .paddingAll(3))
                                    : Container(
                                        width: 15.0,
                                        height: 15.0,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            border:
                                                Border.all(color: black1Color),
                                            color: bg1),
                                      ))),
                  )
                : const SizedBox(height: 10),
            Container(
              padding: EdgeInsets.only(
                  left: chatID.isNotEmpty || chatMessageList.isNotEmpty
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
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                            borderRadius: data.myMessage == false
                                ? const BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15),
                                    bottomRight: Radius.circular(15))
                                : const BorderRadius.only(
                                    topRight: Radius.circular(15),
                                    topLeft: Radius.circular(15),
                                    bottomLeft: Radius.circular(15)),
                            color: data.myMessage == false
                                ? grey1Color
                                : yellow1Color),
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: ClipRRect(
                            borderRadius: data.myMessage == false
                                ? const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomRight: Radius.circular(10))
                                : const BorderRadius.only(
                                    topRight: Radius.circular(10),
                                    topLeft: Radius.circular(10),
                                    bottomLeft: Radius.circular(10)),
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

  Widget getHttpLinkMessage(index, MessageList data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onLongPress: () {
          if (chatID.isEmpty || chatMessageList.isEmpty) {
            msgDailogShow(data, data.senderData!);
          }
        },
        onTap: () {
          if (chatID.isNotEmpty || chatMessageList.isNotEmpty) {
            setState(() {
              chatID.contains(data.messageId.toString())
                  ? chatID.remove(data.messageId.toString())
                  : chatID.add(data.messageId.toString());
              //forward list
              chatMessageList.contains(data)
                  ? chatMessageList.remove(data)
                  : chatMessageList.add(data);

              print("MESSAGE_LISTTT:${chatMessageList.length}");
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
                    child: InkWell(
                        onTap: () {
                          // Handle checkbox state change if needed
                          setState(() {
                            chatID.contains(data.messageId.toString())
                                ? chatID.remove(data.messageId.toString())
                                : chatID.add(data.messageId.toString());
                            chatMessageList.contains(data)
                                ? chatMessageList.remove(data)
                                : chatMessageList.add(data);
                          });
                          print("ONTAPMSGID:$chatID");
                        },
                        child: chatID.length == 0 || chatMessageList.length == 0
                            ? const SizedBox()
                            : Transform.scale(
                                scale: 1.1,
                                child: chatID.contains(
                                            data.messageId.toString()) ||
                                        chatMessageList.contains(data)
                                    ? Container(
                                        width: 15.0,
                                        height: 15.0,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            color: bg1,
                                            gradient: LinearGradient(
                                                colors: [
                                                  blackColor,
                                                  black1Color
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomCenter)),
                                        child: Image.asset(
                                                "assets/images/right.png")
                                            .paddingAll(3))
                                    : Container(
                                        width: 15.0,
                                        height: 15.0,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            border:
                                                Border.all(color: black1Color),
                                            color: bg1),
                                      ))),
                  )
                : const SizedBox(height: 10),
            Container(
                padding: EdgeInsets.only(
                    left: chatID.isNotEmpty || chatMessageList.isNotEmpty
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
                                    maxHeight:
                                        MediaQuery.of(context).size.width / 3.7,
                                    maxWidth:
                                        MediaQuery.of(context).size.width * .8),
                                decoration: BoxDecoration(
                                    borderRadius: data.myMessage == false
                                        ? const BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10),
                                            bottomRight: Radius.circular(10))
                                        : const BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10),
                                            bottomLeft: Radius.circular(10)),
                                    color: data.myMessage == false
                                        ? grey1Color
                                        : yellow1Color),
                                padding: const EdgeInsets.only(
                                    left: 5, right: 5, top: 5, bottom: 5),
                                child: InkWell(
                                  onTap: () {
                                    launchURL(data.message!);
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.only(
                                            left: 5,
                                            right: 5,
                                            top: 5,
                                            bottom: 5),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10)),
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
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: data.myMessage ==
                                                                false
                                                            ? Colors.white
                                                            : Colors.black,
                                                      ),
                                                    )
                                                  : Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        if (info.image != null)
                                                          Container(
                                                            height: 58,
                                                            width: 57,
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
                                                              child: Image.network(
                                                                  info.image!,
                                                                  fit: BoxFit
                                                                      .cover),
                                                            ),
                                                          ),
                                                        const SizedBox(
                                                            width: 5),
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
                                                                    fontSize:
                                                                        14,
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
                                                                      fontSize:
                                                                          9,
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
                                          titleStyle: TextStyle(
                                            color: data.myMessage == false
                                                ? Colors.white
                                                : Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        data.message!,
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
          if (chatID.isEmpty || chatMessageList.isEmpty) {
            msgDailogShow(data, data.senderData!);
          }
        },
        onTap: () {
          if (chatID.isNotEmpty || chatMessageList.isNotEmpty) {
            setState(() {
              chatID.contains(data.messageId.toString())
                  ? chatID.remove(data.messageId.toString())
                  : chatID.add(data.messageId.toString());
              //forward list
              chatMessageList.contains(data)
                  ? chatMessageList.remove(data)
                  : chatMessageList.add(data);

              print("MESSAGE_LISTTT:${chatMessageList.length}");
            });
          }
          print("ONTAPMSGID:$chatID");
        },
        child: Stack(
          children: [
            isSelectedmessage == "1"
                ? Positioned(
                    left: 5,
                    bottom: 35,
                    child: InkWell(
                        onTap: () {
                          // Handle checkbox state change if needed
                          setState(() {
                            chatID.contains(data.messageId.toString())
                                ? chatID.remove(data.messageId.toString())
                                : chatID.add(data.messageId.toString());
                            chatMessageList.contains(data)
                                ? chatMessageList.remove(data)
                                : chatMessageList.add(data);
                          });
                          print("ONTAPMSGID:$chatID");
                        },
                        child: chatID.length == 0 || chatMessageList.length == 0
                            ? const SizedBox()
                            : Transform.scale(
                                scale: 1.1,
                                child: chatID.contains(
                                            data.messageId.toString()) ||
                                        chatMessageList.contains(data)
                                    ? Container(
                                        width: 15.0,
                                        height: 15.0,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            color: bg1,
                                            gradient: LinearGradient(
                                                colors: [
                                                  blackColor,
                                                  black1Color
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomCenter)),
                                        child: Image.asset(
                                                "assets/images/right.png")
                                            .paddingAll(3))
                                    : Container(
                                        width: 15.0,
                                        height: 15.0,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            border:
                                                Border.all(color: black1Color),
                                            color: bg1),
                                      ))),
                  )
                : const SizedBox(
                    height: 10,
                  ),
            Container(
                padding: EdgeInsets.only(
                    left: chatID.isNotEmpty || chatMessageList.isNotEmpty
                        ? data.myMessage == false
                            ? 35
                            : 10
                        : 3,
                    right: 3,
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
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10),
                                            bottomRight: Radius.circular(10))
                                        : const BorderRadius.only(
                                            topRight: Radius.circular(10),
                                            topLeft: Radius.circular(10),
                                            bottomLeft: Radius.circular(10)),
                                    color: data.myMessage == false
                                        ? grey1Color
                                        : yellow1Color),
                                padding: const EdgeInsets.all(3),
                                child: Column(
                                  children: [
                                    Container(
                                      height: 50,
                                      width: 200,
                                      decoration: BoxDecoration(
                                          borderRadius: matchContact(
                                                  data.sharedContactNumber!)
                                              ? BorderRadius.circular(10)
                                              : const BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  topRight:
                                                      Radius.circular(10)),
                                          color: Colors.white),
                                      child: Row(
                                        children: [
                                          const SizedBox(width: 20),
                                          Container(
                                            height: 30,
                                            width: 30,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(35)),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(35),
                                              child: CustomCachedNetworkImage(
                                                  imageUrl: data
                                                      .sharedContactProfileImage!,
                                                  placeholderColor:
                                                      chatownColor,
                                                  errorWidgeticon: const Icon(
                                                    Icons.person,
                                                    size: 30,
                                                  )),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                capitalizeFirstLetter(
                                                    data.sharedContactName!),
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color: chatColor),
                                              ),
                                              Text(
                                                capitalizeFirstLetter(
                                                    data.sharedContactNumber!),
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
                                    matchContact(data.sharedContactNumber!)
                                        ? const SizedBox.shrink()
                                        : InkWell(
                                            onTap: () {
                                              Get.to(() => SaveContact(
                                                  name: data.sharedContactName!,
                                                  number: data
                                                      .sharedContactNumber!));
                                            },
                                            child: Container(
                                              height: 30,
                                              width: 200,
                                              decoration: const BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  10),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  10)),
                                                  color: Colors.white),
                                              child: const Column(
                                                children: [
                                                  SizedBox(height: 3),
                                                  Text(
                                                    "View contact",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: chatColor),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                  ],
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

  Widget getReplyMessage(index, MessageList data) {
    return InkWell(
      onLongPress: () {
        if (chatID.isEmpty || chatMessageList.isEmpty) {
          msgDailogShow(data, data.senderData!);
        }
      },
      onTap: () {
        if (chatID.isNotEmpty || chatMessageList.isNotEmpty) {
          setState(() {
            chatID.contains(data.messageId.toString())
                ? chatID.remove(data.messageId.toString())
                : chatID.add(data.messageId.toString());
            //forward list
            chatMessageList.contains(data)
                ? chatMessageList.remove(data)
                : chatMessageList.add(data);

            print("MESSAGE_LISTTT:${chatMessageList.length}");
          });
        }
        print("ONTAPMSGID:$chatID");
      },
      child: replyMSGWidget(
          data,
          // msg list index
          index,
          data.senderData!),
    );
  }

//================================================================= KEYBOARD =================================================================================

  bool click = false;

//================================= FORWARD MESSAGE DESIGN ==========================================
  Widget floatbutton1() {
    return chatID.isEmpty
        ? floatbuttonNew()
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
                                    forwardMsgList: chatMessageList,
                                  ),
                                ));
                            chatMessageList = [];
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
                                chatMessageList = [];
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

  Widget floatbuttonNew() {
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                    color: Colors.white),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      Expanded(
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
                          decoration: InputDecoration(
                              alignLabelWithHint: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 2, vertical: 5),
                              border: InputBorder.none,
                              hintText: "Type Message",
                              hintStyle: TextStyle(
                                  color: darkGreyColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400),
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
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                click = !click;
                                closekeyboard();
                              });
                            },
                            child: Image.asset("assets/images/pin.png",
                                height: 20, color: darkGreyColor),
                          ).paddingOnly(left: 10),
                          const SizedBox(width: 10),
                          InkWell(
                            onTap: () {
                              getImageFromCamera();
                              messagecontroller.clear();
                            },
                            child: Image.asset("assets/images/camera1.png",
                                height: 20, color: darkGreyColor),
                          ),
                        ],
                      )
                    ],
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
                          print(messagecontroller.text.trim());
                          print(widget.conversationID);
                          print('text');
                          print(widget.mobileNum);
                          chatContorller.sendMessageText(
                              messagecontroller.text.trim(),
                              widget.conversationID.toString(),
                              'text',
                              widget.mobileNum.toString(),
                              '',
                              reply_chatID);
                          SelectedreplyText = false;
                          chatContorller.isTypingApi(
                              widget.conversationID!, "0");
                          controller.isTyping();
                          typingstart = "0";
                          chatContorller.isSendMsg.value = false;
                          listScrollController!.jumpTo(
                              listScrollController!.position.minScrollExtent);
                        } catch (e) {
                          chatContorller.isSendMsg.value = false;
                          print(e);
                          showCustomToast("Something Error1");
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
                              widget.mobileNum.toString(),
                              '',
                              '');
                          chatContorller.isTypingApi(
                              widget.conversationID!, "0");
                          controller.isTyping();
                          typingstart = "0";
                          chatContorller.isSendMsg.value = false;
                          listScrollController!.jumpTo(
                              listScrollController!.position.minScrollExtent);
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
                  child: Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                              colors: [yellow1Color, yellow2Color],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter)),
                      child: messagecontroller.text.isNotEmpty && isSendbutton
                          ? Image.asset("assets/images/send.png",
                                  color: chatColor)
                              .paddingAll(12)
                          : Image.asset("assets/images/microphone-2.png",
                                  color: chatColor)
                              .paddingAll(12))),
            )
          ],
        ),
        Platform.isIOS
            ? const SizedBox(height: 30)
            : const SizedBox(height: 10),
        click
            ? Container(
                height: 250,
                width: MediaQuery.of(context).size.width * 0.99,
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
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
                                  Image.asset("assets/images/doc1.png",
                                      height: 50),
                                  const SizedBox(height: 8),
                                  const Text('File',
                                      style: TextStyle(
                                          color: chatColor,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 13))
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
                                  child: const Image(
                                    height: 50,
                                    image: AssetImage(
                                      'assets/images/photos.png',
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                const Text('Photo',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 13))
                              ],
                            ),
                          ),
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
                              child: const Column(
                                children: [
                                  Image(
                                    height: 50,
                                    image: AssetImage(
                                      'assets/images/video_gallery.png',
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Text('Video',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 13))
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
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
                                  child: const Image(
                                    height: 50,
                                    image: AssetImage(
                                      'assets/images/gif1.png',
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text('Gif',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 13))
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
                              child: const Image(
                                height: 82,
                                image: AssetImage(
                                  'assets/images/loca1.png',
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                click = !click;
                              });
                              Get.to(
                                      () => ContactSend(
                                            conversationID:
                                                widget.conversationID!,
                                            mobileNum:
                                                widget.mobileNum.toString(),
                                            SelectedreplyText:
                                                SelectedreplyText,
                                            replyID: reply_chatID,
                                          ),
                                      transition: Transition.leftToRight)!
                                  .then((_) {
                                listScrollController!.jumpTo(
                                    listScrollController!
                                        .position.minScrollExtent);
                              });
                            },
                            child: const Image(
                                height: 82,
                                image: AssetImage(
                                  'assets/images/cont1.png',
                                )),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink()
      ],
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
      if (SelectedreplyText == true) {
        chatContorller.sendMessageVoice(
            widget.conversationID!,
            "audio",
            File(recordFilePath),
            '',
            audioController.total,
            widget.mobileNum.toString(),
            '',
            reply_chatID,
            false);
        SelectedreplyText = false;
        listScrollController!
            .jumpTo(listScrollController!.position.minScrollExtent);
      } else {
        chatContorller.sendMessageVoice(
            widget.conversationID!,
            "audio",
            File(recordFilePath),
            '',
            audioController.total,
            widget.mobileNum.toString(),
            '',
            '',
            false);
        listScrollController!
            .jumpTo(listScrollController!.position.minScrollExtent);
      }
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
                        setState1(() {
                          record = true;
                        });
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
                          gradient: LinearGradient(
                              colors: [yellow1Color, yellow2Color],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter)),
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
                          gradient: LinearGradient(
                              colors: [yellow1Color, yellow2Color],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter)),
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

  Widget myVoiceWidget(MessageList data, index) {
    return Container(
      padding: const EdgeInsets.only(right: 12, top: 0, bottom: 0),
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
                data.replyId == 0
                    ? _audio(
                        message: data.url!,
                        isCurrentUser: data.myMessage == false,
                        index: index,
                        duration: data.audioTime!)
                    : _audioReply(
                        message: data.url!,
                        isCurrentUser: data.myMessage == false,
                        index: index,
                        duration: data.audioTime!),
                data.replyId == 0
                    ? Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: SizedBox(
                          child: timestpa(data.messageRead.toString(),
                              data.createdAt!, data.isStarMessage!),
                        ))
                    : const SizedBox.shrink()
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
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      height: 65,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          borderRadius: isCurrentUser
              ? const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10))
              : const BorderRadius.only(
                  topRight: Radius.circular(10),
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10)),
          color: isCurrentUser ? grey1Color : yellow1Color),
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
                        color: isCurrentUser ? grey1Color : yellow1Color,
                      )
                    : Icon(
                        CupertinoIcons.play_circle_fill,
                        color: isCurrentUser ? grey1Color : yellow1Color,
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
    required bool isCurrentUser,
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
            // chatContorller.sendMessageRpltIMGDoc(widget.conversationID, 'image',
            //     value!.path, reply_chatID, widget.mobileNum.toString());
            chatContorller.sendMessageIMGDoc(
                widget.conversationID,
                'image',
                value!.path,
                widget.mobileNum.toString(),
                '',
                reply_chatID,
                false);
            SelectedreplyText = false;
            listScrollController!
                .jumpTo(listScrollController!.position.minScrollExtent);
          } else {
            chatContorller.sendMessageIMGDoc(widget.conversationID, 'image',
                value!.path, widget.mobileNum.toString(), '', '', false);
            listScrollController!
                .jumpTo(listScrollController!.position.minScrollExtent);
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
            chatContorller.sendMessageIMGDoc(
                widget.conversationID,
                'image',
                value!.path,
                widget.mobileNum.toString(),
                '',
                reply_chatID,
                false);
            SelectedreplyText = false;
          } else {
            chatContorller.sendMessageIMGDoc(widget.conversationID, 'image',
                value!.path, widget.mobileNum.toString(), '', '', false);
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
          chatContorller.sendMessageIMGDoc(widget.conversationID, 'document',
              doc!.path, widget.mobileNum.toString(), '', reply_chatID, false);
          SelectedreplyText = false;
        } else {
          chatContorller.sendMessageIMGDoc(widget.conversationID, 'document',
              doc!.path, widget.mobileNum.toString(), '', '', false);
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
            // chatContorller.sendMessageVideoRply(widget.conversationID, "video",
            //     compressedVideos, reply_chatID, widget.mobileNum.toString());
            chatContorller.sendMessageVideo(
                widget.conversationID,
                "video",
                compressedVideos,
                widget.mobileNum.toString(),
                '',
                reply_chatID,
                false);
            SelectedreplyText = false;
            listScrollController!
                .jumpTo(listScrollController!.position.minScrollExtent);
          } else {
            chatContorller.sendMessageVideo(widget.conversationID, "video",
                compressedVideos, widget.mobileNum.toString(), '', '', false);
            listScrollController!
                .jumpTo(listScrollController!.position.minScrollExtent);
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
          // chatContorller.sendMessageGIFRply(widget.conversationID, 'gif', bytes,
          //     reply_chatID, widget.mobileNum.toString());
          chatContorller.sendMessageGIF(widget.conversationID, 'gif', bytes, '',
              widget.mobileNum.toString(), '', reply_chatID);
          SelectedreplyText = false;
          listScrollController!
              .jumpTo(listScrollController!.position.minScrollExtent);
        } else {
          chatContorller.sendMessageGIF(widget.conversationID, 'gif', bytes, '',
              widget.mobileNum.toString(), '', '');
          listScrollController!
              .jumpTo(listScrollController!.position.minScrollExtent);
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
      // chatContorller.sendMessageLocationRply(widget.conversationID!, "location",
      //     _placeLat!, _placeLong!, reply_chatID, widget.mobileNum.toString());
      chatContorller.sendMessageLocation(
          widget.conversationID!,
          "location",
          _placeLat!,
          _placeLong!,
          widget.mobileNum.toString(),
          '',
          reply_chatID);
      SelectedreplyText = false;
      listScrollController!
          .jumpTo(listScrollController!.position.minScrollExtent);
    } else {
      chatContorller.sendMessageLocation(widget.conversationID!, "location",
          _placeLat!, _placeLong!, widget.mobileNum.toString(), '', '');
      listScrollController!
          .jumpTo(listScrollController!.position.minScrollExtent);
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
  Future msgDailogShow(MessageList data, SenderData users) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: const Color.fromRGBO(30, 30, 30, 0.37),
              ),
            ),
            AlertDialog(
              insetPadding: const EdgeInsets.all(15),
              alignment: Alignment.bottomCenter,
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
                    data.messageType == "location"
                        ? capitalizeFirstLetter("📌 Location")
                        : data.messageType == "video"
                            ? capitalizeFirstLetter("🎥 Video")
                            : data.messageType == "image"
                                ? capitalizeFirstLetter("📷 Photo")
                                : data.messageType == "document"
                                    ? capitalizeFirstLetter("📄 Documenet")
                                    : data.messageType == "audio"
                                        ? capitalizeFirstLetter(
                                            "🔊 Voice message")
                                        : data.messageType == "link"
                                            ? capitalizeFirstLetter(
                                                data.message!)
                                            : data.messageType == "gif"
                                                ? "GIF"
                                                : data.messageType == "contact"
                                                    ? "Contact"
                                                    : capitalizeFirstLetter(
                                                        data.message!),
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
                  //================ COPY ===============================
                  data.messageType != "location" &&
                          data.messageType != "image" &&
                          data.messageType != "video" &&
                          data.messageType != "document" &&
                          data.messageType != "audio" &&
                          data.messageType != "gif" &&
                          data.messageType != "contact"
                      ? SizedBox(
                          height: 45,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                // chatID.add(msgID);
                                // isSelectedmessage = "1";
                              });
                              Navigator.pop(context);
                              Clipboard.setData(
                                  ClipboardData(text: data.message!));
                              showCustomToast("Message copied");
                              // Add your copy functionality here
                            },
                            child: Row(
                              children: [
                                const SizedBox(width: 10),
                                Image.asset("assets/images/copy.png",
                                    height: 18, color: chatColor),
                                const SizedBox(width: 10),
                                const Text(
                                  'Copy',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                )
                              ],
                            ),
                          ))
                      : const SizedBox.shrink(),
                  // Add SizedBox between Copy and Forward
                  data.messageType != "location" &&
                          data.messageType != "image" &&
                          data.messageType != "video" &&
                          data.messageType != "docdocument" &&
                          data.messageType != "audio" &&
                          data.messageType != "gif" &&
                          data.messageType != "contact"
                      ? Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey[200],
                        )
                      : const SizedBox.shrink(),
                  //================================== REPLY ================================
                  SizedBox(
                      height: 45,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            SelectedreplyText = !SelectedreplyText;
                            USERTEXT = data.myMessage == false
                                ? "${users.firstName} ${users.lastName!}"
                                : "You";
                            replyText = (data.messageType == "text"
                                ? data.message
                                : data.messageType == "location"
                                    ? "📌 Location"
                                    : data.messageType == "image"
                                        ? "📷 Photo"
                                        : data.messageType == "video"
                                            ? "🎥 Video"
                                            : data.messageType == "docdocument"
                                                ? "📄 Documenet"
                                                : data.messageType == "audio"
                                                    ? "🔊 Voice message"
                                                    : data.messageType == "gif"
                                                        ? "GIF"
                                                        : data.messageType ==
                                                                "contact"
                                                            ? "Contact"
                                                            : data.message)!;
                            reply_chatID = data.messageId.toString();
                            // rplyTime = time;
                            print("TEXT:$replyText");
                            print("RPLYTIME:$rplyTime");
                            print("RPLY$SelectedreplyText");
                            print("SELECT_MSG_ID:$reply_chatID");
                          });
                        },
                        child: Row(
                          children: [
                            const SizedBox(width: 10),
                            Image.asset("assets/images/reply.png",
                                height: 18, color: chatColor),
                            const SizedBox(width: 10),
                            const Text(
                              'Reply',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          ],
                        ),
                      )),

                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.grey[200],
                  ),
                  // Add your forward functionality here
                  SizedBox(
                    height: 45,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          chatID.add(data.messageId.toString());
                          chatMessageList.add(data);
                          isSelectedmessage = "1";
                          print("MSGID:${data.messageId}");
                          print("MESSAGE_LIST:${chatMessageList.length}");
                        });
                        // Add your forward functionality here
                      },
                      child: Row(
                        children: [
                          const SizedBox(width: 10),
                          Image.asset("assets/images/forward1.png",
                              height: 18, color: chatColor),
                          const SizedBox(width: 10),
                          const Text(
                            'Forward',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.grey[200],
                  ),
                  // ========================== delete =============================
                  SizedBox(
                    height: 45,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          chatID.add(data.messageId.toString());
                          chatMessageList.add(data);
                          isSelectedmessage = "1";
                          print("MSGID:${data.messageId}");
                          print("MESSAGE_LIST:$chatMessageList");
                        });
                      },
                      child: Row(
                        children: [
                          const SizedBox(width: 10),
                          Image.asset("assets/images/trash.png",
                              height: 18, color: chatColor),
                          const SizedBox(width: 10),
                          const Text(
                            'Delete',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.grey[200],
                  ),
                  SizedBox(
                    height: 45,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        if (data.isStarMessage != false) {
                          print("******");
                          chatContorller
                              .removeStarApi(data.messageId.toString());
                        } else {
                          chatContorller.addStarApi(data.messageId.toString());
                          print("+++++++");
                        }
                        // starchat(msgID);
                      },
                      child: Row(
                        children: [
                          const SizedBox(width: 10),
                          data.isStarMessage != false
                              ? Image.asset("assets/images/star-slash.png",
                                  color: chatColor, height: 18) //starUnfill
                              : Image.asset("assets/images/starUnfill.png",
                                  color: chatColor, height: 18),
                          const SizedBox(width: 10),
                          Text(
                            data.isStarMessage != false
                                ? 'Unstar Message'
                                : 'Star Message',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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

  Widget replyMSGWidget(MessageList data, int index, SenderData users) {
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
                          chatID.contains(data.messageId.toString())
                              ? chatID.remove(data.messageId.toString())
                              : chatID.add(data.messageId.toString());
                          chatMessageList.contains(data)
                              ? chatMessageList.remove(data)
                              : chatMessageList.add(data);
                        });
                        print("ONTAPMSGID:$chatID");
                      },
                      child: chatID.length == 0 || chatMessageList.length == 0
                          ? const SizedBox()
                          : Transform.scale(
                              scale: 1.1,
                              child: chatID.contains(
                                          data.messageId.toString()) ||
                                      chatMessageList.contains(data)
                                  ? Container(
                                      width: 15.0,
                                      height: 15.0,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          color: bg1,
                                          gradient: LinearGradient(
                                              colors: [blackColor, black1Color],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomCenter)),
                                      child:
                                          Image.asset("assets/images/right.png")
                                              .paddingAll(3))
                                  : Container(
                                      width: 15.0,
                                      height: 15.0,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          border:
                                              Border.all(color: black1Color),
                                          color: bg1),
                                    ))),
                )
              : const SizedBox(height: 10),
          Container(
            padding: EdgeInsets.only(
                left: chatID.isNotEmpty || chatMessageList.isNotEmpty
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
                            padding: const EdgeInsets.only(
                                left: 5, right: 5, top: 0, bottom: 0),
                            decoration: BoxDecoration(
                                borderRadius: data.myMessage == false
                                    ? const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                        bottomRight: Radius.circular(10))
                                    : const BorderRadius.only(
                                        topRight: Radius.circular(10),
                                        topLeft: Radius.circular(10),
                                        bottomLeft: Radius.circular(10)),
                                color: data.myMessage == false
                                    ? grey1Color
                                    : yellow1Color),
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
                                          data.replyId) {
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
                                        bottom: 5, top: 5),
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
                                            RichText(
                                                textAlign: TextAlign.start,
                                                text: TextSpan(children: [
                                                  TextSpan(
                                                    text: isUserMatch(
                                                        data.replyId.toString(),
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
                                              isMatching(
                                                  data.replyId.toString()),
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
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: data.messageType == "text"
                                      ? Text(data.message!)
                                      : data.messageType == "document"
                                          ? InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    PageTransition(
                                                      curve: Curves.linear,
                                                      type: PageTransitionType
                                                          .rightToLeft,
                                                      child: FileView(
                                                          file: data.url!),
                                                    ));
                                              },
                                              child: Row(
                                                children: [
                                                  const Image(
                                                    height: 30,
                                                    image: AssetImage(
                                                        'assets/images/pdf.png'),
                                                  ),
                                                  FutureBuilder<
                                                      Map<String, dynamic>>(
                                                    future:
                                                        getPdfInfo(data.url!),
                                                    builder:
                                                        (context, snapshot) {
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
                                                              extractFilename(
                                                                      data.url!)
                                                                  .toString()
                                                                  .split("-")
                                                                  .last,
                                                              style:
                                                                  const TextStyle(
                                                                color:
                                                                    chatColor,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                            const Text(
                                                              '0 Page - 0 KB',
                                                              style: TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              ),
                                                            )
                                                          ],
                                                        ).paddingOnly(left: 12);
                                                      } else if (snapshot
                                                          .hasError) {
                                                        return const Text('');
                                                      } else if (snapshot
                                                          .hasData) {
                                                        final int pageCount =
                                                            snapshot.data![
                                                                'pageCount'];
                                                        final String fileSize =
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
                                                                      left: 11),
                                                              child: Text(
                                                                extractFilename(
                                                                        data.url!)
                                                                    .toString()
                                                                    .split("-")
                                                                    .last,
                                                                style:
                                                                    const TextStyle(
                                                                  color:
                                                                      chatColor,
                                                                  fontSize: 14,
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
                                                                color:
                                                                    Colors.grey,
                                                                fontSize: 10,
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
                                                  const SizedBox(height: 15)
                                                ],
                                              ),
                                            )
                                          : data.messageType == "image"
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
                                                            image: data.url!,
                                                            userimg: users
                                                                .profileImage!,
                                                          )),
                                                    );
                                                  },
                                                  child: SizedBox(
                                                    width: 210,
                                                    height: 150,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      child: CachedNetworkImage(
                                                        imageUrl: data.url!,
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
                                              : data.messageType == "video"
                                                  ? Stack(
                                                      children: [
                                                        SizedBox(
                                                          width: 210,
                                                          height: 150,
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            child:
                                                                CachedNetworkImage(
                                                              imageUrl: data
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
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                        Positioned(
                                                            top: 50,
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
                                                                        url: data
                                                                            .url!,
                                                                        play:
                                                                            true,
                                                                        mute:
                                                                            false,
                                                                        date: convertUTCTimeTo12HourFormat(
                                                                            data.createdAt!),
                                                                      ),
                                                                    ));
                                                              },
                                                              child: CircleAvatar(
                                                                  radius: 20,
                                                                  backgroundColor:
                                                                      blurColor,
                                                                  foregroundColor:
                                                                      chatownColor,
                                                                  child: Image.asset(
                                                                      "assets/images/play2.png",
                                                                      height:
                                                                          12)),
                                                            ))
                                                      ],
                                                    )
                                                  : data.messageType ==
                                                          "location"
                                                      ? InkWell(
                                                          onTap: () {
                                                            MapUtils.openMap(
                                                                double.parse(data
                                                                    .latitude!),
                                                                double.parse(data
                                                                    .longitude!));
                                                          },
                                                          child: Container(
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
                                                              height: 130,
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
                                                                child: data.latitude ==
                                                                            "" ||
                                                                        data.longitude ==
                                                                            ""
                                                                    ? Container(
                                                                        decoration:
                                                                            const BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/map_Blurr.png"), fit: BoxFit.cover)),
                                                                        child:
                                                                            Icon(
                                                                          Icons
                                                                              .error_outline,
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
                                                                            target:
                                                                                LatLng(double.parse(data.latitude!), double.parse(data.longitude!)),
                                                                            zoom: 15),
                                                                        mapType:
                                                                            MapType.normal,
                                                                        onMapCreated:
                                                                            (GoogleMapController
                                                                                controller111) {
                                                                          // controller.complete();
                                                                        },
                                                                      ),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : data.messageType ==
                                                              "audio"
                                                          ? myVoiceWidget(
                                                              data, index)
                                                          : data.messageType ==
                                                                  "link"
                                                              ? FlutterLinkPreview(
                                                                  url: data
                                                                      .message!,
                                                                  builder:
                                                                      (info) {
                                                                    if (info
                                                                        is WebInfo) {
                                                                      return info.title == null &&
                                                                              info.description == null
                                                                          ? Text(
                                                                              data.message!,
                                                                              style: TextStyle(
                                                                                fontSize: 14,
                                                                                fontWeight: FontWeight.w400,
                                                                                color: data.myMessage == false ? Colors.white : Colors.black,
                                                                              ),
                                                                            )
                                                                          : Row(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                                              children: [
                                                                                if (info.image != null)
                                                                                  Container(
                                                                                    height: 58,
                                                                                    width: 57,
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
                                                                  titleStyle:
                                                                      TextStyle(
                                                                    color: data.myMessage ==
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
                                                              : data.messageType ==
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
                                                                                image: data.url!,
                                                                                userimg: users.profileImage!,
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
                                                                              BorderRadius.circular(10),
                                                                          child:
                                                                              CachedNetworkImage(
                                                                            imageUrl:
                                                                                data.url!,
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
                                                                  : data.messageType ==
                                                                          "contact"
                                                                      ? Column(
                                                                          children: [
                                                                            Container(
                                                                              height: 50,
                                                                              width: 210,
                                                                              decoration: BoxDecoration(borderRadius: matchContact(data.sharedContactNumber!) ? BorderRadius.circular(10) : const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)), color: Colors.white),
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
                                                                                          imageUrl: data.sharedContactProfileImage!,
                                                                                          placeholderColor: chatownColor,
                                                                                          errorWidgeticon: const Icon(
                                                                                            Icons.person,
                                                                                            size: 30,
                                                                                          )),
                                                                                    ),
                                                                                  ),
                                                                                  const SizedBox(width: 5),
                                                                                  Column(
                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: [
                                                                                      Text(
                                                                                        capitalizeFirstLetter(data.sharedContactName!),
                                                                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: chatColor),
                                                                                      ),
                                                                                      Text(
                                                                                        capitalizeFirstLetter(data.sharedContactNumber!),
                                                                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: chatColor),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            const SizedBox(height: 3),
                                                                            matchContact(data.sharedContactNumber!)
                                                                                ? const SizedBox.shrink()
                                                                                : InkWell(
                                                                                    onTap: () {
                                                                                      Get.to(() => SaveContact(name: data.sharedContactName!, number: data.sharedContactNumber!));
                                                                                    },
                                                                                    child: Container(
                                                                                      height: 30,
                                                                                      width: 210,
                                                                                      decoration: const BoxDecoration(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)), color: Colors.white),
                                                                                      child: const Column(
                                                                                        children: [
                                                                                          SizedBox(height: 3),
                                                                                          Text(
                                                                                            "View contact",
                                                                                            textAlign: TextAlign.center,
                                                                                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: chatColor),
                                                                                          ),
                                                                                        ],
                                                                                      ),
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
                      Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: SizedBox(
                            child: timestpa(data.messageRead.toString(),
                                data.createdAt!, data.isStarMessage!),
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
                  onTap: () async {
                    await getRoomController.getRoomModelApi(
                        conversationID: widget.conversationID,
                        callType: "audio_call");
                    print(
                        "ROOMID 2 ${Get.find<RoomIdController>().roomModel.value!.roomId}");
                    Get.to(() => AudioCallScreen(
                          roomID: Get.find<RoomIdController>()
                              .roomModel
                              .value!
                              .roomId,
                          conversation_id: widget.conversationID ?? "",
                          isCaller: true,
                          receiverImage: widget.userPic!,
                          receiverUserName: widget.username!,
                        ));
                  },
                  child: Image.asset(
                    "assets/images/call_1.png",
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
                  onTap: () async {
                    await getRoomController.getRoomModelApi(
                        conversationID: widget.conversationID,
                        callType: "video_call");
                    print(
                        "ROOMID 1 ${Get.find<RoomIdController>().roomModel.value!.roomId}");
                    Get.to(() => VideoCallScreen(
                          roomID: Get.find<RoomIdController>()
                              .roomModel
                              .value!
                              .roomId,
                          conversation_id: widget.conversationID ?? "",
                          isCaller: true,
                        ));
                  },
                  child: Image.asset(
                    "assets/images/video_1.png",
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
              chatID = [];
              chatMessageList = [];
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
                      chatMessageList = [];
                    });
                    chatContorller.isSendMsg.value = false;
                  } catch (e) {
                    setState(() {
                      isSelectedmessage = "0";
                      chatID = [];
                      chatMessageList = [];
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
              isKeyboard = false;
              showDialog(
                barrierColor: const Color.fromRGBO(30, 30, 30, 0.37),
                context: context,
                builder: (BuildContext context) {
                  return Stack(
                    children: [
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                        child: Container(
                          color: const Color.fromRGBO(30, 30, 30, 0.37),
                        ),
                      ),
                      AlertDialog(
                        insetPadding: const EdgeInsets.all(8),
                        alignment: Alignment.bottomCenter,
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                        content: SizedBox(
                          height: 150,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              Text(
                                chatListController.blockModel.value!.isBlock ==
                                        true
                                    ? "Are you sure you want to Unblock?"
                                    : "Are you sure you want to Block?",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 16),
                              ),
                              const SizedBox(height: 15),
                              Text(
                                chatListController.blockModel.value!.isBlock ==
                                        true
                                    ? "Are you sure you want to unblock profile of  @${widget.username}?"
                                    : "Are you sure you want to block profile of  @${widget.username}?",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: appgrey2,
                                    fontSize: 13),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      height: 40,
                                      width: MediaQuery.of(context).size.width *
                                          0.35,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: yellow2Color, width: 1),
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: const Center(
                                          child: Text(
                                        'Cancel',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
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
                                          0.35,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          gradient: LinearGradient(
                                              colors: [
                                                yellow1Color,
                                                yellow2Color
                                              ],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter)),
                                      child: Center(
                                          child: Text(
                                        chatListController.blockModel.value!
                                                    .isBlock ==
                                                true
                                            ? "Unblock"
                                            : 'Block',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: chatColor),
                                      )),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
              isKeyboard = false;
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
