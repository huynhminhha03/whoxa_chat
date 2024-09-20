// ignore_for_file: use_build_context_synchronously, unused_local_variable, avoid_print, no_leading_underscores_for_local_identifiers, prefer_final_fields, unused_field, file_names

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meyaoo_new/app.dart';
import 'package:meyaoo_new/src/global/api_helper.dart';
import 'package:meyaoo_new/src/global/global.dart';
import 'package:country_calling_code_picker/picker.dart';
import 'package:meyaoo_new/src/screens/user/otp.dart';
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
  String selectedCountry = 'india';
  String selectedCountrycode = '+91';
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

  Future<void> requestPermissions() async {
    // Request notification permission
    await Permission.notification.request();

    // Request location permission
    await Permission.location.request();

    // Request camera permission
    await Permission.camera.request();

    // Request microphone permission
    await Permission.microphone.request();

    // Request storage permission
    await Permission.storage.request();

    // Request photo library permission
    await Permission.photos.request();

    await Permission.contacts.request();
  }

  void _startTimer() {
    _counter = 60;
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      //setState(() {
      (_counter > 0) ? _counter-- : _timer!.cancel();
      //});
      print(_counter);
      _events!.add(_counter);
    });
  }

  //------------------------------------------------------------- OTP caLL -------------------------------------------------------------//
  // this api mobile number submit and otp get
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
                  //  otpStatus: userOtpStatus!.otpStatus![0].name!,
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
  //-------------------------------------------------------------otpcheck-------------------------------------------------------------//

//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  @override
  initState() {
    //otpStatus();
    _events = StreamController<int>();
    _events!.add(60);
    super.initState();
    print(start);
    initCountry();
  }

  // UserOtpStatus? userOtpStatus;
  // bool isLoad = false;
  // otpStatus() async {
  //   setState(() {
  //     isLoad = true;
  //   });
  //   try {
  //     var uri = Uri.parse("${baseUrl()}AdminOtpStatus");
  //     var request = http.MultipartRequest("GET", uri);
  //     Map<String, String> headers = {
  //       "Accept": "application/json",
  //     };
  //     request.headers.addAll(headers);
  //     var response = await request.send();
  //     String responseData =
  //         await response.stream.transform(utf8.decoder).join();
  //     var userData = json.decode(responseData);
  //     userOtpStatus = UserOtpStatus.fromJson(userData);
  //     print("OTP_STATUS:$responseData");
  //     if (userOtpStatus!.responseCode == "1") {
  //       setState(() {
  //         isLoad = false;
  //       });
  //     } else {
  //       setState(() {
  //         isLoad = false;
  //       });
  //     }
  //   } catch (e) {
  //     setState(() {
  //       isLoad = false;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: bg,
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
              const SizedBox(height: 10),
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
            ? const Center(
                child: SizedBox(
                height: 30,
                width: 30,
                child: CircularProgressIndicator(color: chatownColor),
              ))
            : CustomButtom(
                onPressed: () {
                  log("MOBILE_NUM:${selectedCountrycode + phoneController.text}");
                  if (myKey5.currentState!.validate()) {
                    setState(() {
                      isLoading = true;
                    });
                    oTPcaLL();
                    // userOtpStatus!.otpStatus![0].name == "firebase"
                    //     ? sendOtp()
                    //     : oTPcaLL();
                  } else {
                    Fluttertoast.showToast(
                        msg: languageController
                            .textTranslate('Enter valid mobile number'));
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
              // child: Image.asset("assets/images/Group 137.png"),
            ),
          ),
          Image.asset("assets/images/logo.png", height: 90),
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
                            const Icon(
                              Icons.arrow_drop_down,
                              color: appColorYellow,
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
                            mobileNumber =
                                value; // Update mobileNumber with the value from TextField
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
                          // ),
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
          )
        ],
      ),
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

        _selectedCountry = country;

        // Update maxLength based on the selected country
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
        // setState(() {
        //   timer.cancel();
        //   wait = false;
        // });
        timer.cancel();
        wait = false;
      } else {
        start--;
        // setState(() {
        //   start--;
        // });
      }
    });
  }

  Future sendOtp() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '$selectedCountrycode${phoneController.text}',
      verificationCompleted: (PhoneAuthCredential credential) {
        setState(() {
          isLoading = false;
        });
      },
      timeout: const Duration(seconds: 30),
      verificationFailed: (FirebaseAuthException e) {
        Fluttertoast.showToast(msg: e.message!, toastLength: Toast.LENGTH_LONG);
        setState(() {
          isLoading = false;
        });
      },
      codeSent: (String verificationId, int? resendToken) {
        Flogin.verify = verificationId;
        if (kDebugMode) {
          print('PHONE PAGE VARIFI::::$verificationId');
        }
        Fluttertoast.showToast(
            msg: languageController.textTranslate('OTP sent Succesfully'));
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
                //otpStatus: userOtpStatus!.otpStatus![0].name!,
              ),
            ));
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }
}
