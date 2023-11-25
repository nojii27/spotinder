import 'dart:async';
import 'package:flutter/material.dart';
import 'package:SpoTinder/api/server_api.dart';
import 'package:SpoTinder/models/requests/updateProfile_model.dart';

import '../../constants.dart';
import 'chat_page.dart';

//This file contains profile page and edit profile page
class MatchProfilePage extends StatefulWidget {
  final ChatPageArgs arg;

  MatchProfilePage({Key? key, required this.arg}) : super(key: key);

  @override
  State<MatchProfilePage> createState() => _MatchProfilePageState();
}

class _MatchProfilePageState extends State<MatchProfilePage> {
  late Future<GetProfileResponseModel> getMachProfile;

  @override
  void initState() {
    getMachProfile =
        APIService.getProfile(matchID: widget.arg.match.profile.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black87,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_outlined,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          ListView(),
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: mainGradient,
            ),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                height: MediaQuery.of(context).size.height,
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    FutureBuilder(
                      future: getMachProfile,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {

                          if (snapshot.data!.status.status == "success") {
                            final matchProfile = snapshot.data!.profileData!;
                            return Column(
                              children: [
                                Card(
                                  elevation: 0,
                                  color: Colors.transparent,
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height: 375,
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: primaryDarkColor,
                                            radius: 84,
                                            child: CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  matchProfile
                                                      .images[0].imageUrl,
                                                  headers: {
                                                    'Authorization':
                                                        widget.arg.user.token
                                                  }),
                                              //NetworkImage
                                              radius: 80,
                                            ), //CircleAvatar
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),

                                          Text(
                                            matchProfile.surname,
                                            style:
                                                secondaryDarkTitleStyle, //Textstyle
                                          ), //Text
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          ! haveBothAccepted() ? ElevatedButton(
                                              style: secondaryButtonStyle,
                                              onPressed: () {
                                                APIService.postAction(widget.arg.match.id, "accept").then((value) {
                                                  if(value.status == "success")
                                                    {
                                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sent an acceptation request to ${matchProfile.surname} succesfully")));
                                                    }
                                                  else
                                                    {
                                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("An error occured: ${value.errorMsg}")));
                                                    }
                                                });
                                              }  ,
                                              child: Text(
                                                'Accept to share with ${matchProfile.surname}',
                                                style: tertiaryTitleStyle,
                                              )) : const Text(""),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Expanded(
                                            child: Text(
                                              matchProfile.description,
                                              maxLines: 9,
                                              softWrap: false,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  tertiaryDarkTitleStyle, //Textstyle
                                            ),
                                          ),
                                          //SizedBox
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  itemCount: matchProfile.images.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        image: DecorationImage(
                                            image: NetworkImage(
                                                matchProfile
                                                    .images![index].imageUrl,
                                                headers: {
                                                  "Authorization":
                                                      widget.arg.user.token
                                                }),
                                            fit: BoxFit.cover),
                                      ),
                                    );
                                  },
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 10.0,
                                    mainAxisSpacing: 10.0,
                                    childAspectRatio: 600 / 900,
                                  ),
                                )
                              ],
                            );
                          } else {
                            return Text(
                                'Error during loading.. try again later');
                          }
                        } else {
                          return Center(
                              heightFactor: 10.0,
                              child: CircularProgressIndicator());
                        }
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool haveBothAccepted() {
    return widget.arg.match.accepted & widget.arg.match.profile.accepted;
  }
}
