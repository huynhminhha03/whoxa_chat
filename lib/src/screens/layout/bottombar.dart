// ignore_for_file: avoid_print, unnecessary_brace_in_string_interps, deprecated_member_use, unused_field

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:meyaoo_new/Models/user_profile_model.dart';
import 'package:meyaoo_new/app.dart';
import 'package:meyaoo_new/controller/add_contact_controller.dart';
import 'package:meyaoo_new/controller/all_block_list_controller.dart';
import 'package:meyaoo_new/controller/all_star_msg_controller.dart';
import 'package:meyaoo_new/controller/avatar_controller.dart';
import 'package:meyaoo_new/controller/call_controller.dart/get_roomId_controller.dart';
import 'package:meyaoo_new/controller/online_controller.dart';
import 'package:meyaoo_new/controller/single_chat_controller.dart';
import 'package:meyaoo_new/controller/user_chatlist_controller.dart';
import 'package:meyaoo_new/controller/get_contact_controller.dart';
import 'package:meyaoo_new/main.dart';
import 'package:meyaoo_new/src/global/api_helper.dart';
import 'package:meyaoo_new/src/global/global.dart';
import 'package:meyaoo_new/src/global/strings.dart';
import 'package:meyaoo_new/src/screens/chat/chats.dart';
import 'package:meyaoo_new/src/screens/layout/contact_new.dart';
import 'package:meyaoo_new/src/screens/layout/story/stroy.dart';
import 'package:meyaoo_new/src/screens/user/profile.dart';
import 'package:meyaoo_new/src/screens/calllist/call_list.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class TabbarScreen extends StatefulWidget {
  int? currentTab;
  Widget currentPage = const Chats();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  TabbarScreen({super.key, this.currentTab}) {
    currentTab = currentTab ?? 0;
  }
  @override
  // ignore: library_private_types_in_public_api
  _TabbarScreenState createState() {
    return _TabbarScreenState();
  }
}

class _TabbarScreenState extends State<TabbarScreen>
    with WidgetsBindingObserver {
  OnlineOfflineController controller = Get.put(OnlineOfflineController());
  ChatListController chatListController = Get.put(ChatListController());
  GetAllDeviceContact getAllDeviceContact = Get.put(GetAllDeviceContact());
  RoomIdController getRoomController = Get.put(RoomIdController());
  AddContactController addContactController = Get.put(AddContactController());
  SingleChatContorller singleChatContorller = Get.put(SingleChatContorller());
  AllBlockListController allBlockListController =
      Get.put(AllBlockListController());
  AllStaredMsgController allStaredMsgController =
      Get.put(AllStaredMsgController());
  AvatarController avatarController = Get.put(AvatarController());
  String _timeZone = 'Fetching time zone...';

  void _selectTab(int tabItem) {
    setState(() {
      widget.currentTab = tabItem;
      switch (tabItem) {
        case 0:
          widget.currentPage = const Chats();
          break;
        case 1:
          widget.currentPage = const StorySectionScreen();
          break;

        case 2:
          widget.currentPage = const call_history();
          break;
        case 3:
          widget.currentPage = FlutterContactsExample(isValue: false);
          //Contact();
          break;

        case 4:
          widget.currentPage = const Profile();
          break;
      }
    });
  }

  String _fcmtoken = "";
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  Future<bool> _getToken() async {
    if (Platform.isIOS) {
      await firebaseMessaging.getAPNSToken().then((token) {
        setState(() {
          _fcmtoken = token!;
        });
      });
    } else if (Platform.isAndroid) {
      await firebaseMessaging.getToken().then((token) {
        setState(() {
          _fcmtoken = token!;
        });
      });
    }

    return true;
  }

  bool isLoading = false;
  final ApiHelper apiHelper = ApiHelper();
  UserProfileModel userProfileModel = UserProfileModel();
  editApiCall() async {
    await _getToken();
    closeKeyboard();

    setState(() {
      isLoading = true;
    });

    var uri = Uri.parse(apiHelper.userCreateProfile);
    var request = http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
      'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}'
    };
    request.headers.addAll(headers);
    request.fields['device_token'] = _fcmtoken;
    request.fields['one_signal_player_id'] =
        OneSignal.User.pushSubscription.id!;

    print(request.fields);

    var response = await request.send();

    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);
    userProfileModel = UserProfileModel.fromJson(userData);

    print(responseData);

    if (userProfileModel.success == true) {
      await Hive.box(userdata)
          .put(userBio, userProfileModel.resData!.bio.toString());
      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

//=============================================================== UTC TIME ZONE =========================================================
//=============================================================== UTC TIME ZONE =========================================================
//=============================================================== UTC TIME ZONE =========================================================
  Future<void> _fetchTimeZone() async {
    try {
      Position position = await _getCurrentLocation();
      String timeZone =
          await _getTimeZoneFromApi(position.latitude, position.longitude);
      setState(() {
        _timeZone = timeZone;
      });
      // Store the time zone name in Hive
      await Hive.box(userdata).put(utcLocaName, timeZone);
      log("UTC_NAME:${Hive.box(userdata).get(utcLocaName)}");
    } catch (e) {
      setState(() {
        _timeZone = 'Error fetching time zone: $e';
      });
    }
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<String> _getTimeZoneFromApi(double latitude, double longitude) async {
    const String apiKey = 'AIzaSyAMZ4GbRFYSevy7tMaiH5s0JmMBBXc0qBA';
    final String url =
        'https://maps.googleapis.com/maps/api/timezone/json?location=$latitude,$longitude&timestamp=${DateTime.now().millisecondsSinceEpoch ~/ 1000}&key=$apiKey';

    int retries = 3;
    while (retries > 0) {
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          return data['timeZoneId'];
        } else {
          throw Exception(
              'Failed to get time zone data: ${response.statusCode}');
        }
      } on SocketException catch (_) {
        if (retries == 1) {
          throw Exception('Network error');
        }
        await Future.delayed(const Duration(seconds: 2));
      } on TimeoutException catch (_) {
        if (retries == 1) {
          throw Exception('Timeout error');
        }
        await Future.delayed(const Duration(seconds: 2));
      }
      retries--;
    }
    throw Exception('Failed to get time zone data after retries');
  }

  @override
  initState() {
    widget.currentPage =
        widget.currentTab == 4 ? const Profile() : const Chats();
    WidgetsBinding.instance.addObserver(this);
    if (Hive.box(userdata).get(authToken) == '' &&
        Hive.box(userdata).get(authToken) == null) {
      socketIntilized.initlizedsocket();
    }
    editApiCall();
    _fetchTimeZone();
    permissionAcessPhone();
    getRoomController.callHistory();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  String _getIndianUtcTime() {
    final now =
        DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(now);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    print('State☺☺☺☺☺☺☺☺☺☺☺☺☺☺: $state');
    setState(() {
      if (state == AppLifecycleState.detached) {
        isOnline = "Online";
        //chatListController.forOnlineUser();
        controller.forData();
        print("state: $state");
      } else if (state == AppLifecycleState.inactive) {
        isOnline = _getIndianUtcTime();
        controller.offlineUser();
        print("state: $state");
      } else if (state == AppLifecycleState.paused) {
        isOnline = _getIndianUtcTime();
        controller.offlineUser();
        print("state: $state");
      } else if (state == AppLifecycleState.resumed) {
        isOnline = "Online";
        //chatListController.forOnlineUser();
        controller.forData();
        print("state: $state");
      }
    });
  }

  permissionAcessPhone() async {
    var permission = await Permission.contacts.request();
    if (permission.isGranted) {
      await addContactController.getContactsFromGloble();
      print("@@@@@@@@@@@: ${addContactController.mobileContacts.runtimeType}");
      log("MY_DEVICE_CONTACS: ${addContactController.mobileContacts}");
      // var contactJson = json.encode(addContactController.mobileContacts);
      // //jsonEncode(mobileContacts);
      // //log("JSON: $contactJson");
      // getAllDeviceContact.getAllContactApi(contact: contactJson);
    } else {
      permissionAcessPhone();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
          key: widget.scaffoldKey,
          body: widget.currentPage,
          // body:
          // _handlePages[_currentIndex],
          bottomNavigationBar: Container(
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                  color: Colors.grey.shade300,
                  offset: const Offset(0.0, 4.0),
                  blurRadius: 15,
                  spreadRadius: 0)
            ]),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(0),
                topLeft: Radius.circular(0),
              ),
              child: BottomNavigationBar(
                selectedIconTheme: const IconThemeData(color: chatownColor),
                selectedItemColor: Colors.black,
                selectedFontSize: 10,
                unselectedFontSize: 10,
                unselectedLabelStyle: const TextStyle(color: Colors.white),
                selectedLabelStyle: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 10),
                backgroundColor: Colors.white,
                type: BottomNavigationBarType.fixed,
                currentIndex: widget.currentTab!,
                onTap: (int i) {
                  _selectTab(i);
                },
                items: <BottomNavigationBarItem>[
                  widget.currentTab == 0
                      ? BottomNavigationBarItem(
                          icon: const Image(
                              image: AssetImage('assets/icons/chat1.png'),
                              width: 24),
                          label: languageController.textTranslate('Chat'))
                      : const BottomNavigationBarItem(
                          icon: Image(
                            image: AssetImage('assets/images/message-text.png'),
                            width: 24,
                            color: chatColor,
                          ),
                          label: ""),
                  widget.currentTab == 1
                      ? BottomNavigationBarItem(
                          //status2
                          icon: const Image(
                              image: AssetImage('assets/icons/status1.png'),
                              width: 24),
                          label: languageController.textTranslate('Status'))
                      : const BottomNavigationBarItem(
                          icon: Image(
                              image: AssetImage('assets/images/status2.png'),
                              width: 24,
                              color: chatColor),
                          label: ""),
                  widget.currentTab == 2
                      ? BottomNavigationBarItem(
                          icon: const Image(
                              image: AssetImage('assets/icons/call1.png'),
                              width: 24),
                          label: languageController.textTranslate('Call'))
                      : const BottomNavigationBarItem(
                          icon: Image(
                            image: AssetImage('assets/images/call_1.png'),
                            width: 24,
                            color: chatColor,
                          ),
                          label: ""),
                  widget.currentTab == 3
                      ? BottomNavigationBarItem(
                          icon: const Image(
                              image: AssetImage('assets/icons/contact1.png'),
                              width: 25),
                          label: languageController.textTranslate('Contact'))
                      : const BottomNavigationBarItem(
                          icon: Image(
                            image: AssetImage('assets/images/contacts.png'),
                            width: 25,
                            color: Colors.black,
                          ),
                          label: ""),
                  widget.currentTab == 4
                      ? BottomNavigationBarItem(
                          icon: const Image(
                              image: AssetImage('assets/icons/setting1.png'),
                              width: 24),
                          label: languageController.textTranslate('Profile'))
                      : const BottomNavigationBarItem(
                          icon: Image(
                            image: AssetImage('assets/images/setting.png'),
                            width: 24,
                            color: Colors.black,
                          ),
                          label: "",
                        ),
                ],
              ),
            ),
          )),
    );
  }
}
