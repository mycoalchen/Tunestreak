import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:spotify/spotify.dart';
import 'package:just_audio/just_audio.dart';
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
  Future<void> onAddFriendTapped() async {
    widget.firestore
        .collection("users")
        .doc(Provider.of<UserProvider>(context, listen: false).fbDocId)
        .collection("friends")
        .add({"fbDocId": widget.fbDocId, "streak": 0});
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
                onPressed: onAddFriendTapped,
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
  Future<void> onTapped() async {
    UserProvider up = Provider.of<UserProvider>(context, listen: false);
    // Track b3d = await up.spotify.tracks
    //     .get('1bxZpUVoYnwDzR42vGpzlA?si=0aaa35a0b22c4b19');
    // final player = AudioPlayer();
    // if (b3d.previewUrl != null) {
    //   final duration = await player.setUrl(b3d.previewUrl!);
    //   player.play();
    // } else {
    //   print("ERROR: PREVIEW NULL");
    // }
    List<PlayHistory> rp =
        (await up.spotify.me.recentlyPlayed()).toList() as List<PlayHistory>;
    for (PlayHistory p in rp.getRange(0, 8)) {
      print(p.track!.name!);
    }
    // final topTracks = await up.spotify.me.topTracks();
    // final topTrackIds = topTracks.take(8).map((track) => track.id).toList();
    // for (int i = 0; i < topTrackIds.length; i++) {
    //   Track track = await up.spotify.tracks.get(topTrackIds[i]!);
    //   print(track.name);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.fromLTRB(30, 10, 30, 0),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
              bottom: BorderSide(
            color: circleColor,
            width: 2.0,
          )),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("${widget.username} (${widget.name})",
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
                      onPressed: onTapped,
                      child: const Text("Send song",
                          style: TextStyle(fontSize: 19.0)),
                    )
                  ],
                ),
              )
            ]));
  }
}
