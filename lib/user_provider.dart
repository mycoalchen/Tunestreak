import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart' as spt;
import 'package:tunestreak/constants.dart';
import 'dart:math' as math;
import 'utilities.dart';

class UserProviderParams {
  late spt.SpotifyApi spotify;
  late spt.UserPublic spotifyUser;
  late String username, email, fbDocId, id;

  UserProviderParams();
}

class UserProvider extends ChangeNotifier {
  late spt.SpotifyApi? spotify;
  late spt.UserPublic? spotifyUser;

  late String? username;
  late String? email;
  late String? fbDocId;
  late String? id;

  var friendsList = List<TsUser>.empty(growable: true);
  Map<TsUser, bool> sendTo = {};

  late CircleAvatar profilePicture = defaultProfilePicture();

  UserProvider(UserProviderParams? params) {
    if (params != null) {
      spotify = params.spotify;
      spotifyUser = params.spotifyUser;
      username = params.username;
      email = params.email;
      fbDocId = params.fbDocId;
      id = params.id;
    }
  }

  static CircleAvatar defaultProfilePicture() {
    return const CircleAvatar(
        backgroundColor: circleColor,
        foregroundColor: darkGray,
        child: Icon(Icons.account_circle));
  }

  // Clears everything
  void signOut() {
    spotify = null;
    spotifyUser = null;
    username = null;
    email = null;
    fbDocId = null;
    id = null;
    friendsList = List<TsUser>.empty(growable: true);
    sendTo = {};
    profilePicture = defaultProfilePicture();
  }

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
    sendTo.clear();
    for (TsUser friend in friendsList) {
      sendTo[friend] = false;
    }
    notifyListeners();
  }

  void addFriend(TsUser newFriend) {
    friendsList.add(newFriend);
    sendTo[newFriend] = false;
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
      profilePicture = defaultProfilePicture();
    } else {
      profilePicture = newPp;
    }
    notifyListeners();
  }
}
