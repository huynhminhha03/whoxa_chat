// ignore_for_file: camel_case_types, unused_local_variable, avoid_print, use_build_context_synchronously, avoid_returning_null_for_void, prefer_if_null_operators
import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:meyaoo_new/Models/user_profile_model.dart';
import 'package:meyaoo_new/src/global/api_helper.dart';
import 'package:meyaoo_new/src/global/global.dart';
import 'package:meyaoo_new/src/global/strings.dart';

final ApiHelper apiHelper = ApiHelper();

class about extends StatefulWidget {
  const about({super.key});

  @override
  State<about> createState() => _aboutState();
}

class _aboutState extends State<about> {
  TextEditingController aboutController = TextEditingController();
  UserProfileModel userProfileModel = UserProfileModel();
  bool isSelectedmessage = false;
  String selectedabouttext = "";
  @override
  void initState() {
    aboutController.text = Hive.box(userdata).get(userBio) == null
        ? ""
        : Hive.box(userdata).get(userBio);
    selectedabouttext = Hive.box(userdata).get(userBio) == null
        ? ""
        : Hive.box(userdata).get(userBio);
    super.initState();
  }

  List<Module> bioList = [
    Module("Available"),
    Module("Busy"),
    Module("At school"),
    Module("At the movies"),
    Module("At work"),
    Module("Battery about to die"),
    Module("Can't talk, ChatsApp only"),
    Module("In a metting"),
    Module("At the gym"),
    Module("Sleeping"),
    Module("Urgent calls only"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColorWhite,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: chatownColor,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        title: const Text(
          'About',
          style: TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontFamily: "Poppins",
              fontWeight: FontWeight.w500),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () {
                editApiCall();
              },
              child: const Text(
                // aboutController.text.isEmpty ? 'Edit' : 'Done',
                "Edit",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 30,
                ),
                const Text(
                  'CURRENTLY SET TO',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 60,
                  width: MediaQuery.of(context).size.width,
                  child: TextField(
                      controller: aboutController,
                      readOnly: false,
                      maxLength: 50,
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
                        hintText: 'Type here',
                        hintStyle: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                            fontWeight: FontWeight.w400),
                        filled: true,
                        fillColor: Colors.transparent,

                        // ),
                      )),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'SELECT YOUR ABOUT',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                ListView.builder(
                    itemCount: bioList.length,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedabouttext =
                                    bioList[index].name.toString();
                                aboutController.text =
                                    bioList[index].name.toString();
                                selectedabouttext =
                                    bioList[index].name.toString();
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(bioList[index].name.toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 15,
                                        color: Colors.black,
                                      )),
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
                                      )
                                    : const SizedBox()
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Divider(
                            height: 1,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                        ],
                      );
                    }),
              ]),
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
    request.fields['bio'] = aboutController.text;

    print(request.fields);

    var response = await request.send();

    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);
    userProfileModel = UserProfileModel.fromJson(userData);

    print(responseData);

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
