import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:flutter/src/widgets/image.dart'
    as fImage; // Flutter-defined Image; prevent conflict with Spotify-defined image
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
  // whether showSongsToSend is still being run
  bool isLoading = false;

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
  }

  // clips a string to length with "..." at the end if clipped
  String clipString(String string, int length) {
    if (string.length > length) {
      return string.substring(0, length) + "...";
    } else
      return string;
  }

  Future<void> showSongsToSend(BuildContext context) async {
    setState(() => isLoading = true);
    // Get recently played songs from Spotify API
    List<Row> songRows = List<Row>.empty(growable: true);
    UserProvider up = Provider.of<UserProvider>(context, listen: false);
    await up.spotify.me.recentlyPlayed(limit: 8).then((value) async {
      List<PlayHistory> recentlyPlayed = value.toList();
      for (PlayHistory ph in recentlyPlayed) {
        Track track = await up.spotify.tracks.get(ph.track!.id!);
        fImage.Image trackImage =
            fImage.Image.network(track.album!.images![0].url!);
        // Add a row for each song
        songRows.add(Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
                padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                height: 60,
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: trackImage,
                )),
            Container(
              padding: const EdgeInsets.all(8),
              height: 60,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(clipString(track.name!, 25), style: songInfoTextStyle),
                  Text(clipString(track.artists![0].name!, 25),
                      style: songInfoTextStyle),
                ],
              ),
            )
          ],
        ));
      }
    });
    setState(() => isLoading = false);
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
              height: 500,
              margin: const EdgeInsets.fromLTRB(6, 0, 6, 12),
              decoration: BoxDecoration(
                color: darkGray,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.builder(
                  itemCount: 8,
                  itemBuilder: (BuildContext context, int index) {
                    return songRows[index];
                  }));
        });
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
                      onPressed: () => showSongsToSend(context),
                      child: Text(sendSongText(),
                          style: const TextStyle(fontSize: 19.0)),
                    )
                  ],
                ),
              )
            ]));
  }
}
