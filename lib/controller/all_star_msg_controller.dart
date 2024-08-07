// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:meyaoo_new/Models/all_starred_msg_list.dart';
import 'package:meyaoo_new/controller/reply_msg_controller.dart';
import 'package:meyaoo_new/src/global/api_helper.dart';
import 'package:http/http.dart' as http;
import 'package:meyaoo_new/src/global/strings.dart';

final ApiHelper apiHelper = ApiHelper();

class AllStaredMsgController extends GetxController {
  RxBool isLoading = false.obs;
  Rx<AllStaredMsgModel?> starMessageModel = AllStaredMsgModel().obs;
  RxList<StarMessageList> allStarred = <StarMessageList>[].obs;

  getAllStarMsg(conversationid) async {
    isLoading.value = true;

    try {
      var uri = Uri.parse(apiHelper.allStarredUrl);
      var request = http.MultipartRequest("POST", uri);
      Map<String, String> headers = {
        'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
        "Accept": "application/json",
      };
      request.headers.addAll(headers);
      request.fields['conversation_id'] = conversationid;

      var response = await request.send();
      print(response.statusCode);
      String responseData =
          await response.stream.transform(utf8.decoder).join();
      var userData = json.decode(responseData);
      starMessageModel.value = AllStaredMsgModel.fromJson(userData);
      print(responseData);
      allStarred.clear();
      if (starMessageModel.value!.success == true) {
        if (starMessageModel.value != null) {
          for (var i = 0;
              i < starMessageModel.value!.starMessageList!.length;
              i++) {
            allStarred.add(starMessageModel.value!.starMessageList![i]);
          }

          for (var i = 0;
              i < starMessageModel.value!.starMessageList!.length;
              i++) {
            if (allStarred[i].chat!.replyId != 0) {
              print("INDEXXXX:$i");
              Get.put(ReplyMsgController()).getReplyDataApi(
                  replyMsgId: allStarred[i].chat!.replyId.toString(), index: i);
            }
          }
        }
        isLoading.value = false;
      } else {
        isLoading.value = false;
      }
    } catch (e) {
      isLoading.value = false;
    } finally {
      isLoading.value = false;
    }
  }
}
