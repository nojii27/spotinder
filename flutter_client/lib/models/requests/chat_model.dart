import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:SpoTinder/models/requests/baseResponse_model.dart';

class GetMessagesResponseModel {
  GetMessagesResponseModel(
    this.status,
    this.data,
  );

  SpotinderResponseModel status;
  List<Message> data;

  factory GetMessagesResponseModel.fromJson(
          Map<String, dynamic> json) =>
      GetMessagesResponseModel(
        SpotinderResponseModel.fromJson(json),
        List<Message>.from(json["data"].map((x) => Message.fromJson(x))),
      );

}

class Message
{
  bool sender;
  DateTime timeStamp;
  String content;
  bool isRead;

  Message(this.sender, this.timeStamp, this.content, this.isRead);

  factory Message.fromJson(Map<String, dynamic> json)
  {
    // Convert UTC to local time
    String dateStr = json['timestamp'];
    DateTime parsedDateTime = DateFormat('MM/DD/yy HH:mm:ss').parseUTC(dateStr).toLocal();

    return Message(
      json['sender'],
      parsedDateTime,
      json['content'],
      json['isRead']
    );
  }
}

class MessageReceivedModel
{
  int matchId;
  Message message;

  MessageReceivedModel(this.matchId, this.message);

  factory MessageReceivedModel.fromJson(Map<String, dynamic> json)
  {
    return MessageReceivedModel(
      json['matchID'],
      Message.fromJson(json['message'])
    );
  }
}

class SendMessageModel
{
  int matchId;
  String content;

  SendMessageModel(this.matchId, this.content);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'matchID': matchId,
      'message': content
    };

    return map;
  }

  String toJsonStr() {
    return json.encode(toJson());
  }
}
