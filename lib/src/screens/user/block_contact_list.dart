// ignore_for_file: avoid_print, unused_field
import 'package:flutter/material.dart';
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
    return Scaffold(
        backgroundColor: appColorWhite,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: chatownColor,
          centerTitle: true,
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child:
                const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black),
          ),
          title: const Text(
            "Block list",
            style: TextStyle(fontSize: 18, color: Colors.black),
          ),
        ),
        body: Obx(() {
          return allBlockListController.isLoading.value &&
                  allBlockListController.allBlock.isEmpty
              ? loader(context)
              : allBlockListController.allBlock.isNotEmpty
                  ? SingleChildScrollView(
                      child: Padding(
                      padding:
                          const EdgeInsets.only(left: 20, top: 20, right: 20),
                      child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: allBlockListController.allBlock.length,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            if (allBlockListController.allBlock[index]
                                .conversation!.blockedUserDetails!.isNotEmpty) {
                              return profileWidget(
                                  allBlockListController.allBlock[index],
                                  index);
                            } else {
                              return const SizedBox.shrink();
                            }
                          }),
                    ))
                  : Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 100),
                          Image.asset(
                            "assets/images/no_chat_list.png",
                            height: 300,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 1,
                            decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10)),
                            child: const Padding(
                              padding: EdgeInsets.all(15.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "You don't have any block list.",
                                    softWrap: true,
                                    maxLines: 2,
                                    style: TextStyle(
                                        color: chatColor,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w300),
                                  ),
                                ],
                              ),
                            ),
                          ).paddingSymmetric(horizontal: 30),
                        ],
                      ),
                    );
        }));
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
                  height: 40,
                  width: 40,
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
                        style: const TextStyle(fontWeight: FontWeight.w500)),
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
                height: 25,
                width: 60,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: chatStrokeColor,
                    border: Border.all(color: chatownColor)),
                child: const Center(
                  child: Text(
                    "Unblock",
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w500),
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
