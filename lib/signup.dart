import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'constants.dart';
import 'home.dart';

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  bool _spotifyConnected = false;
  bool _canSignUp = false;
  String serverResponse = 'Server Response';

  String _localhost() {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    }
    else {
      return 'http://localhost:3000';
    }
  }

  _makeGetRequest() async {
    final url = Uri.parse(_localhost());
    // Send a GET request to the url
    Response response = await get(url);
    setState(() {
      serverResponse = response.body;
    });
  }

  Widget _buildSpotifyButton() {
    return Container(
    margin: const EdgeInsets.only(top: 7.5, bottom: 10.0),
      height: 50,
      width: 270,
      child: ElevatedButton(
        onPressed: () => {
          _makeGetRequest()
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