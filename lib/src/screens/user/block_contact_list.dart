// ignore_for_file: avoid_print, unused_field
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:meyaoo_new/Models/block_list_model.dart';
import 'package:meyaoo_new/controller/all_block_list_controller.dart';
import 'package:meyaoo_new/controller/user_chatlist_controller.dart';
import 'package:meyaoo_new/src/global/global.dart';

class BlockList extends StatefulWidget {
  const BlockList({super.key});

  @override
  State<BlockList> createState() => _BlockListState();
}

class _BlockListState extends State<BlockList> {
  AllBlockListController allBlockListController = Get.find();
  ChatListController chatListController = Get.find();

  @override
  void initState() {
    allBlockListController.getBlockListApi();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: const Color(0xffFFEDAB).withOpacity(0.05),
      ),
      child: Scaffold(
          backgroundColor: appColorWhite,
          body: Column(
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
                      "Block List",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Poppins",
                      ),
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
              Expanded(
                child: Obx(() {
                  return allBlockListController.isLoading.value &&
                          allBlockListController.allBlock.isEmpty
                      ? loader(context)
                      : allBlockListController.allBlock.isNotEmpty
                          ? SingleChildScrollView(
                              child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 20, right: 20),
                              child: ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemCount:
                                      allBlockListController.allBlock.length,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    if (allBlockListController
                                        .allBlock[index]
                                        .conversation!
                                        .blockedUserDetails!
                                        .isNotEmpty) {
                                      return profileWidget(
                                          allBlockListController
                                              .allBlock[index],
                                          index);
                                    } else {
                                      return const SizedBox.shrink();
                                    }
                                  }),
                            ))
                          : Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 25),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      "assets/images/empty_block.png",
                                      height: 200,
                                      width: 200,
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      "You don’t have any block Contact",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Color(0xff959595),
                                          fontSize: 10,
                                          fontFamily: "Poppins",
                                          fontWeight: FontWeight.w400),
                                    ).paddingSymmetric(horizontal: 50)
                                  ],
                                ),
                              ),
                            );
                  // Center(
                  //     child: Column(
                  //       crossAxisAlignment: CrossAxisAlignment.center,
                  //       children: [
                  //         const SizedBox(height: 100),
                  //         Image.asset(
                  //           "assets/images/empty_block.png",
                  //           height: 300,
                  //         ),
                  //       ],
                  //     ),
                  //   );
                }),
              ),
            ],
          )),
    );
  }

  Widget profileWidget(BlockUserList data, index) {
    return Column(
      children: [
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  height: 45,
                  width: 45,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(50)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: CustomCachedNetworkImage(
                      imageUrl: data
                          .conversation!.blockedUserDetails![0].profileImage!,
                      placeholderColor: chatownColor,
                      errorWidgeticon: const Icon(Icons.person),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        capitalizeFirstLetter(data.conversation!
                                .blockedUserDetails![0].firstName! +
                            data.conversation!.blockedUserDetails![0]
                                .lastName!),
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 14)),
                    Text(
                      data.conversation!.blockedUserDetails![0].phoneNumber!,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                          color: Colors.grey),
                    ),
                  ],
                )
              ],
            ),
            InkWell(
              onTap: () {
                chatListController.blockUserApi(data.conversationId);
                allBlockListController.allBlock.remove(data);
              },
              child: Container(
                height: 28,
                width: 80,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: chatStrokeColor,
                    border: Border.all(color: chatownColor)),
                child: const Center(
                  child: Text(
                    "Unblock",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 5),
        if (index !=
            allBlockListController.blockListModel.value!.blockUserList!.length -
                1)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Divider(
              color: Colors.grey.shade200,
            ),
          )
      ],
    );
  }
}
