// ignore_for_file: avoid_print, must_be_immutable, unused_local_variable

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:meyaoo_new/src/global/global.dart';
import 'package:meyaoo_new/src/global/strings.dart';
import 'package:meyaoo_new/src/screens/layout/bottombar.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

const String appId = "a6da6b51ecc1430ca4a0cb1b3b4235cb";

class VoiceCall extends StatefulWidget {
  String? fromChannelId;
  String? fromToken;
  String? waitChannelId;
  String? waitToken;
  String? callerImage;
  String? reciverImage;
  String? callerName;
  String? reciverName;
  String? callerId;
  String? reciverId;
  bool isCaller;
  bool? isReciverWait;
  String? callID;
  VoiceCall({
    super.key,
    this.fromChannelId,
    this.fromToken,
    this.waitChannelId,
    this.waitToken,
    required this.isCaller,
    this.callerImage,
    this.reciverImage,
    this.callerName,
    this.reciverName,
    this.callerId,
    this.reciverId,
    this.isReciverWait,
    this.callID,
  });

  @override
  State<VoiceCall> createState() => _VoiceCallState();
}

class _VoiceCallState extends State<VoiceCall> {
  // ignore: unused_field
  int? _remoteUid = 0;
  // ignore: unused_field
  bool _localUserJoined = false;
  late RtcEngine _engine;
  String? fromChannelId;
  String? fromToken;

  bool enableAudio = true;
  bool enableSpeaker = false;

  bool _isTimerRunning = false;
  int _secondsElapsed = 0;

  @override
  void initState() {
    super.initState();

    fromChannelId = widget.fromChannelId;
    fromToken = widget.fromToken;
    print("widget.fromChannelId::$fromChannelId");
    print("widget.fromToken::$fromToken");
    initAgora();
  }

  Future<void> initAgora() async {
    // retrieve permissions
    await [Permission.microphone].request();

    //create the engine
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: "a6da6b51ecc1430ca4a0cb1b3b4235cb",
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("local user ${connection.localUid} joined");
          setState(() {
            _localUserJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("remote user $remoteUid joined");
          setState(() {
            _remoteUid = remoteUid;
            if (!_isTimerRunning) {
              startTimer();
            }
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          debugPrint("remote user $remoteUid left channel");
          setState(() {
            _remoteUid = null;
          });
          Get.off(TabbarScreen());
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint(
              '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
        },
      ),
    );

    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    // await _engine.enableVideo();
    await _engine.enableAudio();
    await _engine.setDefaultAudioRouteToSpeakerphone(false);

    // await _engine.enable();
    await _engine.startPreview();

    await _engine.joinChannel(
      token: "$fromToken",
      channelId: "$fromChannelId",
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  void startTimer() {
    // Start the timer
    _isTimerRunning = true;
    const oneSecond = Duration(seconds: 1);
    Timer.periodic(oneSecond, (timer) {
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  String formatTime(int seconds) {
    // Format the elapsed time in the format 00:00
    String minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    String remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  @override
  void dispose() {
    super.dispose();
    _dispose();
  }

  Future<void> _dispose() async {
    await _engine.leaveChannel();
    await _engine.release();
  }

// to user side cut call api

  cutCallToUserApi(String callCUT) async {
    var uri = Uri.parse('${baseUrl()}CutCall');
    var request = http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };

    request.headers.addAll(headers);
    request.fields['from_user'] = Hive.box(userdata).get(userId);
    request.fields['to_user'] = widget.reciverId!;
    request.fields['type'] = "audio_call";
    request.fields['call_id'] = widget.callID!;
    request.fields['call_check'] = callCUT;
    var response = await request.send();
    print(response.statusCode);

    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = jsonDecode(responseData);

    log("To_SIDE:${request.fields}");
    log("To_SIDE:$responseData");

    if (response.statusCode == 200) {
      setState(() {});
    }
  }

// from side call cut api
  cutCallFromApi(String callCUT) async {
    var uri = Uri.parse('${baseUrl()}CallCutFromUser');
    var request = http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };

    request.headers.addAll(headers);
    request.fields['from_user'] = Hive.box(userdata).get(userId);
    request.fields['to_user'] = widget.reciverId!;
    request.fields['type'] = "audio_call";
    request.fields['call_id'] = widget.callID!;
    request.fields['call_check'] = callCUT;
    var response = await request.send();
    print(response.statusCode);

    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = jsonDecode(responseData);

    log("FROM_SIDE:${request.fields}");
    log("FROM_SIDE:$responseData");

    if (response.statusCode == 200) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white.withOpacity(0.4),
        body: SafeArea(
          child: Column(
            children: [
              Flexible(
                child: Center(
                  child: widget.isCaller == false
                      ? Stack(
                          children: [
                            Opacity(
                              opacity: 0.2,
                              child: SizedBox(
                                height: Get.height,
                                width: Get.width,
                                child: Material(
                                  clipBehavior: Clip.hardEdge,
                                  child: widget.callerImage!.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: widget.callerImage!,
                                          width: 100.0,
                                          height: 100.0,
                                          fit: BoxFit.cover,
                                          progressIndicatorBuilder:
                                              (context, url, progress) {
                                            return const Center(
                                              child: CircularProgressIndicator(
                                                color: chatownColor,
                                              ),
                                            );
                                          },
                                          errorWidget: (context, url, error) =>
                                              const Material(
                                                clipBehavior: Clip.hardEdge,
                                                child: Padding(
                                                  padding: EdgeInsets.all(0.0),
                                                  child: Icon(
                                                    Icons.person,
                                                    size: 40,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ))
                                      : Image.asset(
                                          'assets/images/user1.png',
                                          width: 100.0,
                                          height: 100.0,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                            ),
                            Positioned(
                              child: Align(
                                alignment: Alignment.center,
                                child: Column(
                                  children: [
                                    const SizedBox(height: 250),
                                    Container(
                                      height: 130,
                                      width: 130,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 2, color: Colors.white),
                                        shape: BoxShape.circle,
                                        color: Colors.red,
                                      ),
                                      child: Material(
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(100.0),
                                        ),
                                        clipBehavior: Clip.hardEdge,
                                        child: widget.callerImage!.isNotEmpty
                                            ? CachedNetworkImage(
                                                imageUrl: widget.callerImage!,
                                                progressIndicatorBuilder:
                                                    (context, url, progress) {
                                                  return const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: chatownColor,
                                                    ),
                                                  );
                                                },
                                                errorWidget: (context, url,
                                                        error) =>
                                                    const Material(
                                                      clipBehavior:
                                                          Clip.hardEdge,
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.all(0.0),
                                                        child: Icon(
                                                          Icons.person,
                                                          size: 40,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ))
                                            : const Padding(
                                                padding: EdgeInsets.all(05.0),
                                                child: Icon(
                                                  Icons.person,
                                                  size: 90,
                                                ),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      widget.callerName!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                        fontFamily: "Poppins-Medium",
                                      ),
                                    ),
                                    _remoteUid != 0
                                        ? const SizedBox()
                                        : const SizedBox(height: 10),
                                    _remoteUid != 0
                                        ? const SizedBox()
                                        : const Text(
                                            'is Audio Calling...',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                    const SizedBox(height: 10),
                                    _remoteUid != 0
                                        ? Text(
                                            formatTime(_secondsElapsed),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                            ),
                                          )
                                        : const SizedBox()
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : Stack(
                          children: [
                            Opacity(
                              opacity: 0.2,
                              child: SizedBox(
                                height: Get.height,
                                width: Get.width,
                                child: Material(
                                  clipBehavior: Clip.hardEdge,
                                  child: widget.reciverImage!.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: widget.reciverImage!,
                                          width: 100.0,
                                          height: 100.0,
                                          fit: BoxFit.cover,
                                          progressIndicatorBuilder:
                                              (context, url, progress) {
                                            return const Center(
                                              child: CircularProgressIndicator(
                                                color: chatownColor,
                                              ),
                                            );
                                          },
                                          errorWidget: (context, url, error) =>
                                              const Material(
                                                clipBehavior: Clip.hardEdge,
                                                child: Padding(
                                                  padding: EdgeInsets.all(0.0),
                                                  child: Icon(
                                                    Icons.person,
                                                    size: 40,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ))
                                      : Image.asset(
                                          'assets/images/user1.png',
                                          // width: 100.0,
                                          // height: 100.0,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                            ),
                            Positioned(
                              child: Align(
                                alignment: Alignment.center,
                                child: Column(
                                  children: [
                                    const SizedBox(height: 250),
                                    Container(
                                      height: 130,
                                      width: 130,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 2, color: Colors.white),
                                        shape: BoxShape.circle,
                                        color: Colors.red,
                                      ),
                                      child: Material(
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(100.0),
                                        ),
                                        clipBehavior: Clip.hardEdge,
                                        child: widget.reciverImage!.isNotEmpty
                                            ? CachedNetworkImage(
                                                imageUrl: widget.reciverImage!,
                                                progressIndicatorBuilder:
                                                    (context, url, progress) {
                                                  return const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: chatownColor,
                                                    ),
                                                  );
                                                },
                                                errorWidget: (context, url,
                                                        error) =>
                                                    const Material(
                                                      clipBehavior:
                                                          Clip.hardEdge,
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.all(0.0),
                                                        child: Icon(
                                                          Icons.person,
                                                          size: 40,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ))
                                            : const Padding(
                                                padding: EdgeInsets.all(05.0),
                                                child: Icon(
                                                  Icons.person,
                                                  size: 90,
                                                ),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    _remoteUid != 0
                                        ? const SizedBox()
                                        : Text(
                                            _localUserJoined == false
                                                ? 'Calling...'
                                                : 'Ringing...',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                    const SizedBox(height: 10),
                                    Text(
                                      widget.reciverName!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                        fontFamily: "Poppins-Medium",
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    _remoteUid != 0
                                        ? Text(
                                            formatTime(_secondsElapsed),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                            ),
                                          )
                                        : const SizedBox()
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(0, 14, 0, 28),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10))),
                //from side
                child: widget.isCaller == true
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          RawMaterialButton(
                            elevation: 0,
                            onPressed: () async {
                              speakerEnableDisable();
                            },
                            shape: const CircleBorder(),
                            fillColor: Colors.grey.shade200,
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Icon(
                                enableSpeaker == false
                                    ? Icons.volume_off_rounded
                                    : Icons.volume_up_rounded,
                                size: 27.0,
                                color: chatColor,
                              ),
                            ),
                          ),
                          RawMaterialButton(
                            elevation: 0,
                            onPressed: () async {
                              localAudioEnableDisable();
                            },
                            shape: const CircleBorder(),
                            fillColor: Colors.grey.shade200,
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Icon(
                                enableAudio == true ? Icons.mic : Icons.mic_off,
                                size: 27.0,
                                color: chatColor,
                              ),
                            ),
                          ),
                          // RawMaterialButton(
                          //   elevation: 0,
                          //   onPressed: () async {},
                          //   shape: const CircleBorder(),
                          //   fillColor: Colors.grey.shade200,
                          //   child: Padding(
                          //     padding: const EdgeInsets.all(15.0),
                          //     child: Icon(
                          //       Icons.chat_bubble,
                          //       size: 27.0,
                          //       color: Colors.grey.shade400,
                          //     ),
                          //   ),
                          // ),
                          // call My side
                          RawMaterialButton(
                            elevation: 0,
                            onPressed: () async {
                              if (_remoteUid == 0) {
                                cutCallFromApi("1");
                                endCall();
                                print("USER__FROM_1");
                              } else {
                                cutCallFromApi("0");
                                endCall();
                                print("USER__FROM_2");
                              }
                            },
                            shape: const CircleBorder(),
                            fillColor: Colors.red,
                            child: const Padding(
                              padding: EdgeInsets.all(15.0),
                              child: Icon(
                                Icons.call_end,
                                size: 27.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      )
                    //to side
                    : widget.isReciverWait == false
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              RawMaterialButton(
                                elevation: 0,
                                onPressed: () async {
                                  speakerEnableDisable();
                                },
                                shape: const CircleBorder(),
                                fillColor: Colors.grey.shade200,
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Icon(
                                    enableSpeaker == false
                                        ? Icons.volume_off_rounded
                                        : Icons.volume_up_rounded,
                                    size: 27.0,
                                    color: chatColor,
                                  ),
                                ),
                              ),
                              RawMaterialButton(
                                elevation: 0,
                                onPressed: () async {
                                  localAudioEnableDisable();
                                },
                                shape: const CircleBorder(),
                                fillColor: Colors.grey.shade200,
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Icon(
                                    enableAudio == true
                                        ? Icons.mic
                                        : Icons.mic_off,
                                    size: 27.0,
                                    color: chatColor,
                                  ),
                                ),
                              ),
                              // RawMaterialButton(
                              //   elevation: 0,
                              //   onPressed: () async {
                              //     // videoEnableDisable();
                              //   },
                              //   shape: const CircleBorder(),
                              //   fillColor: Colors.grey.shade200,
                              //   child: Padding(
                              //     padding: const EdgeInsets.all(15.0),
                              //     child: Icon(
                              //       Icons.chat_bubble,
                              //       size: 27.0,
                              //       color: Colors.grey.shade400,
                              //     ),
                              //   ),
                              // ),
                              RawMaterialButton(
                                onPressed: () async {
                                  cutCallToUserApi("0");
                                  endCall();
                                  print("USER__TO_1");
                                },
                                shape: const CircleBorder(),
                                fillColor: Colors.red,
                                child: const Padding(
                                  padding: EdgeInsets.all(15.0),
                                  child: Icon(
                                    Icons.call_end,
                                    size: 27.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      // chatController.callCut(
                                      //   toUser: widget.callerId,
                                      // );
                                      if (_remoteUid == 0) {
                                        cutCallToUserApi("1");
                                        endCall();
                                        print("USER__TO_2");
                                      } else {
                                        cutCallToUserApi("0");
                                        endCall();
                                        print("USER__TO_3");
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 10),
                                      decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: const Row(
                                        children: [
                                          Icon(
                                            Icons.call_end,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 15),
                                          Text(
                                            'Decline',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Colors.white,
                                              fontFamily: "Poppins-Medium",
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        print(
                                            "widget.waitChannelId!::${widget.waitChannelId!}");
                                        print(
                                            "widget.waitToken!::${widget.waitToken!}");
                                        widget.isReciverWait = false;
                                        fromChannelId = widget.waitChannelId!;
                                        fromToken = widget.waitToken;
                                        initAgora();
                                      });
                                      // if (widget.type == 'Video call') {
                                      //   // Navigate to the desired screen based on the payload'
                                      //   Get.to(VideoCallPage(
                                      //     fromChannelId: widget.channel,
                                      //     fromToken: widget.token,
                                      //     isCaller: false,
                                      //     callerImage: widget.callerImage,
                                      //     callerName: widget.callerName,
                                      //   ));
                                      // } else if (widget.type == 'Audio call') {
                                      //   Get.to(VoiceCall(
                                      //     fromChannelId: widget.channel,
                                      //     fromToken: widget.token,
                                      //     isCaller: false,
                                      //     callerImage: widget.callerImage,
                                      //     callerName: widget.callerName,
                                      //   ));
                                      // }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 10),
                                      decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: const Row(
                                        children: [
                                          Icon(
                                            Icons.call,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 15),
                                          Text(
                                            'Accept',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Colors.white,
                                              fontFamily: "Poppins-Medium",
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
              )
            ],
          ),
        )

        // Padding(
        //   padding: const EdgeInsets.symmetric(
        //     horizontal: 25,
        //     vertical: 8,
        //   ),
        //   child: Column(
        //     // mainAxisAlignment: MainAxisAlignment.center,
        //     crossAxisAlignment: CrossAxisAlignment.center,
        //     children: [
        //       const SizedBox(
        //         height: 80,
        //       ),
        //       Align(
        //         alignment: Alignment.centerLeft,
        //         child: Column(
        //           crossAxisAlignment: CrossAxisAlignment.start,
        //           children: [
        //             Text(
        //               widget.isCaller == false
        //                   ? widget.callerName!
        //                   : widget.reciverName!,
        //               style: TextStyle(
        //                 color: Colors.white,
        //                 fontSize: 28,
        //               ),
        //             ),
        //             widget.isCaller == false
        //                 ? Text(
        //                     formatTime(_secondsElapsed),
        //                     style: const TextStyle(
        //                       color: Colors.white,
        //                       fontSize: 18,
        //                     ),
        //                   )
        //                 : Text(
        //                     _localUserJoined == false
        //                         ? 'Calling...'
        //                         : _remoteUid == 0
        //                             ? 'Ringing...'
        //                             : formatTime(_secondsElapsed),
        //                     style: const TextStyle(
        //                       color: Colors.white,
        //                       fontSize: 18,
        //                     ),
        //                   ),
        //           ],
        //         ),
        //       ),
        //       const SizedBox(
        //         height: 80,
        //       ),
        //       widget.isCaller == false
        //           ? Container(
        //               height: 100,
        //               width: 100,
        //               decoration: BoxDecoration(
        //                 border: Border.all(
        //                   width: 0.5,
        //                 ),
        //                 shape: BoxShape.circle,
        //                 color: Colors.red,
        //               ),
        //               child: Material(
        //                 child: widget.callerImage!.isNotEmpty
        //                     ? CachedNetworkImage(
        //                         placeholder: (context, url) => Container(
        //                           child: CupertinoActivityIndicator(),
        //                           width: 30.0,
        //                           height: 30.0,
        //                           padding: EdgeInsets.all(10.0),
        //                         ),
        //                         errorWidget: (context, url, error) => Material(
        //                           child: Padding(
        //                             padding: const EdgeInsets.all(0.0),
        //                             child: Icon(
        //                               Icons.person,
        //                               size: 30,
        //                               color: Colors.grey,
        //                             ),
        //                           ),
        //                           borderRadius: BorderRadius.all(
        //                             Radius.circular(8.0),
        //                           ),
        //                           clipBehavior: Clip.hardEdge,
        //                         ),
        //                         imageUrl: widget.callerImage!,
        //                         width: 80.0,
        //                         height: 80.0,
        //                         fit: BoxFit.cover,
        //                       )
        //                     : Padding(
        //                         padding: const EdgeInsets.all(05.0),
        //                         child: Icon(
        //                           Icons.person,
        //                           size: 70,
        //                         ),
        //                       ),
        //                 borderRadius: BorderRadius.all(
        //                   Radius.circular(100.0),
        //                 ),
        //                 clipBehavior: Clip.hardEdge,
        //               ),
        //             )
        //           : Container(
        //               height: 100,
        //               width: 100,
        //               decoration: BoxDecoration(
        //                 border: Border.all(
        //                   width: 0.5,
        //                 ),
        //                 shape: BoxShape.circle,
        //                 color: Colors.red,
        //               ),
        //               child: Material(
        //                 child: widget.reciverImage!.isNotEmpty
        //                     ? CachedNetworkImage(
        //                         placeholder: (context, url) => Container(
        //                           child: CupertinoActivityIndicator(),
        //                           width: 30.0,
        //                           height: 30.0,
        //                           padding: EdgeInsets.all(10.0),
        //                         ),
        //                         errorWidget: (context, url, error) => Material(
        //                           child: Padding(
        //                             padding: const EdgeInsets.all(0.0),
        //                             child: Icon(
        //                               Icons.person,
        //                               size: 30,
        //                               color: Colors.grey,
        //                             ),
        //                           ),
        //                           borderRadius: BorderRadius.all(
        //                             Radius.circular(8.0),
        //                           ),
        //                           clipBehavior: Clip.hardEdge,
        //                         ),
        //                         imageUrl: widget.reciverImage!,
        //                         width: 80.0,
        //                         height: 80.0,
        //                         fit: BoxFit.cover,
        //                       )
        //                     : Padding(
        //                         padding: const EdgeInsets.all(05.0),
        //                         child: Icon(
        //                           Icons.person,
        //                           size: 70,
        //                         ),
        //                       ),
        //                 borderRadius: BorderRadius.all(
        //                   Radius.circular(100.0),
        //                 ),
        //                 clipBehavior: Clip.hardEdge,
        //               ),
        //             ),
        //       const SizedBox(
        //         height: 120,
        //       ),
        //       Padding(
        //         padding: const EdgeInsets.symmetric(
        //           horizontal: 15,
        //         ),
        //         child: Row(
        //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //           children: [
        //             optionsButton(
        //               icon: enableAudio == true ? Icons.mic : Icons.mic_off,
        //               lable: 'mute',
        //               onPressed: () async {
        //                 localAudioEnableDisable();
        //               },
        //             ),
        //             optionsButton(
        //               icon: Icons.chat_bubble,
        //               lable: 'message',
        //             ),
        //             optionsButton(
        //               icon: enableSpeaker == true
        //                   ? Icons.volume_up_rounded
        //                   : Icons.volume_off_rounded,
        //               lable: 'speaker',
        //               onPressed: () async {
        //                 speakerEnableDisable();
        //               },
        //             ),
        //           ],
        //         ),
        //       ),
        //       const SizedBox(
        //         height: 40,
        //       ),
        //       RawMaterialButton(
        //         onPressed: () async {
        //           endCall();
        //         },
        //         shape: const CircleBorder(),
        //         elevation: 0,
        //         fillColor: Colors.red,
        //         child: const Padding(
        //           padding: EdgeInsets.all(19.0),
        //           child: Icon(
        //             Icons.call_end,
        //             size: 35.0,
        //             color: Colors.white,
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        );
  }

  endCall() async {
    await _engine.leaveChannel();
    await _engine.release();
    // ignore: use_build_context_synchronously
    Get.off(TabbarScreen());
  }

  localAudioEnableDisable() async {
    if (enableAudio == true) {
      await _engine.enableLocalAudio(false);
      setState(() {
        enableAudio = false;
      });
    } else {
      await _engine.enableLocalAudio(true);
      setState(() {
        enableAudio = true;
      });
    }
  }

  speakerEnableDisable() async {
    if (enableSpeaker == true) {
      await _engine.setEnableSpeakerphone(false);
      setState(() {
        enableSpeaker = false;
      });
    } else {
      await _engine.setEnableSpeakerphone(true);
      setState(() {
        enableSpeaker = true;
      });
    }
  }
}

Widget optionsButton({
  void Function()? onPressed,
  IconData? icon,
  String? lable,
}) {
  return Column(
    children: [
      RawMaterialButton(
        onPressed: onPressed,
        shape: const CircleBorder(
            side: BorderSide(
          color: Colors.white,
          width: 2,
        )),
        fillColor: Colors.transparent,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(19.0),
          child: Icon(
            icon,
            size: 35.0,
            color: Colors.white,
          ),
        ),
      ),
      const SizedBox(
        height: 3,
      ),
      Text(
        lable!,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
        ),
      ),
    ],
  );
}

// class Audiocall extends StatefulWidget {
//   String touser;
//   String userName;
//   String userImage;
//   String? token;
//   String? channelId;
//   Audiocall(
//       {super.key,
//       required this.touser,
//       required this.userName,
//       required this.userImage,
//       this.token,
//       this.channelId});

//   @override
//   State<Audiocall> createState() => _AudiocallState();
// }

// class _AudiocallState extends State<Audiocall> {
//   double volume = 0.1;

//   AudioPlayer audioPlayer = AudioPlayer();

//   AudioCallModel audioCallModel = AudioCallModel();
//   int? _remoteUid; // uid of the remote user
//   bool _isJoined = false;
//   bool isLoading = true;
//   bool speaker = false;
//   int uid = 0;
//   late RtcEngine agoraEngine;

//   bool muted = false;

//   List<int> _callDurations = [];

//   DateTime? _callStartTime;
//   DateTime? _callEndTime;
//   Timer? _timer;
//   int _elapsedSeconds = 0;
//   bool _isCallActive = false;
//   void setVolume(double value) {
//     audioPlayer.setVolume(value);
//   }

//   void _startCall() {
//     setState(() {
//       _isCallActive = true;
//       _callStartTime = DateTime.now();
//       _elapsedSeconds = 0;
//       _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//         setState(() {
//           _elapsedSeconds++;
//         });
//       });
//     });
//   }

//   void _endCall() {
//     setState(() {
//       _isCallActive = false;
//       _callEndTime = DateTime.now();
//       _timer!.cancel();
//       final callDuration = _callEndTime!.difference(_callStartTime!).inSeconds;
//       _callDurations.add(callDuration);
//     });
//   }

//   String formatDuration(int seconds) {
//     final minutes = seconds ~/ 60;
//     final remainingSeconds = seconds % 60;
//     return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
//   }

//   void playAudio() async {
//     var ap = AudioPlayer();
//     await ap.play(AssetSource("audio/notification.mp3"));
//   }

//   @override
//   void initState() {
//     super.initState();
//     print(widget.touser);
//     print(widget.userName);
//     print("AUDIO: ${widget.token}");
//     print("AUDIO CHANNEL :${widget.channelId}");
//     // Set up an instance of Agora engine
//     setupVoiceSDKEngine();
//     setVolume(0.1);
//     playAudio();
//   }

// // Clean up the resources when you leave
//   @override
//   void dispose() {
//     _timer!.cancel();
//     agoraEngine.leaveChannel();
//     agoraEngine.release();
//     audioPlayer.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//           elevation: 0,
//           backgroundColor: gradient1,
//           title: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.lock, color: Colors.black),
//               Container(width: 5),
//               const Text(
//                 "End-to-end voice call",
//                 style: TextStyle(fontSize: 14, color: Colors.white),
//               ),
//             ],
//           ),
//           centerTitle: true,
//           automaticallyImplyLeading: false,
//           leading: null),
//       body: SafeArea(
//           child: Stack(
//         children: [
//           Container(
//             height: MediaQuery.of(context).size.height,
//             width: MediaQuery.of(context).size.width,
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [gradient1, gradient2],
//                 begin: Alignment.topLeft,
//                 end: Alignment.centerRight,
//               ),
//             ),
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Column(
//                 children: [
//                   Text(
//                     widget.userName,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 18,
//                     ),
//                   ),

//                   SizedBox(height: MediaQuery.of(context).size.height * 0.05),
//                   const Text(
//                     "Voice Call",
//                     style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.black,
//                         fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(
//                     height: 6,
//                   ),
//                   isLoading
//                       ? const Text(
//                           "Calling",
//                           style: TextStyle(fontSize: 20, color: Colors.black),
//                         )
//                       : _status(),
//                   SizedBox(height: MediaQuery.of(context).size.height * 0.10),

//                   CircleAvatar(
//                     radius: 80,
//                     backgroundImage: NetworkImage(widget.userImage),
//                   ),

//                   SizedBox(height: MediaQuery.of(context).size.height * 0.30),
//                   SizedBox(
//                     width: MediaQuery.of(context).size.width,
//                     child: Container(
//                       width: MediaQuery.of(context).size.width,
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             InkWell(
//                                 onTap: () {
//                                   _onToggleMute();
//                                 },
//                                 child: !muted
//                                     ? Image.asset(
//                                         "assets/images/voice.png",
//                                         height: 45,
//                                       )
//                                     : Image.asset(
//                                         "assets/images/muted.png",
//                                         height: 45,
//                                       )),
//                             InkWell(
//                                 onTap: () {
//                                   leave();
//                                 },
//                                 child: Image.asset(
//                                   "assets/images/cut_call.png",
//                                   height: 85,
//                                 )),
//                             speaker
//                                 ? InkWell(
//                                     onTap: () {
//                                       _onSpeaker();
//                                     },
//                                     child: Image.asset(
//                                       "assets/images/speaker.png",
//                                       height: 25,
//                                       color:
//                                           const Color.fromARGB(255, 3, 192, 9),
//                                     ))
//                                 : InkWell(
//                                     onTap: () {
//                                       _onSpeaker();
//                                     },
//                                     child: Image.asset(
//                                       "assets/images/speaker.png",
//                                       height: 25,
//                                       color: Colors.white,
//                                     )),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),

//                   // SizedBox(height: 20),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       )),
//     );
//   }

//   void _onSpeaker() {
//     setState(() {
//       speaker = !speaker;
//       setVolume(1);
//     });
//     if (speaker == true) {
//       agoraEngine.setEnableSpeakerphone(speaker);
//     } else {
//       agoraEngine.setEnableSpeakerphone(speaker);
//       // player.earpieceOrSpeakersToggle();
//     }
//   }

//   void _onSpeaker1() {
//     setState(() {
//       setVolume(3);
//       speaker = !speaker;
//     });
//     if (speaker == true) {
//       agoraEngine.setEnableSpeakerphone(speaker);
//     } else {
//       agoraEngine.setEnableSpeakerphone(speaker);
//       // player.earpieceOrSpeakersToggle();
//     }
//   }

//   void _onToggleMute() async {
//     setState(() {
//       muted = !muted;
//     });
//     await agoraEngine.muteLocalAudioStream(muted);
//   }

//   // audiocalling() async {
//   //   var uri = Uri.parse('${baseUrl()}audioCall');
//   //   var request = http.MultipartRequest("POST", uri);
//   //   Map<String, String> headers = {
//   //     "Accept": "application/json",
//   //   };

//   //   request.headers.addAll(headers);
//   //   request.fields['from_user'] = widget.fromuser;
//   //   request.fields['to_user'] = widget.touser;
//   //   var response = await request.send();
//   //   print(response.statusCode);

//   //   String responseData = await response.stream.transform(utf8.decoder).join();
//   //   var userData = jsonDecode(responseData);

//   //   audioCallModel = AudioCallModel.fromJson(userData);
//   //   log(responseData);

//   //   if (response.statusCode == 200) {
//   //     join();
//   //     setState(() {
//   //       isLoading = false;
//   //     });
//   //   }
//   // }

//   Future<void> setupVoiceSDKEngine() async {
//     // retrieve or request microphone permission
//     await [Permission.microphone].request();

//     //create an instance of the Agora engine
//     agoraEngine = createAgoraRtcEngine();
//     await agoraEngine.initialize(const RtcEngineContext(
//       appId: "a6da6b51ecc1430ca4a0cb1b3b4235cb",
//       channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
//     ));

//     // Register the event handler
//     agoraEngine.registerEventHandler(
//       RtcEngineEventHandler(
//         onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
//           debugPrint("local user ${connection.localUid} joined");
//           //  showMessage("Local user uid:${connection.localUid} joined the channel");
//           setState(() {
//             _isJoined = true;
//           });
//         },
//         onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
//           debugPrint("remote user $remoteUid joined");
//           //   showMessage("Remote user uid:$remoteUid joined the channel");
//           setState(() {
//             _startCall();
//             _remoteUid = remoteUid;
//           });
//           stopAudio();
//         },
//         onUserOffline: (RtcConnection connection, int remoteUid,
//             UserOfflineReasonType reason) {
//           //  showMessage("Remote user uid:$remoteUid left the channel");
//           debugPrint("remote user $remoteUid left channel");
//           setState(() {
//             _remoteUid = null;
//             _endCall();
//           });
//           Get.off(TabbarScreen());
//         },
//         onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
//           debugPrint(
//               '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
//         },
//       ),
//     );

//     await agoraEngine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
//     await agoraEngine.enableAudio();
//     await agoraEngine.setDefaultAudioRouteToSpeakerphone(false);
//     await agoraEngine.startPreview();
//     await agoraEngine.joinChannel(
//       token: widget.token!,
//       channelId: widget.channelId!,
//       options: const ChannelMediaOptions(),
//       uid: uid,
//     );
//   }

//   void join() async {
//     // Set channel options including the client role and channel profile
//     ChannelMediaOptions options = const ChannelMediaOptions(
//       clientRoleType: ClientRoleType.clientRoleBroadcaster,
//       channelProfile: ChannelProfileType.channelProfileCommunication,
//     );

//     await agoraEngine.joinChannel(
//       token: widget.token!,
//       channelId: widget.channelId!,
//       options: options,
//       uid: uid,
//     );
//   }

//   void leave() {
//     setState(() {
//       _isJoined = false;
//       _remoteUid = null;
//     });
//     agoraEngine.leaveChannel();
//     agoraEngine.release();
//     Get.to(TabbarScreen());
//     stopAudio();
//   }

// // Clean up the resources when you leave

//   Widget _status() {
//     String statusText;

//     if (!_isJoined)
//       statusText = 'Ringing';
//     else if (_remoteUid == null)
//       statusText = 'Ringing';
//     else
//       statusText = "${formatDuration(_elapsedSeconds)}";

//     return Text(
//       statusText,
//     );
//   }

//   void stopAudio() {
//     audioPlayer.stop();
//   }
// }
