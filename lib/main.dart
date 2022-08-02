// @dart=2.9

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:spotify/spotify.dart';
import 'package:tunestreak/home.dart';
import 'package:tunestreak/streaks.dart';
import 'package:tunestreak/user_provider.dart';
import 'firebase_options.dart';
import 'signup1.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  // Check if user already has signin credentials saved in local storage
  Future<UserProviderParams> getSigninCredentials() async {
    final storage = FlutterSecureStorage();
    Map<String, String> storedValues = await storage.readAll();
    // No credentials found
    if (storedValues.isEmpty) {
      return null;
    }
    // Credentials found
    else {
      print("Used saved credentials flow");
      try {
        UserProviderParams params = UserProviderParams();
        // Get Spotify credentials
        final spotifyCredentials = SpotifyApiCredentials(
          storedValues["tunestreak_clientId"],
          storedValues["tunestreak_clientSecret"],
          accessToken: storedValues["tunestreak_accessToken"],
          refreshToken: storedValues["tunestreak_refreshToken"],
          scopes:
              List<String>.from(jsonDecode(storedValues["tunestreak_scopes"])),
          expiration:
              DateTime.parse(storedValues["tunestreak_expiration"].toString()),
        );
        params.spotify = SpotifyApi(spotifyCredentials);
        params.spotifyUser = await params.spotify.me.get();
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        await firestore
            .collection("users")
            .doc(storedValues["tunestreak_fbDocId"])
            .get()
            .then(
          (doc) {
            params.username = doc.get("username");
            params.email = doc.get("email");
            params.fbDocId = doc.id;
            params.id = doc.get("id");
            return params;
          },
        );
      } catch (e) {
        print(e);
        return null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProviderParams>(
        future: getSigninCredentials(),
        builder: (context, AsyncSnapshot<UserProviderParams> snapshot) {
          if (snapshot.hasData) {
            return MultiProvider(
                providers: [
                  ChangeNotifierProvider<UserProvider>(
                      create: (context) => UserProvider(snapshot.data)),
                ],
                child: Consumer<UserProvider>(
                  builder: (context, userProvider, child) => const MaterialApp(
                    debugShowCheckedModeBanner: false,
                    home: HomeScreen(),
                  ),
                ));
          } else {
            return MultiProvider(
                providers: [
                  ChangeNotifierProvider<UserProvider>(
                      create: (context) => UserProvider(null)),
                ],
                child: Consumer<UserProvider>(
                  builder: (context, userProvider, child) => MaterialApp(
                    debugShowCheckedModeBanner: false,
                    home: Signup1(),
                  ),
                ));
          }
        });
  }
}
