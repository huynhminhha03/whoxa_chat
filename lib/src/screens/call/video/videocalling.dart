// ignore_for_file: must_be_immutable, avoid_print, unused_local_variable

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meyaoo_new/src/global/global.dart';
import 'package:meyaoo_new/src/global/strings.dart';
import 'package:meyaoo_new/src/screens/layout/bottombar.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoCallPage extends StatefulWidget {
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
  String? callID;
  VideoCallPage({
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
    this.callID,
  });

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  // String? appId = "80eee2e8cd9647e6ad0f6a75e925e101";
  // String token =
  //     "007eJxTYMjjaPmy+WVN+7wzAe+22xQnFN0zq+ERPb1TS+v2ZHmb2ZUKDBbmFiYpxhaGqYnmqSYWSUaWRqbGhsbGRqnGliZmyebJ0xk/pzYEMjII/1RgZmSAQBCfiaHEkIEBAAbAHZM=";
  // // "007eJxTYPjjPE3y0ByJS75mq+qtJe9Oq1EXXfGMwdH0/ubWuY//9txWYLAwSE1NNUq1SE6xNDMxTzVLTDFIM0s0N021NDJNNTQwtOc9ltoQyMjAeb2WlZEBAkF8VoaS1OISYwYGAJfgIBY5";
  // String channel = widget.fromChannelId!;
  String? fromChannelId;
  String? fromToken;
  bool? isCaller;
  int? _remoteUid;
  bool _localUserJoined = false;
  late RtcEngine _engine;

  bool enableVideo = true;
  bool enableAudio = true;
  bool enableVolume = true;
  // bool enableVolume = true;

  @override
  void initState() {
    super.initState();
    isCaller = widget.isCaller;
    fromChannelId = widget.fromChannelId;
    fromToken = widget.fromToken;
    print("widget.fromChannelId::$fromChannelId");
    print("widget.fromToken::$fromToken");
    // print("widget.videoCallModel!.channel::${widget.videoCallModel.channel}");
    // print("widget.videoCallModel!.token::${widget.videoCallModel!.token}");
    initAgora();
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

  cutCallToUserApi(String callCUT) async {
    var uri = Uri.parse('${baseUrl()}CutCall');
    var request = http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };

    request.headers.addAll(headers);
    request.fields['from_user'] = Hive.box(userdata).get(userId);
    request.fields['to_user'] = widget.reciverId!;
    request.fields['type'] = "video_call";
    request.fields['call_id'] = widget.callID!;
    request.fields['call_check'] = callCUT;
    var response = await request.send();
    print(response.statusCode);

    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = jsonDecode(responseData);

    log("TO_SIDE:${request.fields}");
    log("TO_SIDE:$responseData");

    if (response.statusCode == 200) {
      setState(() {});
      endCall();
    }
  }

  cutCallFromApi(String callCUT) async {
    var uri = Uri.parse('${baseUrl()}CallCutFromUser');
    var request = http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };

    request.headers.addAll(headers);
    request.fields['from_user'] = Hive.box(userdata).get(userId);
    request.fields['to_user'] = widget.reciverId!;
    request.fields['type'] = "video_call";
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
                  isCaller == true
                      ? Positioned(
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
                        )
                      : widget.isReciverWait == true
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
              child: isCaller == true
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
                                  ? Icons.volume_up_rounded
                                  : Icons.volume_off_rounded,
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
                              enableVolume == true
                                  ? Icons.mic_none_outlined
                                  : Icons.mic_off_outlined,
                              size: 27.0,
                              color: chatColor,
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
                              color: chatColor,
                            ),
                          ),
                        ),
                        RawMaterialButton(
                          elevation: 0,
                          onPressed: () async {
                            if (_remoteUid == null) {
                              cutCallFromApi("1");
                              endCall();
                            } else {
                              cutCallFromApi("0");
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
                                audioEnableDisable();
                              },
                              shape: const CircleBorder(),
                              fillColor: Colors.grey.shade200,
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Icon(
                                  enableAudio == true
                                      ? Icons.volume_up_rounded
                                      : Icons.volume_off_rounded,
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
                                  enableVolume == true
                                      ? Icons.mic_none_outlined
                                      : Icons.mic_off_outlined,
                                  size: 27.0,
                                  color: chatColor,
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
                                cutCallToUserApi("0");
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
                                    if (_remoteUid == null) {
                                      cutCallToUserApi("1");
                                      endCall();
                                    } else {
                                      cutCallToUserApi("0");
                                      endCall();
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
                                        SizedBox(height: 15),
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
      ),
    );
  }

  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: fromChannelId),
        ),
      );
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
                            border: Border.all(width: 2, color: Colors.white),
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
                        const SizedBox(height: 20),
                        Text(
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
                      ],
                    ),
                  ),
                ),
              ],
            );
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
    if (enableAudio == true) {
      await _engine.muteRemoteAudioStream(mute: true, uid: _remoteUid!);
      setState(() {
        enableAudio = false;
      });
    } else {
      // await _engine.enableAudio();
      await _engine.muteRemoteAudioStream(mute: false, uid: _remoteUid!);
      setState(() {
        enableAudio = true;
      });
    }
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
    // ignore: use_build_context_synchronously
    Get.off(TabbarScreen());
  }
}
