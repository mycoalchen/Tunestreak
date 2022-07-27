import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:spotify/spotify.dart';
import 'package:flutter/src/widgets/image.dart'
    as fImage; // Flutter-defined Image; prevent conflict with Spotify-defined image
import 'add_friends.dart';
import 'user_provider.dart';
import 'utilities.dart';
import 'constants.dart';

class SendSongPage extends StatefulWidget {
  const SendSongPage({Key? key}) : super(key: key);

  @override
  State<SendSongPage> createState() => SendSongPageState();
}

class SendSongPageState extends State<SendSongPage> {
  late List<TsUser> friendsList;
  int songsToLoad = 8;
  int songsLoaded = 0;
  List<bool> currentlyPlaying = List<bool>.filled(8, false);
  List<Track> recentlyPlayed = List<Track>.empty(growable: true);
  static AudioPlayer audioPlayer = AudioPlayer();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<String> previewUrls = List<String>.empty(growable: true);

  // Return either a play or pause icon
  IconData playPause(int index) {
    if (currentlyPlaying[index]) {
      return Icons.pause;
    } else {
      return Icons.play_arrow;
    }
  }

  // Set state of this song to playing, start playing preview
  // trackIndex is the index of this track in recentlyPlayed
  Future<void> onPlaySongTapped(String trackId, int trackIndex) async {
    if (!currentlyPlaying[trackIndex]) {
      // Pause all other players
      for (int i = 0; i < recentlyPlayed.length; i++) {
        setState(() => currentlyPlaying[i] = false);
      }
      Track track = await Provider.of<UserProvider>(context, listen: false)
          .spotify
          .tracks
          .get(trackId);
      setState(() => currentlyPlaying[trackIndex] = true);
      audioPlayer.pause();
      await audioPlayer.setUrl(previewUrls[trackIndex]);
      audioPlayer.play();
    } else {
      audioPlayer.pause();
      setState(() {
        currentlyPlaying[trackIndex] = false;
      });
    }
  }

  // Gets recently played songs from Spotify API, sets songRows state to those songs
  Future<void> loadSongs() async {
    // Get recently played songs from Spotify API
    List<Track> songs = List<Track>.empty(growable: true);
    List<String> preUrls = List<String>.empty(growable: true);
    UserProvider up = Provider.of<UserProvider>(context, listen: false);
    await up.spotify.me.recentlyPlayed(limit: songsToLoad).then((value) async {
      List<PlayHistory> songList = value.toList();
      for (int i = 0; i < songList.length; i++) {
        Track track = await up.spotify.tracks.get(songList[i].track!.id!);
        songs.add(track);
        if (!mounted) return;
        // Get preview url - if none, it will not be rendered
        if (track.previewUrl != null) {
          preUrls.add(track.previewUrl!);
        } else {
          preUrls.add("");
        }
        setState(() {
          recentlyPlayed = songs;
          previewUrls = preUrls;
          songsLoaded += 1;
        });
      }
    });
  }

  // Sends the song at trackIndex to the currently selected friends
  Future<void> sendSong(int trackIndex) async {
    Map<TsUser, bool> sendTo =
        Provider.of<UserProvider>(context, listen: false).sendTo;
    String myFbDocId =
        Provider.of<UserProvider>(context, listen: false).fbDocId;
    for (var friend in sendTo.entries) {
      if (!friend.value) {
        continue;
      }
      final friendsFriendCollection = firestore
          .collection("users")
          .doc(friend.key.fbDocId)
          .collection("friends");
      // Add the id of this track to this user's entry in the friend's document of this user
      await friendsFriendCollection
          // Get the document in "friends" collection with this user's id
          .where("fbDocId", isEqualTo: myFbDocId)
          .get()
          .then((QuerySnapshot res) async {
        // res should only hold the document in "friends" representing this user
        if (res.docs.isEmpty) {
          print(
              "ERROR: Tried to send song to nonexistent user - send_song.dart line 102");
          return;
        }
        if (res.docs.length > 1) {
          print(
              "ERROR: More than one friends have same firebase doc id - send_song.dart line 102");
          return;
        }
        await friendsFriendCollection.doc(res.docs[0].id).update({
          "sentSongs": FieldValue.arrayUnion([recentlyPlayed[trackIndex].id]),
        });
      });
    }
    print("Sent song $trackIndex");
  }

  @override
  void initState() {
    super.initState();
    friendsList = Provider.of<UserProvider>(context, listen: false).friendsList;
    loadSongs();
  }

  @override
  void dispose() {
    audioPlayer.pause();
    super.dispose();
  }

  Widget _buildSongsList() {
    if (songsLoaded == 0) {
      return Container(child: Text("Loading..."));
    } else {
      return Expanded(
        child: ListView.builder(
            itemCount: songsLoaded,
            itemBuilder: (BuildContext context, int index) {
              Track track = recentlyPlayed[index];
              return Container(
                decoration: BoxDecoration(color: Colors.white),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                                padding: EdgeInsets.fromLTRB(10, 5, 5, 5),
                                height: 50,
                                child: FittedBox(
                                  fit: BoxFit.fill,
                                  child: fImage.Image.network(
                                      track.album!.images![0].url!),
                                )),
                            Container(
                                padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                                height: 70,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(clipString(track.name!, 23),
                                          style: songInfoTextStyleSmall),
                                      Text(
                                        clipString(track.artists![0].name!, 18),
                                        style: songInfoTextStyleSmall,
                                      )
                                    ])),
                          ]),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              RawMaterialButton(
                                constraints:
                                    BoxConstraints.tight(const Size(38, 38)),
                                onPressed: () =>
                                    onPlaySongTapped(track.id!, index),
                                elevation: 2.0,
                                fillColor: spotifyGreen,
                                shape: const CircleBorder(),
                                child: Icon(
                                  playPause(index),
                                  size: 26.0,
                                  color: Colors.black,
                                ),
                              ),
                              RawMaterialButton(
                                constraints:
                                    BoxConstraints.tight(const Size(38, 38)),
                                onPressed: () {
                                  sendSong(index);
                                },
                                elevation: 2.0,
                                fillColor: teal,
                                shape: const CircleBorder(),
                                child: const Icon(Icons.send,
                                    size: 25.0, color: Colors.black),
                              ),
                            ]),
                      )
                    ]),
              );
            }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<TsUser, bool> sendTo =
        Provider.of<UserProvider>(context, listen: true).sendTo;
    return Scaffold(
      body: Column(children: [
        // Friends list
        AppBar(
          backgroundColor: Colors.transparent,
          toolbarHeight: 50.0,
          centerTitle: false,
          automaticallyImplyLeading: false,
          title: Text("Send to:", style: header1),
          elevation: 0,
        ),
        ListView.builder(
            shrinkWrap: true,
            itemCount: friendsList.length,
            itemBuilder: (BuildContext context, int index) {
              // Do not display if it doesn't have a preview url or if preview url hasn't been loaded
              if (previewUrls.length <= index || previewUrls[index] == "") {
                return Container();
              }
              return Container(
                  padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                  decoration: sendToCardDecoration,
                  height: 50,
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            "${friendsList[index].username} (${friendsList[index].name})",
                            style: TextStyle(fontSize: 18.0)),
                        Checkbox(
                            value: sendTo[friendsList[index]],
                            onChanged: (value) {
                              setState(() {
                                sendTo[friendsList[index]] =
                                    !(sendTo[friendsList[index]]!);
                              });
                            }),
                      ]));
            }),
        // Song list
        AppBar(
          backgroundColor: Colors.transparent,
          toolbarHeight: 50.0,
          centerTitle: false,
          automaticallyImplyLeading: false,
          title: Text("Select songs", style: header1),
          elevation: 0,
        ),
        _buildSongsList(),
      ]),
    );
  }
}
