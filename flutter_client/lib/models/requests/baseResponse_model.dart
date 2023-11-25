class SpotinderResponseModel{
  final String status;
  final String errorMsg;

  SpotinderResponseModel(this.status, this.errorMsg);

  factory SpotinderResponseModel.fromJson(Map<String, dynamic> json) {
    return SpotinderResponseModel(
      json["status"] ?? "",
      json["error_msg"] ?? "" //      json["data"] == null ? Data("", "") : Data.fromJson(json['data']),
    );
  }
}

