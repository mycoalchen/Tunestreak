import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tunestreak/signup2.dart';
import 'package:tunestreak/spotify_provider.dart';
import 'package:web_socket_channel/io.dart';
import 'package:spotify/spotify.dart' as spt;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'dart:io';
import 'dart:convert';
import 'constants.dart';
import 'home.dart';
import 'config.dart';
import 'login_webview.dart';



class Signup1 extends StatefulWidget {
  @override
  _Signup1State createState() => _Signup1State();
}

class _Signup1State extends State<Signup1> {
  var authUri;

  bool _canSignUp = false;
  String serverResponse = 'Connect Spotify';

  void sendMessage(msg) {
    print('Called sendMessage with msg ' + msg);
    IOWebSocketChannel? channel;
    try {
      channel = IOWebSocketChannel.connect('ws://10.0.2.2:3080');
    } catch (e) {
      print("Error on connecting to websocket: " + e.toString());
    }
    // // send message msg
    channel?.sink.add(msg);
    // // listen for event - print the event and close the channel if we get it
    channel?.stream.listen((event) {
      if (event!.isNotEmpty) {
        print(event);
        channel!.sink.close();
      }
    });
  }
  
  // copied from https://github.com/rinukkusu/spotify-dart
  // copied from https://medium.com/@ekosuprastyo15/webview-in-flutter-example-a11a24eb617f
  Future<void> _handleSpotifyButtonPress(BuildContext context, SpotifyProvider spotifyProvider) async {

    final credentials = spt.SpotifyApiCredentials(spotifyClientId, spotifyClientSecret);
    final grant = spt.SpotifyApi.authorizationCodeGrant(credentials);
    final scopes = ['user-read-email', 'user-library-read'];
    authUri = grant.getAuthorizationUrl(
      Uri.parse(spotifyRedirectUri),
      scopes: scopes,
    );

    // !mounted fixes issue of passing BuildContext through async
    if (!mounted) return;    
    ResponseUriWrapper responseUri = ResponseUriWrapper('default');
    responseUri.addListener(() async {
      if (responseUri.getValue() != 'default') {
        // This code called after login_webview redirects to repsponse Uri
        spt.SpotifyApi spotify = spt.SpotifyApi.fromAuthCodeGrant(grant, responseUri.getValue()!);
        spotifyProvider.setSpotify(spotify);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Signup2())
        );
      }
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AuthWebView(authUri.toString(), spotifyRedirectUri, responseUri)),
    );
  }

  Widget _buildSpotifyButton(SpotifyProvider spotifyProvider) {
    return Container(
    margin: const EdgeInsets.only(top: 7.5, bottom: 10.0),
      height: 50,
      width: 270,
      child: ElevatedButton(
        onPressed: () => {
          _handleSpotifyButtonPress(context, spotifyProvider)
        },
        style: loginButtonStyle,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Image.asset(
              'assets/icons/Spotify.png',
              fit: BoxFit.contain,
              height: 30,
            ),
            const SizedBox(width: 8),
            Text(
              //'Connect Spotify',
              serverResponse,
              style: connectButtonTextStyle,
            ),
          ]
        ),
      ),
    );
  }
  Widget _buildSignupText() {
    return const Text(
      'Connect your Spotify account to get started.',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        fontFamily: 'OpenSans',
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            blurRadius: 6,
            color: darkGray,
          )
        ]
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: <Widget>[
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: teal,
                ),
              ),
              Container(
                height: double.infinity,
                alignment: Alignment.center,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 120.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        'Welcome!',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'OpenSans',
                          fontSize: 50.0,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 6,
                              color: darkGray,
                            )
                          ]
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Consumer<SpotifyProvider>(
                        builder: (context, spotifyProvider, child) => _buildSpotifyButton(spotifyProvider),
                      ),
                      const SizedBox(height: 10.0),
                      _buildSignupText(),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}