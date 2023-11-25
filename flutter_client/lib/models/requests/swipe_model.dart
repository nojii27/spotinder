import 'baseResponse_model.dart';

//This file contains all requests/response that can be made relating to a profile

class PostSwipeResultResponse{
  SpotinderResponseModel status;
  SwipeData swipeData;
  PostSwipeResultResponse(this.status, this.swipeData);

  factory PostSwipeResultResponse.fromJson(Map<String, dynamic> json) {
    return PostSwipeResultResponse(
      SpotinderResponseModel.fromJson(json),
      json['data'] != null ? SwipeData.fromJson(json['data']) : SwipeData.noArgs()
    );
  }
}

class PostSwipeResultRequest {
  int profileId;
  String swipeDirection;
  PostSwipeResultRequest(this.profileId, this.swipeDirection);


  Map<String, dynamic> toJson() {
    return {
      'id' : profileId,
      'swipe' : swipeDirection,
    };
  }
}

class SwipeData
{
  bool isMatch;
  SwipeData(this.isMatch);
  SwipeData.noArgs() : isMatch = false;
  factory SwipeData.fromJson(Map<String, dynamic> json) {
    return SwipeData(
        json['match']
    );
  }

}