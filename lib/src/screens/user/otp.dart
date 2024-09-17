// ignore_for_file: avoid_print, use_build_context_synchronously, must_be_immutable, no_leading_underscores_for_local_identifiers, unused_local_variable, non_constant_identifier_names, camel_case_types

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:meyaoo_new/Models/VerifyotpModel.dart';
import 'package:meyaoo_new/Models/firebase_otp_model.dart';
import 'package:meyaoo_new/main.dart';
import 'package:meyaoo_new/src/global/api_helper.dart';
import 'package:meyaoo_new/src/global/global.dart';
import 'package:meyaoo_new/src/global/strings.dart';
import 'package:meyaoo_new/src/screens/user/create_profile.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:http/http.dart' as http;

final ApiHelper apiHelper = ApiHelper();

class otp extends StatefulWidget {
  String phoneController;
  final String? varify;
  final TextEditingController? email;
  final String? selectedCountry;
  final String inWhichScreen;
  final String countryName;
  //String otpStatus;
  otp({
    super.key,
    required this.phoneController,
    this.varify,
    this.email,
    this.selectedCountry,
    required this.inWhichScreen,
    required this.countryName,
    // required this.otpStatus
  });

  static String verify = "";

  @override
  State<otp> createState() => _otpState();
}

class _otpState extends State<otp> {
  // final TextEditingController phoneController = TextEditingController();

  int _counter = 0;

  Timer? _timer;

  String selectedCountryimg = '';
  late TextEditingController controller;
  late bool autoFocus;
  int start = 60;
  bool wait = false;
  String _code = "";
  bool isOtpComplete = false;
  bool isLoading = false;
  bool isLoading2 = false;
  StreamController<int>? _events;

  VerifyOTPModel? send;
  void _startTimer() {
    _counter = 300;
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      //setState(() {
      (_counter > 0) ? _counter-- : _timer!.cancel();
      //});
      if (_counter == 0) {
        showCustomToast("Please resend OTP");
        _code = "";
      }

      // Add minutes and seconds calculation
      int minutes = _counter ~/ 60;
      int seconds = _counter % 60;

      print('$minutes:${seconds.toString().padLeft(2, '0')}');
      // print(_counter);
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

  @override
  void initState() {
    log("COUNTRY_NAME: ${widget.countryName}");
    _getToken();

    _events = StreamController<int>();
    _events!.add(60);
    super.initState();
    print(start);
    _startTimer();
    // initCountry();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      // bottomNavigationBar: BottomAppBar(
      //   color: Colors.white,
      //   elevation: 0,
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: [
      //       Expanded(
      //         child: Padding(
      //           padding: const EdgeInsets.symmetric(horizontal: 15),
      //           child: button(),
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
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
            ? const Center(
                child: SizedBox(
                height: 30,
                width: 30,
                child: CircularProgressIndicator(color: chatownColor),
              ))
            : CustomButtom(
                onPressed: () {
                  setState(() {
                    isOtpComplete //otpcheck()
                        ?
                        // widget.otpStatus == "firebase"
                        //     ? otpcheckFirebase()
                        //     : otpcheck()
                        otpcheck()
                        : _counter == 0
                            ? showCustomToast("Please Resend OTP")
                            : showCustomToast("Please Enter OTP");
                  });
                },
                title: "Login",
              ));
  }

  Widget otp_widget() {
    return Column(
      children: [
        StreamBuilder<int>(
            stream: _events!.stream,
            builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
              // print(snapshot.data.toString());
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Image.asset("assets/images/logo.png", height: 90),
                    const SizedBox(height: 15),
                    Image.asset("assets/images/welcome.png", height: 44),
                    const SizedBox(height: 8),
                    const Text(
                      "Hello welcome to chat app",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Poppins'),
                    ),
                    const SizedBox(height: 34),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '6 digit OTP has been sent to',
                        style: TextStyle(
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
                    OtpTextField(
                      // contentPadding:
                      //     const EdgeInsets.only(bottom: 2, left: 20, right: 20),
                      showCursor: true,
                      cursorColor: Colors.black,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      fieldWidth: 50, fieldHeight: 60,
                      numberOfFields: 6,
                      clearText: true,
                      borderColor: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                      showFieldAsBox: true,
                      focusedBorderColor: chatownColor,
                      margin: EdgeInsets.zero,
                      onCodeChanged: (String code) {
                        setState(() {
                          _code = code;
                          isOtpComplete = code.length == 6;
                        });
                        print("OTP : $code");
                      },
                      //runs when every textfield is filled
                      onSubmit: (String verificationCode) {
                        setState(() {
                          _code = verificationCode;
                          isOtpComplete = verificationCode.length == 6;
                          // otpcheck();
                        });
                      },
                    ).paddingSymmetric(horizontal: 20),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                          onTap: () {
                            if (_code.isNotEmpty) {
                              showCustomToast(
                                  "You can't send otp once it's enetered");
                            } else {
                              "${(snapshot.data! ~/ 60).toString().padLeft(2, '0')}:${(snapshot.data! % 60).toString().padLeft(2, '0')}" ==
                                      "00:00"
                                  ?
                                  // widget.otpStatus == "firebase"
                                  //     ? resendOtpFirebase()
                                  //     : resendoTP()
                                  resendoTP()
                                  : showCustomToast(
                                      "Wait for a ${(snapshot.data! ~/ 60).toString().padLeft(2, '0')}:${(snapshot.data! % 60).toString().padLeft(2, '0')} ");
                            }
                          },
                          child: Text(
                            "Resend OTP",
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
                          //otpcheck();
                        },
                        child: Center(
                          child: Text(
                            // 'Resend Code in 00:${snapshot.data.toString().padLeft(2, '0')}',
                            "Resend Code in ${(snapshot.data! ~/ 60).toString().padLeft(2, '0')}:${(snapshot.data! % 60).toString().padLeft(2, '0')}",
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
                  ],
                ),
              );
            }),
      ],
    );
  }

  // void startTimer() {
  //   print("--------------------->>>>>>>");
  //   const onsec = Duration(seconds: 1);
  //   Timer _timer = Timer.periodic(onsec, (timer) {
  //     print(start);
  //     if (start == 0) {
  //       setState(() {
  //         timer.cancel();
  //         wait = false;
  //       });
  //     } else {
  //       setState(() {
  //         start--;
  //       });
  //     }
  //   });
  // }

  otpcheck() async {
    if (_code.isNotEmpty) {
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
      request.fields['otp'] = _code;
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
        // Cancel the timer if responseCode is 1
        _timer?.cancel(); // Cancelling the timer
        isLoading2 = false;
        Navigator.of(context, rootNavigator: true).pop();
        _setDataToHive(send!);

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

        showCustomToast("CANNOT VERIFY OTP");
      }
    } else {
      setState(() {
        isLoading2 = false;
      });

      showCustomToast("Please Enter OTP");
    }
  }

  FirebaseOtpModel? firebaseSend;
  otpcheckFirebase() async {
    if (_code.isNotEmpty) {
      setState(() {
        isLoading2 = true;
      });
      var uri = Uri.parse("${baseUrl()}FirebaseOtp");
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
        // Cancel the timer if responseCode is 1
        _timer?.cancel(); // Cancelling the timer
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
        showCustomToast("CANNOT VERIFY OTP");
      }
    } else {
      setState(() {
        isLoading2 = false;
      });
      showCustomToast("Please Enter OTP");
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

      // Reset the counter back to 60
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
          Fluttertoast.showToast(msg: 'OTP sent Succesfully');
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

      // Reset the counter back to 60
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
        // print('instructor_id : ${userData['instructor_id']}');
        setState(() {
          isLoading = false;
          _startTimer();
        });

        print('REQUESTED FIELDS : ${request.fields}');
        print('OTP SENT SUCESSFULLY');
        showCustomToast("OTP SENT SUCESSFULLY");
      } else {
        setState(() {
          isLoading = false;
        });
        showCustomToast("Enter valid Phone number");
        print('Enter valid Phone number');
      }
    } else {
      setState(() {
        isLoading = false;
      });
      showCustomToast("Enter Phone number");
      print('Enter Phone number');
    }
  }
}
