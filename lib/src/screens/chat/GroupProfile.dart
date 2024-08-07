// // ignore_for_file: avoid_print, must_be_immutable, use_full_hex_values_for_flutter_colors, file_names, use_build_context_synchronously

// ignore_for_file: avoid_print, must_be_immutable, use_build_context_synchronously, non_constant_identifier_names, file_names, use_full_hex_values_for_flutter_colors, unused_field

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:meyaoo_new/controller/all_star_msg_controller.dart';
import 'package:meyaoo_new/controller/single_chat_media_controller.dart';
import 'package:meyaoo_new/controller/user_chatlist_controller.dart';
import 'package:meyaoo_new/model/chat_profile_model.dart';
import 'package:meyaoo_new/model/group_audio_call_model.dart';
import 'package:meyaoo_new/model/groupvideocall_model.dart';
import 'package:meyaoo_new/src/global/global.dart';
import 'package:meyaoo_new/src/global/strings.dart';
import 'package:meyaoo_new/src/screens/call/audio/group_audio_call.dart';
import 'package:meyaoo_new/src/screens/call/video/group_video_call.dart';
import 'package:meyaoo_new/src/screens/chat/Media.dart';
import 'package:meyaoo_new/src/screens/chat/allstarred_msg_list.dart';
import 'package:meyaoo_new/src/screens/chat/group_memberlist.dart';
import 'package:meyaoo_new/src/screens/chat/group_profile_update.dart';
import 'package:meyaoo_new/src/screens/chat/single_chat.dart';

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

  GroupAudioCallModel grpAudioCallModel = GroupAudioCallModel();
  groupAudiocalling() async {
    setState(() {
      isLoading = true;
    });
    print("Audio_call_api");
    var uri = Uri.parse('${baseUrl()}GroupAudioCall');
    var request = http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };

    request.headers.addAll(headers);
    request.fields['group_id'] = "";
    request.fields['from_user'] = Hive.box(userdata).get(userId);

    var response = await request.send();
    print(request.fields);
    print(response.statusCode);

    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = jsonDecode(responseData);

    grpAudioCallModel = GroupAudioCallModel.fromJson(userData);
    log(responseData);
    setState(() {
      isLoading = false;
    });
    if (grpAudioCallModel.responseCode == "1") {
      setState(() {
        isLoading = false;
      });
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GroupVoiceCall(
              fromChannelId: "",
              fromToken: grpAudioCallModel.token,
              isCaller: true,
              callerImage: grpAudioCallModel.callerProfilePic,
              callerName: grpAudioCallModel.callerName,
              reciverImage: grpAudioCallModel.receiverProfilePic,
              reciverName: grpAudioCallModel.receiverName,
              callerId: grpAudioCallModel.callerId,
              reciverId: grpAudioCallModel.receiverId,
            ),
          ));
    }
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  GroupVideocallModel videoCallModel = GroupVideocallModel();

  videocall() async {
    setState(() {
      isLoading = true;
    });

    var uri = Uri.parse('${baseUrl()}GroupVideoCall');
    var request = http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };

    request.headers.addAll(headers);
    request.fields['from_user'] = Hive.box(userdata).get(userId);
    request.fields['group_id'] = "";
    var response = await request.send();
    print(response.statusCode);

    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = jsonDecode(responseData);

    videoCallModel = GroupVideocallModel.fromJson(userData);
    log(responseData);
    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      setState(() {
        isLoading = false;
      });
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GroupVideoCallScreen(
              fromChannelId: "",
              fromToken: videoCallModel.token,
              isCaller: true,
              callerImage: videoCallModel.callerProfilePic,
              callerName: videoCallModel.callerName,
              reciverImage: videoCallModel.receiverProfilePic,
              reciverName: videoCallModel.receiverName,
              callerId: videoCallModel.callerId,
              reciverId: videoCallModel.receiverId,
            ),
          ));
    }
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColorWhite,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: chatownColor,
        automaticallyImplyLeading: false,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Image.asset("assets/images/arrow-left.png",
                height: 18, color: chatColor),
          ),
        ),
        title: const Center(
          child: Text(
            'Group Info',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.w400, fontSize: 19),
          ),
        ),
        actions: [
          Obx(() {
            return chatProfileController.isLoading.value
                ? const Icon(
                    Icons.more_vert,
                    color: chatColor,
                    size: 24,
                  ).paddingOnly(right: 5)
                : _popMenu(
                    context,
                    chatProfileController
                        .profileModel.value!.conversationDetails!);
          })
        ],
      ),
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
      body: SafeArea(
          child: Stack(children: [
        Container(
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(),
        ),
        Obx(() {
          return chatProfileController.isLoading.value
              ? loader(context)
              : SingleChildScrollView(
                  child: SizedBox(
                    child: Column(
                      children: [
                        profilePic(chatProfileController
                            .profileModel.value!.conversationDetails!),
                        const SizedBox(height: 20),
                        Divider(thickness: 1, color: Colors.grey.shade300),
                        groupprofiledetails(chatProfileController
                            .profileModel.value!.conversationDetails!),
                        isLoading
                            ? Container()
                            : Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 25,
                                        top: 20,
                                        right: 25,
                                        bottom: 10),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          isParticipantsOpen =
                                              !isParticipantsOpen; // Toggle the state
                                        });
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                height: 45,
                                                width: 45,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Color.fromRGBO(
                                                      243, 243, 243, 1.000),
                                                ),
                                                child: Center(
                                                    child: Image.asset(
                                                        "assets/icons/eye.png",
                                                        height: 17)),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              const Padding(
                                                padding:
                                                    EdgeInsets.only(top: 2),
                                                child: Text(
                                                  'View Participants',
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                chatProfileController
                                                    .profileModel
                                                    .value!
                                                    .conversationDetails!
                                                    .conversationsUsers!
                                                    .length
                                                    .toString(),
                                                style: const TextStyle(
                                                    color: Colors.grey),
                                              ),
                                              Icon(
                                                isParticipantsOpen
                                                    ? Icons.keyboard_arrow_down
                                                    : Icons.keyboard_arrow_up,
                                                size: 23,
                                                color: Colors.grey,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (isParticipantsOpen) // Render the widget conditionally based on the state
                                    participants(),

                                  // medialinks(profileModel!),

                                  // blockandnotificaion(),
                                ],
                              ),
                      ],
                    ),
                  ),
                );
        }),
      ])),
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
        height: 48,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          // border: Border.all(color:  Colors.black, width: 1),
          borderRadius: BorderRadius.circular(5),
          color: chatownColor,
        ),
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
    return Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Column(
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
                InkWell(
                    onTap: () {
                      groupAudiocalling();
                    },
                    child: Container(
                      height: 53,
                      width: 68,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: chatownColor),
                          color: chatStrokeColor),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image(
                            image: AssetImage(
                              "assets/images/call_1.png",
                            ),
                            color: chatColor,
                            height: 15,
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Audio",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w400),
                          )
                        ],
                      ),
                    )),
                const SizedBox(
                  width: 30,
                ),
                InkWell(
                  onTap: () {
                    videocall();
                  },
                  child: Container(
                    height: 53,
                    width: 68,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: chatownColor),
                        color: chatStrokeColor),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/video_1.png",
                          color: chatColor,
                          height: 16,
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "Video",
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w400),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  width: 30,
                ),
                InkWell(
                  onTap: () {
                    Get.back(result: "1");
                  },
                  child: Container(
                    height: 53,
                    width: 68,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: chatownColor),
                        color: chatStrokeColor),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/icons/search-normal.png",
                          color: chatColor,
                          height: 15,
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "Search",
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w400),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 25,
            ),
            Container(
              height: 50,
              width: double.infinity,
              color: chatStrokeColor,
              child: const Padding(
                padding: EdgeInsets.only(left: 32, top: 15),
                child: Text("Preferences",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Media(
                            peeid: widget.conversationID,
                            peername: data.groupName!)));
              },
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 25, top: 10, right: 25, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 45,
                          width: 45,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color.fromRGBO(243, 243, 243, 1.000),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(14.0),
                            child: Image(
                              image: AssetImage('assets/icons/gallery.png'),
                              color: Colors.black,
                              height: 25,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Text(
                            'Media',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w400),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          chatProfileController.totalCount.toString(),
                          style: const TextStyle(color: Colors.grey),
                        ),
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
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25, right: 25),
              child: Divider(
                height: 2,
                color: Colors.grey.shade300,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: () {
                Get.to(
                    () => AllStarredMsgList(
                        conversationid: widget.conversationID,
                        isPersonal: true),
                    transition: Transition.rightToLeft);
              },
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 25, top: 10, right: 25, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 45,
                          width: 45,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color.fromRGBO(243, 243, 243, 1.000),
                          ),
                          child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Image.asset("assets/icons/star2.png",
                                  color: chatColor)),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                            'Started Messages',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w400),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Obx(() {
                          return Text(
                            allStaredMsgController.allStarred.isEmpty
                                ? "0"
                                : allStaredMsgController.allStarred.length
                                    .toString(),
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
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25, right: 25),
              child: Divider(
                height: 2,
                color: Colors.grey.shade300,
              ),
            )
          ],
        ));
  }

  Widget profilePic(ConversationDetails data) {
    return Padding(
      padding: const EdgeInsets.only(left: 25, top: 20),
      child: Row(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
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
            child: CustomCachedNetworkImage(
              imageUrl: data.groupProfileImage!,
              errorWidgeticon: const Icon(Icons.groups, size: 50),
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                child: Text(
                  capitalizeFirstLetter(data.groupName!),
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 20),
                ),
              ),
              const SizedBox(height: 10),
              RichText(
                  text: TextSpan(children: [
                WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Image.asset(
                      "assets/icons/people.png",
                      height: 21,
                      color: chatColor,
                    )),
                const WidgetSpan(child: SizedBox(width: 5)),
                TextSpan(
                  text: data.conversationsUsers!.length.toString(),
                  style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: Color(0xffA59FAC)),
                ),
              ])),
            ],
          )
        ],
      ),
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
                    Navigator.pop(context);
                    chatProfileController.removeAdminApi(
                        widget.conversationID, data.user!.userId.toString());
                    chatProfileController.users.remove(data);
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
                        const SizedBox(
                          width: 155,
                          height: 30,
                          child: Text(
                            'bio',
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
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
                    ? Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Text(
                          "Admin",
                          style: TextStyle(
                              color: Colors.grey.shade400,
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
                        height: 200,
                        child: Column(
                          children: [
                            const SizedBox(height: 5),
                            const Text(
                              "Group exit",
                              style: TextStyle(
                                  color: chatColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 22),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Text(
                              "Are you exit from ${data.groupName!} group?",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: appgrey2,
                                  fontSize: 13),
                            ),
                            const SizedBox(height: 30),
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
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: chatColor),
                                    )),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                InkWell(
                                  onTap: () {
                                    chatProfileController.exitGroupApi(
                                        cID: widget.conversationID);
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
                                      'Exit',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
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
}
