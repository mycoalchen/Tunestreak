import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart' as spt;
import 'dart:math' as math;
import 'utilities.dart';

class UserProvider extends ChangeNotifier {
  late spt.SpotifyApi spotify;
  late spt.UserPublic spotifyUser;

  late String username;
  late String email;
  late String fbDocId;
  late String id;

  var friendsList = List<TsUser>.empty(growable: true);
  Map<TsUser, bool> sendTo = {};

  late CircleAvatar profilePicture = CircleAvatar(
    backgroundColor:
        Colors.primaries[math.Random().nextInt(Colors.primaries.length)],
    child: Text(username.substring(0, 2)),
  );

  void setId(String newId) {
    id = newId;
    notifyListeners();
  }

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

  void setFriendsList(List<TsUser> newFriendsList) {
    friendsList = newFriendsList;
    notifyListeners();
  }

  void addFriend(TsUser newFriend) {
    friendsList.add(newFriend);
    notifyListeners();
  }

  void setSendTo(Map<TsUser, bool> newSendTo) {
    sendTo = newSendTo;
    notifyListeners();
  }

  void updateSendTo(TsUser friend, bool send) {
    sendTo[friend] = send;
    notifyListeners();
  }

  void setProfilePicture(CircleAvatar? newPp) {
    if (newPp == null) {
      profilePicture = CircleAvatar(
        backgroundColor:
            Colors.primaries[math.Random().nextInt(Colors.primaries.length)],
        child: Text(username.substring(0, 2)),
      );
    } else {
      profilePicture = newPp;
    }
    notifyListeners();
  }
}
