// ignore_for_file: use_build_context_synchronously, avoid_print, must_be_immutable, file_names, unused_element

import 'dart:developer';
import 'dart:ui';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:meyaoo_new/controller/all_star_msg_controller.dart';
import 'package:meyaoo_new/controller/single_chat_media_controller.dart';
import 'package:meyaoo_new/controller/user_chatlist_controller.dart';
import 'package:meyaoo_new/model/chat_profile_model.dart';
import 'package:meyaoo_new/src/screens/chat/Media.dart';
import 'package:meyaoo_new/src/screens/chat/allstarred_msg_list.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meyaoo_new/src/global/global.dart';
import 'package:meyaoo_new/src/screens/chat/chatvideo.dart';
import 'package:meyaoo_new/src/screens/chat/imageView.dart';
import 'package:page_transition/page_transition.dart';

class ChatProfile extends StatefulWidget {
  String? fullName;
  String? profileimg;
  String? peeid;
  String? status;
  String? phnnum;
  ChatProfile({
    super.key,
    this.fullName,
    this.profileimg,
    this.peeid,
    this.phnnum,
    this.status,
  });
  @override
  State<ChatProfile> createState() => _ChatProfileState();
}

class _ChatProfileState extends State<ChatProfile> {
  AllStaredMsgController allStaredMsgController = Get.find();
  ChatListController chatListController = Get.find();
  ChatProfileController chatProfileController =
      Get.put(ChatProfileController());
  bool isLoading = false;
  File? image;
  final picker = ImagePicker();
  @override
  void initState() {
    print("ID:${widget.peeid}");
    print("PH:${widget.phnnum}");
    chatProfileController.getProfileDATA(widget.peeid!);
    allStaredMsgController.getAllStarMsg(widget.peeid);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color.fromRGBO(250, 250, 250, 1),
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: Get.height * 0.13),
                        profilePicWidget(chatProfileController
                            .profileModel.value!.conversationDetails!),
                        Center(
                            child: profiledetails(chatProfileController
                                .profileModel.value!.conversationDetails!)),
                      ],
                    ),
                    Positioned(
                        top: 40,
                        left: 5,
                        child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.arrow_back_ios, size: 19))),
                  ],
                ),
              );
      }),
      // bottomNavigationBar:
      //     BottomAppBar(color: Colors.white, elevation: 0, child: blockButton()),
    );
  }

  Widget profilePicWidget(ConversationDetails data) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 10),
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: Colors.white),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                width: 95,
                height: 95,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: data.isGroup == false
                    ? CustomCachedNetworkImage(
                        imageUrl:
                            data.conversationsUsers![0].user!.profileImage!,
                        errorWidgeticon: const Icon(Icons.person),
                      )
                    : CustomCachedNetworkImage(
                        imageUrl: data.groupProfileImage!,
                        errorWidgeticon: const Icon(Icons.groups),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          data.isGroup == false
              ? Text(
                  data.conversationsUsers![0].user!.userName!,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 18),
                )
              : Text(
                  data.groupName!,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 18),
                ),
          const SizedBox(height: 10),
          data.isGroup == false
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        "${data.conversationsUsers![0].user!.countryCode.toString()} ${data.conversationsUsers![0].user!.phoneNumber.toString()}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Colors.grey,
                        ))
                  ],
                )
              : const SizedBox(),
        ],
      ),
    );
  }

  Widget profiledetails(ConversationDetails data) {
    String matchNum(String number) {
      for (var i = 0; i < data.conversationsUsers!.length; i++) {
        if (number == data.conversationsUsers![i].user!.userName) {
          return data.conversationsUsers![i].user!.bio!;
        }
      }
      return '';
    }

    return Column(
      children: [
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buttonContainer(
                onTap: () {
                  chatListController.blockModel.value!.isBlock == true
                      ? Fluttertoast.showToast(
                          msg: "User blocked, not able to voice call")
                      : '';
                },
                img: "assets/images/call_1.png",
                title: "Audio"),
            const SizedBox(width: 30),
            buttonContainer(
                onTap: () {
                  chatListController.blockModel.value!.isBlock == true
                      ? Fluttertoast.showToast(
                          msg: "User blocked, not able to video call")
                      : '';
                },
                img: "assets/images/video_1.png",
                title: "Video"),
            const SizedBox(width: 30),
            buttonContainer(
                onTap: () {
                  Get.back(result: "1");
                },
                img: "assets/icons/search-normal.png",
                title: "Search")
          ],
        ),
        const SizedBox(height: 20),
        bioAndCreatedAt(data),
        // Container(
        //   width: MediaQuery.sizeOf(context).width * 0.90,
        //   decoration: BoxDecoration(
        //       borderRadius: BorderRadius.circular(10),
        //       color: const Color.fromRGBO(243, 243, 243, 1.000)),
        //   child: Padding(
        //     padding: const EdgeInsets.all(15.0),
        //     child: SelectableText(matchNum(widget.fullName!)),
        //   ),
        // ),
        const SizedBox(
          height: 20,
        ),
        mediaContainer(),
        const SizedBox(
          height: 20,
        ),
        stareContainer(),
        const SizedBox(
          height: 36,
        ),
        others(data),
      ],
    );
  }

  Widget others(ConversationDetails data) {
    return Column(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            showDialog(
              barrierColor: const Color.fromRGBO(30, 30, 30, 0.37),
              context: context,
              barrierDismissible: false,
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
                                  ? "Are you sure you want to unblock profile of  @${widget.fullName}?"
                                  : "Are you sure you want to block profile of  @${widget.fullName}?",
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
                                    height: 38,
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
                                        .blockUserApi(widget.peeid);
                                    Navigator.pop(context);
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
                                    child: Center(
                                        child: Text(
                                      chatListController
                                                  .blockModel.value!.isBlock ==
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
          child: Container(
            decoration: const BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(
                blurRadius: 0.5,
                spreadRadius: 0,
                offset: Offset(0, 0.4),
                color: Color.fromRGBO(239, 239, 239, 1),
              )
            ]),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 25, top: 15, right: 25, bottom: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/icons/block.png",
                        height: 18,
                        width: 18,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        chatListController.blockModel.value!.isBlock == true
                            ? 'Unblock ${data.conversationsUsers![0].user!.userName!}'
                            : 'Block ${data.conversationsUsers![0].user!.userName!}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xffFF2525),
                          fontFamily: "Poppins",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 1,
        ),
        Container(
          decoration: const BoxDecoration(color: Colors.white, boxShadow: [
            BoxShadow(
              blurRadius: 0.5,
              spreadRadius: 0,
              offset: Offset(0, 0.4),
              color: Color.fromRGBO(239, 239, 239, 1),
            )
          ]),
          child: Padding(
            padding:
                const EdgeInsets.only(left: 25, top: 15, right: 25, bottom: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/icons/report.png",
                      height: 18,
                      width: 18,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Report ${data.conversationsUsers![0].user!.userName!}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xffFF2525),
                        fontFamily: "Poppins",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 1,
        ),
        Container(
          decoration: const BoxDecoration(color: Colors.white, boxShadow: [
            BoxShadow(
              blurRadius: 0.5,
              spreadRadius: 0,
              offset: Offset(0, 0.4),
              color: Color.fromRGBO(239, 239, 239, 1),
            )
          ]),
          child: Padding(
            padding:
                const EdgeInsets.only(left: 25, top: 15, right: 25, bottom: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/icons/delete.png",
                      height: 18,
                      width: 18,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Delete ${data.conversationsUsers![0].user!.userName!}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xffFF2525),
                        fontFamily: "Poppins",
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
  }

  Widget bioAndCreatedAt(ConversationDetails data) {
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
                conversationid: widget.peeid, isPersonal: true),
            transition: Transition.rightToLeft,
          );
        },
        child: Padding(
          padding:
              const EdgeInsets.only(left: 20, top: 10, right: 25, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: Get.width * 0.80,
                child: Text(
                  data.conversationsUsers![0].user!.bio!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      fontFamily: "Poppins",
                      color: Color(0xff000000)),
                ),
              ),
              Row(
                children: [
                  Text(
                    "Logged in",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 9,
                        fontFamily: "Poppins",
                        color: const Color(0xff000000).withOpacity(0.26)),
                  ),
                  const SizedBox(
                    width: 2,
                  ),
                  Text(
                    dateFormate(
                      convertToLocalDate(
                          data.conversationsUsers![0].user!.createdAt),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 9,
                        fontFamily: "Poppins",
                        color: const Color(0xff000000).withOpacity(0.26)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
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
                  builder: (context) =>
                      Media(peeid: widget.peeid, peername: widget.fullName)));
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
                  conversationid: widget.peeid, isPersonal: true),
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
                    'Starred Messages',
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

  Widget blockButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: InkWell(
        onTap: () {
          showDialog(
            barrierColor: const Color.fromRGBO(30, 30, 30, 0.37),
            context: context,
            barrierDismissible: false,
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
                            chatListController.blockModel.value!.isBlock == true
                                ? "Are you sure you want to Unblock?"
                                : "Are you sure you want to Block?",
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            chatListController.blockModel.value!.isBlock == true
                                ? "Are you sure you want to unblock profile of  @${widget.fullName}?"
                                : "Are you sure you want to block profile of  @${widget.fullName}?",
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
                                  height: 38,
                                  width:
                                      MediaQuery.of(context).size.width * 0.35,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: yellow2Color, width: 1),
                                      borderRadius: BorderRadius.circular(12)),
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
                                  chatListController.blockUserApi(widget.peeid);
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  height: 40,
                                  width:
                                      MediaQuery.of(context).size.width * 0.35,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      gradient: LinearGradient(
                                          colors: [yellow1Color, yellow2Color],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter)),
                                  child: Center(
                                      child: Text(
                                    chatListController
                                                .blockModel.value!.isBlock ==
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
        child: Container(
          height: 45,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                  colors: [yellow1Color, yellow2Color],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter)),
          child: Center(
            child: Obx(() {
              return Text(
                chatListController.blockModel.value!.isBlock == true
                    ? 'UnBlock'
                    : "Block",
                style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 16),
              );
            }),
          ),
        ),
      ),
    );
  }
}
