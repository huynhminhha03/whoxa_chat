// ignore_for_file: must_be_immutable, depend_on_referenced_packages, constant_identifier_names, avoid_print, non_constant_identifier_names

// // ignore_for_file: avoid_print, use_build_context_synchronously
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart' as getx;
import 'package:meyaoo_new/main.dart';
import 'package:meyaoo_new/src/global/global.dart';
import 'package:peerdart/peerdart.dart';
import 'package:uuid/uuid.dart';

class VideoCallScreen extends StatefulWidget {
  String? roomID;
  String? conversation_id;
  VideoCallScreen({super.key, this.roomID, this.conversation_id});

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

  // RTCVideoRenderer remoteRenderer = RTCVideoRenderer();
  // RTCVideoRenderer remote2Renderer = RTCVideoRenderer();

  // late RTCPeerConnection _peerConnection;
  String? peerid;
  bool inCall = false;
  bool isScreenBig = true;

  @override
  void initState() {
    super.initState();

    _initializeRenderers();

    // _initSocket();
  }

  Future<void> _initializeRenderers() async {
    await localRenderer.initialize();
    print("ROOMID ${widget.roomID}");
    await _initPeer();
  }

  // static const CLOUD_HOST = "192.168.0.17";
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

  // final List<RTCVideoRenderer> _remoteRenderers = [];
  // _createPeerConnection() async {
  //   final configuration = {
  //     'iceServers': [
  //       {'urls': 'stun:stun.l.google.com:19302'},
  //       {
  //         'urls': 'turn:192.168.0.14:4001',
  //         'username': 'peerjs',
  //         'credential': 'peerjsp',
  //       }
  //     ],
  //   };
  //   final peerConnection = await createPeerConnection(configuration);
  //   // print("join room success ${peerConnection.connectionState}");
  //   peerConnection.onIceCandidate = (candidate) {
  //     print("join room success");
  //     socketIntilized.socket!
  //         .emit("join-room", {widget.roomID, candidate.candidate});
  //   };
  //   peerConnection.onTrack = (event) {
  //     print("join room success ${peerConnection.connectionState}");

  //     // if (event.track.kind == 'video') {
  //     //   final renderer = RTCVideoRenderer();
  //     //   _remoteRenderers.add(renderer);
  //     //   renderer.initialize();
  //     //   renderer.srcObject = event.streams[0];
  //     //   setState(() {});
  //     // }
  //   };
  //   // return peerConnection;
  // }

  Future<void> _initPeer() async {
    try {
      myPeer = Peer(
        id: const Uuid().v4(),
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
    // myPeer!.on<MediaConnection>().listen((event) {

    // });
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
        // call.on("close").listen((event) {
        //   setState(() {
        //     inCall = false;
        //   });
        // });

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
        });
      });
      socketIntilized.socket!.on(
        "user-connected-to-call",
        (userId) {
          print("PEERID☺☺☺☺☺☺☺ remote: $userId");
          connectNewUser(userId, mediaStream);
        },
      );
    });
    socketIntilized.socket!.on(
        "user-disconnected-from-call",
        (userId) => {
              print("disconnected  $userId"),
              if (peers[userId] != null)
                {
                  print("disconnected userid $userId"),
                  peers[userId]!.close(),
                  if (remoteRenderers[userId] != null)
                    {
                      remoteRenderers[userId]!.dispose(),
                      remoteRenderers.remove(userId),
                    },
                  setState(() {}),
                  print("disconnected peers[userId] ${peers[userId]}"),
                  print("remoteRenderers length ${remoteRenderers.length}"),
                }
            });
  }

  // navigator.mediaDevices
  //     .getUserMedia({'video': true, 'audio': true}).then((stream) {
  //   localRenderer.srcObject = stream;
  //   print('my stream $stream');
  //   setState(() {});
  //   myPeer!.on("call", context, (ev, context) {
  //     print("call from ${ev.eventData} to $peerid");
  //     MediaConnection call = ev as MediaConnection;
  //     call.answer(stream);
  //     call.on("stream", context, (userVideoStream, context) {
  //       remoteRenderer.srcObject = userVideoStream as MediaStream;
  //       setState(() {});
  //     });
  //   });
  //   socketIntilized.socket!.on(
  //     "user-connected",
  //     (userId) {
  //       print("PEERID☺☺☺☺☺☺☺ remote: $userId");
  //       connectNewUser(userId, stream);
  //     },
  //   );
  // });

  // connectNewUser(userId, stream) {
  //   print('new connected user...');
  //   print('new connected userid $userId');
  //   print('new connected stream $stream');
  //   MediaConnection call = myPeer!.call(userId, stream);
  //   setState(() {});
  //   call.on("stream", context, (userVideoStream, context) {
  //     print('new user stream...');
  //     setState(() {
  //       remote2Renderer.srcObject = userVideoStream as MediaStream;
  //     });
  //   });
  //   call.on("close", context, (ev, context) {
  //     remoteRenderer.srcObject = null;
  //     setState(() {});
  //   });
  //   peers[userId] = call;
  // }

  // _startLocalStream();

  // // Handle incoming calls
  //  peer!.on('call', context, (event, context) {
  //   final MediaConnection call = event as MediaConnection;
  //   call.answer(localStream!);
  //   call.on('stream', context, (stream, context) {
  //     final MediaStream remoteStream = stream as MediaStream;
  //     setState(() {
  //       this.remoteStream = remoteStream;
  //       remoteRenderer.srcObject = remoteStream;
  //     });
  //   });
  // });

  // peer!.on('error', context, ((error, _) {
  //   print("ERROR CHECK:${error.eventData}");
  // }));

  // Future<void> _startLocalStream() async {
  //   try {
  //     localStream = await navigator.mediaDevices
  //         .getUserMedia({'video': true, 'audio': true});
  //     setState(() {
  //       localRenderer.srcObject = localStream;
  //     });
  //     _startCall('remote-peer-id');
  //   } catch (e) {
  //     print('Error accessing media devices: $e');
  //   }
  // }

  // Future<void> _startCall(String userId) async {
  //   localStream = await navigator.mediaDevices
  //       .getUserMedia({'video': true, 'audio': true});
  //   localRenderer.srcObject = localStream;

  //   // Replace 'remote-peer-id' with the actual remote peer ID
  //   final call = myPeer!.call(userId, localStream!);
  //   call.on('stream', context, ((stream, context) {
  //     final MediaStream st = stream as MediaStream;
  //     setState(() {
  //       remoteStream = st;
  //       remoteRenderer.srcObject = remoteStream;
  //       inCall = true; // Set the call state
  //     });
  //   }));
  //   setState(() {
  //     connection = call; // Store the current call
  //   });
  // }

  // void _endCall() {
  //   // Consider adding logic to close or hang up the connection
  //   // Close the peer connection
  //   // Close the peer connection if it exists
  //   if (call != null) {
  //     call!.close(); // Close the current call
  //     setState(() {
  //       remote2Renderer.srcObject = null;
  //       remoteStream = null;
  //       call = null;
  //       localRenderer.srcObject = null;
  //       localStream = null;
  //       inCall = false;
  //     });
  //     print('conection_closed');
  //     getx.Get.back();
  //   } else {
  //     setState(() {
  //       localRenderer.srcObject = null;
  //       localStream = null;
  //       inCall = false;
  //     });
  //     print('conection_closed');
  //     getx.Get.back();
  //   }
  // }

  void _endCall() {
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

  // void _toggleMicrophone() {
  //   final audioTracks = localStream?.getAudioTracks();
  //   if (audioTracks != null && audioTracks.isNotEmpty) {
  //     setState(() {
  //       audioTracks[0].enabled = !audioTracks[0].enabled;
  //     });
  //   }
  // }

  // void _toggleCamera() {
  //   final videoTracks = localStream?.getVideoTracks();
  //   if (videoTracks != null && videoTracks.isNotEmpty) {
  //     setState(() {
  //       videoTracks[0].enabled = !videoTracks[0].enabled;
  //     });
  //   }
  // }

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
            forTwo(),
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
                        Image.asset(
                          "assets/icons/camera_off.png",
                          height: 60,
                          width: 60,
                        ),
                        Image.asset(
                          "assets/icons/mice_on.png",
                          height: 60,
                          width: 60,
                        ),
                        Image.asset(
                          "assets/icons/volume_on.png",
                          height: 60,
                          width: 60,
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
                        localRenderer,
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
                        localRenderer,
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
                        localRenderer,
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
                        localRenderer,
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
                    localRenderer,
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
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  child: RTCVideoView(
                    localRenderer,
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
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  child: RTCVideoView(
                    localRenderer,
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
              mirror: true,
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
