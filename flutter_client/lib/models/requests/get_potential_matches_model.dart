import '../User.dart';
import 'baseResponse_model.dart';

class GetPotentialMatchesResponseModel {
  GetPotentialMatchesResponseModel(
    this.status,
    this.data,
  );

  SpotinderResponseModel status;
  List<PotentialMatchData> data;

  factory GetPotentialMatchesResponseModel.fromJson(
          Map<String, dynamic> json) =>
      GetPotentialMatchesResponseModel(
        SpotinderResponseModel.fromJson(json),
        List<PotentialMatchData>.from(json["data"].map((x) => PotentialMatchData.fromJson(x))),
      );

}

class PotentialMatchData {
  PotentialMatchData(
    this.match,
    this.profile,
    this.genres,
  );

  int match;
  PotentialMatchProfile profile;
  List<String> genres;

  factory PotentialMatchData.fromJson(Map<String, dynamic> json) =>
      PotentialMatchData(
        json["match"],
        PotentialMatchProfile.fromJson(json["profile"]),
        List<String>.from(json["genres"].map((x) => x)),
      );
}

class PotentialMatchProfile {
  final int id;
  final String surname;
  final String description;
  final int age;
  final String gender;
  final List<SpotinderImage> images;
  PotentialMatchProfile(
      this.id, this.surname, this.description, this.age, this.gender, this.images);


  factory PotentialMatchProfile.fromJson(Map<String, dynamic> json) =>
      PotentialMatchProfile(
        json["id"],
        json["surname"],
        json["description"],
        json["age"],
        json["gender"],
        List<SpotinderImage>.from(json["images"].map((x) => SpotinderImage.fromJson(x))),
      );

}
