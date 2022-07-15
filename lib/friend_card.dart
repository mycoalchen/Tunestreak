import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:flutter/src/widgets/image.dart'
    as fImage; // Flutter-defined Image; prevent conflict with Spotify-defined image
import 'package:spotify/spotify.dart';
import 'package:just_audio/just_audio.dart';
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
        .add({"fbDocId": widget.user.fbDocId, "streak": 0});
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
  const StreakCard(this.user, this.firestore);

  @override
  State<StreakCard> createState() => _StreakCardState();
}

class _StreakCardState extends State<StreakCard> {
  // whether showSongsToSend is still being run
  bool isLoading = false;
  List<bool> currentlyPlaying = List<bool>.filled(8, false);

  Future<void> onSendSongTapped() async {
    UserProvider up = Provider.of<UserProvider>(context, listen: false);
    List<PlayHistory> rp =
        (await up.spotify.me.recentlyPlayed()).toList() as List<PlayHistory>;
    for (PlayHistory p in rp.getRange(0, 8)) {
      print(p.track!.name!);
    }
  }

  // trackIndex is the index of this track in recentlyPlayed
  Future<void> onPlaySongTapped(String trackId, int trackIndex) async {
    Track track = await Provider.of<UserProvider>(context, listen: false)
        .spotify
        .tracks
        .get(trackId);
    final player = AudioPlayer();
    if (track.previewUrl != null) {
      final duration = await player.setUrl(track.previewUrl!);
      player.play();
      setState(() {
        currentlyPlaying[trackIndex] = true;
      });
    } else {
      print("ERROR: PREVIEW NULL");
    }
  }

  // Return either a play or pause icon
  IconData playPause(int index) {
    if (currentlyPlaying[index]) {
      return Icons.pause;
    } else {
      return Icons.play_arrow;
    }
  }

  Future<void> showSongsToSend(BuildContext context) async {
    setState(() => isLoading = true);
    // Get recently played songs from Spotify API
    List<Widget> songRows = List<Widget>.empty(growable: true);
    UserProvider up = Provider.of<UserProvider>(context, listen: false);
    await up.spotify.me.recentlyPlayed(limit: 8).then((value) async {
      List<PlayHistory> recentlyPlayed = value.toList();
      for (int i = 0; i < recentlyPlayed.length; i++) {
        Track track = await up.spotify.tracks.get(recentlyPlayed[i].track!.id!);
        fImage.Image trackImage =
            fImage.Image.network(track.album!.images![0].url!);
        // Add a row for each song
        songRows.add(
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                          height: 50,
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
                            Text(clipString(track.name!, 23),
                                style: songInfoTextStyle),
                            Text(clipString(track.artists![0].name!, 18),
                                style: songInfoTextStyle),
                          ],
                        ),
                      ),
                    ]),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                RawMaterialButton(
                  constraints: BoxConstraints.tight(const Size(38, 38)),
                  onPressed: () =>
                      onPlaySongTapped(recentlyPlayed[i].track!.id!, i),
                  elevation: 2.0,
                  fillColor: spotifyGreen,
                  shape: const CircleBorder(),
                  child: Icon(
                    playPause(i),
                    size: 26.0,
                    color: Colors.black,
                  ),
                ),
                RawMaterialButton(
                  constraints: BoxConstraints.tight(const Size(38, 38)),
                  onPressed: () {},
                  elevation: 2.0,
                  fillColor: teal,
                  shape: const CircleBorder(),
                  child:
                      const Icon(Icons.send, size: 25.0, color: Colors.black),
                ),
              ])
            ],
          ),
        );
      }
    });
    setState(() => isLoading = false);
    // This allows the modal bottom sheet to listen to state changes
    final stateNotifier = ValueNotifier(currentlyPlaying);
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return ValueListenableBuilder<List<bool>>(
            valueListenable: stateNotifier,
            builder: (context, snapshot, child) {
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
            },
          );
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
