// ignore_for_file: avoid_print, use_build_context_synchronously, unnecessary_null_comparison
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:meyaoo_new/controller/all_block_list_controller.dart';
import 'package:meyaoo_new/controller/all_star_msg_controller.dart';
import 'package:meyaoo_new/src/global/global.dart';
import 'package:meyaoo_new/src/global/strings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:meyaoo_new/src/screens/chat/allstarred_msg_list.dart';
import 'package:meyaoo_new/src/screens/layout/tell_friend_list.dart';
import 'package:meyaoo_new/src/screens/user/FinalLogin.dart';
import 'package:meyaoo_new/src/screens/user/block_contact_list.dart';
import 'package:meyaoo_new/src/screens/user/create_profile.dart';
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
        extendBodyBehindAppBar: true,
        backgroundColor: const Color.fromRGBO(250, 250, 250, 1),
        body: Stack(children: [
          SizedBox(
            height: 200,
            width: double.infinity,
            child: Image.asset(
              cacheHeight: 140,
              "assets/images/back_img1.png",
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 80),
              profileWidget(),
              Expanded(child: SingleChildScrollView(child: aboutWidget())),
              const SizedBox(height: 10),
            ],
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
        ]));
  }

  Widget profileWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Hero(
            tag: '1',
            child: Center(
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(110)),
                child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: CustomCachedNetworkImage(
                      imageUrl: Hive.box(userdata).get(userImage),
                      placeholderColor: chatownColor,
                      errorWidgeticon: const Icon(Icons.person),
                    )),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '${Hive.box(userdata).get(firstName)} ${Hive.box(userdata).get(lastName)}',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 3),
              Stack(
                alignment: Alignment.center,
                children: [
                  Lottie.asset(
                    'assets/Lottie ANIMATION/call_recieve_animation.json',
                    height: 15,
                    width: 15,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    height: 5,
                    width: 5,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.green),
                  )
                ],
              ),
              const SizedBox(width: 3),
              const Text(
                "Online",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget aboutWidget() {
    return Padding(
      padding: const EdgeInsets.only(left: 18, right: 18),
      child: Column(
        children: [
          //_________________________________ PROFILE _____________________________________________
          containerProfileDesign(
              onTap: () {
                // internetController.isOnline.value
                //     ?
                Get.to(AddPersonaDetails(isRought: true, isback: true),
                        duration: const Duration(milliseconds: 800),
                        transition: Transition.rightToLeft)!
                    .then((_) {
                  setState(() {});
                });

                // : Fluttertoast.showToast(
                //     msg: "Check your connectivity",
                //     gravity: ToastGravity.BOTTOM);
              },
              image: 'assets/images/about.png',
              title: 'Profile',
              about: ''),

          const SizedBox(height: 10),
          //__________________________________ AOBUT_______________________________________________
          containerProfileDesign(
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
              image: 'assets/images/about.png',
              title: 'About',
              about: Hive.box(userdata).get(userBio) == null
                  ? ""
                  : capitalizeFirstLetter(Hive.box(userdata).get(userBio))),
          const SizedBox(height: 10),
          //_________________________________ Starred Messaged _____________________________________
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
            child: Container(
              height: 46,
              width: Get.width * 90,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade200)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset("assets/images/starUnfill.png",
                          color: black1Color, height: 16),
                      const SizedBox(width: 10),
                      const Text(
                        "Starred Messages",
                        style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600),
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
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  )
                ],
              ).paddingSymmetric(horizontal: 10),
            ),
          ),
          const SizedBox(height: 10),
          //_________________________________ BLOCK CONTACTS_________________________________________
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
            child: Container(
              height: 46,
              width: Get.width * 90,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade200)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/block1.png',
                        fit: BoxFit.cover,
                        height: 16,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Block Contacts",
                        style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Obx(() {
                        return Text(
                          allBlockListController.allBlock.isEmpty
                              ? "0"
                              : allBlockListController.allBlock.length
                                  .toString(),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w400,
                          ),
                        );
                      }),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  )
                ],
              ).paddingSymmetric(horizontal: 10),
            ),
          ),
          const SizedBox(height: 10),
          //_________________________________ TELL FRIEND_____________________________________________
          containerProfileDesign(
              onTap: () {
                // internetController.isOnline.value
                //     ?
                Get.to(const InviteFriend(),
                    transition: Transition.rightToLeft);
                // : Fluttertoast.showToast(
                //     msg: "Check your connectivity",
                //     gravity: ToastGravity.BOTTOM);
              },
              image: 'assets/images/share1.png',
              title: "Tell a firend",
              about: ''),
          const SizedBox(height: 10),
          //_________________________________ SHARE LINK_____________________________________________
          containerProfileDesign(
              onTap: () {
                // internetController.isOnline.value
                //     ?
                Share.share('https://pub.dev/packages/share_plus',
                    subject: 'Check out this website');
                // : Fluttertoast.showToast(
                //     msg: "Check your connectivity",
                //     gravity: ToastGravity.BOTTOM);
              },
              image: 'assets/images/share2.png',
              title: "Share a link",
              about: ''),
          const SizedBox(height: 10),
          //________________________________ LOGOUT ___________________________________________________
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
              height: 46,
              width: Get.width * 90,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade200)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        "assets/images/logout.png",
                        fit: BoxFit.cover,
                        color: Colors.red,
                        height: 16,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Logout",
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16)
                ],
              ).paddingSymmetric(horizontal: 10),
            ),
          ),
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
