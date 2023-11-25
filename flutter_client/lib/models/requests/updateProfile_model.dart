
import 'baseResponse_model.dart';
import 'package:SpoTinder/models/User.dart';

//This file contains all requests/response that can be made relating to a profile

class UpdateResponseModel {
  SpotinderResponseModel status;

  UpdateResponseModel(this.status);

  factory UpdateResponseModel.fromJson(Map<String, dynamic> json) {
    return UpdateResponseModel(
      SpotinderResponseModel.fromJson(json),
    );
  }
}

class UpdateRequestModel {
  ProfileData profileData;
  List<String> images;

  UpdateRequestModel(this.profileData, this.images);

  UpdateRequestModel.noArgs() : profileData = ProfileData.noArgs(), images = [];

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = profileData.toJson();
    map['images'] = images;
    return map;
  }
}


class GetProfileResponseModel{
  SpotinderResponseModel status;
  ProfileData profileData;

  GetProfileResponseModel(this.status, this.profileData);

  factory GetProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return GetProfileResponseModel(
      SpotinderResponseModel.fromJson(json),
      json["data"] != null ? ProfileData.fromJson(json["data"]) : ProfileData.noArgs(),
    );
  }

}





