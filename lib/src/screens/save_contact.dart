// ignore_for_file: must_be_immutable

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:meyaoo_new/src/global/global.dart';

class SaveContact extends StatefulWidget {
  String name;
  String number;
  SaveContact({super.key, required this.name, required this.number});

  @override
  State<SaveContact> createState() => _SaveContactState();
}

class _SaveContactState extends State<SaveContact> {
  Future<void> saveContactInBackground(Map<String, String> contactData) async {
    final contact = Contact()
      ..name.first = contactData['name']!
      ..phones = [Phone(contactData['number']!)];

    await contact.insert();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        shape: Border(bottom: BorderSide(color: Colors.grey.shade400)),
        titleSpacing: -10,
        leadingWidth: 50,
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          child: const Icon(Icons.arrow_back_ios, size: 18),
        ),
        title: const Text(
          "View Contact",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.grey.shade200),
                    child: const Icon(Icons.person),
                  ),
                  const SizedBox(width: 20),
                  SelectableText(
                    widget.name,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w500),
                  )
                ],
              ),
              containerWidget(
                  onTap: () async {
                    print("@@@@@@@@@@@@@@@@@@@@@");
                    // Request permission to access contacts
                    if (await FlutterContacts.requestPermission()) {
                      final contactData = {
                        'name': widget.name,
                        'number': widget.number,
                      };

                      await compute(saveContactInBackground, contactData);
                    }
                  },
                  title: "Add")
            ],
          ).paddingSymmetric(horizontal: 20),
          Row(
            children: [
              Image.asset("assets/images/call_1.png",
                  height: 18, width: 18, color: Colors.grey.shade500),
              const SizedBox(width: 5),
              SelectableText(
                widget.number,
                style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 15,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ).paddingOnly(left: 90)
        ],
      ),
    );
  }
}
