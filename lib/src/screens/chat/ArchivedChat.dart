// ignore_for_file: curly_braces_in_flow_control_structures, avoid_print, prefer_if_null_operators, prefer_is_empty, unused_field, avoid_function_literals_in_foreach_calls, unused_local_variable, file_names
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:meyaoo_new/controller/online_controller.dart';
import 'package:meyaoo_new/controller/user_chatlist_controller.dart';
import 'package:meyaoo_new/model/common_widget.dart';
import 'package:meyaoo_new/model/userchatlist_model/archive_list_model.dart';
import 'package:meyaoo_new/src/global/global.dart';
import 'package:meyaoo_new/src/screens/chat/group_chat_temp.dart';
import 'package:meyaoo_new/src/screens/chat/single_chat.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';

class ArchiveChat extends StatefulWidget {
  const ArchiveChat({super.key});

  @override
  State<ArchiveChat> createState() => _ArchiveChatState();
}

class _ArchiveChatState extends State<ArchiveChat> with WidgetsBindingObserver {
  ChatListController chatListController = Get.put(ChatListController());
  TextEditingController controller = TextEditingController();
  OnlineOfflineController onlieController = Get.find();

  Future<void> requestPermissions() async {
    // Request notification permission
    await Permission.notification.request();

    // Request location permission
    await Permission.location.request();

    // Request camera permission
    await Permission.camera.request();

    // Request microphone permission
    await Permission.microphone.request();

    // Request storage permission
    await Permission.storage.request();

    // Request photo library permission
    await Permission.photos.request();

    await Permission.contacts.request();
  }

  @override
  void initState() {
    super.initState();
    requestPermissions();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      chatListController.forArchiveChatList();
    });
  }

  bool? isonline;

  Widget isUserOnline(String userID) {
    for (var i = 0; i < onlieController.allOffline.length; i++) {
      if (userID == onlieController.allOffline[i].userId.toString()) {
        return const SizedBox.shrink();
      }
    }
    return const SizedBox.shrink();
  }

  String isUserTyping(String cID) {
    for (var i = 0; i < onlieController.typingList.length; i++) {
      if (cID == onlieController.typingList[i].conversationId.toString()) {
        return "Typing...";
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: AppBar(
            shape: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            scrolledUnderElevation: 0,
            backgroundColor: appColorWhite,
            elevation: 0,
            titleSpacing: 0,
            leadingWidth: 50,
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black)),
            title: const Text(
              'Archive list',
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                  color: Colors.black),
            ),
          ),
        ),
        body: Container(
          color: Colors.white,
          child: Column(
            children: [
              const SizedBox(height: 10),
              searchBar(),
              Expanded(child: SingleChildScrollView(child: chatListScreen1()))
            ],
          ),
        ));
  }

//_________________________________________________________________________________________________________________________________________________________
  Widget chatListScreen1() {
    print(
        "LENGTH:${chatListController.userArchiveListModel.value!.archiveList!.length}");
    return Obx(() {
      return chatListController
                  .userArchiveListModel.value!.archiveList!.length >
              0
          ? _searchResult.length != 0 ||
                  controller.text.trim().toLowerCase().isNotEmpty
              ? ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _searchResult.length,
                  itemBuilder: (context, index) {
                    List chatlist = _searchResult;
                    return chatsWidget(chatlist[index], index);
                  },
                )
              : ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: chatListController
                      .userArchiveListModel.value!.archiveList!.length,
                  itemBuilder: (context, index) {
                    isOnline = chatListController.onlineUsers
                        .contains(chatListController
                            .userChatListModel.value!.chatList![index].userId
                            .toString())
                        .toString();
                    return chatsWidget(
                        chatListController
                            .userArchiveListModel.value!.archiveList![index],
                        index);
                  },
                )
          : Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 150),
                  Image.asset(
                    "assets/images/no_contact_found.png",
                    height: 250,
                  ),
                ],
              ),
            );
    });
  }

  Widget chatsWidget(ArchiveList data, index) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          InkWell(
            onLongPress: () {
              // data.isGroup == false
              //     ? dialogBox(data.isBlock.toString(), data.userId.toString())
              //     : null;
              dialogBox(data.isBlock.toString(), data.conversationId.toString(),
                  data.isGroup!, data.userName!, data.groupName!, data);
            },
            onTap: () {
              Navigator.push(
                context,
                PageTransition(
                    curve: Curves.linear,
                    type: PageTransitionType.rightToLeft,
                    child: data.isGroup == false
                        ? SingleChatMsg(
                            conversationID: data.conversationId.toString(),
                            username: data.userName,
                            userPic: data.profileImage,
                            index: 0,
                            isMsgHighLight: false,
                            isBlock: data.isBlock,
                            userID: data.userId.toString(),
                          )
                        //____________________navigate to group chat_________________________
                        : GroupChatMsg(
                            conversationID: data.conversationId.toString(),
                            gPusername: data.groupName,
                            gPPic: data.groupProfileImage,
                            index: 0,
                            isMsgHighLight: false,
                          )),
              ).then((value) {});
            },
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(),
                  height: 70,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(
                        width: 0,
                      ),
                      Stack(
                        children: [
                          Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              shape: BoxShape.circle,
                            ),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: data.profileImage != ""
                                    ? CustomCachedNetworkImage(
                                        imageUrl: data.profileImage.toString(),
                                        placeholderColor: chatownColor,
                                        errorWidgeticon: const Icon(
                                          Icons.person,
                                          size: 30,
                                        ))
                                    : CustomCachedNetworkImage(
                                        imageUrl:
                                            data.groupProfileImage.toString(),
                                        placeholderColor: chatownColor,
                                        errorWidgeticon: const Icon(
                                          Icons.groups,
                                          size: 30,
                                        ))),
                          ),
                          Positioned(
                              bottom: 5,
                              right: 0,
                              child: Obx(() {
                                return onlieController.allOnline
                                        .contains(data.userId.toString())
                                    ? Container(
                                        height: 10,
                                        width: 10,
                                        decoration: const BoxDecoration(
                                            color: Colors.green,
                                            shape: BoxShape.circle),
                                      )
                                    : isUserOnline(data.userId.toString());
                              }))
                        ],
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.75,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                data.userName.toString().isEmpty
                                    ? Text(
                                        capitalizeFirstLetter(
                                            '${data.groupName}'),
                                        textAlign: TextAlign.left,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15),
                                      )
                                    : Text(
                                        capitalizeFirstLetter(data.userName!),
                                        textAlign: TextAlign.left,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15),
                                      ),
                                Text(
                                  data.createdAt!.isEmpty
                                      ? ''
                                      : "${CommonWidget.convertDateForm(data.createdAt!)}",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey),
                                ),
                              ],
                            ),
                            onlieController.typingList.isNotEmpty
                                ? Obx(() {
                                    return Text(
                                      isUserTyping(
                                          data.conversationId.toString()),
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    );
                                  })
                                : data.lastMessageType == "text"
                                    ? Text(
                                        capitalizeFirstLetter(
                                            data.lastMessage!),
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      )
                                    : data.lastMessageType == "image"
                                        ? Row(
                                            children: [
                                              Image.asset(
                                                "assets/icons/image_icon.png",
                                                height: 15,
                                                color: Colors.grey,
                                              ),
                                              const Text(" Photo",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey))
                                            ],
                                          )
                                        : data.lastMessageType == "location"
                                            ? Row(
                                                children: [
                                                  Image.asset(
                                                    "assets/icons/location_icon.png",
                                                    height: 15,
                                                    color: Colors.grey,
                                                  ),
                                                  const Text(" Location",
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey))
                                                ],
                                              )
                                            : data.lastMessageType == "video"
                                                ? Row(
                                                    children: [
                                                      Image.asset(
                                                        "assets/icons/video_icon.png",
                                                        height: 15,
                                                        color: Colors.grey,
                                                      ),
                                                      const Text(" Video",
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors.grey))
                                                    ],
                                                  )
                                                : data.lastMessageType == "gif"
                                                    ? const Row(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .gif_box_outlined,
                                                            color: Colors.grey,
                                                          ),
                                                          Text(
                                                            "GIF",
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontSize: 13),
                                                          ),
                                                        ],
                                                      )
                                                    : data.lastMessageType ==
                                                            "link"
                                                        ? const Row(
                                                            children: [
                                                              Icon(
                                                                  CupertinoIcons
                                                                      .link,
                                                                  size: 15,
                                                                  color: Colors
                                                                      .grey),
                                                              Text(" Link",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .grey,
                                                                      fontSize:
                                                                          13))
                                                            ],
                                                          )
                                                        : data.lastMessageType ==
                                                                "audio"
                                                            ? Row(
                                                                children: [
                                                                  Image.asset(
                                                                      "assets/images/microphone-2.png",
                                                                      height:
                                                                          15,
                                                                      color: Colors
                                                                          .grey),
                                                                  const Text(
                                                                      " Voice message",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .grey,
                                                                          fontSize:
                                                                              13))
                                                                ],
                                                              )
                                                            : data.lastMessageType ==
                                                                    "contact"
                                                                ? Row(
                                                                    children: [
                                                                      Image.asset(
                                                                          'assets/icons/profile_outline.png',
                                                                          height:
                                                                              15,
                                                                          color:
                                                                              Colors.grey),
                                                                      const Text(
                                                                          " Contact",
                                                                          style: TextStyle(
                                                                              color: Colors.grey,
                                                                              fontSize: 13))
                                                                    ],
                                                                  )
                                                                : const SizedBox
                                                                    .shrink()
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     // group audio call outgoing
                            //     data.type == "call" &&
                            //             data.lastMessage == "call" &&
                            //             data.isgroup == "1" &&
                            //             data.callType == "1" &&
                            //             data.isComeing == "Outgoing"
                            //         ? Row(
                            //             children: [
                            //               const Image(
                            //                 image: AssetImage(
                            //                     'assets/images/call-outgoing.png'),
                            //                 height: 14,
                            //               ),
                            //               Text(
                            //                 "  ${capitalizeFirstLetter("end call at")} ",
                            //                 style:
                            //                     const TextStyle(fontSize: 13),
                            //               ),
                            //               Text(
                            //                 convertUTCTimeTo12HourFormat(
                            //                     data.lastMessageCreated!),
                            //                 style:
                            //                     const TextStyle(fontSize: 13),
                            //               )
                            //             ],
                            //           )
                            //         // group incoming audio call
                            //         : data.type == "call" &&
                            //                 data.lastMessage == "call" &&
                            //                 data.isgroup == "1" &&
                            //                 data.callType == "1" &&
                            //                 data.isComeing == "Incoming"
                            //             ? Row(
                            //                 children: [
                            //                   const Image(
                            //                     image: AssetImage(
                            //                         'assets/images/call-outgoing.png'),
                            //                     height: 14,
                            //                   ),
                            //                   Text(
                            //                     "  ${capitalizeFirstLetter("end call at")} ",
                            //                     style: const TextStyle(
                            //                         fontSize: 13),
                            //                   ),
                            //                   Text(
                            //                     convertUTCTimeTo12HourFormat(
                            //                         data.lastMessageCreated!),
                            //                     style: const TextStyle(
                            //                         fontSize: 13),
                            //                   )
                            //                 ],
                            //               )
                            //             // group video call outgoing
                            //             : data.type == "call" &&
                            //                     data.lastMessage == "call" &&
                            //                     data.isgroup == "1" &&
                            //                     data.callType == "0" &&
                            //                     data.isComeing == "Outgoing"
                            //                 ? Row(
                            //                     children: [
                            //                       const Image(
                            //                         image: AssetImage(
                            //                             'assets/images/videoo.png'),
                            //                         height: 14,
                            //                       ),
                            //                       Text(
                            //                         "  ${capitalizeFirstLetter("end call")} ",
                            //                         style: const TextStyle(
                            //                             fontSize: 13),
                            //                       ),
                            //                       Text(
                            //                         convertUTCTimeTo12HourFormat(
                            //                             data.lastMessageCreated!),
                            //                         style: const TextStyle(
                            //                             fontSize: 13),
                            //                       )
                            //                     ],
                            //                   )
                            //                 // group video call incoming
                            //                 : data.type == "call" &&
                            //                         data.lastMessage ==
                            //                             "call" &&
                            //                         data.isgroup == "1" &&
                            //                         data.callType == "0" &&
                            //                         data.isComeing == "Incoming"
                            //                     ? Row(
                            //                         children: [
                            //                           const Image(
                            //                             image: AssetImage(
                            //                                 'assets/images/videoo.png'),
                            //                             height: 14,
                            //                           ),
                            //                           Text(
                            //                             "  ${capitalizeFirstLetter("end call")} ",
                            //                             style: const TextStyle(
                            //                                 fontSize: 13),
                            //                           ),
                            //                           Text(
                            //                             convertUTCTimeTo12HourFormat(
                            //                                 data.lastMessageCreated!),
                            //                             style: const TextStyle(
                            //                                 fontSize: 13),
                            //                           )
                            //                         ],
                            //                       )
                            //                     //_______________________________________________________________________incoming audio call
                            //                     : data.type == "call" &&
                            //                             data.lastMessage!
                            //                                 .startsWith(
                            //                                     "end call at") &&
                            //                             data.callType == "1" &&
                            //                             data.isComeing ==
                            //                                 "Incoming"
                            //                         ? Row(
                            //                             children: [
                            //                               const Image(
                            //                                 image: AssetImage(
                            //                                     'assets/images/call-incoming.png'),
                            //                                 height: 14,
                            //                               ),
                            //                               Text(
                            //                                 "  ${capitalizeFirstLetter("End call at")} ",
                            //                                 style:
                            //                                     const TextStyle(
                            //                                         fontSize:
                            //                                             13),
                            //                               ),
                            //                               Text(
                            //                                 convertUTCTimeTo12HourFormat(
                            //                                     data.lastMessageCreated!),
                            //                                 style:
                            //                                     const TextStyle(
                            //                                         fontSize:
                            //                                             13),
                            //                               )
                            //                             ],
                            //                           )
                            //                         //__________________________________________________________________Outgoing audio call
                            //                         : data.type == "call" &&
                            //                                 data.lastMessage!
                            //                                     .startsWith(
                            //                                         "end call at") &&
                            //                                 data.callType ==
                            //                                     "1" &&
                            //                                 data.isComeing ==
                            //                                     "Outgoing"
                            //                             ? Row(
                            //                                 children: [
                            //                                   const Image(
                            //                                     image: AssetImage(
                            //                                         'assets/images/call-outgoing.png'),
                            //                                     height: 14,
                            //                                   ),
                            //                                   Text(
                            //                                     "  ${capitalizeFirstLetter("End call at")} ",
                            //                                     style:
                            //                                         const TextStyle(
                            //                                             fontSize:
                            //                                                 13),
                            //                                   ),
                            //                                   Text(
                            //                                     convertUTCTimeTo12HourFormat(
                            //                                         data.lastMessageCreated!),
                            //                                     style:
                            //                                         const TextStyle(
                            //                                             fontSize:
                            //                                                 13),
                            //                                   )
                            //                                 ],
                            //                               )
                            //                             //________________________________________________________________MISSELD CALL AUIDO INCOMING
                            //                             : data.type == "call" &&
                            //                                     data.lastMessage!
                            //                                         .startsWith(
                            //                                             "Missed call") &&
                            //                                     data.callType ==
                            //                                         "1" &&
                            //                                     data.isComeing ==
                            //                                         "Incoming"
                            //                                 ? Row(
                            //                                     children: [
                            //                                       const Image(
                            //                                         image: AssetImage(
                            //                                             'assets/images/NotRecive.png'),
                            //                                         height: 12,
                            //                                       ),
                            //                                       Text(
                            //                                           "  ${data.lastMessage!} "),
                            //                                       Text(
                            //                                         convertUTCTimeTo12HourFormat(
                            //                                             data.lastMessageCreated!),
                            //                                         style: const TextStyle(
                            //                                             fontSize:
                            //                                                 13),
                            //                                       )
                            //                                     ],
                            //                                   )
                            //                                 //______________________________________________________MISSED CALL AUDIO OUTGOING
                            //                                 : data.type == "call" &&
                            //                                         data.lastMessage!
                            //                                             .startsWith(
                            //                                                 "Missed call") &&
                            //                                         data.callType ==
                            //                                             "1" &&
                            //                                         data.isComeing ==
                            //                                             "Outgoing"
                            //                                     ? Row(
                            //                                         children: [
                            //                                           const Image(
                            //                                             image: AssetImage(
                            //                                                 'assets/images/NotRecive.png'),
                            //                                             height:
                            //                                                 12,
                            //                                           ),
                            //                                           Text(
                            //                                               "  ${data.lastMessage!} "),
                            //                                           Text(
                            //                                             convertUTCTimeTo12HourFormat(
                            //                                                 data.lastMessageCreated!),
                            //                                             style: const TextStyle(
                            //                                                 fontSize:
                            //                                                     13),
                            //                                           )
                            //                                         ],
                            //                                       )

                            //                                     //___________________________________________________MISSED VIDEO CALL OUTGOING__________________________
                            //                                     : data.type ==
                            //                                                 "call" &&
                            //                                             data.lastMessage!.startsWith(
                            //                                                 "Missed call") &&
                            //                                             data.callType ==
                            //                                                 "0" &&
                            //                                             data.isComeing ==
                            //                                                 "Outgoing"
                            //                                         ? Row(
                            //                                             children: [
                            //                                               Image
                            //                                                   .asset(
                            //                                                 'assets/images/videocall_missed.png',
                            //                                                 height:
                            //                                                     14,
                            //                                               ),
                            //                                               Text(
                            //                                                 "  ${capitalizeFirstLetter(data.lastMessage!)} ",
                            //                                                 style:
                            //                                                     const TextStyle(fontSize: 13),
                            //                                               ),
                            //                                               Text(
                            //                                                 convertUTCTimeTo12HourFormat(data.lastMessageCreated!),
                            //                                                 style:
                            //                                                     const TextStyle(fontSize: 13),
                            //                                               )
                            //                                             ],
                            //                                           )
                            //                                         //___________________________________________________MISSED VIDEO CALL INCOMING_____________________________
                            //                                         : data.type ==
                            //                                                     "call" &&
                            //                                                 data.lastMessage!.startsWith("Missed call") &&
                            //                                                 data.callType == "0" &&
                            //                                                 data.isComeing == "Incoming"
                            //                                             ? Row(
                            //                                                 children: [
                            //                                                   Image.asset(
                            //                                                     'assets/images/videocall_missed.png',
                            //                                                     height: 14,
                            //                                                   ),
                            //                                                   Text(
                            //                                                     "  ${capitalizeFirstLetter(data.lastMessage!)} ",
                            //                                                     style: const TextStyle(fontSize: 13),
                            //                                                   ),
                            //                                                   Text(
                            //                                                     convertUTCTimeTo12HourFormat(data.lastMessageCreated!),
                            //                                                     style: const TextStyle(fontSize: 13),
                            //                                                   )
                            //                                                 ],
                            //                                               )
                            //                                             //__________________________________________________VIDEO CALL INCOMING__________________________________
                            //                                             : data.type == "call" && data.lastMessage!.startsWith("end call at") && data.callType == "0" && data.isComeing == "Incoming"
                            //                                                 ? Row(
                            //                                                     children: [
                            //                                                       Image.asset(
                            //                                                         'assets/images/videoo.png',
                            //                                                         height: 14,
                            //                                                       ),
                            //                                                       Text(
                            //                                                         "  ${capitalizeFirstLetter("end call at")} ",
                            //                                                         style: const TextStyle(fontSize: 13),
                            //                                                       ),
                            //                                                       Text(
                            //                                                         convertUTCTimeTo12HourFormat(data.lastMessageCreated!),
                            //                                                         style: const TextStyle(fontSize: 13),
                            //                                                       )
                            //                                                     ],
                            //                                                   )
                            //                                                 //____________________________________________ VIDEO CALL OUTGOING _____________________________________
                            //                                                 : data.type == "call" && data.lastMessage!.startsWith("end call at") && data.callType == "0" && data.isComeing == "Outgoing"
                            //                                                     ? Row(
                            //                                                         children: [
                            //                                                           Image.asset(
                            //                                                             'assets/images/videoo.png',
                            //                                                             height: 14,
                            //                                                           ),
                            //                                                           Text(
                            //                                                             "  ${capitalizeFirstLetter("end call at")} ",
                            //                                                             style: const TextStyle(fontSize: 13),
                            //                                                           ),
                            //                                                           Text(
                            //                                                             convertUTCTimeTo12HourFormat(data.lastMessageCreated!),
                            //                                                             style: const TextStyle(fontSize: 13),
                            //                                                           )
                            //                                                         ],
                            //                                                       )
                            //                                                     //______________________________________________________________________ TEXT___________________________
                            //                                                     : data.type == "text"
                            //                                                         ? SizedBox(
                            //                                                             width: 200,
                            //                                                             child: Text(
                            //                                                               data.lastMessage!,
                            //                                                               maxLines: 1,
                            //                                                               overflow: TextOverflow.ellipsis,
                            //                                                             ),
                            //                                                           )
                            //                                                         //________________________________________________LINK______________________________
                            //                                                         : data.type == "link"
                            //                                                             ? const Row(
                            //                                                                 children: [
                            //                                                                   Icon(CupertinoIcons.link, size: 15, color: chatColor),
                            //                                                                   Text(" Link")
                            //                                                                 ],
                            //                                                               )
                            //                                                             //_____________________________________ IMAGE __________________________________________________
                            //                                                             : data.type == "image"
                            //                                                                 ? Row(
                            //                                                                     children: [
                            //                                                                       Image.asset(
                            //                                                                         "assets/icons/image_icon.png",
                            //                                                                         height: 15,
                            //                                                                         color: chatColor,
                            //                                                                       ),
                            //                                                                       const Text(" Photo")
                            //                                                                     ],
                            //                                                                   )
                            //                                                                 //_________________________________VIDEO ____________________________________________
                            //                                                                 : data.type == "video"
                            //                                                                     ? Row(
                            //                                                                         children: [
                            //                                                                           Image.asset(
                            //                                                                             "assets/icons/video_icon.png",
                            //                                                                             height: 15,
                            //                                                                             color: chatColor,
                            //                                                                           ),
                            //                                                                           const Text(" Video")
                            //                                                                         ],
                            //                                                                       )
                            //                                                                     //_______________________________DOC ______________________________________________________
                            //                                                                     : data.type == "doc"
                            //                                                                         ? Row(
                            //                                                                             children: [
                            //                                                                               Image.asset(
                            //                                                                                 "assets/icons/file_icon.png",
                            //                                                                                 height: 15,
                            //                                                                                 color: chatColor,
                            //                                                                               ),
                            //                                                                               const Text(" Document")
                            //                                                                             ],
                            //                                                                           )
                            //                                                                         //______________________________ LOCATION ____________________________________________________
                            //                                                                         : data.type == "location"
                            //                                                                             ? Row(
                            //                                                                                 children: [
                            //                                                                                   Image.asset(
                            //                                                                                     "assets/icons/location_icon.png",
                            //                                                                                     height: 15,
                            //                                                                                     color: chatColor,
                            //                                                                                   ),
                            //                                                                                   const Text(" Location")
                            //                                                                                 ],
                            //                                                                               )
                            //                                                                             //______________________________ GIF ____________________________________________________
                            //                                                                             : data.type == "gif"
                            //                                                                                 ? Row(
                            //                                                                                     children: [
                            //                                                                                       Image.asset("assets/images/gif-file.png", height: 22),
                            //                                                                                       const Text(
                            //                                                                                         "GIF",
                            //                                                                                         maxLines: 1,
                            //                                                                                         overflow: TextOverflow.ellipsis,
                            //                                                                                         style: TextStyle(color: chatColor, fontSize: 13),
                            //                                                                                       ),
                            //                                                                                     ],
                            //                                                                                   )
                            //                                                                                 : data.type == "voicemessage"
                            //                                                                                     ? Row(
                            //                                                                                         children: [
                            //                                                                                           Image.asset("assets/images/microphone-2.png", height: 15, color: chatColor),
                            //                                                                                           const Text(" Voice message")
                            //                                                                                         ],
                            //                                                                                       )
                            //                                                                                     //_________________________________________________________________ REPLY TYPE ___________________
                            //                                                                                     : data.type == "reply" && data.replyType == "reply@text"
                            //                                                                                         ? SizedBox(
                            //                                                                                             width: 200,
                            //                                                                                             child: Text(
                            //                                                                                               data.lastMessage!,
                            //                                                                                               maxLines: 1,
                            //                                                                                               overflow: TextOverflow.ellipsis,
                            //                                                                                             ),
                            //                                                                                           )
                            //                                                                                         : data.type == "reply" && data.replyType == "reply@link"
                            //                                                                                             ? const Row(
                            //                                                                                                 children: [
                            //                                                                                                   Icon(CupertinoIcons.link, size: 15, color: gradient1),
                            //                                                                                                   Text(" Link")
                            //                                                                                                 ],
                            //                                                                                               )
                            //                                                                                             : data.type == "reply" && data.replyType == "reply@image"
                            //                                                                                                 ? Row(
                            //                                                                                                     children: [
                            //                                                                                                       Image.asset(
                            //                                                                                                         "assets/icons/image_icon.png",
                            //                                                                                                         height: 15,
                            //                                                                                                         color: chatColor,
                            //                                                                                                       ),
                            //                                                                                                       const Text(" Photo")
                            //                                                                                                     ],
                            //                                                                                                   )
                            //                                                                                                 : data.type == "reply" && data.replyType == "reply@video"
                            //                                                                                                     ? Row(
                            //                                                                                                         children: [
                            //                                                                                                           Image.asset(
                            //                                                                                                             "assets/icons/video_icon.png",
                            //                                                                                                             height: 15,
                            //                                                                                                             color: chatColor,
                            //                                                                                                           ),
                            //                                                                                                           const Text(" Video")
                            //                                                                                                         ],
                            //                                                                                                       )
                            //                                                                                                     : data.type == "reply" && data.replyType == "reply@doc"
                            //                                                                                                         ? Row(
                            //                                                                                                             children: [
                            //                                                                                                               Image.asset(
                            //                                                                                                                 "assets/icons/file_icon.png",
                            //                                                                                                                 height: 15,
                            //                                                                                                                 color: chatColor,
                            //                                                                                                               ),
                            //                                                                                                               const Text(" Document")
                            //                                                                                                             ],
                            //                                                                                                           )
                            //                                                                                                         : data.type == "reply" && data.replyType == "reply@location"
                            //                                                                                                             ? Row(
                            //                                                                                                                 children: [
                            //                                                                                                                   Image.asset(
                            //                                                                                                                     "assets/icons/location_icon.png",
                            //                                                                                                                     height: 15,
                            //                                                                                                                     color: chatColor,
                            //                                                                                                                   ),
                            //                                                                                                                   const Text(" Location")
                            //                                                                                                                 ],
                            //                                                                                                               )
                            //                                                                                                             : data.type == "reply" && data.replyType == "reply@gif"
                            //                                                                                                                 ? Row(
                            //                                                                                                                     children: [
                            //                                                                                                                       Image.asset("assets/images/gif-file.png", height: 22),
                            //                                                                                                                       const Text(
                            //                                                                                                                         "GIF",
                            //                                                                                                                         maxLines: 1,
                            //                                                                                                                         overflow: TextOverflow.ellipsis,
                            //                                                                                                                         style: TextStyle(color: chatColor, fontSize: 13),
                            //                                                                                                                       ),
                            //                                                                                                                     ],
                            //                                                                                                                   )
                            //                                                                                                                 : data.type == "reply" && data.replyType == "reply@audio"
                            //                                                                                                                     ? Row(
                            //                                                                                                                         children: [
                            //                                                                                                                           Image.asset("assets/images/microphone-2.png", height: 15, color: chatColor),
                            //                                                                                                                           const Text(" Voice message")
                            //                                                                                                                         ],
                            //                                                                                                                       )
                            //                                                                                                                     : Text(
                            //                                                                                                                         data.lastMessage == null || data.lastMessage == "" ? "" : capitalizeFirstLetter(data.lastMessage!),
                            //                                                                                                                         maxLines: 2,
                            //                                                                                                                         textAlign: TextAlign.left,
                            //                                                                                                                         style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
                            //                                                                                                                       ),
                            //     data.personalCount != "0"
                            //         ? Container(
                            //             height: 20,
                            //             width: 20,
                            //             decoration: const BoxDecoration(
                            //               shape: BoxShape.circle,
                            //               color: chatownColor,
                            //             ),
                            //             child: Center(
                            //               child: Text(
                            //                 (int.parse(data.personalCount!) >=
                            //                         99)
                            //                     ? '99+'
                            //                     : data.personalCount!,
                            //                 style: const TextStyle(
                            //                   fontSize: 10,
                            //                 ),
                            //               ),
                            //             ),
                            //           )
                            //         : const SizedBox.shrink()
                            //   ],
                            // )
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (index !=
                  chatListController
                          .userArchiveListModel.value!.archiveList!.length -
                      1 &&
              index != _searchResult.length - 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                color: Colors.grey.shade300,
              ),
            )
        ],
      ),
    );
  }

  String convertUTCTimeTo12HourFormat(String utcTimeString) {
    DateTime utcDate = DateTime.parse(utcTimeString);
    String formattedTime = DateFormat('h:mm a').format(utcDate.toLocal());
    return formattedTime;
  }

  Widget searchBar() {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: Colors.grey.shade100),
      child: TextField(
        controller: controller,
        onChanged: onSearchTextChanged,
        decoration: const InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.all(17),
            child: Image(
              image: AssetImage('assets/icons/search.png'),
            ),
          ),
          hintText: 'Search User',
          hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(borderSide: BorderSide.none),
        ),
      ),
    );
  }

//_________________________________________________________________________________________________________________________________________________________

  Future dialogBox(String isblock, String cID, bool isGroup, String uname,
      String gpname, ArchiveList data) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
            ),
            content: SizedBox(
              height: isGroup == false ? 87 : 50,
              child: Column(
                children: [
                  SizedBox(
                    height: 40,
                    child: ListTile(
                      leading: const Text(
                        'Unarchive',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.archive_outlined,
                        size: 19,
                        color: Colors.black,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        isGroup == false
                            ? chatListController.addArchveApi(cID, uname)
                            : chatListController.addArchveApi(cID, gpname);
                        chatListController
                            .userArchiveListModel.value!.archiveList!
                            .remove(data);
                      },
                    ),
                  ),
                  isGroup == false
                      ? const SizedBox(height: 5)
                      : const SizedBox.shrink(),
                  isGroup == false
                      ? Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey[200],
                        )
                      : const SizedBox.shrink(),
                  isGroup == false
                      ? SizedBox(
                          height: 40,
                          child: ListTile(
                            leading: Text(
                              isblock == "false" ? 'Block' : "Unblock",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.block,
                              size: 19,
                              color: Colors.black,
                            ),
                            onTap: () {
                              setState(() {});
                              Navigator.pop(context);
                              chatListController.blockUserApi(cID);
                            },
                          ),
                        )
                      : const SizedBox.shrink()
                ],
              ),
            ),
          );
        });
  }

// This function search chats user/group name
  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    chatListController.userArchiveListModel.value!.archiveList!
        .forEach((userDetail) {
      if (userDetail.userName != null) if (userDetail.userName!
          .toLowerCase()
          .contains(text.toLowerCase())) _searchResult.add(userDetail);
    });

    chatListController.userArchiveListModel.value!.archiveList!
        .forEach((userDetail) {
      if (userDetail.groupName != null) if (userDetail.groupName!
          .toLowerCase()
          .contains(text.toLowerCase())) _searchResult.add(userDetail);
    });

    setState(() {});
  }
}

List _searchResult = [];
