// ignore_for_file: must_be_immutable, unnecessary_null_comparison, unused_local_variable, unused_field, non_constant_identifier_names

import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whoxachat/app.dart';
import 'package:whoxachat/controller/single_chat_controller.dart';
import 'package:whoxachat/src/global/common_widget.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../../../controller/get_contact_controller.dart';

class ContactSend extends StatefulWidget {
  String conversationID;
  String mobileNum;
  bool SelectedreplyText;
  String replyID;
  ContactSend(
      {super.key,
      required this.conversationID,
      required this.mobileNum,
      required this.SelectedreplyText,
      required this.replyID});

  @override
  State<ContactSend> createState() => _ContactSendState();
}

class _ContactSendState extends State<ContactSend> {
  List<Contact>? _contacts;
  bool _permissionDenied = false;
  TextEditingController controller = TextEditingController();
  GetAllDeviceContact getAllDeviceContact = Get.put(GetAllDeviceContact());
  SingleChatContorller chatContorller = Get.put(SingleChatContorller());
  List<Contact> filteredContacts = [];
  String searchText = '';
  Contact? selectedContact;

  @override
  void initState() {
    apis();
    super.initState();
  }

  Future<void> apis() async {
    await _fetchContacts();

    log("MY_DEVICE_CONTACS: ${addContactController.mobileContacts}");
    var contactJson = json.encode(addContactController.mobileContacts);
    getAllDeviceContact.getAllContactApi(contact: contactJson);
  }

  Future _fetchContacts() async {
    // Step 1: Check permission

    bool permissionGranted = await FlutterContacts.requestPermission(
      readonly: true,
    );

    debugPrint("_permissionDenied 1 $permissionGranted");

    if (!permissionGranted) {
      setState(() {
        _permissionDenied = true;
      });
      debugPrint("_permissionDenied $_permissionDenied");
      return; // If permission is denied, don't proceed further
    }
    // }

    try {
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );

      // Log the number of contacts fetched
      debugPrint("Fetched ${contacts.length} contacts.");

      // Optional: Log contact names or other properties to verify the fetched data
      for (var contact in contacts) {
        debugPrint("Contact name: ${contact.displayName}");
      }

      setState(() {
        _contacts = contacts;
        filteredContacts = contacts;
      });
    } catch (e) {
      debugPrint("Error fetching contacts: $e");
      setState(() {
        _permissionDenied = true;
      });
    }
  }

  // Future _fetchContacts() async {
  //   if (!await FlutterContacts.requestPermission(
  //     readonly: true,
  //   )) {
  //     setState(() => _permissionDenied = true);
  //   } else {
  //     final contacts = await FlutterContacts.getContacts(
  //         withProperties: true, withPhoto: true);
  //     setState(() {
  //       _contacts = contacts;
  //       filteredContacts = contacts;
  //     });
  //   }
  // }

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
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: appColorWhite,
        titleSpacing: 0,
        leadingWidth: 50,
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          child:
              const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black),
        ),
        title: Text(
          languageController.textTranslate('Send to'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          InkWell(
            onTap: () {
              if (widget.SelectedreplyText == true) {
                String mobileNum = getMobile(
                    selectedContact!.phones.map((e) => e.number).toString());
                int matchingIndex = isMatchinginvite(mobileNum);
                String profileImage = matchingIndex != -1
                    ? getAllDeviceContact.getList[matchingIndex].profileImage!
                    : "";

                chatContorller.sendMessageContact(
                    widget.conversationID,
                    "contact",
                    selectedContact!.displayName,
                    getMobile(selectedContact!.phones
                        .map((e) => e.number)
                        .toString()),
                    widget.mobileNum,
                    profileImage,
                    '',
                    widget.replyID);
                widget.SelectedreplyText = false;
              } else {
                String mobileNum = getMobile(
                    selectedContact!.phones.map((e) => e.number).toString());
                int matchingIndex = isMatchinginvite(mobileNum);
                String profileImage = matchingIndex != -1
                    ? getAllDeviceContact.getList[matchingIndex].profileImage!
                    : "";

                chatContorller.sendMessageContact(
                    widget.conversationID,
                    "contact",
                    selectedContact!.displayName,
                    getMobile(selectedContact!.phones
                        .map((e) => e.number)
                        .toString()),
                    widget.mobileNum,
                    profileImage,
                    '',
                    '');
              }
            },
            child: Container(
              height: 30,
              width: 63,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  color: secondaryColor),
              child: Center(
                  child: Text(
                languageController.textTranslate('Next'),
                style: const TextStyle(fontSize: 12),
              )),
            ).paddingOnly(right: 20),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: commonSearchField(
                  context: context,
                  controller: controller,
                  onChanged: (value) {
                    setState(() {
                      searchText = value.toLowerCase().trim();
                    });
                  },
                  hintText:
                      languageController.textTranslate('Search name or number'),
                ),
                // Container(
                //   height: 50,
                //   width: MediaQuery.of(context).size.width * 0.9,
                //   decoration: BoxDecoration(
                //       color: const Color(0xffFFFFFF),
                //       borderRadius: BorderRadius.circular(10)),
                //   child: TextField(
                //     controller: controller,
                //     onChanged: (value) {
                //       setState(() {
                //         searchText = value.toLowerCase().trim();
                //       });
                //     },
                //     decoration: InputDecoration(
                //       prefixIcon: const Padding(
                //         padding: EdgeInsets.all(17),
                //         child: Image(
                //           image: AssetImage('assets/icons/search.png'),
                //         ),
                //       ),
                //       hintText: languageController
                //           .textTranslate('Search name or number'),
                //       hintStyle:
                //           const TextStyle(fontSize: 12, color: Colors.grey),
                //       filled: true,
                //       fillColor: Colors.grey.shade100,
                //       border: const OutlineInputBorder(
                //         borderSide: BorderSide.none,
                //       ),
                //     ),
                //   ),
                // ),
              ),
            ),
          ),
          const Text(
            "Frequently Contacted",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ).paddingSymmetric(horizontal: 20, vertical: 5),
          Expanded(
              child: SingleChildScrollView(
            child: inviteFriend(searchText),
          ))
        ],
      ),
    );
  }

  int isMatchinginvite(String userNumber) {
    for (int i = 0; i < getAllDeviceContact.getList.length; i++) {
      if (userNumber == getAllDeviceContact.getList[i].phoneNumber) {
        return i;
      }
    }
    return -1;
  }

  List<Contact> getFilteredContacts(String searchText) {
    List<Contact> filteredContacts = [];
    for (int i = 0; i < addContactController.allcontacts.length; i++) {
      Contact contact = addContactController.allcontacts[i];
      if ((contact.displayName.toLowerCase().contains(searchText))) {
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

        int matchingIndex = isMatchinginvite(
            getMobile(contact.phones.map((e) => e.number).toString()));

        return Column(
          children: <Widget>[
            Row(
              children: [
                Expanded(
                  child: ListTile(
                      onTap: () {
                        setState(() {
                          selectedContact = contact;
                        });
                      },
                      leading: Stack(
                        children: <Widget>[
                          Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              shape: BoxShape.circle,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: matchingIndex != -1
                                  ? CustomCachedNetworkImage(
                                      imageUrl: getAllDeviceContact
                                          .getList[matchingIndex].profileImage!,
                                      placeholderColor: chatownColor,
                                      errorWidgeticon: const Icon(
                                        Icons.person,
                                        size: 30,
                                      ))
                                  : (Center(
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
                          ),
                        ],
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
                      trailing: selectedContact == contact
                          ? Container(
                              height: 20,
                              width: 20,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22),
                                  color: chatownColor),
                              child: const Center(
                                child: Icon(Icons.check, size: 13),
                              ),
                            )
                          : Container(
                              height: 20,
                              width: 20,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22),
                                  color: Colors.white,
                                  border: Border.all(color: chatownColor)),
                            )),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
