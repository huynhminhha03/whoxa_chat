// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously, must_be_immutable, avoid_print, avoid_types_as_parameter_names
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meyaoo_new/Models/user_profile_model.dart';
import 'package:meyaoo_new/Models/username_check_model.dart';
import 'package:meyaoo_new/src/global/api_helper.dart';
import 'package:meyaoo_new/src/global/strings.dart';
import 'package:meyaoo_new/src/screens/layout/bottombar.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:meyaoo_new/src/global/global.dart';

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
  // TEXT CONTROLLER
  final TextEditingController fNameController = TextEditingController();
  final TextEditingController lNameController = TextEditingController();
  final TextEditingController userController = TextEditingController();
  final TextEditingController mobController = TextEditingController();
  final TextEditingController nationController = TextEditingController();
  UserNameCheckModel? userNameCheckModel;
  bool isUsername = false;

  @override
  void initState() {
    log("TOKEN: ${Hive.box(userdata).get(authToken)}");
    _getToken();
    CheckUserConnection();
    print("NATIONALITY: ${nationController.text}");
    super.initState();
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
        showCustomToast("No Internet Connection");

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
      //Set data in hive
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

      if (userProfileModel.resData!.country != '') {
        await Hive.box(userdata)
            .put(userCountryName, userProfileModel.resData!.country.toString());
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
    request.fields['one_signal_player_id'] =
        OneSignal.User.pushSubscription.id!;
    request.fields['country'] = nationController.text;

    if (image != null) {
      request.files
          .add(await http.MultipartFile.fromPath('files', image!.path));
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

      if (userProfileModel.resData!.country != '') {
        await Hive.box(userdata)
            .put(userCountryName, userProfileModel.resData!.country.toString());
      }

      setState(() {
        buttonClick = false;
      });

      log(responseData);

      if (widget.isRought == true) {
        Get.back();
      } else {
        Navigator.pushAndRemoveUntil(
            context,
            PageTransition(
              curve: Curves.linear,
              type: PageTransitionType.rightToLeft,
              child: TabbarScreen(currentTab: 0),
            ),
            (route) => false);
      }
      showCustomToast("Success");
    } else {
      setState(() {
        buttonClick = false;
      });
      showCustomToast("Error");
    }
  }

  Timer? timer;
  checkUserName(String xyz) async {
    setState(() {
      isUsername = true;
    });
    try {
      var uri = Uri.parse(apiHelper.userNameCheck);
      var request = http.MultipartRequest("POST", uri);
      Map<String, String> headers = {
        "Accept": "application/json",
        'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}'
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
        Fluttertoast.showToast(msg: userNameCheckModel!.message!);
        // timer = Timer(const Duration(seconds: 5), () {
        //   userController.clear();
        // });
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
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color.fromRGBO(250, 250, 250, 1),
      body: isLoading
          ? loader(context)
          : Container(
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
                    padding: const EdgeInsets.only(
                        left: 25, right: 25, bottom: 20, top: 80),
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
                                UserNameWid(),
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
                                  height: 20,
                                ),
                                // _submitButton()
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Positioned(
                      top: 45,
                      left: 15,
                      child: Text(
                        "Profile",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      )),
                  Positioned(
                      top: 45,
                      right: 15,
                      child: InkWell(
                          onTap: () {
                            closekeyboard();

                            if (userController.text.isNotEmpty &&
                                fNameController.text.isNotEmpty &&
                                lNameController.text.isNotEmpty) {
                              editApiCall();
                            } else {
                              if (userController.text.isEmpty) {
                                showCustomToast("Please enter username");
                              } else if (fNameController.text.isEmpty) {
                                showCustomToast("Please enter first name");
                              } else if (lNameController.text.isEmpty) {
                                showCustomToast("Please enter last name");
                              }
                            }
                          },
                          child: buttonClick
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                        strokeWidth: 3, color: Colors.black),
                                  ),
                                )
                              : const Icon(Icons.check, size: 25)))
                ],
              )),
    );
  }

  bool buttonClick = false;
  // Widget _submitButton(BuildContext context) {
  //   return InkWell(
  //     onTap: () {
  //       closekeyboard();

  //       if (userController.text.isNotEmpty &&
  //           fNameController.text.isNotEmpty &&
  //           lNameController.text.isNotEmpty) {
  //         editApiCall();
  //       } else {
  //         if (userController.text.isEmpty) {
  //           showCustomToast("Please enter username");
  //         } else if (fNameController.text.isEmpty) {
  //           showCustomToast("Please enter first name");
  //         } else if (lNameController.text.isEmpty) {
  //           showCustomToast("Please enter last name");
  //         }
  //       }
  //     },
  //     child: buttonClick
  //         ? Center(
  //             child: Lottie.asset(
  //               'assets/icons/Loader.json',
  //               width: 80,
  //               animate: true,
  //               repeat: true,
  //             ),
  //           )
  //         : Container(
  //             height: 50,
  //             width: MediaQuery.of(context).size.width,
  //             decoration: BoxDecoration(
  //               // border: Border.all(color:  Colors.black, width: 1),
  //               borderRadius: BorderRadius.circular(25),
  //               color: chatownColor,
  //             ),
  //             child: const Center(
  //               child: Text(
  //                 'Continue',
  //                 style: TextStyle(
  //                     color: Colors.black,
  //                     fontWeight: FontWeight.w500,
  //                     fontSize: 16),
  //               ),
  //             ),
  //           ),
  //   );
  // }

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
                      selectImageSource();
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
                                    colors: [yellow1Color, yellow2Color],
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

  Widget gender() {
    return Container(
      decoration: const BoxDecoration(),
      child: Column(
        children: [
          const Row(
            children: [
              Text(
                'Gender',
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: Colors.black),
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
                      height: 14,
                      width: 14,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(width: 1, color: Colors.black)),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: isselected == true
                                  ? LinearGradient(
                                      colors: [blackcolor, black1Color],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    )
                                  : const LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Colors.transparent,
                                      ],
                                    )),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Male',
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
                      height: 14,
                      width: 14,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              width: 1,
                              color: isselected2 == true
                                  ? Colors.black
                                  : Colors.black)),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: isselected2 == true
                                  ? LinearGradient(
                                      colors: [blackcolor, black1Color],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    )
                                  : const LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Colors.transparent
                                      ],
                                    )),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Female',
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

  Widget UserNameWid() {
    return Container(
      decoration: const BoxDecoration(),
      child: Column(
        children: [
          const Row(
            children: [
              Text(
                'Username',
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: Colors.black),
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
                  checkUserName(searchText);
                },
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                readOnly: false,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: appgrey)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: appgrey),
                      borderRadius: BorderRadius.circular(10)),
                  contentPadding:
                      const EdgeInsets.only(top: 1, left: 15, bottom: 1),
                  // hintText: 'Add a brief description',
                  hintStyle: const TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                      fontWeight: FontWeight.w400),
                  filled: true,
                  fillColor: Colors.white,

                  // ),
                )),
          )
        ],
      ),
    );
  }

  Widget Lastname() {
    return Column(
      children: [
        const Row(
          children: [
            Text(
              'Last Name',
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: Colors.black),
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
                    borderSide: const BorderSide(color: appgrey)),
                focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: appgrey),
                    borderRadius: BorderRadius.circular(10)),
                contentPadding:
                    const EdgeInsets.only(top: 1, left: 15, bottom: 1),
                // hintText: 'Add a brief description',
                hintStyle: const TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                    fontWeight: FontWeight.w400),
                filled: true,
                fillColor: Colors.white,

                // ),
              )),
        )
      ],
    );
  }

  Widget userImg() {
    profileImg;
    if (checkForNull(Hive.box(userdata).get(userImage)) != null) {
      profileImg = Hive.box(userdata).get(userImage);
    }
    return Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(100),
      child: GestureDetector(
        onTap: () {
          selectImageSource();
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
                    offset: Offset(0.0, 0.0) // shadow direction: bottom right
                    )
              ]),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(110),
              child: image == null
                  ? userProfileModel.resData!.profileImage != null
                      ? CachedNetworkImage(
                          imageUrl: userProfileModel.resData!.profileImage!,
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
                      : Container(
                          height: 30,
                          width: 30,
                          decoration: const BoxDecoration(
                              color: Color(0xffE7E8EC), shape: BoxShape.circle),
                          child: const Icon(
                            Icons.person,
                            size: 15,
                            color: Colors.black,
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
                  const Text(
                    "Upload Image",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
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
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0))),
                      ),
                      child: const Text(
                        "Take Picture",
                        style: TextStyle(color: Colors.black),
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
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                      child: const Text(
                        "From Gallery",
                        style: TextStyle(color: chatColor),
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
                      color: blackcolor, // button color
                      child: InkWell(
                        splashColor: Colors.black, // inkwell color
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
          const Row(
            children: [
              Text(
                'First Name',
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: Colors.black),
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
                      borderSide: const BorderSide(color: appgrey)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: appgrey),
                      borderRadius: BorderRadius.circular(10)),
                  contentPadding:
                      const EdgeInsets.only(top: 1, left: 15, bottom: 1),
                  // hintText: 'Add a brief description',
                  hintStyle: const TextStyle(
                      fontSize: 17,
                      color: Colors.grey,
                      fontWeight: FontWeight.w400),
                  filled: true,
                  fillColor: Colors.white,

                  // ),
                )),
          )
        ],
      ),
    );
  }

  Widget Nationality() {
    final String nation = nationController.text;
    return Container(
      height: 48,
      width: Get.width * 0.90,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300)),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Image.asset("assets/images/location1.png", height: 21),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Country",
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                    color: Color.fromRGBO(80, 80, 80, 1)),
              ),
              Text(
                nation,
                style:
                    const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
              )
            ],
          )
        ],
      ),
      // child: SizedBox(
      //   height: 50,
      //   width: MediaQuery.of(context).size.width,
      //   child: TextField(
      //       controller: nationController,
      //       readOnly: false,
      //       enabled: false,
      //       style: TextStyle(color: Colors.grey.shade500),
      //       keyboardType: TextInputType.number,
      //       decoration: InputDecoration(
      //         border: OutlineInputBorder(
      //             borderRadius: BorderRadius.circular(10),
      //             borderSide: const BorderSide(color: appgrey)),
      //         enabledBorder: OutlineInputBorder(
      //             borderRadius: BorderRadius.circular(10),
      //             borderSide: const BorderSide(color: appgrey)),
      //         focusedBorder: OutlineInputBorder(
      //             borderSide: const BorderSide(color: appgrey),
      //             borderRadius: BorderRadius.circular(10)),
      //         contentPadding:
      //             const EdgeInsets.only(top: 1, left: 15, bottom: 1),
      //         // hintText: 'Add a brief description',
      //         hintStyle: const TextStyle(
      //             fontSize: 17,
      //             color: Colors.grey,
      //             fontWeight: FontWeight.w400),
      //         filled: true,
      //         fillColor: const Color.fromARGB(255, 235, 235, 235),

      //         // ),
      //       )),
      // ),
    );
  }

  Widget MobileNumber() {
    final String number = mobController.text;
    return Container(
      height: 48,
      width: Get.width * 0.90,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300)),
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
                  const Text(
                    "Phone",
                    style: TextStyle(
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
      // child: Column(
      //   children: [
      //     const Row(
      //       children: [
      //         Text(
      //           'Mobile Number',
      //           style: TextStyle(
      //               fontWeight: FontWeight.w400,
      //               fontSize: 13,
      //               color: Colors.black),
      //         ),
      //       ],
      //     ),
      //     const SizedBox(
      //       height: 10,
      //     ),
      //     SizedBox(
      //       height: 50,
      //       width: MediaQuery.of(context).size.width,
      //       child: TextField(
      //           controller: mobController,
      //           readOnly: false,
      //           enabled: false,
      //           style: TextStyle(color: Colors.grey.shade500),
      //           keyboardType: TextInputType.number,
      //           decoration: InputDecoration(
      //             border: OutlineInputBorder(
      //                 borderRadius: BorderRadius.circular(25),
      //                 borderSide: const BorderSide(color: appgrey)),
      //             enabledBorder: OutlineInputBorder(
      //                 borderRadius: BorderRadius.circular(25),
      //                 borderSide: const BorderSide(color: appgrey)),
      //             focusedBorder: OutlineInputBorder(
      //                 borderSide: const BorderSide(color: appgrey),
      //                 borderRadius: BorderRadius.circular(25)),
      //             contentPadding:
      //                 const EdgeInsets.only(top: 1, left: 15, bottom: 1),
      //             // hintText: 'Add a brief description',
      //             hintStyle: const TextStyle(
      //                 fontSize: 17,
      //                 color: Colors.grey,
      //                 fontWeight: FontWeight.w400),
      //             filled: true,
      //             fillColor: const Color.fromARGB(255, 235, 235, 235),

      //             // ),
      //           )),
      //     )
      //   ],
      // ),
    );
  }

  openImageFromCamOrGallary(BuildContext context) {
    containerForSheet<String>(
      context: context,
      child: CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: const Text(
              "Camera",
              style: TextStyle(color: Colors.black, fontSize: 15),
            ),
            onPressed: () {
              getImageFromCamera();
              Navigator.of(context, rootNavigator: true).pop("Discard");
            },
          ),
          CupertinoActionSheetAction(
            child: const Text(
              "Photo & Video Library",
              style: TextStyle(color: Colors.black, fontSize: 15),
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
            // Navigator.pop(context, 'Cancel');
            Navigator.of(context, rootNavigator: true).pop("Discard");
          },
          child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Future getImageFromCamera() async {
    // ignore: deprecated_member_use
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
    // ignore: deprecated_member_use
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
