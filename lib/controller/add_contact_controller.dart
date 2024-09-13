import 'dart:convert';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:meyaoo_new/Models/add_contact_model.dart';
import 'package:meyaoo_new/controller/user_chatlist_controller.dart';
import 'package:meyaoo_new/src/global/api_helper.dart';
import 'package:http/http.dart' as http;
import 'package:meyaoo_new/src/global/global.dart';
import 'package:meyaoo_new/src/global/strings.dart';
import 'package:meyaoo_new/src/screens/chat/single_chat.dart';

final ApiHelper apiHelper = ApiHelper();
ChatListController chatListController = Get.find();

class AddContactController extends GetxController {
  RxBool isLoading = false.obs;
  Rx<AddContactModel?> model = AddContactModel().obs;
  RxBool isGetContectsFromDeviceLoading = false.obs;

  Future<void> addContactApi(fullName, mobileNum, profile) async {
    isLoading(true);

    var uri = Uri.parse(apiHelper.addContact);
    var request = http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
      "Accept": "application/json",
    };

    request.headers.addAll(headers);
    request.fields['full_name'] = fullName;
    request.fields['phone_number'] = mobileNum;

    var response = await request.send();
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);

    model.value = AddContactModel.fromJson(userData);

    if (model.value!.success == true) {
      isLoading(false);
      Get.to(() => SingleChatMsg(
            conversationID: '',
            username: fullName,
            userPic: profile,
            mobileNum: mobileNum,
            index: 0,
            userID: model.value!.userId.toString(),
          ));
    } else {
      isLoading(false);
      showCustomToast(model.value!.message!);
    }
  }

  //================================================================= GET ALL CONTACT =========================================================
  List<Map<String, String>> mobileContacts = [];
//var mobileContacts = [];
  List<Contact> allcontacts = [];

  Future getContactsFromGloble() async {
    isGetContectsFromDeviceLoading.value = true;

    var contacts = (await FlutterContacts.getContacts(
      withProperties: true,
      withPhoto: true,
    ))
        .toList();

    allcontacts = contacts.toList();

    // for (int i = 0; i < allcontacts.length; i++) {
    //   Contact c = allcontacts.elementAt(i);
    //   if (c.phones.isNotEmpty) {
    //     getContacts.add(c.phones.map((e) => getMobile(e.number)));
    //   }
    // }
    String cleanNumber(String number) {
      return getMobile(number);
    }

    for (Contact c in allcontacts) {
      if (c.phones.isNotEmpty) {
        // Get the cleaned phone numbers
        List<String> cleanedNumbers =
            c.phones.map((e) => cleanNumber(e.number)).toList();
        for (String number in cleanedNumbers) {
          // Add contact with display name and cleaned number
          mobileContacts.add({'name': c.displayName, 'number': number});
        }
      }
    }
    var contactJson = json.encode(addContactController.mobileContacts);
    await getAllDeviceContact.getAllContactApi(contact: contactJson);
    isGetContectsFromDeviceLoading.value = false;
  }
}
