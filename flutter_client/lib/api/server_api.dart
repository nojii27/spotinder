import 'package:SpoTinder/models/requests/chat_model.dart';
import 'package:SpoTinder/models/requests/get_potential_matches_model.dart';
import 'package:SpoTinder/models/requests/login_model.dart';
import 'package:SpoTinder/models/requests/signup_model.dart';
import 'package:SpoTinder/models/requests/swipe_model.dart';
import 'package:SpoTinder/models/requests/updateProfile_model.dart';
import 'package:SpoTinder/models/requests/get_matches_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/requests/baseResponse_model.dart';

class APIService {
  static const String host = "spotinder.duckdns.org";
  static const String apiUrl = "https://$host/api";
  static const String webSocketUrl = "wss://$host/ws";
  static const String loginEndPoint = "$apiUrl/login";
  static const String signupEndPoint = "$apiUrl/register";
  static const String logoutEndPoint = "$apiUrl/spotify/disconnect";
  static const String updateProfileEndPoint = "$apiUrl/profile";
  static const String getProfileDataEndPoint = updateProfileEndPoint;
  static const String getPotentialMatchesEndPoint = "$apiUrl/profiles";
  static const String postSwipeResultEndPoint = "$apiUrl/swipe";
  static const String getMatchesEndpoint = "$apiUrl/matches";
  static const String getMessagesEndpoint = "$apiUrl/messenger/";
  static const String chatWebSocketEndpoint = "$webSocketUrl/chat";
  static const String postProfilesActionEndPoint = "$apiUrl/match/";
  static late Map<String, String> headers;

  static void setHeaders(String authToken) {
    headers = {'Authorization': authToken};
  }

  static Future<LoginResponseModel> login(
      LoginRequestModel loginRequestModel) async {

    final response = await http.post(
      Uri.parse(loginEndPoint),
      body: jsonEncode(loginRequestModel),
    );

    if (response.statusCode == 200)
    {
      return LoginResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          "Login Request wasn't handled properly ${response.statusCode}");
    }
  }

  static Future<SignUpResponseModel> signUp(
      SignUpRequestModel signUpRequestModel) async {


    final response = await http.post(
      Uri.parse(signupEndPoint),
      body: jsonEncode(signUpRequestModel),
    );

    if (response.statusCode == 200) {
      return SignUpResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          "SignUp Request wasn't handled properly ${response.statusCode}");
    }
  }

  static Future<SignUpResponseModel> disconnectSpotify() async {
    final response = await http.post(
      Uri.parse(logoutEndPoint),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      return SignUpResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          "Logout Request wasn't handled properly ${response.statusCode}");
    }
  }

  static Future<UpdateResponseModel> updateProfile(
      UpdateRequestModel updateRequestModel) async {
    final response = await http.post(
      Uri.parse(updateProfileEndPoint),
      headers: headers,
      body: jsonEncode(updateRequestModel),
    );
    
    if (response.statusCode == 200) {
      return UpdateResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          "update Request wasn't handled properly ${response.statusCode}");
    }
  }

  static Future<GetProfileResponseModel> getProfile({int matchID=-1}) async {
    final uri = matchID >= 0 ?
       Uri.parse('$getProfileDataEndPoint/$matchID')
          : Uri.parse(getProfileDataEndPoint);
    final response = await http.get(
      uri,
      headers: headers,
    );
    

    if (response.statusCode == 200) {
      return GetProfileResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          "Get profile Request wasn't handled properly ${response.statusCode}");
    }
  }

  static Future<GetPotentialMatchesResponseModel> getPotentialMatches() async {
    final response = await http.get(
      Uri.parse(getPotentialMatchesEndPoint),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      return GetPotentialMatchesResponseModel.fromJson(
          json.decode(response.body));
    } else {
      throw Exception(
          "Get Potential Matches Request wasn't handled properly ${response.statusCode}");
    }
  }

  static Future<PostSwipeResultResponse> postSwipeResult(
      PostSwipeResultRequest request) async {
    
    final response = await http.post(
      Uri.parse(postSwipeResultEndPoint),
      headers: headers,
      body: jsonEncode(request.toJson())
    );

    

    if(response.statusCode == 200)
      {
        return PostSwipeResultResponse.fromJson(json.decode(response.body));
      }
    else
      {
        throw Exception("Post swipe result wasn't handled properly");
      }

  }

  static Future<GetMatchesResponse> getMatches() async
  {
    final response = await http.get(
      Uri.parse(getMatchesEndpoint),
      headers: headers,
    );

    

    if(response.statusCode == 200)
      {
        return GetMatchesResponse.fromJson(json.decode(response.body));
      }
    else
      {
        throw Exception("Get matches result wasn't handled properly");
      }

  }

  static Future<GetMessagesResponseModel> getMessages(int id) async
  {
    final response = await http.get(
      Uri.parse(getMessagesEndpoint + id.toString()),
      headers: headers,
    );

    

    if(response.statusCode == 200)
      {
        return GetMessagesResponseModel.fromJson(json.decode(response.body));
      }
    else
      {
        throw Exception("Get messenger/$id result wasn't handled properly");
      }

  }

  static Future<SpotinderResponseModel> postAction(int id, String action) async // accept or remove
  {
    final response = await http.post(
      Uri.parse(postProfilesActionEndPoint + id.toString()),
      headers: headers,
      body: jsonEncode({'action': action})
    );

    

    if(response.statusCode == 200)
    {
      return SpotinderResponseModel.fromJson(json.decode(response.body));
    }
    else
    {
      throw Exception("postAction result wasn't handled properly");
    }

  }

}
