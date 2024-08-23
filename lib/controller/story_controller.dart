// ignore_for_file: prefer_null_aware_operators, unnecessary_null_comparison, unused_local_variable, avoid_print

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/dio.dart' as dd;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meyaoo_new/Models/Story%20Models/add_story_data.dart';
import 'package:meyaoo_new/Models/Story%20Models/my_story_seen_list_data.dart';
import 'package:meyaoo_new/Models/Story%20Models/status_delete_model.dart';
import 'package:meyaoo_new/Models/Story%20Models/story_list_data.dart';
import 'package:meyaoo_new/Models/Story%20Models/view_story_data.dart';
import 'package:meyaoo_new/hive_service/hive_service.dart';
import 'package:meyaoo_new/src/global/api_helper.dart';
import 'package:meyaoo_new/src/global/global.dart';
import 'package:meyaoo_new/src/global/strings.dart';
import 'package:meyaoo_new/src/screens/layout/story/final_story.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

final apiHelper = ApiHelper();

class StroyGetxController extends GetxController {
  Dio dio = Dio();

  var isUploadStoryLoad = false.obs;
  var isAllUserStoryLoad = false.obs;
  var isProfileLoading = false.obs;
  var isMyStorySeenLoading = false.obs;
  var isMyStoryDeleteLoading = false.obs;

  var isSeenUserOpen = false;

  final _picker = ImagePicker();

  var deleteStatusModel = StatusDeleteModel().obs;

  var addStoryData = AddStoryDataModel().obs;
  var storyListData = StoryListData().obs;
  RxList<ViewedStatusList> viewedStatusList = <ViewedStatusList>[].obs;
  RxList<NotViewedStatusList> notViewedStatusList = <NotViewedStatusList>[].obs;
  ////
  var allStoryListData = StoryListData().obs;
  var viewStoryData = ViewStoryData().obs;
  var myStorySeenData = MyStorySeenListData().obs;

  var totalSeenNumberList = [].obs;

  var indexOfStory = 0.obs;

  var pageIndexValue = 0.obs;
  var storyIndexValue = 0.obs;

  // final userIdOfAccount = Hive.box(userdata).get(userId);

  RxString imagePath = ''.obs;
  RxString videoPath = ''.obs;

  late FilePickerResult result;

  late Options options;

  //var contactListData = ContactListResponseModel().obs;

  StroyGetxController() {
    options = Options(
      headers: {
        'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
        "Accept": "application/json",
      },
      validateStatus: (status) {
        return status! >= 200 && status <= 500;
      },
    );
  }

  filePickForStory() async {
    result = (await FilePicker.platform.pickFiles(
      allowMultiple: false,
      allowCompression: true,
      type: FileType.image,
      // allowedExtensions: [
      //   'jpg',
      //   'jpeg',
      //   'png',
      //   //'mp4',
      // ],
    ))!;

    if (result != null) {
      if (kDebugMode) {
        print("File selected");
      }
      log("IDENTIFIER ${result.files[0].identifier!}");
      log("FILE ${result.files[0]}");

      String? filePath = result.files.single.path;
      String? extension =
          filePath != null ? filePath.split('.').last.toLowerCase() : null;

      // if (extension == 'mp4') {
      //   Get.to(() => VideoTrimmer(
      //         files: result.files[0],
      //       ));
      //   // The picked file is an MP4 video
      // } else {
      //   Get.to(() => const FinalStoryConfirmationScreen());

      //   // The picked file is not an MP4 video
      // }
      Get.to(() => const FinalStoryConfirmationScreen());
    }
  }

  // late XFile? imageFile;

  // getImageFromGallery() async {
  //   final pickedFile =
  //       await ImagePicker().pickImage(source: ImageSource.gallery);

  //   if (pickedFile != null) {
  //     // A file was picked from the gallery
  //     imageFile = XFile(pickedFile.path);

  //     // Proceed with your logic here, such as navigating to the next screen
  //     Get.to(() => const FinalStoryConfirmationScreen());
  //   }
  // }

  void setImagePath(String path) {
    imagePath.value = path;
    if (kDebugMode) {
      print("${imagePath.value} PATH☺☺☺");
    }
    //addImageStory(imagePath.value);
  }

  Future<void> openImagePicker(bool isForCamera) async {
    final XFile? pickedImage = await _picker.pickImage(
        source: isForCamera ? ImageSource.camera : ImageSource.gallery);
    if (pickedImage != null) {
      setImagePath(pickedImage.path);
      Get.back();
    }
  }

  getVideoFromCamera(bool isForCamera) async {
    final XFile? pickedVideo = await _picker.pickVideo(
        source: isForCamera ? ImageSource.camera : ImageSource.gallery);
    if (pickedVideo != null) {
      videoPath.value = pickedVideo.path;
      // setImagePath(pickedImage.path);
      Get.back();
    }
  }

  addImageStory(
    String imagePath,
    String text,
  ) async {
    print(text);
    try {
      isUploadStoryLoad(true);

      dd.FormData formData = dd.FormData.fromMap({
        if (imagePath.isNotEmpty)
          "files": await dd.MultipartFile.fromFile(
            imagePath,
          ),
        "status_text": text,
      });

      final result = await dio.post(apiHelper.addStoryUrl,
          data: formData, options: options);
      final respo = AddStoryDataModel.fromJson(result.data);

      addStoryData = respo.obs;

      log("Requested Data of add_story ${formData.fields}");
      log("Requested Data files of add_story ${formData.files}");
      log("MESSAGE ${addStoryData.value.message}");

      if (kDebugMode) {
        print("Status of add_story : ${result.statusCode}");
      }

      if (result.statusCode == 200) {
        if (addStoryData.value.success == true) {
          Fluttertoast.showToast(msg: "Story Uploaded");
          await getAllUsersStory();
          storyListData.refresh();
          Get.back();
        }
      } else {}
    } catch (e) {
      log(e.toString());
    } finally {
      isUploadStoryLoad(false);
    }
  }

  addVideoStory(
    String imagePath,
    String text,
  ) async {
    try {
      log("Image Path $imagePath");

      isUploadStoryLoad(true);
      Directory appDirectory = await getApplicationDocumentsDirectory();
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String thumbnailPath = '${appDirectory.path}/thumbnail_$timestamp.jpg';

      // await flutterFFmpeg.execute(
      //   '-i $imagePath -ss 00:00:01 -vframes 1 $thumbnailPath',
      // );

      File thumbnailFile = File(thumbnailPath);

      dd.FormData formData = dd.FormData.fromMap({
        // if (imagePath.isNotEmpty)
        "files": await dd.MultipartFile.fromFile(
          imagePath,
        ),
        "status_text": text
        // "user_id": Hive.box(userdata).get(userId),
        // // "video_thumbnail": thumbnailFile,
        // "type": "video",
      });

      print("Requested Data of add_story $formData");
      print("Requested Data of add_story ${formData.fields}");

      for (int i = 0; i < formData.fields.length; i++) {
        print(
            "Requested Data of add_story form data  ${formData.fields[i].value}");
      }

      final result = await dio.post(apiHelper.addStatusUrl,
          data: formData, options: options);
      final respo = AddStoryDataModel.fromJson(result.data);

      addStoryData = respo.obs;

      if (kDebugMode) {
        print("Status of add_story : ${result.statusCode}");
      }

      if (result.statusCode == 200) {
        if (addStoryData.value.success == true) {
          Fluttertoast.showToast(msg: "Story Uploaded");
          await getAllUsersStory();
          storyListData.refresh();
          Get.back();
        }
      } else {}
    } catch (e) {
      log(e.toString());
    } finally {
      isUploadStoryLoad(false);
    }
  }

  getAllUsersStory() async {
    try {
      isAllUserStoryLoad(true);

      //var box = await Hive.openBox(HiveService.getAllStoryBox);

      // Map<String, dynamic> data = {
      //   'user_id': Hive.box(userdata).get(userId),
      // };

      // if (internetController.isOnline.value) {
      //   final result = await dio.post("${baseUrl()}GerStoryByUser",
      //       data: data, options: options);

      //   final respo = StoryListData.fromJson(result.data);

      //   storyListData = respo.obs;
      //   allStoryListData = respo.obs;
      //   var storeJsonData = json.encode(result.data);
      //   box.put(HiveKeyService.storyKey, storeJsonData);
      //   var getData = box.get(HiveKeyService.storyKey);
      //   log("STORY:$getData");

      //   if (kDebugMode) {
      //     print("Status of get_story_by_user : ${result.statusCode}");
      //   }
      // } else {
      //   var getData = box.get(HiveKeyService.storyKey);
      //   if (getData == null) {
      //     storyListData.value.post = null;
      //     storyListData.value.myPost = null;
      //   } else {
      //     var getJSONData = json.decode(getData);
      //     var respo = StoryListData.fromJson(getJSONData);
      //     storyListData = respo.obs;
      //     print("GET_STORY:$respo");
      //   }
      // }
      final result = await dio.post(apiHelper.statusListUrl, options: options);

      final respo = StoryListData.fromJson(result.data);

      storyListData = respo.obs;
      viewedStatusList.value = storyListData.value.viewedStatusList!;
      notViewedStatusList.value = storyListData.value.notViewedStatusList!;
      allStoryListData = respo.obs;

      var storeJsonData = json.encode(result.data);
      //box.put(HiveKeyService.storyKey, storeJsonData);
      log("STORY-LIST:$respo");
      log("STORY-LIST:${storyListData.toString()}");
      log("STORY-LIST:${allStoryListData.toString()}");
      //log("SEEN-LIST:$seenList");
      if (kDebugMode) {
        print("Status of get_story_by_user : ${result.statusCode}");
      }
      isAllUserStoryLoad(false);
    } catch (e) {
      log(e.toString());
      isAllUserStoryLoad(false);
    } finally {
      isAllUserStoryLoad(false);
    }
  }

  viewStoryAPI(String storyID, viewCount, pageIndex) async {
    try {
      Map<String, dynamic> data = {
        'status_id': storyID,
        'status_count': viewCount
      };

      log("Requested Data of view_story $data");

      final result =
          await dio.post(apiHelper.viewStatusUrl, data: data, options: options);

      dd.FormData formData = dd.FormData.fromMap(
          {"status_id": storyID, "status_count": viewCount});

      print("Requested Data of add_story ${formData.fields}");

      print("Staus of view_story ${result.statusCode}");

      final respo = ViewStoryData.fromJson(result.data);
      storyListData.value.notViewedStatusList![pageIndex].userData!.statuses![0]
          .statusViews![0].statusCount = storyListData
              .value
              .notViewedStatusList![pageIndex]
              .userData!
              .statuses![0]
              .statusViews![0]
              .statusCount! +
          1;

      storyListData.refresh();
      viewedStatusList.refresh();
      notViewedStatusList.refresh();
      print("Requested Data of add_story$respo");
      // if (respo.responseCode == 1) {
      //   for (int i = 0; i < storyListData.value.post!.length; i++) {
      //     for (int j = 0;
      //         j < storyListData.value.post![i].storyImage!.length;
      //         j++) {
      //       if (storyID ==
      //           storyListData.value.post![i].storyImage![j].storyId
      //               .toString()) {
      //         log("Story ID MATCHED");
      //         storyListData.value.post![i].storyImage![j].isSeen = 1;
      //         if (storyListData.value.post![i].userReadCount !=
      //             storyListData.value.post![i].totalStories) {
      //           log("USER COUNT ${storyListData.value.post![i].userReadCount}");
      //           storyListData.value.post![i].userReadCount =
      //               storyListData.value.post![i].userReadCount! + 1;
      //           log("USER COUNT AFTER ${storyListData.value.post![i].userReadCount}");
      //           storyListData.refresh();
      //         }
      //       }
      //       // if( storyListData.value.post![i].storyImage![j]. )
      //     }
      //   }
      // }

      viewStoryData = respo.obs;
    } catch (e) {
      log(e.toString());
    } finally {}
  }

  myStorySeenListAPI(String storyID) async {
    try {
      isMyStorySeenLoading(true);

      Map<String, dynamic> data = {'status_id': storyID};

      var box = await Hive.openBox(HiveService.storySeenListBox);

      if (kDebugMode) {
        print("Requested data of story_seen_list $data");
      }

      // if (internetController.isOnline.value) {
      //   final result = await dio.post("${baseUrl()}StorySeenList",
      //       data: data, options: options);

      //   log("Status of story_seen_list ${result.statusCode}");

      //   var storeJsonData = json.encode(result.data);
      //   await box.put(storyID, storeJsonData);
      //   var getData = box.get(storyID);

      //   log("Stored Seen List $getData");

      //   // if (result.statusCode == 200) {}

      //   final respo = MyStorySeenListData.fromJson(result.data);
      //   myStorySeenData = respo.obs;

      //   if (myStorySeenData.value.post!.isNotEmpty) {
      //     print(myStorySeenData.value.post![0].username);
      //   }
      // } else {
      //   var getData = box.get(storyID);
      //   if (getData == null) {
      //     myStorySeenData.value.post = null;
      //   } else {
      //     var getJsonData = json.decode(getData);
      //     final respo = MyStorySeenListData.fromJson(getJsonData);
      //     myStorySeenData = respo.obs;
      //   }
      // }
      final result = await dio.post(apiHelper.myStatusSeenListUrl,
          data: data, options: options);

      log("Status of story_seen_list ${result.statusCode}");

      var storeJsonData = json.encode(result.data);
      await box.put(storyID, storeJsonData);
      var getData = box.get(storyID);

      log("Stored Seen List $getData");

      // if (result.statusCode == 200) {}

      final respo = MyStorySeenListData.fromJson(result.data);
      myStorySeenData = respo.obs;

      if (myStorySeenData.value.statusViewsList!.isNotEmpty) {
        print(myStorySeenData.value.statusViewsList![0].user!.firstName);
      }
    } catch (e) {
      log(e.toString());
    } finally {
      isMyStorySeenLoading(false);
    }
  }

  myStoryDelete(statusMediaID) async {
    try {
      isMyStoryDeleteLoading(true);

      var uri = Uri.parse(apiHelper.statusDetele);
      var request = http.MultipartRequest("POST", uri);
      Map<String, String> headers = {
        'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
        "Accept": "application/json",
      };

      //add headers
      request.headers.addAll(headers);
      request.fields['status_media_id'] = statusMediaID;

      print(request.fields);
      // send
      var response = await request.send();

      String responseData =
          await response.stream.transform(utf8.decoder).join();
      var useData = json.decode(responseData);

      deleteStatusModel.value = StatusDeleteModel.fromJson(useData);

      if (deleteStatusModel.value.success == true) {
        isMyStoryDeleteLoading(false);
        showCustomToast("You Story Removed");
        storyListData.refresh();
        Get.back();
      }
    } catch (e) {
      log("Error occurred: ${e.toString()}");
    } finally {
      isMyStoryDeleteLoading(false);
    }
  }

  getAllUsersStoryUpdate() async {
    final result = await dio.post(apiHelper.statusListUrl, options: options);

    final respo = StoryListData.fromJson(result.data);

    storyListData = respo.obs;
    viewedStatusList.value = storyListData.value.viewedStatusList!;
    notViewedStatusList.value = storyListData.value.notViewedStatusList!;
    allStoryListData = respo.obs;

    var storeJsonData = json.encode(result.data);
    //box.put(HiveKeyService.storyKey, storeJsonData);
    log("STORY-LIST:$respo");
    log("STORY-LIST:${storyListData.toString()}");
    log("STORY-LIST:${allStoryListData.toString()}");
    //log("SEEN-LIST:$seenList");
    if (kDebugMode) {
      print("Status of get_story_by_user : ${result.statusCode}");
    }
  }
}
