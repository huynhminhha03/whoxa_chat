// ignore_for_file: camel_case_types, avoid_print, unused_field

import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meyaoo_new/Models/get_all_audiocall_list_model.dart';
import 'package:meyaoo_new/Models/get_all_videocall_list_model.dart';
import 'package:meyaoo_new/controller/call_history_controller.dart';
import 'package:meyaoo_new/src/global/global.dart';
import 'package:meyaoo_new/Models/calllistmodel.dart';

class call_history extends StatefulWidget {
  const call_history({super.key});

  @override
  State<call_history> createState() => _call_historyState();
}

class _call_historyState extends State<call_history> {
  int selectedindex = 0;
  CallHistoryController callController = Get.put(CallHistoryController());

  @override
  void initState() {
    callController.callHistoryApi();
    callController.callHistoryApiVideo();
    callController.callHistoryApiAudio();
    getContactsFromGloble();
    //_fetchContacts();
    super.initState();
  }

  // List<Contact>? _contacts;
  // bool _permissionDenied = false;
  // List<String> allNumbers = [];
  // List<String> allNames = [];

  // Future _fetchContacts() async {
  //   print("in fetch data");
  //   if (!await FlutterContacts.requestPermission(readonly: true)) {
  //     print("in if statement");
  //     setState(() => _permissionDenied = true);
  //   } else {
  //     print("in else statement");
  //     final contacts = await FlutterContacts.getContacts();
  //     setState(() => _contacts = contacts);

  //     log("length ${_contacts!.length}");
  //     for (int i = 0; i < _contacts!.length; i++) {
  //       setState(() {});
  //       final val = await FlutterContacts.getContact(_contacts![i].id);

  //       allNumbers.add(val!.phones.isNotEmpty
  //           ? val.phones.first.normalizedNumber.trim()
  //           : '');
  //       allNames.add(val.displayName);
  //       log("SINGLE ${val.phones.single.number}");
  //       log("NORMALIZED NUMBER 1 ${val.phones.first.normalizedNumber}");
  //       log("NORMALIZED NUMBER ${val.phones.last.normalizedNumber}");

  //       log("ALL NUMBER ${allNumbers[i].trim()}");
  //       log("index $i");
  //       log("Name ${_contacts![i].id}");

  //       setState(() {});
  //     }
  //   }
  // }

  // int getIndexFromNumber(String name) {
  //   if (_contacts != null) {
  //     for (int i = 0; i < allNumbers.length; i++) {
  //       if (allNumbers.elementAt(i) == name) {
  //         return i;
  //       }
  //     }
  //   }
  //   return -1; // Return -1 if name is not found
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
              preferredSize: const Size.fromHeight(25),
              child: AppBar(
                scrolledUnderElevation: 0,
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
              )),
          body: Obx(() {
            return callController.isLoading.value
                ? loaderWidget()
                : Stack(
                    children: [
                      Container(
                          // height: MediaQuery.of(context).size.height * 0.9,
                          width: MediaQuery.of(context).size.width,
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  topRight: Radius.circular(30))),
                          child: Container(
                            color: Colors.transparent,
                            height: MediaQuery.of(context).size.height,
                            child: DefaultTabController(
                              length: 3,
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(color: appgrey2),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: ButtonsTabBar(
                                      borderWidth: 1,
                                      unselectedBorderColor: Colors.transparent,
                                      borderColor: Colors.transparent,
                                      backgroundColor: chatownColor,
                                      unselectedBackgroundColor:
                                          Colors.transparent,
                                      unselectedLabelStyle:
                                          const TextStyle(color: appgrey2),
                                      labelStyle: TextStyle(
                                          color: selectedindex == 0
                                              ? Colors.black
                                              : appgrey2,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14),
                                      onTap: (p0) {
                                        setState(() {
                                          selectedindex = p0;
                                        });
                                      },
                                      tabs: [
                                        Tab(
                                          child: Row(
                                            children: [
                                              const SizedBox(
                                                width: 25,
                                              ),
                                              Image.asset(
                                                'assets/images/callVector.png',
                                                width: 16,
                                                height: 16,
                                                color: selectedindex == 0
                                                    ? Colors.black
                                                    : appgrey2,
                                              ),
                                              // Adjust the spacing between image and text
                                              Text(
                                                "  All         ",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color: selectedindex == 1
                                                        ? appgrey2
                                                        : Colors.black),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Tab(
                                          child: Row(
                                            children: [
                                              const SizedBox(
                                                width: 18,
                                              ),
                                              Image.asset(
                                                'assets/images/Video 3.png',
                                                width: 16,
                                                height: 16,
                                                color: selectedindex == 1
                                                    ? Colors.black
                                                    : appgrey2,
                                              ),
                                              // Adjust the spacing between image and text
                                              Text(
                                                "   Video Call   ",
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
                                        Tab(
                                          child: Row(
                                            children: [
                                              const SizedBox(
                                                width: 20,
                                              ),
                                              Image.asset(
                                                'assets/images/Call Missed.png',
                                                width: 16,
                                                height: 16,
                                                color: selectedindex == 2
                                                    ? Colors.black
                                                    : appgrey2,
                                              ),
                                              // Adjust the spacing between image and text
                                              Text(
                                                "   Missed     ",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: selectedindex == 2
                                                      ? Colors.black
                                                      : appgrey2,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: TabBarView(
                                      children: <Widget>[
                                        //_______________________________________________________________________________________
                                        //_____________________________ ALL CALL LIST____________________________________________
                                        //_______________________________________________________________________________________
                                        //AllCallList(),
                                        callController.callListModel.value!
                                                    .messagesList ==
                                                null
                                            ? const SizedBox()
                                            : callController
                                                    .callListModel
                                                    .value!
                                                    .messagesList!
                                                    .isEmpty
                                                ? Center(
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.2,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 10),
                                                          child: Image.asset(
                                                              "assets/images/no_call_history.png",
                                                              height: 300),
                                                        ),
                                                        Container(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.1,
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                : Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10,
                                                            right: 10),
                                                    child: ListView.builder(
                                                        shrinkWrap: true,
                                                        itemCount:
                                                            callController
                                                                .callListModel
                                                                .value!
                                                                .messagesList!
                                                                .length,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 10,
                                                                horizontal: 10),
                                                        scrollDirection:
                                                            Axis.vertical,
                                                        itemBuilder:
                                                            (context, index) {
                                                          return allwidget(
                                                              callController
                                                                  .callListModel
                                                                  .value!
                                                                  .messagesList![index]);
                                                        }),
                                                  ),

                                        //___________________________________________________________________________________________
                                        //_____________________________ VIDEO CALL LIST TABBAR ______________________________________
                                        //___________________________________________________________________________________________
                                        //AllVideoCallList(),
                                        callController.videoCallListModel.value!
                                                    .videoCallList ==
                                                null
                                            ? const SizedBox()
                                            : callController
                                                    .videoCallListModel
                                                    .value!
                                                    .videoCallList!
                                                    .isEmpty
                                                ? Center(
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.2,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 10),
                                                          child: Image.asset(
                                                              "assets/images/no_call_history.png",
                                                              height: 300),
                                                        ),
                                                        Container(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.1,
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                : Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10,
                                                            right: 10),
                                                    child: ListView.builder(
                                                        shrinkWrap: true,
                                                        itemCount: callController
                                                            .videoCallListModel
                                                            .value!
                                                            .videoCallList!
                                                            .length,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 10,
                                                                horizontal: 10),
                                                        scrollDirection:
                                                            Axis.vertical,
                                                        itemBuilder:
                                                            (context, index) {
                                                          return videocallwidget(
                                                              callController
                                                                  .videoCallListModel
                                                                  .value!
                                                                  .videoCallList![index]);
                                                        }),
                                                  ),

                                        //______________________________________________________________________________________
                                        //__________________________MISSED CALL LIST TABBAR_____________________________________
                                        //______________________________________________________________________________________
                                        //AllAudioCallList()
                                        callController.audioCallListModel.value!
                                                    .missedCallList ==
                                                null
                                            ? const SizedBox()
                                            : callController
                                                    .audioCallListModel
                                                    .value!
                                                    .missedCallList!
                                                    .isEmpty
                                                ? Center(
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.2,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 10),
                                                          child: Image.asset(
                                                              "assets/images/no_call_history.png",
                                                              height: 300),
                                                        ),
                                                        Container(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.1,
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                : Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10,
                                                            right: 10),
                                                    child: ListView.builder(
                                                        shrinkWrap: true,
                                                        itemCount: callController
                                                            .audioCallListModel
                                                            .value!
                                                            .missedCallList!
                                                            .length,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 10,
                                                                horizontal: 10),
                                                        scrollDirection:
                                                            Axis.vertical,
                                                        itemBuilder:
                                                            (context, index) {
                                                          return missedwidget(
                                                              callController
                                                                  .audioCallListModel
                                                                  .value!
                                                                  .missedCallList![index]);
                                                        }),
                                                  )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
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
                      //                 style: TextStyle(
                      //                     fontSize: 15, color: chatColor),
                      //               ).paddingSymmetric(vertical: 8),
                      //             )),
                      //       ),
                    ],
                  );
          })),
    );
  }

//---------------------------------------------------- All Call List ----------------------------------------------------------
  Widget allwidget(MessagesList allList) {
    String getContact(mobile) {
      if (mobile != null) {
        var name = mobile;
        bool found = false;
        for (var i = 0; i < allcontacts.length; i++) {
          if (allcontacts[i]
              .phones
              .map((e) => e.number)
              .toString()
              .replaceAll(RegExp(r"\s+\b|\b\s"), "")
              .contains(mobile)) {
            name = allcontacts[i].displayName;
            found = true;
            break; // Once found, no need to continue searching
          }
        }
        if (!found) {
          return allList.username!; // Return username if contact not found
        }
        return name;
      } else {
        return mobile;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration:
                const BoxDecoration(shape: BoxShape.circle, color: appgrey),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: CustomCachedNetworkImage(
                    imageUrl: allList.profilePic!,
                    errorWidgeticon: Icon(
                      allList.groupname == "" ? Icons.person : Icons.groups_2,
                      size: 30,
                    ))),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                allList.groupname == ""
                    ? Text(
                        capitalizeFirstLetter(
                            getContact(getMobile(allList.mobileNumber!))),
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      )
                    : Text(
                        allList.groupname!,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                const SizedBox(height: 5),
                Text(
                  formatDateTime(DateTime.parse(allList.timestamp!)),
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: appgrey2),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                //____________________ AUDIO CALL STATUS__________________
                allList.callType == "audio_call" &&
                        allList.message == "" &&
                        allList.isComeing == "Outgoing"
                    ? const Image(
                        image: AssetImage('assets/images/call-outgoing.png'),
                        height: 20,
                      )
                    : allList.callType == "audio_call" &&
                            allList.message == "" &&
                            allList.isComeing == "Incoming"
                        ? const Image(
                            image:
                                AssetImage('assets/images/call-incoming.png'),
                            height: 20,
                          )
                        : allList.callType == "audio_call" &&
                                allList.message == "missed call"
                            ? const Image(
                                image:
                                    AssetImage('assets/images/NotRecive.png'),
                                height: 13,
                              )
                            //____________________ VIDEO CALL STATUS__________________
                            : allList.callType == "video_call" &&
                                    allList.message == "" &&
                                    allList.isComeing == "Incoming"
                                ? const Image(
                                    image:
                                        AssetImage('assets/images/videoo.png'),
                                    height: 20,
                                  )
                                : allList.callType == "video_call" &&
                                        allList.message == "" &&
                                        allList.isComeing == "Outgoing"
                                    ? const Image(
                                        image: AssetImage(
                                            'assets/images/videoo.png'),
                                        height: 20,
                                      )
                                    : allList.callType == "video_call" &&
                                            allList.message == "missed call"
                                        ? const Image(
                                            image: AssetImage(
                                                'assets/images/videocall_missed.png'),
                                            height: 20,
                                          )
                                        :
                                        //_____________________GROUP AUDIO CALL STATUS_______________________________
                                        allList.callType ==
                                                    "group_audio_call" &&
                                                allList.message == "" &&
                                                allList.isComeing == "Outgoing"
                                            ? const Image(
                                                image: AssetImage(
                                                    'assets/images/call-outgoing.png'),
                                                height: 20,
                                              )
                                            : allList.callType ==
                                                        "group_audio_call" &&
                                                    allList.message == "" &&
                                                    allList.isComeing ==
                                                        "Incoming"
                                                ? const Image(
                                                    image: AssetImage(
                                                        'assets/images/call-incoming.png'),
                                                    height: 20,
                                                  )
                                                : allList.callType ==
                                                            "group_audio_call" &&
                                                        allList.message ==
                                                            "missed call"
                                                    ? const Image(
                                                        image: AssetImage(
                                                            'assets/images/NotRecive.png'),
                                                        height: 20,
                                                      )
                                                    //____________________________GROUP VIDEO CALL STATUS______________________________________
                                                    : allList.callType ==
                                                                "group_video_call" &&
                                                            allList.message ==
                                                                "" &&
                                                            allList.isComeing ==
                                                                "Incoming"
                                                        ? const Image(
                                                            image: AssetImage(
                                                                'assets/images/videoo.png'),
                                                            height: 20,
                                                          )
                                                        : allList.callType ==
                                                                    "group_video_call" &&
                                                                allList.message ==
                                                                    "" &&
                                                                allList.isComeing ==
                                                                    "Outgoing"
                                                            ? const Image(
                                                                image: AssetImage(
                                                                    'assets/images/videoo.png'),
                                                                height: 20,
                                                              )
                                                            : allList.callType ==
                                                                        "group_video_call" &&
                                                                    allList.message ==
                                                                        "missed call"
                                                                ? const Image(
                                                                    image: AssetImage(
                                                                        'assets/images/videocall_missed.png'),
                                                                    height: 20,
                                                                  )
                                                                : const SizedBox()
              ],
            ),
          )
        ],
      ),
    );
  }

//---------------------------------------------------- VIDEO MISSED CALL WIDGET ------------------------------------------------
  Widget videocallwidget(VideoCallList videoCallList) {
    String getContact(mobile) {
      if (mobile != null) {
        var name = mobile;
        bool found = false;
        for (var i = 0; i < allcontacts.length; i++) {
          if (allcontacts[i]
              .phones
              .map((e) => e.number)
              .toString()
              .replaceAll(RegExp(r"\s+\b|\b\s"), "")
              .contains(mobile)) {
            name = allcontacts[i].displayName;
            found = true;
            break; // Once found, no need to continue searching
          }
        }
        if (!found) {
          return videoCallList
              .username!; // Return username if contact not found
        }
        return name;
      } else {
        return mobile;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: CustomCachedNetworkImage(
                    imageUrl: videoCallList.profilePic!,
                    errorWidgeticon: Icon(
                      videoCallList.groupname == ""
                          ? Icons.person
                          : Icons.groups_2,
                      size: 30,
                    ))),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  videoCallList.groupname == ""
                      ? capitalizeFirstLetter(
                          getContact(getMobile(videoCallList.mobileNumber!)))
                      : capitalizeFirstLetter(videoCallList.groupname!),
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                ),
                Text(
                  formatDateTime(DateTime.parse(videoCallList.timestamp!)),
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: appgrey2),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                videoCallList.callType == "video_call" &&
                        videoCallList.message == ""
                    ? const Image(
                        image: AssetImage('assets/images/videoo.png'),
                        height: 20,
                      )
                    : videoCallList.callType == "group_video_call"
                        ? const Image(
                            image: AssetImage('assets/images/videoo.png'),
                            height: 20,
                          )
                        : videoCallList.callType == "group_video_call" &&
                                videoCallList.message == "missed call"
                            ? const Image(
                                image: AssetImage(
                                    'assets/images/videocall_missed.png'),
                                height: 20,
                              )
                            : videoCallList.callType == "video_call" &&
                                    videoCallList.message == "missed call"
                                ? const Image(
                                    image: AssetImage(
                                        'assets/images/videocall_missed.png'),
                                    height: 20,
                                  )
                                : videoCallList.callType == "video_call" &&
                                        videoCallList.message ==
                                            "missed call" &&
                                        videoCallList.isComeing == "Outgoing"
                                    ? const Image(
                                        image: AssetImage(
                                            'assets/images/videocall_missed.png'),
                                        height: 20,
                                      )
                                    : const SizedBox()
                //          Image(
                //   image: AssetImage('assets/images/videoo.png'),
                //   height: 15,
                // )
              ],
            ),
          )
        ],
      ),
    );
  }

//---------------------------------------------------- AUDIO MISSED CALL WIDGET ------------------------------------------------
  Widget missedwidget(MissedCallList missCallList) {
    String getContact(mobile) {
      if (mobile != null) {
        var name = mobile;
        bool found = false;
        for (var i = 0; i < allcontacts.length; i++) {
          if (allcontacts[i]
              .phones
              .map((e) => e.number)
              .toString()
              .replaceAll(RegExp(r"\s+\b|\b\s"), "")
              .contains(mobile)) {
            name = allcontacts[i].displayName;
            found = true;
            break; // Once found, no need to continue searching
          }
        }
        if (!found) {
          return missCallList.username!; // Return username if contact not found
        }
        return name;
      } else {
        return mobile;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: CustomCachedNetworkImage(
                    imageUrl: missCallList.profilePic!,
                    errorWidgeticon: Icon(
                      missCallList.groupname == ""
                          ? Icons.person
                          : Icons.groups_2,
                      size: 30,
                    ))),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  capitalizeFirstLetter(
                      getContact(getMobile(missCallList.mobileNumber!))),
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                ),
                Text(
                  formatDateTime(DateTime.parse(missCallList.timestamp!)),
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: appgrey2),
                ),
              ],
            ),
          ),
          const Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Image(
                  image: AssetImage('assets/images/NotRecive.png'),
                  height: 13,
                )
              ],
            ),
          )
        ],
      ),
    );
  }

//------------------------------------
  Widget loaderWidget() {
    return Stack(
      children: [
        Container(
            // height: MediaQuery.of(context).size.height * 0.9,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30))),
            child: Container(
              color: Colors.transparent,
              height: MediaQuery.of(context).size.height,
              child: DefaultTabController(
                length: 3,
                child: Column(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: appgrey2),
                          borderRadius: BorderRadius.circular(10)),
                      child: ButtonsTabBar(
                        borderWidth: 1,
                        unselectedBorderColor: Colors.transparent,
                        borderColor: Colors.transparent,
                        backgroundColor: chatownColor,
                        unselectedBackgroundColor: Colors.transparent,
                        unselectedLabelStyle: const TextStyle(color: appgrey2),
                        labelStyle: TextStyle(
                            color: selectedindex == 0 ? Colors.black : appgrey2,
                            fontWeight: FontWeight.w500,
                            fontSize: 14),
                        onTap: (p0) {
                          setState(() {
                            selectedindex = p0;
                          });
                        },
                        tabs: [
                          Tab(
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 25,
                                ),
                                Image.asset(
                                  'assets/images/callVector.png',
                                  width: 16,
                                  height: 16,
                                  color: selectedindex == 0
                                      ? Colors.black
                                      : appgrey2,
                                ),
                                // Adjust the spacing between image and text
                                Text(
                                  "  All         ",
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: selectedindex == 1
                                          ? appgrey2
                                          : Colors.black),
                                ),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 18,
                                ),
                                Image.asset(
                                  'assets/images/Video 3.png',
                                  width: 16,
                                  height: 16,
                                  color: selectedindex == 1
                                      ? Colors.black
                                      : appgrey2,
                                ),
                                // Adjust the spacing between image and text
                                Text(
                                  "   Video Call   ",
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
                          Tab(
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 20,
                                ),
                                Image.asset(
                                  'assets/images/Call Missed.png',
                                  width: 16,
                                  height: 16,
                                  color: selectedindex == 2
                                      ? Colors.black
                                      : appgrey2,
                                ),
                                // Adjust the spacing between image and text
                                Text(
                                  "   Missed     ",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: selectedindex == 2
                                        ? Colors.black
                                        : appgrey2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 330),
                    loader(context)
                  ],
                ),
              ),
            )),
        // inController.isOnline.value
        //     ? const SizedBox.shrink()
        //     : Positioned(
        //         bottom: 0.5,
        //         child: Container(
        //             width: Get.width,
        //             decoration: const BoxDecoration(color: chatownColor),
        //             child: Center(
        //               child: const Text(
        //                 "No Internet",
        //                 style: TextStyle(fontSize: 15, color: chatColor),
        //               ).paddingSymmetric(vertical: 8),
        //             )),
        //       ),
      ],
    );
  }
}
