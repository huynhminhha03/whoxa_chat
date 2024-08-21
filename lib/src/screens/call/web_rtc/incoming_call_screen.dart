// ignore_for_file: must_be_immutable, non_constant_identifier_names

import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart' as getx;
import 'package:lottie/lottie.dart';
import 'package:meyaoo_new/controller/call_controller.dart/get_roomId_controller.dart';
import 'package:meyaoo_new/src/Notification/notification_service.dart';
import 'package:meyaoo_new/src/global/global.dart';
import 'package:meyaoo_new/src/screens/call/web_rtc/audio_call_screen.dart';
import 'package:meyaoo_new/src/screens/call/web_rtc/video_call_screen.dart';

class IncomingCallScrenn extends StatefulWidget {
  String roomID;
  String callerImage;
  String senderName;
  String conversation_id;
  String caller_id;
  String message_id;
  bool forVideoCall = true;
  String? receiverImage;
  IncomingCallScrenn({
    super.key,
    required this.roomID,
    required this.callerImage,
    required this.senderName,
    required this.conversation_id,
    required this.caller_id,
    required this.message_id,
    this.forVideoCall = true,
    this.receiverImage,
  });

  @override
  State<IncomingCallScrenn> createState() => _IncomingCallScrennState();
}

class _IncomingCallScrennState extends State<IncomingCallScrenn> {
  RTCVideoRenderer localRenderer = RTCVideoRenderer();
  RoomIdController roomIdController = getx.Get.put(RoomIdController());

  @override
  void initState() {
    initializeLocalRender();
    localCamera();
    super.initState();
  }

  Future<void> initializeLocalRender() async {
    await localRenderer.initialize();
  }

  localCamera() {
    navigator.mediaDevices
        .getUserMedia({"video": true, "audio": true}).then((mediaStream) {
      localRenderer.srcObject = mediaStream;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    // ignore: prefer_const_constructors
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: getx.Get.height,
            width: getx.Get.width,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
              child: widget.forVideoCall == true
                  ? RTCVideoView(
                      localRenderer,
                      mirror: true,
                      objectFit:
                          RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    )
                  :
                  //  Container(
                  //     decoration: BoxDecoration(
                  //       color: appColorWhite.withOpacity(0.1),
                  //       image: DecorationImage(
                  //         image: NetworkImage(widget.receiverImage!),
                  //         fit: BoxFit.cover,
                  //       ),
                  //     ),
                  //     child: BackdropFilter(
                  //       filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  //       child: Text(""),
                  // child:
                  Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: widget.callerImage,
                          fit: BoxFit.cover,
                          placeholder: (context, url) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: appIconColor,
                              ),
                            );
                          },
                          errorWidget: (context, url, error) {
                            return const Icon(
                              Icons.person,
                              size: 30,
                            );
                          },
                        ),
                        BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                          child: Container(
                            color: Colors.black.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(
                      Icons.arrow_back,
                    ),
                    const Text(
                      "End-to-end encrypted",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        fontFamily: "Poppins",
                      ),
                    ),
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(100)),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: appColorBlack.withOpacity(0.07),
                            ),
                            color: appColorBlack.withOpacity(0.10),
                          ),
                          child: Image.asset(
                            "assets/icons/profile-add.png",
                            height: 16,
                            width: 16,
                          ).paddingAll(9),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 73,
                ),
                Text(
                  widget.senderName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                    fontFamily: "Poppins",
                  ),
                ),
                const SizedBox(
                  height: 9,
                ),
                Text(
                  widget.forVideoCall == true
                      ? "Incoming Video Call"
                      : "Incoming Audio Call",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    fontFamily: "Poppins",
                  ),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Lottie.asset(
                      'assets/Lottie ANIMATION/caller_bg_animation.json',
                      height: 200,
                      width: 200,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: appColorWhite,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: CustomCachedNetworkImage(
                          imageUrl: widget.callerImage,
                          size: 129,
                          errorWidgeticon: const Icon(
                            Icons.person,
                            size: 30,
                          ),
                        ),
                      ).paddingAll(4),
                    ),
                  ],
                ),
                SizedBox(
                  height: getx.Get.height * 0.31,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () {
                        roomIdController.callCutByReceiver(
                          conversationID: widget.conversation_id,
                          message_id: widget.message_id,
                          caller_id: widget.caller_id,
                        );
                      },
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Lottie.asset(
                                'assets/Lottie ANIMATION/call_cut_animation.json',
                                height: 110,
                                width: 110,
                                fit: BoxFit.cover,
                              ),
                              Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(150),
                                    color: colorE04300),
                                child: Center(
                                    child: Image.asset(
                                  "assets/icons/call_reject.png",
                                  height: 24,
                                  width: 24,
                                )),
                              ),
                              const Positioned(
                                bottom: 5,
                                child: Text(
                                  "Reject",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    fontFamily: "Poppins",
                                    color: appColorWhite,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        LocalNotificationService.notificationsPlugin
                            .cancelAll();
                        if (widget.forVideoCall == true) {
                          getx.Get.off(
                            VideoCallScreen(
                              roomID: widget.roomID,
                              conversation_id: widget.conversation_id,
                            ),
                          );
                        } else {
                          getx.Get.off(
                            AudioCallScreen(
                              roomID: widget.roomID,
                              conversation_id: widget.conversation_id,
                              receiverImage: widget.callerImage,
                              receiverUserName: widget.senderName,
                            ),
                          );
                        }
                      },
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Lottie.asset(
                                'assets/Lottie ANIMATION/call_recieve_animation.json',
                                height: 110,
                                width: 110,
                                fit: BoxFit.cover,
                              ),
                              Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(150),
                                    color: color3CE000),
                                child: Center(
                                    child: Image.asset(
                                  "assets/icons/call_confirm.png",
                                  height: 24,
                                  width: 24,
                                )),
                              ),
                              const Positioned(
                                bottom: 5,
                                child: Text(
                                  "Conform",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    fontFamily: "Poppins",
                                    color: appColorWhite,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    localRenderer.srcObject?.getTracks().forEach((track) {
      track.stop();
    });
    localRenderer.dispose();
    super.dispose();
  }
}
