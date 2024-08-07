// ignore_for_file: avoid_print, use_build_context_synchronously, must_be_immutable, camel_case_types, non_constant_identifier_names, unnecessary_null_comparison
import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meyaoo_new/controller/group_create_controller.dart';
import 'package:meyaoo_new/src/global/global.dart';

class group_profile extends StatefulWidget {
  String dp;
  String groupid;
  String name;
  group_profile(
      {super.key, required this.dp, required this.groupid, required this.name});

  @override
  State<group_profile> createState() => _group_profileState();
}

class _group_profileState extends State<group_profile> {
  GroupCreateController gpCreateController = Get.put(GroupCreateController());
  TextEditingController groupnameController = TextEditingController();
  File? image;
  final picker = ImagePicker();

  bool ActiveConnection = false;
  String T = "";

  @override
  void initState() {
    // log("groupid" + widget.groupid.toString());
    print("GROUP_ID: ${widget.groupid}");
    groupnameController.text = widget.name;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColorWhite,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: chatownColor,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child:
                Image.asset("assets/images/arrow-left.png", color: chatColor),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Group Profile',
          style: TextStyle(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 100,
                    ),
                    groupprofiledetails(),
                    const SizedBox(
                      height: 50,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 25, right: 25),
                      child: SizedBox(
                        height: 70,
                        width: MediaQuery.of(context).size.width,
                        child: TextFormField(
                            maxLength: 16,
                            // textAlign: TextAlign.center,
                            // textAlignVertical: TextAlignVertical.s,
                            controller: groupnameController,
                            readOnly: false,
                            autofocus: false,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade100,
                                  )),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade100,
                                  ),
                                  borderRadius: BorderRadius.circular(10)),
                              contentPadding: const EdgeInsets.only(
                                  top: 1, left: 15, bottom: 1),
                              // hintText: 'Add a brief description',
                              hintText: 'Group Name Change',
                              hintStyle: const TextStyle(
                                fontSize: 10,
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade100,

                              // ),
                            )),
                      ),
                    )
                  ]),
            ),
          ),
          doneWidget().paddingOnly(bottom: 30)
        ],
      ),
    );
  }

  Widget doneWidget() {
    return Obx(() {
      return gpCreateController.isCreate.value
          ? loader(context)
          : InkWell(
              onTap: () {
                print("UPDATE:");
                String? filePath = image?.path;
                gpCreateController.groupCreateUpate(
                    groupnameController.text.toString(),
                    filePath,
                    widget.groupid.toString());
              },
              child: Container(
                height: 48,
                width: MediaQuery.of(context).size.width * 0.87,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: chatownColor,
                ),
                child: const Center(
                  child: Text(
                    'Update',
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

  Widget groupprofiledetails() {
    return Stack(
      children: [
        InkWell(
          onTap: () {
            selectImageSource();
          },
          child: Container(
            height: 200,
            width: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(200),
              child: image == null
                  ? widget.dp != null
                      ? Image.network(
                          widget.dp,
                          fit: BoxFit.fill,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.network(
                            "https://static-00.iconduck.com/assets.00/person-icon-512x483-d7q8hqj4.png",
                            height: 20,
                          ).paddingAll(10),
                        )
                      : Obx(() {
                          return Image.network(
                            gpCreateController.createModel.value!
                                .conversationDetails!.groupProfileImage!,
                            height: 20,
                          ).paddingAll(10);
                        })
                  : Image.file(image!, fit: BoxFit.fill),
            ),
          ),
        ),
        Positioned(
          bottom: 7,
          right: 20,
          child: InkWell(
            onTap: () {
              selectImageSource();
            },
            child: Container(
              width: 35,
              height: 35,
              decoration: const BoxDecoration(
                color: chatownColor,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child:
                    Image.asset("assets/images/edit-2.png", color: chatColor),
              ),
            ),
          ),
        ),
      ],
    );
  }

  selectImageSource() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(8.0),
            ),
          ),
          content: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(height: 20.0),
                  Image.asset(
                    'assets/icons/upload_vec.png',
                    height: 100,
                    width: 100,
                  ),
                  Container(height: 15.0),
                  const Text(
                    "Upload Image",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Container(height: 15.0),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        getImageFromCamera();
                      },
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0))),
                      ),
                      child: const Text(
                        "Take Picture",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        getImageFromGallery();
                      },
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                      child: const Text(
                        "From Gallery",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  Container(height: 15.0),
                ],
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.topRight,
                  child: ClipOval(
                    child: Material(
                      elevation: 5,
                      color: chatownColor, // button color
                      child: InkWell(
                        splashColor: chatownColor, // inkwell color
                        child: const SizedBox(
                            width: 25,
                            height: 25,
                            child: Icon(
                              Icons.close,
                              size: 20,
                              color: Colors.black,
                            )),
                        onTap: () {
                          closeKeyboard();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future getImageFromCamera() async {
    // ignore: deprecated_member_use
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future getImageFromGallery() async {
    // ignore: deprecated_member_use
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }
}
