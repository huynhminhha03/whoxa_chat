class ChatProfileModel {
  bool? status;
  ConversationDetails? conversationDetails;
  List<MediaData>? mediaData;
  List<DocumentData>? documentData;
  List<LinkData>? linkData;

  ChatProfileModel(
      {this.status,
      this.conversationDetails,
      this.mediaData,
      this.documentData,
      this.linkData});

  ChatProfileModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    conversationDetails = json['conversationDetails'] != null
        ? ConversationDetails.fromJson(json['conversationDetails'])
        : null;
    if (json['mediaData'] != null) {
      mediaData = <MediaData>[];
      json['mediaData'].forEach((v) {
        mediaData!.add(MediaData.fromJson(v));
      });
    }
    if (json['documentData'] != null) {
      documentData = <DocumentData>[];
      json['documentData'].forEach((v) {
        documentData!.add(DocumentData.fromJson(v));
      });
    }
    if (json['linkData'] != null) {
      linkData = <LinkData>[];
      json['linkData'].forEach((v) {
        linkData!.add(LinkData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (conversationDetails != null) {
      data['conversationDetails'] = conversationDetails!.toJson();
    }
    if (mediaData != null) {
      data['mediaData'] = mediaData!.map((v) => v.toJson()).toList();
    }
    if (documentData != null) {
      data['documentData'] = documentData!.map((v) => v.toJson()).toList();
    }
    if (linkData != null) {
      data['linkData'] = linkData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ConversationDetails {
  String? groupProfileImage;
  bool? isGroup;
  String? groupName;
  List<ConversationsUsers>? conversationsUsers;

  ConversationDetails(
      {this.groupProfileImage,
      this.isGroup,
      this.groupName,
      this.conversationsUsers});

  ConversationDetails.fromJson(Map<String, dynamic> json) {
    groupProfileImage = json['group_profile_image'];
    isGroup = json['is_group'];
    groupName = json['group_name'];
    if (json['ConversationsUsers'] != null) {
      conversationsUsers = <ConversationsUsers>[];
      json['ConversationsUsers'].forEach((v) {
        conversationsUsers!.add(ConversationsUsers.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['group_profile_image'] = groupProfileImage;
    data['is_group'] = isGroup;
    data['group_name'] = groupName;
    if (conversationsUsers != null) {
      data['ConversationsUsers'] =
          conversationsUsers!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ConversationsUsers {
  bool? isAdmin;
  int? conversationsUserId;
  String? createdAt;
  User? user;

  ConversationsUsers(
      {this.isAdmin, this.conversationsUserId, this.createdAt, this.user});

  ConversationsUsers.fromJson(Map<String, dynamic> json) {
    isAdmin = json['is_admin'];
    conversationsUserId = json['conversations_user_id'];
    createdAt = json['createdAt'];
    user = json['User'] != null ? User.fromJson(json['User']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['is_admin'] = isAdmin;
    data['conversations_user_id'] = conversationsUserId;
    data['createdAt'] = createdAt;
    if (user != null) {
      data['User'] = user!.toJson();
    }
    return data;
  }
}

class User {
  String? profileImage;
  int? userId;
  String? phoneNumber;
  String? countryCode;
  String? country;
  String? userName;
  String? firstName;
  String? lastName;
  String? bio;

  User(
      {this.profileImage,
      this.userId,
      this.phoneNumber,
      this.countryCode,
      this.country,
      this.userName,
      this.firstName,
      this.lastName,
      this.bio});

  User.fromJson(Map<String, dynamic> json) {
    profileImage = json['profile_image'];
    userId = json['user_id'];
    phoneNumber = json['phone_number'];
    countryCode = json['country_code'];
    country = json['country'];
    userName = json['user_name'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    bio = json['bio'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['profile_image'] = profileImage;
    data['user_id'] = userId;
    data['phone_number'] = phoneNumber;
    data['country_code'] = countryCode;
    data['country'] = country;
    data['user_name'] = userName;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['bio'] = bio;
    return data;
  }
}

class MediaData {
  String? url;
  String? thumbnail;
  int? messageId;
  String? videoTime;
  String? messageType;
  String? createdAt;

  MediaData(
      {this.url,
      this.thumbnail,
      this.messageId,
      this.videoTime,
      this.messageType,
      this.createdAt});

  MediaData.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    thumbnail = json['thumbnail'];
    messageId = json['message_id'];
    videoTime = json['video_time'];
    messageType = json['message_type'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    data['thumbnail'] = thumbnail;
    data['message_id'] = messageId;
    data['video_time'] = videoTime;
    data['message_type'] = messageType;
    data['createdAt'] = createdAt;
    return data;
  }
}

class DocumentData {
  String? url;
  int? messageId;
  String? messageType;
  String? createdAt;

  DocumentData({this.url, this.messageId, this.messageType, this.createdAt});

  DocumentData.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    messageId = json['message_id'];
    messageType = json['message_type'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    data['message_id'] = messageId;
    data['message_type'] = messageType;
    data['createdAt'] = createdAt;
    return data;
  }
}

class LinkData {
  int? messageId;
  String? message;
  String? messageType;
  String? createdAt;

  LinkData({this.messageId, this.message, this.messageType, this.createdAt});

  LinkData.fromJson(Map<String, dynamic> json) {
    messageId = json['message_id'];
    message = json['message'];
    messageType = json['message_type'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message_id'] = messageId;
    data['message'] = message;
    data['message_type'] = messageType;
    data['createdAt'] = createdAt;
    return data;
  }
}
