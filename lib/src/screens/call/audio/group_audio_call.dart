// ignore_for_file: avoid_print, must_be_immutable, prefer_final_fields

import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meyaoo_new/src/global/global.dart';
import 'package:meyaoo_new/src/screens/layout/bottombar.dart';
import 'package:permission_handler/permission_handler.dart';

const String appId = "a6da6b51ecc1430ca4a0cb1b3b4235cb";

class GroupVoiceCall extends StatefulWidget {
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
  GroupVoiceCall({
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
  });

  @override
  State<GroupVoiceCall> createState() => _GroupVoiceCallState();
}

class _GroupVoiceCallState extends State<GroupVoiceCall> {
  // ignore: unused_field
  // int? _remoteUid = 0;
  Map<int, bool> _remoteUids = {};
  // ignore: unused_field
  bool _localUserJoined = false;
  late RtcEngine _engine;
  String? fromChannelId;
  String? fromToken;

  bool enableAudio = true;
  bool enableSpeaker = false;

  bool _isTimerRunning = false;
  int _secondsElapsed = 0;

  int _uid = 0;

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
            _remoteUids[remoteUid] = false; // Initialize with false
            if (!_isTimerRunning) {
              startTimer();
            }
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          debugPrint("remote user $remoteUid left channel");
          setState(() {
            _remoteUids.remove(remoteUid); // Remove the user from the map
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

    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );

    await _engine.joinChannel(
      token: "$fromToken",
      channelId: "$fromChannelId",
      uid: _uid,
      options: options,
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
                                    _remoteUids.isNotEmpty
                                        ? const SizedBox()
                                        : const SizedBox(height: 10),
                                    _remoteUids.isNotEmpty
                                        ? const SizedBox()
                                        : const Text(
                                            'is Audio Calling...',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                    const SizedBox(height: 10),
                                    _remoteUids.isNotEmpty
                                        ? Text(
                                            formatTime(_secondsElapsed),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                            ),
                                          )
                                        : const SizedBox(),
                                    _remoteUids.isNotEmpty
                                        ? Text(
                                            'Joined: ${_remoteUids.length + 1}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                            ),
                                          )
                                        : const SizedBox(),
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
                                          placeholder: (context, url) =>
                                              Container(
                                            width: 40,
                                            height: 40,
                                            padding: const EdgeInsets.all(10.0),
                                            child:
                                                const CupertinoActivityIndicator(),
                                          ),
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
                                          ),
                                          imageUrl: widget.reciverImage!,
                                          width: 100.0,
                                          height: 100.0,
                                          fit: BoxFit.cover,
                                        )
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
                                                placeholder: (context, url) =>
                                                    Container(
                                                  width: 40.0,
                                                  height: 40.0,
                                                  padding: const EdgeInsets.all(
                                                      10.0),
                                                  child:
                                                      const CupertinoActivityIndicator(),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        const Material(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(8.0),
                                                  ),
                                                  clipBehavior: Clip.hardEdge,
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.all(0.0),
                                                    child: Icon(
                                                      Icons.person,
                                                      size: 40,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ),
                                                imageUrl: widget.reciverImage!,
                                                width: 100.0,
                                                height: 100.0,
                                                fit: BoxFit.cover,
                                              )
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
                                    _remoteUids.isNotEmpty
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
                                    _remoteUids.isNotEmpty
                                        ? Text(
                                            formatTime(_secondsElapsed),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                            ),
                                          )
                                        : const SizedBox(),
                                    _remoteUids.isNotEmpty
                                        ? Text(
                                            'Joined: ${_remoteUids.length + 1}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                            ),
                                          )
                                        : const SizedBox(),
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
                          RawMaterialButton(
                            elevation: 0,
                            onPressed: () async {
                              if (_remoteUids.isEmpty) {
                                //cutCallFromApi();
                                endCall();
                              } else {
                                endCall();
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
                                elevation: 0,
                                onPressed: () async {
                                  endCall();
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
                                      endCall();
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
        ));
  }

  endCall() async {
    for (int remoteUid in _remoteUids.keys.toList()) {
      await _engine.leaveChannel();
      await _engine.release();
      _remoteUids[remoteUid] = true; // Update the call status for this user
      _remoteUids.remove(remoteUid);
    }
    _isTimerRunning = false;
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
