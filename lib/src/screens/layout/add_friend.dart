import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:whoxachat/app.dart';
import 'package:whoxachat/src/global/api_helper.dart';
import 'package:whoxachat/src/global/common_widget.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:whoxachat/src/global/strings.dart';

final ApiHelper apiHelper = ApiHelper();

class AddFriendScreen extends StatefulWidget {
  @override
  _AddFriendScreenState createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  TextEditingController controller = TextEditingController();
  String searchText = '';
  Map<String, dynamic>? friendData;
  bool isLoading = false;
  List<dynamic> friendRequests = [];

  @override
  void initState() {
    super.initState();
    getFriendRequests(); // Lấy danh sách yêu cầu khi màn hình khởi động
  }

  Future<void> getFriendRequests() async {
    try {
      var uri = Uri.parse(apiHelper.getFriendRequests);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          friendRequests = data['requests'];
        });
      } else {
        print("Lỗi khi lấy danh sách yêu cầu kết bạn: ${response.body}");
      }
    } catch (e) {
      print("Lỗi khi lấy danh sách yêu cầu kết bạn: $e");
    }
  }

  /// 🔍 **Kiểm tra trạng thái bạn bè**
  Future<void> checkAddFriend() async {
    if (searchText.isEmpty) return;

    setState(() {
      isLoading = true;
      friendData = null;
    });

    try {
      var uri = Uri.parse(apiHelper.checkAddFriend);

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
        },
        body: jsonEncode({'phone_number': searchText}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          friendData = data;
        });
      } else {
        setState(() {
          friendData = null;
        });
      }
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      setState(() {
        friendData = null;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> respondFriendRequest(String friendId, String action) async {
    try {
      var uri = Uri.parse(apiHelper.respondFriendRequest);

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
        },
        body: jsonEncode({'friend_id': friendId, 'action': action}),
      );

      if (response.statusCode == 200) {
        Get.snackbar("Thành công",
            action == "accept" ? "Đã chấp nhận kết bạn" : "Đã từ chối lời mời",
            backgroundColor: Colors.green, colorText: Colors.white);
        getFriendRequests(); // Refresh danh sách sau khi xử lý
      } else {
        Get.snackbar("Lỗi", "Không thể xử lý yêu cầu",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      print("Lỗi khi xử lý yêu cầu kết bạn: $e");
    }
  }

  /// 📤 **Gửi yêu cầu kết bạn**
  Future<void> sendFriendRequest(String userId) async {
    try {
      var uri = Uri.parse(apiHelper.addFriend);

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}'
        },
        body: jsonEncode({'phone_number': searchText}),
      );

      if (response.statusCode == 200) {
        Get.snackbar("Thành công", "Yêu cầu kết bạn đã được gửi!",
            backgroundColor: Colors.green, colorText: Colors.white);
        checkAddFriend(); // Cập nhật lại trạng thái
      } else {
        Get.snackbar("Lỗi", "Không thể gửi yêu cầu kết bạn!",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      print("Lỗi khi gửi yêu cầu kết bạn: $e");
    }
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
        title: Text(
          languageController.textTranslate('Add Friend'),
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ô tìm kiếm
              Container(
                color: appColorWhite,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                child: commonSearchField(
                  context: context,
                  controller: controller,
                  onChanged: (value) {
                    setState(() {
                      searchText = value.toLowerCase().trim();
                    });
                    if (value.isNotEmpty) {
                      checkAddFriend();
                    }
                  },
                  hintText:
                      languageController.textTranslate('Search name or number'),
                ),
              ),

              const SizedBox(height: 15),

              // Kết quả tìm kiếm
              friendData == null
                  ? SizedBox()
                  : Expanded(
                      child: isLoading
                          ? Center(child: CircularProgressIndicator())
                          : friendResultWidget(),
                    ),
              friendRequests.isEmpty
                  ? Center(child: Text("Không có lời mời kết bạn"))
                  : Expanded(child: buildFriendRequestsList()),
            ],
          ),
        ],
      ),
    );
  }

  /// 📌 **Hiển thị thông tin bạn bè**
  Widget friendResultWidget() {
    if (friendData == null || friendData?['receiver_id'] == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Vui lòng nhập đúng số điện thoại để tìm kiếm.',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    int? status = friendData?['status'];
    String receiver_id = friendData?['receiver_id']?.toString() ?? '';
    String sender_id = friendData?['sender_id']?.toString() ?? '';

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.person, color: Colors.white),
      ),
      title: Text(friendData?['full_name'] ?? 'Không xác định'),
      subtitle: Text("ID: $receiver_id"),
      trailing: getFriendStatusWidget(status, receiver_id, sender_id),
    );
  }

  /// 🏷 **Hiển thị trạng thái bạn bè**
  Widget getFriendStatusWidget(
      int? status, String receiver_id, String sender_id) {
    if (receiver_id == sender_id) {
      return SizedBox(); // Không hiển thị gì nếu là chính mình
    }

    if (status == 1) {
      return Text(
        "Đã là bạn bè",
        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
      );
    } else if (status == 0) {
      return Text(
        "Đang chờ xác nhận",
        style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
      );
    } else if (status == 2) {
      return Text(
        "Lời mời bị từ chối",
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      );
    } else {
      return ElevatedButton(
        onPressed: () {
          if (userId.isNotEmpty) {
            sendFriendRequest(userId);
          }
        },
        child: Text("Kết bạn"),
      );
    }
  }

  Widget buildFriendRequestsList() {
    return ListView.builder(
      itemCount: friendRequests.length,
      itemBuilder: (context, index) {
        var friend = friendRequests[index];
        return Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hiển thị Avatar + Tên
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: chatColor,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        friend['full_name'] ?? 'Không xác định',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "ID: ${friend['user_id']}",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 10),

              // Nút Chấp nhận & Từ chối
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        respondFriendRequest(
                            friend['user_id'].toString(), "accept");
                      },
                      style:
                          ElevatedButton.styleFrom(backgroundColor: chatColor),
                      child: Text("Chấp nhận",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        respondFriendRequest(
                            friend['user_id'].toString(), "reject");
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: colorB0B0B0),
                      child: Text("Từ chối",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
