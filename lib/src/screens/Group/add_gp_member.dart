// ignore_for_file: avoid_types_as_parameter_names, avoid_function_literals_in_foreach_calls, empty_catches, prefer_typing_uninitialized_variables, avoid_print, library_prefixes, must_be_immutable, file_names, unused_field

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meyaoo_new/controller/get_contact_controller.dart';
import 'package:meyaoo_new/controller/group_create_controller.dart';
import 'package:meyaoo_new/controller/user_chatlist_controller.dart';
import 'package:meyaoo_new/model/userchatlist_model/userchatlist_model.dart';
import 'package:meyaoo_new/src/global/global.dart';
import 'package:meyaoo_new/Models/get_contact_model.dart';
import 'package:meyaoo_new/src/screens/Group/create_gp.dart';

class AddMembersinGroup1 extends StatefulWidget {
  String? grpId;
  AddMembersinGroup1({super.key, this.grpId});

  @override
  State<AddMembersinGroup1> createState() => _AddMembersinGroup1State();
}

class _AddMembersinGroup1State extends State<AddMembersinGroup1> {
  GetAllDeviceContact getAllDeviceContact = Get.find();
  ChatListController chatListController = Get.find();
  GroupCreateController gpCreateController = Get.find();
  @override
  void initState() {
    var contactJson = json.encode(mobileContacts);
    getAllDeviceContact.getAllContactApi(contact: contactJson);

    super.initState();
  }

  List contactID = [];
  List<SelectedContact> contactData = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey.shade300)),
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leadingWidth: 50,
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          child: const Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
        title: const Text(
          'Add Participants',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        actions: [
          Padding(
              padding: const EdgeInsets.only(right: 15),
              child: containerWidget(
                  onTap: () async {
                    if (contactData.isNotEmpty) {
                      final result = await Get.to(() => MyWidget(
                          contactData: contactData, contactID: contactID));
                      setState(() {
                        contactData.length = result;
                      });
                    } else {
                      showCustomToast("Please select members");
                    }
                  },
                  title: "Next"))
        ],
      ),
      body: Column(children: [
        const SizedBox(height: 10),
        Container(
            width: MediaQuery.of(context).size.width * 0.90,
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(0.0),
                    topLeft: Radius.circular(0.0))),
            child: SizedBox(
              height: 45,
              width: MediaQuery.of(context).size.width * 0.9,
              child: TextField(
                  cursorColor: Colors.black,
                  // controller: aboutController,
                  readOnly: false,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 238, 238, 238),
                        )),
                    focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 238, 238, 238),
                        ),
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding:
                        const EdgeInsets.only(top: 1, left: 15, bottom: 1),
                    hintText: 'Search name or number',
                    hintStyle: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w400),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 238, 238, 238),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(13),
                      child: Image(
                        image: AssetImage('assets/icons/search.png'),
                      ),
                    ),

                    // ),
                  )),
            )),
        const SizedBox(height: 10),
        contactData.isEmpty ? const SizedBox.shrink() : selectedUsersList(),
        contactData.isEmpty
            ? const SizedBox.shrink()
            : Divider(color: Colors.grey.shade300),
        Expanded(
            child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 10, top: 20),
                child: Text(
                  "Frequently Contacted",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
              recentContactWidget(context),
              if (hasMatchingContacts()) // Check if there are matching contacts
                const Padding(
                  padding: EdgeInsets.only(
                      left: 10, top: 10), // Reduced top padding to 10
                  child: Text(
                    "Contacts on ChatWeb",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
              if (hasMatchingContacts()) listOfContactWidget(context),
            ],
          ),
        ))
      ]),
    );
  }

//======================================================== RECENT CHAT CONTACT ===========================================
//======================================================== RECENT CHAT CONTACT ===========================================
//======================================================== RECENT CHAT CONTACT ===========================================
  Container recentContactWidget(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            0, 0, 0, 10), // Reduced bottom padding to 10
        child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          itemCount:
              chatListController.userChatListModel.value!.chatList!.length,
          itemBuilder: (context, index) {
            return recentchatcard(
                chatListController.userChatListModel.value!.chatList![index],
                index);
          },
        ),
      ),
    );
  }

  Widget recentchatcard(ChatList data, index) {
    if (data.isGroup == false) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: InkWell(
          onTap: () {
            setState(() {
              contactID.contains(data.userId)
                  ? contactID.remove(data.userId)
                  : contactID.add(data.userId);
            });
            setState(() {
              // Create a contact object to be added or removed
              SelectedContact selectedContact = SelectedContact(
                userId: data.userId!,
                userName: data.userName!,
                profileImage: data.profileImage!,
              );

              // Check if the contact already exists in the list
              bool isSelect = contactData.contains(selectedContact);

              // Add or remove based on the existence
              isSelect
                  ? contactData.remove(selectedContact)
                  : contactData.add(selectedContact);
            });
            print("CONTACT_ID:$contactID");
            print("CONTACT-DATA:$contactData");
          },
          child: SizedBox(
            height: 85,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 0),
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.network(
                      data.profileImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.person),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.65,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 25),
                      Text(
                        capitalizeFirstLetter(data.userName!),
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        data.phoneNumber!,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 22,
                  width: 22,
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: contactID.contains(data.userId) ||
                                contactData.contains(SelectedContact(
                                    userId: data.userId!,
                                    userName: data.userName!,
                                    profileImage: data.profileImage!))
                            ? Colors.white
                            : chatownColor,
                      ),
                      shape: BoxShape.circle,
                      color: contactID.contains(data.userId) ||
                              contactData.contains(SelectedContact(
                                  userId: data.userId!,
                                  userName: data.userName!,
                                  profileImage: data.profileImage!))
                          ? chatownColor
                          : Colors.white),
                  child: Icon(Icons.check,
                      size: 15,
                      color: contactID.contains(data.userId) ||
                              contactData.contains(SelectedContact(
                                  userId: data.userId!,
                                  userName: data.userName!,
                                  profileImage: data.profileImage!))
                          ? Colors.black
                          : Colors.white),
                ),
                const SizedBox(width: 5),
              ],
            ),
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

//================================================================= CONTACT LIST =============================================
//================================================================= CONTACT LIST =============================================
//================================================================= CONTACT LIST =============================================
  bool isMatching(String userid) {
    for (var i = 0;
        i < chatListController.userChatListModel.value!.chatList!.length;
        i++) {
      if (chatListController.userChatListModel.value!.chatList![i].userId
              .toString() ==
          userid) {
        return false;
      }
    }
    return true;
  }

  bool hasMatchingContacts() {
    for (var contact in getAllDeviceContact.getList) {
      if (isMatching(contact.userId.toString())) {
        return true;
      }
    }
    return false;
  }

  Container listOfContactWidget(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
        child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          primary: false,
          padding: EdgeInsets.zero,
          itemCount: getAllDeviceContact.getList.length,
          itemBuilder: (BuildContext context, int index) {
            return chatcard(getAllDeviceContact.getList[index]).paddingZero;
          },
        ),
      ),
    );
  }

  Widget chatcard(NewContactList data) {
    if (isMatching(data.userId.toString())) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  contactID.contains(data.userId)
                      ? contactID.remove(data.userId)
                      : contactID.add(data.userId);
                });
                setState(() {
                  // Create a contact object to be added or removed
                  SelectedContact selectedContact = SelectedContact(
                    userId: data.userId!,
                    userName: data.userName!,
                    profileImage: data.profileImage!,
                  );

                  // Check if the contact already exists in the list
                  bool isSelect = contactData.contains(selectedContact);

                  // Add or remove based on the existence
                  isSelect
                      ? contactData.remove(selectedContact)
                      : contactData.add(selectedContact);
                });
              },
              child: SizedBox(
                height: 85,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 0),
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.network(
                          data.profileImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.person),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.65,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 25),
                          Text(
                            capitalizeFirstLetter(data.userName!),
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 16),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                data.phoneNumber!,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w400, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 22,
                      width: 22,
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: contactID.contains(data.userId) ||
                                    contactData.contains(SelectedContact(
                                        userId: data.userId!,
                                        userName: data.userName!,
                                        profileImage: data.profileImage!))
                                ? Colors.white
                                : chatownColor,
                          ),
                          shape: BoxShape.circle,
                          color: contactID.contains(data.userId) ||
                                  contactData.contains(SelectedContact(
                                      userId: data.userId!,
                                      userName: data.userName!,
                                      profileImage: data.profileImage!))
                              ? chatownColor
                              : Colors.white),
                      child: Icon(Icons.check,
                          size: 15,
                          color: contactID.contains(data.userId) ||
                                  contactData.contains(SelectedContact(
                                      userId: data.userId!,
                                      userName: data.userName!,
                                      profileImage: data.profileImage!))
                              ? Colors.black
                              : Colors.white),
                    ),
                    const SizedBox(width: 5),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget create() {
    return Obx(() {
      return gpCreateController.isMember.value
          ? loader(context)
          : InkWell(
              onTap: () {
                log(persons.length.toString());
                contactID.isNotEmpty
                    ? gpCreateController.addToGroupMember(
                        widget.grpId!, contactID)
                    : showCustomToast("Please select member");
              },
              child: Container(
                height: 50,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  // border: Border.all(color:  Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(25),
                  color: chatownColor,
                ),
                child: const Center(
                  child: Text(
                    'Create',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 16),
                  ),
                ),
              ),
            );
    });
  }

  Widget selectedUsersList() {
    return SizedBox(
        height: 75,
        child: Align(
          alignment: Alignment.centerLeft,
          child: ListView.builder(
            itemCount: contactData.length,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20),
            itemBuilder: (context, index) {
              return InkWell(
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                splashFactory: NoSplash.splashFactory,
                onTap: () {
                  setState(() {
                    contactData.removeAt(index);
                  });
                },
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image.network(
                              contactData[index].profileImage,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.person),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          contactData[index].userName,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w400),
                        )
                      ],
                    ),
                    Positioned(
                        top: 2,
                        right: 2,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              contactData.removeAt(index);
                            });
                          },
                          child: Container(
                            height: 12,
                            width: 12,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.black),
                                color: chatLogoColor),
                            child: const Center(
                              child: Icon(Icons.close,
                                  color: Colors.black, size: 7),
                            ),
                          ),
                        ))
                  ],
                ).paddingOnly(right: 20),
              );
            },
          ),
        ));
  }
}
