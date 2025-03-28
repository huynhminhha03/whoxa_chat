// ignore_for_file: avoid_print, use_build_context_synchronously, must_be_immutable, no_leading_underscores_for_local_identifiers, unused_local_variable, non_constant_identifier_names, camel_case_types, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:whoxachat/Models/VerifyotpModel.dart';
import 'package:whoxachat/Models/firebase_otp_model.dart';
import 'package:whoxachat/app.dart';
import 'package:whoxachat/controller/avatar_controller.dart';
import 'package:whoxachat/main.dart';
import 'package:whoxachat/src/global/api_helper.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:whoxachat/src/global/strings.dart';
import 'package:whoxachat/src/screens/layout/bottombar.dart';
import 'package:whoxachat/src/screens/user/create_profile.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:http/http.dart' as http;
import 'package:pinput/pinput.dart';

final ApiHelper apiHelper = ApiHelper();

class otp extends StatefulWidget {
  String phoneController;
  final String? varify;
  final TextEditingController? email;
  final String? selectedCountry;
  final String inWhichScreen;
  final String countryName;

  otp({
    super.key,
    required this.phoneController,
    this.varify,
    this.email,
    this.selectedCountry,
    required this.inWhichScreen,
    required this.countryName,
  });

  static String verify = "";

  @override
  State<otp> createState() => _otpState();
}

class _otpState extends State<otp> {
// class _otpState extends State<otp> with CodeAutoFill {

  AvatarController avatarController = Get.put(AvatarController());

  int _counter = 0;

  Timer? _timer;

  String selectedCountryimg = '';
  late TextEditingController controller;
  late bool autoFocus;
  int start = 60;
  bool wait = false;
  final String _code = "";
  final TextEditingController _codeController = TextEditingController();
  bool isOtpComplete = false;
  bool isLoading = false;
  bool isLoading2 = false;
  StreamController<int>? _events;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  VerifyOTPModel? send;
  void _startTimer() {
    _counter = 300;
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      (_counter > 0) ? _counter-- : _timer!.cancel();

      if (_counter == 0) {
        showCustomToast(languageController.textTranslate('Please resend OTP'));
        _codeController.text = "";
      }

      int minutes = _counter ~/ 60;
      int seconds = _counter % 60;

      print('$minutes:${seconds.toString().padLeft(2, '0')}');

      _events!.add(_counter);
    });
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

  Future<void> verifyOtpFireBase() async {
    String otpCode = _codeController.text.trim();

    if (otpCode.isEmpty || otpCode.length < 6) {
      Fluttertoast.showToast(msg: "Please enter a valid 6-digit OTP");
      return;
    }

    setState(() {
      isLoading = true;
    });
    try {
      // Tạo credential từ OTP nhập vào
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.varify!,
        smsCode: otpCode,
      );

      // Đăng nhập bằng OTP
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      String? idToken =
          await userCredential.user?.getIdToken(); // Lấy Firebase ID Token
      print(idToken);
      if (idToken == null) {
        print("❌ Không lấy được ID Token từ Firebase.");
        return;
      }

      var uri = Uri.parse(apiHelper.verifyOtpPhoneFireBase);
      var request = http.MultipartRequest("POST", uri);
      Map<String, String> headers = {
        "Accept": "application/json",
      };
      request.headers.addAll(headers);

      request.fields['country_code'] = widget.selectedCountry!;
      request.fields['phone_number'] = widget.phoneController;
      request.fields['id_token'] = idToken;
      request.fields['device_token'] = _fcmtoken;
      request.fields['one_signal_player_id'] =
          OneSignal.User.pushSubscription.id!;

      var response = await request.send();
      // Gửi ID Token lên server để xác thực & lưu vào DB
      print(response.statusCode);

      String responseData =
          await response.stream.transform(utf8.decoder).join();
      var userData = json.decode(responseData);
      send = VerifyOTPModel.fromJson(userData);
  
      print("RESPONSE DATA: $responseData");
      if (send!.success == true) {
        await Hive.box(userdata).put(authToken, send!.token.toString());
        await Hive.box(userdata)
            .put(userName, send!.resData!.userName.toString());
        await Hive.box(userdata)
            .put(firstName, send!.resData!.firstName.toString());
        await Hive.box(userdata)
            .put(lastName, send!.resData!.lastName.toString());
        await Hive.box(userdata)
            .put(userImage, send!.resData!.profileImage.toString());
        if (send!.resData!.gender != '') {
          await Hive.box(userdata)
              .put(userGender, send!.resData!.gender.toString());
        }

        if (send!.resData!.countryFullName != '') {
          await Hive.box(userdata)
              .put(userCountryName, send!.resData!.countryFullName.toString());
        }

        _timer?.cancel();
        isLoading2 = false;
        Navigator.of(context, rootNavigator: true).pop();
        _setDataToHive(send!);

        if (Hive.box(userdata).get(authToken) != null &&
            Hive.box(userdata).get(lastName) != null &&
            Hive.box(userdata).get(lastName)!.isNotEmpty &&
            Hive.box(userdata).get(firstName) != null &&
            Hive.box(userdata).get(firstName)!.isNotEmpty) {
          print("☺☺☺☺GO TO HOME PAGE☺☺☺☺");
          Get.offAll(TabbarScreen(
            currentTab: 0,
          ));
        } else {
          Navigator.pushReplacement(
            context,
            PageTransition(
              curve: Curves.linear,
              type: PageTransitionType.rightToLeft,
              child: AddPersonaDetails(isRought: false, isback: false),
            ),
          );
        }
        _timer?.cancel();
        if (mounted) {
          setState(() {
            isLoading2 = false;
          });
        }
      } else {
        setState(() {
          isLoading2 = false;
        });

        showCustomToast(languageController.textTranslate('CANNOT VERIFY OTP'));
      }

      Navigator.pushReplacement(
        context,
        PageTransition(
          curve: Curves.linear,
          type: PageTransitionType.rightToLeft,
          child: AddPersonaDetails(isRought: false, isback: false),
        ),
      );
    } catch (e) {
      Fluttertoast.showToast(msg: "Invalid OTP, please try again.");
      print("Error verifying OTP: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    log("COUNTRY_NAME: ${widget.countryName}");
    _getToken();

    _events = StreamController<int>();
    _events!.add(60);
    super.initState();
    print(start);
    _startTimer();

    super.initState();
  }

  PinTheme defaultPinTheme = PinTheme(
    width: 50,
    height: 60,
    textStyle: const TextStyle(
      fontSize: 16,
      color: Colors.black,
      fontWeight: FontWeight.w500,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.grey.shade200, width: 2),
      borderRadius: BorderRadius.circular(4),
    ),
  );
  PinTheme focusedPinTheme = PinTheme(
    width: 50,
    height: 60,
    textStyle: const TextStyle(
      fontSize: 16,
      color: Colors.black,
      fontWeight: FontWeight.w500,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: chatownColor, width: 2),
      borderRadius: BorderRadius.circular(4),
    ),
  );
  PinTheme submittedPinTheme = PinTheme(
    width: 50,
    height: 60,
    textStyle: const TextStyle(
      fontSize: 16,
      color: Colors.black,
      fontWeight: FontWeight.w500,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.grey.shade200, width: 2),
      borderRadius: BorderRadius.circular(4),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColorWhite,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: bg,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
            _timer?.cancel();
          },
          icon: Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300)),
            child: const Icon(
              Icons.arrow_back_ios_new_outlined,
              color: Colors.black,
              size: 15,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: bg,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                    color: appColorWhite,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30))),
                child: otp_widget(),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget button({required String time}) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: isLoading2
            ? Center(
                child: SizedBox(
                height: 30,
                width: 30,
                child: CircularProgressIndicator(color: chatownColor),
              ))
            : CustomButtom(
                onPressed: () {
                  setState(() {
                    isOtpComplete
                        ? verifyOtpFireBase()
                        : _counter == 0
                            ? showCustomToast(languageController
                                .textTranslate('Please Resend OTP'))
                            : showCustomToast(languageController
                                .textTranslate('Please Enter OTP'));
                  });
                },
                title: languageController.textTranslate('Login'),
              ));
  }

  FocusNode otpFocus = FocusNode();

  Widget otp_widget() {
    return Column(
      children: [
        StreamBuilder<int>(
            stream: _events!.stream,
            builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
              return Column(
                children: [
                  Image.network(
                    languageController.appSettingsData[0].appLogo!,
                    height: 90,
                  ),
                  const SizedBox(height: 15),
                  Image.asset("assets/images/welcome.png", height: 44),
                  const SizedBox(height: 8),
                  Text(
                    languageController
                        .textTranslate('Hello welcome to chat app'),
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Poppins'),
                  ),
                  const SizedBox(height: 34),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      languageController
                          .textTranslate('6 digit OTP has been sent to'),
                      style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins'),
                    ),
                  ).paddingOnly(left: 20),
                  const SizedBox(
                    height: 5,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "${widget.selectedCountry}-${widget.phoneController}",
                      style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontFamily: "Poppins"),
                    ),
                  ).paddingOnly(left: 20),
                  const SizedBox(height: 20),
                  Pinput(
                    length: 6,
                    controller: _codeController,
                    showCursor: true,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: focusedPinTheme,
                    submittedPinTheme: defaultPinTheme,
                    focusNode: otpFocus,
                    onChanged: (String code) {
                      setState(() {
                        _codeController.text = code;
                        isOtpComplete = code.length == 6;
                      });
                      print("OTP : $code");
                    },
                    onSubmitted: (String verificationCode) {
                      setState(() {
                        _codeController.text = verificationCode;
                        isOtpComplete = verificationCode.length == 6;
                      });
                    },
                  ).paddingSymmetric(horizontal: 20),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                        onTap: () {
                          if (_codeController.text.isNotEmpty) {
                            showCustomToast(
                                "You can't send otp once it's enetered");
                          } else {
                            "${(snapshot.data! ~/ 60).toString().padLeft(2, '0')}:${(snapshot.data! % 60).toString().padLeft(2, '0')}" ==
                                    "00:00"
                                ? resendoTP()
                                : showCustomToast(
                                    "${languageController.textTranslate('Wait for a')} ${(snapshot.data! ~/ 60).toString().padLeft(2, '0')}:${(snapshot.data! % 60).toString().padLeft(2, '0')} ");
                          }
                        },
                        child: Text(
                          languageController.textTranslate('Resend OTP'),
                          style: TextStyle(
                              fontSize: 14,
                              color:
                                  "${(snapshot.data! ~/ 60).toString().padLeft(2, '0')}:${(snapshot.data! % 60).toString().padLeft(2, '0')}" ==
                                          "00:00"
                                      ? const Color.fromRGBO(252, 198, 4, 1)
                                      : Colors.grey,
                              fontWeight: FontWeight.w500,
                              fontFamily: "Poppins"),
                        )),
                  ).paddingOnly(right: 20),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: InkWell(
                      onTap: () {
                        isLoading2;
                      },
                      child: Center(
                        child: Text(
                          "${languageController.textTranslate('Resend Code in')} ${(snapshot.data! ~/ 60).toString().padLeft(2, '0')}:${(snapshot.data! % 60).toString().padLeft(2, '0')}",
                          style: const TextStyle(
                              color: Color.fromRGBO(113, 113, 113, 1),
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                              fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  button(time: snapshot.data.toString().padLeft(2, '0')),
                  const SizedBox(height: 35),
                  
                ],
              );
            }),
      ],
    );
  }

  otpcheck() async {
    if (_codeController.text.isNotEmpty) {
      setState(() {
        isLoading2 = true;
      });
      var uri = Uri.parse(apiHelper.verifyOtpPhone);
      var request = http.MultipartRequest("POST", uri);
      Map<String, String> headers = {
        "Accept": "application/json",
      };
      request.headers.addAll(headers);

      request.fields['country_code'] = widget.selectedCountry!;
      request.fields['phone_number'] = widget.phoneController;
      request.fields['otp'] = _codeController.text;
      request.fields['device_token'] = _fcmtoken;
      request.fields['one_signal_player_id'] =
          OneSignal.User.pushSubscription.id!;

      var response = await request.send();
      print(response.statusCode);

      String responseData =
          await response.stream.transform(utf8.decoder).join();
      var userData = json.decode(responseData);
      send = VerifyOTPModel.fromJson(userData);
      log(responseData);
      if (send!.success == true) {
        await Hive.box(userdata).put(authToken, send!.token.toString());
        await Hive.box(userdata)
            .put(userName, send!.resData!.userName.toString());
        await Hive.box(userdata)
            .put(firstName, send!.resData!.firstName.toString());
        await Hive.box(userdata)
            .put(lastName, send!.resData!.lastName.toString());
        await Hive.box(userdata)
            .put(userImage, send!.resData!.profileImage.toString());
        if (send!.resData!.gender != '') {
          await Hive.box(userdata)
              .put(userGender, send!.resData!.gender.toString());
        }

        if (send!.resData!.countryFullName != '') {
          await Hive.box(userdata)
              .put(userCountryName, send!.resData!.countryFullName.toString());
        }

        _timer?.cancel();
        isLoading2 = false;
        Navigator.of(context, rootNavigator: true).pop();
        _setDataToHive(send!);

        if (Hive.box(userdata).get(authToken) != null &&
            Hive.box(userdata).get(lastName) != null &&
            Hive.box(userdata).get(lastName)!.isNotEmpty &&
            Hive.box(userdata).get(firstName) != null &&
            Hive.box(userdata).get(firstName)!.isNotEmpty) {
          print("☺☺☺☺GO TO HOME PAGE☺☺☺☺");
          Get.offAll(TabbarScreen(
            currentTab: 0,
          ));
        } else {
          Navigator.pushReplacement(
            context,
            PageTransition(
              curve: Curves.linear,
              type: PageTransitionType.rightToLeft,
              child: AddPersonaDetails(isRought: false, isback: false),
            ),
          );
        }
        _timer?.cancel();
        if (mounted) {
          setState(() {
            isLoading2 = false;
          });
        }
      } else {
        setState(() {
          isLoading2 = false;
        });

        showCustomToast(languageController.textTranslate('CANNOT VERIFY OTP'));
      }
    } else {
      setState(() {
        isLoading2 = false;
      });

      showCustomToast(languageController.textTranslate('Please Enter OTP'));
    }
  }

  FirebaseOtpModel? firebaseSend;
  otpcheckFirebase() async {
    if (_code.isNotEmpty) {
      setState(() {
        isLoading2 = true;
      });
      var uri = Uri.parse("${ApiHelper.baseUrl}/FirebaseOtp");
      var request = http.MultipartRequest("POST", uri);
      Map<String, String> headers = {
        "Accept": "application/json",
      };
      request.headers.addAll(headers);

      request.fields['otp'] = _code;

      request.fields['phone'] =
          widget.selectedCountry! + widget.phoneController;
      request.fields['device_token'] = _fcmtoken;
      request.fields['country_name'] = widget.countryName;

      var response = await request.send();
      print(response.statusCode);

      String responseData =
          await response.stream.transform(utf8.decoder).join();
      var userData = json.decode(responseData);
      firebaseSend = FirebaseOtpModel.fromJson(userData);
      log(responseData);
      if (firebaseSend!.responseCode == "1") {
        _timer?.cancel();
        isLoading2 = false;
        Navigator.of(context, rootNavigator: true).pop();
        _setDataToHiveFirebase(firebaseSend!);

        Navigator.pushReplacement(
          context,
          PageTransition(
            curve: Curves.linear,
            type: PageTransitionType.rightToLeft,
            child: AddPersonaDetails(isRought: false, isback: false),
          ),
        );
        _timer?.cancel();
        if (mounted) {
          setState(() {
            isLoading2 = false;
          });
        }
      } else {
        setState(() {
          isLoading2 = false;
        });
        showCustomToast(languageController.textTranslate('CANNOT VERIFY OTP'));
      }
    } else {
      setState(() {
        isLoading2 = false;
      });
      showCustomToast(languageController.textTranslate('Please Enter OTP'));
    }
  }

//============ SET DATA OTP RESPONSE DATA TO HIVE SAVE DATA =========================
  Future<void> _setDataToHive(VerifyOTPModel profileDetailResponse) async {
    await Hive.box(userdata).put(userId, profileDetailResponse.resData!.userId);
    await Hive.box(userdata).put(userCountryName, widget.countryName);
    await Hive.box(userdata).put(authToken, profileDetailResponse.token);
    await Hive.box(userdata).put(
        userMobile,
        profileDetailResponse.resData!.countryCode! +
            profileDetailResponse.resData!.phoneNumber!);

    await socketIntilized.initlizedsocket();
  }

//============ SET DATA FIREBASE OPT RESPONSE DATA TO HIVE SAVE DATA =========================
  Future<void> _setDataToHiveFirebase(
      FirebaseOtpModel profileDetailResponse) async {
    await Hive.box(userdata).put(userId, profileDetailResponse.userId);
    await Hive.box(userdata).put(userCountryName, widget.countryName);
    await Hive.box(userdata).put(userMobile, profileDetailResponse.phone);
  }

  bool isLoding = false;
  resendOtpFirebase() async {
    try {
      _timer?.cancel();

      _counter = 60;

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '${widget.selectedCountry}${widget.phoneController}',
        verificationCompleted: (PhoneAuthCredential credential) {},
        timeout: const Duration(seconds: 30),
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            isLoding = false;
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          otp.verify = verificationId;
          if (kDebugMode) {
            print('PHONE PAGE VARIFI::::$verificationId');
          }
          Fluttertoast.showToast(
              msg: languageController.textTranslate('OTP sent Succesfully'));
          setState(() {
            isLoding = false;
          });
          _startTimer();
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error');
      setState(() {
        isLoding = false;
      });
    }
  }

  resendoTP() async {
    if (widget.phoneController.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      _timer?.cancel();

      _counter = 300;
      var uri = Uri.parse(apiHelper.registerPhone);
      var request = http.MultipartRequest("POST", uri);
      Map<String, String> headers = {
        "Accept": "application/json",
      };
      request.headers.addAll(headers);
      request.fields['country_code'] = widget.selectedCountry!;
      request.fields['phone_number'] = widget.phoneController;
      var response = await request.send();

      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
          _startTimer();
        });

        print('REQUESTED FIELDS : ${request.fields}');
        print('OTP SENT SUCESSFULLY');
        showCustomToast(
            languageController.textTranslate('OTP SENT SUCESSFULLY'));
      } else {
        setState(() {
          isLoading = false;
        });
        showCustomToast(
            languageController.textTranslate('Enter valid Phone number'));
        print('Enter valid Phone number');
      }
    } else {
      setState(() {
        isLoading = false;
      });
      showCustomToast(languageController.textTranslate('Enter Phone number'));
      print('Enter Phone number');
    }
  }
}
