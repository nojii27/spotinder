import 'baseResponse_model.dart';

class DisconnectResponseModel {
  SpotinderResponseModel status;
  DisconnectResponseModel(this.status);


  factory DisconnectResponseModel.fromJson(Map<String, dynamic> json) {
    return DisconnectResponseModel(
      SpotinderResponseModel.fromJson(json)
    );
  }

}

class DisconnectRequestModel {
  String username;
  String password;  // or hash?

  DisconnectRequestModel(this.username, this.password);

  DisconnectRequestModel.noArgs() : username = "", password = "";


  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'username': username.trim(),
      'password': password,
    };
    return map;
  }

}
