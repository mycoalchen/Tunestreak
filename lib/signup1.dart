import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'signup2.dart';
import 'signin.dart';
import 'spotify_provider.dart';
import 'package:web_socket_channel/io.dart';
import 'package:spotify/spotify.dart' as spt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'constants.dart';
import 'config.dart';
import 'login_webview.dart';


class Signup1 extends StatefulWidget {
  @override
  _Signup1State createState() => _Signup1State();
}

class _Signup1State extends State<Signup1> {
  var authUri;
  final storage = const FlutterSecureStorage();

  // Save Spotify API Credentials to FlutterSecureStorage
  Future<void> saveSpotifyCredentials(spt.SpotifyApi spotifyApi) async {
    spt.SpotifyApiCredentials credentials = await spotifyApi.getCredentials();
    print("Saving Spotify Credentials - clientId " + credentials.clientId!);
    await storage.write(key: "clientId", value: credentials.clientId);
    await storage.write(key: "clientSecret", value: credentials.clientSecret);
    await storage.write(key: "accessToken", value: credentials.accessToken);
    await storage.write(key: "refreshToken", value: credentials.refreshToken);
    await storage.write(key: "expiration", value: credentials.expiration.toString());
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
  
  // copied from https://github.com/rinukkusu/spotify-dart
  // copied from https://medium.com/@ekosuprastyo15/webview-in-flutter-example-a11a24eb617f
  Future<void> _handleSpotifyButtonPress(BuildContext context, SpotifyProvider spotifyProvider) async {
    Map<String, String> storedValues = await storage.readAll();
    // No stored values - need to do authentication-code flow
    if (storedValues.isEmpty) {
      print("Using authentication code flow");

      final credentials = spt.SpotifyApiCredentials(spotifyClientId, spotifyClientSecret);
      final grant = spt.SpotifyApi.authorizationCodeGrant(credentials);
      final scopes = ['user-read-email', 'user-library-read'];

      authUri = grant.getAuthorizationUrl(Uri.parse(spotifyRedirectUri), scopes: scopes);

      if (!mounted) return;    
      ResponseUriWrapper responseUri = ResponseUriWrapper('default');

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AuthWebView(authUri.toString(), spotifyRedirectUri, responseUri)),
      );
      
      responseUri.addListener(() async {
        if (responseUri.getValue() != 'default') {
          // This code called after login_webview redirects to response Uri
          spt.SpotifyApi spotify = spt.SpotifyApi.fromAuthCodeGrant(grant, responseUri.getValue()!);
          spotifyProvider.setUser(await spotify.me.get());
          spotifyProvider.setSpotify(spotify);
          // Save credentials to storage
          await saveSpotifyCredentials(spotify);
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Signup2())
          );
        }
      });
    }
    // Read from stored values
    else {
      print("Used saved credentials flow");
      final spotifyCredentials = spt.SpotifyApiCredentials(
        storedValues["clientId"],
        storedValues["clientSecret"],
        accessToken: storedValues["accessToken"],
        refreshToken: storedValues["refreshToken"],
        scopes: ['user-read-email', 'user-library-read'],
        expiration: DateTime.parse(storedValues["expiration"].toString()),
      );
      
      spt.SpotifyApi spotify = spt.SpotifyApi(spotifyCredentials);
      spotifyProvider.setUser(await spotify.me.get());
      spotifyProvider.setSpotify(spotify);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Signup2())
      );
    }
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
            const Text(
              'Connect Spotify',
              style: connectButtonTextStyle,
            ),
          ]
        ),
      ),
    );
  }
  Widget _buildSignInButton() {
    return Container(
    margin: const EdgeInsets.only(top: 7.5, bottom: 10.0),
      height: 50,
      width: 270,
      child: ElevatedButton(
        onPressed: () => {
          Navigator.push(context,
            MaterialPageRoute(builder: (context) => Signin()),
          )
        },
        style: loginButtonStyle,
        child: const Text(
              'Sign in',
              style: connectButtonTextStyle,
            ),
        ),
    );
  }
  Widget _buildText(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
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
                      _buildText("Connect your Spotify account to get started."),
                      const SizedBox(height: 10.0),
                      Consumer<SpotifyProvider>(
                        builder: (context, spotifyProvider, child) => _buildSpotifyButton(spotifyProvider),
                      ),
                      const SizedBox(height: 10.0),
                      _buildText("Already have an account?"),
                      const SizedBox(height: 10.0),
                      _buildSignInButton(),
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