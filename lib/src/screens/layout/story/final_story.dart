// ignore_for_file: depend_on_referenced_packages

import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meyaoo_new/controller/story_controller.dart';
import 'package:meyaoo_new/src/global/global.dart';
import 'package:video_player/video_player.dart';

class FinalStoryConfirmationScreen extends StatefulWidget {
  const FinalStoryConfirmationScreen({super.key});

  @override
  State<FinalStoryConfirmationScreen> createState() =>
      _FinalStoryConfirmationScreenState();
}

class _FinalStoryConfirmationScreenState
    extends State<FinalStoryConfirmationScreen> {
  StroyGetxController storyController = Get.put(StroyGetxController());

  // late VideoPlayerController _controller;
  // late Future<void> _initializeVideoPlayerFuture; // For Check In Video

  @override
  void initState() {
    // if (storyController.result.files[0].path!.endsWith('mp4')) {
    //   _controller = VideoPlayerController.file(
    //       File(storyController.result.files[0].path!));
    //   _initializeVideoPlayerFuture = _controller.initialize();
    // }

    super.initState();
  }

  @override
  void dispose() {
    if (storyController.result.files[0].path!.endsWith('mp4')) {
      // _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size(0, 0),
          child: AppBar(backgroundColor: Colors.white, elevation: 0)),
      body: Obx(() {
        return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          // (storyController.result.files[0].path!.endsWith('jpg') ||
          //         storyController.result.files[0].path!.endsWith('jpeg') ||
          //         storyController.result.files[0].path!.endsWith('png'))
          //     ?
          Expanded(
              child: Image.file(File(storyController.result.files[0].path!))),
          // : Expanded(
          //     child: GestureDetector(
          //       onTap: () {
          //         if (mounted) {
          //           setState(() {
          //             if (_controller.value.isPlaying) {
          //               _controller.pause();
          //             } else {
          //               // If the video is paused, play it.
          //               _controller.play();
          //             }
          //           });
          //         }
          //       },
          //       child: Stack(
          //         children: [
          //           FutureBuilder(
          //             future: _initializeVideoPlayerFuture,
          //             builder: (context, snapshot) {
          //               if (snapshot.connectionState ==
          //                   ConnectionState.done) {
          //                 // If the VideoPlayerController has finished initialization, use
          //                 // the data it provides to limit the aspect ratio of the video.
          //                 return Center(
          //                   child: AspectRatio(
          //                     aspectRatio: _controller.value.aspectRatio,
          //                     // Use the VideoPlayer widget to display the video.
          //                     child: VideoPlayer(_controller),
          //                   ),
          //                 );
          //               } else {
          //                 // If the VideoPlayerController is still initializing, show a
          //                 // loading spinner.
          //                 return const Center(
          //                   child: CircularProgressIndicator(
          //                     color: Colors.white,
          //                   ),
          //                 );
          //               }
          //             },
          //           ),
          //           (_controller.value.isPlaying ||
          //                   _controller.value.isBuffering)
          //               ? const SizedBox.shrink()
          //               : Container(
          //                   decoration: BoxDecoration(
          //                       color: Colors.grey.withOpacity(0.63)),
          //                   child: const Center(
          //                       child: Icon(
          //                     CupertinoIcons.play,
          //                     size: 35,
          //                   )),
          //                 ),
          //           Positioned(
          //               bottom: 0,
          //               width: MediaQuery.of(context).size.width,
          //               child: VideoProgressIndicator(
          //                 _controller,
          //                 allowScrubbing: true,
          //                 colors: VideoProgressColors(
          //                     backgroundColor:
          //                         Colors.grey.withOpacity(0.50),
          //                     bufferedColor:
          //                         Colors.blueGrey.withOpacity(0.9),
          //                     playedColor: blackcolor),
          //               )),
          //         ],
          //       ),
          //     ),
          //   ),
          storyController.isUploadStoryLoad.value
              ? SizedBox(
                  height: 50,
                  child: Center(
                    child: loader(context),
                  ),
                )
                  .paddingSymmetric(horizontal: 10)
                  .paddingOnly(top: 15, bottom: 15)
              : SizedBox(
                  height: 50,
                  width: Get.width,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: chatownColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      onPressed: () {
                        if (storyController.result.files[0].path!
                                .endsWith('jpg') ||
                            storyController.result.files[0].path!
                                .endsWith('jpeg') ||
                            storyController.result.files[0].path!
                                .endsWith('png')) {
                          storyController.addImageStory(
                              storyController.result.files[0].path!);
                        } else if (storyController.result.files[0].path!
                            .endsWith('mp4')) {
                          log("Add Story Path ${storyController.result.files[0].path!}");
                          storyController.addVideoStory(
                              storyController.result.files[0].path!);
                        }
                      },
                      child: const Text(
                        "Upload",
                        style: TextStyle(
                            fontSize: 18,
                            color: blackcolor,
                            fontWeight: FontWeight.w500),
                      )),
                )
                  .paddingSymmetric(horizontal: 10, vertical: 15)
                  .paddingOnly(top: 15, bottom: 15)
        ]);
      }),
    );
  }
}
