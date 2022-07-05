import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/io.dart';
import 'package:spotify/spotify.dart' as spt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'constants.dart';
import 'config.dart';
import 'signup2.dart';
import 'signin.dart';
import 'home.dart';
import 'user_provider.dart';
import 'user_provider.dart';
import 'login_webview.dart';


class Signup1 extends StatefulWidget {
  @override
  _Signup1State createState() => _Signup1State();
}

class _Signup1State extends State<Signup1> {
  var authUri;
  final storage = const FlutterSecureStorage();
  final firestore = FirebaseFirestore.instance;

  // Save Spotify API Credentials to FlutterSecureStorage
  Future<void> saveSpotifyCredentials(spt.SpotifyApi spotifyApi, String username) async {
    spt.SpotifyApiCredentials credentials = await spotifyApi.getCredentials();
    await storage.write(key: "${username}_accessToken", value: credentials.accessToken);
    await storage.write(key: "${username}_refreshToken", value: credentials.refreshToken);
    await storage.write(key: "${username}_expiration", value: credentials.expiration.toString());
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
  Future<void> _handleSpotifyButtonPress(BuildContext context, UserProvider userProvider) async {
    // Map<String, String> storedValues = await storage.readAll();
    // No stored values - need to do authentication-code flow
    // if (storedValues.isEmpty) {

    // Set SpotifyApi object
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
        userProvider.setSpotifyUser(await spotify.me.get());
        userProvider.setSpotify(spotify);

        // Check if this is a new or returning user
        // Get the Firestore user object with this Spotify account
        final spt.UserPublic su = await spotify.me.get();
        firestore.collection("users").where("sptId", isEqualTo: su.id).get().then(
          (QuerySnapshot res) async {
            if (res.docs.isEmpty) { // New user
              print("No user found with Spotify id ${su.id}");
              if (!mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Signup2())
              );
            } else { // Returning user - set User in UserProvider
              final fbUserObject = res.docs[0];
              // Set email, username, and firebase docId
              Provider.of<UserProvider>(context, listen: false).setUser(
                fbUserObject.get("username"),
                fbUserObject.get("email"),
                fbUserObject.id,
              );
              // Set id
              Provider.of<UserProvider>(context, listen: false).setId(
                fbUserObject.get("id"),
              );
              // Get profile picture from Firebase Storage - first need user id
              final String id = Provider.of<UserProvider>(context, listen: false).id;
              final ppRef = FirebaseStorage.instance.ref().child(
                "profilePictures/$id");
              try {
                const oneMegabyte = 1024 * 1024;
                final Uint8List? ppData = await ppRef.getData(oneMegabyte);
                final ppImage = MemoryImage(ppData!);
                if (!mounted) return;
                // Set profile picture in provider
                Provider.of<UserProvider>(context, listen: false).setProfilePicture(CircleAvatar(backgroundImage: ppImage));
              } on FirebaseException catch (e) {
                print(e);
              }

              if (!mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen())
              );
            }
          },
          onError: (e) {
            print("Error fetching Spotify user: $e");
            return;
          }
        );
      }
    });
    // }
    // Read from stored values
    // else {
    //   print("Used saved credentials flow");
    //   final spotifyCredentials = spt.SpotifyApiCredentials(
    //     storedValues["clientId"],
    //     storedValues["clientSecret"],
    //     accessToken: storedValues["accessToken"],
    //     refreshToken: storedValues["refreshToken"],
    //     scopes: ['user-read-email', 'user-library-read'],
    //     expiration: DateTime.parse(storedValues["expiration"].toString()),
    //   );
    //   spt.SpotifyApi spotify = spt.SpotifyApi(spotifyCredentials);
    //   spotifyProvider.setUser(await spotify.me.get());
    //   spotifyProvider.setSpotify(spotify);
    //   if (!mounted) return;
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(builder: (context) => Signup2())
    //   );
    // }
  }

  Widget _buildSpotifyButton(UserProvider userProvider) {
    return Container(
    margin: const EdgeInsets.only(top: 7.5, bottom: 10.0),
      height: 50,
      width: 270,
      child: ElevatedButton(
        onPressed: () => {
          _handleSpotifyButtonPress(context, userProvider)
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
                      Consumer<UserProvider>(
                        builder: (context, userProvider, child) => _buildSpotifyButton(userProvider),
                      ),
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