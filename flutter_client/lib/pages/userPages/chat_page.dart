import 'package:SpoTinder/models/requests/get_matches_model.dart';
import 'package:SpoTinder/models/requests/chat_model.dart';
import 'package:flutter/material.dart';
import 'package:SpoTinder/models/User.dart';
import 'package:SpoTinder/api/server_api.dart';

import 'package:SpoTinder/constants.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatPageArgs
{
  final User user;
  final Match match;
  final WebSocketSink? ws;
  final Stream<dynamic> updateStream;

  const ChatPageArgs(this.user, this.match, this.ws, this.updateStream);
}

class ChatPage extends StatefulWidget {
  final ChatPageArgs arg;
  Future<GetMessagesResponseModel>?  getMessagesResponse;

  ChatPage({Key? key, required this.arg}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
{
  TextEditingController textFieldController = TextEditingController();
  ScrollController messagesScrollController = ScrollController();

  @override
  void initState()
  {
    // messagesScrollController.addListener(messagesListScrollEvent);
    super.initState();
    widget.getMessagesResponse ??= APIService.getMessages(
      widget.arg.match.id
    );
    widget.getMessagesResponse?.then((value) {
        setState((){
            widget.arg.match.messages = value.data;
            if (widget.arg.match.messages.isNotEmpty) {
              widget.arg.match.messages[0].isRead = true;
            }
        });
    });

    listenForChanges(widget.arg.updateStream);
  }

  Future<void> listenForChanges(Stream<dynamic> stream) async {
    await for (final value in stream) {
      setState(() {
          if (widget.arg.match.messages.isNotEmpty) {
            widget.arg.match.messages[0].isRead = true;
          }
      });
    }
  }

  void sendMessage()
  {
    String text = textFieldController.text;
    if (text.isEmpty) {
      return;
    }

    SendMessageModel msgModel = SendMessageModel(
      widget.arg.match.id,
      textFieldController.text,
    );

    widget.arg.ws?.add(msgModel.toJsonStr());

    Message msg = Message(
      true,
      DateTime.now(),
      textFieldController.text,
      true
    );

    messagesScrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
    );

    setState(() {
        widget.arg.match.messages.insert(0, msg);
        textFieldController.clear();
    });

  }

  // lazy loading?
  // void messagesListScrollEvent()
  // {
  //   var before = messagesScrollController.position.extentBefore; // en dessous
  //   var after = messagesScrollController.position.extentAfter; // au dessus
  // }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black87,
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_outlined,
            color: Colors.white,
          ),
        ),
        flexibleSpace: SafeArea(
          child: Container(
            padding: EdgeInsets.only(left: 45),
            child: GestureDetector(
              onTap: () => Navigator.of(context).pushNamed("/MatchProfilePage", arguments: widget.arg),
              child: Row(
                children: <Widget>[
                  SizedBox(width: 2,),
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      widget.arg.match.profile.imageURL,
                      headers: {'Authorization': widget.arg.user.token},
                    ),
                    maxRadius: 23,
                  ),
                  SizedBox(width: 12,),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(widget.arg.match.profile.surname, style: tertiaryTitleStyle,),
                        SizedBox(height: 6,),
                        Text("Online", style: tertiaryTitleStyle,),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: GestureDetector(
        child: Stack(
          children: <Widget>[
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: mainGradient,
              ),
            ),
            Column(
              children: [
                Expanded(child: ListView.builder(
                    reverse: true,
                    controller: messagesScrollController,
                    itemCount: widget.arg.match.messages.length,
                    shrinkWrap: true,
                    padding: EdgeInsets.only(top: 10,bottom: 10),
                    // physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index){
                      return Container(
                        padding: EdgeInsets.only(left: 14,right: 14,top: 10,bottom: 10),
                        child: Align(
                          alignment: (widget.arg.match.messages[index].sender?Alignment.topRight:Alignment.topLeft),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: (widget.arg.match.messages[index].sender?Colors.teal:Colors.grey.shade200),
                            ),
                            padding: EdgeInsets.all(16),
                            child: Text(widget.arg.match.messages[index].content, style: TextStyle(fontSize: 15, color: widget.arg.match.messages[index].sender?Colors.white:Colors.black),),
                          ),
                        ),
                      );
                    },
                )),
                Container(
                  padding: EdgeInsets.only(left: 10,bottom: 10,top: 10),
                  height: 60,
                  width: double.infinity,
                  color: Color(0xff5ac18e),
                  child: Row(
                    children: <Widget>[
                      SizedBox(width: 15,),
                      Expanded(
                        child: TextField(
                          controller: textFieldController,
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            hintText: "Write message...",
                            // hintStyle: TextStyle(color: Colors.white),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      SizedBox(width: 15,),
                      FloatingActionButton(
                        onPressed: () => sendMessage(),
                        child: Icon(Icons.send,color: Colors.white,size: 18,),
                        backgroundColor: Colors.black87,
                        elevation: 0,
                      ),
                    ],
                  ),
                ),
              ],
            )
            // ),
          ],
        ),
      ),
    );
  }
}
