import 'baseResponse_model.dart';

class SignUpResponseModel {
  SpotinderResponseModel status;
  SignUpResponseModel(this.status);


  factory SignUpResponseModel.fromJson(Map<String, dynamic> json) {
    return SignUpResponseModel(
      SpotinderResponseModel.fromJson(json)
    );
  }

}

class SignUpRequestModel {
  String username;
  String password;  // or hash?

  SignUpRequestModel(this.username, this.password);

  SignUpRequestModel.noArgs() : username = "", password = "";


  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'username': username.trim(),
      'password': password,
    };
    return map;
  }

}
