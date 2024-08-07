// ignore_for_file: prefer_is_empty, unnecessary_null_comparison, deprecated_member_use, curly_braces_in_flow_control_structures, avoid_function_literals_in_foreach_calls, unused_element
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:meyaoo_new/controller/add_contact_controller.dart';
import 'package:meyaoo_new/controller/get_contact_controller.dart';
import 'package:meyaoo_new/controller/user_chatlist_controller.dart';
import 'package:meyaoo_new/src/global/global.dart';
import 'package:meyaoo_new/src/global/strings.dart';
import 'package:meyaoo_new/src/screens/chat/create_group.dart';
import 'package:url_launcher/url_launcher.dart';

class InviteFriend extends StatefulWidget {
  const InviteFriend({super.key});

  @override
  State<InviteFriend> createState() => _InviteFriendState();
}

class _InviteFriendState extends State<InviteFriend> {
  List<Contact>? _contacts;
  TextEditingController controller = TextEditingController();
  String searchText = '';
  GetAllDeviceContact getAllDeviceContact = Get.find();
  AddContactController addContactController = Get.put(AddContactController());
  ChatListController chatListController = Get.find();
  List<Contact> filteredContacts = [];

  @override
  void initState() {
    apis();
    super.initState();
  }

  Future<void> apis() async {
    await _fetchContacts();
    await getContactsFromGloble();
    log("MY_DEVICE_CONTACS: $mobileContacts");
    var contactJson = json.encode(mobileContacts);
    getAllDeviceContact.getAllContactApi(contact: contactJson);
    chatListController.forChatList();
  }

  Future _fetchContacts() async {
    if (!await FlutterContacts.requestPermission(readonly: true)) {
    } else {
      final contacts = await FlutterContacts.getContacts(
          withProperties: true, withPhoto: true);
      setState(() {
        _contacts = contacts;
        filteredContacts =
            contacts; // Initially set filteredContacts to all contacts
      });
    }
  }

  void filterContacts(String query) {
    if (_contacts != null) {
      setState(() {
        filteredContacts = _contacts!
            .where((contact) =>
                contact.displayName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: chatownColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          leading: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child:
                  const Icon(Icons.arrow_back_ios, color: chatColor, size: 20)),
          centerTitle: true,
          title: const Text(
            'Tell a friend',
            style: TextStyle(
                fontWeight: FontWeight.w500, fontSize: 20, color: Colors.black),
          )),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //To of search bar
              Container(
                color: chatownColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width * 0.9,
                        decoration: BoxDecoration(
                            color: const Color(0xffFFFFFF),
                            borderRadius: BorderRadius.circular(7)),
                        child: TextField(
                          controller: controller,
                          onChanged: (value) {
                            setState(() {
                              searchText = value.toLowerCase().trim();
                            });
                          },
                          decoration: const InputDecoration(
                            suffixIcon: Padding(
                              padding: EdgeInsets.all(17),
                              child: Image(
                                image: AssetImage('assets/icons/search.png'),
                              ),
                            ),
                            hintText: '  What are you looking for?',
                            hintStyle:
                                TextStyle(fontSize: 12, color: Colors.grey),
                            filled: true,
                            fillColor: Colors.transparent,
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Obx(() {
                    return Column(
                      children: [inviteFriend(searchText)],
                    );
                  }),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  bool isMatchinginvite(String userNumber) {
    for (int i = 0; i < getAllDeviceContact.getList.length; i++) {
      List<String> numbers = userNumber.split(',');
      for (String listNumber in numbers) {
        if (listNumber == getAllDeviceContact.getList[i].phoneNumber) {
          return false;
        }
      }
    }
    return true;
  }

  List<Contact> getFilteredContacts(String searchText) {
    List<Contact> filteredContacts = [];
    for (int i = 0; i < allcontacts.length; i++) {
      Contact contact = allcontacts[i];
      if (isMatchinginvite(
              getMobile(contact.phones.map((e) => e.number).toString())) &&
          (contact.displayName?.toLowerCase().contains(searchText) ??
              false ||
                  contact.phones
                      .any((phone) => phone.number.contains(searchText)))) {
        filteredContacts.add(contact);
      }
    }
    return filteredContacts;
  }

  Widget inviteFriend(String searchText) {
    List<Contact> filteredContacts = getFilteredContacts(searchText);
    return ListView.builder(
      padding: const EdgeInsets.all(0),
      itemCount: filteredContacts.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        var contact = filteredContacts[index];
        Uint8List? image = contact.photo;
        return Column(
          children: <Widget>[
            getMobile(Hive.box(userdata).get(userMobile)) ==
                    getMobile(contact.phones.map((e) => e.number).toString())
                ? const SizedBox.shrink()
                : ListTile(
                    onTap: () {
                      inviteMe(contact.phones.map((e) => e.number).toString());
                    },
                    leading: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: contact.photo != null
                              ? Image.memory(
                                  image!,
                                  fit: BoxFit.cover,
                                  width: 50,
                                  height: 50,
                                )
                              : Center(
                                  child: Text(
                                    contact.displayName != null
                                        ? contact.displayName[0]
                                        : "?",
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontFamily: "MontserratBold",
                                        fontWeight: FontWeight.bold),
                                  ),
                                )),
                    ),
                    title: Text(
                      contact.displayName,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Container(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          getMobile(
                              contact.phones.map((e) => e.number).toString()),
                          maxLines: 1,
                        )),
                    trailing: const Text(
                      "Invite  ",
                      style: TextStyle(fontSize: 14, color: Colors.blue),
                    ),
                  ),
          ],
        );
      },
    );
  }

  inviteMe(phone) async {
    // Android
    String uri =
        'sms:$phone?body=${"‎Hey there! Join me on our Chat app!\nChat with friends, share photos & videos instantly.\nDownload now.\nLet's stay connected!"}';
    if (await canLaunch(uri)) {
      await launch(uri);
    } else {
      // iOS
      String uri =
          'sms:$phone?body=${"‎Hey there! Join me on our Chat app!\nChat with friends, share photos & videos instantly.\nDownload now.\nLet's stay connected!"}';
      if (await canLaunch(uri)) {
        await launch(uri);
      } else {
        throw 'Could not launch $uri';
      }
    }
  }

  Widget contactDesign() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        InkWell(
          onTap: () {
            images();
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 17),
            child: Row(
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
                      child: const Center(child: Icon(Icons.groups_2))),
                ),
                const SizedBox(width: 10),
                const Text(
                  "New Group",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Divider(
          thickness: 1.5,
          color: Colors.grey.shade300,
        ),
        const SizedBox(height: 15),
        const Padding(
          padding: EdgeInsets.only(left: 20),
          child: Text(
            "CONTACTS",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 12),
        Divider(
          thickness: 1.5,
          color: Colors.grey.shade300,
        ),
      ],
    );
  }

  Future images() {
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
            title: Center(
              child: Text(
                capitalizeFirstLetter('Group Info'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: chatColor,
                ),
              ),
            ),
            content: const SizedBox(height: 243, child: create_group()),
          );
        });
      },
    );
  }
}
