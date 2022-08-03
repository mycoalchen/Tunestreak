import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:spotify/spotify.dart';
import 'package:tunestreak/home.dart';
import 'package:tunestreak/user_provider.dart';
import 'firebase_options.dart';
import 'signup1.dart';

class HomeLoading extends StatefulWidget {
  const HomeLoading({Key? key}) : super(key: key);

  @override
  State<HomeLoading> createState() => _HomeLoadingState();
}

class _HomeLoadingState extends State<HomeLoading> {
  // Check if user already has signin credentials saved in local storage
  Future<void> setSigninCredentials() async {
    const storage = FlutterSecureStorage();
    Map<String, String> storedValues = await storage.readAll();
    UserProviderParams params = UserProviderParams();
    // No credentials found
    if (storedValues.isEmpty) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Signup1()),
      );
      return;
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
              List<String>.from(jsonDecode(storedValues["tunestreak_scopes"]!)),
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
          (doc) async {
            params.username = doc.get("username");
            params.email = doc.get("email");
            params.fbDocId = doc.id;
            params.id = doc.get("id");
            print("Firebase info set");
            Provider.of<UserProvider>(context, listen: false).setParams(params);
            // Set friendsList and sendTo
            await Provider.of<UserProvider>(context, listen: false)
                .fetchAndSetFriendsListAndSendTo();
            // Check if this user has a profile picture
            if (!mounted) return;
            await Provider.of<UserProvider>(context, listen: false)
                .fetchAndSetProfilePicutre();
            if (!mounted) return;
            Navigator.pop(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const HomeScreen()));
            return;
          },
        );
      } catch (e) {
        print(e);
        if (!mounted) return;
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Signup1()),
        );
        return;
      }
    }
    return;
  }

  @override
  void initState() {
    super.initState();
    setSigninCredentials();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child:
          Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
        CircularProgressIndicator(),
        SizedBox(height: 10),
        Text(
          "Fetching local data...",
          style: TextStyle(fontSize: 14, color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ]),
    );
  }
}
