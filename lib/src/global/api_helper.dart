class ApiHelper {
  static const String baseUrl = 'http://62.72.36.245:3000/api';

  /// API Paths
  String registerPhone = "$baseUrl/register-phone";
  String verifyOtpPhone = "$baseUrl/verify-phone-otp";
  String userCreateProfile = "$baseUrl/user-details";
  String userNameCheck = "$baseUrl/check-user-name";
  String getAllContact = "$baseUrl/get-all-available-contacts";
  String addContact = "$baseUrl/add-contact-name";
  String sendChatMsg = "$baseUrl/send-message";
  String deleteChatMsg = "$baseUrl/delete-messages";
  String getOnetoOneMedia = "$baseUrl/get-one-to-one-media";
  String createGroupAdmin = "$baseUrl/create-group-admin";
  String removeGroupAdmin = "$baseUrl/remove-member-from-group";
  String createGroup = "$baseUrl/create-group";
  String addMemberToGroup = "$baseUrl/add-member-to-group";
  String addArchive = "$baseUrl/add-to-archive";
  String addStar = "$baseUrl/add-to-star-message";
  String getRoomIdUrl = "$baseUrl/call-user";
  String blockUserUrl = "$baseUrl/block-user";
  String allStarredUrl = '$baseUrl/star-message-list';
  String blockUserList = '$baseUrl/block-user-list';
  String getReplyUrl = '$baseUrl/get-message-details';
  String exitGroupUrl = '$baseUrl/exit-from-group';
  String addStoryUrl = '$baseUrl/add-status';
  String statusListUrl = '$baseUrl/status-list';
  String clearChatUrl = '$baseUrl/clear-all-chat';
  String viewStatusUrl = '$baseUrl/view-status';
  String myStatusSeenListUrl = '$baseUrl/status-view-list';
  String addStatusUrl = '$baseUrl/add-status';
  String callCutByMe = '$baseUrl/call-cut-by-me';
  String callCutByReceiver = '$baseUrl/call-cut-by-receiver';
  String statusDetele = '$baseUrl/delete-status-media-by-id';
}
