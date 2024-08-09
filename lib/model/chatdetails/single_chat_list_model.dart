// import 'package:meyaoo_new/Models/reply_msg_model.dart';

class SingleChatListModel {
  List<MessageList>? messageList;

  SingleChatListModel({this.messageList});

  SingleChatListModel.fromJson(Map<String, dynamic> json) {
    if (json['MessageList'] != null) {
      messageList = <MessageList>[];
      json['MessageList'].forEach((v) {
        messageList!.add(MessageList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (messageList != null) {
      data['MessageList'] = messageList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MessageList {
  String? url;
  String? thumbnail;
  int? messageId;
  String? message;
  String? messageType;
  int? messageRead;
  String? videoTime;
  String? audioTime;
  String? latitude;
  String? longitude;
  String? sharedContactName;
  String? sharedContactNumber;
  int? forwardId;
  int? replyId;
  int? statusId;
  String? createdAt;
  String? updatedAt;
  int? senderId;
  int? conversationId;
  bool? isStarMessage;
  bool? myMessage;
  SenderData? senderData;
  String? whoSeenTheMessage;
  String? sharedContactProfileImage;
  // ResData? resData;

  MessageList(
      {this.url,
      this.thumbnail,
      this.messageId,
      this.message,
      this.messageType,
      this.messageRead,
      this.videoTime,
      this.audioTime,
      this.latitude,
      this.longitude,
      this.sharedContactName,
      this.sharedContactNumber,
      this.forwardId,
      this.replyId,
      this.statusId,
      this.createdAt,
      this.updatedAt,
      this.senderId,
      this.conversationId,
      this.isStarMessage,
      this.myMessage,
      this.senderData,
      this.whoSeenTheMessage,
      this.sharedContactProfileImage
      // this.resData
      });

  MessageList.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    thumbnail = json['thumbnail'];
    messageId = json['message_id'];
    message = json['message'];
    messageType = json['message_type'];
    messageRead = json['message_read'];
    videoTime = json['video_time'];
    audioTime = json['audio_time'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    sharedContactName = json['shared_contact_name'];
    sharedContactNumber = json['shared_contact_number'];
    forwardId = json['forward_id'];
    replyId = json['reply_id'];
    statusId = json['status_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    senderId = json['senderId'];
    conversationId = json['conversation_id'];
    isStarMessage = json['is_star_message'];
    myMessage = json['myMessage'];
    senderData = json['senderData'] != null
        ? SenderData.fromJson(json['senderData'])
        : null;
    whoSeenTheMessage = json['who_seen_the_message'];
    sharedContactProfileImage = json['shared_contact_profile_image'];
    // resData =
    //     json['resData'] != null ? ResData.fromJson(json['resData']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    data['thumbnail'] = thumbnail;
    data['message_id'] = messageId;
    data['message'] = message;
    data['message_type'] = messageType;
    data['message_read'] = messageRead;
    data['video_time'] = videoTime;
    data['audio_time'] = audioTime;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['shared_contact_name'] = sharedContactName;
    data['shared_contact_number'] = sharedContactNumber;
    data['forward_id'] = forwardId;
    data['reply_id'] = replyId;
    data['status_id'] = statusId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['senderId'] = senderId;
    data['conversation_id'] = conversationId;
    data['is_star_message'] = isStarMessage;
    data['myMessage'] = myMessage;
    if (senderData != null) {
      data['senderData'] = senderData!.toJson();
    }
    data['who_seen_the_message'] = whoSeenTheMessage;
    data['shared_contact_profile_image'] = sharedContactProfileImage;
    // if (resData != null) {
    //   data['resData'] = resData!.toJson();
    // }
    return data;
  }
}

class SenderData {
  String? profileImage;
  int? userId;
  String? userName;
  String? firstName;
  String? lastName;
  String? phoneNumber;

  SenderData(
      {this.profileImage,
      this.userId,
      this.userName,
      this.firstName,
      this.lastName,
      this.phoneNumber});

  SenderData.fromJson(Map<String, dynamic> json) {
    profileImage = json['profile_image'];
    userId = json['user_id'];
    userName = json['user_name'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    phoneNumber = json['phone_number'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['profile_image'] = profileImage;
    data['user_id'] = userId;
    data['user_name'] = userName;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['phone_number'] = phoneNumber;
    return data;
  }
}
