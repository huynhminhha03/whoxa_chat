// ignore_for_file: camel_case_types, unused_local_variable, avoid_print, use_build_context_synchronously, avoid_returning_null_for_void, prefer_if_null_operators
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:meyaoo_new/Models/user_profile_model.dart';
import 'package:meyaoo_new/src/global/api_helper.dart';
import 'package:meyaoo_new/src/global/global.dart';
import 'package:meyaoo_new/src/global/strings.dart';
import 'package:meyaoo_new/src/screens/user/about_2.dart';

final ApiHelper apiHelper = ApiHelper();

class about extends StatefulWidget {
  const about({super.key});

  @override
  State<about> createState() => _aboutState();
}

class _aboutState extends State<about> {
  //TextEditingController aboutController = TextEditingController();
  UserProfileModel userProfileModel = UserProfileModel();
  bool isSelectedmessage = false;
  String selectedabouttext = "";
  @override
  void initState() {
    statusText = Hive.box(userdata).get(userBio) == null
        ? ""
        : Hive.box(userdata).get(userBio);
    selectedabouttext = Hive.box(userdata).get(userBio) == null
        ? ""
        : Hive.box(userdata).get(userBio);
    super.initState();
  }

  List<Module> bioList = [
    Module("At work"),
    Module("Available"),
    Module("Busy"),
    Module("At Office"),
    Module("Battery about to die"),
    Module("In a metting"),
    Module("At the gym"),
    Module("Sleeping"),
  ];

  String statusText = '';

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: const Color(0xffFFEDAB).withOpacity(0.05),
      ),
      child: Scaffold(
        backgroundColor: appColorWhite,
        // appBar: AppBar(
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(0),
        //     side: BorderSide(color: Colors.grey.shade200),
        //   ),
        //   elevation: 0,
        //   backgroundColor: Colors.white,
        //   leading: InkWell(
        //     onTap: () {
        //       Navigator.pop(context);
        //     },
        //     child: const Icon(
        //       Icons.arrow_back_ios_new_rounded,
        //       size: 18,
        //       color: Colors.black,
        //     ),
        //   ),
        //   title: const Text(
        //     'About',
        //     style: TextStyle(
        //         color: Colors.black,
        //         fontSize: 20,
        //         fontFamily: "Poppins",
        //         fontWeight: FontWeight.w500),
        //   ),
        //   actions: [
        //     Padding(
        //       padding: const EdgeInsets.only(right: 12),
        //       child: InkWell(
        //         onTap: () {
        //           editApiCall();
        //         },
        //         child: statusText.isEmpty
        //             ? const SizedBox.shrink()
        //             : const Icon(Icons.check, color: Colors.black),
        //       ),
        //     ),
        //   ],
        // ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 130,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xffFFEDAB).withOpacity(0.04),
                      const Color(0xffFCC604).withOpacity(0.04),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: const Icon(
                        Icons.arrow_back_ios,
                        size: 20,
                        color: chatColor,
                      ),
                    ),
                    const SizedBox(
                      width: 7,
                    ),
                    const Text(
                      "About",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Poppins",
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        editApiCall();
                      },
                      child: statusText.isEmpty
                          ? const SizedBox.shrink()
                          : const Icon(Icons.check, color: Colors.black),
                    ),
                  ],
                ).paddingOnly(top: 20).paddingSymmetric(
                      horizontal: 28,
                    ),
              ),
              const Divider(
                color: Color(0xffE9E9E9),
                height: 1,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        'Currently set to',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Stack(
                        children: [
                          InkWell(
                            onLongPress: () {
                              Clipboard.setData(
                                  ClipboardData(text: statusText));
                            },
                            onTap: () async {
                              final result = await Get.to(() => about2(
                                    initialText: statusText,
                                  ));
                              if (result != null) {
                                setState(() {
                                  statusText = result;
                                });
                              }
                            },
                            child: Container(
                              width: Get.width * 0.90,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                  border:
                                      Border.all(color: Colors.grey.shade300)),
                              child: SelectableText(
                                statusText,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500),
                              ).paddingAll(12).paddingOnly(right: 5),
                            ),
                          ),
                          const Positioned(
                              top: 13,
                              right: 5,
                              child: Icon(Icons.arrow_forward_ios, size: 17))
                        ],
                      ),
                      // SizedBox(
                      //   height: 60,
                      //   width: MediaQuery.of(context).size.width,
                      //   child: TextField(
                      //       controller: aboutController,
                      //       readOnly: false,
                      //       enabled: false,
                      //       autofocus: false,
                      //       maxLength: 50,
                      //       style: const TextStyle(
                      //           color: Colors.black,
                      //           fontSize: 12,
                      //           fontWeight: FontWeight.w500),
                      //       textCapitalization: TextCapitalization.sentences,
                      //       decoration: InputDecoration(
                      //         enabledBorder: OutlineInputBorder(
                      //             borderRadius: BorderRadius.circular(10),
                      //             borderSide: const BorderSide(color: appgrey)),
                      //         focusedBorder: OutlineInputBorder(
                      //             borderSide: const BorderSide(color: appgrey),
                      //             borderRadius: BorderRadius.circular(10)),
                      //         disabledBorder: OutlineInputBorder(
                      //             borderSide: const BorderSide(color: appgrey),
                      //             borderRadius: BorderRadius.circular(10)),
                      //         border: OutlineInputBorder(
                      //           borderRadius: BorderRadius.circular(10),
                      //           borderSide: const BorderSide(color: appgrey),
                      //         ),
                      //         contentPadding: const EdgeInsets.only(
                      //             top: 1, left: 15, bottom: 1),
                      //         suffixIcon: const Icon(Icons.arrow_forward_ios,
                      //             size: 17, color: Colors.black),
                      //         hintText: 'Type here',
                      //         hintStyle: const TextStyle(
                      //             fontSize: 12,
                      //             color: Colors.grey,
                      //             fontWeight: FontWeight.w400),
                      //         filled: true,
                      //         fillColor: Colors.white,

                      //         // ),
                      //       )),
                      // ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        'Select your About',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade300)),
                        child: ListView.separated(
                            itemCount: bioList.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            padding: EdgeInsets.zero,
                            separatorBuilder: (context, index) {
                              return index != bioList.length - 1
                                  ? Divider(
                                      height: 1,
                                      color: Colors.grey.shade300,
                                    )
                                  : const SizedBox.shrink();
                            },
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedabouttext =
                                        bioList[index].name.toString();
                                    statusText = bioList[index].name.toString();
                                    selectedabouttext =
                                        bioList[index].name.toString();
                                  });
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Expanded(
                                      child:
                                          Text(bioList[index].name.toString(),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                                color: Colors.black,
                                              )).paddingOnly(left: 12),
                                    ),
                                    // Your additional condition here

                                    bioList[index].name.toString() ==
                                            selectedabouttext
                                        ? Container(
                                            height: 20,
                                            width: 20,
                                            decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: chatownColor),
                                            child: const Icon(
                                              Icons.check,
                                              color: chatColor,
                                              size: 15,
                                            ),
                                          ).paddingOnly(right: 12)
                                        : const SizedBox()
                                  ],
                                ),
                              ).paddingOnly(top: 15, bottom: 15);
                            }),
                      ),
                    ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool isLoading = false;
  editApiCall() async {
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
    request.fields['bio'] = statusText;

    print(request.fields);

    var response = await request.send();

    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);
    userProfileModel = UserProfileModel.fromJson(userData);

    print("DATA:$responseData");

    if (userProfileModel.success == true) {
      await Hive.box(userdata)
          .put(userBio, userProfileModel.resData!.bio.toString());
      setState(() {
        isLoading = false;
      });

      log(responseData);
      Get.back();
      showCustomToast("Update");
    } else {
      setState(() {
        isLoading = false;
      });
      showCustomToast("Error");
    }
  }
}

class Module {
  final String name;

  Module(this.name);
}
