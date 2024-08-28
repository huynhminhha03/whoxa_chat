class CallHistoryModel {
  List<CallList>? callList;
  bool? success;

  CallHistoryModel({this.callList, this.success});

  CallHistoryModel.fromJson(Map<String, dynamic> json) {
    callList = json["callList"] == null
        ? null
        : (json["callList"] as List).map((e) => CallList.fromJson(e)).toList();
    success = json["success"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (callList != null) {
      data["callList"] = callList?.map((e) => e.toJson()).toList();
    }
    data["success"] = success;
    return data;
  }
}

class CallList {
  int? callId;
  int? messageId;
  String? missedCall;
  String? callAccept;
  String? callType;
  String? callDecline;
  String? roomId;
  String? callTime;
  String? createdAt;
  String? updatedAt;
  int? conversationId;
  int? userId;
  Conversation? conversation;
  User? user;

  CallList(
      {this.callId,
      this.messageId,
      this.missedCall,
      this.callAccept,
      this.callType,
      this.callDecline,
      this.roomId,
      this.callTime,
      this.createdAt,
      this.updatedAt,
      this.conversationId,
      this.userId,
      this.conversation,
      this.user});

  CallList.fromJson(Map<String, dynamic> json) {
    callId = json["call_id"];
    messageId = json["message_id"];
    missedCall = json["missed_call"];
    callAccept = json["call_accept"];
    callType = json["call_type"];
    callDecline = json["call_decline"];
    roomId = json["room_id"];
    callTime = json["call_time"];
    createdAt = json["createdAt"];
    updatedAt = json["updatedAt"];
    conversationId = json["conversation_id"];
    userId = json["user_id"];
    conversation = json["Conversation"] == null
        ? null
        : Conversation.fromJson(json["Conversation"]);
    user = json["User"] == null ? null : User.fromJson(json["User"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["call_id"] = callId;
    data["message_id"] = messageId;
    data["missed_call"] = missedCall;
    data["call_accept"] = callAccept;
    data["call_type"] = callType;
    data["call_decline"] = callDecline;
    data["room_id"] = roomId;
    data["call_time"] = callTime;
    data["createdAt"] = createdAt;
    data["updatedAt"] = updatedAt;
    data["conversation_id"] = conversationId;
    data["user_id"] = userId;
    if (conversation != null) {
      data["Conversation"] = conversation?.toJson();
    }
    if (user != null) {
      data["User"] = user?.toJson();
    }
    return data;
  }
}

class User {
  String? profileImage;
  int? userId;
  String? phoneNumber;
  String? userName;
  String? firstName;
  String? lastName;

  User(
      {this.profileImage,
      this.userId,
      this.phoneNumber,
      this.userName,
      this.firstName,
      this.lastName});

  User.fromJson(Map<String, dynamic> json) {
    profileImage = json["profile_image"];
    userId = json["user_id"];
    phoneNumber = json["phone_number"];
    userName = json["user_name"];
    firstName = json["first_name"];
    lastName = json["last_name"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["profile_image"] = profileImage;
    data["user_id"] = userId;
    data["phone_number"] = phoneNumber;
    data["user_name"] = userName;
    data["first_name"] = firstName;
    data["last_name"] = lastName;
    return data;
  }
}

class Conversation {
  String? groupProfileImage;
  int? conversationId;
  bool? isGroup;
  String? groupName;

  Conversation(
      {this.groupProfileImage,
      this.conversationId,
      this.isGroup,
      this.groupName});

  Conversation.fromJson(Map<String, dynamic> json) {
    groupProfileImage = json["group_profile_image"];
    conversationId = json["conversation_id"];
    isGroup = json["is_group"];
    groupName = json["group_name"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["group_profile_image"] = groupProfileImage;
    data["conversation_id"] = conversationId;
    data["is_group"] = isGroup;
    data["group_name"] = groupName;
    return data;
  }
}
