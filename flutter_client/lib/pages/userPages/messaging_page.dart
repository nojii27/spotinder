import 'dart:async';
import 'dart:convert';

import 'package:SpoTinder/models/requests/get_matches_model.dart';
import 'package:SpoTinder/models/requests/chat_model.dart';
import 'package:SpoTinder/pages/userPages/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:SpoTinder/models/User.dart';
import 'package:SpoTinder/api/server_api.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:SpoTinder/constants.dart';
import 'package:intl/intl.dart';

class MessagingPage extends StatefulWidget {
  final User user;
  Future<GetMatchesResponse>?  getMatchesResponse;
  List<Match> matches = [];
  WebSocketChannel? ws;
  StreamController notifier = StreamController.broadcast();

  MessagingPage({Key? key, required this.user}) : super(key: key);

  @override
  State<MessagingPage> createState() => _MessagingPageState();
}

class _MessagingPageState extends State<MessagingPage>
{
  @override
  void initState()
  {
    super.initState();
    widget.ws = WebSocketChannel.connect(
      Uri.parse(APIService.chatWebSocketEndpoint + "?authorization=${widget.user.token}"),
    );

    if (widget.ws != null) {
      wsListen(widget.ws!.stream);
    }

    display();
  }

  Future<void> refresh({bool force=false}) async
  {
    widget.getMatchesResponse = null;
    widget.matches = [];
    display();
  }

  Future<void> wsListen(Stream<dynamic> stream) async {
    await for (final value in stream) {

      if (value == "Not allowed") {
        continue;
      }

      MessageReceivedModel newMsg = MessageReceivedModel.fromJson(json.decode(value));
      setState(() {
          for (var m in widget.matches) {
            if (m.id == newMsg.matchId) {
              m.messages.insert(0, newMsg.message);
              // refresh chat page if any ...
              widget.notifier.add("1");
            }
          }
      });
    }
  }

  void display()
  {
    widget.getMatchesResponse ??= APIService.getMatches();
    widget.getMatchesResponse?.then((value) {
        widget.matches = value.matchesData!.matches;
        setState((){});
    });
  }

  void deleteMatchDialog(BuildContext context, Match match)
  {
    AlertDialog dialog = AlertDialog(
      content: Text('Are you shure you want to delete ${match.profile.surname} for the matches?'),
      actions: [
        Container(
          child: TextButton(
            style: secondaryButtonStyle,
            child: const Text(
              'Cancel',
              style: normalBoldTextStyle,
            ),
            onPressed: () => Navigator.of(context).pop(),
          )
        ),
        Container(
          child: TextButton(
            style: secondaryButtonStyle,
            child: const Text(
              'Confirm',
              style: normalBoldTextStyle,
            ),
            onPressed: () {
              APIService.postAction(match.id, "remove").then((value) {
                  if(value.status == "success")
                  {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Removed ${match.profile.surname} successfully"),));
                    refresh();
                  }
                  else
                  {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("An error occured : ${value.errorMsg}"),));
                  }
              });
              Navigator.of(context).pop();
            } , //remove from matches
          )
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return dialog;
      },
    );
  }

  String? formatDateTime(DateTime? timestamp)
  {
    if (timestamp == null) {
      return null;
    }

    final now = DateTime.now();

    Duration diff = now.difference(timestamp);
    // print Now
    if (diff.inMinutes < 1) {
      return "Now";
    }

    // print only the time
    else if (diff.inDays < 1) {
      return DateFormat('HH:mm').format(timestamp);
    }

    // print 'Yesterday'
    else if (diff.inDays == 1) {
      return "Yesterday";
    }

    // print the date
    else {
      return DateFormat('DD/MM').format(timestamp);
    }

  }

  FutureOr onGoBack(dynamic value) {
    setState(() {});
  }

  bool isUnread(Message? msg)
  {
    if (msg == null) {
      return false;
    }
    if (msg.sender) {
      return false;
    }
    return !(msg.isRead);
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: GestureDetector(
        child: RefreshIndicator(
          onRefresh: () => refresh(),
          child: Stack(
            children: <Widget>[
              Center(child:Container(
                  height: double.infinity,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: mainGradient,
                  ),
                  child: widget.matches.length == 0?
                  // in case there's no matches
                  CustomScrollView(
                    slivers: [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          // mainAxisSize:  MainAxisSize.max,
                          children: [
                            Flexible(
                              flex: 1,
                              child: Container(child: Text("No matches yet...", style: primaryDarkTitleStyle))
                            )
                          ]
                        )
                      )
                    ],
                  )
                  // in case there are matches
                  :ListView.builder(
                    itemCount: widget.matches.length,
                    itemBuilder: (context, index) {
                      final item = widget.matches[index];
                      Message? latestMsg;
                      if (item.messages.isNotEmpty) {
                        latestMsg = item.messages.elementAt(0);
                      }
                      else {
                        latestMsg = null;
                      }
                      return GestureDetector(
                        onTap: () => Navigator.pushNamed(
                          context,
                          "/ChatPage",
                          arguments: ChatPageArgs(widget.user, item, widget.ws?.sink, widget.notifier.stream)
                        ).then(onGoBack),
                        onLongPress: () => deleteMatchDialog(context, item),
                        child: ConversationListTile(
                          item.profile.surname,
                          latestMsg?.content??"",
                          formatDateTime(latestMsg?.timeStamp)??"",
                          item.profile.imageURL,
                          isUnread(latestMsg),
                          widget.user.token,
                        )
                      );
                    },
                  )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ConversationListTile extends StatefulWidget {
  String surname;
  String message;
  String dateTime;
  String imageURL;
  bool isUnread;
  String token;

  ConversationListTile(this.surname, this.message, this.dateTime, this.imageURL, this.isUnread, this.token);

  @override
  State<ConversationListTile> createState() => _ConversationListTileState();
}

class _ConversationListTileState  extends State<ConversationListTile> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.only(left: 16,right: 16,top: 10,bottom: 10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      widget.imageURL,
                      headers: {'Authorization': widget.token},
                    ),
                    maxRadius: 30,
                  ),
                  const SizedBox(width: 16,),
                  Expanded(
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            widget.surname,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(height: 6,),
                          Text(
                            widget.message,
                            style: TextStyle(fontSize: 15,color: Colors.black87, fontWeight: widget.isUnread?FontWeight.bold:FontWeight.normal),
                            softWrap: false,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(widget.dateTime, style: TextStyle(fontSize: 14,fontWeight: widget.isUnread?FontWeight.bold:FontWeight.normal),),
          ],
        ),
      ),
    );
  }
}
