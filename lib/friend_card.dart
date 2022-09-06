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

// Handles "Add Friend" (Send friend request) and "Accept" functionality
class AddFriendCard extends StatefulWidget {
  final TsUser user;
  final FirebaseFirestore firestore;
  final String type; // Can be "Add Friend", "Requested", or "Accept"
  const AddFriendCard(this.user, this.firestore, this.type);

  @override
  State<AddFriendCard> createState() => _AddFriendCardState();
}

class _AddFriendCardState extends State<AddFriendCard> {
  CircleAvatar profilePicture = UserProvider.defaultProfilePicture();
  late String addFriendText;

  Future<void> onAddFriendTapped() async {
    // Send a friend request to the friend
    if (addFriendText == "Requested") return;
    if (addFriendText == "Add Friend") {
      final up = Provider.of<UserProvider>(context, listen: false);
      final sfr = up.sentFriendRequests;
      if (sfr == null) return;
      // Add friend in this user's sentFriendRequests collection
      widget.firestore.collection("users").doc(up.fbDocId).update({
        "sentFriendRequests": FieldValue.arrayUnion([widget.user.fbDocId])
      });
      // Add this user in friend's receivedFriendRequests collection
      widget.firestore.collection("users").doc(widget.user.fbDocId).update({
        "receivedFriendRequests": FieldValue.arrayUnion([up.fbDocId])
      });
      // Add this friend to the UserProvider's sentFriendsRequests list
      sfr.add(widget.user.fbDocId);
      up.setSentFriendRequests(sfr);
      setState(() => addFriendText = "Requested");
    } else if (addFriendText == "Accept") {
      final up = Provider.of<UserProvider>(context, listen: false);
      // Add friend in this user's friends collection
      final moments =
          await widget.firestore.collection("moments").add({"songs": []});
      if (!mounted) return;
      await widget.firestore
          .collection("users")
          .doc(up.fbDocId)
          .collection("friends")
          .add({
        "fbDocId": widget.user.fbDocId,
        "streak": 0,
        'sentSongs': [],
        'moments': moments.id
      });
      // Add this user in friend's friends collection
      if (!mounted) return;
      await widget.firestore
          .collection("users")
          .doc(widget.user.fbDocId)
          .collection("friends")
          .add({
        "fbDocId": up.fbDocId,
        "streak": 0,
        "sentSongs": [],
        "moments": moments.id
      });
      // Remove this friend request in this user's receivedFriendRequests array
      if (!mounted) return;
      await widget.firestore.collection("users").doc(up.fbDocId).update({
        "receivedFriendRequests": FieldValue.arrayRemove([widget.user.fbDocId])
      });
      // Remove this friend request in the friend's sentFriendRequests array
      if (!mounted) return;
      await widget.firestore
          .collection("users")
          .doc(widget.user.fbDocId)
          .update({
        "sentFriendRequests": FieldValue.arrayRemove([up.fbDocId])
      });
      if (!mounted) return;
      up.addFriend(widget.user);
      setState(() => addFriendText = "Added");
    }
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
    addFriendText = widget.type;
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  profilePicture,
                  const SizedBox(width: 12),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(widget.user.username,
                            style: TextStyle(fontSize: 18.0)),
                        Text(widget.user.name,
                            style: TextStyle(fontSize: 14.0)),
                      ]),
                ],
              ),
              TextButton(
                style: addFriendButtonStyle,
                onPressed: onAddFriendTapped,
                child: Text(addFriendText, style: TextStyle(fontSize: 19.0)),
              )
            ]));
  }
}
