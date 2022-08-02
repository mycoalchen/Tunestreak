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

// Check if user already has signin credentials saved in local storage
Future<UserProviderParams> getSigninCredentials() async {
  const storage = FlutterSecureStorage();
  Map<String, String> storedValues = await storage.readAll();
  UserProviderParams params = UserProviderParams();
  // No credentials found
  if (storedValues.isEmpty) {
    return params;
  }
  // Credentials found
  else {
    print("Used saved credentials flow");
    try {
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
      print("Spotify set");
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
          print("Firebase info set");
          return params;
        },
      );
    } catch (e) {
      print(e);
      return params;
    }
  }
  return params;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  UserProviderParams params = await getSigninCredentials();
  print("params: ${params.id}");
  runApp(MyApp(params));
}

class MyApp extends StatelessWidget {
  final UserProviderParams params;
  const MyApp(this.params, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Params unset - no login info found
    if (params.id == "default") {
      print("No user info found");
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
    } else {
      print("User info found");
      return MultiProvider(
          providers: [
            ChangeNotifierProvider<UserProvider>(
                create: (context) => UserProvider(params)),
          ],
          child: Consumer<UserProvider>(
            builder: (context, userProvider, child) => const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: HomeScreen(),
            ),
          ));
    }
  }
}
