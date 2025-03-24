// ignore_for_file: avoid_print, unused_field

import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:whoxachat/app.dart';
import 'package:whoxachat/controller/story_controller.dart';
import 'package:whoxachat/src/global/common_widget.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:whoxachat/src/global/strings.dart';
import 'package:whoxachat/src/screens/layout/story/my_stories_list_screen.dart';
import 'package:whoxachat/src/screens/layout/story/story_screen.dart';
import 'package:whoxachat/src/screens/layout/story/story_screen_viewed.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: appColorWhite,
        automaticallyImplyLeading: false,
        title: Image.network(
          languageController.appSettingsData[0].appLogo!,
          height: 45,
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
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            languageController.textTranslate('Status'),
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: "Poppins"),
                          ).paddingSymmetric(horizontal: 20),
                          ListTile(
                            onTap: () {
                              Get.to(
                                const MyStoriesListScreen(),
                                transition: Transition.rightToLeft,
                              );
                            },
                            leading: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Obx(
                                    () => Container(
                                      height: 50,
                                      width: 50,
                                      decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          border: Border.all(
                                              color: (storyController
                                                          .isAllUserStoryLoad
                                                          .value) &&
                                                      (storyController
                                                          .isProfileLoading
                                                          .value) &&
                                                      storyController
                                                          .storyListData
                                                          .value
                                                          .myStatus!
                                                          .statuses!
                                                          .isEmpty
                                                  ? Colors.grey.shade400
                                                  : chatownColor,
                                              width: 2),
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
                                      ).marginAll(3),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            title: Text(
                                languageController.textTranslate('My Story')),
                            subtitle: Text(languageController
                                .textTranslate('Tap to add your story')),
                            titleTextStyle: const TextStyle(
                                fontSize: 16, color: blackcolor),
                            subtitleTextStyle: const TextStyle(
                                fontSize: 14, color: Colors.grey),
                            trailing: Obx(
                              () => Wrap(
                                children: [
                                  const SizedBox(width: 10),
                                  (storyController.isAllUserStoryLoad.value) &&
                                          (storyController
                                              .isProfileLoading.value) &&
                                          storyController.storyListData.value
                                              .myStatus!.statuses!.isEmpty
                                      ? const SizedBox.shrink()
                                      : InkWell(
                                          onTap: () {
                                            storyController.filePickForStory();
                                          },
                                          child: Image.asset(
                                            'assets/images/gallery.png',
                                            height: 23,
                                            color: appColorBlack,
                                          ),
                                        ),
                                  // const SizedBox(width: 20),
                                  // Image.asset(
                                  //   'assets/images/edit-2.png',
                                  //   height: 23,
                                  //   color: appColorBlack,
                                  // ),
                                ],
                              ),
                            ),
                          ),
                          const Divider(),
                          storyController.isAllUserStoryLoad.value
                              ? const SizedBox()
                              : storyController.notViewedStatusList.isEmpty &&
                                      storyController.viewedStatusList.isEmpty
                                  ? Expanded(
                                      child: commonImageTexts(
                                        image:
                                            "assets/images/no_contact_found_1.png",
                                        text1: "No Status found",
                                        text2:
                                            "You can find your connected friends or family status.",
                                      ),
                                    )
                                  : const SizedBox.shrink(),
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
                                  : SingleChildScrollView(
                                      child: ListView.builder(
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
                                              : ListTile(
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
                                        },
                                      ),
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
                                  : SingleChildScrollView(
                                      child: ListView.builder(
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
                                        },
                                      ),
                                    ),
                        ]),
                  ),
                ],
              );
      }),
    );
  }
}
