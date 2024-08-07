// ignore_for_file: depend_on_referenced_packages, constant_identifier_names, duplicate_ignore, avoid_print

import 'package:flutter/material.dart';
import 'package:peerdart/peerdart.dart';
import 'package:uuid/uuid.dart';

class AudioCallScreen extends StatefulWidget {
  const AudioCallScreen({super.key});

  @override
  State<AudioCallScreen> createState() => AudioCallScreenState();
}

class AudioCallScreenState extends State<AudioCallScreen> {
  @override
  void initState() {
    _initializeRenderers();
    super.initState();
  }

  Future<void> _initializeRenderers() async {
    await _initPeer();
  }

  Peer? myPeer;
  String? peerid;
  // ignore: constant_identifier_names
  static const CLOUD_HOST = "62.72.36.245";
  static const CLOUD_PORT = 4001;

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

    myPeer!.on("open").listen((event) {
      setState(() {
        peerid = event.toString();
      });
      print("PEERID☺☺☺☺☺☺☺:$event");
      // Emit the myPeer ID to the socket
      // socketIntilized.socket!.emit("test");
      // // Emit the myPeer ID to the socket
      // socketIntilized.socket!.emit("join-room",
      //     {"roomId": "f1e39a41-a656-425c-8893-f241df9f5843", "userId": event});
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
