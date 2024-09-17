// ignore_for_file: avoid_print, unused_field

import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:meyaoo_new/controller/story_controller.dart';
import 'package:meyaoo_new/src/global/global.dart';
import 'package:meyaoo_new/src/global/strings.dart';
import 'package:meyaoo_new/src/screens/layout/story/story_screen.dart';
import 'package:meyaoo_new/src/screens/layout/story/story_screen_viewed.dart';
import 'package:status_view/status_view.dart';

class StorySectionScreen extends StatefulWidget {
  const StorySectionScreen({super.key});

  @override
  State<StorySectionScreen> createState() => _StorySectionScreenState();
}

class _StorySectionScreenState extends State<StorySectionScreen> {
  StroyGetxController storyController = Get.put(StroyGetxController());

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
        backgroundColor: appColorWhite,
        automaticallyImplyLeading: false,
        title: Image.asset("assets/images/logo.png", height: 45),
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
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Status",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: "Poppins"),
                            ).paddingSymmetric(horizontal: 20),
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
                                      height: 50,
                                      width: 50,
                                      decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          border: Border.all(
                                              color: appColorYellow, width: 1),
                                          shape: BoxShape.circle),
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            Hive.box(userdata).get(userImage),
                                        fit: BoxFit.cover,
                                        errorWidget: (context, url, error) {
                                          return const Icon(
                                            Icons.error,
                                            color: blackcolor,
                                          );
                                        },
                                      ).marginAll(2),
                                    ),
                                  ),
                                  // CircleAvatar(backgroundColor: blackcolor),
                                  Positioned(
                                    bottom: -1,
                                    right: 1,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                                colors: [
                                                  yellow1Color,
                                                  yellow2Color
                                                ],
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter),
                                            shape: BoxShape.circle),
                                        child: const Icon(
                                          Icons.add,
                                          color: Colors.black,
                                          size: 15,
                                        ),
                                      ).paddingAll(2),
                                    ),
                                  )
                                ],
                              ),
                              title: const Text("My Story"),
                              subtitle: const Text("Tap to add your story"),
                              titleTextStyle: const TextStyle(
                                  fontSize: 16, color: blackcolor),
                              subtitleTextStyle: const TextStyle(
                                  fontSize: 14, color: Colors.grey),
                              trailing: Obx(
                                () => Wrap(
                                  children: [
                                    const SizedBox(width: 10),
                                    (storyController
                                                .isAllUserStoryLoad.value) ||
                                            // (storyController
                                            //             .isMyStorySeenLoading.value) ||
                                            (storyController
                                                .isProfileLoading.value) ||
                                            storyController.storyListData.value
                                                .myStatus!.statuses!.isEmpty
                                        ? const SizedBox.shrink()
                                        : InkWell(
                                            onTap: () {
                                              Get.to(() => const StoryScreen6PM(
                                                    isForMyStory: true,
                                                  ));
                                            },
                                            child: Image.asset(
                                                'assets/images/eye.png',
                                                height: 23)),
                                  ],
                                ),
                              ),
                            ),
                            const Divider(),
                            storyController.isAllUserStoryLoad.value
                                ? const SizedBox()
                                : storyController.notViewedStatusList.isEmpty
                                    ? const SizedBox()
                                    : const Text(
                                        "Recent",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                      ).paddingOnly(left: 20),
                            storyController.isAllUserStoryLoad.value
                                ? const SizedBox()
                                : storyController.notViewedStatusList.isEmpty
                                    ? const SizedBox()
                                    : ListView.builder(
                                        itemCount: storyController
                                            .notViewedStatusList.length,
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        scrollDirection: Axis.vertical,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return storyController
                                                      .notViewedStatusList[
                                                          index]
                                                      .userData!
                                                      .userId ==
                                                  Hive.box(userdata).get(userId)
                                              ? const SizedBox.shrink()
                                              :
                                              // storyController
                                              //             .notViewedStatusList[
                                              //                 index]
                                              //             .userData!
                                              //             .statuses![0]
                                              //             .statusViews![0]
                                              //             .statusCount ==
                                              //         storyController
                                              //             .notViewedStatusList[
                                              //                 index]
                                              //             .userData!
                                              //             .statuses![0]
                                              //             .statusMedia!
                                              //             .length
                                              //     ? const SizedBox()
                                              //     :
                                              ListTile(
                                                  onTap: () {
                                                    storyController
                                                        .pageIndexValue
                                                        .value = index;
                                                    storyController
                                                        .storyIndexValue
                                                        .value = storyController
                                                                .notViewedStatusList[
                                                                    index]
                                                                .userData!
                                                                .statuses![0]
                                                                .statusViews![0]
                                                                .statusCount! ==
                                                            0
                                                        ? 0
                                                        : storyController
                                                                    .notViewedStatusList[
                                                                        index]
                                                                    .userData!
                                                                    .statuses![
                                                                        0]
                                                                    .statusViews![
                                                                        0]
                                                                    .statusCount! ==
                                                                storyController
                                                                    .notViewedStatusList
                                                                    .length
                                                            ? 0
                                                            : storyController
                                                                    .notViewedStatusList[
                                                                        index]
                                                                    .userData!
                                                                    .statuses![
                                                                        0]
                                                                    .statusViews![
                                                                        0]
                                                                    .statusCount! -
                                                                1;
                                                    log("Page Index Value : ${storyController.pageIndexValue.value}");
                                                    log("Story Index Value : ${storyController.storyIndexValue.value}");
                                                    setState(() {});
                                                    Get.to(() => StoryScreen6PM(
                                                            pageIndex: index,
                                                            storyIndex: 0,
                                                            i: index,
                                                            username:
                                                                storyController
                                                                    .notViewedStatusList[
                                                                        index]
                                                                    .fullName))!
                                                        .then((_) {
                                                      print("REFRESH");
                                                      print(
                                                          "COUNT:${storyController.notViewedStatusList[index].userData!.statuses![0].statusViews![0].statusCount}");
                                                      print(
                                                          "COUNT:${storyController.notViewedStatusList[index].userData!.statuses![0].statusMedia!.length}");
                                                      storyController
                                                          .storyListData
                                                          .refresh();
                                                      storyController
                                                          .notViewedStatusList
                                                          .refresh();
                                                      storyController
                                                          .viewedStatusList
                                                          .refresh();
                                                      if (index ==
                                                          storyController
                                                                  .notViewedStatusList
                                                                  .length -
                                                              1) {
                                                        // If it's the last index, call getAllUsersStoryUpdate()
                                                        storyController
                                                            .getAllUsersStoryUpdate();
                                                      }
                                                    });
                                                  },
                                                  leading: Obx(() {
                                                    return StatusView(
                                                      radius: 25,
                                                      spacing: 10,
                                                      strokeWidth: 2,
                                                      indexOfSeenStatus:
                                                          storyController
                                                              .notViewedStatusList[
                                                                  index]
                                                              .userData!
                                                              .statuses![0]
                                                              .statusViews![0]
                                                              .statusCount!,
                                                      numberOfStatus:
                                                          storyController
                                                              .notViewedStatusList[
                                                                  index]
                                                              .userData!
                                                              .statuses![0]
                                                              .statusMedia!
                                                              .length,
                                                      padding: 3,
                                                      centerImageUrl:
                                                          storyController
                                                              .notViewedStatusList[
                                                                  index]
                                                              .userData!
                                                              .profileImage!,
                                                      seenColor:
                                                          Colors.grey.shade400,
                                                      unSeenColor: chatownColor,
                                                    );
                                                  }),
                                                  title: Text(
                                                      "${storyController.notViewedStatusList[index].fullName}"),
                                                  subtitle: Text(formatCreateDate(
                                                      storyController
                                                          .notViewedStatusList[
                                                              index]
                                                          .userData!
                                                          .statuses![0]
                                                          .updatedAt!)),
                                                  titleTextStyle:
                                                      const TextStyle(
                                                          fontSize: 16,
                                                          color: blackcolor),
                                                  subtitleTextStyle:
                                                      const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.grey),
                                                ).paddingOnly(bottom: 5);
                                          //: const SizedBox();
                                        },
                                      ),
                            storyController.isAllUserStoryLoad.value
                                ? const SizedBox()
                                : storyController.viewedStatusList.isEmpty
                                    ? const SizedBox()
                                    : const Text(
                                        "Viewed",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                      ).paddingOnly(left: 20),
                            storyController.isAllUserStoryLoad.value
                                ? const SizedBox()
                                : storyController.viewedStatusList.isEmpty
                                    ? const SizedBox()
                                    : ListView.builder(
                                        itemCount: storyController
                                            .viewedStatusList.length,
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        scrollDirection: Axis.vertical,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return storyController
                                                      .viewedStatusList[index]
                                                      .userData!
                                                      .userId ==
                                                  Hive.box(userdata).get(userId)
                                              ? const SizedBox.shrink()
                                              : ListTile(
                                                  onTap: () {
                                                    storyController
                                                        .pageIndexValue
                                                        .value = index;
                                                    storyController
                                                        .storyIndexValue
                                                        .value = storyController
                                                                .viewedStatusList[
                                                                    index]
                                                                .userData!
                                                                .statuses![0]
                                                                .statusViews![0]
                                                                .statusCount! ==
                                                            0
                                                        ? 0
                                                        : storyController
                                                                    .viewedStatusList[
                                                                        index]
                                                                    .userData!
                                                                    .statuses![
                                                                        0]
                                                                    .statusViews![
                                                                        0]
                                                                    .statusCount! ==
                                                                storyController
                                                                    .viewedStatusList
                                                                    .length
                                                            ? 0
                                                            : storyController
                                                                    .viewedStatusList[
                                                                        index]
                                                                    .userData!
                                                                    .statuses![
                                                                        0]
                                                                    .statusViews![
                                                                        0]
                                                                    .statusCount! -
                                                                1;
                                                    log("Page Index Value : ${storyController.pageIndexValue.value}");
                                                    log("Story Index Value : ${storyController.storyIndexValue.value}");
                                                    setState(() {});
                                                    Get.to(() => StoryScreen6PMViewed(
                                                            pageIndex: index,
                                                            storyIndex: 0,
                                                            i: index,
                                                            username:
                                                                storyController
                                                                    .viewedStatusList[
                                                                        index]
                                                                    .fullName))!
                                                        .then((_) {
                                                      print("REFRESH");
                                                      storyController
                                                          .storyListData
                                                          .refresh();
                                                      storyController
                                                          .notViewedStatusList
                                                          .refresh();
                                                      storyController
                                                          .viewedStatusList
                                                          .refresh();
                                                    });
                                                  },
                                                  leading: Obx(() {
                                                    return StatusView(
                                                      radius: 25,
                                                      spacing: 10,
                                                      strokeWidth: 2,
                                                      indexOfSeenStatus:
                                                          storyController
                                                              .viewedStatusList[
                                                                  index]
                                                              .userData!
                                                              .statuses![0]
                                                              .statusViews![0]
                                                              .statusCount!,
                                                      numberOfStatus:
                                                          storyController
                                                              .viewedStatusList[
                                                                  index]
                                                              .userData!
                                                              .statuses![0]
                                                              .statusMedia!
                                                              .length,
                                                      padding: 3,
                                                      centerImageUrl:
                                                          storyController
                                                              .viewedStatusList[
                                                                  index]
                                                              .userData!
                                                              .profileImage!,
                                                      seenColor:
                                                          Colors.grey.shade400,
                                                      unSeenColor: chatownColor,
                                                    );
                                                  }),
                                                  title: Text(
                                                      "${storyController.viewedStatusList[index].fullName}"),
                                                  subtitle: Text(
                                                      formatCreateDate(
                                                          storyController
                                                              .viewedStatusList[
                                                                  index]
                                                              .userData!
                                                              .statuses![0]
                                                              .updatedAt!)),
                                                  titleTextStyle:
                                                      const TextStyle(
                                                          fontSize: 16,
                                                          color: blackcolor),
                                                  subtitleTextStyle:
                                                      const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.grey),
                                                ).paddingOnly(bottom: 5);
                                          //: const SizedBox();
                                        },
                                      ),
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
