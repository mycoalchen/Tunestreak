import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:spotify/spotify.dart';
import 'package:flutter/src/widgets/image.dart'
    as fImage; // Flutter-defined Image; prevent conflict with Spotify-defined image
import 'package:tunestreak/song_card.dart';
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
          .spotify!
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
    await up.spotify!.me.recentlyPlayed(limit: songsToLoad).then((value) async {
      List<PlayHistory> songList = value.toList();
      for (int i = 0; i < songList.length; i++) {
        Track track = await up.spotify!.tracks.get(songList[i].track!.id!);
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
    bool nobodySelected = true;
    for (bool selected in sendTo.values) {
      if (selected) {
        nobodySelected = false;
        break;
      }
    }
    if (nobodySelected) return;
    String myFbDocId =
        Provider.of<UserProvider>(context, listen: false).fbDocId!;
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        "Sent song!",
        textAlign: TextAlign.center,
        style: settingsTitleStyle,
      ),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.white,
      margin: const EdgeInsets.fromLTRB(30, 0, 30, 10),
    ));
    if (!mounted) return;
    Map<TsUser, bool> newSendTo = sendTo;
    for (TsUser user in newSendTo.keys) {
      newSendTo[user] = false;
    }
    Provider.of<UserProvider>(context, listen: false).setSendTo(newSendTo);
  }

  @override
  void initState() {
    super.initState();
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
              if (previewUrls.length <= index || previewUrls[index] == "") {
                return Container();
              }
              Track track = recentlyPlayed[index];
              return SongCard(index, track, playPause, onPlaySongTapped, true,
                  sendSong: sendSong);
            }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<TsUser, bool> sendTo =
        Provider.of<UserProvider>(context, listen: true).sendTo;
    List<TsUser> friendsList =
        Provider.of<UserProvider>(context, listen: true).friendsList;
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
