import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:meyaoo_new/Models/get_avatars_model.dart';
import 'package:meyaoo_new/src/global/api_helper.dart';
import 'package:meyaoo_new/src/global/strings.dart';

class AvatarController extends GetxController {
  ApiHelper apiHelper = ApiHelper();
  RxBool isGetAvatarLoading = false.obs;
  RxList<Avtars> avatarsData = <Avtars>[].obs;
  RxInt avatarIndex = (-1).obs;

  @override
  void onInit() {
    getAvatars();
    super.onInit();
  }

  getAvatars() async {
    try {
      isGetAvatarLoading.value = true;
      // final token = "${Hive.box(userdata).get(authToken)}";
      await Hive.openBox(userdata);
      log("token: ${Hive.box(userdata).get(authToken)}");
      final responseJson = await apiHelper.postMethod(
        url: apiHelper.listOfAvatars,
        headers: {
          'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
          "Accept": "application/json",
        },
        requestBody: {},
      );
      avatarsData.value = AvatarsModel.fromJson(responseJson).avtars!;
      log("avatarsData length ${avatarsData.length}");
      isGetAvatarLoading.value = false;
    } catch (e) {
      isGetAvatarLoading.value = false;

      if (kDebugMode) {
        print('get avatarsData faield: $e');
      }
    }
  }
}
