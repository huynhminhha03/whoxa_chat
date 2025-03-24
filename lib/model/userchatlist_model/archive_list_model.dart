class UserArchiveListModel {
  List<ArchiveList>? archiveList;

  UserArchiveListModel({this.archiveList});

  UserArchiveListModel.fromJson(Map<String, dynamic> json) {
    if (json['archiveList'] != null) {
      archiveList = <ArchiveList>[];
      json['archiveList'].forEach((v) {
        archiveList!.add(ArchiveList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (archiveList != null) {
      data['archiveList'] = archiveList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ArchiveList {
  int? conversationId;
  bool? isGroup;
  String? groupName;
  String? groupProfileImage;
  String? lastMessage;
  String? lastMessageType;
  int? userId;
  String? userName;
  String? phoneNumber;
  String? profileImage;
  bool? isBlock;
  String? createdAt;
  String? updatedAt;

  ArchiveList(
      {this.conversationId,
      this.isGroup,
      this.groupName,
      this.groupProfileImage,
      this.lastMessage,
      this.lastMessageType,
      this.userId,
      this.userName,
      this.phoneNumber,
      this.profileImage,
      this.isBlock,
      this.createdAt,
      this.updatedAt});

  ArchiveList.fromJson(Map<String, dynamic> json) {
    conversationId = json['conversation_id'];
    isGroup = json['is_group'];
    groupName = json['group_name'];
    groupProfileImage = json['group_profile_image'];
    lastMessage = json['last_message'];
    lastMessageType = json['last_message_type'];
    userId = json['user_id'];
    userName = json['user_name'];
    phoneNumber = json['phone_number'];
    profileImage = json['profile_image'];
    isBlock = json['is_block'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['conversation_id'] = conversationId;
    data['is_group'] = isGroup;
    data['group_name'] = groupName;
    data['group_profile_image'] = groupProfileImage;
    data['last_message'] = lastMessage;
    data['last_message_type'] = lastMessageType;
    data['user_id'] = userId;
    data['user_name'] = userName;
    data['phone_number'] = phoneNumber;
    data['profile_image'] = profileImage;
    data['is_block'] = isBlock;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}
