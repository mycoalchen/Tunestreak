import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart' as spt;

class UserProvider extends ChangeNotifier {
  late spt.SpotifyApi spotify;
  late spt.UserPublic spotifyUser;
  
  late String username;
  late String email;
  late String fbDocId;

  void setSpotify(spt.SpotifyApi newSpotify) {
    spotify = newSpotify;
    notifyListeners();
  }
  void setSpotifyUser(spt.UserPublic newUser) {
    spotifyUser = newUser;
    notifyListeners();
  }
  void setUser(String newUsername, String newEmail, String newFbDocId) {
    username = newUsername;
    email = newEmail;
    fbDocId = newFbDocId;
    notifyListeners();
  }
}