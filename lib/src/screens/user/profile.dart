// ignore_for_file: avoid_print, use_build_context_synchronously, unnecessary_null_comparison
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:meyaoo_new/app.dart';
import 'package:meyaoo_new/controller/all_block_list_controller.dart';
import 'package:meyaoo_new/controller/all_star_msg_controller.dart';
import 'package:meyaoo_new/controller/avatar_controller.dart';
import 'package:meyaoo_new/src/global/global.dart';
import 'package:meyaoo_new/src/global/strings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:meyaoo_new/src/screens/chat/allstarred_msg_list.dart';
import 'package:meyaoo_new/src/screens/layout/tell_friend_list.dart';
import 'package:meyaoo_new/src/screens/user/FinalLogin.dart';
import 'package:meyaoo_new/src/screens/user/block_contact_list.dart';
import 'package:meyaoo_new/src/screens/user/create_profile.dart';
import 'package:meyaoo_new/src/screens/user/language_popup.dart';
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
  AvatarController avatarController = Get.find();

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
            height: Get.height * 0.27,
            width: double.infinity,
            child: Image.asset(
              cacheHeight: 140,
              "assets/images/back_img1.png",
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              SizedBox(height: Get.height * 0.13),
              profileWidget(),
              Expanded(child: SingleChildScrollView(child: aboutWidget())),
              const SizedBox(height: 10),
            ],
          ),
          const Positioned(
              top: 45,
              left: 15,
              child: Text(
                "Settings",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              )),
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

  String? profileImg;

  Widget profileWidget() {
    profileImg;
    if (checkForNull(Hive.box(userdata).get(userImage)) != null) {
      profileImg = Hive.box(userdata).get(userImage);
    }
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
                    child: profileImg != null &&
                            profileImg !=
                                "http://62.72.36.245:3000/uploads/not-found-images/profile-image.png" &&
                            avatarController.avatarIndex.value == -1 &&
                            image == null
                        ? avatarController.avatarsData
                                .where(
                                    (avatar) => avatar.avtarMedia == profileImg)
                                .map((avatar) => avatar.avtarMedia!)
                                .isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: profileImg!,
                                imageBuilder: (context, imageProvider) =>
                                    Container(
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
                            : CachedNetworkImage(
                                imageUrl: profileImg!,
                                imageBuilder: (context, imageProvider) =>
                                    Container(
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
                        : image == null
                            ? Obx(
                                () => avatarController.avatarIndex.value != -1
                                    ? CachedNetworkImage(
                                        imageUrl: avatarController
                                            .avatarsData[avatarController
                                                .avatarIndex.value]
                                            .avtarMedia!,
                                        imageBuilder:
                                            (context, imageProvider) =>
                                                Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.person,
                                                color: chatColor),
                                      )
                                    : Hive.box(userdata).get(userGender) ==
                                            "male"
                                        ? CachedNetworkImage(
                                            imageUrl: avatarController
                                                .avatarsData
                                                .where((avatar) =>
                                                    avatar.avatarGender ==
                                                        "male" &&
                                                    avatar.defaultAvtar == true)
                                                .map((avatar) =>
                                                    avatar.avtarMedia!)
                                                .first,
                                            imageBuilder:
                                                (context, imageProvider) =>
                                                    Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.person,
                                                        color: chatColor),
                                          )
                                        : Hive.box(userdata).get(userGender) !=
                                                    null &&
                                                Hive.box(userdata)
                                                        .get(userGender) ==
                                                    "female"
                                            ? CachedNetworkImage(
                                                imageUrl: avatarController
                                                    .avatarsData
                                                    .where((avatar) =>
                                                        avatar.avatarGender ==
                                                            "female" &&
                                                        avatar.defaultAvtar ==
                                                            true)
                                                    .map((avatar) =>
                                                        avatar.avtarMedia!)
                                                    .first,
                                                imageBuilder:
                                                    (context, imageProvider) =>
                                                        Container(
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    image: DecorationImage(
                                                      image: imageProvider,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        const Icon(Icons.person,
                                                            color: chatColor),
                                              )
                                            : Container(
                                                height: 30,
                                                width: 30,
                                                decoration: const BoxDecoration(
                                                    color: Color(0xFFFCC604),
                                                    shape: BoxShape.circle),
                                                child: const Icon(
                                                  Icons.person,
                                                  size: 30,
                                                  color: Colors.black,
                                                ),
                                              ),
                              )
                            : Image.file(image!, fit: BoxFit.cover)
                    //  CustomCachedNetworkImage(
                    //   imageUrl: Hive.box(userdata).get(userImage),
                    //   placeholderColor: chatownColor,
                    //   errorWidgeticon: const Icon(Icons.person),
                    // ),
                    ),
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
              Text(
                languageController.textTranslate('Online'),
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
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

                Get.find<AvatarController>().avatarIndex.value = -1;
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
              title: languageController.textTranslate('Profile'),
              about: ''),
          // ),

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
              title: languageController.textTranslate('About'),
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
                      transition: Transition.rightToLeft)!
                  .then((_) {
                allStaredMsgController.allStarred.refresh();
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
                      Image.asset("assets/images/starUnfill.png",
                          color: black1Color, height: 16),
                      const SizedBox(width: 10),
                      Text(
                        languageController.textTranslate('Starred Messages'),
                        style: const TextStyle(
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
                      Text(
                        languageController.textTranslate('Block Contacts'),
                        style: const TextStyle(
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
          containerProfileDesign(
            onTap: () {
              chooseLanguage();
            },
            image: 'assets/images/language-square.png',
            title: "App Language".tr,
            about: '',
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
              title: languageController.textTranslate('Tell a firend'),
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
              title: languageController.textTranslate('Share a link'),
              about: ''),
          const SizedBox(height: 10),
          //________________________________ LOGOUT ___________________________________________________
          InkWell(
            onTap: () async {
              //when app logout then user offline
              //store all uerData clear
              showDialog(
                barrierColor: const Color.fromRGBO(30, 30, 30, 0.37),
                context: context,
                builder: (BuildContext context) {
                  return BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                    child: AlertDialog(
                      insetPadding: const EdgeInsets.all(8),
                      alignment: Alignment.bottomCenter,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                      ),
                      content: SizedBox(
                        width: Get.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 10),
                            const Text(
                              "Are you sure you want to Logout?",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                            const SizedBox(height: 15),
                            const Text(
                              "Your session will expire upon logout. Are you absolutely sure?",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: appgrey2,
                                  fontSize: 13),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    height: 40,
                                    width: MediaQuery.of(context).size.width *
                                        0.35,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: yellow2Color, width: 1),
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: Center(
                                        child: Text(
                                      languageController
                                          .textTranslate('Cancel'),
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: chatColor),
                                    )),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                InkWell(
                                  onTap: () async {
                                    var box = Hive.box(userdata);
                                    await languageController
                                        .getLanguageTranslation();

                                    // Delete specific keys
                                    await box.delete(userId);
                                    await box.delete(authToken);
                                    await box.delete(firstName);
                                    await box.delete(lastName);
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
                                    height: 40,
                                    width: MediaQuery.of(context).size.width *
                                        0.35,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        gradient: LinearGradient(
                                            colors: [
                                              yellow1Color,
                                              yellow2Color
                                            ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter)),
                                    child: Center(
                                        child: Text(
                                      languageController
                                          .textTranslate('Logout'),
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: chatColor),
                                    )),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
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
                      Text(
                        languageController.textTranslate('Logout'),
                        style: const TextStyle(
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

          const SizedBox(
            height: 38,
          ),
          const CustomButtom(
            title: "Delete Account",
          ).paddingSymmetric(
            horizontal: 37,
          ),
          const SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }

  chooseLanguage() {
    return showDialog(
        context: context,
        barrierColor: const Color.fromRGBO(30, 30, 30, 0.37),
        builder: (BuildContext context) {
          return Stack(
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: const LanguagePopUp(),
              ),
            ],
          );
        });
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
                    Text(
                      languageController.textTranslate(
                          'Are you sure you want to delete your account?'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
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
                        child: Center(
                          child: Text(
                            languageController.textTranslate('YES'),
                            style: const TextStyle(
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
                        child: Center(
                          child: Text(
                            languageController.textTranslate('NO'),
                            style: const TextStyle(
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
