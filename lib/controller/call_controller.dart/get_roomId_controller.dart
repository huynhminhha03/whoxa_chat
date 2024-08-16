// ignore_for_file: avoid_print, file_names, non_constant_identifier_names

import 'dart:convert';

import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:meyaoo_new/Models/calls_Model/get_roomId.dart';
import 'package:http/http.dart' as http;
import 'package:meyaoo_new/src/Notification/notification_service.dart';
import 'package:meyaoo_new/src/global/api_helper.dart';
import 'package:meyaoo_new/src/global/global.dart';
import 'package:meyaoo_new/src/global/strings.dart';
// import 'package:meyaoo_new/src/screens/call/web_rtc/web_rtc.dart';

final ApiHelper apiHelper = ApiHelper();

class RoomIdController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isCallCutByMeLoading = false.obs;
  RxBool isCallCutByReceiverLoading = false.obs;
  Rx<GetRoomIdModel?> roomModel = GetRoomIdModel().obs;

  getRoomModelApi({String? conversationID, String? callType}) async {
    isLoading(true);
    try {
      var uri = Uri.parse(apiHelper.getRoomIdUrl);
      var request = http.MultipartRequest("POST", uri);
      Map<String, String> headers = {
        'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
        "Accept": "application/json",
      };

      request.headers.addAll(headers);
      request.fields['conversation_id'] = conversationID!;
      request.fields['call_type'] = callType!;

      print("FILEDS:${request.fields}");

      var response = await request.send();
      String responseData =
          await response.stream.transform(utf8.decoder).join();
      var userData = json.decode(responseData);

      roomModel.value = GetRoomIdModel.fromJson(userData);

      print("DATA:$responseData");

      if (roomModel.value!.success == true) {
        // Get.to(() => CallScreen(
        //     roomID: roomModel.value!.roomId, conversation_id: conversationID));
        isLoading(false);
      } else {
        isLoading(false);
        showCustomToast("Something went wrong...!");
      }
    } catch (e) {
      isLoading(false);
      print(e.toString());
    } finally {
      isLoading(false);
    }
  }

  callCutByMe(
      {required String conversationID, required String callType}) async {
    isCallCutByMeLoading(true);
    try {
      var uri = Uri.parse(apiHelper.callCutByMe);
      var request = http.MultipartRequest("POST", uri);
      Map<String, String> headers = {
        'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
        "Accept": "application/json",
      };

      request.headers.addAll(headers);
      request.fields['conversation_id'] = conversationID;
      request.fields['call_type'] = callType;
      request.fields['message_id'] = roomModel.value!.messageId.toString();

      print("FILEDS:${request.fields}");

      var response = await request.send();
      String responseData =
          await response.stream.transform(utf8.decoder).join();
      var callCutByMeData = json.decode(responseData);

      print("callCutByMeData: $callCutByMeData");

      if (callCutByMeData["success"] == true) {
        Get.back();
        // Get.to(() => CallScreen(
        //     roomID: roomModel.value!.roomId, conversation_id: conversationID));
        isCallCutByMeLoading(false);
      } else {
        isCallCutByMeLoading(false);
        showCustomToast("Something went wrong...!");
      }
    } catch (e) {
      isCallCutByMeLoading(false);
      print(e.toString());
    } finally {
      isCallCutByMeLoading(false);
    }
  }

  callCutByReceiver({
    required String conversationID,
    required String message_id,
    required String caller_id,
  }) async {
    isCallCutByReceiverLoading(true);
    try {
      var uri = Uri.parse(apiHelper.callCutByReceiver);
      var request = http.MultipartRequest("POST", uri);
      Map<String, String> headers = {
        'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
        "Accept": "application/json",
      };

      request.headers.addAll(headers);
      request.fields['conversation_id'] = conversationID;
      request.fields['message_id'] = message_id;
      request.fields['caller_id'] = caller_id;

      print("callCutByReceiver FILEDS:${request.fields}");

      var response = await request.send();
      String responseData =
          await response.stream.transform(utf8.decoder).join();
      var callCutByReceiverData = json.decode(responseData);

      print("callCutByRcecieverData: $callCutByReceiverData");

      if (callCutByReceiverData["success"] == true) {
        LocalNotificationService.notificationsPlugin.cancelAll();
        Get.back();
        // Get.to(() => CallScreen(
        //     roomID: roomModel.value!.roomId, conversation_id: conversationID));
        isCallCutByReceiverLoading(false);
      } else {
        isCallCutByReceiverLoading(false);
        showCustomToast("Something went wrong...!");
      }
    } catch (e) {
      isCallCutByReceiverLoading(false);
      print(e.toString());
    } finally {
      isCallCutByReceiverLoading(false);
    }
  }
}
