// class StoryListData {
//   String? status;
//   String? msg;
//   List<Post>? post;
//   List<MyPost>? myPost;

//   StoryListData({this.status, this.msg, this.post, this.myPost});

//   StoryListData.fromJson(Map<String, dynamic> json) {
//     status = json["status"];
//     msg = json["msg"];
//     post = json["post"] == null
//         ? null
//         : (json["post"] as List).map((e) => Post.fromJson(e)).toList();
//     myPost = json["my_post"] == null
//         ? null
//         : (json["my_post"] as List).map((e) => MyPost.fromJson(e)).toList();
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data["status"] = status;
//     data["msg"] = msg;
//     if (post != null) {
//       data["post"] = post?.map((e) => e.toJson()).toList();
//     }
//     if (myPost != null) {
//       data["my_post"] = myPost?.map((e) => e.toJson()).toList();
//     }
//     return data;
//   }
// }

// class MyPost {
//   String? storyId;
//   String? userId;
//   String? url;
//   String? type;
//   String? createDate;
//   String? username;
//   String? mobileNumber;
//   String? profilePic;
//   List<StoryImage1>? storyImage;

//   MyPost(
//       {this.storyId,
//       this.userId,
//       this.url,
//       this.type,
//       this.createDate,
//       this.username,
//       this.mobileNumber,
//       this.profilePic,
//       this.storyImage});

//   MyPost.fromJson(Map<String, dynamic> json) {
//     storyId = json["story_id"];
//     userId = json["user_id"];
//     url = json["url"];
//     type = json["type"];
//     createDate = json["create_date"];
//     username = json["username"];
//     profilePic = json["profile_pic"];
//     mobileNumber = json['mobile_number'];
//     storyImage = json["story_image"] == null
//         ? null
//         : (json["story_image"] as List)
//             .map((e) => StoryImage1.fromJson(e))
//             .toList();
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data["story_id"] = storyId;
//     data["user_id"] = userId;
//     data["url"] = url;
//     data["type"] = type;
//     data["create_date"] = createDate;
//     data["username"] = username;
//     data["profile_pic"] = profilePic;
//     data['mobile_number'] = mobileNumber;
//     if (storyImage != null) {
//       data["story_image"] = storyImage?.map((e) => e.toJson()).toList();
//     }
//     return data;
//   }
// }

// class StoryImage1 {
//   int? storyId;
//   String? url;
//   String? type;

//   StoryImage1({this.storyId, this.url, this.type});

//   StoryImage1.fromJson(Map<String, dynamic> json) {
//     storyId = json["story_id"];
//     url = json["url"];
//     type = json["type"];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data["story_id"] = storyId;
//     data["url"] = url;
//     data["type"] = type;
//     return data;
//   }
// }

// class Post {
//   String? storyId;
//   String? userId;
//   String? url;
//   String? type;
//   String? createDate;
//   int? totalStories;
//   int? userReadCount;
//   String? username;
//   String? mobileNumber;
//   String? profilePic;
//   List<StoryImage>? storyImage;

//   Post(
//       {this.storyId,
//       this.userId,
//       this.url,
//       this.type,
//       this.createDate,
//       this.totalStories,
//       this.userReadCount,
//       this.username,
//       this.mobileNumber,
//       this.profilePic,
//       this.storyImage});

//   Post.fromJson(Map<String, dynamic> json) {
//     storyId = json["story_id"];
//     userId = json["user_id"];
//     url = json["url"];
//     type = json["type"];
//     createDate = json["create_date"];
//     totalStories = json["total_stories"];
//     userReadCount = json["user_read_count"];
//     username = json["username"];
//     mobileNumber = json['mobile_number'];
//     profilePic = json["profile_pic"];
//     storyImage = json["story_image"] == null
//         ? null
//         : (json["story_image"] as List)
//             .map((e) => StoryImage.fromJson(e))
//             .toList();
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data["story_id"] = storyId;
//     data["user_id"] = userId;
//     data["url"] = url;
//     data["type"] = type;
//     data["create_date"] = createDate;
//     data["total_stories"] = totalStories;
//     data["user_read_count"] = userReadCount;
//     data["username"] = username;
//     data['mobile_number'] = mobileNumber;
//     data["profile_pic"] = profilePic;
//     if (storyImage != null) {
//       data["story_image"] = storyImage?.map((e) => e.toJson()).toList();
//     }
//     return data;
//   }
// }

// class StoryImage {
//   int? storyId;
//   String? url;
//   String? type;
//   int? isSeen;

//   StoryImage({this.storyId, this.url, this.type, this.isSeen});

//   StoryImage.fromJson(Map<String, dynamic> json) {
//     storyId = json["story_id"];
//     url = json["url"];
//     type = json["type"];
//     isSeen = json["is_seen"];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data["story_id"] = storyId;
//     data["url"] = url;
//     data["type"] = type;
//     data["is_seen"] = isSeen;
//     return data;
//   }
// }
class StoryListData {
  bool? success;
  String? message;
  List<StatusList>? statusList;
  UserData? myStatus;

  StoryListData({this.success, this.message, this.statusList, this.myStatus});

  StoryListData.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['statusList'] != null) {
      statusList = <StatusList>[];
      json['statusList'].forEach((v) {
        statusList!.add(StatusList.fromJson(v));
      });
    }
    myStatus =
        json['myStatus'] != null ? UserData.fromJson(json['myStatus']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (statusList != null) {
      data['statusList'] = statusList!.map((v) => v.toJson()).toList();
    }
    if (myStatus != null) {
      data['myStatus'] = myStatus!.toJson();
    }
    return data;
  }
}

class StatusList {
  String? fullName;
  String? phoneNumber;
  UserData? userData;

  StatusList({this.fullName, this.phoneNumber, this.userData});

  StatusList.fromJson(Map<String, dynamic> json) {
    fullName = json['full_name'];
    phoneNumber = json['phone_number'];
    userData =
        json['userData'] != null ? UserData.fromJson(json['userData']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['full_name'] = fullName;
    data['phone_number'] = phoneNumber;
    if (userData != null) {
      data['userData'] = userData!.toJson();
    }
    return data;
  }
}

class UserData {
  String? profileImage;
  int? userId;
  List<Statuses>? statuses;

  UserData({this.profileImage, this.userId, this.statuses});

  UserData.fromJson(Map<String, dynamic> json) {
    profileImage = json['profile_image'];
    userId = json['user_id'];
    if (json['Statuses'] != null) {
      statuses = <Statuses>[];
      json['Statuses'].forEach((v) {
        statuses!.add(Statuses.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['profile_image'] = profileImage;
    data['user_id'] = userId;
    if (statuses != null) {
      data['Statuses'] = statuses!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Statuses {
  int? statusId;
  String? statusText;
  String? createdAt;
  List<StatusMedia>? statusMedia;
  List<StatusViews>? statusViews;

  Statuses(
      {this.statusId,
      this.statusText,
      this.createdAt,
      this.statusMedia,
      this.statusViews});

  Statuses.fromJson(Map<String, dynamic> json) {
    statusId = json['status_id'];
    statusText = json['status_text'];
    createdAt = json['createdAt'];
    if (json['StatusMedia'] != null) {
      statusMedia = <StatusMedia>[];
      json['StatusMedia'].forEach((v) {
        statusMedia!.add(StatusMedia.fromJson(v));
      });
    }
    if (json['StatusViews'] != null) {
      statusViews = <StatusViews>[];
      json['StatusViews'].forEach((v) {
        statusViews!.add(StatusViews.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status_id'] = statusId;
    data['status_text'] = statusText;
    data['createdAt'] = createdAt;
    if (statusMedia != null) {
      data['StatusMedia'] = statusMedia!.map((v) => v.toJson()).toList();
    }
    if (statusViews != null) {
      data['StatusViews'] = statusViews!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class StatusMedia {
  String? url;
  int? statusMediaId;

  StatusMedia({this.url, this.statusMediaId});

  StatusMedia.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    statusMediaId = json['status_media_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    data['status_media_id'] = statusMediaId;
    return data;
  }
}

class StatusViews {
  int? statusCount;

  StatusViews({this.statusCount});

  StatusViews.fromJson(Map<String, dynamic> json) {
    statusCount = json['status_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status_count'] = statusCount;
    return data;
  }
}
