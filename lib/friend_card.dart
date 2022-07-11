import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';
import 'constants.dart';

class AddFriendCard extends StatefulWidget {
  final String name, username, fbDocId;
  final FirebaseFirestore firestore;
  const AddFriendCard(this.name, this.username, this.fbDocId, this.firestore);

  @override
  State<AddFriendCard> createState() => _AddFriendCardState();
}

class _AddFriendCardState extends State<AddFriendCard> {
  void onTapped() {
    print("Tapped");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
        height: 60,
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
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(widget.username, style: TextStyle(fontSize: 18.0)),
                    Text(widget.name, style: TextStyle(fontSize: 14.0)),
                  ]),
              TextButton(
                style: addFriendButtonStyle,
                child:
                    const Text("Add friend", style: TextStyle(fontSize: 19.0)),
                onPressed: () async {
                  widget.firestore
                      .collection("users")
                      .doc(Provider.of<UserProvider>(context, listen: false)
                          .fbDocId)
                      .collection("friends")
                      .add({"fbDocId": widget.fbDocId, "streak": 0});
                },
              )
            ]));
  }
}

class StreakCard extends StatefulWidget {
  final String name, username, fbDocId;
  final FirebaseFirestore firestore;
  const StreakCard(this.name, this.username, this.fbDocId, this.firestore);

  @override
  State<StreakCard> createState() => _StreakCardState();
}

class _StreakCardState extends State<StreakCard> {
  void onTapped() {
    print("Tapped");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
        height: 60,
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
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(widget.username, style: TextStyle(fontSize: 18.0)),
                    Text(widget.name, style: TextStyle(fontSize: 14.0)),
                  ]),
              TextButton(
                style: addFriendButtonStyle,
                child:
                    const Text("Send song", style: TextStyle(fontSize: 19.0)),
                onPressed: () async {
                  widget.firestore
                      .collection("users")
                      .doc(Provider.of<UserProvider>(context, listen: false)
                          .fbDocId)
                      .collection("friends")
                      .add({"fbDocId": widget.fbDocId, "streak": 0});
                },
              )
            ]));
  }
}
