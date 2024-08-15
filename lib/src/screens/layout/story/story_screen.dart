// ignore_for_file: avoid_print, depend_on_referenced_packages, unused_field

import 'dart:async';
import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:meyaoo_new/controller/story_controller.dart';
import 'package:meyaoo_new/src/global/global.dart';
import 'package:meyaoo_new/src/global/strings.dart';
import 'package:story/story.dart';
import 'package:video_player/video_player.dart';

class StoryScreen6PM extends StatefulWidget {
  final bool isForMyStory;
  final int pageIndex;
  final int storyIndex;
  final int i;
  final String? username;
  const StoryScreen6PM(
      {super.key,
      this.isForMyStory = false,
      this.pageIndex = 0,
      this.storyIndex = 0,
      this.i = 0,
      this.username});

  @override
  State<StoryScreen6PM> createState() => _StoryScreen6PMState();
}

class _StoryScreen6PMState extends State<StoryScreen6PM> {
  StroyGetxController storyGetxController = Get.find<StroyGetxController>();
  late ValueNotifier<IndicatorAnimationCommand> indicatorAnimationController;

  // late CachedVideoPlayerController controller;

  VideoPlayerController? _controller;
  Future<void>? _initializeVideoPlayerFuture1;

  int? videoLengthInSeconds;
  loadVideoPlayer(String videoFile) async {
    log("LOAD VIDEO PLAYER");
    log("VIDEO FILE : $videoFile");
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(
        videoFile,
        // "https://meyaoo.theprimoapp.com/public/story_img/posts2024041007164415397891-hd_1080_1920_25fps.mp4",
        // "https://videos.pexels.com/video-files/20770858/20770858-sd_540_960_30fps.mp4"
        // widget.filePath,
      ),
    );
    indicatorAnimationController.value = IndicatorAnimationCommand.pause;
    final Duration duration = _controller!.value.duration;
    // setState(() {
    videoLengthInSeconds = duration.inSeconds;
    // });
    log("VIDEO LENGTH IS $videoLengthInSeconds");
    _initializeVideoPlayerFuture1 = _controller!.initialize();
    _controller!.setLooping(true);
    _controller!.play();

    // controller = VideoPlayerController.network(widget.filePath);
    // controller.addListener(() {
    //   setState(() {});
    // });
    // controller.initialize().then((value) {
    //   setState(() {});
    // });
  }

  // late VideoPlayerController controller;
  // late List<VideoPlayerController> _videoControllers;

  // late Future<void> _initializeVideoPlayerFuture;

  String formatCreateDate(String createDate) {
    DateTime now = DateTime.now();
    DateTime createDate1 = DateTime.parse(createDate);
    DateTime postDate = DateFormat("yyyy-MM-dd HH:mm:ss")
        .parse(createDate1.toLocal().toString());
    String formattedDate;

    if (now.difference(postDate).inDays == 0) {
      formattedDate = "Today, ${DateFormat.jm().format(postDate)}";
    } else if (now.difference(postDate).inDays == 1) {
      formattedDate = "Yesterday, ${DateFormat.jm().format(postDate)}";
    } else {
      formattedDate = DateFormat.yMMMMd().add_jm().format(postDate);
    }

    return formattedDate;
  }

  int? length;
  int? i;

  late VideoPlayerController controller1;
  @override
  void initState() {
    indicatorAnimationController = ValueNotifier<IndicatorAnimationCommand>(
        IndicatorAnimationCommand.resume);

    log("INDEX PAGE : ${widget.pageIndex}");
    if (!widget.isForMyStory) {
      length = storyGetxController.pageIndexValue.value == 0
          ? storyGetxController.storyListData.value.statusList!.length
          : storyGetxController.pageIndexValue.value;
      storyGetxController.pageIndexValue.value = widget.pageIndex;
      storyGetxController.storyIndexValue.value = widget.storyIndex;

      log("Page Index Value ${storyGetxController.pageIndexValue.value}");
      log("Length OF POST $length");
    }
    // setState(() {
    //   _fetchContacts();
    // });
    setState(() {});
    super.initState();
  }

  @override
  void dispose() {
    storyGetxController.pageIndexValue.value = 0;
    storyGetxController.storyIndexValue.value = 0;
    indicatorAnimationController.dispose();
    // if (controller.value.isPlaying) {
    //   controller.dispose();
    // }
    // Dispose of the video controller if it exists and is initialized
    if (_controller != null) {
      _controller!.pause(); // Pause the video before disposing
      _controller!.dispose();
    }

    // _controller.play();
    // if()
    // if (_controller.isBlank!) {
    //   log("Controller is Blank");
    // } else {
    //   _controller.dispose();
    // }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Minimum example to explain the usage.
    return
        // Obx(() {
        //   return

        Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                // for (int i = 0;
                //     i < storyGetxController.storyListData.value.post!.length;
                //     i++)
                Obx(() {
                  return StoryPageView(
                    indicatorHeight: 4,
                    backgroundColor: Colors.black,

                    onPageChanged: ((p0) {
                      log("THIS IS P0 $p0");

                      storyGetxController.pageIndexValue.value = p0;
                      storyGetxController.pageIndexValue.refresh();

                      storyGetxController.storyIndexValue.value =
                          storyGetxController
                              .storyListData
                              .value
                              .statusList![
                                  storyGetxController.pageIndexValue.value]
                              .userData!
                              .statuses!
                              .length;

                      log("STORY LENGTH ${storyGetxController.storyListData.value.statusList![storyGetxController.pageIndexValue.value].userData!.statuses!.length} ---");

                      setState(() {});
                      // storyGetxController.pageIndexValue.value++;
                      // storyGetxController.storyListData.refresh();
                    }),
                    initialPage: widget.pageIndex,
                    initialStoryIndex: (pageIndex) {
                      return 0;
                      // storyGetxController.storyIndexValue.value;
                    },
                    storyLength: (pageIndex) {
                      log("STORY LENGTH PAGEINDEX : $pageIndex");
                      log("STORY LENGTH PAGEEEEEEEE ${storyGetxController.pageIndexValue.value}");
                      return widget.isForMyStory
                          ? storyGetxController.storyListData.value.myStatus!
                              .statuses![0].statusMedia!.length
                          : storyGetxController
                              .storyListData
                              .value
                              .statusList![pageIndex]
                              .userData!
                              .statuses![0]
                              .statusMedia!
                              .length;
                    },
                    // pageLength: 1,
                    pageLength: widget.isForMyStory
                        ? storyGetxController
                            .storyListData.value.myStatus!.statuses!.length
                        : storyGetxController
                            .storyListData.value.statusList!.length,
                    // widget.pageIndex == 0
                    //     ? storyGetxController.storyListData.value.post!.length
                    //     : storyGetxController.storyListData.value.post!.length -
                    //         widget.pageIndex,
                    //  storyGetxController.storyListData.value.post!.length -
                    //     storyGetxController.pageIndexValue.value,
                    onPageLimitReached: () {
                      Get.back();
                    },

                    // initialPage: 1,
                    // initialStoryIndex: (pageIndex) {
                    //   return
                    // },
                    indicatorPadding:
                        const EdgeInsets.only(top: 50, left: 10, right: 10),
                    indicatorDuration: Duration(
                        seconds: videoLengthInSeconds == null
                            ? 15
                            : _controller!.value.duration.inSeconds),
                    indicatorAnimationController: indicatorAnimationController,
                    indicatorVisitedColor: chatownColor,
                    indicatorUnvisitedColor:
                        const Color.fromRGBO(158, 158, 158, 1),

                    itemBuilder: (context, pageIndex, storyIndex) {
                      log("ITEM BUILDER PAGE INDEX $pageIndex");
                      log("ITEM BUILDER STORY INDEX $storyIndex");

                      log('STORY PAGE INDEX VALUE !!! ${storyGetxController.pageIndexValue.value}');

                      if (widget.isForMyStory) {
                        // print(
                        //     "STORY TYPE ${storyGetxController.storyListData.value.myPost![pageIndex].storyImage![storyIndex].type}");
                        //ttttttttttttttteeeeeeeeeeeeeeemmmmmmmmmmmmmmppppppppppppp
                        // if (storyGetxController.storyListData.value.myStatus!.statuses![pageIndex]
                        //         .statusMedia![storyIndex].type ==
                        //     "video") {
                        //   if (_controller != null) {
                        //     _controller!.pause(); // Pause the video before disposing
                        //     _controller!.dispose();
                        //   }

                        //   log("TYPE IS VIDEO");
                        //   loadVideoPlayer(storyGetxController.storyListData.value
                        //       .myPost![pageIndex].storyImage![storyIndex].url!);
                        //   // _videoControllers = List.generate(
                        //   //   storyGetxController.storyListData.value.post!.length,
                        //   //   (index) => VideoPlayerController.network(
                        //   //       "https://videos.pexels.com/video-files/18724815/18724815-sd_540_960_20fps.mp4"
                        //   //       // storyGetxController.storyListData.value.post![pageIndex]
                        //   //       //     .storyImage![storyIndex].url!,
                        //   //       ),
                        //   // );
                        // }

                        log("YES FOR MY STORY");
                        log("ID IS : ${storyGetxController.storyListData.value.myStatus!.statuses![pageIndex].statusMedia![storyIndex].statusMediaId!.toString()}");
                        storyGetxController.myStorySeenListAPI(
                            storyGetxController.storyListData.value.myStatus!
                                .statuses![pageIndex].statusId!
                                .toString());
                      } else {
                        if (storyGetxController
                                .storyListData
                                .value
                                .statusList![pageIndex]
                                .userData!
                                .statuses![0]
                                .statusViews![0]
                                .statusCount! <
                            storyIndex + 1) {
                          storyGetxController.viewStoryAPI(
                              storyGetxController
                                  .storyListData
                                  .value
                                  .statusList![pageIndex]
                                  .userData!
                                  .statuses![0]
                                  .statusId!
                                  .toString(),
                              storyIndex + 1,
                              pageIndex);

                          // storyGetxController.storyListData.refresh();
                        }
                        // if (storyGetxController.storyListData.value.statusList![pageIndex]
                        //         .userData!.statuses![storyIndex].type ==
                        //     "video") {
                        //   if (_controller != null) {
                        //     _controller!.pause(); // Pause the video before disposing
                        //     _controller!.dispose();
                        //   }
                        //   log("THIS IS USER VIDEOS");
                        //   loadVideoPlayer(storyGetxController.storyListData.value
                        //       .post![pageIndex].storyImage![storyIndex].url!);
                        //   indicatorAnimationController.value =
                        //       IndicatorAnimationCommand.pause;
                        //   log("Value of indicator ${indicatorAnimationController.value}");

                        //   // _controller = VideoPlayerController.networkUrl(
                        //   //   Uri.parse(
                        //   // storyGetxController
                        //   //     .storyListData
                        //   //     .value
                        //   //     .post![storyGetxController.pageIndexValue.value]
                        //   //     .storyImage![storyGetxController.storyIndexValue.value]
                        //   //     .url!,
                        //   //   ),
                        //   // )..initialize().then((value) {
                        //   //     setState(() {});
                        //   //   });
                        //   // controller = VideoPlayerController.networkUrl(Uri.parse(
                        //   //     storyGetxController
                        //   //         .storyListData
                        //   //         .value
                        //   //         .post![storyGetxController.pageIndexValue.value]
                        //   //         .storyImage![
                        //   //             storyGetxController.storyIndexValue.value]
                        //   //         .url!));
                        //   // controller.initialize().then((value) {
                        //   //   // controller.play();
                        //   //   log("VIDEO INITIALIZED");
                        //   //   setState(() {});
                        //   //   indicatorAnimationController.value =
                        //   //       IndicatorAnimationCommand.resume;
                        //   // });

                        //   // _initializeVideoPlayerFuture = _controller.initialize();
                        //   // controller = VideoPlayerController.networkUrl(Uri.parse(
                        //   //     storyGetxController.storyListData.value.post![pageIndex]
                        //   //         .storyImage![storyIndex].url!));
                        // }
                      }

                      // pageIndex = storyGetxController.pageIndexValue.value == 0
                      //     ? 0
                      //     : storyGetxController.storyListData.value.post!.length -
                      //         storyGetxController.pageIndexValue.value;
                      // widget.pageIndex;

                      // pageIndex = storyGetxController.pageIndexValue.value;
                      // storyIndex = storyGetxController.storyIndexValue.value;
                      log("Inside Page Index : $pageIndex");
                      log("Inside Story Index : $storyIndex");

                      // setState(() {

                      // if (!widget.isForMyStory) {
                      //   storyGetxController.viewStoryAPI(storyGetxController
                      //       .storyListData
                      //       .value
                      //       .post![pageIndex]
                      //       .storyImage![storyIndex]
                      //       .storyId!
                      //       .toString());
                      // }

                      if (!widget.isForMyStory) {
                        storyGetxController.pageIndexValue.value = pageIndex;
                        storyGetxController.storyIndexValue.value = storyIndex;
                      }

                      // });

                      // if (!widget.isForMyStory) {
                      // storyGetxController.myStorySeenListAPI(storyGetxController
                      //     .storyListData
                      //     .value
                      //     .post![pageIndex]
                      //     .storyImage![storyIndex]
                      //     .storyId!
                      //     .toString());
                      // }

                      // if (widget.isForMyStory) {
                      //   if (storyGetxController.storyListData.value.myPost![0]
                      //           .storyImage![storyIndex].type ==
                      //       "video") {
                      //     // controller1 = _videoControllers[pageIndex];
                      //   }
                      // } else {
                      //   if (storyGetxController
                      //           .storyListData
                      //           .value
                      //           .post![storyGetxController.pageIndexValue.value]
                      //           .storyImage![storyGetxController.storyIndexValue.value]
                      //           .type ==
                      //       "video") {
                      //     controller1 = _videoControllers[pageIndex];
                      //   }
                      // }

                      // storyGetxController.storyListData.value.post[pageIndex].
                      return widget.isForMyStory
                          ? StoryImage(
                              /// key is required
                              key: ValueKey(
                                storyGetxController
                                    .storyListData
                                    .value
                                    .myStatus!
                                    .statuses![0]
                                    .statusMedia![storyIndex]
                                    .url!,
                              ),
                              imageProvider: CachedNetworkImageProvider(
                                storyGetxController
                                    .storyListData
                                    .value
                                    .myStatus!
                                    .statuses![0]
                                    .statusMedia![storyIndex]
                                    .url!,
                              ),
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: chatownColor,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.network_check, size: 40),
                              // fit: BoxFit.contain,
                            )
                          // CachedNetworkImage(
                          // imageUrl: storyGetxController.storyListData.value
                          //     .myPost![0].storyImage![storyIndex].url!,
                          //     progressIndicatorBuilder: (context, url, progress) {
                          //       log("Progress $progress");
                          //       if (100 == progress.downloaded) {
                          //         log("downloaded");
                          //       }
                          //       log("Progress 1 ${progress.progress}");

                          //       if (progress.downloaded == 1) {
                          //         indicatorAnimationController.value =
                          //             IndicatorAnimationCommand.resume;
                          //       } else if (progress.downloaded == 1) {
                          //         indicatorAnimationController.value =
                          //             IndicatorAnimationCommand.pause;
                          //       }

                          //       // return showModalForPause();
                          //       return const CupertinoActivityIndicator();
                          //     },
                          //   )
                          // :
                          // //  Text(
                          // //     "It's a Video",
                          // //     style: TextStyle(fontSize: 14, color: Colors.black),
                          // //   )
                          // FutureBuilder(
                          //     future: _initializeVideoPlayerFuture1,
                          //     builder: (context, snapshot) {
                          //       if (snapshot.connectionState ==
                          //           ConnectionState.waiting) {
                          //         indicatorAnimationController.value =
                          //             IndicatorAnimationCommand.pause;
                          //         return const CupertinoActivityIndicator();
                          //       } else if (snapshot.connectionState ==
                          //           ConnectionState.done) {
                          //         indicatorAnimationController.value =
                          //             IndicatorAnimationCommand.resume;
                          //         // If the VideoPlayerController has finished initialization, use
                          //         // the data it provides to limit the aspect ratio of the video.
                          //         return AspectRatio(
                          //           aspectRatio: _controller!.value.aspectRatio,
                          //           // Use the VideoPlayer widget to display the video.
                          //           child: VideoPlayer(
                          //             _controller!,
                          //           ),
                          //         );
                          //       } else {
                          //         // If the VideoPlayerController is still initializing, show a
                          //         // loading spinner.
                          //         return const Center(
                          //           child: CircularProgressIndicator(
                          //               color: chatownColor),
                          //         );
                          //       }
                          //     },
                          //   )
                          //  VideoPlayer(controller1)

                          // controller.value.isInitialized
                          //     ? AspectRatio(
                          //         aspectRatio: controller.value.aspectRatio,
                          //         child: VideoPlayer(controller))
                          //     : SizedBox(
                          //         height: Get.height,
                          //         child: const Center(
                          //             child: CircularProgressIndicator()),
                          //       )
                          // FutureBuilder(
                          //     future: _initializeVideoPlayerFuture,
                          //     builder: (context, snapshot) {
                          //       if (snapshot.connectionState ==
                          //           ConnectionState.done) {
                          //         indicatorAnimationController.value =
                          //             IndicatorAnimationCommand.resume;

                          //         // If the VideoPlayerController has finished initialization, use
                          //         // the data it provides to limit the aspect ratio of the video.
                          //         return AspectRatio(
                          //           aspectRatio: _controller.value.aspectRatio,
                          //           // Use the VideoPlayer widget to display the video.
                          //           child: VideoPlayer(_controller),
                          //         );
                          //       } else {
                          //         indicatorAnimationController.value =
                          //             IndicatorAnimationCommand.pause;

                          //         // If the VideoPlayerController is still initializing, show a
                          //         // loading spinner.
                          //         return const Center(
                          //           child: CircularProgressIndicator(),
                          //         );
                          //       }
                          //     },
                          //   )
                          // VideoProgressIndicator(
                          //     controller, //video player controller
                          //     allowScrubbing: true,
                          //     colors: const VideoProgressColors(
                          //       //video player progress bar
                          //       backgroundColor: Colors.redAccent,
                          //       playedColor: Colors.green,
                          //       bufferedColor: Colors.purple,
                          //     ))
                          : StoryImage(
                              /// key is required
                              key: ValueKey(
                                storyGetxController
                                    .storyListData
                                    .value
                                    .statusList![storyGetxController
                                        .pageIndexValue.value]
                                    .userData!
                                    .statuses![0]
                                    .statusMedia![storyGetxController
                                        .storyIndexValue.value]
                                    .url,
                              ),
                              imageProvider: CachedNetworkImageProvider(
                                storyGetxController
                                    .storyListData
                                    .value
                                    .statusList![storyGetxController
                                        .pageIndexValue.value]
                                    .userData!
                                    .statuses![0]
                                    .statusMedia![storyGetxController
                                        .storyIndexValue.value]
                                    .url!,
                              ),
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(
                                      color: chatownColor),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.network_check, size: 40),
                              // fit: BoxFit.contain,
                            );
                      // CachedNetworkImage(
                      // imageUrl: storyGetxController
                      //     .storyListData
                      //     .value
                      //     .post![storyGetxController.pageIndexValue.value]
                      //     .storyImage![
                      //         storyGetxController.storyIndexValue.value]
                      //     .url!,
                      //     progressIndicatorBuilder: (context, url, progress) {
                      //       log("Progress $progress");

                      //       if (100 == progress.downloaded) {
                      //         log("downloaded");
                      //       }
                      //       log("Progress 1 ${progress.progress}");

                      //       if (progress.downloaded == 1) {
                      //         indicatorAnimationController.value =
                      //             IndicatorAnimationCommand.resume;
                      //       } else if (progress.downloaded == 1) {
                      // indicatorAnimationController.value =
                      //     IndicatorAnimationCommand.pause;
                      //       }
                      //       // showModalForPause();
                      //       // return showModalForPause();
                      //       return const CupertinoActivityIndicator();
                      //     },
                      //   )
                      // :
                      // //  Text(
                      // //     "It's user video story",
                      // //     style: TextStyle(fontSize: 14, color: Colors.black),
                      // //   );
                      // FutureBuilder(
                      //     future: _initializeVideoPlayerFuture1,
                      //     builder: (context, snapshot) {
                      //       if (snapshot.connectionState ==
                      //           ConnectionState.waiting) {
                      //         indicatorAnimationController.value =
                      //             IndicatorAnimationCommand.pause;
                      //         return const CupertinoActivityIndicator();
                      //       } else if (snapshot.connectionState ==
                      //           ConnectionState.done) {
                      //         // setState(() {
                      //         indicatorAnimationController.value =
                      //             IndicatorAnimationCommand.resume;
                      //         // });
                      //         // If the VideoPlayerController has finished initialization, use
                      //         // the data it provides to limit the aspect ratio of the video.
                      //         return AspectRatio(
                      //           aspectRatio: _controller!.value.aspectRatio,
                      //           // Use the VideoPlayer widget to display the video.
                      //           child: VideoPlayer(
                      //             _controller!,
                      //           ),
                      //         );
                      //       } else {
                      //         // setState(() {

                      //         // });
                      //         // If the VideoPlayerController is still initializing, show a
                      //         // loading spinner.
                      //         return const Center(
                      //           child: CircularProgressIndicator(
                      //               color: chatownColor),
                      //         );
                      //       }
                      //     },
                      //   );
                      // VideoPlayer(controller1);
                      //  controller.value.isInitialized
                      //     ? AspectRatio(
                      //         aspectRatio: controller.value.aspectRatio,
                      //         child: VideoPlayer(controller))
                      //     : SizedBox(
                      //         height: Get.height,
                      //         child: const Center(
                      //             child: CircularProgressIndicator()),
                      //       );
                      //  FutureBuilder(
                      //     future: _initializeVideoPlayerFuture,
                      //     builder: (context, snapshot) {
                      //       if (snapshot.connectionState ==
                      //           ConnectionState.done) {
                      //         indicatorAnimationController.value =
                      //             IndicatorAnimationCommand.pause;
                      //         // If the VideoPlayerController has finished initialization, use
                      //         // the data it provides to limit the aspect ratio of the video.
                      //         return AspectRatio(
                      //           aspectRatio: _controller.value.aspectRatio,
                      //           // Use the VideoPlayer widget to display the video.
                      //           child: VideoPlayer(_controller),
                      //         );
                      //       } else {
                      //         // If the VideoPlayerController is still initializing, show a
                      //         // loading spinner.
                      //         indicatorAnimationController.value =
                      //             IndicatorAnimationCommand.resume;

                      //         return const Center(
                      //           child: CircularProgressIndicator(),
                      //         );
                      //       }
                      //     },
                      //   );
                      // VideoProgressIndicator(
                      //     controller, //video player controller
                      //     allowScrubbing: true,
                      //     colors: const VideoProgressColors(
                      //       //video player progress bar
                      //       backgroundColor: Colors.redAccent,
                      //       playedColor: Colors.green,
                      //       bufferedColor: Colors.purple,
                      //     ));

                      // Center(
                      //     child: Text(
                      //         "${storyGetxController.storyListData.value.post![pageIndex].storyImage![storyIndex].type} ${storyGetxController.storyListData.value.post![pageIndex].storyImage![storyIndex].storyId}"),
                      //   );
                    },

                    gestureItemBuilder: (context, pageIndex, storyIndex) {
                      pageIndex = widget.pageIndex;
                      return widget.isForMyStory
                          ? Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 32),
                                child: Obx(() {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          indicatorAnimationController.value =
                                              IndicatorAnimationCommand.pause;
                                          showModalForSeenUsersList();
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset('assets/images/eye.png',
                                                height: 20,
                                                color: Colors.white),
                                            const SizedBox(width: 3),
                                            storyGetxController
                                                        .isMyStorySeenLoading
                                                        .value ||
                                                    storyGetxController
                                                        .isAllUserStoryLoad
                                                        .value
                                                ? const SizedBox.shrink()
                                                : Text(
                                                    storyGetxController
                                                                .myStorySeenData
                                                                .value
                                                                .statusViewsList!
                                                                .isEmpty ||
                                                            storyGetxController
                                                                    .myStorySeenData
                                                                    .value
                                                                    .statusViewsList!
                                                                    .length ==
                                                                0
                                                        ? "0"
                                                        : storyGetxController
                                                            .myStorySeenData
                                                            .value
                                                            .statusViewsList!
                                                            .length
                                                            .toString(),
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        color: const Color.fromARGB(
                                            255, 46, 46, 46),
                                        icon:
                                            const Icon(Icons.keyboard_arrow_up),
                                        iconSize: 30,
                                        onPressed: () {
                                          indicatorAnimationController.value =
                                              IndicatorAnimationCommand.pause;
                                          showModalForSeenUsersList();
                                          // Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  );
                                }),
                              ),
                            )
                          : const SizedBox.shrink();
                    },
                  );
                }),
                Positioned(
                  top: 66,
                  left: 16,
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: SizedBox(
                          height: 25,
                          width: 25,
                          // decoration: const BoxDecoration(
                          //     shape: BoxShape.circle, color: Colors.black),
                          child: CachedNetworkImage(
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.person_2),
                              fit: BoxFit.cover,
                              imageUrl: widget.isForMyStory
                                  ? storyGetxController.storyListData.value
                                      .myStatus!.profileImage!
                                  : storyGetxController
                                      .storyListData
                                      .value
                                      .statusList![storyGetxController
                                          .pageIndexValue.value]
                                      .userData!
                                      .profileImage!),
                        ),
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      Material(
                        color: Colors.transparent,
                        child: Text(
                          widget.isForMyStory
                              ? "${Hive.box(userdata).get(firstName)} ${Hive.box(userdata).get(lastName)}"
                              : capitalizeFirstLetter(storyGetxController
                                  .storyListData
                                  .value
                                  .statusList![
                                      storyGetxController.pageIndexValue.value]
                                  .fullName!),
                          // "${storyGetxController.storyListData.value.post![storyGetxController.pageIndexValue.value].username}",
                          style: const TextStyle(
                              color: Colors.black, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ));
    // });
  }

  Future showModalForSeenUsersList() {
    return showDialog(
      barrierColor: const Color.fromRGBO(30, 30, 30, 0.37),
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            insetPadding: const EdgeInsets.all(8),
            alignment: Alignment.bottomCenter,
            backgroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            content: Obx(() {
              return storyGetxController.isMyStorySeenLoading.value ||
                      storyGetxController.isAllUserStoryLoad.value
                  ? SizedBox(
                      height: MediaQuery.of(context).size.height * 0.33,
                      child: const Center(
                          child:
                              CircularProgressIndicator(color: chatownColor)))
                  : storyGetxController.myStorySeenData.value.statusViewsList ==
                          null
                      ? SizedBox(
                          height: MediaQuery.of(context).size.height * 0.33,
                          child: Center(
                            child: const Text(
                              "Your Story hasn't been viewed by any users yet.",
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 14, color: Colors.black),
                            ).paddingSymmetric(horizontal: 40),
                          ),
                        )
                      : ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(18),
                            topRight: Radius.circular(18),
                          ),
                          child: Column(
                            children: [
                              // const Icon(
                              //   Icons.keyboard_arrow_down,
                              //   size: 30,
                              //   color: Colors.black,
                              // ),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                decoration:
                                    const BoxDecoration(color: chatownColor),
                                child: Text(
                                  "View By ${storyGetxController.myStorySeenData.value.statusViewsList!.length.toString()}",
                                  style: const TextStyle(
                                      fontSize: 18, color: Colors.black),
                                )
                                    .paddingSymmetric(vertical: 12)
                                    .paddingOnly(left: 15),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  itemCount: storyGetxController.myStorySeenData
                                      .value.statusViewsList!.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return ListTile(
                                      leading: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: CircleAvatar(
                                          backgroundColor: Colors.black,
                                          child: CachedNetworkImage(
                                            imageUrl: storyGetxController
                                                .myStorySeenData
                                                .value
                                                .statusViewsList![index]
                                                .user!
                                                .profileImage!,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        capitalizeFirstLetter(
                                            storyGetxController
                                                .myStorySeenData
                                                .value
                                                .statusViewsList![index]
                                                .user!
                                                .userName!),
                                        style: const TextStyle(
                                            fontSize: 15, color: Colors.black),
                                      ),
                                      subtitle: Text(
                                        formatCreateDate(storyGetxController
                                            .myStorySeenData
                                            .value
                                            .statusViewsList![index]
                                            .createdAt!),
                                        style: const TextStyle(
                                            fontSize: 13, color: Colors.grey),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
            }));
      },
    ).whenComplete(() {
      indicatorAnimationController.value = IndicatorAnimationCommand.resume;
      // controller.play();
    });
  }

  showModalForPause() {
    return showModalBottomSheet(
      context: context,
      elevation: 0,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
        topLeft: Radius.circular(18),
        topRight: Radius.circular(18),
      )),
      builder: (BuildContext context) {
        return const SizedBox();
        // });
      },
    ).whenComplete(() {
      indicatorAnimationController.value = IndicatorAnimationCommand.resume;
      // controller.play();
    });
  }
}
