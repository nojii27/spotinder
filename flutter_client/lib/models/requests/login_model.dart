import 'dart:convert';

import 'baseResponse_model.dart';
//TODO: Heritage
class LoginResponseModel {
  final SpotinderResponseModel status;
  final LoginResponseData data;

  LoginResponseModel(this.status, this.data);

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      SpotinderResponseModel.fromJson(json),
      json["data"] == null ? LoginResponseData("", "") : LoginResponseData.fromJson(json['data']),
    );
  }
}

class LoginRequestModel {
  String username;
  String password;

  LoginRequestModel(this.username, this.password);


  LoginRequestModel.noArgs() : username = "", password = "";


  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'username': username.trim(),
      'password': password
    };

    return map;
  }

}

class LoginResponseData {
  final String token;
  final String spotifyURL;

  LoginResponseData(this.token, this.spotifyURL);

  factory LoginResponseData.fromJson(dynamic json) {
    return LoginResponseData(json['token'] ?? "", json['spotifyURL'] ?? "");
  }
}

