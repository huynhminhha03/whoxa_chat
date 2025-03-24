class GroupCreateModel {
  bool? success;
  String? message;
  int? conversationId;
  ConversationDetails? conversationDetails;

  GroupCreateModel(
      {this.success,
      this.message,
      this.conversationId,
      this.conversationDetails});

  GroupCreateModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    conversationId = json['conversation_id'];
    conversationDetails = json['conversationDetails'] != null
        ? ConversationDetails.fromJson(json['conversationDetails'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    data['conversation_id'] = conversationId;
    if (conversationDetails != null) {
      data['conversationDetails'] = conversationDetails!.toJson();
    }
    return data;
  }
}

class ConversationDetails {
  String? groupProfileImage;
  String? groupName;

  ConversationDetails({this.groupProfileImage, this.groupName});

  ConversationDetails.fromJson(Map<String, dynamic> json) {
    groupProfileImage = json['group_profile_image'];
    groupName = json['group_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['group_profile_image'] = groupProfileImage;
    data['group_name'] = groupName;
    return data;
  }
}
