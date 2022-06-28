import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart' as spt;

class SpotifyProvider extends ChangeNotifier {
  late spt.SpotifyApi spotify;
  late spt.UserPublic user;
  void setSpotify(spt.SpotifyApi newSpotify) {
    spotify = newSpotify;
    notifyListeners();
  }
  void setUser(spt.UserPublic newUser) {
    user = newUser;
    notifyListeners();
  }
}