import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whoxachat/src/global/common_widget.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:whoxachat/src/global/strings.dart';
import 'package:whoxachat/app.dart';

class AddFriendScreen extends StatefulWidget {
  @override
  _AddFriendScreenState createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  TextEditingController controller = TextEditingController();
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColorWhite, // Giữ màu nền giống màn hình khác
      appBar: AppBar(
        backgroundColor: appColorWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          languageController.textTranslate('Add Friend'), // Tiêu đề đa ngôn ngữ
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Get.back(); // Quay lại màn hình trước
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
                  },
                  hintText:
                      languageController.textTranslate('Search name or number'),
                ),
              ),

              const SizedBox(height: 15),

              // Danh sách bạn bè sẽ hiển thị tại đây
              Expanded(
                child: Center(
                  child: Text(
                    'Danh sách bạn bè sẽ hiển thị tại đây',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
