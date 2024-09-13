// ignore_for_file: camel_case_types, avoid_print, unused_field

import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:meyaoo_new/controller/call_controller.dart/get_roomId_controller.dart';
import 'package:meyaoo_new/controller/call_history_controller.dart';
import 'package:meyaoo_new/src/global/global.dart';
import 'package:meyaoo_new/src/global/strings.dart';

class call_history extends StatefulWidget {
  const call_history({super.key});

  @override
  State<call_history> createState() => _call_historyState();
}

class _call_historyState extends State<call_history>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  int selectedindex = 0;
  CallHistoryController callController = Get.put(CallHistoryController());
  final RoomIdController roomIdController = Get.find();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    roomIdController.callHistory();
    // Add a listener to update the selected index when the tab is changed
    _tabController?.addListener(() {
      setState(() {
        selectedindex = _tabController?.index ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: const Color.fromRGBO(250, 250, 250, 1),
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: AppBar(
            scrolledUnderElevation: 0,
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Image.asset("assets/images/logo.png", height: 45),
            automaticallyImplyLeading: false,
          )),
      body: Stack(
        children: [
          Container(
            // height: MediaQuery.of(context).size.height * 0.9,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(color: Colors.white),
            child: Container(
              color: Colors.transparent,
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: <Widget>[
                  ButtonsTabBar(
                    controller: _tabController,
                    borderWidth: 1,
                    unselectedBorderColor: Colors.transparent,
                    borderColor: Colors.transparent,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [yellow1Color, yellow2Color],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    unselectedBackgroundColor: Colors.transparent,
                    unselectedLabelStyle: const TextStyle(
                      color: appgrey2,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    labelStyle: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    onTap: (p0) {
                      setState(() {
                        selectedindex = p0;
                      });
                      print("INDEX:$selectedindex");
                    },
                    tabs: [
                      Tab(
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 25,
                            ),
                            Image.asset(
                              'assets/images/call_1.png',
                              width: 16,
                              height: 16,
                              color:
                                  selectedindex == 0 ? Colors.black : appgrey2,
                            ),
                            // Adjust the spacing between image and text
                            Text(
                              "  All Call         ",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: selectedindex == 0
                                    ? Colors.black
                                    : appgrey2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 20,
                            ),
                            Image.asset(
                              'assets/images/call-remove.png',
                              width: 16,
                              height: 16,
                              color:
                                  selectedindex == 1 ? Colors.black : appgrey2,
                            ),
                            // Adjust the spacing between image and text
                            Text(
                              "   Missed Call     ",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: selectedindex == 1
                                    ? Colors.black
                                    : appgrey2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: <Widget>[
                        allCalls(),
                        missedCalls(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }

  allCalls() {
    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        Expanded(
          child: roomIdController.callHistoryData.isEmpty &&
                  roomIdController.isCallHistoryLoading.value == true
              ? loader(context)
              : Obx(
                  () => ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: roomIdController.callHistoryData.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              CustomCachedNetworkImage(
                                size: 50,
                                imageUrl: roomIdController
                                            .callHistoryData[index]
                                            .conversation!
                                            .isGroup ==
                                        true
                                    ? roomIdController.callHistoryData[index]
                                        .conversation!.groupProfileImage!
                                    : roomIdController.callHistoryData[index]
                                        .user!.profileImage!,
                                placeholderColor: chatownColor,
                                errorWidgeticon: const Icon(
                                  Icons.groups,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    roomIdController.callHistoryData[index]
                                                .conversation!.isGroup ==
                                            true
                                        ? roomIdController
                                            .callHistoryData[index]
                                            .conversation!
                                            .groupName!
                                        : "${roomIdController.callHistoryData[index].user!.firstName!} ${roomIdController.callHistoryData[index].user!.lastName!}",
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                      color: Color(0xff0B0B0B),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 2,
                                  ),
                                  Row(
                                    children: [
                                      Image.asset(
                                        roomIdController.callHistoryData[index]
                                                    .callType ==
                                                "video_call"
                                            ? roomIdController
                                                        .callHistoryData[index]
                                                        .missedCall ==
                                                    "1"
                                                ? "assets/icons/missed_video_call.png"
                                                : roomIdController
                                                            .callHistoryData[
                                                                index]
                                                            .callDecline ==
                                                        "1"
                                                    ? "assets/icons/missed_video_call.png"
                                                    : roomIdController
                                                                .callHistoryData[
                                                                    index]
                                                                .userId ==
                                                            Hive.box(userdata)
                                                                .get(userId)
                                                        ? "assets/icons/outgoing_video_call.png"
                                                        : "assets/icons/incoming_video_call.png"
                                            : roomIdController
                                                        .callHistoryData[index]
                                                        .missedCall ==
                                                    "1"
                                                ? "assets/icons/missed_audio_call.png"
                                                : roomIdController
                                                            .callHistoryData[
                                                                index]
                                                            .callDecline ==
                                                        "1"
                                                    ? "assets/icons/missed_audio_call.png"
                                                    : roomIdController
                                                                .callHistoryData[
                                                                    index]
                                                                .userId ==
                                                            Hive.box(userdata)
                                                                .get(userId)
                                                        ? "assets/icons/outgoing_audio_call.png"
                                                        : "assets/icons/incoming_audio_call.png",
                                        height: 14,
                                        width: 14,
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      Text(
                                        roomIdController.callHistoryData[index]
                                                    .callType ==
                                                "video_call"
                                            ? roomIdController
                                                        .callHistoryData[index]
                                                        .missedCall ==
                                                    "1"
                                                ? "Missed Video Call"
                                                : roomIdController
                                                            .callHistoryData[
                                                                index]
                                                            .callDecline ==
                                                        "1"
                                                    ? "Video Call Declined"
                                                    : roomIdController
                                                                .callHistoryData[
                                                                    index]
                                                                .userId ==
                                                            Hive.box(userdata)
                                                                .get(userId)
                                                        ? "Outgoing Video Call"
                                                        : "Incoming Video Call"
                                            : roomIdController
                                                        .callHistoryData[index]
                                                        .missedCall ==
                                                    "1"
                                                ? "Missed Audio Call"
                                                : roomIdController
                                                            .callHistoryData[
                                                                index]
                                                            .callDecline ==
                                                        "1"
                                                    ? "Audio Call Declined"
                                                    : roomIdController
                                                                .callHistoryData[
                                                                    index]
                                                                .userId ==
                                                            Hive.box(userdata)
                                                                .get(userId)
                                                        ? "Outgoing Audio Call"
                                                        : "Incoming Audio Call",
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                          color: Color(0xffA4A4A4),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    formatDateCallHistorry(convertToLocalDate(
                                        roomIdController
                                            .callHistoryData[index].updatedAt)),
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 9,
                                      color: Color(0xff606060),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    convertUTCTimeTo12HourFormat(
                                      roomIdController
                                          .callHistoryData[index].updatedAt!,
                                    ),
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 8,
                                      color: Color(0xff606060),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ).paddingSymmetric(horizontal: 20, vertical: 7),
                          index == roomIdController.callHistoryData.length - 1
                              ? const SizedBox(
                                  height: 20,
                                )
                              : Divider(
                                  color: Colors.grey.shade300,
                                )
                        ],
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  missedCalls() {
    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        Expanded(
          child: roomIdController.callHistoryData.isEmpty &&
                  roomIdController.isCallHistoryLoading.value == true
              ? loader(context)
              : Obx(
                  () => ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: roomIdController.callHistoryData.length,
                    itemBuilder: (context, index) {
                      return roomIdController
                                  .callHistoryData[index].missedCall ==
                              "0"
                          ? const SizedBox.shrink()
                          : Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    CustomCachedNetworkImage(
                                      size: 50,
                                      imageUrl: roomIdController
                                                  .callHistoryData[index]
                                                  .conversation!
                                                  .isGroup ==
                                              true
                                          ? roomIdController
                                              .callHistoryData[index]
                                              .conversation!
                                              .groupProfileImage!
                                          : roomIdController
                                              .callHistoryData[index]
                                              .user!
                                              .profileImage!,
                                      placeholderColor: chatownColor,
                                      errorWidgeticon: const Icon(
                                        Icons.groups,
                                        size: 30,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          roomIdController
                                                      .callHistoryData[index]
                                                      .conversation!
                                                      .isGroup ==
                                                  true
                                              ? roomIdController
                                                  .callHistoryData[index]
                                                  .conversation!
                                                  .groupName!
                                              : "${roomIdController.callHistoryData[index].user!.firstName!} ${roomIdController.callHistoryData[index].user!.lastName!}",
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15,
                                            color: Color(0xff0B0B0B),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 2,
                                        ),
                                        Row(
                                          children: [
                                            Image.asset(
                                              roomIdController
                                                          .callHistoryData[
                                                              index]
                                                          .callType ==
                                                      "video_call"
                                                  ? "assets/icons/missed_video_call.png"
                                                  : "assets/icons/missed_audio_call.png",
                                              height: 14,
                                              width: 14,
                                            ),
                                            const SizedBox(
                                              width: 4,
                                            ),
                                            Text(
                                              roomIdController
                                                          .callHistoryData[
                                                              index]
                                                          .callType ==
                                                      "video_call"
                                                  ? "Missed Video Call"
                                                  : "Missed Audio Call",
                                              style: const TextStyle(
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12,
                                                color: Color(0xffA4A4A4),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          formatDateCallHistorry(
                                              convertToLocalDate(
                                                  roomIdController
                                                      .callHistoryData[index]
                                                      .updatedAt)),
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w400,
                                            fontSize: 9,
                                            color: Color(0xff606060),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 8,
                                        ),
                                        Text(
                                          convertUTCTimeTo12HourFormat(
                                            roomIdController
                                                .callHistoryData[index]
                                                .updatedAt!,
                                          ),
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w400,
                                            fontSize: 8,
                                            color: Color(0xff606060),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ).paddingSymmetric(horizontal: 20, vertical: 7),
                                index ==
                                        roomIdController
                                                .callHistoryData.length -
                                            1
                                    ? const SizedBox(
                                        height: 20,
                                      )
                                    : Divider(
                                        color: Colors.grey.shade300,
                                      )
                              ],
                            );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
