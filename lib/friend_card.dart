import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:spotify/spotify.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tunestreak/send_song.dart';
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
  Future<void> onAddFriendTapped() async {
    widget.firestore
        .collection("users")
        .doc(Provider.of<UserProvider>(context, listen: false).fbDocId)
        .collection("friends")
        .add({"fbDocId": widget.user.fbDocId, "streak": 0, 'sentSongs': []});
    Provider.of<UserProvider>(context, listen: false).addFriend(widget.user);
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
                    Text(widget.user.username,
                        style: TextStyle(fontSize: 18.0)),
                    Text(widget.user.name, style: TextStyle(fontSize: 14.0)),
                  ]),
              TextButton(
                style: addFriendButtonStyle,
                child:
                    const Text("Add friend", style: TextStyle(fontSize: 19.0)),
                onPressed: onAddFriendTapped,
              )
            ]));
  }
}

class StreakCard extends StatefulWidget {
  final TsUser user;
  final FirebaseFirestore firestore;
  // function to move page controller to Send Song tab
  final void Function() openSendSong;

  const StreakCard(this.user, this.firestore, this.openSendSong);

  @override
  State<StreakCard> createState() => _StreakCardState();
}

class _StreakCardState extends State<StreakCard> {
  // whether showSongsToSend is still being run
  bool isLoading = false;

  void onSendSongTapped(context) {
    Map<TsUser, bool> sendTo = {};
    for (var friend
        in Provider.of<UserProvider>(context, listen: false).friendsList) {
      sendTo[friend] = false;
    }
    sendTo[widget.user] = true;
    Provider.of<UserProvider>(context, listen: false).setSendTo(sendTo);
    widget.openSendSong();
  }

  String sendSongText() {
    if (isLoading) {
      return "Loading...";
    } else {
      return "Send song";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.fromLTRB(30, 10, 30, 0),
        decoration: userCardDecoration,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("${widget.user.username} (${widget.user.name})",
                        style: TextStyle(fontSize: 18.0)),
                    Text("5", style: TextStyle(fontSize: 18.0)),
                  ]),
              Container(
                padding: EdgeInsets.only(top: 5.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      style: addFriendButtonStyle.copyWith(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(pink)),
                      onPressed: () => {},
                      child: const Text("Open song",
                          style: TextStyle(fontSize: 19.0)),
                    ),
                    TextButton(
                      style: addFriendButtonStyle,
                      onPressed: () => onSendSongTapped(context),
                      child: Text(sendSongText(),
                          style: const TextStyle(fontSize: 19.0)),
                    )
                  ],
                ),
              )
            ]));
  }
}
