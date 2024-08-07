// ignore_for_file: avoid_print, use_build_context_synchronously, unnecessary_null_comparison
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meyaoo_new/controller/all_block_list_controller.dart';
import 'package:meyaoo_new/controller/all_star_msg_controller.dart';
import 'package:meyaoo_new/src/global/global.dart';
import 'package:meyaoo_new/src/global/strings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:meyaoo_new/src/screens/chat/allstarred_msg_list.dart';
import 'package:meyaoo_new/src/screens/layout/tell_friend_list.dart';
import 'package:meyaoo_new/src/screens/user/FinalLogin.dart';
import 'package:meyaoo_new/src/screens/user/block_contact_list.dart';
import 'package:meyaoo_new/src/screens/user/profile2.dart';
import 'package:meyaoo_new/src/screens/user/profile_about.dart';
import 'package:share_plus/share_plus.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  AllBlockListController allBlockListController = Get.find();
  AllStaredMsgController allStaredMsgController = Get.find();

  @override
  void initState() {
    print(
      checkForNull(Hive.box(userdata).get(userGender)) != null
          ? Hive.box(userdata).get(userGender).toString().toTitleCase()
          : '',
    );
    allBlockListController.getBlockListApi();
    allStaredMsgController.getAllStarMsg('');
    super.initState();
  }

  bool isLoading = false;
  File? image;
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: appColorWhite,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: chatownColor,
          scrolledUnderElevation: 0,
          title: const Center(
            child: Text(
              "Profile",
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
          ),
        ),
        body: SafeArea(
            child: Stack(children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.9,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  profileWidget(),
                  Divider(
                    color: Colors.grey.shade300,
                  ),
                  aboutWidget(),
                  // InkWell(
                  //   onTap: () {
                  //     // if (internetController.isOnline.value) {
                  //     //   //deleteAccApi();
                  //     //   deleteAccAsk();
                  //     // } else {
                  //     //   Fluttertoast.showToast(
                  //     //       msg: "Check your connectivity",
                  //     //       gravity: ToastGravity.BOTTOM);
                  //     // }
                  //     deleteAccAsk();
                  //   },
                  //   child: Container(
                  //     height: 55,
                  //     width: MediaQuery.sizeOf(context).width * 0.90,
                  //     decoration: BoxDecoration(
                  //         borderRadius: BorderRadius.circular(5),
                  //         color: const Color.fromRGBO(255, 244, 244, 1.000)),
                  //     child: Row(
                  //       crossAxisAlignment: CrossAxisAlignment.center,
                  //       children: [
                  //         const SizedBox(width: 15),
                  //         Image.asset("assets/images/trash.png"),
                  //         const SizedBox(width: 7),
                  //         const Padding(
                  //           padding: EdgeInsets.only(top: 4),
                  //           child: Text(
                  //             "Delete Account",
                  //             style: TextStyle(
                  //                 fontSize: 13,
                  //                 fontWeight: FontWeight.w400,
                  //                 color: Color.fromRGBO(255, 40, 40, 1.000)),
                  //           ),
                  //         )
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  //const SizedBox(height: 15),
                  InkWell(
                    onTap: () {
                      //when app logout then user offline
                      //store all uerData clear
                      Hive.box(userdata).clear();
                      // then navigate to login page
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Flogin(),
                          ),
                          (route) => false);
                    },
                    child: Container(
                      height: 55,
                      width: MediaQuery.sizeOf(context).width * 0.90,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: chatStrokeColor),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(width: 15),
                          Image.asset("assets/images/logout.png",
                              height: 20, color: chatownColor),
                          const SizedBox(width: 7),
                          const Padding(
                            padding: EdgeInsets.only(top: 3),
                            child: Text(
                              "Logout",
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: chatownColor),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          // internetController.isOnline.value
          //     ? const SizedBox.shrink()
          //     : Positioned(
          //         bottom: 0.5,
          //         child: Container(
          //             width: Get.width,
          //             decoration: const BoxDecoration(color: chatownColor),
          //             child: Center(
          //               child: const Text(
          //                 "No Internet",
          //                 style: TextStyle(fontSize: 15, color: chatColor),
          //               ).paddingSymmetric(vertical: 8),
          //             )),
          //       ),
        ])));
  }

  Widget profileWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Hero(
                tag: '1',
                child: Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(),
                    child: Padding(
                        padding: const EdgeInsets.only(left: 1),
                        child: CustomCachedNetworkImage(
                          imageUrl: Hive.box(userdata).get(userImage),
                          placeholderColor: chatownColor,
                          errorWidgeticon: const Icon(Icons.person),
                        )),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${Hive.box(userdata).get(firstName)} ${Hive.box(userdata).get(lastName)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/images/call_1.png",
                        height: 20,
                        color: Colors.grey,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text('${Hive.box(userdata).get(userMobile)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Colors.grey,
                          ))
                    ],
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: InkWell(
              onTap: () {
                // internetController.isOnline.value
                //     ?
                Get.to(const profile2(),
                        duration: const Duration(milliseconds: 800),
                        transition: Transition.rightToLeft)!
                    .then((_) {
                  setState(() {});
                });

                // : Fluttertoast.showToast(
                //     msg: "Check your connectivity",
                //     gravity: ToastGravity.BOTTOM);
              },
              child: Container(
                height: 32,
                width: 62,
                decoration: BoxDecoration(
                    border: Border.all(color: chatownColor),
                    borderRadius: BorderRadius.circular(10),
                    color: chatStrokeColor),
                child: const Center(
                    child: Text(
                  "Edit",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget aboutWidget() {
    return Padding(
      padding: const EdgeInsets.only(left: 18, right: 18),
      child: Column(
        children: [
          const SizedBox(height: 10),
          //___________________________________AOBUT____________________________
          InkWell(
            onTap: () {
              // internetController.isOnline.value
              //     ?
              Get.to(() => const about(), transition: Transition.rightToLeft)!
                  .then((value) {
                print("BACK");
                setState(() {});
              });
              // : Fluttertoast.showToast(
              //     msg: "Check your connectivity",
              //     gravity: ToastGravity.BOTTOM);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(45),
                          color: Colors.grey.shade200),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/images/message-text.svg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "About",
                      style: TextStyle(
                          fontSize: 14.5, fontWeight: FontWeight.w500),
                    )
                  ],
                ),
                Row(
                  children: [
                    SizedBox(
                      width: Get.width * .45,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          Hive.box(userdata).get(userBio) == null
                              ? ""
                              : capitalizeFirstLetter(
                                  Hive.box(userdata).get(userBio)),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 17)
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 10),
          Divider(
            thickness: 1,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 10),
          //____________________________________ Starred Messaged ________________________________
          InkWell(
            onTap: () {
              // internetController.isOnline.value
              //     ?
              Get.to(AllStarredMsgList(index: 0),
                  transition: Transition.rightToLeft);
              // : Fluttertoast.showToast(
              //     msg: "Check your connectivity",
              //     gravity: ToastGravity.BOTTOM);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(45),
                          color: Colors.grey.shade200),
                      child: Center(
                        child: Image.asset("assets/images/starUnfill.png",
                            color: chatColor, height: 20),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Starred Messages",
                      style: TextStyle(
                          fontSize: 14.5, fontWeight: FontWeight.w500),
                    )
                  ],
                ),
                Row(
                  children: [
                    Obx(() {
                      return Text(
                        allStaredMsgController.allStarred.isEmpty
                            ? "0"
                            : allStaredMsgController.allStarred.length
                                .toString(),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w400,
                        ),
                      );
                    }),
                    const SizedBox(width: 15),
                    const Icon(Icons.arrow_forward_ios, size: 17)
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 10),
          Divider(
            thickness: 1,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 10),
          //_______________________________________________ BLOCK CONTACTS_____________________________
          InkWell(
            onTap: () {
              // internetController.isOnline.value
              //     ?
              Get.to(const BlockList(), transition: Transition.rightToLeft)!
                  .then((value) {
                Get.find<AllBlockListController>().getBlockListApi();
              });
              // : Fluttertoast.showToast(
              //     msg: "Check your connectivity",
              //     gravity: ToastGravity.BOTTOM);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(45),
                          color: Colors.grey.shade200),
                      child: Center(
                          child: SvgPicture.asset(
                        'assets/images/stop-circle.svg',
                        fit: BoxFit.cover,
                      )),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Block Contacts",
                      style: TextStyle(
                          fontSize: 14.5, fontWeight: FontWeight.w500),
                    )
                  ],
                ),
                Row(
                  children: [
                    Obx(() {
                      return Text(
                        allBlockListController.allBlock.isEmpty
                            ? "0"
                            : allBlockListController.allBlock.length.toString(),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w400,
                        ),
                      );
                    }),
                    const SizedBox(width: 15),
                    const Icon(Icons.arrow_forward_ios, size: 17)
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 10),
          Divider(
            thickness: 1,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 10),
          //_________________________________ TELL FRIEND_____________________________________________
          InkWell(
            onTap: () {
              // internetController.isOnline.value
              //     ?
              Get.to(const InviteFriend(), transition: Transition.rightToLeft);
              // : Fluttertoast.showToast(
              //     msg: "Check your connectivity",
              //     gravity: ToastGravity.BOTTOM);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(45),
                          color: Colors.grey.shade200),
                      child: Center(
                        child: Image.asset("assets/images/sms-notification.png",
                            color: chatColor, height: 20),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Tell a firend",
                      style: TextStyle(
                          fontSize: 14.5, fontWeight: FontWeight.w500),
                    )
                  ],
                ),
                const Icon(Icons.arrow_forward_ios, size: 17)
              ],
            ),
          ),
          const SizedBox(height: 10),
          Divider(
            thickness: 1,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () {
              // internetController.isOnline.value
              //     ?
              Share.share('https://pub.dev/packages/share_plus',
                  subject: 'Check out this website');
              // : Fluttertoast.showToast(
              //     msg: "Check your connectivity",
              //     gravity: ToastGravity.BOTTOM);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(45),
                          color: Colors.grey.shade200),
                      child: const Center(
                        child: Icon(CupertinoIcons.share, size: 20),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Share a link",
                      style: TextStyle(
                          fontSize: 14.5, fontWeight: FontWeight.w500),
                    )
                  ],
                ),
                const Icon(Icons.arrow_forward_ios, size: 17)
              ],
            ),
          ),
          const SizedBox(height: 10),
          Divider(
            thickness: 1,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Future deleteAccAsk() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, kk) {
          return AlertDialog(
            backgroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
            ),
            content: SizedBox(
                height: 350,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          // shape: BoxShape.circle,
                          borderRadius: BorderRadius.circular(300),
                          color: const Color.fromARGB(255, 245, 243, 243),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: Hive.box(userdata).get(userImage),
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          placeholder: (context, url) =>
                              Center(child: loader(context)),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.person),
                        )),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      '${Hive.box(userdata).get(firstName)} ${Hive.box(userdata).get(lastName)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 18),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'Are you sure you want to delete your account?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Colors.grey),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 45,
                        width: 220,
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10)),
                        child: const Center(
                          child: Text(
                            'YES',
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 45,
                        width: 220,
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10)),
                        child: const Center(
                          child: Text(
                            'NO',
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
          );
        });
      },
    );
  }
}
