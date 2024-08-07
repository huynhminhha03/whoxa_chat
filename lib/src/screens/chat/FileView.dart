// ignore_for_file: file_names

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class FileView extends StatefulWidget {
  final String file;
  const FileView({super.key, required this.file});

  @override
  State<FileView> createState() => _FileViewState();
}

class _FileViewState extends State<FileView> {
  String url = "";
  @override
  void initState() {
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: SfPdfViewer.network(widget.file),
        ),
      ),
    ).paddingOnly(top: 30);
  }
}
