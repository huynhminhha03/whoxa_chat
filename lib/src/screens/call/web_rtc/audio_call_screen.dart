// ignore_for_file: must_be_immutable, depend_on_referenced_packages, constant_identifier_names, avoid_print, non_constant_identifier_names

// // ignore_for_file: avoid_print, use_build_context_synchronously
import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart' as getx;
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'package:meyaoo_new/controller/call_controller.dart/get_roomId_controller.dart';
import 'package:meyaoo_new/main.dart';
import 'package:meyaoo_new/src/global/common_widget.dart';
import 'package:meyaoo_new/src/global/global.dart';
import 'package:meyaoo_new/src/global/strings.dart';
import 'package:meyaoo_new/src/screens/layout/bottombar.dart';
import 'package:peerdart/peerdart.dart';
import 'package:uuid/uuid.dart';

class AudioCallScreen extends StatefulWidget {
  String? roomID;
  String conversation_id;
  String receiverImage;
  String receiverUserName;
  bool isCaller = false;
  AudioCallScreen(
      {super.key,
      this.roomID,
      required this.conversation_id,
      required this.receiverImage,
      required this.receiverUserName,
      this.isCaller = false});

  @override
  State<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen> {
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

      if (widget.isCaller == true && _seconds == 0) {
        startTimer();
      }
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
        .getUserMedia({"video": false, "audio": true}).then((mediaStream) {
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

      if (widget.isCaller == false) {
        startTimer();
      }
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
                          if (widget.isCaller == true)
                            {
                              getx.Get.back(),
                            }
                          else
                            {
                              getx.Get.to(
                                TabbarScreen(
                                  currentTab: 0,
                                ),
                              ),
                            }
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

  // Future<void> _initPeer() async {
  //   try {
  //     myPeer = Peer(
  //       id: "${const Uuid().v4()}/${Hive.box(userdata).get(userId).toString()}",
  //       options: PeerOptions(
  //         port: CLOUD_PORT,
  //         host: CLOUD_HOST,
  //         secure: false,
  //         path: '/',
  //         // config: defaultConfig,
  //         // pingInterval: 50,
  //       ),
  //     );
  //   } catch (e) {
  //     print('Unhandled exception in _initPeer: $e');
  //   }

  //   myPeer!.on("open").listen((event) {
  //     setState(() {
  //       peerid = event.toString();
  //     });
  //     print("PEERID☺☺☺☺☺☺☺:$event");
  //     socketIntilized.socket!
  //         .emit("join-call", {"room_id": widget.roomID, "user_id": event});
  //   });

  //   connectNewUser(userId, MediaStream mediaStream) async {
  //     print('new connected userid $userId');
  //     print('new connected stream $mediaStream');

  //     final call = myPeer!.call(userId, mediaStream);
  //     print('new connected user... ${call.connectionId}');

  //     call.on<MediaStream>("stream").listen((stream) async {
  //       print("call.peer ${call.peer}");
  //       if (!remoteRenderers.containsKey(call.peer)) {
  //         RTCVideoRenderer renderer = RTCVideoRenderer();
  //         await renderer.initialize();
  //         setState(() {
  //           remoteRenderers[call.peer] = renderer;
  //         });
  //       }
  //       remoteRenderers[userId]!.srcObject = stream;
  //       startTimer();
  //       print("remoteStream $stream");
  //       print("remoteRenderers length ${remoteRenderers.length}");
  //     });

  //     call.on("close").listen((onData) {
  //       print("call closed");
  //       if (remoteRenderers[userId] != null) {
  //         remoteRenderers[userId]!.dispose();
  //         remoteRenderers.remove(userId);
  //         print("remoteRenderers length ${remoteRenderers.length}");
  //       }
  //     });

  //     peers[userId] = call;
  //     print("peers $peers");
  //   }

  //   navigator.mediaDevices
  //       .getUserMedia({"video": false, "audio": true}).then((mediaStream) {
  //     localRenderer.srcObject = mediaStream;
  //     print('my stream $mediaStream');

  //     myPeer!.on<MediaConnection>("call").listen((call) {
  //       print("call from ${call.peer} to $peerid");
  //       print('my stream $mediaStream');
  //       call.answer(mediaStream);

  //       call.on<MediaStream>("stream").listen((remoteStream) async {
  //         // remoteRenderer.srcObject = remoteStream;
  //         if (!remoteRenderers.containsKey(call.peer)) {
  //           RTCVideoRenderer renderer = RTCVideoRenderer();

  //           await renderer.initialize();
  //           setState(() {
  //             remoteRenderers[call.peer] = renderer;
  //           });
  //         }
  //         setState(() {
  //           remoteRenderers[call.peer]!.srcObject = remoteStream;
  //         });
  //         print("remoteRenderers length ${remoteRenderers.length}");
  //         print("remoteStream $remoteStream");
  //         startTimer();
  //       });
  //       print("call peer ${call.peer}");
  //       peers[call.peer] = call;
  //     });
  //     socketIntilized.socket!.on(
  //       "user-connected-to-call",
  //       (userId) {
  //         print("PEERID☺☺☺☺☺☺☺ remote: $userId");
  //         connectNewUser(userId, mediaStream);
  //         isReciverConnect = true;
  //         // setState(() {});
  //       },
  //     );
  //   });

  //   socketIntilized.socket!.on(
  //       "user-disconnected-from-call",
  //       (userId) => {
  //             print("disconnected  $userId"),
  //             print("peers $peers"),
  //             if (peers[userId] != null)
  //               {
  //                 print("disconnected userid $userId"),
  //                 peers[userId]!.close(),
  //                 if (remoteRenderers[userId] != null)
  //                   {
  //                     remoteRenderers[userId]!.dispose(),
  //                     remoteRenderers.remove(userId),
  //                     if (remoteRenderers.isEmpty)
  //                       {
  //                         getx.Get.back(),
  //                       }
  //                   },
  //                 setState(() {}),
  //                 print("disconnected peers[userId] ${peers[userId]}"),
  //                 print("remoteRenderers length ${remoteRenderers.length}"),
  //               }
  //             else
  //               {
  //                 print("peers else $peers"),
  //               }
  //           });

  //   socketIntilized.socket!.on("call_decline", (data) {
  //     print("call_decline data : $data");
  //     getx.Get.back();
  //     setState(() {
  //       localRenderer.dispose();
  //       myPeer!.dispose();
  //     });
  //   });
  // }

  void _endCall() {
    if (isReciverConnect == false && widget.isCaller == true) {
      print("callCutByMe calling...");
      roomIdController.callCutByMe(
          conversationID: widget.conversation_id, callType: "audio_call");
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
    if (widget.isCaller == true) {
      getx.Get.back();
    } else {
      getx.Get.to(
        TabbarScreen(
          currentTab: 0,
        ),
      );
    }
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

  Timer? _timer;
  int _seconds = 0;

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  String getFormattedTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$remainingSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleScreenSize,
      child: Scaffold(
        backgroundColor: appColorBlack,
        body: Stack(
          children: [
            forTwo(),

            Positioned(
                top: 145,
                left: 20,
                right: 20,
                child: Column(
                  children: [
                    Text(
                      widget.receiverUserName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                        fontFamily: "Poppins",
                      ),
                    ),
                    const SizedBox(
                      height: 9,
                    ),
                    const Text(
                      "Audio Calling",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        fontFamily: "Poppins",
                      ),
                    ),
                    const SizedBox(
                      height: 9,
                    ),
                    Text(
                      remoteRenderers.isEmpty
                          ? "00:00"
                          : getFormattedTime(_seconds),
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
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
                              imageUrl: widget.receiverImage,
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
                  ],
                )),
            // forThree(),
            // forFour(),
            // forFive(),
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

  Widget forTwo() {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: widget.receiverImage,
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
    localRenderer.srcObject!.getTracks().forEach((track) => track.stop());
    localRenderer.srcObject!.getAudioTracks().forEach((track) => track.stop());
    localRenderer.srcObject!.getVideoTracks().forEach((track) => track.stop());
    localRenderer.srcObject = null;
    localRenderer.dispose();
    // remoteRenderer.dispose();

    remoteRenderers.forEach((key, renderer) {
      renderer.srcObject!.getTracks().forEach((track) => track.stop());
      renderer.srcObject!.getAudioTracks().forEach((track) => track.stop());
      renderer.srcObject!.getVideoTracks().forEach((track) => track.stop());
      renderer.srcObject = null;
      renderer.dispose();
    });
    myPeer!.dispose();
    _timer?.cancel();
    super.dispose();
  }
}
