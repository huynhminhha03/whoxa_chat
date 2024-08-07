// ignore_for_file: deprecated_member_use, depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

// ignore: must_be_immutable
class PlayVideo extends StatefulWidget {
  final String videoLink;
  const PlayVideo({super.key, required this.videoLink});

  @override
  State<PlayVideo> createState() => _PlayVideoState();
}

class _PlayVideoState extends State<PlayVideo> {
  // ChewieController? _chewieController;
  // late VideoPlayerController _videoPlayerController;
  VideoPlayerController? _controller;
  Future<void>? _initializeVideoPlayerFuture;
  @override
  void initState() {
    _controller = VideoPlayerController.network(widget.videoLink);
    _initializeVideoPlayerFuture = _controller!.initialize();
    _controller!.setLooping(true);
    _controller!.setVolume(1.0);
    super.initState();
  }
  // @override
  // void initState() {
  //   super.initState();
  //   print('video link ============= > init ${widget.videoLink}');
  //   initializePlayer();
  // }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }
  // void dispose() {
  //   super.dispose();
  //   _videoPlayerController.dispose();
  //   _chewieController!.dispose();
  // }

  // Future<void> initializePlayer() async {
  //   _videoPlayerController = VideoPlayerController.network(widget.videoLink);

  //   await Future.wait([_videoPlayerController.initialize()]);
  //   _createChewieController();

  //   print('video link ============= > ${widget.videoLink}');

  //   setState(() {});
  // }

  // void _createChewieController() {
  //   _chewieController = ChewieController(
  //       videoPlayerController: _videoPlayerController,
  //       autoPlay: true,
  //       looping: true,
  //       showControls: true,
  //       showControlsOnInitialize: true,
  //       hideControlsTimer: Duration(seconds: 3));
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder(
          future: _initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.blue,
                ),
              );
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            if (_controller!.value.isPlaying) {
              _controller!.pause();
            } else {
              _controller!.play();
            }
          });
        },
        child: Icon(
          _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}
  // Widget build(BuildContext context) {
  //   return SafeArea(
  //       child: Scaffold(
  //     backgroundColor: Colors.black,
  //     body: Stack(
  //       alignment: Alignment.center,
  //       children: [
  //         Container(
  //             height: double.infinity,
  //             width: double.infinity,
  //             color: Colors.black,
  //             child: _chewieController != null &&
  //                     _chewieController!
  //                         .videoPlayerController.value.isInitialized
  //                 ? Chewie(
  //                     controller: _chewieController!,
  //                   )
  //                 : Center(
  //                     child: CircularProgressIndicator(color: appColorOrange),
  //                   )),
  //         Positioned(
  //           left: 20,
  //           top: 20,
  //           child: InkWell(
  //             onTap: () {
  //               _videoPlayerController.dispose();
  //               _chewieController!.dispose();
  //               Navigator.pop(context);
  //             },
  //             child: const Icon(
  //               Icons.arrow_back_ios_new_rounded,
  //               color: appColorWhite,
  //               size: 24,
  //             ),
  //           ),
  //         )
  //       ],
  //     ),
  //   ));
  // }

