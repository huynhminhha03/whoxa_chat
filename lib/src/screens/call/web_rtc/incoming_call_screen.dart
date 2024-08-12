// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class IncomingCallScrenn extends StatefulWidget {
  String roomID;
  String callerImage;
  IncomingCallScrenn({
    super.key,
    required this.roomID,
    required this.callerImage,
  });

  @override
  State<IncomingCallScrenn> createState() => _IncomingCallScrennState();
}

class _IncomingCallScrennState extends State<IncomingCallScrenn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
