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
  String? statusText;
  String? url;
  int? statusMediaId;

  StatusMedia({this.statusText, this.url, this.statusMediaId});

  StatusMedia.fromJson(Map<String, dynamic> json) {
    statusText = json['status_text'];
    url = json['url'];
    statusMediaId = json['status_media_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status_text'] = statusText;
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
