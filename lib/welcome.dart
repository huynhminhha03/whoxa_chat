// ignore_for_file: avoid_print

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meyaoo_new/src/global/global.dart';
import 'package:meyaoo_new/src/screens/user/FinalLogin.dart';
import 'package:meyaoo_new/web_view.dart';
import 'package:permission_handler/permission_handler.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  bool check = false;

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

  @override
  Widget build(BuildContext context) {
    void handleURLButtonPress(BuildContext context, String url) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => PrivacyWebView(url: url)));
    }

    return Scaffold(
      backgroundColor: const Color(0xffFFFFFF),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 50.6,
            color: chatownColor,
          ),
          Container(
              width: double.infinity,
              color: chatownColor,
              child: const Text(
                "Chatapp",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
              )),
          Container(
            height: 20.6,
            color: chatownColor,
          ),
          Flexible(
            flex: 1,
            child: Container(
              width: MediaQuery.of(context).size.width * 2.9,
              decoration: const BoxDecoration(color: chatownColor),
              child: SvgPicture.asset(
                'assets/images/welcome-cropped (3).svg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * .52,
            width: MediaQuery.of(context).size.width * 1.2,
            decoration: const BoxDecoration(
              color: Colors.black,
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 25),
              child: Column(
                children: [
                  const SizedBox(
                    height: 75,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      'Stay connected with your friends and family',
                      style: TextStyle(
                          fontSize: 34,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Schyler'),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Checkbox(
                          fillColor: MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                            if (states.contains(MaterialState.disabled)) {
                              return const Color(0xFFE2E2E2).withOpacity(.32);
                            }
                            return chatownColor;
                          }),
                          side: const BorderSide(color: chatownColor),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                          // side: BorderSide(),
                          activeColor: chatownColor,
                          checkColor: chatColor,
                          value: check,
                          onChanged: (bool? value) {
                            setState(() {
                              check = value!;
                            });
                            print(check);
                          },
                        ),
                      ),
                      Flexible(
                        child: GestureDetector(
                          onTap: () {
                            // Add your navigation logic or any other action here
                          },
                          child: Text.rich(
                            TextSpan(
                              text: 'To continue, check ',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Schyler',
                              ),
                              children: [
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.white,
                                    decorationThickness: 1.5,
                                  ),
                                  // Add your onTap logic for Privacy Policy
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      // Add your navigation logic or any other action here
                                      handleURLButtonPress(context,
                                          "https://theprimocys.com/privacy-policy-whoxa.html");
                                    },
                                ),
                                const TextSpan(
                                  text: ' and ',
                                ),
                                TextSpan(
                                  text: 'Terms & Conditions.',
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.white,
                                    decorationThickness: 1.5,
                                  ),
                                  // Add your onTap logic for Term Condition
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      // Add your navigation logic or any other action here
                                      handleURLButtonPress(context,
                                          "https://theprimocys.com/Terms-of-use-whoxa.html");
                                    },
                                ),
                              ],
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  GestureDetector(
                    onTap: () async {
                      //await Hive.box(userdata).put(authToken, pawanTOKEN);
                      check == true
                          ? Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Flogin()),
                              (route) => false)
                          : Fluttertoast.showToast(
                              msg:
                                  "Allow check to continue privacy policy and term condition",
                              backgroundColor: Colors.white,
                              textColor: chatColor);
                    },
                    child: Container(
                      height: 53,
                      width: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.white),
                      child: const Center(
                          child: Text(
                        'Get Started',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Schyler'),
                      )),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
