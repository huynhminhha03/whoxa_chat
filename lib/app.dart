// ignore_for_file: avoid_print, empty_catches, unused_local_variable, use_build_context_synchronously, depend_on_referenced_packages, unused_import

import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
// import 'package:meyaoo_new/controller/call_history_controller.dart';
import 'package:meyaoo_new/controller/get_delete_story.dart';
import 'package:meyaoo_new/notification_service.dart';
import 'package:meyaoo_new/src/global/global.dart';
import 'package:meyaoo_new/src/global/strings.dart';
import 'package:meyaoo_new/src/screens/call/audio/audiocalling.dart';
import 'package:meyaoo_new/src/screens/call/audio/group_audio_call.dart';
import 'package:meyaoo_new/src/screens/call/video/group_video_call_recived.dart';
import 'package:meyaoo_new/src/screens/call/web_rtc/video_call_screen.dart';
import 'package:meyaoo_new/src/screens/user/create_profile.dart';
import 'package:meyaoo_new/welcome.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import 'src/screens/layout/bottombar.dart';

class AppScreen extends StatefulWidget {
  const AppScreen({super.key});

  @override
  State<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> with WidgetsBindingObserver {
  //CallHistoryController callController = Get.put(CallHistoryController());
  GetDeleteStroy deleteStroy = Get.put(GetDeleteStroy());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    requestPermissions();
    _checkPermissions();
    FirebaseMessaging.instance.getInitialMessage().then(
      (message) {
        print("FirebaseMessaging.instance.getInitialMessage");
        if (message != null) {
          print("New Notification");
          // if (message.data['title'] == 'Call Decline') {
          //   Get.to(ChatList());
          // }
        }
      },
    );

    FirebaseMessaging.onMessage.listen(
      (message) async {
        print("FirebaseMessaging.onMessage.listen");
        LocalNotificationService.notificationsPlugin.cancelAll();
        print("NOTIFICATION:::: ${message.data}");

        // if (message.data['call_type'] == 'video_call') {
        //   print('testing incoming video call');
        //   CallKitParams callKitParams = CallKitParams(
        //     id: const Uuid().v4(),
        //     nameCaller: 'Hien Nguyen',
        //     appName: 'Meyaoo',
        //     avatar: 'https://i.pravatar.cc/100',
        //     handle: '0123456789',
        //     type: 0,
        //     textAccept: 'Conform',
        //     textDecline: 'Reject',
        //     // missedCallNotification: const NotificationParams(
        //     //   showNotification: true,
        //     //   isShowCallback: true,
        //     //   subtitle: 'Missed call',
        //     //   callbackText: 'Call back',
        //     // ),
        //     duration: 30000,
        //     // extra: <String, dynamic>{'userId': '1a2b3c4d'},
        //     // headers: <String, dynamic>{
        //     //   'apiKey': 'Abc@123!',
        //     //   'platform': 'flutter'
        //     // },
        //     android: const AndroidParams(
        //       isCustomNotification: true,
        //       isShowLogo: true,
        //       ringtonePath: 'system_ringtone_default',
        //       backgroundColor: '#0955fa',
        //       backgroundUrl: 'https://i.pravatar.cc/500',
        //       actionColor: '#4CAF50',
        //       textColor: '#ffffff',
        //       incomingCallNotificationChannelName: "Incoming Call",
        //       missedCallNotificationChannelName: "Missed Call",
        //       isShowFullLockedScreen: true,
        //       isShowCallID: false,
        //     ),
        //     ios: const IOSParams(
        //       // iconName: 'CallKitLogo',
        //       handleType: 'generic',
        //       supportsVideo: true,
        //       maximumCallGroups: 2,
        //       maximumCallsPerCallGroup: 1,
        //       audioSessionMode: 'default',
        //       audioSessionActive: true,
        //       audioSessionPreferredSampleRate: 44100.0,
        //       audioSessionPreferredIOBufferDuration: 0.005,
        //       supportsDTMF: true,
        //       supportsHolding: true,
        //       supportsGrouping: false,
        //       supportsUngrouping: false,
        //       ringtonePath: 'system_ringtone_default',
        //     ),
        //   );
        //   await FlutterCallkitIncoming.showCallkitIncoming(callKitParams);
        //   FlutterCallkitIncoming.onEvent.listen((event) {
        //     switch (event!.event) {
        //       case Event.actionCallIncoming:
        //         print("NOTIFICATION EVENT actionCallIncoming");
        //         break;
        //       case Event.actionCallStart:
        //         print("NOTIFICATION EVENT actionCallStart");
        //         break;
        //       case Event.actionCallAccept:
        //         print("NOTIFICATION EVENT actionCallAccept");
        //         Get.to(
        //           VideoCallScreen(
        //             roomID: message.data['room_id'],
        //           ),
        //           transition: Transition.rightToLeft,
        //         );
        //         break;
        //       case Event.actionCallDecline:
        //         print("NOTIFICATION EVENT actionCallDecline");
        //         FlutterCallkitIncoming.endAllCalls();
        //         break;
        //       case Event.actionCallEnded:
        //         print("NOTIFICATION EVENT actionCallEnded");
        //         FlutterCallkitIncoming.endAllCalls();
        //         break;
        //       case Event.actionCallTimeout:
        //         print("NOTIFICATION EVENT actionCallTimeout");
        //         FlutterCallkitIncoming.endAllCalls();
        //         break;
        //       case Event.actionCallCallback:
        //         print("NOTIFICATION EVENT actionCallCallback");

        //         break;
        //       case Event.actionCallToggleHold:
        //         print("NOTIFICATION EVENT actionCallToggleHold");

        //         break;
        //       case Event.actionCallToggleMute:
        //         print("NOTIFICATION EVENT actionCallToggleMute");

        //         break;
        //       case Event.actionCallToggleDmtf:
        //         print("NOTIFICATION EVENT actionCallToggleDmtf");

        //         break;
        //       case Event.actionCallToggleGroup:
        //         print("NOTIFICATION EVENT actionCallToggleGroup");

        //         break;
        //       case Event.actionCallToggleAudioSession:
        //         print("NOTIFICATION EVENT actionCallToggleAudioSession");

        //         break;
        //       case Event.actionDidUpdateDevicePushTokenVoip:
        //         print("NOTIFICATION EVENT actionDidUpdateDevicePushTokenVoip");

        //         break;
        //       case Event.actionCallCustom:
        //         print("NOTIFICATION EVENT actionCallCustom");

        //         break;
        //     }
        //   });
        // } else {
        if (message.notification != null) {
          print(message.notification!.title);

          print(message.data['message']);

          print("message.data ${message.data}");
          if (message.data['title'] == 'Call Decline') {
            Get.to(TabbarScreen());
          }

          ///SIMPLE NOTIFICATION
          InitializationSettings initializationSettings =
              const InitializationSettings(
            android: AndroidInitializationSettings("@mipmap/ic_launcher"),
          );

          LocalNotificationService.notificationsPlugin.initialize(
            initializationSettings,
            //-----------------------------------------------------------------------------
            //--------------------------- WHEN APP BACKGROUND -----------------------------
            //-----------------------------------------------------------------------------
            onDidReceiveBackgroundNotificationResponse: (details) {
              if (details.actionId == 'accept') {
                print("accept");
                if (message.data['call_type'] == 'video_call') {
                  // Navigate to the desired screen based on the payload'
                  Get.to(VideoCallScreen(
                    roomID: message.data['room_id'],
                  ));
                } else if (message.data['title'] == 'Audio call') {
                  Get.to(VoiceCall(
                    fromChannelId: message.data['channel'],
                    fromToken: message.data['token'],
                    isCaller: false,
                    callerImage: message.data['caller_profile_pic'],
                    callerName: message.data['caller_name'],
                    isReciverWait: false,
                  ));
                } else if (message.data['title'] == 'Group Audio call') {
                  Get.to(() => GroupVoiceCall(
                        fromChannelId: message.data['channel'],
                        fromToken: message.data['token'],
                        isCaller: false,
                        callerImage: message.data['receiver_profile_pic'],
                        callerName: message.data['receiver_name'],
                        isReciverWait: false,
                      ));
                } else if (message.data['title'] == 'Group Video call') {
                  Get.to(() => GroupReceivedVideoCallScreen(
                        fromChannelId: message.data['channel'],
                        fromToken: message.data['token'],
                        isCaller: false,
                        callerImage: message.data['receiver_profile_pic'],
                        callerName: message.data['receiver_name'],
                        isReciverWait: false,
                      ));
                  // Get.to(() => GroupVideoCallScreen(
                  //       fromChannelId: message.data['channel'],
                  //       fromToken: message.data['token'],
                  //       isCaller: false,
                  //       callerImage: message.data['caller_profile_pic'],
                  //       callerName: message.data['receiver_name'],
                  //       isReciverWait: false,
                  //     ));
                }
              } else if (details.actionId == 'decline') {
                print("☺☺☺☺☺☺☺☺☺☺☺☺☺☺decline_background");
              } else {
                if (message.data['call_type'] == 'video_call') {
                  Get.to(VideoCallScreen(
                    roomID: message.data['room_id'],
                  ));
                  // Get.to(VideoCallPage(
                  //   callerImage: message.data['caller_profile_pic'],
                  //   callerName: message.data['caller_name'],
                  //   reciverImage: message.data['receiver_profile_pic'],
                  //   reciverName: message.data['receiver_name'],
                  //   isCaller: false,
                  //   isReciverWait: true,
                  //   waitChannelId: message.data['channel'],
                  //   waitToken: message.data['token'],
                  //   callerId: message.data['my_id'],
                  //   reciverId: message.data['toUser'],
                  // ));
                } else if (message.data['title'] == 'Audio call') {
                  Get.to(VoiceCall(
                    isCaller: false,
                    callerImage: message.data['caller_profile_pic'],
                    callerName: message.data['caller_name'],
                    isReciverWait: true,
                    waitChannelId: message.data['channel'],
                    waitToken: message.data['token'],
                    callerId: message.data['my_id'],
                    reciverId: message.data['toUser'],
                  ));
                } else if (message.data['title'] == 'Group Audio call') {
                  Get.to(() => GroupVoiceCall(
                        isCaller: false,
                        callerImage: message.data['receiver_profile_pic'],
                        callerName: message.data['receiver_name'],
                        isReciverWait: true,
                        waitChannelId: message.data['channel'],
                        waitToken: message.data['token'],
                        callerId: message.data['my_id'],
                        reciverId: message.data['toUser'],
                      ));
                } else if (message.data['title'] == 'Group video call') {
                  Get.to(() => GroupReceivedVideoCallScreen(
                        isCaller: false,
                        callerImage: message.data['receiver_profile_pic'],
                        callerName: message.data['receiver_name'],
                        isReciverWait: true,
                        waitChannelId: message.data['channel'],
                        waitToken: message.data['token'],
                        callerId: message.data['my_id'],
                        reciverId: message.data['toUser'],
                      ));
                } else if (message.data['title_done'] == 'Message') {
                  print("ID::::::");
                  // single chat message notification through navigate specific single_chat
                  // Get.to(() => SingelChatDetailsScreenTemp(
                  //       index: 0,
                  //       seconduserID: message.data['second_user_id'],
                  //       secondUsername: capitalizeFirstLetter(getContact1(
                  //           getMobile(message.data['mobile']),
                  //           message.data['second_username'])),
                  //       groupID: "",
                  //       groupName: "",
                  //       myID: message.data['my_id'],
                  //       isBlocked: "0",
                  //       seconduserpic: message.data['profile_image'],
                  //       phoneNumber: message.data['mobile'],
                  //       userStatus: "",
                  //       lastSeen: "",
                  //     ));
                } else if (message.data['title_done'] == 'group_message') {
                  print("GROUP::::");
                  // group chat message notification through navigate specific group_chat
                  // Get.to(() => GroupchatScreenTemp(
                  //       groupID: message.data['group_id'],
                  //       groupName: message.data['group_name'],
                  //       myID: Hive.box(userdata).get(userId),
                  //       seconduserpic: message.data['group_profile_image'],
                  //     ));
                }
              }
              // }
            },
            //-----------------------------------------------------------------------------------------------------------
            //------------------------------------------------- WEHN APP IS ALREADY OPEN THEN RECEIVED NOTIFI------------
            //-----------------------------------------------------------------------------------------------------------
            onDidReceiveNotificationResponse: (details) {
              if (details.actionId == 'accept') {
                print("accept");
                if (message.data['call_type'] == 'video_call') {
                  Get.to(VideoCallScreen(
                    roomID: message.data['room_id'],
                  ));
                  // Navigate to the desired screen based on the payload'
                  // Get.to(VideoCallPage(
                  //   fromChannelId: message.data['channel'],
                  //   fromToken: message.data['token'],
                  //   isCaller: false,
                  //   callerImage: message.data['caller_profile_pic'],
                  //   callerName: message.data['caller_name'],
                  //   isReciverWait: false,
                  // ));
                } else if (message.data['title'] == 'Audio call') {
                  Get.to(VoiceCall(
                    fromChannelId: message.data['channel'],
                    fromToken: message.data['token'],
                    isCaller: false,
                    callerImage: message.data['caller_profile_pic'],
                    callerName: message.data['caller_name'],
                    isReciverWait: false,
                  ));
                } else if (message.data['title'] == 'Group Audio call') {
                  Get.to(() => GroupVoiceCall(
                        fromChannelId: message.data['channel'],
                        fromToken: message.data['token'],
                        isCaller: false,
                        callerImage: message.data['receiver_profile_pic'],
                        callerName: message.data['receiver_name'],
                        isReciverWait: false,
                      ));
                } else if (message.data['title'] == 'Group Video call') {
                  Get.to(() => GroupReceivedVideoCallScreen(
                        fromChannelId: message.data['channel'],
                        fromToken: message.data['token'],
                        isCaller: false,
                        callerImage: message.data['receiver_profile_pic'],
                        callerName: message.data['receiver_name'],
                        isReciverWait: false,
                      ));
                }
              } else if (details.actionId == 'decline') {
                print("☺☺☺☺☺☺☺☺☺☺☺☺☺☺decline_insideapp");
              } else {
                if (message.data['call_type'] == 'video_call') {
                  Get.to(VideoCallScreen(
                    roomID: message.data['room_id'],
                  ));
                  // Get.to(VideoCallPage(
                  //   callerImage: message.data['caller_profile_pic'],
                  //   callerName: message.data['caller_name'],
                  //   reciverImage: message.data['receiver_profile_pic'],
                  //   reciverName: message.data['receiver_name'],
                  //   isCaller: false,
                  //   isReciverWait: true,
                  //   waitChannelId: message.data['channel'],
                  //   waitToken: message.data['token'],
                  //   callerId: message.data['my_id'],
                  //   reciverId: message.data['toUser'],
                  // ));
                } else if (message.data['title'] == 'Audio call') {
                  Get.to(VoiceCall(
                    isCaller: false,
                    callerImage: message.data['caller_profile_pic'],
                    callerName: message.data['caller_name'],
                    isReciverWait: true,
                    waitChannelId: message.data['channel'],
                    waitToken: message.data['token'],
                    callerId: message.data['my_id'],
                    reciverId: message.data['toUser'],
                  ));
                } else if (message.data['title'] == 'Group Audio call') {
                  Get.to(() => GroupVoiceCall(
                        isCaller: false,
                        callerImage: message.data['receiver_profile_pic'],
                        callerName: message.data['receiver_name'],
                        isReciverWait: true,
                        waitChannelId: message.data['channel'],
                        waitToken: message.data['token'],
                        callerId: message.data['my_id'],
                        reciverId: message.data['toUser'],
                      ));
                } else if (message.data['title'] == 'Group Video call') {
                  Get.to(() => GroupReceivedVideoCallScreen(
                        isCaller: false,
                        callerImage: message.data['receiver_profile_pic'],
                        callerName: message.data['receiver_name'],
                        isReciverWait: true,
                        waitChannelId: message.data['channel'],
                        waitToken: message.data['token'],
                        callerId: message.data['my_id'],
                        reciverId: message.data['toUser'],
                      ));
                } else if (message.data['title_done'] == 'Message') {
                  print("ID::::::");
                  // single chat message notification through navigate specific single_chat
                  // Get.to(() => SingelChatDetailsScreenTemp(
                  //       index: 0,
                  //       seconduserID: message.data['second_user_id'],
                  //       secondUsername: capitalizeFirstLetter(getContact1(
                  //           getMobile(message.data['mobile']),
                  //           message.data['second_username'])),
                  //       groupID: "",
                  //       groupName: "",
                  //       myID: message.data['my_id'],
                  //       isBlocked: "0",
                  //       seconduserpic: message.data['profile_image'],
                  //       phoneNumber: message.data['mobile'],
                  //       userStatus: "",
                  //       lastSeen: "",
                  //     ));
                } else if (message.data['title_done'] == 'group_message') {
                  print("GROUP::::");
                  // group chat message notification through navigate specific group_chat
                  // Get.to(() => GroupchatScreenTemp(
                  //       groupID: message.data['group_id'],
                  //       groupName: message.data['group_name'],
                  //       myID: Hive.box(userdata).get(userId),
                  //       seconduserpic: message.data['group_profile_image'],
                  //     ));
                }
              }
              // }
            },
          );
          LocalNotificationService.createanddisplaynotification(message);
        }
        // }
      },
    );

    // FirebaseMessaging.onMessageOpenedApp.listen(
    //   (message) async {
    //     print("FirebaseMessaging.onMessageOpenedApp.listen");
    //     if (message.data['call_type'] == 'video_call') {
    //       CallKitParams callKitParams = CallKitParams(
    //         id: const Uuid().v4(),
    //         nameCaller: 'Hien Nguyen',
    //         appName: 'Callkit',
    //         avatar: 'https://i.pravatar.cc/100',
    //         handle: '0123456789',
    //         type: 0,
    //         textAccept: 'Accept',
    //         textDecline: 'Decline',
    //         missedCallNotification: const NotificationParams(
    //           showNotification: true,
    //           isShowCallback: true,
    //           subtitle: 'Missed call',
    //           callbackText: 'Call back',
    //         ),
    //         duration: 30000,
    //         extra: <String, dynamic>{'userId': '1a2b3c4d'},
    //         headers: <String, dynamic>{
    //           'apiKey': 'Abc@123!',
    //           'platform': 'flutter'
    //         },
    //         android: const AndroidParams(
    //             isCustomNotification: true,
    //             isShowLogo: false,
    //             ringtonePath: 'system_ringtone_default',
    //             backgroundColor: '#0955fa',
    //             backgroundUrl: 'https://i.pravatar.cc/500',
    //             actionColor: '#4CAF50',
    //             textColor: '#ffffff',
    //             incomingCallNotificationChannelName: "Incoming Call",
    //             missedCallNotificationChannelName: "Missed Call",
    //             isShowCallID: false),
    //         ios: const IOSParams(
    //           // iconName: 'CallKitLogo',
    //           handleType: 'generic',
    //           supportsVideo: true,
    //           maximumCallGroups: 2,
    //           maximumCallsPerCallGroup: 1,
    //           audioSessionMode: 'default',
    //           audioSessionActive: true,
    //           audioSessionPreferredSampleRate: 44100.0,
    //           audioSessionPreferredIOBufferDuration: 0.005,
    //           supportsDTMF: true,
    //           supportsHolding: true,
    //           supportsGrouping: false,
    //           supportsUngrouping: false,
    //           ringtonePath: 'system_ringtone_default',
    //         ),
    //       );
    //       await FlutterCallkitIncoming.showCallkitIncoming(callKitParams);
    //     } else {
    //       if (message.notification != null) {
    //         print('title-----> ${message.notification!.title}');
    //         // print(message.notification!);

    //         print(message.data['message']);

    //         print('data--->> ${message.data}');

    //         if (message.data['title'] == 'Call Decline') {
    //           print('☺☺☺☺☺☺☺☺☺☺☺☺☺☺decline_app_closed');
    //           // Get.to(ChatList());
    //         } else if (message.data['call_type'] == 'video_call') {
    //           Get.to(VideoCallScreen(
    //             roomID: message.data['room_id'],
    //           ));
    //           // Get.to(VideoCallPage(
    //           //   callerImage: message.data['caller_profile_pic'],
    //           //   callerName: message.data['caller_name'],
    //           //   reciverImage: message.data['receiver_profile_pic'],
    //           //   reciverName: message.data['receiver_name'],
    //           //   isCaller: false,
    //           //   isReciverWait: true,
    //           //   waitChannelId: message.data['channel'],
    //           //   waitToken: message.data['token'],
    //           //   callerId: message.data['my_id'],
    //           //   reciverId: message.data['toUser'],
    //           // ));
    //         } else if (message.data['title'] == 'Audio call') {
    //           Get.to(VoiceCall(
    //             isCaller: false,
    //             callerImage: message.data['caller_profile_pic'],
    //             callerName: message.data['caller_name'],
    //             isReciverWait: true,
    //             waitChannelId: message.data['channel'],
    //             waitToken: message.data['token'],
    //             callerId: message.data['my_id'],
    //             reciverId: message.data['toUser'],
    //           ));
    //         } else if (message.data['title'] == 'Group Audio call') {
    //           Get.to(() => GroupVoiceCall(
    //                 isCaller: false,
    //                 callerImage: message.data['receiver_profile_pic'],
    //                 callerName: message.data['receiver_name'],
    //                 isReciverWait: true,
    //                 waitChannelId: message.data['channel'],
    //                 waitToken: message.data['token'],
    //                 callerId: message.data['my_id'],
    //                 reciverId: message.data['toUser'],
    //               ));
    //         } else if (message.data['title'] == 'Group Video call') {
    //           Get.to(() => GroupReceivedVideoCallScreen(
    //                 isCaller: false,
    //                 callerImage: message.data['receiver_profile_pic'],
    //                 callerName: message.data['receiver_name'],
    //                 isReciverWait: true,
    //                 waitChannelId: message.data['channel'],
    //                 waitToken: message.data['token'],
    //                 callerId: message.data['my_id'],
    //                 reciverId: message.data['toUser'],
    //               ));
    //         } else if (message.data['title_done'] == 'Message') {
    //           print("ID::::::");
    //           // single chat message notification through navigate specific single_chat
    //           // Get.to(() => SingelChatDetailsScreenTemp(
    //           //       index: 0,
    //           //       seconduserID: message.data['second_user_id'],
    //           //       secondUsername: capitalizeFirstLetter(getContact1(
    //           //           getMobile(message.data['mobile']),
    //           //           message.data['second_username'])),
    //           //       groupID: "",
    //           //       groupName: "",
    //           //       myID: message.data['my_id'],
    //           //       isBlocked: "0",
    //           //       seconduserpic: message.data['profile_image'],
    //           //       phoneNumber: message.data['mobile'],
    //           //       userStatus: "",
    //           //       lastSeen: "",
    //           //     ));
    //         } else if (message.data['title_done'] == 'group_message') {
    //           print("GROUP::::");
    //           // group chat message notification through navigate specific group_chat
    //           // Get.to(() => GroupchatScreenTemp(
    //           //       groupID: message.data['group_id'],
    //           //       groupName: message.data['group_name'],
    //           //       myID: Hive.box(userdata).get(userId),
    //           //       seconduserpic: message.data['group_profile_image'],
    //           //     ));
    //         }
    //       }
    //     }
    //   },
    // );

    deleteStroy.getDelete();
    // callController.callHistoryApi();
    // callController.callHistoryApiVideo();
    // callController.callHistoryApiAudio();
    log("AuthToken: ${Hive.box(userdata).get(authToken)}");
  }

  Future<void> _checkPermissions() async {
    if (await Permission.contacts.request().isGranted) {
      // You can access the contacts
      getContactsFromGloble();
    } else {
      // You can show a message to the user asking them to grant the permission
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Contacts permission is required to use this feature')),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   super.didChangeAppLifecycleState(state);
  //   print('State♥♥♥♥♥♥♥♥♥♥♥♥♥: $state');
  //   if (state == AppLifecycleState.paused ||
  //       state == AppLifecycleState.inactive) {
  //     // typingFunction("0");
  //     fetchData("0");
  //     // typingFunction(DateTime.now().millisecondsSinceEpoch.toString());
  //   } else if (state == AppLifecycleState.resumed ||
  //       state == AppLifecycleState.detached) {
  //     // typingFunction("1");
  //     fetchData("1");
  //   }
  // }

  // void typingFunction(String status) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('${baseUrl()}UserOnline'),
  //       body: {
  //         'user_id': Hive.box(userdata).get(userId),
  //         'is_online': status,
  //       },
  //     );
  //     print("USER_ONLINE☺☺☺☺☺☺☺☺☺☺:${response.body}");
  //     print("USER_ONLINE");
  //     if (response.statusCode == 200) {
  //     } else {}
  //   } catch (error) {}
  // }

  @override
  Widget build(BuildContext context) {
    return _handleCurrentScreen();
  }

  Widget _handleCurrentScreen() {
    var box = Hive.box(userdata);
    if (box.get(userId) != null &&
        box.get(authToken) != null &&
        box.get(lastName) != null &&
        box.get(lastName)!.isNotEmpty &&
        box.get(firstName) != null &&
        box.get(firstName)!.isNotEmpty) {
      return TabbarScreen();
    } else if (box.get(userId) == null &&
        box.get(authToken) == null &&
        box.get(lastName) == null &&
        box.get(firstName) == null) {
      return const Welcome();
    } else {
      return AddPersonaDetails(isback: false);
    }
    // if (Hive.box(userdata).get(userId) != null &&
    //     Hive.box(userdata).get(authToken) != null &&
    //     Hive.box(userdata).get(lastName) != null &&
    //     Hive.box(userdata).get(firstName) != null) {
    //   return TabbarScreen();
    // } else if (Hive.box(userdata).get(userId) == null &&
    //     Hive.box(userdata).get(authToken) == null &&
    //     Hive.box(userdata).get(lastName) == null &&
    //     Hive.box(userdata).get(firstName) == null) {
    //   return const Welcome();
    // } else {
    //   return AddPersonaDetails(isback: false);
    // }
  }

  Future<void> requestPermissions() async {
    // Request notification permission
    await Permission.notification.request();

    // Request location permission
    await Permission.location.request();

    // Request camera permission
    await Permission.camera.request();

    // Request microphone permission
    await Permission.microphone.request();

    // Request storage permission
    await Permission.storage.request();

    // Request photo library permission
    await Permission.photos.request();
  }
}
