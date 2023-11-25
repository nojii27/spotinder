import 'package:SpoTinder/pages/userPages/chat_page.dart';
import 'package:SpoTinder/pages/userPages/match_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:SpoTinder/pages/nonUserPages/login_page.dart';
import 'package:SpoTinder/pages/nonUserPages/signup_page.dart';
import 'package:SpoTinder/pages/nonUserPages/spotify_auhorization_webview.dart';
import 'package:SpoTinder/pages/userPages/home_page.dart';
import 'package:SpoTinder/pages/userPages/profile_page.dart';
import 'package:SpoTinder/pages/userPages/chat_page.dart';

import 'models/User.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    final args = routeSettings.arguments;

    switch (routeSettings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/SignUpPage':
        return MaterialPageRoute(builder: (_) => const SignUpPage());
      case '/SpotifyLoginPage':
        if (args is User) {
          return MaterialPageRoute(builder: (_) => SpotifyWebView(user: args));
        } else {
          return MaterialPageRoute(
              builder: (_) => const BasicErrorPage(
                    errorMessage:
                        "Specified argument for spotifyLoginPage is of wrong type!",
                  ));
        }
      case '/HomePage':
        if(args is User)
          {
            return MaterialPageRoute(builder: (_) => HomePage(user: args,));
          }
        else {
          return MaterialPageRoute(builder: (_) => const BasicErrorPage(errorMessage: "Error, argument to HomePage isn't User"));
        }
      case '/EditProfilePage':
        {
          if(args is User) {
            return MaterialPageRoute(builder: (_) => EditProfilePage(user: args,));
          }
          return MaterialPageRoute(builder: (_) => const BasicErrorPage(errorMessage: "Error, argument to HomePage isn't User"));
        }

      case '/ChatPage':
        {
          if(args is ChatPageArgs) {
            return MaterialPageRoute(builder: (_) => ChatPage(arg: args));
          }
          return MaterialPageRoute(builder: (_) => const BasicErrorPage(errorMessage: "Error, argument to HomePage isn't User"));
        }
      case '/MatchProfilePage':
        {
          if(args is ChatPageArgs) {
            return MaterialPageRoute(builder: (_) => MatchProfilePage(arg: args,));
          }
          return MaterialPageRoute(builder: (_) => const BasicErrorPage(errorMessage: "Error, argument to HomePage isn't User"));
        }
      default:
        return MaterialPageRoute(
            builder: (_) =>
                const BasicErrorPage(errorMessage: "Page not found"));
    }
  }
}

class BasicErrorPage extends StatelessWidget {
  final String errorMessage;

  const BasicErrorPage({Key? key, required this.errorMessage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Are you lost? $errorMessage'),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed("/");
            },
            child: const Text('Go back to home page'),
          )
        ],
      ),
    ));
  }
}
