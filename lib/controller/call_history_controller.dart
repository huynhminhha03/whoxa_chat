// ignore_for_file: avoid_print

import 'package:get/get.dart';
import 'package:meyaoo_new/Models/calllistmodel.dart';
import 'package:meyaoo_new/Models/get_all_audiocall_list_model.dart';
import 'package:meyaoo_new/Models/get_all_videocall_list_model.dart';

class CallHistoryController extends GetxController {
  // InternetController inController = Get.find<InternetController>();
  RxBool isLoading = true.obs;
  Rx<CalllistModel?> callListModel = CalllistModel().obs;
  Rx<GetAllVideoCallListModel?> videoCallListModel =
      GetAllVideoCallListModel().obs;
  Rx<GetAllAudioCallListModel?> audioCallListModel =
      GetAllAudioCallListModel().obs;

  Future<void> callHistoryApi() async {

    // try {
    //   // if (inController.isOnline.value) {
    //   //   isLoading.value = true;
    //   //   var uri = Uri.parse('${baseUrl()}GetCallList');
    //   //   var request = http.MultipartRequest("POST", uri);
    //   //   Map<String, String> headers = {
    //   //     "Accept": "application/json",
    //   //   };

    //   //   request.headers.addAll(headers);
    //   //   // request.fields['from_user'] = widget.fromuser;
    //   //   request.fields['user_id'] = Hive.box(userdata).get(userId);
    //   //   request.fields['call_type'] = "all";
    //   //   var response = await request.send();
    //   //   print(response.statusCode);

    //   //   String responseData =
    //   //       await response.stream.transform(utf8.decoder).join();
    //   //   var userData = jsonDecode(responseData);
    //   //   box.put(HiveKeyService.callListKey, responseData);
    //   //   var getChat = box.get(HiveKeyService.callListKey);
    //   //   print("ABCD:$getChat");

    //   //   callListModel.value = CalllistModel.fromJson(userData);
    //   //   log("ALL:::::$responseData");
    //   // } else {
    //   //   var getChat = box.get(HiveKeyService.callListKey);
    //   //   if (getChat != null) {
    //   //     var getJsonData = json.decode(getChat);
    //   //     print("GETDATA:$getJsonData");
    //   //     callListModel.value = CalllistModel.fromJson(getJsonData);
    //   //   }
    //   // }
    //   isLoading.value = true;
    //   var uri = Uri.parse('${baseUrl()}GetCallList');
    //   var request = http.MultipartRequest("POST", uri);
    //   Map<String, String> headers = {
    //     "Accept": "application/json",
    //   };

    //   request.headers.addAll(headers);
    //   // request.fields['from_user'] = widget.fromuser;
    //   request.fields['user_id'] = Hive.box(userdata).get(userId);
    //   request.fields['call_type'] = "all";
    //   var response = await request.send();
    //   print(response.statusCode);

    //   String responseData =
    //       await response.stream.transform(utf8.decoder).join();
    //   var userData = jsonDecode(responseData);
    //   box.put(HiveKeyService.callListKey, responseData);
    //   var getChat = box.get(HiveKeyService.callListKey);
    //   print("ABCD:$getChat");

    //   callListModel.value = CalllistModel.fromJson(userData);
    //   log("ALL:::::$responseData");
    // } catch (e) {
    //   print(e);
    // } finally {
    //   isLoading.value = false;
    // }
  }

  Future<void> callHistoryApiVideo() async {

    // try {
    //   // if (inController.isOnline.value) {
    //   //   isLoading.value = true;
    //   //   var uri = Uri.parse('${baseUrl()}VideoCallList');
    //   //   var request = http.MultipartRequest("POST", uri);
    //   //   Map<String, String> headers = {
    //   //     "Accept": "application/json",
    //   //   };

    //   //   request.headers.addAll(headers);
    //   //   // request.fields['from_user'] = widget.fromuser;
    //   //   request.fields['user_id'] = Hive.box(userdata).get(userId);
    //   //   request.fields['call_type'] = "video_call";
    //   //   var response = await request.send();
    //   //   print(response.statusCode);

    //   //   String responseData =
    //   //       await response.stream.transform(utf8.decoder).join();
    //   //   var userData = jsonDecode(responseData);
    //   //   box.put(HiveKeyService.callListKey1, responseData);
    //   //   var getChat = box.get(HiveKeyService.callListKey1);
    //   //   print("ABCD:$getChat");

    //   //   videoCallListModel.value = GetAllVideoCallListModel.fromJson(userData);
    //   //   log("ALL_VIDEO:::::$responseData");
    //   // } else {
    //   //   var getChat = box.get(HiveKeyService.callListKey1);
    //   //   if (getChat != null) {
    //   //     var getJsonData = json.decode(getChat);
    //   //     print("VIDEOGETDATA:$getJsonData");
    //   //     videoCallListModel.value =
    //   //         GetAllVideoCallListModel.fromJson(getJsonData);
    //   //     videoCallListModel.refresh();
    //   //   }
    //   // }
    //   isLoading.value = true;
    //   var uri = Uri.parse('${baseUrl()}VideoCallList');
    //   var request = http.MultipartRequest("POST", uri);
    //   Map<String, String> headers = {
    //     "Accept": "application/json",
    //   };

    //   request.headers.addAll(headers);
    //   // request.fields['from_user'] = widget.fromuser;
    //   request.fields['user_id'] = Hive.box(userdata).get(userId);
    //   request.fields['call_type'] = "video_call";
    //   var response = await request.send();
    //   print(response.statusCode);

    //   String responseData =
    //       await response.stream.transform(utf8.decoder).join();
    //   var userData = jsonDecode(responseData);
    //   box.put(HiveKeyService.callListKey1, responseData);
    //   var getChat = box.get(HiveKeyService.callListKey1);
    //   print("ABCD:$getChat");

    //   videoCallListModel.value = GetAllVideoCallListModel.fromJson(userData);
    //   log("ALL_VIDEO:::::$responseData");
    // } catch (e) {
    //   print(e);
    // } finally {
    //   isLoading.value = false;
    // }
  }

  Future<void> callHistoryApiAudio() async {

    // try {
    //   // if (inController.isOnline.value) {
    //   //   isLoading.value = true;
    //   //   var uri = Uri.parse('${baseUrl()}AudioCallList');
    //   //   var request = http.MultipartRequest("POST", uri);
    //   //   Map<String, String> headers = {
    //   //     "Accept": "application/json",
    //   //   };

    //   //   request.headers.addAll(headers);
    //   //   // request.fields['from_user'] = widget.fromuser;
    //   //   request.fields['user_id'] = Hive.box(userdata).get(userId);
    //   //   request.fields['call_type'] = "audio_call";
    //   //   var response = await request.send();
    //   //   print(response.statusCode);

    //   //   String responseData =
    //   //       await response.stream.transform(utf8.decoder).join();
    //   //   var userData = jsonDecode(responseData);
    //   //   box.put(HiveKeyService.callListKey2, responseData);
    //   //   var getChat = box.get(HiveKeyService.callListKey2);
    //   //   print("ABCD:$getChat");

    //   //   audioCallListModel.value = GetAllAudioCallListModel.fromJson(userData);
    //   //   log("ALL_AUDIO:::::$responseData");
    //   // } else {
    //   //   var getChat = box.get(HiveKeyService.callListKey2);
    //   //   if (getChat != null) {
    //   //     var getJsonData = json.decode(getChat);
    //   //     print("AUDIOGETDATA:$getJsonData");
    //   //     audioCallListModel.value =
    //   //         GetAllAudioCallListModel.fromJson(getJsonData);
    //   //   }
    //   // }
    //   isLoading.value = true;
    //   var uri = Uri.parse('${baseUrl()}AudioCallList');
    //   var request = http.MultipartRequest("POST", uri);
    //   Map<String, String> headers = {
    //     "Accept": "application/json",
    //   };

    //   request.headers.addAll(headers);
    //   // request.fields['from_user'] = widget.fromuser;
    //   request.fields['user_id'] = Hive.box(userdata).get(userId);
    //   request.fields['call_type'] = "audio_call";
    //   var response = await request.send();
    //   print(response.statusCode);

    //   String responseData =
    //       await response.stream.transform(utf8.decoder).join();
    //   var userData = jsonDecode(responseData);
    //   box.put(HiveKeyService.callListKey2, responseData);
    //   var getChat = box.get(HiveKeyService.callListKey2);
    //   print("ABCD:$getChat");

    //   audioCallListModel.value = GetAllAudioCallListModel.fromJson(userData);
    //   log("ALL_AUDIO:::::$responseData");
    // } catch (e) {
    //   print(e);
    // } finally {
    //   isLoading.value = false;
    // }
  }
}
