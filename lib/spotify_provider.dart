import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart' as spt;

class SpotifyProvider extends ChangeNotifier {
  late spt.SpotifyApi spotify;
  void setSpotify(spt.SpotifyApi newSpotify) {
    spotify = newSpotify;
    notifyListeners();
  }
}