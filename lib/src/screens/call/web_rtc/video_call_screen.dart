// ignore_for_file: non_constant_identifier_names, must_be_immutable, avoid_print, library_prefixes, depend_on_referenced_packages, constant_identifier_names, use_build_context_synchronously

// import 'package:flutter/material.dart';
// import 'package:meyaoo_new/main.dart';
// import 'package:peerdart/peerdart.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:socket_io_client/socket_io_client.dart';

// class CallExample extends StatefulWidget {
//   String? roomID;
//   String? conversation_id;
//   CallExample({super.key, this.roomID, this.conversation_id});

//   @override
//   State<CallExample> createState() => _CallExampleState();
// }

// class _CallExampleState extends State<CallExample> {
//   final TextEditingController _controller = TextEditingController();
//   final Peer peer = Peer(
//       options: PeerOptions(
//           port: 4001,
//           host: '62.72.36.245',
//           path: '/',
//           secure: false,
//           debug: LogLevel.All));
//   final _localRenderer = RTCVideoRenderer();
//   final _remoteRenderer = RTCVideoRenderer();
//   bool inCall = false;
//   String? peerId;

//   @override
//   void initState() {
//     super.initState();
//     _localRenderer.initialize();
//     _remoteRenderer.initialize();

//     peer.on('open', context, ((id, _) {
//       setState(() {
//         peerId = peer.id;
//       });
//       print("PEERID☺☺☺☺☺☺☺:$peerId");
//       // Emit the peer ID to the socket
//       socketIntilized.socket!.emit("join-room", {widget.roomID, id});
//     }));

//     peer.on("call", context, (event, context) async {
//       final mediaStream = await navigator.mediaDevices
//           .getUserMedia({"video": true, "audio": false});

//       call.answer(mediaStream);

//       call.on("close").listen((event) {
//         setState(() {
//           inCall = false;
//         });
//       });

//       call.on<MediaStream>("stream").listen((event) {
//         _localRenderer.srcObject = mediaStream;
//         _remoteRenderer.srcObject = event;

//         setState(() {
//           inCall = true;
//         });
//       });
//     });
//   }

//   @override
//   void dispose() {
//     peer.dispose();
//     _controller.dispose();
//     _localRenderer.dispose();
//     _remoteRenderer.dispose();
//     super.dispose();
//   }

//   void connect() async {
//     final mediaStream = await navigator.mediaDevices
//         .getUserMedia({"video": true, "audio": false});

//     final conn = peer.call(_controller.text, mediaStream);

//     conn.on("close").listen((event) {
//       setState(() {
//         inCall = false;
//       });
//     });

//     conn.on<MediaStream>("stream").listen((event) {
//       _remoteRenderer.srcObject = event;
//       _localRenderer.srcObject = mediaStream;

//       setState(() {
//         inCall = true;
//       });
//     });

//     // });
//   }

//   void send() {
//     // conn.send('Hello!');
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               _renderState(),
//               const Text(
//                 'Connection ID:',
//               ),
//               SelectableText(peerId ?? ""),
//               TextField(
//                 controller: _controller,
//               ),
//               ElevatedButton(onPressed: connect, child: const Text("connect")),
//               ElevatedButton(
//                   onPressed: send, child: const Text("send message")),
//               if (inCall)
//                 Expanded(
//                   child: RTCVideoView(
//                     _localRenderer,
//                   ),
//                 ),
//               if (inCall)
//                 Expanded(
//                   child: RTCVideoView(
//                     _remoteRenderer,
//                   ),
//                 ),
//             ],
//           ),
//         ));
//   }

//   Widget _renderState() {
//     Color bgColor = inCall ? Colors.green : Colors.grey;
//     Color txtColor = Colors.white;
//     String txt = inCall ? "Connected" : "Standby";
//     return Container(
//       decoration: BoxDecoration(color: bgColor),
//       child: Text(
//         txt,
//         style:
//             Theme.of(context).textTheme.titleLarge?.copyWith(color: txtColor),
//       ),
//     );
//   }
// }

// // ignore_for_file: avoid_print, use_build_context_synchronously
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
      // Emit the myPeer ID to the socket
      socketIntilized.socket!.emit("test");
      // Emit the myPeer ID to the socket
      socketIntilized.socket!.emit("join-call", {
        "room_id": "ff3aae8b-bea3-4f92-a008-24d6816f1eb2",
        "user_id": event
      });
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
        // localRenderer.srcObject = mediaStream;
      });

      call.on("close").listen((onData) {
        print("call closed");
        if (remoteRenderers[userId] != null) {
          remoteRenderers[userId]!.dispose();
          remoteRenderers.remove(userId);
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
            Column(
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
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(5),
                    ),
                    child: RTCVideoView(
                      remoteRenderers[remoteRenderers.keys.elementAt(0)]!,
                      mirror: true,
                      objectFit:
                          RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    ),
                  ),
                ),
                // Expanded(
                //   child: GridView.builder(
                //     gridDelegate:
                //         const SliverGridDelegateWithFixedCrossAxisCount(
                //       crossAxisCount: 2,
                //     ),
                //     itemCount: remoteRenderers.length,
                //     itemBuilder: (context, index) {
                //       print("remoteRenderers length ${remoteRenderers.length}");

                //       String key = remoteRenderers.keys.elementAt(index);
                //       return SizedBox(
                //           height: 300,
                //           child: RTCVideoView(remoteRenderers[key]!,
                //               mirror: true));
                //     },
                //   ),
                // ),
              ],
            ),

            // Positioned.fill(
            //   child: isScreenBig
            //       ? RTCVideoView(remoteRenderer)
            //       : RTCVideoView(localRenderer, mirror: true),
            // ),
            // Positioned(
            //   bottom: 20,
            //   right: 20,
            //   width: 100,
            //   height: 150,
            //   child: isScreenBig
            //       ? RTCVideoView(localRenderer, mirror: true)
            //       : RTCVideoView(remoteRenderer),
            // ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: appColorWhite.withOpacity(0.36),
                  borderRadius: BorderRadius.circular(38),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // IconButton(
                    //   icon: const Icon(Icons.call),
                    //   onPressed: () => _startCall(
                    //       'remote-peer-id'), // Replace with actual remote peer ID
                    // ),
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
                  ],
                ).paddingSymmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
