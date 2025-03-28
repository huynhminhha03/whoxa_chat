// ignore_for_file: library_private_types_in_public_api, unnecessary_null_comparison, prefer_is_empty, must_be_immutable, deprecated_member_use, unused_field, avoid_print

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whoxachat/app.dart';
import 'package:whoxachat/controller/add_contact_controller.dart';
import 'package:whoxachat/model/userchatlist_model/userchatlist_model.dart';
import 'package:whoxachat/src/global/api_helper.dart';
import 'package:whoxachat/src/global/common_widget.dart';
import 'package:whoxachat/src/screens/Group/add_gp_member.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:whoxachat/src/global/strings.dart';
import 'package:whoxachat/src/screens/chat/single_chat.dart';
import 'package:whoxachat/src/screens/layout/add_friend.dart';
import 'package:http/http.dart' as http;

final ApiHelper apiHelper = ApiHelper();

class FlutterContactsExample2 extends StatefulWidget {
  bool isValue;
  FlutterContactsExample2({super.key, required this.isValue});

  @override
  _FlutterContactsExample2State createState() =>
      _FlutterContactsExample2State();
}

class _FlutterContactsExample2State extends State<FlutterContactsExample2> {
  List<Contact>? _contacts;
  List<Map<String, dynamic>> friends = [];
  TextEditingController controller = TextEditingController();
  String searchText = '';
  bool _isPermissionGranted = false;
  bool isLoading = false;
  int countFriendRequests = 0;

  @override
  void initState() {
    _checkContactPermission();
    apis();
    fetchFriendRequestsCount();
    log(Hive.box(userdata).get(userMobile), name: "USER-MOBILE");
    super.initState();
  }

  Future<void> fetchFriendRequestsCount() async {
    try {
      var uri = Uri.parse(apiHelper.countFriendRequests);
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
        },
      );

      print("📡 API Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            countFriendRequests = data['count'];
          });
        } else {
          log("⚠️ API trả về lỗi: ${data['message']}");
        }
      } else {
        log("❌ Lỗi HTTP: ${response.statusCode}");
      }
    } catch (error) {
      log("🚨 Lỗi khi gọi API: $error");
    }
  }

  Future<void> fetchFriendsData() async {
    setState(() => isLoading = true);
    friends = await fetchFriends();
    setState(() => isLoading = false);
  }

  /// 🔄 **Hàm Refresh**
  Future<void> refreshFriends() async {
    await fetchFriendsData(); // Gọi lại API
  }

  // Check if the contact permission is granted
  Future<void> _checkContactPermission() async {
    PermissionStatus status = await Permission.contacts.status;

    setState(() {
      _isPermissionGranted = status.isGranted;
    });
  }

  Future<void> apis() async {
    log("MY_DEVICE_CONTACS: ${addContactController.mobileContacts}");

    chatListController.forChatList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColorWhite,
      appBar: AppBar(
        backgroundColor: appColorWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Image.network(
          languageController.appSettingsData[0].appLogo!,
          height: 45,
        ),
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: appColorWhite,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: commonSearchField(
                        context: context,
                        controller: controller,
                        onChanged: (value) {
                          setState(() {
                            searchText = value.toLowerCase().trim();
                          });
                        },
                        hintText: languageController
                            .textTranslate('Search name or number'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              InkWell(
                onTap: () {
                  Get.to(() =>
                      AddMembersinGroup1()); // Điều hướng sang màn hình "New Group"
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 17, right: 17),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween, // Chia khoảng cách đều
                    children: [
                      // New Group (Nhấn vào sẽ mở màn hình tạo nhóm)
                      InkWell(
                        onTap: () {
                          Get.to(() =>
                              AddMembersinGroup1()); // Điều hướng sang màn hình "New Group"
                        },
                        child: Row(
                          children: [
                            Container(
                              height: 45,
                              width: 45,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                shape: BoxShape.circle,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Center(
                                  child: Image.asset(
                                    "assets/images/group1.png",
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              languageController.textTranslate('New Group'),
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),

                      InkWell(
                        onTap: () {
                          Get.to(() => AddFriendScreen())?.then((_) {
                            fetchFriendsData();
                            fetchFriendRequestsCount(); // Fetch lại danh sách bạn bè khi quay lại
                          });
                        },
                        child: Row(
                          children: [
                            Stack(
                              clipBehavior:
                                  Clip.none, // Để không bị cắt phần số lượng
                              children: [
                                Icon(Icons.person_add, color: chatColor),
                                if (countFriendRequests > 0)
                                  Positioned(
                                    right: -2, // Dịch ra ngoài một chút cho đẹp
                                    top: -2,
                                    child: Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment
                                          .center, // Căn giữa số lượng trong hình tròn
                                      child: Text(
                                        "$countFriendRequests",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 5),
                            Text(
                              languageController.textTranslate('Add Friend'),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Divider(
                thickness: 1.5,
                color: Colors.grey.shade200,
              ),
              Expanded(
                child: RefreshIndicator(
                  color: chatownColor,
                  onRefresh: refreshFriends, // Gọi lại API khi kéo xuống

                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        controller.text.trim().isEmpty
                            ? contactDesign()
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget contactDesign() {
    return FutureBuilder(
      future: fetchFriends(), // Gọi API lấy danh sách bạn bè
      builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator()); // Hiển thị vòng tròn tải
        }

        if (snapshot.hasError) {
          return Center(child: Text("Lỗi khi tải danh sách bạn bè."));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              "Bạn chưa có bạn bè nào.",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          );
        }

        List<Map<String, dynamic>> friends = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 10),
              child: Text(
                languageController.textTranslate('List Friends'),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              physics: BouncingScrollPhysics(),
              shrinkWrap: true,
              itemCount: friends.length,
              itemBuilder: (context, index) {
                var friend = friends[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: friend['profile_image'] != null
                        ? NetworkImage(friend['profile_image'])
                        : null,
                    child: friend['profile_image'] == null
                        ? Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  title: Text("${friend['first_name']} ${friend['last_name']}"),
                  subtitle: Text(friend['phone_number']),
                  trailing: IconButton(
                    icon: Icon(Icons.message, color: chatColor, size: 24),
                    onPressed: () {
                      openOrCreateChat(friend);
                    },
                  ),
                  onTap: () {
                    openOrCreateChat(friend);
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  /// 🛠 **Hàm mở hoặc tạo cuộc trò chuyện**
  void openOrCreateChat(Map<String, dynamic> friend) {
    var chatList = chatListController.userChatListModel.value?.chatList ?? [];

    // Kiểm tra xem đã có cuộc trò chuyện với bạn này chưa
    ChatList? existingChat = chatList.firstWhere(
      (chat) => chat?.userId?.toString() == friend['user_id'].toString(),
      orElse: () => ChatList(),
    );

    if (existingChat != null) {
      // Nếu đã có, mở lại cuộc trò chuyện
      Get.to(() => SingleChatMsg(
            conversationID: existingChat.conversationId?.toString() ?? '',
            username: "${friend['first_name']} ${friend['last_name']}",
            userPic: friend['profile_image'] ?? 'default_image_url',
            mobileNum: friend['phone_number'],
            index: 0,
            isBlock: existingChat.isBlock,
            userID: friend['user_id'].toString(),
          ));
    } else {
      // Nếu chưa có, tạo cuộc trò chuyện mới
      Get.to(() => SingleChatMsg(
            conversationID: '', // Để server tự tạo ID mới
            username: "${friend['first_name']} ${friend['last_name']}",
            userPic: friend['profile_image'] ?? 'default_image_url',
            mobileNum: friend['phone_number'],
            index: 0,
            userID: friend['user_id'].toString(),
          ));
    }
  }

  Future<List<Map<String, dynamic>>> fetchFriends() async {
    try {
      var uri = Uri.parse(apiHelper.friendList);

      final response = await http.post(
         uri,// API lấy danh sách bạn bè
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
        },
        body: jsonEncode({}), // Không cần tham số
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['friends']);
        }
      }
      return [];
    } catch (error) {
      print("Lỗi khi lấy danh sách bạn bè: $error");
      return [];
    }
  }
}
