import 'package:flutter/material.dart';
import 'package:SpoTinder/constants.dart';
import 'package:SpoTinder/models/User.dart';
import 'package:SpoTinder/pages/userPages/messaging_page.dart';
import 'package:SpoTinder/pages/userPages/profile_page.dart';
import 'package:SpoTinder/pages/userPages/settings_page.dart';
import 'package:SpoTinder/pages/userPages/swipe_page.dart';

class HomePage extends StatefulWidget {
  final User user;
  late ProfilePage profilePage;
  late SwipePage swipePage;
  late MessagingPage messagingPage;
  late SettingsPage settingsPage;

  HomePage({Key? key, required this.user}) : super(key: key) {
    profilePage = ProfilePage(user : user);
    swipePage = SwipePage(user: user);
    messagingPage = MessagingPage(user: user);
    settingsPage = SettingsPage(user: user);
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  late final pages = [
    widget.profilePage,
    widget.swipePage,
    widget.messagingPage,
    widget.settingsPage,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (newIndex) {
          setState(() {
            currentIndex = newIndex;
          });

        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.perm_identity_outlined, color: primaryWhiteColor,),
            label: 'Profile',
            backgroundColor: primaryDarkColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swipe, color: primaryWhiteColor),
            label: 'Swipe',
            backgroundColor: primaryDarkColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.messenger, color: primaryWhiteColor),
            label: 'Messenger',
            backgroundColor: primaryDarkColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, color: primaryWhiteColor),
            label: 'Settings',
            backgroundColor: primaryDarkColor,
          ),
        ],
      ),
    );
  }
}
