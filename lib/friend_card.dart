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
  final TsUser friend;
  final FirebaseFirestore firestore;
  // function to move page controller to Send Song tab
  final void Function() openSendSong;

  const StreakCard(this.friend, this.firestore, this.openSendSong, {Key? key})
      : super(key: key);

  @override
  State<StreakCard> createState() => _StreakCardState();
}

class _StreakCardState extends State<StreakCard> {
  // whether showSongsToSend is still being run
  bool isLoading = false;
  String streak = "...";

  void onSendSongTapped(context) {
    Map<TsUser, bool> sendTo = {};
    for (var friend
        in Provider.of<UserProvider>(context, listen: false).friendsList) {
      sendTo[friend] = false;
    }
    sendTo[widget.friend] = true;
    Provider.of<UserProvider>(context, listen: false).setSendTo(sendTo);
    widget.openSendSong();
  }

  Future<void> setStreak(BuildContext context) async {
    widget.firestore
        .collection("users")
        .doc(Provider.of<UserProvider>(context, listen: false).fbDocId)
        .collection("friends")
        .where("fbDocId", isEqualTo: widget.friend.fbDocId)
        .get()
        .then((value) {
      setState(() => streak = value.docs[0].get("streak").toString());
    });
  }

  String sendSongText() {
    if (isLoading) {
      return "Loading...";
    } else {
      return "Send song";
    }
  }

  void onOpenSongTapped(context) async {
    final friendsCollection = widget.firestore
        .collection("users")
        .doc(Provider.of<UserProvider>(context, listen: false).fbDocId)
        .collection("friends");
    String friendDocId = "";
    // Get the id of the friend's doc in the user's friend collection
    await friendsCollection
        .where("fbDocId", isEqualTo: widget.friend.fbDocId)
        .get()
        .then((QuerySnapshot res) async {
      if (res.docs.isEmpty) {
        print(
            "ERROR: Tried to open song from nonexistent user - friend_card.dart line 112");
        return;
      }
      if (res.docs.length > 1) {
        print(
            "ERROR: More than one friends have same firebase doc id - friend_card.dart line 117");
        return;
      }
      friendDocId = res.docs[0].id;
    });
    await friendsCollection.doc(friendDocId).get().then((value) async {
      List<String> songs = List.from(value.get("sentSongs"));
      await friendsCollection.doc(friendDocId).update({
        "sentSongs": FieldValue.arrayRemove([songs[0]]),
        // Update the streak
        "streak": FieldValue.increment(1),
      });
      // Play the song
      AudioPlayer audioPlayer = AudioPlayer();
      Track track = await Provider.of<UserProvider>(context, listen: false)
          .spotify
          .tracks
          .get(songs[0]);
      if (track.previewUrl != null) {
        audioPlayer.pause();
        await audioPlayer.setUrl(track.previewUrl!);
        audioPlayer.play();
      } else {
        print("ERROR: PREVIEW NULL");
      }
    });
    // Update the streak in the friend's doc of this user
    // Get the id of this user's doc in the friend's friends collection
    await widget.firestore
        .collection("users")
        .doc(widget.friend.fbDocId)
        .collection("friends")
        .where("fbDocId",
            isEqualTo:
                Provider.of<UserProvider>(context, listen: false).fbDocId)
        .get()
        .then((res) async {
      await widget.firestore
          .collection("users")
          .doc(widget.friend.fbDocId)
          .collection("friends")
          .doc(res.docs[0].id)
          .update({"streak": FieldValue.increment(1)});
    });
  }

  @override
  void initState() {
    super.initState();
    setStreak(context);
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
                    Text("${widget.friend.username} (${widget.friend.name})",
                        style: TextStyle(fontSize: 18.0)),
                    Text(streak, style: TextStyle(fontSize: 18.0)),
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
                      onPressed: () => onOpenSongTapped(context),
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
