import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meyaoo_new/Models/language_translatioins_model.dart';
import 'package:meyaoo_new/Models/languages_model.dart';
import 'package:meyaoo_new/src/global/api_helper.dart';

class LanguageController extends GetxController {
  ApiHelper apiHelper = ApiHelper();

  RxBool isLanguagLoading = false.obs;
  RxBool isGetLanguagsLoading = false.obs;

  // RxInt selectedLanguageIndex = 0.obs;

  @override
  void onInit() {
    getLanguageTranslation();
    getLanguages();
    super.onInit();
  }

  Rx<LanguageTranslationModel> languageTranslationsData =
      LanguageTranslationModel().obs;

  RxList<Languages> languagesData = <Languages>[].obs;

  getLanguageTranslation({String lnId = ""}) async {
    try {
      isLanguagLoading.value = true;

      final responseJson = await apiHelper.postMethod(
        url: "http://192.168.0.27:3001/API/fetch-default-language",
        requestBody: lnId.isEmpty
            ? {}
            : {
                'status_id': lnId,
              },
      );

      if (responseJson["success"] == true) {
        languageTranslationsData.value =
            LanguageTranslationModel.fromJson(responseJson);
      }

      isLanguagLoading.value = false;
    } catch (e) {
      isLanguagLoading.value = false;

      debugPrint('get language Translations failed : $e');
    }
  }

  getLanguages() async {
    try {
      isGetLanguagsLoading.value = true;

      final responseJson = await apiHelper.postMethod(
        url: "http://192.168.0.27:3001/API/List-Language",
        requestBody: {},
      );

      if (responseJson["success"] == true) {
        languagesData.value = LanguagesModel.fromJson(responseJson)
            .languages!
            .where((element) => element.status == true)
            .toList();

        debugPrint("languagesData length ${languagesData.length}");
      }

      isGetLanguagsLoading.value = false;
    } catch (e) {
      isGetLanguagsLoading.value = false;

      debugPrint('get languages failed : $e');
    }
  }

  String textTranslate(String text) {
    return languageTranslationsData.value.results == null ||
            languageTranslationsData.value.results!.isEmpty
        ? text
        : languageTranslationsData.value.results!
                .where((element) => element.key == text)
                .isEmpty
            ? text
            : languageTranslationsData.value.results!
                .where((element) => element.key == text)
                .first
                .translation!;
  }

  TextDirection textDirection() {
    return languageTranslationsData.value.languageAlignment == null ||
            languageTranslationsData.value.languageAlignment!.isEmpty
        ? TextDirection.ltr
        : languageTranslationsData.value.languageAlignment == "ltr"
            ? TextDirection.ltr
            : TextDirection.rtl;
  }
}
