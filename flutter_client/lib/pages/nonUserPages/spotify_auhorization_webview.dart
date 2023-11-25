import 'package:SpoTinder/constants.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../models/User.dart';
class SpotifyWebView extends StatefulWidget {
  final User user;
  const SpotifyWebView({Key? key, required this.user} ) : super(key: key);

  @override
  State<SpotifyWebView> createState() => _SpotifyWebViewState();
}

class _SpotifyWebViewState extends State<SpotifyWebView> {
  late WebViewController myController;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spotify login'),
        centerTitle: true,
      ),
      body: WebView(
        onWebViewCreated: (controller)
        {
          myController = controller;
        },
        onPageFinished: (value) async {
          if(await checkSpotifyResponse(value))
          {
            widget.user.profileData = ProfileData.noArgs();
            widget.user.profileData!.images.add(SpotinderImage(0, defaultImageUrl));
              Navigator.pushNamedAndRemoveUntil(context, '/HomePage', arguments: widget.user , (_) => false);
          }
        },
        javascriptMode: JavascriptMode.unrestricted,
        initialUrl: widget.user.spotifyURL,
      ),
    );
  }

  Future<bool> checkSpotifyResponse(String url) async {
      if(url.startsWith("https://spotinder.duckdns.org/api/spotify/callback")) {
        var value = await myController.evaluateJavascript("document.documentElement.innerText") ;

        if(value.contains("success")) {   //... not the best way I concede but weird errors when attempt to map the json
          return true;
        }
        return false;
      }
      return false;
  }

}
