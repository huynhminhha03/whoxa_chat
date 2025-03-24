// ignore_for_file: use_build_context_synchronously, unused_local_variable, avoid_print, no_leading_underscores_for_local_identifiers, prefer_final_fields, unused_field, file_names

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:whoxachat/app.dart';
import 'package:whoxachat/src/global/api_helper.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:country_calling_code_picker/picker.dart';
import 'package:whoxachat/src/screens/user/otp.dart';
import 'package:whoxachat/src/screens/user/pp_and_tc_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';

final ApiHelper apiHelper = ApiHelper();

class Flogin extends StatefulWidget {
  const Flogin({super.key});

  static String verify = "";

  @override
  State<Flogin> createState() => _FloginState();
}

class _FloginState extends State<Flogin> {
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  GlobalKey<FormState> myKey5 = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();
  Country? _selectedCountry;
  Timer? _timer;
  int _counter = 0;
  String selectedCountry = 'United States of America';
  String selectedCountrycode = '+1';
  String selectedCountrySortName = 'US';
  String selectedCountryimg = '';
  int maxLength = 10;
  late TextEditingController controller;
  late bool autoFocus;
  int start = 60;
  bool wait = false;
  String _code = "";
  bool isLoading = false;
  bool isLoading2 = false;
  StreamController<int>? _events;
  void initCountry() async {
    Timer? _timer;
    int _counter = 0;
    Country? _selectedCountry;
    StreamController<int>? _events;
    final country = await getDefaultCountry(context);
    setState(() {
      _selectedCountry = country;
    });
    requestPermissions();
  }

  String mobileNumber = '';
  int? lengthNum;
  bool check = false;
  

  Future<void> requestPermissions() async {
    await Permission.notification.request();

    // await Permission.location.request();

    await Permission.camera.request();

    await Permission.microphone.request();

    await Permission.storage.request();

    await Permission.photos.request();

    await Permission.contacts.request();
  }

  void _startTimer() {
    _counter = 60;
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      (_counter > 0) ? _counter-- : _timer!.cancel();

      print(_counter);
      _events!.add(_counter);
    });
  }

  oTPcaLL() async {
    try {
      if (phoneController.text.isNotEmpty) {
        setState(() {
          isLoading = true;
        });
        var uri = Uri.parse(apiHelper.registerPhone);
        var request = http.MultipartRequest("POST", uri);
        Map<String, String> headers = {
          "Accept": "application/json",
        };
        request.headers.addAll(headers);
        print("URL: ${apiHelper.registerPhone}");
        request.fields['country_code'] = selectedCountrycode;
        request.fields['phone_number'] = phoneController.text;
        request.fields['country_full_name'] = selectedCountry;
        request.fields['country'] = selectedCountrySortName;

        print("FIELDS:${request.fields}");
        var response = await request.send();
        if (response.statusCode == 200) {
          setState(() {
            isLoading = false;
            _startTimer();
          });

          startTimer();

          showCustomToast(
              languageController.textTranslate('OTP SENT SUCESSFULLY'));

          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => otp(
                  phoneController: phoneController.text,
                  selectedCountry: selectedCountrycode,
                  countryName: selectedCountry,
                  varify: "",
                  inWhichScreen: 'Mobile screen',
                ),
              ));
        } else {
          setState(() {
            isLoading = false;
          });

          showCustomToast(
              languageController.textTranslate('Enter valid Phone number'));
        }
      } else {
        setState(() {
          isLoading = false;
        });

        showCustomToast(languageController.textTranslate('Enter Phone number'));
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
      Get.snackbar(
          "Error",
          languageController
              .textTranslate('Something went wrong while sending OTP'));
    }
  }

//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  @override
  initState() {
    _events = StreamController<int>();
    _events!.add(60);
    super.initState();
    print(start);
    initCountry();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColorWhite,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: appColorWhite,
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                key: myKey5,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                      color: appColorWhite,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30))),
                  child: header(),
                ),
              ),
              const SizedBox(height: 10),
              if (Platform.isIOS) button() else button(),
              const SizedBox(height: 35),
            ],
          ),
        ),
      ),
    );
  }

  Widget button() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: isLoading
            ? Center(
                child: SizedBox(
                height: 30,
                width: 30,
                child: CircularProgressIndicator(color: chatownColor),
              ))
            : CustomButtom(
                onPressed: () {
                  if (check == true) {
                    log("MOBILE_NUM:${selectedCountrycode + phoneController.text}");
                    if (myKey5.currentState!.validate()) {
                      setState(() {
                        isLoading = true;
                      });
                      sendOtp();
                    } else {
                      Fluttertoast.showToast(
                          msg: languageController
                              .textTranslate('Enter valid mobile number'));
                    }
                  } else {
                    Fluttertoast.showToast(
                        msg: languageController.textTranslate(
                            'Allow check to continue privacy policy and term condition'),
                        backgroundColor: Colors.black,
                        textColor: appColorWhite);
                  }
                },
                title: languageController.textTranslate('Send OTP'),
              ));
  }

  Widget header() {
    var country = _selectedCountry;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.09),
            ),
          ),
          Image.network(
            languageController.appSettingsData[0].appLogo!,
            height: 90,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 15),
          Image.asset("assets/images/welcome.png", height: 44),
          const SizedBox(height: 8),
          Text(
            languageController.textTranslate('Hello welcome to chat app'),
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                fontFamily: 'Poppins'),
          ),
          const SizedBox(height: 34),
          const SizedBox(
            height: 15,
          ),
          Align(
              alignment: Alignment.centerLeft,
              child: Text(
                languageController.textTranslate('Mobile Number'),
                style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    fontFamily: 'Poppins'),
              )),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Container(
                height: 47,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12)),
                  border:
                      Border.all(color: const Color.fromRGBO(176, 176, 176, 1)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: InkWell(
                        onTap: () {
                          _onPressedShowBottomSheet();
                        },
                        child: Row(
                          children: [
                            Text(
                              selectedCountrycode,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(
                              width: 2,
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: chatownColor,
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(left: 10),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12)),
                    border: Border(
                        top:
                            BorderSide(color: Color.fromRGBO(176, 176, 176, 1)),
                        right:
                            BorderSide(color: Color.fromRGBO(176, 176, 176, 1)),
                        bottom: BorderSide(
                            color: Color.fromRGBO(176, 176, 176, 1))),
                  ),
                  child: SizedBox(
                    height: 45,
                    child: TextField(
                        style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500),
                        cursorColor: Colors.black,
                        onChanged: (value) {
                          setState(() {
                            mobileNumber = value;
                          });
                        },
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(maxLength),
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        controller: phoneController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          contentPadding:
                              EdgeInsets.only(top: 1, left: 4, bottom: 1),
                          hintStyle: TextStyle(
                              fontSize: 17,
                              color: Colors.grey,
                              fontWeight: FontWeight.w400),
                          filled: true,
                          fillColor: Colors.transparent,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                        )),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
                languageController.textTranslate(
                    'We will send you 6 digit code on the given phone number'),
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Poppins')),
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.zero,
            margin: EdgeInsets.zero,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                        onTap: () {
                          setState(() {
                            check = !check;
                          });
                        },
                        child: check == true
                            ? selectedContainer()
                            : unSelectedContainer())
                    .paddingOnly(top: 4),
                const SizedBox(
                  width: 6,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {},
                    child: Obx(
                      () => Text.rich(
                        TextSpan(
                          text:
                              "${languageController.textTranslate('To continue, check')} ",
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins'),
                          children: [
                            TextSpan(
                              text: languageController
                                  .textTranslate('Privacy Policy'),
                              style: const TextStyle(
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.black,
                                decorationThickness: 1.5,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Get.to(PpAndTcScreen());
                                  // handleURLButtonPress(
                                  //     context, "${baseUrl()}get-privacy-policy");
                                },
                            ),
                            TextSpan(
                              text:
                                  " ${languageController.textTranslate('and')} ",
                            ),
                            TextSpan(
                              text: languageController
                                  .textTranslate('Terms & Conditions.'),
                              style: const TextStyle(
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.black,
                                decorationThickness: 1.5,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Get.to(PpAndTcScreen(
                                    isFromPP: false,
                                  ));
                                  // handleURLButtonPress(
                                  //     context, "${baseUrl()}get-tncs");
                                },
                            ),
                          ],
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ),
                ),
              ],
            ).paddingOnly(left: 0, right: 60),
          ),
        ],
      ),
    );
  }

  Widget selectedContainer() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 16,
      width: 16,
      decoration: BoxDecoration(
        // shape: BoxShape.circle,
        borderRadius: BorderRadius.circular(2),
        color: appColorBlack,
      ),
      child: Image.asset(
        "assets/images/check.png",
        scale: 2,
        color: appColorWhite,
      ).paddingAll(3),
    );
  }

  Widget unSelectedContainer() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 16,
      width: 16,
      decoration: BoxDecoration(
          // shape: BoxShape.circle,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(width: 1, color: appColorBlack)),
    );
  }

  void _onPressedShowBottomSheet() async {
    final country = await showCountryPickerSheet(
      context,
    );
    if (country != null) {
      setState(() {
        selectedCountrycode = country.callingCode;
        selectedCountry = country.name;
        selectedCountrySortName = country.countryCode;

        debugPrint("selectedCountry SortName $selectedCountrySortName");
        debugPrint("selectedCountry Name ${country.name}");

        _selectedCountry = country;

        maxLength = countryMobileLengths[selectedCountrycode] ?? 10;
      });
    }
  }

  void startTimer() {
    print("--------------------->>>>>>>");
    const onsec = Duration(seconds: 1);
    Timer _timer = Timer.periodic(onsec, (timer) {
      print(start);
      if (start == 0) {
        timer.cancel();
        wait = false;
      } else {
        start--;
      }
    });
  }


Future<void> sendOtp() async {
  try {
    final String phoneNumber = '$selectedCountrycode${phoneController.text}';
    
    // Debug: In đầu vào
    if (kDebugMode) {
      print('🔹 Sending OTP to: $phoneNumber');
    }

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {
        if (kDebugMode) {
          print('✅ Verification Completed: $credential');
        }
        setState(() {
          isLoading = false;
        });
      },
      timeout: const Duration(seconds: 30),
      verificationFailed: (FirebaseAuthException e) {
        if (kDebugMode) {
          print('❌ Verification Failed: ${e.code} - ${e.message}');
        }
        Fluttertoast.showToast(msg: e.message!, toastLength: Toast.LENGTH_LONG);
        setState(() {
          isLoading = false;
        });
      },
      codeSent: (String verificationId, int? resendToken) {
        if (kDebugMode) {
          print('📩 Code Sent! Verification ID: $verificationId, Resend Token: $resendToken');
        }
        
        
        Flogin.verify = verificationId;

        Fluttertoast.showToast(
          msg: languageController.textTranslate('OTP sent Successfully')
        );
        
        setState(() {
          isLoading = false;
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => otp(
              phoneController: phoneController.text,
              selectedCountry: selectedCountrycode,
              countryName: selectedCountry,
              varify: verificationId,
              inWhichScreen: 'Mobile screen',
            ),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        if (kDebugMode) {
          print('⏳ Code Auto Retrieval Timeout: $verificationId');
        }
      },
    );
  } catch (e) {
    // Bắt lỗi chung nếu có ngoại lệ không mong muốn
    if (kDebugMode) {
      print('🔥 Exception in sendOtp: $e');
    }
    Fluttertoast.showToast(msg: 'Error: $e', toastLength: Toast.LENGTH_LONG);
    setState(() {
      isLoading = false;
    });
  }
}

}
