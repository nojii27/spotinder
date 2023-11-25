import 'package:flutter/material.dart';
import 'package:SpoTinder/api/server_api.dart';
import 'package:SpoTinder/models/User.dart';
import 'package:SpoTinder/models/requests/disconnect_model.dart';

import '../../constants.dart';

class SettingsPage extends StatefulWidget {
  final User user;

  const SettingsPage({Key? key, required this.user}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPage();
}

class _SettingsPage extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        child: Stack(
          children: <Widget>[
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: mainGradient,
              ),
              child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 120),
                  child: Column(
                    children: <Widget>[
                      const Text('Settings page',style: primaryTitleStyle,),
                      const SizedBox(
                        height: 30,
                      ),
                      ElevatedButton(
                        onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("logout success")));
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/', (_) => false);
                        },
                        style: secondaryButtonStyle,
                        child: Text(
                          'Logout',
                          style: TextStyle(
                              color: Theme.of(context).secondaryHeaderColor),
                        ),
                      ),
                      const SizedBox(height: 50,),
                      ElevatedButton(
                        onPressed: () {
                          disconnectAndRedirect(context);
                        },
                        style: secondaryButtonStyle,
                        child: Text(
                          'Logout and disconnect spotify',
                          style: TextStyle(
                              color: Theme.of(context).secondaryHeaderColor),
                        ),
                      ),
                      const SizedBox(height: 60,),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, "/SpotifyLoginPage");
                        },
                        style: secondaryButtonStyle,
                        child: Text(
                          'Connect a spotify account',
                          style: TextStyle(
                              color: Theme.of(context).secondaryHeaderColor),
                        ),
                      )
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }

  void disconnectAndRedirect(BuildContext context) {
    APIService
        .disconnectSpotify()
        .then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("disconnected successfully")));
      Navigator.pushNamedAndRemoveUntil(
          context, '/', (_) => false);
    });
  }
}
