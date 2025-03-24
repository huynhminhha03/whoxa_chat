class MyStorySeenListData {
  bool? success;
  String? message;
  List<StatusViewsList>? statusViewsList;

  MyStorySeenListData({this.success, this.message, this.statusViewsList});

  MyStorySeenListData.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['statusViewsList'] != null) {
      statusViewsList = <StatusViewsList>[];
      json['statusViewsList'].forEach((v) {
        statusViewsList!.add(StatusViewsList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (statusViewsList != null) {
      data['statusViewsList'] =
          statusViewsList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class StatusViewsList {
  String? createdAt;
  int? statusCount;
  User? user;

  StatusViewsList({this.createdAt, this.user});

  StatusViewsList.fromJson(Map<String, dynamic> json) {
    createdAt = json['createdAt'];
    statusCount = json['status_count'];
    user = json['User'] != null ? User.fromJson(json['User']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['createdAt'] = createdAt;
    data['status_count'] = statusCount;
    if (user != null) {
      data['User'] = user!.toJson();
    }
    return data;
  }
}

class User {
  String? profileImage;
  int? userId;
  String? firstName;
  String? lastName;
  String? phoneNumber;
  String? userName;

  User(
      {this.profileImage,
      this.userId,
      this.firstName,
      this.lastName,
      this.phoneNumber,
      this.userName});

  User.fromJson(Map<String, dynamic> json) {
    profileImage = json['profile_image'];
    userId = json['user_id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    phoneNumber = json['phone_number'];
    userName = json['user_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['profile_image'] = profileImage;
    data['user_id'] = userId;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['phone_number'] = phoneNumber;
    data['user_name'] = userName;
    return data;
  }
}
