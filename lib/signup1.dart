import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/io.dart';
import 'package:spotify/spotify.dart' as spt;
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';
import 'constants.dart';
import 'home.dart';
import 'config.dart';
import 'spotify_login_webview.dart';


class Signup1 extends StatefulWidget {
  @override
  _Signup1State createState() => _Signup1State();
}

class _Signup1State extends State<Signup1> {
  var authUri;

  bool _spotifyConnected = false;
  bool _canSignUp = false;
  String serverResponse = 'Server Response';

  // copied from https://github.com/rinukkusu/spotify-dart
  Future<void> initializeSpotifyStuff () async {
    final credentials = spt.SpotifyApiCredentials(spotifyClientId, spotifyClientSecret);
    final grant = spt.SpotifyApi.authorizationCodeGrant(credentials);
    final redirectUri = spotifyRedirectUri;
    final scopes = ['user-read-email', 'user-library-read'];
    authUri = grant.getAuthorizationUrl(
      Uri.parse(redirectUri),
      scopes: scopes,
    );
    // TODO: implement listen
    final responseUri = await listen(redirectUri);
    final spotify = spt.SpotifyApi.fromAuthCodeGrant(grant, responseUri);
  }

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
  
  // copied from https://medium.com/@ekosuprastyo15/webview-in-flutter-example-a11a24eb617f
  void _handleSpotifyButtonPress(BuildContext context) async {
    await initializeSpotifyStuff();
    if (!mounted) return;
    Navigator.push(context, 
      MaterialPageRoute(builder: ((context) => 
      WebViewContainer(authUri))));
  }

  Widget _buildSpotifyButton() {
    return Container(
    margin: const EdgeInsets.only(top: 7.5, bottom: 10.0),
      height: 50,
      width: 270,
      child: ElevatedButton(
        onPressed: () => {
          _handleSpotifyButtonPress(context)
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
  Widget _buildSignUpButton() {
    if (_canSignUp) {
      return Container(
        height: 50,
        width: 150,
        child: ElevatedButton(
          onPressed: () => {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            )
          },
          style: loginButtonStyle,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
              Text(
                'Continue',
                style: connectButtonTextStyle,
              ),
            ]
          ),
        ),
      );
    }
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
                      _buildSpotifyButton(),
                      const SizedBox(height: 10.0),
                      _buildSignUpButton(),
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