// // ignore_for_file: avoid_print, must_be_immutable, use_full_hex_values_for_flutter_colors, file_names, use_build_context_synchronously

// ignore_for_file: avoid_print, must_be_immutable, use_build_context_synchronously, non_constant_identifier_names, file_names, use_full_hex_values_for_flutter_colors, unused_field
import 'dart:developer';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:meyaoo_new/controller/all_star_msg_controller.dart';
import 'package:meyaoo_new/controller/single_chat_media_controller.dart';
import 'package:meyaoo_new/controller/user_chatlist_controller.dart';
import 'package:meyaoo_new/model/chat_profile_model.dart';
import 'package:meyaoo_new/src/global/global.dart';
import 'package:meyaoo_new/src/global/strings.dart';
import 'package:meyaoo_new/src/screens/chat/Media.dart';
import 'package:meyaoo_new/src/screens/chat/allstarred_msg_list.dart';
import 'package:meyaoo_new/src/screens/chat/chatvideo.dart';
import 'package:meyaoo_new/src/screens/chat/group_memberlist.dart';
import 'package:meyaoo_new/src/screens/chat/group_profile_update.dart';
import 'package:meyaoo_new/src/screens/chat/imageView.dart';
import 'package:meyaoo_new/src/screens/chat/single_chat.dart';
import 'package:page_transition/page_transition.dart';

class GroupProfile extends StatefulWidget {
  String conversationID;
  GroupProfile({super.key, required this.conversationID});

  @override
  State<GroupProfile> createState() => _GroupProfileState();
}

class _GroupProfileState extends State<GroupProfile> {
  ChatListController chatListController = Get.put(ChatListController());
  ChatProfileController chatProfileController =
      Get.put(ChatProfileController());
  AllStaredMsgController allStaredMsgController = Get.find();
  bool isLoading = false;
  bool isParticipantsOpen = true;

  @override
  void initState() {
    // log("groupid" + widget.groupid.toString());
    print("GROUP_ID: ${widget.conversationID}");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      chatProfileController
          .getProfileDATA(widget.conversationID)
          .whenComplete(() {
        getAdmin();
      });
      allStaredMsgController.getAllStarMsg(widget.conversationID);
    });
    super.initState();
  }

  bool isIamAdmin = false;
  getAdmin() {
    for (int i = 0;
        i <
            chatProfileController.profileModel.value!.conversationDetails!
                .conversationsUsers!.length;
        i++) {
      if (Hive.box(userdata).get(userId) ==
          chatProfileController.profileModel.value!.conversationDetails!
              .conversationsUsers![i].user!.userId) {
        if (chatProfileController.profileModel.value!.conversationDetails!
                .conversationsUsers![i].isAdmin ==
            false) {
          setState(() {
            isIamAdmin = false;
          });
        } else {
          setState(() {
            isIamAdmin = true;
          });
        }

        print("MYADMIN$isIamAdmin");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color.fromRGBO(250, 250, 250, 1),
      bottomNavigationBar: isIamAdmin == true
          ? BottomAppBar(
              elevation: 0,
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Addparticipants(),
                    ),
                  ),
                ],
              ),
            )
          : null,
      body: Obx(() {
        return chatProfileController.isLoading.value
            ? loader(context)
            : SingleChildScrollView(
                child: Stack(
                  children: [
                    SizedBox(
                      height: Get.height * 0.27,
                      width: double.infinity,
                      child: Image.asset(
                        cacheHeight: 140,
                        "assets/images/back_img1.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                    Column(
                      children: [
                        SizedBox(height: Get.height * 0.13),
                        profilePic(chatProfileController
                            .profileModel.value!.conversationDetails!),
                        const SizedBox(height: 10),
                        groupprofiledetails(chatProfileController
                            .profileModel.value!.conversationDetails!),
                      ],
                    ),
                    Positioned(
                        top: 40,
                        left: 5,
                        child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                              // Get.find<SingleChatContorller>()
                              //     .userdetailschattModel
                              //     .value
                              //     ?.messageList
                              //     ?.clear();
                              // Get.find<SingleChatContorller>()
                              //     .getdetailschat(widget.conversationID);
                            },
                            icon: const Icon(Icons.arrow_back_ios, size: 19))),
                    Positioned(
                        top: 40,
                        right: 5,
                        child: Obx(() {
                          return chatProfileController.isLoading.value
                              ? const Icon(
                                  Icons.more_vert,
                                  color: chatColor,
                                  size: 24,
                                ).paddingOnly(right: 5)
                              : _popMenu(
                                  context,
                                  chatProfileController.profileModel.value!
                                      .conversationDetails!);
                        }))
                  ],
                ),
              );
      }),
    );
  }

  Widget Addparticipants() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  GetMembersinGroup(grpId: widget.conversationID),
            ));
      },
      child: Container(
        height: 47,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            // border: Border.all(color:  Colors.black, width: 1),
            borderRadius: BorderRadius.circular(5),
            gradient: LinearGradient(
                colors: [yellow1Color, yellow2Color],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter)),
        child: const Center(
          child: Text(
            'Add Participants',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget groupprofiledetails(ConversationDetails data) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          height: 25,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buttonContainer(
                onTap: () {}, img: "assets/images/call_1.png", title: "Audio"),
            const SizedBox(
              width: 30,
            ),
            buttonContainer(
                onTap: () {}, img: "assets/images/video_1.png", title: "Video"),
            const SizedBox(
              width: 30,
            ),
            buttonContainer(
                onTap: () {
                  Get.back(result: "1");
                },
                img: "assets/icons/search-normal.png",
                title: "Search")
          ],
        ),
        const SizedBox(
          height: 15,
        ),
        mediaContainer(),
        const SizedBox(
          height: 10,
        ),
        stareContainer(),
        const SizedBox(
          height: 10,
        ),
        memberListWidget()
      ],
    );
  }

  Widget profilePic(ConversationDetails data) {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: CustomCachedNetworkImage(
                imageUrl: data.groupProfileImage!,
                errorWidgeticon: const Icon(Icons.groups, size: 50),
              ),
            ),
          ),
        ),
        const SizedBox(height: 25),
        Text(
          capitalizeFirstLetter(data.groupName!),
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ).paddingSymmetric(horizontal: 15)
      ],
    );
  }

  bool isBlockUser(String conversationID) {
    for (var i = 0;
        i < chatListController.userChatListModel.value!.chatList!.length;
        i++) {
      if (chatListController.userChatListModel.value!.chatList![i].isGroup ==
          false) {
        if (conversationID ==
            chatListController
                .userChatListModel.value!.chatList![i].conversationId
                .toString()) {
          return chatListController
              .userChatListModel.value!.chatList![i].isBlock!;
        }
      }
    }
    return false;
  }

  Future<void> showAnimatedDialog(ConversationsUsers data) {
    return showModalBottomSheet(
      backgroundColor: Colors.white,
      elevation: 0,
      context: context,
      builder: (context) {
        return SizedBox(
          height: 250, // Set height to 200 pixels
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SingleChatMsg(
                                conversationID:
                                    data.conversationsUserId.toString(),
                                username: data.user!.userName,
                                userPic: data.user!.profileImage,
                                index: 0,
                                searchText: "",
                                searchTime: "",
                                mobileNum: "",
                                isMsgHighLight: false,
                                isBlock: isBlockUser(
                                    data.conversationsUserId.toString()),
                                userID: data.user!.userId.toString(),
                              )),
                    ).then((value) {
                      Navigator.pop(context);
                    });
                  },
                  child: const Text(
                    'View Profile',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.black),
                  ),
                ),
                const SizedBox(height: 30),
                data.isAdmin == true
                    ? InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          chatProfileController.makeAdminApi(
                              widget.conversationID,
                              data.user!.userId.toString(),
                              true.toString());
                          setState(() {
                            getAdmin();
                          });
                        },
                        child: const Text(
                          'Dismiss As Admin',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Colors.black),
                        ),
                      )
                    : InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          chatProfileController.makeAdminApi(
                              widget.conversationID,
                              data.user!.userId.toString(),
                              "");
                          setState(() {
                            getAdmin();
                          });
                        },
                        child: const Text(
                          'Make Group Admin',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Colors.black),
                        ),
                      ),
                const SizedBox(height: 30),
                InkWell(
                  onTap: () {
                    showDialog(
                      barrierColor: const Color.fromRGBO(30, 30, 30, 0.37),
                      context: context,
                      builder: (BuildContext context) {
                        return BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                          child: AlertDialog(
                            insetPadding: const EdgeInsets.all(8),
                            alignment: Alignment.bottomCenter,
                            backgroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            content: SizedBox(
                              width: Get.width,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 10),
                                  const Text(
                                    "Are you sure you want to Remove?",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16),
                                  ),
                                  const SizedBox(height: 15),
                                  Text(
                                    "Are you sure you want to remove ${data.user!.userName} from this group?",
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
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          height: 40,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.35,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: yellow2Color,
                                                  width: 1),
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
                                        onTap: () async {
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                          chatProfileController.removeAdminApi(
                                              widget.conversationID,
                                              data.user!.userId.toString());
                                          chatProfileController.users
                                              .remove(data);
                                        },
                                        child: Container(
                                          height: 40,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
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
                                          child: const Center(
                                              child: Text(
                                            'Remove',
                                            style: TextStyle(
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
                        );
                      },
                    );
                  },
                  child: const Text(
                    'Remove from group',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.red),
                  ),
                ),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 45,
                    width: 45,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: appgrey,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(
                            0.0,
                            0.0,
                          ),
                          blurRadius: 1.0,
                          spreadRadius: 0.0,
                        ), //BoxShadow
                        BoxShadow(
                          color: Colors.white,
                          offset: Offset(0.0, 0.0),
                          blurRadius: 0.0,
                          spreadRadius: 0.0,
                        ), //BoxShadow
                      ],
                    ),
                    child: const Center(
                        child: Icon(
                      Icons.close,
                      size: 15,
                      color: Colors.black,
                    )),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget chatcard(ConversationsUsers data, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
      child: InkWell(
        onTap: () {
          if (data.user!.userId != Hive.box(userdata).get(userId) &&
              isIamAdmin == true) {
            showAnimatedDialog(data);
          } else {
            null;
          }
        },
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Stack(children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: CustomCachedNetworkImage(
                              imageUrl: data.user!.profileImage.toString(),
                              errorWidgeticon: const Icon(
                                CupertinoIcons.person_fill,
                                size: 30,
                              ))),
                      // Positioned(
                      //   bottom: 1,
                      //   right: -10,
                      //   child: Padding(
                      //     padding: const EdgeInsets.only(right: 10),
                      //     child: Column(
                      //       mainAxisAlignment: MainAxisAlignment.center,
                      //       children: [
                      //         data.isAdmin == true
                      //             ? Container(
                      //                 height: 12,
                      //                 width: 12,
                      //                 decoration: BoxDecoration(
                      //                     borderRadius:
                      //                         BorderRadius.circular(12),
                      //                     color: Colors.green),
                      //               )
                      //             : Container(
                      //                 height: 12,
                      //                 width: 12,
                      //                 decoration: BoxDecoration(
                      //                     borderRadius:
                      //                         BorderRadius.circular(12),
                      //                     color: Colors.grey),
                      //               ),
                      //       ],
                      //     ),
                      //   ),
                      // )
                    ]),
                    const SizedBox(
                      width: 15,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                            Hive.box(userdata).get(userId).toString() ==
                                    data.user!.userId.toString()
                                ? "You"
                                : capitalizeFirstLetter(data.user!.userName!),
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Colors.black,
                            )),
                        const SizedBox(
                          height: 5,
                        ),
                        SizedBox(
                          width: 155,
                          height: 30,
                          child: Text(
                            data.user!.bio!,
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 10,
                                color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                data.isAdmin == true
                    ? const Padding(
                        padding: EdgeInsets.only(right: 10, top: 7),
                        child: Text(
                          "Admin",
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: 10,
                              fontWeight: FontWeight.w500),
                        ),
                      )
                    : const SizedBox()
              ],
            ),
            // if (index != data.conversationsUsers![index] - 1)
            //   Divider(
            //     color: Colors.grey.shade300,
            //     height: 2,
            //   )
          ],
        ),
      ),
    );
  }

  Widget participants() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Column(
        children: [
          const SizedBox(
            height: 5,
          ),
          ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            physics: const NeverScrollableScrollPhysics(),
            primary: false,
            padding: EdgeInsets.zero,
            itemCount: chatProfileController.users.length,
            itemBuilder: (BuildContext context, int index) {
              return chatcard(chatProfileController.users[index], index);
            },
          ),
        ],
      ),
    );
  }

  Widget _popMenu(BuildContext context, ConversationDetails data) {
    return PopupMenuButton(
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
                barrierColor: const Color.fromRGBO(30, 30, 30, 0.37),
                context: context,
                builder: (BuildContext context) {
                  return BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                    child: AlertDialog(
                      insetPadding: const EdgeInsets.all(8),
                      alignment: Alignment.bottomCenter,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                      ),
                      content: SizedBox(
                        width: Get.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 10),
                            const Text(
                              "Are you sure you want to Remove?",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              "Are you exit from ${data.groupName!} group?",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: appgrey2,
                                  fontSize: 13),
                            ),
                            const SizedBox(height: 20),
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
                                  onTap: () async {
                                    chatProfileController.exitGroupApi(
                                        cID: widget.conversationID);
                                  },
                                  child: Container(
                                    height: 40,
                                    width: MediaQuery.of(context).size.width *
                                        0.35,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        gradient: LinearGradient(
                                            colors: [
                                              yellow1Color,
                                              yellow2Color
                                            ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter)),
                                    child: const Center(
                                        child: Text(
                                      'Exit',
                                      style: TextStyle(
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
                  );
                },
              );
              // showDialog(
              //   context: context,
              //   builder: (BuildContext context) {
              //     return Container(
              //       decoration:
              //           BoxDecoration(color: Colors.white.withOpacity(0.4)),
              //       child: AlertDialog(
              //         backgroundColor: Colors.white,
              //         shape: const RoundedRectangleBorder(
              //           borderRadius: BorderRadius.all(
              //             Radius.circular(20),
              //           ),
              //         ),
              //         content: SizedBox(
              //           width: MediaQuery.of(context).size.width * 0.90,
              //           height: 200,
              //           child: Column(
              //             children: [
              //               const SizedBox(height: 5),
              //               const Text(
              //                 "Group exit",
              //                 style: TextStyle(
              //                     color: chatColor,
              //                     fontWeight: FontWeight.w500,
              //                     fontSize: 22),
              //               ),
              //               const SizedBox(
              //                 height: 30,
              //               ),
              //               Text(
              //                 "Are you exit from ${data.groupName!} group?",
              //                 textAlign: TextAlign.center,
              //                 style: const TextStyle(
              //                     fontWeight: FontWeight.w500,
              //                     color: appgrey2,
              //                     fontSize: 13),
              //               ),
              //               const SizedBox(height: 30),
              //               Row(
              //                 mainAxisAlignment: MainAxisAlignment.spaceAround,
              //                 children: [
              //                   InkWell(
              //                     onTap: () {
              //                       Navigator.pop(context);
              //                     },
              //                     child: Container(
              //                       height: 40,
              //                       width: MediaQuery.of(context).size.width *
              //                           0.30,
              //                       decoration: BoxDecoration(
              //                           border: Border.all(
              //                               color: chatColor, width: 1),
              //                           borderRadius:
              //                               BorderRadius.circular(20)),
              //                       child: const Center(
              //                           child: Text(
              //                         'Cancel',
              //                         style: TextStyle(
              //                             fontSize: 15,
              //                             fontWeight: FontWeight.w500,
              //                             color: chatColor),
              //                       )),
              //                     ),
              //                   ),
              //                   const SizedBox(
              //                     width: 10,
              //                   ),
              //                   InkWell(
              //                     onTap: () {
              //                       chatProfileController.exitGroupApi(
              //                           cID: widget.conversationID);
              //                     },
              //                     child: Container(
              //                       height: 40,
              //                       width: MediaQuery.of(context).size.width *
              //                           0.30,
              //                       decoration: BoxDecoration(
              //                           borderRadius: BorderRadius.circular(20),
              //                           color: chatColor),
              //                       child: const Center(
              //                           child: Text(
              //                         'Exit',
              //                         style: TextStyle(
              //                             fontSize: 15,
              //                             fontWeight: FontWeight.w500,
              //                             color: Colors.white),
              //                       )),
              //                     ),
              //                   ),
              //                 ],
              //               ),
              //             ],
              //           ),
              //         ),
              //       ),
              //     );
              //   },
              // );
            },
            child: const Text("Group exit")),
        PopupMenuItem(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => group_profile(
                        dp: chatProfileController.profileModel.value!
                            .conversationDetails!.groupProfileImage!,
                        groupid: widget.conversationID,
                        name: chatProfileController.profileModel.value!
                            .conversationDetails!.groupName!),
                  )).then((value) {
                chatProfileController
                    .getProfileDATAUpdate(widget.conversationID);
              });
            },
            child: const Text('Group edit')),
      ],
    );
  }

  Widget mediaContainer() {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
          blurRadius: 0.5,
          spreadRadius: 0,
          offset: Offset(0, 0.4),
          color: Color.fromRGBO(239, 239, 239, 1),
        )
      ]),
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Media(
                      peeid: widget.conversationID,
                      peername: chatProfileController.profileModel.value!
                          .conversationDetails!.groupName!)));
        },
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Media, links and docs",
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey),
                ),
                Row(
                  children: [
                    Text(
                      chatProfileController.totalCount.toString(),
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: appgrey2,
                    ),
                  ],
                )
              ],
            ).paddingSymmetric(horizontal: 20, vertical: 10),
            SizedBox(
              height: 100,
              child: chatProfileController
                      .profileModel.value!.mediaData!.isEmpty
                  ? const Center(
                      child: Text(
                        "You haven't share any media",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : Align(
                      alignment: Alignment.centerLeft,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemCount: chatProfileController
                              .profileModel.value!.mediaData!.length
                              .clamp(0, 4),
                          padding: const EdgeInsets.only(left: 20),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return chatProfileController
                                    .profileModel.value!.mediaData![index].url
                                    .toString()
                                    .contains(".mp4")
                                ? InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => VideoViewFix(
                                              username:
                                                  "${capitalizeFirstLetter("")} ${capitalizeFirstLetter("")}",
                                              url: chatProfileController
                                                  .profileModel
                                                  .value!
                                                  .mediaData![index]
                                                  .url!,
                                              play: true,
                                              mute: false,
                                              date: "",

                                              ///convertUTCTimeTo12HourFormat(data.createdAt!),
                                            ),
                                          ));
                                    },
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          height: 100,
                                          width: 100,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                          ),
                                          child: ClipRRect(
                                            child: CachedNetworkImage(
                                              imageUrl: chatProfileController
                                                  .profileModel
                                                  .value!
                                                  .mediaData![index]
                                                  .thumbnail!,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                            top: 40,
                                            child: Image.asset(
                                                "assets/images/play1.png",
                                                height: 22,
                                                color: chatColor))
                                      ],
                                    ),
                                  ).paddingOnly(right: 10)
                                : InkWell(
                                    onTap: () {
                                      log(chatProfileController.profileModel
                                          .value!.mediaData![index].url!);
                                      Navigator.push(
                                        context,
                                        PageTransition(
                                            curve: Curves.linear,
                                            type:
                                                PageTransitionType.rightToLeft,
                                            child: ImageView(
                                              image: chatProfileController
                                                  .profileModel
                                                  .value!
                                                  .mediaData![index]
                                                  .url!,
                                              userimg: "",
                                            )),
                                      );
                                    },
                                    child: Container(
                                        height: 100,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                        ),
                                        child: ClipRRect(
                                          child: CachedNetworkImage(
                                            imageUrl: chatProfileController
                                                .profileModel
                                                .value!
                                                .mediaData![index]
                                                .url!,
                                            fit: BoxFit.cover,
                                          ),
                                        )),
                                  ).paddingOnly(right: 10);
                          }),
                    ),
            ),
            const SizedBox(height: 10)
          ],
        ),
      ),
    );
  }

  Widget stareContainer() {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
          blurRadius: 0.5,
          spreadRadius: 0,
          offset: Offset(0, 0.4),
          color: Color.fromRGBO(239, 239, 239, 1),
        )
      ]),
      child: InkWell(
        onTap: () {
          Get.to(
              () => AllStarredMsgList(
                  conversationid: widget.conversationID, isPersonal: true),
              transition: Transition.rightToLeft);
        },
        child: Padding(
          padding:
              const EdgeInsets.only(left: 25, top: 10, right: 25, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset("assets/icons/star2.png", color: chatColor),
                  const SizedBox(
                    width: 10,
                  ),
                  const Text(
                    'Started Messages',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
              Row(
                children: [
                  Obx(() {
                    return Text(
                      allStaredMsgController.allStarred.isEmpty
                          ? "0"
                          : allStaredMsgController.allStarred.length.toString(),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                      ),
                    );
                  }),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 15,
                    color: appgrey2,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget memberListWidget() {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
          blurRadius: 0.5,
          spreadRadius: 0,
          offset: Offset(0, 0.4),
          color: Color.fromRGBO(239, 239, 239, 1),
        )
      ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${chatProfileController.profileModel.value!.conversationDetails!.conversationsUsers!.length.toString()} Group Members",
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
          ).paddingOnly(left: 23, top: 10),
          participants()
        ],
      ),
    );
  }
}
