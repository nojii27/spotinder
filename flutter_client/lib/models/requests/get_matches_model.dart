import 'package:SpoTinder/models/requests/chat_model.dart';

import 'baseResponse_model.dart';

class GetMatchesResponse{
  SpotinderResponseModel status;
  GetMatchesData? matchesData;
  GetMatchesResponse(this.status, this.matchesData);

  factory GetMatchesResponse.fromJson(Map<String, dynamic> json) {
    return GetMatchesResponse(
      SpotinderResponseModel.fromJson(json),
      json['data'] != null ? GetMatchesData.fromJson(json['data']) : null
    );
  }
}

class GetMatchesData
{
  List<Match> matches;

  GetMatchesData(this.matches);

  factory GetMatchesData.fromJson(List<dynamic> json)
  {
    List<Match> matchList = [];
    for (Map<String, dynamic> m in json) {
      matchList.add(Match.fromJson(m));
    }

    return GetMatchesData(
      matchList
    );
  }
}

class Match {
  int id;
  bool accepted;
  MatchProfile profile;
  List<Message> messages;

  Match(this.id, this.accepted, this.profile, this.messages);
  factory Match.fromJson(Map<String, dynamic> json)
  {
    List<Message> msg = [];

    if (json['last_message'] != null) {
      msg.add(Message.fromJson(json['last_message']));
    }

    return Match(
      json['id'],
      json['accepted'],
      MatchProfile.fromJson(json['profile']),
      msg,
    );
  }
}

class MatchProfile
{
  int id;
  String surname;
  bool accepted;
  String imageURL;

  MatchProfile(this.id, this.surname, this.accepted, this.imageURL);

  factory MatchProfile.fromJson(Map<String, dynamic> json) {

    return MatchProfile(
      json['id'],
      json['surname'],
      json['accepted'],
      json['image']['download_url'],
    );
  }

}
