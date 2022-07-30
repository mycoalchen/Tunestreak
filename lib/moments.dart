import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:spotify/spotify.dart';
import 'package:flutter/src/widgets/image.dart'
    as fImage; // Flutter-defined Image; prevent conflict with Spotify-defined image
import 'package:tunestreak/home_app_bar.dart';
import 'package:tunestreak/song_card.dart';
import 'add_friends.dart';
import 'user_provider.dart';
import 'utilities.dart';
import 'constants.dart';

class Moments extends StatefulWidget {
  final TsUser friend;
  const Moments(this.friend, {Key? key}) : super(key: key);

  @override
  State<Moments> createState() => _MomentsState();
}

class _MomentsState extends State<Moments> {
  List<Track> moments = List<Track>.empty(growable: true);
  int songsLoaded = 0;
  // Index in list of currently playing song (-1 when no song playing)
  int currentlyPlaying = -1;
  static AudioPlayer audioPlayer = AudioPlayer();
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Return either a play or pause icon
  IconData playPause(int index) {
    if (currentlyPlaying == index) {
      return Icons.pause;
    } else {
      return Icons.play_arrow;
    }
  }

  // Set state of this song to playing, start playing preview
  // trackIndex is the index of this track in recentlyPlayed
  Future<void> onPlaySongTapped(String trackId, int trackIndex) async {
    print(currentlyPlaying);
    print("trackIndex - " + trackIndex.toString());
    // Play
    if (currentlyPlaying != trackIndex || currentlyPlaying == -1) {
      Track track = await Provider.of<UserProvider>(context, listen: false)
          .spotify
          .tracks
          .get(trackId);
      audioPlayer.pause();
      // We know previewUrl isn't null here because it couldn't have been null when originally sent
      await audioPlayer.setUrl(moments[trackIndex].previewUrl!);
      audioPlayer.play();
      setState(() => currentlyPlaying = trackIndex);
    } else {
      print("Pausing song");
      // Pause
      audioPlayer.pause();
      setState(() {
        currentlyPlaying = -1;
      });
    }
  }

  // Gets moments saved in Firestore, sets moments state to those songs
  Future<void> loadSongs() async {
    UserProvider up = Provider.of<UserProvider>(context, listen: false);
    // Get id of moments doc
    String friendDocId = await getFriendDoc(up.fbDocId, widget.friend.fbDocId);
    String momentsId = await firestore
        .collection("users")
        .doc(up.fbDocId)
        .collection("friends")
        .doc(friendDocId)
        .get()
        .then((value) => value.get("moments"));
    await firestore
        .collection("moments")
        .doc(momentsId)
        .get()
        .then((value) async {
      for (String trackId in value.get("songs")) {
        Track track = await up.spotify.tracks.get(trackId);
        setState(() {
          moments.add(track);
          songsLoaded++;
        });
      }
    });
  }

  Widget _buildSongsList() {
    if (songsLoaded == 0) {
      return const Center(
          child: Padding(
              padding: EdgeInsets.all(30),
              child: Text("Loading...", style: TextStyle(fontSize: 16))));
    } else {
      return Expanded(
          child: ListView.builder(
              itemCount: songsLoaded,
              itemBuilder: (BuildContext context, int index) {
                Track track = moments[index];
                return SongCard(
                    index, track, playPause, onPlaySongTapped, false);
              }));
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(
        title: "${widget.friend.name.split(" ").first} Moments",
      ),
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [_buildSongsList()]),
      bottomNavigationBar: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Material(
                  color: teal,
                  child: InkWell(
                      onTap: () => Navigator.pop(context),
                      splashColor: darkTeal,
                      child: SizedBox(
                          height: 90,
                          child: Center(
                              child: Text('Back',
                                  textAlign: TextAlign.center,
                                  style: songInfoTextStyleBig))))),
            ),
            Expanded(
                child: Material(
                    color: spotifyGreen,
                    child: InkWell(
                        onTap: () => {},
                        splashColor: darkGreen,
                        child: SizedBox(
                            height: 90,
                            child: Center(
                                child: Text('Save to Spotify',
                                    textAlign: TextAlign.center,
                                    style: songInfoTextStyleBig.copyWith(
                                        color: Colors.black))))))),
          ]),
    );
  }
}
