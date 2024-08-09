// ignore_for_file: use_build_context_synchronously, avoid_print, must_be_immutable, file_names

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:meyaoo_new/controller/all_star_msg_controller.dart';
import 'package:meyaoo_new/controller/single_chat_media_controller.dart';
import 'package:meyaoo_new/controller/user_chatlist_controller.dart';
import 'package:meyaoo_new/model/audiocallmodel.dart';
import 'package:meyaoo_new/model/chat_profile_model.dart';
import 'package:meyaoo_new/model/videocallmodel.dart';
import 'package:meyaoo_new/src/screens/chat/Media.dart';
import 'package:meyaoo_new/src/screens/chat/allstarred_msg_list.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meyaoo_new/src/global/global.dart';
import 'package:page_transition/page_transition.dart';
import '../../global/strings.dart';

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
    chatProfileController.getProfileDATA(widget.peeid!);
    allStaredMsgController.getAllStarMsg(widget.peeid);
    super.initState();
  }

  AudioCallModel audioCallModel = AudioCallModel();
  audiocalling() async {
    var uri = Uri.parse('${baseUrl()}audioCall');
    var request = http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };

    request.headers.addAll(headers);
    request.fields['from_user'] = Hive.box(userdata).get(userId);
    request.fields['to_user'] = widget.peeid!;
    var response = await request.send();
    print(response.statusCode);

    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = jsonDecode(responseData);

    audioCallModel = AudioCallModel.fromJson(userData);
    log(responseData);

    if (response.statusCode == 200) {
      setState(() {
        print("caller token::${audioCallModel.token}");
        print("caller channel::${audioCallModel.callerId}");
      });
    }
  }

  VideoCallModel videoCallModel = VideoCallModel();
  videocallApi() async {
    var uri = Uri.parse('${baseUrl()}videoCall');
    var request = http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };

    request.headers.addAll(headers);
    request.fields['from_user'] = Hive.box(userdata).get(userId);
    request.fields['to_user'] = widget.peeid!;
    var response = await request.send();

    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = jsonDecode(responseData);

    videoCallModel = VideoCallModel.fromJson(userData);
    log(responseData);

    if (response.statusCode == 200) {
      setState(() {
        print("caller token::${videoCallModel.token}");
        print("caller channel::${videoCallModel.callerId}");
      });
      // Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //         builder: (context) => VideoCallPage(
      //               fromChannelId: widget.peeid!,
      //               fromToken: videoCallModel.token,
      //               isCaller: true,
      //               callerImage: videoCallModel.callerProfilePic,
      //               callerName: videoCallModel.callerName,
      //               reciverImage: videoCallModel.receiverProfilePic,
      //               reciverName: widget.fullName,
      //               callerId: videoCallModel.callerId,
      //               reciverId: videoCallModel.receiverId,
      //               callID: videoCallModel.callId,
      //             )));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColorWhite,
      appBar: AppBar(
          backgroundColor: chatownColor,
          elevation: 0,
          centerTitle: true,
          leading: InkWell(
            onTap: () {
              // Navigator.pop(context);
              Get.back();
            },
            child: const Icon(Icons.arrow_back_ios, size: 20, color: chatColor),
          ),
          title: const Text(
            'View contact',
            style: TextStyle(
                fontWeight: FontWeight.w500, fontSize: 19, color: chatColor),
          )),
      body: Obx(() {
        return chatProfileController.isLoading.value
            ? loader(context)
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  profilePicWidget(chatProfileController
                      .profileModel.value!.conversationDetails!),
                  Divider(
                    thickness: 1,
                    color: Colors.grey.shade300,
                  ),
                  Center(child: profiledetails()),
                ],
              );
      }),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: InkWell(
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
                        height: 310,
                        child: Column(
                          children: [
                            Obx(() {
                              return Text(
                                chatListController.blockModel.value!.isBlock ==
                                        true
                                    ? 'UnBlock'
                                    : "Block",
                                style: const TextStyle(
                                    color: chatColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 22),
                              );
                            }),
                            const SizedBox(
                              height: 5,
                            ),
                            SizedBox(
                              width: 125,
                              height: 125,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CachedNetworkImage(
                                    imageUrl: widget.profileimg!,
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    placeholder: (context, url) => Center(
                                        child: Image.network(
                                      widget.profileimg!,
                                    )),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Text(
                              capitalizeFirstLetter(widget.fullName!),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 20),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/images/call_1.png",
                                  height: 20,
                                  color: Colors.grey,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                    chatProfileController
                                        .profileModel
                                        .value!
                                        .conversationDetails!
                                        .conversationsUsers![0]
                                        .user!
                                        .phoneNumber
                                        .toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ))
                              ],
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
                                    chatListController
                                        .blockUserApi(widget.peeid);
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
            child: Container(
              height: 50,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: chatownColor,
              ),
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
        ),
      ),
    );
  }

  Widget profilePicWidget(ConversationDetails data) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 10),
      child: Row(
        children: [
          Container(
            width: 95,
            height: 95,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(''),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
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
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
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
                      children: [
                        Image.asset(
                          "assets/images/call_1.png",
                          height: 20,
                          color: Colors.grey,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                            data.conversationsUsers![0].user!.phoneNumber
                                .toString(),
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
        ],
      ),
    );
  }

  Widget profiledetails() {
    return Container(
        // height:300,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    chatListController.blockModel.value!.isBlock == true
                        ? Fluttertoast.showToast(
                            msg: "User blocked, not able to voice call")
                        : audiocalling();
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
                  ),
                ),
                const SizedBox(width: 30),
                InkWell(
                  onTap: () {
                    chatListController.blockModel.value!.isBlock == true
                        ? Fluttertoast.showToast(
                            msg: "User blocked, not able to video call")
                        : videocallApi();
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
                const SizedBox(width: 30),
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
            const SizedBox(height: 20),
            Container(
              width: MediaQuery.sizeOf(context).width * 0.90,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color.fromRGBO(243, 243, 243, 1.000)),
              child: const Padding(
                padding: EdgeInsets.all(15.0),
                child: Text("...."),
              ),
            ),
            const SizedBox(
              height: 20,
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
                  PageTransition(
                    curve: Curves.linear,
                    type: PageTransitionType.rightToLeft,
                    child: Media(
                      peeid: widget.peeid,
                      peername: widget.fullName,
                    ),
                  ),
                );
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
                          height: 42,
                          width: 42,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color.fromRGBO(243, 243, 243, 1.000),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(11.0),
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
                                fontSize: 15, fontWeight: FontWeight.w500),
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
                        conversationid: widget.peeid, isPersonal: true),
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
                          height: 42,
                          width: 42,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color.fromRGBO(243, 243, 243, 1.000),
                          ),
                          child: Padding(
                              padding: const EdgeInsets.all(12.0),
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
                                fontSize: 15, fontWeight: FontWeight.w500),
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

  Widget highlights() {
    return Container(
        // height:300,
        width: MediaQuery.of(context).size.width * 0.90,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                    border: Border(
                  bottom: BorderSide(color: Color(0xffD1D1D1), width: 1),
                )),
                child: const Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Highlights',
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                height: 111,
                width: MediaQuery.of(context).size.width,
                color: Colors.transparent,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  primary: false,
                  padding: EdgeInsets.zero,
                  itemCount: 8,
                  itemBuilder: (BuildContext context, int index) {
                    return highlightscard();
                  },
                ),
              ),
            ],
          ),
        ));
  }

  Widget medialinks(data) {
    return Container(
        // height:300,
        width: MediaQuery.of(context).size.width * 0.90,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                    border: Border(
                  bottom: BorderSide(color: Color(0xffD1D1D1), width: 1),
                )),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Media, links, & docs',
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 16),
                        ),
                        InkWell(
                          onTap: () {
                            // Navigator.push(
                            //   context,
                            //   PageTransition(
                            //     curve: Curves.linear,
                            //     type: PageTransitionType.rightToLeft,
                            //     child: Media(
                            //       peeid: widget.peeid,
                            //       peername: widget.fullName,
                            //     ),
                            //   ),
                            // );
                          },
                          child: Container(
                            height: 26,
                            width: 60,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color(0xffF56A1F), width: 1),
                              borderRadius: BorderRadius.circular(20),
                              color: const Color(0xffFFF7F2),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '0',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xffF56A1F)),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Color(0xffF56A1F),
                                  size: 13,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                height: 100,
                width: MediaQuery.of(context).size.width,
                color: Colors.transparent,
                child: data.media!.isEmpty
                    ? Center(
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10)),
                          child: const Padding(
                            padding: EdgeInsets.all(15.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "you haven't Share any Media",
                                  style: TextStyle(
                                      color: gradient1,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w300),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        primary: false,
                        padding: EdgeInsets.zero,
                        itemCount: data.media!.length,
                        itemBuilder: (BuildContext context, int index) {
                          return chatcard(data.media, index);
                        },
                      ),
              ),
            ],
          ),
        ));
  }

  Widget chatcard(media, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          child: media[index].toString().contains(".mp4")
              ? Container(
                  height: 50,
                  width: 50,
                  color: Colors.grey.shade300,
                  child: const Icon(
                    CupertinoIcons.play_rectangle_fill,
                    size: 50,
                    color: Colors.white,
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: media[index].toString(),
                    fit: BoxFit.fill,
                  ),
                )),
    );
  }

  Widget highlightscard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                border: Border.all(width: 1, color: Colors.black)),
            child: const Padding(
              padding: EdgeInsets.all(3.0),
              child: CircleAvatar(
                radius: 33,
                backgroundColor: Colors.red,
                backgroundImage: AssetImage("assets/images/ice.png"),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Text("Text")
        ],
      ),
    );
  }
}
