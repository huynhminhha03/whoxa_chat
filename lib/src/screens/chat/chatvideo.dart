// ignore_for_file: deprecated_member_use, library_private_types_in_public_api, depend_on_referenced_packages, avoid_print, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meyaoo_new/src/global/global.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:video_player/video_player.dart';

// ignore: must_be_immutable
class VideoViewFix extends StatefulWidget {
  String url;
  bool play;
  bool mute;
  String username;
  String date = "";
  VideoViewFix({
    super.key,
    required this.url,
    required this.play,
    required this.mute,
    required this.username,
    this.date = "",
  });
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<VideoViewFix>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  var scaffoldKey = GlobalKey<ScaffoldState>();

  VideoPlayerController? controller;

  Duration? duration, position;
  late AnimationController _animationController;
  bool isPlay = true;
  double videoProgress = 0.0;

  @override
  void initState() {
    init();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 600,
      ),
    );
    super.initState();
  }

  init() {
    controller = VideoPlayerController.network(widget.url)
      ..addListener(_videoListener)
      ..initialize()
      ..play()
      ..setLooping(true);
  }

  void _videoListener() {
    if (mounted) {
      setState(() {
        videoProgress = controller!.value.position.inMilliseconds /
            controller!.value.duration.inMilliseconds;
        videoProgress = videoProgress.clamp(0.0, 1.0);
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    print('didChangeAppLifecycleState CALLED ✅');
    print(state);

    switch (state) {
      case AppLifecycleState.inactive:
        setState(() {
          controller!.setVolume(0.0);
        });
        print('AppLifecycleState inactive');
        break;
      case AppLifecycleState.resumed:
        setState(() {
          controller!.setVolume(0.5);
        });
        print('AppLifecycleState resumed');
        break;
      case AppLifecycleState.paused:
        setState(() {
          controller!.setVolume(0.0);
        });
        print('AppLifecycleState paused');
        break;
      case AppLifecycleState.detached:
        setState(() {
          controller!.setVolume(0.0);
        });
        print('AppLifecycleState detached');
        break;
      case AppLifecycleState.hidden:
        print('AppLifecycleState hidden');
        break;
    }

    // if (state == AppLifecycleState.inactive &&
    //     state == AppLifecycleState.paused) {
    //   print('if called ✅');
    //   setState(() {
    //     controller.setVolume(0.0);
    //   });
    // } else {
    //   print('if called ✅');
    //   setState(() {
    //     controller.setVolume(0.5);
    //   });
    // }
  }

  // @override
  // void didUpdateWidget(VideoViewFix oldWidget) {
  //   if (widget.play == true && oldWidget.play != widget.play) {
  //     if (widget.play) {
  //       controller!.play();
  //       controller!.setLooping(true);
  //     } else {
  //       controller!.pause();
  //     }
  //   }

  //   super.didUpdateWidget(oldWidget);
  // }

  play() {
    controller!.play();
    setState(() {});
  }

  pause() {
    controller!.pause();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    controller?.removeListener(_videoListener);
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // appBar: AppBar(
      //   elevation: 0,
      //   scrolledUnderElevation: 0,
      //   backgroundColor: Colors.transparent,
      //   foregroundColor: Colors.white,
      // ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (controller!.value.isPlaying) {
            pause();
            isPlay = false;
            _animationController.reverse();
            setState(() {});
          } else {
            play();
            _animationController.animateBack(1,
                duration: const Duration(milliseconds: 500));
            Future.delayed(const Duration(milliseconds: 500), () {
              isPlay = true;
              setState(() {});
            });
          }
        },
        child: Container(
          color: Colors.transparent,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              controller!.value.isInitialized
                  ? controller!.value.aspectRatio < 1
                      ? FittedBox(
                          fit: BoxFit.cover,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: SizedBox(
                            width: controller!.value.size.width,
                            height: controller!.value.size.height,
                            child: Center(
                              child: AspectRatio(
                                  aspectRatio: controller!.value.aspectRatio,
                                  // child:
                                  //  VisibilityDetector(
                                  //     key: Key(DateTime.now()
                                  //         .microsecondsSinceEpoch
                                  //         .toString()),
                                  //     onVisibilityChanged:
                                  //         (VisibilityInfo info) {
                                  //       if (isPlay == true) {
                                  //         debugPrint(
                                  //             "${info.visibleFraction} of my widget is visible");
                                  //         if (info.visibleFraction <= 0.70) {
                                  //           if (controller != null)
                                  //             controller!.pause();
                                  //         } else {
                                  //           if (controller != null)
                                  //             controller!.play();
                                  //         }
                                  //       } else {
                                  //         pause();
                                  //       }
                                  //     },
                                  child: VideoPlayer(controller!)
                                  // )
                                  ),
                            ),
                          ),
                        )
                      : Center(
                          child: AspectRatio(
                            // aspectRatio: 3,
                            aspectRatio: controller!.value.aspectRatio,
                            child: VideoPlayer(controller!),
                          ),
                        )
                  : Center(
                      child: loader(context),
                    ),
              isPlay == true
                  ? const SizedBox()
                  : Center(
                      child: Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: blackcolor.withOpacity(0.46)),
                        child: AnimatedIcon(
                          progress: _animationController,
                          icon: AnimatedIcons.play_pause,
                          color: WhiteColor,
                          size: 35,
                        ).paddingAll(15),
                      ),
                    ),
              // Positioned(
              //   right: 8,
              //   top: 5,
              //   child: Padding(
              //     padding: const EdgeInsets.only(top: 20, right: 20),
              //     child: Text(
              //       // "${controller!.value.position.inMinutes}:${controller!.value.position.inSeconds}",
              //       [
              //         // controller!.value.position.inMinutes,
              //         controller!.value.duration.inMinutes,
              //         controller!.value.duration.inSeconds,
              //         // controller!.value.position.inSeconds
              //       ]
              //           .map((seg) =>
              //               seg.remainder(60).toString().padLeft(2, '0'))
              //           .join(':'),

              //       style: const TextStyle(color: Colors.white),
              //     ),
              //   ),
              // ),

              Positioned(
                left: 25,
                top: 50,
                child: Row(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        Get.back();
                      },
                      child: const Icon(
                        // CupertinoIcons.back,
                        Icons.arrow_back_ios,
                        color: appColorWhite,
                      ),
                    ),
                    const SizedBox(
                      width: 9,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.username,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          widget.date,
                          style: const TextStyle(
                            color: Color(0xFFCCCCCC),
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                // left: 25,
                bottom: 50,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      // "${controller!.value.position.inMinutes}:${controller!.value.position.inSeconds}",
                      [
                        controller!.value.position.inMinutes,
                        // controller!.value.duration.inMinutes,
                        // controller!.value.duration.inSeconds,
                        controller!.value.position.inSeconds
                      ]
                          .map((seg) =>
                              seg.remainder(60).toString().padLeft(2, '0'))
                          .join(':'),

                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(
                      width: 7,
                    ),
                    Expanded(
                      child: LinearPercentIndicator(
                        percent: videoProgress,
                        // width: Get.width,
                        animation: true,
                        animationDuration: 500,
                        backgroundColor: Colors.white.withOpacity(0.15),
                        progressColor: appColorYellow,
                        barRadius: const Radius.circular(2),
                        curve: Curves.linear,
                        restartAnimation: false,
                        animateFromLastPercent: true,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(
                      width: 7,
                    ),
                    Text(
                      // "${controller!.value.position.inMinutes}:${controller!.value.position.inSeconds}",
                      [
                        // controller!.value.position.inMinutes,
                        controller!.value.duration.inMinutes,
                        controller!.value.duration.inSeconds,
                        // controller!.value.position.inSeconds
                      ]
                          .map((seg) =>
                              seg.remainder(60).toString().padLeft(2, '0'))
                          .join(':'),

                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              // Positioned.fill(
              //   child: Container(
              //     decoration: BoxDecoration(
              //       gradient: LinearGradient(
              //         begin: Alignment.bottomCenter,
              //         end: Alignment.center,
              //         colors: [
              //           Colors.black.withOpacity(0.25),
              //           Colors.black.withOpacity(0.0),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
              // Positioned.fill(
              //   child: Container(
              //     decoration: BoxDecoration(
              //       gradient: LinearGradient(
              //         begin: Alignment.topCenter,
              //         end: Alignment.center,
              //         colors: [
              //           Colors.black.withOpacity(0.25),
              //           Colors.black.withOpacity(0.0),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
              // _overlayWidget(controller!),
            ],
          ),
        ),
      ),
    );
  }
}
