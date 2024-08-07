// ignore_for_file: avoid_print, unused_field

import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:meyaoo_new/controller/story_controller.dart';
import 'package:meyaoo_new/src/global/global.dart';
import 'package:meyaoo_new/src/global/strings.dart';
import 'package:meyaoo_new/src/screens/layout/story/story_screen.dart';
import 'package:status_view/status_view.dart';

class StorySectionScreen extends StatefulWidget {
  const StorySectionScreen({super.key});

  @override
  State<StorySectionScreen> createState() => _StorySectionScreenState();
}

class _StorySectionScreenState extends State<StorySectionScreen> {
  StroyGetxController storyController = Get.put(StroyGetxController());

  String formatCreateDate(String dateString) {
    // Parse the date string
    DateTime date = DateTime.parse(dateString).toLocal();

    final now = DateTime.now();
    final difference = now.difference(date);

    // Use DateFormat to format the time part
    String formattedTime = DateFormat("h:mm a").format(date);

    if (difference.inDays == 1) {
      return 'yesterday at $formattedTime';
    } else if (difference.inDays == 0) {
      return 'today at $formattedTime';
    } else {
      return DateFormat("d MMMM y").format(date);
    }
  }

  @override
  void initState() {
    storyController.getAllUsersStory();
    super.initState();
  }

  // bool isMatching(String userNumber) {
  //   for (String numbersString in mobileContacts) {
  //     List<String> numbers = numbersString.split(',');
  //     for (String listNumber in numbers) {
  //       if (listNumber == userNumber) {
  //         return true;
  //       }
  //     }
  //   }
  //   return false;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: chatownColor,
        automaticallyImplyLeading: false,
        title: const Text(
          "Stories",
          style: TextStyle(
              fontWeight: FontWeight.w500, fontSize: 20, color: chatColor),
        ),
      ),
      body: Obx(() {
        return (storyController.isAllUserStoryLoad.value) &&
                (storyController.isMyStorySeenLoading.value) &&
                (storyController.isProfileLoading.value)
            ? Center(child: loader(context))
            : Stack(
                children: [
                  SizedBox(
                    height: Get.height,
                    child: SingleChildScrollView(
                      child: Column(children: [
                        const SizedBox(
                          height: 10,
                        ),
                        ListTile(
                          onTap: () {
                            // inController.isOnline.value
                            //     ?
                            storyController.filePickForStory();
                            // : Fluttertoast.showToast(
                            //     msg: "Check your connectivity",
                            //     gravity: ToastGravity.BOTTOM);
                            // Get.to(() => PhotoScreen());
                            // _showSimpleDialog(context);
                          },
                          leading: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Container(
                                  height: 60,
                                  width: 60,
                                  decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.60),
                                      shape: BoxShape.circle),
                                  child: CachedNetworkImage(
                                    imageUrl: Hive.box(userdata).get(userImage),
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) {
                                      return const Icon(
                                        Icons.error,
                                        color: blackcolor,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              // CircleAvatar(backgroundColor: blackcolor),
                              Positioned(
                                bottom: -1,
                                right: 1,
                                child: Container(
                                  decoration: const BoxDecoration(
                                      color: chatownColor,
                                      shape: BoxShape.circle),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.black,
                                    size: 20,
                                  ),
                                ),
                              )
                            ],
                          ),
                          title: const Text("My Story"),
                          subtitle: const Text("Tap to add your story"),
                          titleTextStyle:
                              const TextStyle(fontSize: 16, color: blackcolor),
                          subtitleTextStyle:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                          trailing: storyController.storyListData.value
                                  .myStatus!.statuses!.isEmpty
                              ? const SizedBox.shrink()
                              : GestureDetector(
                                  onTap: () {
                                    storyController.storyListData.value
                                            .myStatus!.statuses!.isEmpty
                                        ? const SizedBox.shrink()
                                        : Get.to(() => const StoryScreen6PM(
                                              isForMyStory: true,
                                            ));
                                  },
                                  child: const Icon(CupertinoIcons.eye)),
                        ),
                        Container(
                          height: 15,
                          color: const Color(0xfff2f2f2).withOpacity(0.5),
                        ),
                        storyController.isAllUserStoryLoad.value
                            ? const SizedBox()
                            : storyController
                                    .storyListData.value.statusList!.isEmpty
                                ? const SizedBox()
                                : ListView.builder(
                                    itemCount: storyController
                                        .storyListData.value.statusList!.length,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    scrollDirection: Axis.vertical,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return storyController
                                                  .storyListData
                                                  .value
                                                  .statusList![index]
                                                  .userData!
                                                  .userId ==
                                              Hive.box(userdata).get(userId)
                                          ? const SizedBox.shrink()
                                          : ListTile(
                                              onTap: () {
                                                storyController.pageIndexValue
                                                    .value = index;
                                                storyController
                                                    .storyIndexValue.value = 0
                                                        // storyController
                                                        //         .storyListData
                                                        //         .value
                                                        //         .statusList![index]
                                                        //         .userReadCount!
                                                        ==
                                                        0
                                                    ? 0
                                                    : 0
                                                            // storyController
                                                            //             .storyListData
                                                            //             .value
                                                            //             .statusList![index]
                                                            //             .userReadCount!
                                                            ==
                                                            0
                                                        // storyController
                                                        //     .storyListData
                                                        //     .value
                                                        //     .statusList![index]
                                                        //     .totalStories!
                                                        ? 0
                                                        : 0
                                                            // storyController
                                                            //         .storyListData
                                                            //         .value
                                                            //         .statusList![index]
                                                            //         .userReadCount!
                                                            -
                                                            1;
                                                log("Page Index Value : ${storyController.pageIndexValue.value}");
                                                log("Story Index Value : ${storyController.storyIndexValue.value}");
                                                setState(() {});
                                                Get.to(() => StoryScreen6PM(
                                                    pageIndex: index,
                                                    storyIndex: 0,
                                                    i: index,
                                                    username: storyController
                                                        .storyListData
                                                        .value
                                                        .statusList![index]
                                                        .fullName));
                                              },
                                              leading: StatusView(
                                                radius: 31,
                                                spacing: 10,
                                                strokeWidth: 2,
                                                indexOfSeenStatus: 0,
                                                // storyController
                                                //     .storyListData
                                                //     .value
                                                //     .statusList![index]
                                                //     .userReadCount!,
                                                numberOfStatus: storyController
                                                    .storyListData
                                                    .value
                                                    .statusList![index]
                                                    .userData!
                                                    .statuses![0]
                                                    .statusMedia!
                                                    .length,
                                                padding: 0,
                                                centerImageUrl: storyController
                                                    .storyListData
                                                    .value
                                                    .statusList![index]
                                                    .userData!
                                                    .profileImage!,
                                                seenColor: Colors.grey,
                                                unSeenColor: chatownColor,
                                              ),
                                              title: Text(
                                                  "${storyController.storyListData.value.statusList![index].fullName}"),
                                              subtitle: Text(formatCreateDate(
                                                  storyController
                                                      .storyListData
                                                      .value
                                                      .statusList![index]
                                                      .userData!
                                                      .statuses![0]
                                                      .createdAt!)),
                                              titleTextStyle: const TextStyle(
                                                  fontSize: 16,
                                                  color: blackcolor),
                                              subtitleTextStyle:
                                                  const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey),
                                            ).paddingOnly(bottom: 5);
                                      //: const SizedBox();
                                    },
                                  )
                      ]),
                    ),
                  ),
                  // inController.isOnline.value
                  //     ? const SizedBox.shrink()
                  //     : Positioned(
                  //         bottom: 0.5,
                  //         child: Container(
                  //             width: Get.width,
                  //             decoration:
                  //                 const BoxDecoration(color: chatownColor),
                  //             child: Center(
                  //               child: const Text(
                  //                 "No Internet",
                  //                 style:
                  //                     TextStyle(fontSize: 15, color: chatColor),
                  //               ).paddingSymmetric(vertical: 8),
                  //             )),
                  //       ),
                ],
              );
      }),
    );
  }
}
