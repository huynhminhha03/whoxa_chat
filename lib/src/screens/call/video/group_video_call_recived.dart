// ignore_for_file: must_be_immutable, avoid_print, unused_field

import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meyaoo_new/src/screens/layout/bottombar.dart';
import 'package:permission_handler/permission_handler.dart';

class GroupReceivedVideoCallScreen extends StatefulWidget {
  // VideoCallModel? videoCallModel;
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
  GroupReceivedVideoCallScreen({
    super.key,
    // this.videoCallModel,
    this.fromChannelId,
    this.waitChannelId,
    this.fromToken,
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
  State<GroupReceivedVideoCallScreen> createState() =>
      _GroupReceivedVideoCallScreenState();
}

class _GroupReceivedVideoCallScreenState
    extends State<GroupReceivedVideoCallScreen> {
  String? fromChannelId;
  String? fromToken;
  bool? isCaller;
  bool _localUserJoined = false;
  late RtcEngine _engine;
  List<int?> _remoteUids = []; // uid of the remote user

  bool enableVideo = true;
  bool enableAudio = true;
  bool enableVolume = true;
  bool muted = false;

  DateTime? _callStartTime;
  DateTime? _callEndTime;
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _isCallActive = false;
  final List<int> _callDurations = [];

  @override
  void initState() {
    super.initState();
    isCaller = widget.isCaller;
    fromChannelId = widget.fromChannelId;
    fromToken = widget.fromToken;
    print("widget.fromChannelId::$fromChannelId");
    print("widget.fromToken::$fromToken");
    print("RECEIVED");
    // print("widget.videoCallModel!.channel::${widget.videoCallModel.channel}");
    // print("widget.videoCallModel!.token::${widget.videoCallModel!.token}");
    initAgora();
  }

  void _startCall() {
    setState(() {
      _isCallActive = true;
      _callStartTime = DateTime.now();
      _elapsedSeconds = 0;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _elapsedSeconds++;
        });
      });
    });
  }

  void _finishCall() {
    _isCallActive = false;
    _callEndTime = DateTime.now();
    _timer!.cancel();
    final callDuration = _callEndTime!.difference(_callStartTime!).inSeconds;
    _callDurations.add(callDuration);
  }

  String formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> initAgora() async {
    // retrieve permissions
    await [Permission.microphone, Permission.camera].request();

    //create the engine
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: "a6da6b51ecc1430ca4a0cb1b3b4235cb",
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));
    await _engine.enableVideo();

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onLeaveChannel: (RtcConnection connection, stats) {},
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("local user ${connection.localUid} joined");
          setState(() {
            _localUserJoined = true;
            _startCall();
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("remote user $remoteUid joined");
          setState(() {
            _remoteUids.add(remoteUid);
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          debugPrint("remote user $remoteUid left channel");
          setState(() {
            _finishCall();
            _remoteUids.remove(remoteUid);
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
    await _engine.enableVideo();
    await _engine.enableAudio();
    // await _engine.enable();
    await _engine.startPreview();

    await _engine.joinChannel(
      token: "$fromToken",
      channelId: "$fromChannelId",
      uid: 0,
      options: const ChannelMediaOptions(),
    );
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
      backgroundColor: Colors.white.withOpacity(0.2),
      // appBar: AppBar(
      //   title: const Text('Agora Video Call'),
      // ),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              child: Stack(
                children: [
                  Center(
                    child: _remoteVideo(),
                  ),
                  widget.isReciverWait == true
                      ? const SizedBox()
                      : Positioned(
                          top: 15,
                          right: 10,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              width: 110,
                              height: 150,
                              child: Center(
                                child: _localUserJoined
                                    ? AgoraVideoView(
                                        controller: VideoViewController(
                                          rtcEngine: _engine,
                                          canvas: const VideoCanvas(uid: 0),
                                        ),
                                      )
                                    : const CircularProgressIndicator(),
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(0, 14, 0, 28),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10))),
              child: widget.isReciverWait == false
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        RawMaterialButton(
                          elevation: 0,
                          onPressed: () async {
                            audioEnableDisable();
                          },
                          shape: const CircleBorder(),
                          fillColor: Colors.grey.shade200,
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Icon(
                              enableAudio == true
                                  ? Icons.volume_up_outlined
                                  : Icons.volume_off_outlined,
                              size: 27.0,
                              color: Colors.grey.shade400,
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
                              enableVolume == true
                                  ? Icons.mic_none_outlined
                                  : Icons.mic_off_outlined,
                              size: 27.0,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ),
                        RawMaterialButton(
                          elevation: 0,
                          onPressed: () async {
                            videoEnableDisable();
                          },
                          shape: const CircleBorder(),
                          fillColor: Colors.grey.shade200,
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Icon(
                              enableVideo == true
                                  ? Icons.videocam_outlined
                                  : Icons.videocam_off_outlined,
                              size: 27.0,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ),
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
                                    borderRadius: BorderRadius.circular(12)),
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
                          const SizedBox(width: 10),
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
                                    borderRadius: BorderRadius.circular(12)),
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
      ),
    );
  }

  Widget _remoteVideo() {
    if (_remoteUids.isNotEmpty) {
      return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2),
          itemCount: _remoteUids.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return AgoraVideoView(
              key: ValueKey(_remoteUids[index]),
              controller: VideoViewController.remote(
                rtcEngine: _engine,
                canvas: VideoCanvas(uid: _remoteUids[index]),
                connection: RtcConnection(channelId: fromChannelId),
              ),
            );
          });
    } else {
      return isCaller == false
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
                              placeholder: (context, url) => Container(
                                width: 40,
                                height: 40,
                                padding: const EdgeInsets.all(10.0),
                                child: const CupertinoActivityIndicator(),
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
                              imageUrl: widget.callerImage!,
                              width: 100.0,
                              height: 100.0,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              'assets/images/user1.png',
                              width: 100.0,
                              height: 100.0,
                              fit: BoxFit.cover,
                            ),
                      // borderRadius: BorderRadius.all(
                      //   Radius.circular(100.0),
                      // ),
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
                            border: Border.all(width: 2, color: Colors.white),
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
                                    placeholder: (context, url) => Container(
                                      width: 40.0,
                                      height: 40.0,
                                      padding: const EdgeInsets.all(10.0),
                                      child: const CupertinoActivityIndicator(),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Material(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8.0),
                                      ),
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
                                    imageUrl: widget.callerImage!,
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
                        const SizedBox(height: 10),
                        const Text(
                          'is Video Calling...',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : const SizedBox();
    }
  }

  videoEnableDisable() async {
    if (enableVideo == true) {
      await _engine.enableLocalVideo(false);
      setState(() {
        enableVideo = false;
      });
    } else {
      await _engine.enableLocalVideo(true);
      setState(() {
        enableVideo = true;
      });
    }
  }

  audioEnableDisable() async {
    setState(() {
      muted = !muted;
    });
    await _engine.muteLocalAudioStream(muted);
  }

  localAudioEnableDisable() async {
    if (enableVolume == true) {
      await _engine.enableLocalAudio(false);
      setState(() {
        enableVolume = false;
      });
    } else {
      await _engine.enableLocalAudio(true);
      setState(() {
        enableVolume = true;
      });
    }
  }

  endCall() async {
    await _engine.leaveChannel();
    await _engine.release();
    setState(() {
      _remoteUids = [];
      _localUserJoined = false;
    });
    // ignore: use_build_context_synchronously
    Get.off(TabbarScreen());
  }
}
