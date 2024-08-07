// ignore_for_file: file_names

class GetRoomIdModel {
  String? roomId;
  bool? success;

  GetRoomIdModel({this.roomId, this.success});

  GetRoomIdModel.fromJson(Map<String, dynamic> json) {
    roomId = json['room_id'];
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['room_id'] = roomId;
    data['success'] = success;
    return data;
  }
}
