// ignore_for_file: file_names

class VerifyOTPModel {
  String? message;
  bool? success;
  String? token;
  ResData? resData;

  VerifyOTPModel({this.message, this.success, this.token, this.resData});

  VerifyOTPModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    success = json['success'];
    token = json['token'];
    resData =
        json['resData'] != null ? ResData.fromJson(json['resData']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['success'] = success;
    data['token'] = token;
    if (resData != null) {
      data['resData'] = resData!.toJson();
    }
    return data;
  }
}

class ResData {
  String? profileImage;
  int? userId;
  String? phoneNumber;
  String? deviceToken;
  String? userName;
  String? bio;
  String? dob;
  int? status;
  String? countryCode;
  String? password;
  int? otp;
  String? gender;
  String? createdAt;
  String? updatedAt;

  ResData(
      {this.profileImage,
      this.userId,
      this.phoneNumber,
      this.deviceToken,
      this.userName,
      this.bio,
      this.dob,
      this.status,
      this.countryCode,
      this.password,
      this.otp,
      this.gender,
      this.createdAt,
      this.updatedAt});

  ResData.fromJson(Map<String, dynamic> json) {
    profileImage = json['profile_image'];
    userId = json['user_id'];
    phoneNumber = json['phone_number'];
    deviceToken = json['device_token'];
    userName = json['user_name'];
    bio = json['bio'];
    dob = json['dob'];
    status = json['status'];
    countryCode = json['country_code'];
    password = json['password'];
    otp = json['otp'];
    gender = json['gender'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['profile_image'] = profileImage;
    data['user_id'] = userId;
    data['phone_number'] = phoneNumber;
    data['device_token'] = deviceToken;
    data['user_name'] = userName;
    data['bio'] = bio;
    data['dob'] = dob;
    data['status'] = status;
    data['country_code'] = countryCode;
    data['password'] = password;
    data['otp'] = otp;
    data['gender'] = gender;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}
