import 'dart:ui';

import 'package:SpoTinder/api/server_api.dart';
import 'package:SpoTinder/models/requests/swipe_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:SpoTinder/models/User.dart';
import 'package:swipe_cards/swipe_cards.dart';
import '../../constants.dart';
import '../../models/requests/get_potential_matches_model.dart';

class SwipePage extends StatefulWidget {
  final User user;
  bool initDone = false;
  bool firstRun = true;
  List<SwipeCard> potentialMatches = [];
  List<SwipeCard> copyMatches = [];
  SwipePage({Key? key, required this.user}) : super(key: key);

  @override
  State<SwipePage> createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage> {
  List<SwipeItem> swipeItems = <SwipeItem>[];

  @override
  void initState() {
    if (widget.firstRun) {
      fetchPotentialMatches();  //fill potentialMatches with new users
    }
    else{
      widget.copyMatches = widget.potentialMatches.sublist(0);
      initSwipeItems();
    }
    super.initState();
  }

  void initSwipeItems() {
    swipeItems = [];
    for (int i = 0; i < widget.copyMatches.length; i++) {
      swipeItems.add(SwipeItem(
        content: widget.copyMatches[i],
        likeAction: () async {
          PostSwipeResultResponse response = await APIService.postSwipeResult(
              PostSwipeResultRequest(
                  widget.copyMatches[i].profileData.profile.id, "right"));

          if (response.swipeData.isMatch) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('You have a new match!')));
          }
        },
        nopeAction: () {
          APIService.postSwipeResult(PostSwipeResultRequest(
              widget.copyMatches[i].profileData.profile.id, "left"));
        },
      ));
    }

    setState(() {
      widget.initDone = true;
    });
  } // SwipeItem is useful so that we can get the item with the controller, for example when clicking on the like/nope buttons

  void fetchPotentialMatches() async {
    GetPotentialMatchesResponseModel response =
        await APIService.getPotentialMatches();
    widget.potentialMatches = [];
    for (var value in response.data) {
      widget.potentialMatches.add(SwipeCard(
          profileData: value,
          token: widget.user.token)); // token to fetch image if needed
    }

    widget.copyMatches = widget.potentialMatches.sublist(0);  // copy the new list. The copy list will be given to the SwipeCards widget
    initSwipeItems(); // init SwipeItems for MatchEngine (needed for swipe widget)

    widget.firstRun = false;

  }

  @override
  Widget build(BuildContext context) {
    MatchEngine matchEngine = MatchEngine(swipeItems: swipeItems);
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
            Color(0x775ac18e),
            Color(0x995ac18e),
            Color(0xcc5ac18e),
            Color(0xff5ac18e),
            Colors.black
          ])),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              const SizedBox(
                height: 40,
              ),
              widget.initDone
                  ? SizedBox(
                      height: MediaQuery.of(context).size.height - 220 ,
                      child: SwipeCards(
                        matchEngine: matchEngine,
                        itemBuilder: (BuildContext context, int index) {
                          return widget.copyMatches[index];  // index - counter to make sure we build the right card (considering the .removeAt below)
                        },
                        onStackFinished: () {
                          fetchPotentialMatches();
                          setState(() {});
                        },
                        itemChanged: (SwipeItem item, int index) {
                          widget.potentialMatches.removeAt(0);  //always remove the card at the top of the stack
                        },
                        fillSpace: true,
                      ),
                    )
                  : const Center(heightFactor: 15.0,child: CircularProgressIndicator()), //const Text("Searching for people...", style: primaryTitleStyle,)
              const SizedBox(
                height: 10,
              ),

              widget.initDone ? buildButtons(matchEngine) : const Text(''),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildButtons(MatchEngine cardController) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () {
            cardController.currentItem?.nope();
          },
          style: cardsButtonStyle,
          child: const Icon(
            Icons.clear,
            color: Colors.red,
            size: 45,
          ),
        ),
        ElevatedButton(
          onPressed: () {
            cardController.currentItem?.like();
          },
          style: cardsButtonStyle,
          child: const Icon(
            Icons.favorite,
            color: Colors.teal,
            size: 40,
          ),
        ),
      ],
    );
  }
}

class SwipeCard extends StatelessWidget {
  final PotentialMatchData profileData;
  final String token;

  const SwipeCard({Key? key, required this.profileData, required this.token})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          image: NetworkImage(
              profileData.profile.images.isNotEmpty ? profileData.profile.images[0].imageUrl  // if user hasn't uploaded any image
              : defaultImageUrl,
              headers: {'Authorization': token}),
          fit: BoxFit.cover,
          alignment: const Alignment(-0.3, 0),
        )),
        child: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
            colors: [Colors.transparent, Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Spacer(),
                buildNameAndAge(),
                const SizedBox(
                  height: 7,
                ),
                buildDescription(),
                const SizedBox(
                  height: 8,
                ),
                buildPercentile(),
                const SizedBox(
                  height: 20,
                ),
                buildTopGenres(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDescription() {
    return Row(
      children: [
        SizedBox(
            width: 270,
            child: Text(profileData.profile.description,
                style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                    color: primaryWhiteColor))),
      ],
    );
  }

  Widget buildNameAndAge() {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 215,
          child: Text(
            profileData.profile.surname,
            style: primaryTitleStyle,
          ),
        ),
        const SizedBox(
          width: 16,
        ),
        Text(
          '${profileData.profile.age}',
          style: primaryTitleStyle,
        )
      ],
    );
  }


  Widget buildPercentile() {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green,
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        Text(
          'Matching at ${profileData.match}%',
          style: tertiaryTitleStyle,
        ),
      ],
    );
  }

  Widget buildTopGenres() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          width: 130,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(60),
              color: CupertinoColors.inactiveGray),
          child: Text(
            profileData.genres[0],
            textAlign: TextAlign.center,
            style: tertiaryTitleStyle,
          ),
        ),
        Container(
          width: 130,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(60),
              color: CupertinoColors.inactiveGray),
          child: Text(
            profileData.genres[1],
            textAlign: TextAlign.center,
            style: tertiaryTitleStyle,
          ),
        ),
      ],
    );
  }
}


