// ignore_for_file: must_be_immutable, depend_on_referenced_packages, constant_identifier_names, avoid_print, non_constant_identifier_names

// // ignore_for_file: avoid_print, use_build_context_synchronously
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart' as getx;
import 'package:hive/hive.dart';
import 'package:meyaoo_new/controller/call_controller.dart/get_roomId_controller.dart';
import 'package:meyaoo_new/main.dart';
import 'package:meyaoo_new/src/global/common_widget.dart';
import 'package:meyaoo_new/src/global/global.dart';
import 'package:meyaoo_new/src/global/strings.dart';
import 'package:peerdart/peerdart.dart';
import 'package:uuid/uuid.dart';

class VideoCallScreen extends StatefulWidget {
  String? roomID;
  String conversation_id;
  bool isCaller = false;
  VideoCallScreen(
      {super.key,
      this.roomID,
      required this.conversation_id,
      this.isCaller = false});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  Peer? myPeer;
  Map<String, MediaConnection> peers = {};
  // MediaStream? localStream;
  // MediaStream? remoteStream;
  RTCVideoRenderer localRenderer = RTCVideoRenderer();
  // List<RTCVideoRenderer> remoteRenderer = [];
  final Map<String, RTCVideoRenderer> remoteRenderers = {};

  final RoomIdController roomIdController = getx.Get.put(RoomIdController());

  // RTCVideoRenderer remoteRenderer = RTCVideoRenderer();
  // RTCVideoRenderer remote2Renderer = RTCVideoRenderer();

  // late RTCPeerConnection _peerConnection;
  String? peerid;
  bool inCall = false;
  bool isScreenBig = true;
  bool isReciverConnect = false;
  bool isCallCutByMe = false;

  @override
  void initState() {
    super.initState();
    _initializeRenderers();
  }

  Future<void> _initializeRenderers() async {
    await localRenderer.initialize();
    print("ROOMID ${widget.roomID}");
    await _initPeer();
  }

  static const CLOUD_HOST = "62.72.36.245";
  static const CLOUD_PORT = 4001;
  // ignore: unused_field
  static const defaultConfig = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {
        'urls': "turn:62.72.36.245:4001",
        'username': "peerjs",
        'credential': "peerjsp"
      }
    ],
  };

  Future<void> _initPeer() async {
    try {
      myPeer = Peer(
        id: "${const Uuid().v4()}/${Hive.box(userdata).get(userId).toString()}",
        options: PeerOptions(
          port: CLOUD_PORT,
          host: CLOUD_HOST,
          secure: false,
          path: '/',
          // config: defaultConfig,
          // pingInterval: 50,
        ),
      );
    } catch (e) {
      print('Unhandled exception in _initPeer: $e');
    }

    myPeer!.on("open").listen((event) {
      setState(() {
        peerid = event.toString();
      });
      print("PEERID☺☺☺☺☺☺☺:$event");
      socketIntilized.socket!
          .emit("join-call", {"room_id": widget.roomID, "user_id": event});
    });

    connectNewUser(userId, MediaStream mediaStream) async {
      print('new connected userid $userId');
      print('new connected stream $mediaStream');

      final call = myPeer!.call(userId, mediaStream);
      print('new connected user... ${call.connectionId}');

      call.on<MediaStream>("stream").listen((stream) async {
        print("call.peer ${call.peer}");
        if (!remoteRenderers.containsKey(call.peer)) {
          RTCVideoRenderer renderer = RTCVideoRenderer();
          await renderer.initialize();
          setState(() {
            remoteRenderers[call.peer] = renderer;
          });
        }
        remoteRenderers[userId]!.srcObject = stream;
        print("remoteStream $stream");
        print("remoteRenderers length ${remoteRenderers.length}");
      });

      call.on("close").listen((onData) {
        print("call closed");
        if (remoteRenderers[userId] != null) {
          remoteRenderers[userId]!.dispose();
          remoteRenderers.remove(userId);
          print("remoteRenderers length ${remoteRenderers.length}");
        }
      });

      peers[userId] = call;
      print("peers $peers");
    }

    navigator.mediaDevices
        .getUserMedia({"video": true, "audio": true}).then((mediaStream) {
      localRenderer.srcObject = mediaStream;
      print('my stream $mediaStream');

      myPeer!.on<MediaConnection>("call").listen((call) {
        print("call from ${call.peer} to $peerid");
        print('my stream $mediaStream');
        call.answer(mediaStream);

        call.on<MediaStream>("stream").listen((remoteStream) async {
          // remoteRenderer.srcObject = remoteStream;
          if (!remoteRenderers.containsKey(call.peer)) {
            RTCVideoRenderer renderer = RTCVideoRenderer();

            await renderer.initialize();
            setState(() {
              remoteRenderers[call.peer] = renderer;
            });
          }
          setState(() {
            remoteRenderers[call.peer]!.srcObject = remoteStream;
          });
          print("remoteRenderers length ${remoteRenderers.length}");
          print("remoteStream $remoteStream");
        });
        print("call peer ${call.peer}");
        peers[call.peer] = call;
      });
      socketIntilized.socket!.on(
        "user-connected-to-call",
        (userId) {
          print("PEERID☺☺☺☺☺☺☺ remote: $userId");
          connectNewUser(userId, mediaStream);
          isReciverConnect = true;
          // setState(() {});
        },
      );
    });

    socketIntilized.socket!.on(
        "user-disconnected-from-call",
        (userId) => {
              print("disconnected  $userId"),
              print("peers $peers"),
              if (peers[userId] != null)
                {
                  print("disconnected userid $userId"),
                  peers[userId]!.close(),
                  if (remoteRenderers[userId] != null)
                    {
                      remoteRenderers[userId]!.dispose(),
                      remoteRenderers.remove(userId),
                      if (remoteRenderers.isEmpty)
                        {
                          getx.Get.back(),
                        }
                    },
                  setState(() {}),
                  print("disconnected peers[userId] ${peers[userId]}"),
                  print("remoteRenderers length ${remoteRenderers.length}"),
                }
              else
                {
                  print("peers else $peers"),
                }
            });

    socketIntilized.socket!.on("call_decline", (data) {
      print("call_decline data : $data");
      getx.Get.back();
      setState(() {
        localRenderer.srcObject?.getTracks().forEach((track) {
          track.stop();
        });
        remoteRenderers.forEach((key, renderer) {
          renderer.dispose();
        });
        localRenderer.dispose();
        myPeer!.dispose();
      });
    });
  }

  void _endCall() {
    if (isReciverConnect == false && widget.isCaller == true) {
      print("callCutByMe calling...");
      roomIdController.callCutByMe(
          conversationID: widget.conversation_id, callType: "video_call");
    }
    socketIntilized.socket!
        .emit("leave-call", {"room_id": widget.roomID, "user_id": myPeer!.id});

    localRenderer.dispose();
    // remoteRenderer.dispose();
    remoteRenderers.forEach((key, renderer) {
      renderer.dispose();
    });

    setState(() {
      inCall = false;
    });
    getx.Get.back();
  }

  bool microphone = false;
  void _toggleMicrophone() {
    microphone = !microphone;
    localRenderer.srcObject!.getAudioTracks()[0].enabled == true
        ? localRenderer.srcObject!.getAudioTracks()[0].enabled = false
        : localRenderer.srcObject!.getAudioTracks()[0].enabled = true;
    setState(() {});
  }

  bool camera = false;
  void _toggleCamera() {
    camera = !camera;
    localRenderer.srcObject!.getVideoTracks()[0].enabled == true
        ? localRenderer.srcObject!.getVideoTracks()[0].enabled = false
        : localRenderer.srcObject!.getVideoTracks()[0].enabled = true;
    setState(() {});
  }

  bool specker = true;
  void _toggleSpecker() async {
    specker == true
        ? await Helper.setSpeakerphoneOn(false)
        : await Helper.setSpeakerphoneOn(true);
    specker = !specker;
    setState(() {});
  }

  void _toggleScreenSize() {
    setState(() {
      isScreenBig = !isScreenBig;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleScreenSize,
      child: Scaffold(
        backgroundColor: appColorBlack,
        body: Stack(
          children: [
            remoteRenderers.length == 1
                ? forTwo()
                : remoteRenderers.length == 2
                    ? forThree()
                    : remoteRenderers.length == 3
                        ? forFour()
                        : remoteRenderers.length == 4
                            ? forFive()
                            : const SizedBox(),
            Positioned(
              top: 40,
              left: 20,
              right: 20,
              child: Row(
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
                    borderRadius: const BorderRadius.all(Radius.circular(100)),
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
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(38),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: appColorWhite.withOpacity(0.36),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        callOptionsContainer(
                          image: camera == false
                              ? "assets/icons/camera_on.png"
                              : "assets/icons/camera_off.png",
                          onTap: _toggleCamera,
                        ),
                        callOptionsContainer(
                          image: microphone == false
                              ? "assets/icons/mice_off.png"
                              : "assets/icons/mice_on.png",
                          onTap: _toggleMicrophone,
                        ),
                        callOptionsContainer(
                          image:
                              // localRenderer.srcObject!
                              //             .getAudioTracks()[0]
                              //             .enabled ==
                              //         false
                              specker == false
                                  ? "assets/icons/volume_off.png"
                                  : "assets/icons/volume_on.png",
                          onTap: _toggleSpecker,
                        ),
                        GestureDetector(
                          onTap: _endCall,
                          child: Image.asset(
                            "assets/icons/call_end.png",
                            height: 60,
                            width: 60,
                          ),
                        ),
                      ],
                    ).paddingSymmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget forFive() {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                      child: RTCVideoView(
                        remoteRenderers[remoteRenderers.keys.elementAt(0)]!,
                        mirror: true,
                        objectFit:
                            RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 2,
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                      child: RTCVideoView(
                        remoteRenderers[remoteRenderers.keys.elementAt(1)]!,
                        mirror: true,
                        objectFit:
                            RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 2,
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                      child: RTCVideoView(
                        remoteRenderers[remoteRenderers.keys.elementAt(2)]!,
                        mirror: true,
                        objectFit:
                            RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 2,
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                      child: RTCVideoView(
                        remoteRenderers[remoteRenderers.keys.elementAt(3)]!,
                        mirror: true,
                        objectFit:
                            RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 110,
          // left: 20,
          right: 20,
          child: ClipRRect(
            borderRadius: const BorderRadius.all(
              Radius.circular(10),
            ),
            child: SizedBox(
              height: 110,
              width: 85,
              child: RTCVideoView(
                localRenderer,
                mirror: true,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget forFour() {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  child: RTCVideoView(
                    localRenderer,
                    mirror: true,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  ),
                ),
              ),
              const SizedBox(
                width: 2,
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  child: RTCVideoView(
                    remoteRenderers[remoteRenderers.keys.elementAt(0)]!,
                    mirror: true,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 2,
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  child: RTCVideoView(
                    remoteRenderers[remoteRenderers.keys.elementAt(1)]!,
                    mirror: true,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  ),
                ),
              ),
              const SizedBox(
                width: 2,
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  child: RTCVideoView(
                    remoteRenderers[remoteRenderers.keys.elementAt(2)]!,
                    mirror: true,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget forThree() {
    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
            child: RTCVideoView(
              localRenderer,
              mirror: true,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            ),
          ),
        ),
        const SizedBox(
          height: 2,
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  child: RTCVideoView(
                    remoteRenderers[remoteRenderers.keys.elementAt(0)]!,
                    mirror: true,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  ),
                ),
              ),
              const SizedBox(
                width: 2,
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  child: RTCVideoView(
                    remoteRenderers[remoteRenderers.keys.elementAt(1)]!,
                    mirror: true,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget forTwo() {
    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
            child: RTCVideoView(
              localRenderer,
              mirror: false,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            ),
          ),
        ),
        // remoteRenderers.isEmpty
        //     ? const SizedBox()
        //     : const SizedBox(
        //         height: 2,
        //       ),
        remoteRenderers.isEmpty
            ? const SizedBox()
            : Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  child: RTCVideoView(
                    remoteRenderers[remoteRenderers.keys.elementAt(0)]!,
                    mirror: true,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  ),
                ),
              ),
        // Expanded(
        //   child: GridView.builder(
        //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        //       crossAxisCount: 2,
        //     ),
        //     itemCount: remoteRenderers.length,
        //     itemBuilder: (context, index) {
        //       print("remoteRenderers length ${remoteRenderers.length}");

        //       String key = remoteRenderers.keys.elementAt(index);
        //       return SizedBox(
        //           height: 300,
        //           child: RTCVideoView(remoteRenderers[key]!, mirror: true));
        //     },
        //   ),
        // ),
      ],
    );
  }

  // IconButton(
  //   icon: const Icon(Icons.call_end),
  //   onPressed: _endCall,
  // ),
  // IconButton(
  //   icon: const Icon(Icons.mic),
  //   onPressed: () {},
  // ),
  // IconButton(
  //   icon: const Icon(Icons.videocam),
  //   onPressed: () {},
  // ),

  @override
  void dispose() {
    localRenderer.dispose();
    // remoteRenderer.dispose();

    remoteRenderers.forEach((key, renderer) {
      renderer.dispose();
    });
    myPeer!.dispose();
    super.dispose();
  }
}
