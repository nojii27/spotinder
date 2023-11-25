class User {
  final String _username;
  final String _token;
  ProfileData? _profileData;
  final String spotifyURL;
  bool hasToBeUpdated = true; // this is used to know whether the profile page has
  // to be updated (new pictures to fetch). it is set to true when the user edits the profile

  String get username => _username;

  User(this._username, this._token, this.spotifyURL);

  ProfileData? get profileData => _profileData;

  set profileData(ProfileData? value) {
    _profileData = value;
  }

  String get token => _token;

}
class ProfileData{  //toJson doesn't include images, because POST method on /profile awaits
  // base64 Image in string format. Added in the updateRequestModel itself.
  // Here, the from json includes the images for the response,
  // cause the server sends a struct of type SpotinderImage for images
  String description;
  String localisation;
  String gender;
  String surname;
  String birthDate;
  List<SpotinderImage> images;


  ProfileData(this.description, this.localisation, this.gender, this.surname,
      this.birthDate, this.images);

  ProfileData.noArgs() : description = "", localisation = "", gender = "", birthDate = "", surname = "",  images = [];

  Map<String, dynamic> toJson() { //for post, we don't send
    Map<String, dynamic> map = {
      'description': description,
      'localisation': localisation,
      'gender' : gender,
      'surname' : surname,
      'dateOfBirth' : birthDate,
    };

    return map;
  }

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
        json["description"] ?? "",
        json["localisation"] ?? "",
        json["gender"] ?? "",
        json["surname"] ?? "",
        json["dateOfBirth"] ?? "",
        List<SpotinderImage>.from(json["images"].map((x) => SpotinderImage.fromJson(x)))
    );
  }

  bool isEmpty()
  {
    if(surname.isEmpty || birthDate.isEmpty || description.isEmpty || gender.isEmpty || localisation.isEmpty) {
      return true;
    }
    return false;
  }
}

class SpotinderImage{
  int id;
  String imageUrl;

  SpotinderImage(this.id, this.imageUrl);

  factory SpotinderImage.fromJson(Map<String, dynamic> json){
    return SpotinderImage(
        json["id"],
        json["download_url"] ?? ""
    );
  }

}