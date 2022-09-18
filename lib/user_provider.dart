import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart' as spt;
import 'package:tunestreak/constants.dart';
import 'utilities.dart';

class UserProviderParams {
  late spt.SpotifyApi spotify;
  late spt.UserPublic spotifyUser;
  late String username, fbDocId;
  String id = "default"; // This means the user params were not set/found
  UserProviderParams();
}

class UserProvider extends ChangeNotifier {
  late spt.SpotifyApi? spotify;
  late spt.UserPublic? spotifyUser;

  late String? username;
  late String? fbDocId;
  late String? id;

  var friendsList = List<TsUser>.empty(growable: true);
  Map<TsUser, bool> sendTo = {};
  Map<TsUser, CircleAvatar> friendPps = {};
  List<String>? sentFriendRequests;
  List<String>? receivedFriendRequests;

  late CircleAvatar profilePicture = defaultProfilePicture();

  void setParams(UserProviderParams params) {
    spotify = params.spotify;
    spotifyUser = params.spotifyUser;
    username = params.username;
    fbDocId = params.fbDocId;
    id = params.id;
    notifyListeners();
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
    fbDocId = null;
    id = null;
    friendsList = List<TsUser>.empty(growable: true);
    sendTo = {};
    profilePicture = defaultProfilePicture();
    sentFriendRequests = [];
    receivedFriendRequests = [];
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

  void setUser(String newUsername, String newFbDocId) {
    username = newUsername;
    fbDocId = newFbDocId;
    notifyListeners();
  }

  // Assumes fbDocId is already set - sets friendsList, sendTo, and friendPps
  Future<void> fetchAndSetFriends() async {
    // Fetch and set friends list from firestore
    final users = FirebaseFirestore.instance.collection("users");
    await users
        .doc(fbDocId)
        .collection('friends')
        .get()
        .then((QuerySnapshot res) async {
      for (QueryDocumentSnapshot<Object?> doc in res.docs) {
        await users
            .doc(doc.get("fbDocId"))
            .get()
            .then((DocumentSnapshot friend) {
          print("Adding friend  ${friend.id}: ${friend.get("name")}");
          friendsList.add(TsUser(friend.get("name"), friend.get("username"),
              friend.id, friend.get("id")));
        });
      }
    });
    print("Fetched and set friends list");
    // Set sendTo
    for (TsUser friend in friendsList) {
      sendTo[friend] = false;
      // Get profile picture from Firebase Storage
      try {
        final ppRef =
            await FirebaseStorage.instance.ref('profilePictures/${friend.id}');
        final ppData = await ppRef.getData(1048576);
        final ppImage = MemoryImage(ppData!);
        friendPps[friend] = CircleAvatar(backgroundImage: ppImage);
      } catch (e) {
        friendPps[friend] = defaultProfilePicture();
      }
    }
    notifyListeners();
  }

  Future<void> fetchAndSetProfilePicutre() async {
    final doc = await FirebaseFirestore.instance.doc("users/$fbDocId").get();
    if (doc.get("ppSet")) {
      // Get profile picture from Firebase Storage - first need user id
      final ppRef = FirebaseStorage.instance.ref().child("profilePictures/$id");
      try {
        final ppData = await ppRef.getData(1048576);
        final ppImage = MemoryImage(ppData!);
        // Set profile picture in provider
        profilePicture = CircleAvatar(backgroundImage: ppImage);
      } on FirebaseException catch (e) {
        print(
            "Exception when fetching profile picture: ${e.code}: ${e.message}");
      }
    }
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

  void setSentFriendRequests(List<String> newFr) {
    sentFriendRequests = newFr;
    notifyListeners();
  }

  void setReceivedFriendRequests(List<String> newFr) {
    receivedFriendRequests = newFr;
    notifyListeners();
  }
}
