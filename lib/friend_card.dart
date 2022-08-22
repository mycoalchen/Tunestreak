import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:flutter/src/widgets/image.dart'
    as fImage; // Flutter-defined Image; prevent conflict with Spotify-defined image
import 'user_provider.dart';
import 'utilities.dart';
import 'constants.dart';

class AddFriendCard extends StatefulWidget {
  final TsUser user;
  final FirebaseFirestore firestore;
  const AddFriendCard(this.user, this.firestore);

  @override
  State<AddFriendCard> createState() => _AddFriendCardState();
}

class _AddFriendCardState extends State<AddFriendCard> {
  CircleAvatar profilePicture = UserProvider.defaultProfilePicture();
  String addFriendText = "Add Friend";

  // Determine if button should say "Add Friend" or "Added"
  Future<void> setCanAddFriend() async {
    // Check this user's sentFriendRequestsCollection
  }

  Future<void> onAddFriendTapped() async {
    if (Provider.of<UserProvider>(context, listen: false)
        .friendsList
        .contains(widget.user)) {
      return;
    }
    final moments =
        await widget.firestore.collection("moments").add({"songs": []});
    if (!mounted) return;
    // Add friend in this user's friends collection
    widget.firestore
        .collection("users")
        .doc(Provider.of<UserProvider>(context, listen: false).fbDocId)
        .collection("friends")
        .add({
      "fbDocId": widget.user.fbDocId,
      "streak": 0,
      'sentSongs': [],
      'moments': moments.id
    });
    // Add this user in friend's friends collection
    widget.firestore
        .collection("users")
        .doc(widget.user.fbDocId)
        .collection("friends")
        .add({
      "fbDocId": Provider.of<UserProvider>(context, listen: false).fbDocId,
      "streak": 0,
      "sentSongs": [],
      "moments": moments.id
    });
    Provider.of<UserProvider>(context, listen: false).addFriend(widget.user);
    setState(() {
      addFriendText = "Added";
    });
  }

  Future<void> setProfilePicture() async {
    final storageRef = FirebaseStorage.instance.ref();
    final profilePictureRef =
        storageRef.child("profilePictures/${widget.user.id}");
    var url = await profilePictureRef.getDownloadURL();
    if (!mounted) return;
    setState(() {
      profilePicture =
          CircleAvatar(backgroundImage: fImage.Image.network(url).image);
    });
  }

  @override
  void initState() {
    super.initState();
    setProfilePicture();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
        height: 75,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
              bottom: BorderSide(
            color: circleColor,
            width: 2.0,
          )),
        ),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              profilePicture,
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(widget.user.username,
                        style: TextStyle(fontSize: 18.0)),
                    Text(widget.user.name, style: TextStyle(fontSize: 14.0)),
                  ]),
              TextButton(
                style: addFriendButtonStyle,
                onPressed: onAddFriendTapped,
                child: Text(addFriendText, style: TextStyle(fontSize: 19.0)),
              )
            ]));
  }
}

class RemoveFriendCard extends StatefulWidget {
  final TsUser user;
  final FirebaseFirestore firestore;
  const RemoveFriendCard(this.user, this.firestore);

  @override
  State<RemoveFriendCard> createState() => _RemoveFriendCardState();
}

class _RemoveFriendCardState extends State<RemoveFriendCard> {
  CircleAvatar profilePicture = UserProvider.defaultProfilePicture();

  Future<void> onRemoveFriendTapped() async {}

  Future<void> setProfilePicture() async {
    final storageRef = FirebaseStorage.instance.ref();
    final profilePictureRef =
        storageRef.child("profilePictures/${widget.user.id}");
    var url = await profilePictureRef.getDownloadURL();
    if (!mounted) return;
    setState(() {
      profilePicture =
          CircleAvatar(backgroundImage: fImage.Image.network(url).image);
    });
  }

  @override
  void initState() {
    super.initState();
    setProfilePicture();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
        height: 75,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
              bottom: BorderSide(
            color: circleColor,
            width: 2.0,
          )),
        ),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              profilePicture,
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(widget.user.username,
                        style: TextStyle(fontSize: 18.0)),
                    Text(widget.user.name, style: TextStyle(fontSize: 14.0)),
                  ]),
              TextButton(
                style: removeFriendButtonStyle,
                onPressed: onRemoveFriendTapped,
                child: Text("Remove friend", style: TextStyle(fontSize: 19.0)),
              )
            ]));
  }
}
