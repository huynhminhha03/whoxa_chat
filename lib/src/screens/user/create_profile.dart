// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously, must_be_immutable, avoid_print, avoid_types_as_parameter_names, deprecated_member_use
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whoxachat/Models/user_profile_model.dart';
import 'package:whoxachat/Models/username_check_model.dart';
import 'package:whoxachat/app.dart';
import 'package:whoxachat/controller/avatar_controller.dart';
import 'package:whoxachat/src/global/api_helper.dart';
import 'package:whoxachat/src/global/strings.dart';
import 'package:whoxachat/src/screens/user/pick_image_popup.dart';
import 'package:whoxachat/src/screens/user/profile_pic_screen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:whoxachat/src/global/global.dart';

final ApiHelper apiHelper = ApiHelper();

class AddPersonaDetails extends StatefulWidget {
  bool isRought;
  bool isback;
  AddPersonaDetails({super.key, required this.isRought, required this.isback});

  @override
  State<AddPersonaDetails> createState() => _AddPersonaDetailsState();
}

class _AddPersonaDetailsState extends State<AddPersonaDetails> {
  bool isselected = true;
  bool isselected2 = false;
  bool isselected3 = false;
  bool isidcard = true;
  bool ispassport = false;
  bool isLoading = false;
  String? profileImg;
  String? genderData;
  File? image;
  final picker = ImagePicker();
  UserProfileModel userProfileModel = UserProfileModel();

  final TextEditingController fNameController = TextEditingController();
  final TextEditingController lNameController = TextEditingController();
  final TextEditingController userController = TextEditingController();
  final TextEditingController mobController = TextEditingController();
  final TextEditingController nationController = TextEditingController();
  UserNameCheckModel? userNameCheckModel;
  bool isUsername = false;

  AvatarController avatarController = Get.put(AvatarController());

  @override
  void initState() {
    super.initState();
    fetchUserDetailsAPI();
    _getToken();
    CheckUserConnection();
  }

  bool ActiveConnection = false;
  String T = "";
  Future CheckUserConnection() async {
    if (isLoading = true) {
      fNameController.text = Hive.box(userdata).get(firstName).toString();
      lNameController.text = Hive.box(userdata).get(lastName).toString();
      userController.text = Hive.box(userdata).get(userName).toString();
      mobController.text = Hive.box(userdata).get(userMobile).toString();
      nationController.text =
          Hive.box(userdata).get(userCountryName).toString();
    }
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          fetchUserDetailsAPI();
          ActiveConnection = true;

          T = "Turn off the data and repress again";
          log("Connected");
        });
      }
    } on SocketException catch (_) {
      setState(() {
        showCustomToast(
            languageController.textTranslate('No Internet Connection'));

        ActiveConnection = false;
        fNameController.text = Hive.box(userdata).get(firstName) ?? "";
        lNameController.text = Hive.box(userdata).get(lastName) ?? "";
        userController.text = Hive.box(userdata).get(userName) ?? "";
        mobController.text = Hive.box(userdata).get(userMobile) ?? "";
        nationController.text = Hive.box(userdata).get(userCountryName) ?? "";

        if (Hive.box(userdata).get(userGender).toString() == 'male') {
          setState(() {
            isselected = true;
            isselected2 = false;
            isselected3 = false;
          });
        } else if (Hive.box(userdata).get(userGender).toString() == 'female') {
          setState(() {
            isselected = false;
            isselected2 = true;
            isselected3 = false;
          });
        } else {
          setState(() {
            isselected = false;
            isselected2 = false;
            isselected3 = true;
          });
        }
      });
    }
  }

  fetchUserDetailsAPI() async {
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

    var response = await request.send();

    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);
    userProfileModel = UserProfileModel.fromJson(userData);

    if (userProfileModel.success == true) {
      await Hive.box(userdata)
          .put(userName, userProfileModel.resData!.userName.toString());
      await Hive.box(userdata)
          .put(userMobile, userProfileModel.resData!.phoneNumber.toString());
      await Hive.box(userdata)
          .put(firstName, userProfileModel.resData!.firstName.toString());
      await Hive.box(userdata)
          .put(lastName, userProfileModel.resData!.lastName.toString());
      await Hive.box(userdata)
          .put(userImage, userProfileModel.resData!.profileImage.toString());
      if (userProfileModel.resData!.gender != '') {
        await Hive.box(userdata)
            .put(userGender, userProfileModel.resData!.gender.toString());
      }

      if (userProfileModel.resData!.countryFullName != '') {
        await Hive.box(userdata).put(userCountryName,
            userProfileModel.resData!.countryFullName.toString());
      }
      if (userProfileModel.resData!.gender.toString() == 'male') {
        setState(() {
          isselected = true;
          isselected2 = false;
          isselected3 = false;
        });
      } else if (userProfileModel.resData!.gender.toString() == 'female') {
        setState(() {
          isselected = false;
          isselected2 = true;
          isselected3 = false;
        });
      } else {
        setState(() {
          isselected = false;
          isselected2 = false;
          isselected3 = true;
        });
      }
      fNameController.text = Hive.box(userdata).get(firstName).toString();
      lNameController.text = Hive.box(userdata).get(lastName).toString();
      userController.text = Hive.box(userdata).get(userName).toString();
      mobController.text = Hive.box(userdata).get(userMobile).toString();
      nationController.text =
          Hive.box(userdata).get(userCountryName).toString();
      genderData = Hive.box(userdata).get(userGender).toString();
      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      showCustomToast("Error");
    }
  }

  editApiCall() async {
    closeKeyboard();

    setState(() {
      buttonClick = true;
    });

    var uri = Uri.parse(apiHelper.userCreateProfile);
    var request = http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
      'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}'
    };
    request.headers.addAll(headers);
    request.fields['user_name'] = userController.text;
    request.fields['first_name'] = fNameController.text;
    request.fields['last_name'] = lNameController.text;
    request.fields['gender'] = genderData.toString();
    request.fields['device_token'] = _fcmtoken.toString();
    if (widget.isRought == false && Hive.box(userdata).get(userBio) == null) {
      request.fields['bio'] = "Available";
    }
    request.fields['one_signal_player_id'] =
        OneSignal.User.pushSubscription.id!;

    if (widget.isRought == true) {
      if (image != null) {
        request.files
            .add(await http.MultipartFile.fromPath('files', image!.path));
      } else if (avatarController.avatarIndex.value != -1) {
        request.fields['avatar_id'] = avatarController
            .avatarsData[avatarController.avatarIndex.value].avatarId
            .toString();
      } else if (profileImg!.isNotEmpty &&
          profileImg !=
              "https://whoxachat.com/uploads/not-found-images/profile-image.png" &&
          avatarController.avatarsData
              .where((avatar) => avatar.avtarMedia == profileImg)
              .map((avatar) => avatar.avtarMedia!)
              .isNotEmpty &&
          avatarController.avatarIndex.value == -1 &&
          image == null) {
        request.fields['avatar_id'] = avatarController.avatarsData
            .where((avatar) => avatar.avtarMedia == profileImg)
            .map((avatar) => avatar.avatarId!.toString())
            .first;
      } else {
        if (Hive.box(userdata).get(userGender) == "male") {
          request.fields['avatar_id'] = avatarController.avatarsData
              .where((avatar) =>
                  avatar.avatarGender == "male" && avatar.defaultAvtar == true)
              .map((avatar) => avatar.avatarId.toString())
              .first;
        } else {
          request.fields['avatar_id'] = avatarController.avatarsData
              .where((avatar) =>
                  avatar.avatarGender == "female" &&
                  avatar.defaultAvtar == true)
              .map((avatar) => avatar.avatarId.toString())
              .first;
        }
      }
    }
    var response = await request.send();

    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);
    userProfileModel = UserProfileModel.fromJson(userData);

    if (userProfileModel.success == true) {
      await Hive.box(userdata)
          .put(userName, userProfileModel.resData!.userName.toString());
      await Hive.box(userdata)
          .put(firstName, userProfileModel.resData!.firstName.toString());
      await Hive.box(userdata)
          .put(lastName, userProfileModel.resData!.lastName.toString());
      await Hive.box(userdata)
          .put(userImage, userProfileModel.resData!.profileImage.toString());
      if (userProfileModel.resData!.gender != '') {
        await Hive.box(userdata)
            .put(userGender, userProfileModel.resData!.gender.toString());
      }

      if (userProfileModel.resData!.countryFullName != '') {
        await Hive.box(userdata).put(userCountryName,
            userProfileModel.resData!.countryFullName.toString());
      }

      setState(() {
        buttonClick = false;
      });

      log(responseData);

      if (widget.isRought == true) {
        Get.back();
      } else {
        avatarController.getAvatars();
        Get.offAll(
          const ProfilePicScreen(),
          transition: Transition.rightToLeft,
        );
      }
      showCustomToast(languageController.textTranslate('Success'));
    } else {
      setState(() {
        buttonClick = false;
      });
      showCustomToast("Error");
    }
  }

  // checkUserName({
  //   required String userName,
  // }) async {
  //   try {
  //     // isReportUserLoading.value = true;

  //     await Hive.openBox(userdata);
  //     log("token: ${Hive.box(userdata).get(authToken)}");
  //     final responseJson = await apiHelper.postMethod(
  //       url: apiHelper.userNameCheck,
  //       // headers: {
  //       //   'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
  //       //   'Content-Type': 'application/json',
  //       // },
  //       requestBody: {
  //         "user_name": userName,
  //       },
  //     );
  //     if (responseJson['success'] == true) {
  //       showCustomToast("User reported");
  //       Get.back();
  //     }
  //     // isReportUserLoading.value = false;
  //   } catch (e) {
  //     // isReportUserLoading.value = false;

  //     if (kDebugMode) {
  //       print('report user faield: $e');
  //     }
  //   }
  // }

  Timer? timer;
  checkUserName(String xyz) async {
    setState(() {
      isUsername = true;
    });
    try {
      var uri = Uri.parse(apiHelper.userNameCheck);
      var request = http.MultipartRequest("POST", uri);
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        // 'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}'
      };
      request.headers.addAll(headers);
      request.fields['user_name'] = xyz;

      var response = await request.send();
      String responseData =
          await response.stream.transform(utf8.decoder).join();
      var userData = json.decode(responseData);

      userNameCheckModel = UserNameCheckModel.fromJson(userData);

      if (userNameCheckModel!.success == true) {
        setState(() {
          isUsername = false;
        });
      } else {
        setState(() {
          isUsername = false;
        });
        // Fluttertoast.showToast(msg: userNameCheckModel!.message!);
      }
    } catch (e) {
      setState(() {
        isUsername = false;
      });
    } finally {
      setState(() {
        isUsername = false;
      });
    }
  }

  String _fcmtoken = "";
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  Future<bool> _getToken() async {
    if (Platform.isIOS) {
      await firebaseMessaging.getToken().then((token) {
        setState(() {
          _fcmtoken = token!;
        });
        log("DEVICE_TOKEN:$_fcmtoken");
      });
    } else if (Platform.isAndroid) {
      await firebaseMessaging.getToken().then((token) {
        setState(() {
          _fcmtoken = token!;
        });
        log("DEVICE_TOKEN:$_fcmtoken");
      });
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: secondaryColor.withOpacity(0.05),
      ),
      child: Scaffold(
          backgroundColor: const Color.fromRGBO(250, 250, 250, 1),
          body: isLoading
              ? loader(context)
              : widget.isRought == false
                  ? createProfile()
                  : profile()),
    );
  }

  Widget createProfile() {
    return Container(
        width: MediaQuery.of(context).size.width,
        color: const Color.fromRGBO(250, 250, 250, 1),
        child: Column(
          children: [
            Container(
              height: 110,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    secondaryColor.withOpacity(0.04),
                    chatownColor.withOpacity(0.04),
                  ],
                ),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  "Add Info",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Poppins",
                  ),
                ).paddingOnly(top: 30).paddingSymmetric(
                      horizontal: 28,
                    ),
              ),
            ),
            const Divider(
              color: Color(0xffE9E9E9),
              height: 1,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    UserNameWid(),
                    const SizedBox(
                      height: 20,
                    ),
                    Firstname(),
                    const SizedBox(
                      height: 20,
                    ),
                    Lastname(),
                    const SizedBox(
                      height: 20,
                    ),
                    gender(),
                    const SizedBox(
                      height: 25,
                    ),
                    Divider(
                      color: const Color(0xFF000000).withOpacity(0.06),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Contact Details',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              fontFamily: "Poppins",
                              color: Color(0xff3A3333)),
                        ),
                        const Text(
                          '(Non Changeable)',
                          style: TextStyle(
                              fontWeight: FontWeight.w300,
                              fontSize: 8,
                              fontFamily: "Poppins",
                              color: Color(0xff959595)),
                        ).paddingOnly(top: 2, left: 2),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    MobileNumber(),
                    const SizedBox(
                      height: 20,
                    ),
                    Nationality(),
                    const SizedBox(
                      height: 30,
                    ),
                    buttonClick
                        ? Center(
                            child: SizedBox(
                            height: 30,
                            width: 30,
                            child:
                                CircularProgressIndicator(color: chatownColor),
                          ))
                        : CustomButtom(
                            onPressed: () {
                              closekeyboard();

                              if (userController.text.isNotEmpty &&
                                  fNameController.text.isNotEmpty &&
                                  lNameController.text.isNotEmpty) {
                                editApiCall();
                              } else {
                                if (userController.text.isEmpty) {
                                  showCustomToast(languageController
                                      .textTranslate('Please enter username'));
                                } else if (fNameController.text.isEmpty) {
                                  showCustomToast(
                                      languageController.textTranslate(
                                          'Please enter first name'));
                                } else if (lNameController.text.isEmpty) {
                                  showCustomToast(languageController
                                      .textTranslate('Please enter last name'));
                                }
                              }
                            },
                            title: "Continue",
                          ),
                    const SizedBox(
                      height: 30,
                    ),
                  ],
                ).paddingSymmetric(horizontal: 20),
              ),
            ),
          ],
        ));
  }

  Widget profile() {
    return Container(
        width: MediaQuery.of(context).size.width,
        color: const Color.fromRGBO(250, 250, 250, 1),
        child: Stack(
          children: [
            SizedBox(
              height: Get.height * 0.27,
              width: double.infinity,
              child: Image.asset(
                cacheHeight: 140,
                "assets/images/back_img1.png",
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: 25, right: 25, bottom: 20, top: Get.height * 0.13),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _imgWidget(),
                          const SizedBox(
                            height: 15,
                          ),
                          UserNameWid(isCheckuserName: false),
                          const SizedBox(
                            height: 15,
                          ),
                          Firstname(),
                          const SizedBox(
                            height: 15,
                          ),
                          Lastname(),
                          const SizedBox(
                            height: 15,
                          ),
                          gender(),
                          const SizedBox(
                            height: 15,
                          ),
                          MobileNumber(),
                          const SizedBox(
                            height: 15,
                          ),
                          Nationality(),
                          const SizedBox(
                            height: 30,
                          ),
                          buttonClick
                              ? Center(
                                  child: SizedBox(
                                  height: 30,
                                  width: 30,
                                  child: CircularProgressIndicator(
                                      color: chatownColor),
                                ))
                              : CustomButtom(
                                  onPressed: () {
                                    closekeyboard();

                                    if (userController.text.isNotEmpty &&
                                        fNameController.text.isNotEmpty &&
                                        lNameController.text.isNotEmpty) {
                                      editApiCall();
                                    } else {
                                      if (userController.text.isEmpty) {
                                        showCustomToast(
                                            languageController.textTranslate(
                                                'Please enter username'));
                                      } else if (fNameController.text.isEmpty) {
                                        showCustomToast(
                                            languageController.textTranslate(
                                                'Please enter first name'));
                                      } else if (lNameController.text.isEmpty) {
                                        showCustomToast(
                                            languageController.textTranslate(
                                                'Please enter last name'));
                                      }
                                    }
                                  },
                                  title: "Continue",
                                )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
                top: 45,
                left: 15,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: Image.asset(
                        "assets/images/arrow-left.png",
                        color: appColorBlack,
                        scale: 1.5,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Obx(
                      () => Text(
                        languageController.textTranslate('Profile'),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                )),
          ],
        ));
  }

  bool buttonClick = false;

  Widget _imgWidget() {
    return Container(
      height: 110,
      width: 110,
      decoration:
          const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
      child: isLoading
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  userImg(),
                  InkWell(
                    onTap: () {
                      piceImagePopup();
                    },
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(35),
                          color: Colors.white),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                gradient: LinearGradient(
                                    colors: [secondaryColor, chatownColor],
                                    begin: Alignment.topRight,
                                    end: Alignment.bottomCenter)),
                            child: Center(
                                child: Image.asset("assets/images/edit-1.png",
                                    height: 10))),
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }

  piceImagePopup() {
    return showDialog(
        context: context,
        barrierColor: const Color.fromRGBO(30, 30, 30, 0.37),
        builder: (BuildContext context) {
          return const PickImagePopup();
        }).then((value) {
      setState(() {
        image = value["image"];
        if (image != null) {
          avatarController.avatarIndex.value = -1;
        }
      });
    });
  }

  Widget gender() {
    return Container(
      decoration: const BoxDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                languageController.textTranslate('Gender'),
                style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                    fontFamily: "Poppins",
                    color: Color(0xff3A3333)),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 20),
              InkWell(
                onTap: () {
                  setState(() {
                    isselected = true;
                    isselected2 = false;
                    isselected3 = false;
                    genderData = 'male';
                  });
                },
                child: Row(
                  children: [
                    Container(
                      height: 16,
                      width: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isselected == true
                              ? [
                                  const Color(0xff9E9E9E),
                                  const Color(0xff1B1B1B),
                                ]
                              : [
                                  const Color(0xff9E9E9E).withOpacity(0.5),
                                  const Color(0xff1B1B1B).withOpacity(0.5),
                                ],
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: isselected == false
                            ? const BoxDecoration(
                                shape: BoxShape.circle, color: appColorWhite)
                            : BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: appColorWhite, width: 2),
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xff9E9E9E),
                                    Color(0xff1B1B1B),
                                  ],
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      languageController.textTranslate('Male'),
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color:
                              isselected == true ? Colors.black : Colors.grey),
                    )
                  ],
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    isselected = false;
                    isselected2 = true;
                    isselected3 = false;
                    genderData = 'female';
                  });
                },
                child: Row(
                  children: [
                    Container(
                      height: 16,
                      width: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isselected2 == true
                              ? [
                                  const Color(0xff9E9E9E),
                                  const Color(0xff1B1B1B),
                                ]
                              : [
                                  const Color(0xff9E9E9E).withOpacity(0.5),
                                  const Color(0xff1B1B1B).withOpacity(0.5),
                                ],
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: isselected2 == false
                            ? const BoxDecoration(
                                shape: BoxShape.circle, color: appColorWhite)
                            : BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: appColorWhite, width: 2),
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xff9E9E9E),
                                    Color(0xff1B1B1B),
                                  ],
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      languageController.textTranslate('Female'),
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color:
                              isselected2 == true ? Colors.black : Colors.grey),
                    )
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }

  Widget UserNameWid({bool isCheckuserName = true}) {
    return Container(
      decoration: const BoxDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                languageController.textTranslate('Username'),
                style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                    fontFamily: "Poppins",
                    color: Color(0xff3A3333)),
              ),
            ],
          ),
          const SizedBox(height: 5),
          SizedBox(
            height: 50,
            width: MediaQuery.of(context).size.width,
            child: TextField(
              controller: userController,
              onChanged: (String searchText) {
                if (isCheckuserName == true) {
                  checkUserName(searchText);
                }
              },
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              readOnly: false,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xffEFEFEF))),
                  focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xffEFEFEF)),
                      borderRadius: BorderRadius.circular(10)),
                  contentPadding:
                      const EdgeInsets.only(top: 1, left: 15, bottom: 1),
                  hintStyle: const TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                      fontWeight: FontWeight.w400),
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: isCheckuserName == true
                      ? userNameCheckModel == null ||
                              userNameCheckModel!.success == false
                          ? Container(
                              margin: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                // color: Colors.red,
                                border: Border.all(color: Colors.red),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.red,
                              ),
                            )
                          : Container(
                              margin: const EdgeInsets.all(15),
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.white,
                              ),
                            )
                      : const SizedBox.shrink()),
            ),
          )
        ],
      ),
    );
  }

  Widget Lastname() {
    return Column(
      children: [
        Row(
          children: [
            Text(
              languageController.textTranslate('Last Name'),
              style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                  fontFamily: "Poppins",
                  color: Color(0xff3A3333)),
            ),
          ],
        ),
        const SizedBox(
          height: 4,
        ),
        SizedBox(
          height: 50,
          width: MediaQuery.of(context).size.width,
          child: TextField(
              controller: lNameController,
              readOnly: false,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xffEFEFEF))),
                focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xffEFEFEF)),
                    borderRadius: BorderRadius.circular(10)),
                contentPadding:
                    const EdgeInsets.only(top: 1, left: 15, bottom: 1),
                hintStyle: const TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                    fontWeight: FontWeight.w400),
                filled: true,
                fillColor: Colors.white,
              )),
        )
      ],
    );
  }

  Widget userImg() {
    if (checkForNull(Hive.box(userdata).get(userImage)) != null) {
      profileImg = Hive.box(userdata).get(userImage);
    }
    return Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(100),
      child: GestureDetector(
        onTap: () {
          piceImagePopup();
        },
        child: Container(
          height: 110,
          width: 110,
          decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.grey,
                    blurRadius: 1.0,
                    spreadRadius: 0.0,
                    offset: Offset(0.0, 0.0))
              ]),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(110),
              child: profileImg != null &&
                      profileImg !=
                          "https://whoxachat.com/uploads/not-found-images/profile-image.png" &&
                      avatarController.avatarIndex.value == -1 &&
                      image == null
                  ? avatarController.avatarsData
                          .where((avatar) => avatar.avtarMedia == profileImg)
                          .map((avatar) => avatar.avtarMedia!)
                          .isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: profileImg!,
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.person, color: chatColor),
                        )
                      : CachedNetworkImage(
                          imageUrl: profileImg!,
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.person, color: chatColor),
                        )
                  : image == null
                      ? Obx(
                          () => avatarController.avatarIndex.value != -1
                              ? CachedNetworkImage(
                                  imageUrl: avatarController
                                      .avatarsData[
                                          avatarController.avatarIndex.value]
                                      .avtarMedia!,
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.person,
                                          color: chatColor),
                                )
                              : Hive.box(userdata).get(userGender) == "male"
                                  ? CachedNetworkImage(
                                      imageUrl: avatarController.avatarsData
                                          .where((avatar) =>
                                              avatar.avatarGender == "male" &&
                                              avatar.defaultAvtar == true)
                                          .map((avatar) => avatar.avtarMedia!)
                                          .first,
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.person,
                                              color: chatColor),
                                    )
                                  : Hive.box(userdata).get(userGender) !=
                                              null &&
                                          Hive.box(userdata).get(userGender) ==
                                              "female"
                                      ? CachedNetworkImage(
                                          imageUrl: avatarController.avatarsData
                                              .where((avatar) =>
                                                  avatar.avatarGender ==
                                                      "female" &&
                                                  avatar.defaultAvtar == true)
                                              .map((avatar) =>
                                                  avatar.avtarMedia!)
                                              .first,
                                          imageBuilder:
                                              (context, imageProvider) =>
                                                  Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.person,
                                                  color: chatColor),
                                        )
                                      : Container(
                                          height: 30,
                                          width: 30,
                                          decoration:  BoxDecoration(
                                              color: chatownColor,
                                              shape: BoxShape.circle),
                                          child: const Icon(
                                            Icons.person,
                                            size: 30,
                                            color: Colors.black,
                                          ),
                                        ),
                        )
                      : Image.file(image!, fit: BoxFit.cover)),
        ),
      ),
    );
  }

  selectImageSource() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(8.0),
            ),
          ),
          content: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(height: 20.0),
                  Image.asset(
                    'assets/icons/upload_vec.png',
                    height: 100,
                    width: 100,
                  ),
                  Container(height: 15.0),
                  Text(
                    languageController.textTranslate('Upload Image'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Container(height: 15.0),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        getImageFromCamera();
                      },
                      style: ButtonStyle(
                        shape: WidgetStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0))),
                      ),
                      child: Text(
                        languageController.textTranslate('Take Picture'),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        getImageFromGallery();
                      },
                      style: ButtonStyle(
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                      child: Text(
                        languageController.textTranslate('From Gallery'),
                        style: const TextStyle(color: chatColor),
                      ),
                    ),
                  ),
                  Container(height: 15.0),
                ],
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.topRight,
                  child: ClipOval(
                    child: Material(
                      elevation: 5,
                      color: blackcolor,
                      child: InkWell(
                        splashColor: Colors.black,
                        child: const SizedBox(
                            width: 25,
                            height: 25,
                            child: Icon(
                              Icons.close,
                              size: 20,
                              color: Colors.white,
                            )),
                        onTap: () {
                          closeKeyboard();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void containerForSheet<T>({BuildContext? context, Widget? child}) {
    showCupertinoModalPopup<T>(
      context: context!,
      builder: (BuildContext context) => child!,
    ).then<void>((T) {});
  }

  Widget Firstname() {
    return Container(
      decoration: const BoxDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                languageController.textTranslate('First Name'),
                style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                    fontFamily: "Poppins",
                    color: Color(0xff3A3333)),
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          SizedBox(
            height: 50,
            width: MediaQuery.of(context).size.width,
            child: TextField(
                controller: fNameController,
                readOnly: false,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xffEFEFEF))),
                  focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xffEFEFEF)),
                      borderRadius: BorderRadius.circular(10)),
                  contentPadding:
                      const EdgeInsets.only(top: 1, left: 15, bottom: 1),
                  hintStyle: const TextStyle(
                      fontSize: 17,
                      color: Colors.grey,
                      fontWeight: FontWeight.w400),
                  filled: true,
                  fillColor: Colors.white,
                )),
          )
        ],
      ),
    );
  }

  Widget Nationality() {
    final String nation = nationController.text;
    return widget.isRought == true
        ? Container(
            height: 50,
            width: Get.width * 0.90,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                border: Border.all(color: const Color(0XffEFEFEF))),
            child: Row(
              children: [
                const SizedBox(width: 10),
                Image.asset("assets/images/location1.png", height: 21),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      languageController.textTranslate('Country'),
                      style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w400,
                          color: Color.fromRGBO(80, 80, 80, 1)),
                    ),
                    Text(
                      nation,
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w600),
                    )
                  ],
                )
              ],
            ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                languageController.textTranslate('Country'),
                style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                    fontFamily: "Poppins",
                    color: Color(0xff3A3333)),
              ),
              const SizedBox(
                height: 4,
              ),
              Container(
                height: 50,
                width: Get.width * 0.90,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    border: Border.all(color: const Color(0XffEFEFEF))),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    Image.asset("assets/images/location1.png", height: 21),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          nation,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          );
  }

  Widget MobileNumber() {
    final String number = mobController.text;
    return widget.isRought == true
        ? Container(
            height: 50,
            width: Get.width * 0.90,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                border: Border.all(color: const Color(0XffEFEFEF))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset("assets/images/call_1.png",
                        color: Colors.black, height: 21),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          languageController.textTranslate('Phone'),
                          style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w400,
                              color: Color.fromRGBO(80, 80, 80, 1)),
                        ),
                        Text(
                          number,
                          style: const TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w600),
                        )
                      ],
                    )
                  ],
                ),
                Image.asset("assets/images/verify.png", height: 17)
              ],
            ).paddingSymmetric(horizontal: 10),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Phone Number",
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                    fontFamily: "Poppins",
                    color: Color(0xff3A3333)),
              ),
              const SizedBox(
                height: 4,
              ),
              Container(
                height: 50,
                width: Get.width * 0.90,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    border: Border.all(color: const Color(0XffEFEFEF))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset("assets/images/call_1.png",
                            color: Colors.black, height: 21),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              number,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600),
                            )
                          ],
                        )
                      ],
                    ),
                    Image.asset("assets/images/verify.png", height: 17)
                  ],
                ).paddingSymmetric(horizontal: 10),
              ),
            ],
          );
  }

  openImageFromCamOrGallary(BuildContext context) {
    containerForSheet<String>(
      context: context,
      child: CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text(
              languageController.textTranslate('Camera'),
              style: const TextStyle(color: Colors.black, fontSize: 15),
            ),
            onPressed: () {
              getImageFromCamera();
              Navigator.of(context, rootNavigator: true).pop("Discard");
            },
          ),
          CupertinoActionSheetAction(
            child: Text(
              languageController.textTranslate('Photo & Video Library'),
              style: const TextStyle(color: Colors.black, fontSize: 15),
            ),
            onPressed: () {
              getImageFromGallery();
              Navigator.of(context, rootNavigator: true).pop("Discard");
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop("Discard");
          },
          child: Text(
            languageController.textTranslate('Cancel'),
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Future getImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }
}
