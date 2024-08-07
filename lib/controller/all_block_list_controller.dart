// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:meyaoo_new/Models/block_list_model.dart';
import 'package:meyaoo_new/src/global/api_helper.dart';
import 'package:http/http.dart' as http;
import 'package:meyaoo_new/src/global/strings.dart';

final ApiHelper apiHelper = ApiHelper();

class AllBlockListController extends GetxController {
  RxBool isLoading = false.obs;
  Rx<GetBlockListModel?> blockListModel = GetBlockListModel().obs;
  RxList<BlockUserList> allBlock = <BlockUserList>[].obs;

  Future<void> getBlockListApi() async {
    isLoading.value = true;
    try {
      var uri = Uri.parse(apiHelper.blockUserList);
      var request = http.MultipartRequest("POST", uri);

      Map<String, String> headers = {
        'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
        "Accept": "application/json",
      };

      request.headers.addAll(headers);

      var response = await request.send();
      print(response.statusCode);
      String responseData =
          await response.stream.transform(utf8.decoder).join();
      var userData = json.decode(responseData);

      blockListModel.value = GetBlockListModel.fromJson(userData);
      allBlock.clear();
      if (blockListModel.value!.success == true) {
        if (blockListModel.value != null) {
          for (int i = 0;
              i < blockListModel.value!.blockUserList!.length;
              i++) {
            allBlock.add(blockListModel.value!.blockUserList![i]);
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
