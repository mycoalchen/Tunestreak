import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _snapConnected = false;
  bool _spotifyConnected = false;
  Widget _buildSnapchatButton() {
    return Container(
      margin: const EdgeInsets.only(top: 0, bottom: 7.5),
      height: 50,
      width: 270,
      child: ElevatedButton(
        onPressed: () => print('Snapchat Button Pressed'),
        style: snapchatButtonStyle,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Image.asset(
              'assets/icons/Snapchat.png',
              fit: BoxFit.contain,
              height: 30,
            ),
            const SizedBox(width: 8),
            const Text(
              'Connect Snapchat',
              style: connectButtonTextStyle,
            ),
          ]
        ),
      ),
    );
  }
  Widget _buildSpotifyButton() {
    return Container(
    margin: const EdgeInsets.only(top: 7.5, bottom: 10.0),
      height: 50,
      width: 270,
      child: ElevatedButton(
        onPressed: () => print('Spotify Button Pressed'),
        style: spotifyButtonStyle,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Image.asset(
              'assets/icons/Spotify.png',
              fit: BoxFit.contain,
              height: 30,
            ),
            const SizedBox(width: 8),
            const Text(
              'Connect Spotify',
              style: connectButtonTextStyle,
            ),
          ]
        ),
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
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 10,
                              color: darkGray,
                            )
                          ]
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      _buildSnapchatButton(),
                      _buildSpotifyButton(),
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