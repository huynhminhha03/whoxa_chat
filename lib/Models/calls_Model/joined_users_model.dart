class ConnectedUsersModel {
  List<ConnectedUsers>? connectedUsers;

  ConnectedUsersModel({this.connectedUsers});

  ConnectedUsersModel.fromJson(Map<String, dynamic> json) {
    connectedUsers = json["connectedUsers"] == null
        ? null
        : (json["connectedUsers"] as List)
            .map((e) => ConnectedUsers.fromJson(e))
            .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (connectedUsers != null) {
      data["connectedUsers"] = connectedUsers?.map((e) => e.toJson()).toList();
    }
    return data;
  }
}

class ConnectedUsers {
  String? profileImage;
  int? userId;
  String? userName;
  String? firstName;
  String? lastName;

  ConnectedUsers(
      {this.profileImage,
      this.userId,
      this.userName,
      this.firstName,
      this.lastName});

  ConnectedUsers.fromJson(Map<String, dynamic> json) {
    profileImage = json["profile_image"];
    userId = json["user_id"];
    userName = json["user_name"];
    firstName = json["first_name"];
    lastName = json["last_name"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["profile_image"] = profileImage;
    data["user_id"] = userId;
    data["user_name"] = userName;
    data["first_name"] = firstName;
    data["last_name"] = lastName;
    return data;
  }
}
