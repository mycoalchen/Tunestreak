import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:spotify/spotify.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/src/widgets/image.dart'
    as fImage; // Flutter-defined Image; prevent conflict with Spotify-defined image
import 'moments.dart';
import 'user_provider.dart';
import 'utilities.dart';
import 'constants.dart';

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

class _StreakCardState extends State<StreakCard>
    with SingleTickerProviderStateMixin {
  // whether showSongsToSend is still being run
  bool isLoading = false;
  String streak = "...";
  bool pressed = false;
  late AudioPlayer audioPlayer;
  late Stream<DurationState> durationState;
  Color openSongButtonColor = Colors.white;
  Color openSongOverlayColor =
      Colors.white; // Splash color of "open song" button
  int previewLengthSeconds = 30;
  int minStreakLengthSeconds =
      8; // number of seconds that must be listened-to before streak increases
  late Timer streakTimer;
  // id of the Firebase doc containing the moments of this user and the friend
  String momentsId = "";
  // Number of unopened songs
  int numUnopenedSongs = 0;
  // Send/Receive status indicator
  // 0 None, 1 Open, 2 Sent, 3 Opened by friend, 4 Opened by me
  int streakStatus = 0;
  // Time since last song-opening
  String timeSinceLastOpened = "";

  // Called when song has been open for minStreakLength seconds
  Future<void> onStreakTimerFinished() async {
    // Update the streak in this user's doc of the friend
    String friendDocId = await getFriendDoc(
        Provider.of<UserProvider>(context, listen: false).fbDocId!,
        widget.friend.fbDocId);
    if (!mounted) return;
    await widget.firestore
        .collection("users")
        .doc(Provider.of<UserProvider>(context, listen: false).fbDocId)
        .collection("friends")
        .doc(friendDocId)
        .update({"streak": FieldValue.increment(1)});

    // Update the streak in the friend's doc of this user
    if (!mounted) return;
    String userDocId = await getFriendDoc(widget.friend.fbDocId,
        Provider.of<UserProvider>(context, listen: false).fbDocId!);
    await widget.firestore
        .collection("users")
        .doc(widget.friend.fbDocId)
        .collection("friends")
        .doc(userDocId)
        .update({"streak": FieldValue.increment(1)});
    // Update the streak count displayed
    if (!mounted) return;
    setStreak(context);
  }

  Future<void> saveToMoments(Track track, BuildContext context) async {
    String friendDocId = await getFriendDoc(
        Provider.of<UserProvider>(context, listen: false).fbDocId!,
        widget.friend.fbDocId);
    print(friendDocId);
    // Set momentsId
    if (momentsId == "") {
      await widget.firestore
          .collection("users")
          .doc(Provider.of<UserProvider>(context, listen: false).fbDocId)
          .collection("friends")
          .doc(friendDocId)
          .get()
          .then((doc) async {
        setState(() => momentsId = doc.get("moments"));
      });
    }
    await widget.firestore.collection("moments").doc(momentsId).update({
      "songs": FieldValue.arrayUnion([track.id])
    });
  }

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
    final String docId =
        Provider.of<UserProvider>(context, listen: false).fbDocId!;
    final String friendDocId = await getFriendDoc(docId, widget.friend.fbDocId);
    await widget.firestore
        .collection("users")
        .doc(docId)
        .collection("friends")
        .doc(friendDocId)
        .get()
        .then((doc) async {
      Map<String, dynamic> data = doc.data()!;
      if (data.containsKey("lastOpenedTime")) {
        DateTime lastOpened = (data["lastOpenedTime"] as Timestamp).toDate();
        final timeElapsed = DateTime.now().difference(lastOpened);
        if (timeElapsed.inSeconds > 86400) {
          // Set streak to 0
          setFriendSharedValue("streak", 0, docId, widget.friend.fbDocId);
        }
        // Set timeSinceLastOpened
        else {
          if (timeElapsed.inHours > 0) {
            setState(() => timeSinceLastOpened = "${timeElapsed.inHours}h");
          } else if (timeElapsed.inMinutes > 0) {
            setState(() => timeSinceLastOpened = "${timeElapsed.inMinutes}m");
          } else {
            setState(() => timeSinceLastOpened = "${timeElapsed.inSeconds}s");
          }
        }
      }
    });
    widget.firestore
        .collection("users")
        .doc(docId)
        .collection("friends")
        .doc(friendDocId)
        .get()
        .then((value) {
      setState(() => streak = value.get("streak").toString());
    });
  }

  String sendSongText() {
    if (isLoading) {
      return "...";
    } else {
      return "Send";
    }
  }

  Future<void> setStreakStatus() async {
    String docId = Provider.of<UserProvider>(context, listen: false).fbDocId!;
    String friendDocId = await getFriendDoc(docId, widget.friend.fbDocId);
    String myDocId = await getFriendDoc(widget.friend.fbDocId, docId);
    // streakStatus 1 - Open
    await widget.firestore
        .collection("users")
        .doc(docId)
        .collection("friends")
        .doc(friendDocId)
        .get()
        .then((res) async {
      if (List.from(res.get("sentSongs")).isNotEmpty) {
        // streakStatus = 1 - Open
        // Make Open button visible and set numOpenedSongs
        setState(() {
          streakStatus = 1;
          openSongButtonColor = pink;
          openSongOverlayColor = darkPink;
          numUnopenedSongs = List.from(res.get("sentSongs")).length;
        });
      } else {
        if (!mounted) return;
        setState(() {
          openSongButtonColor = Colors.white;
          openSongOverlayColor = Colors.white;
        });
        // streakStatus 2 - Sent
        await widget.firestore
            .collection("users")
            .doc(widget.friend.fbDocId)
            .collection("friends")
            .doc(myDocId)
            .get()
            .then((doc) async {
          if (List.from(doc.get("sentSongs")).isNotEmpty) {
            setState(() => streakStatus = 2);
          } else {
            await widget.firestore
                .collection("users")
                .doc(docId)
                .collection("friends")
                .doc(friendDocId)
                .get()
                .then((doc) {
              final data = doc.data();
              if (!data!.containsKey("lastOpenedByMe")) {
                setState(() => streakStatus = 0);
              } else if (data["lastOpenedByMe"] == false) {
                setState(() => streakStatus = 3);
              } else if (data["lastOpenedByMe"] == true) {
                setState(() => streakStatus = 4);
              }
            });
          }
        });
      }
    });
  }

  // Return text next to icon
  Widget statusIndicatorText(IconData icon, String text) {
    return RichText(
        text: TextSpan(children: [
      statusIndicatorIcon(icon),
      TextSpan(
        text: " $text",
        style: basicBlack(13),
      )
    ]));
  }

  Widget buildStatusIndicator(context) {
    // Sent
    if (streakStatus == 2) {
      return statusIndicatorText(Icons.send, "Sent");
    }
    // Opened by friend
    else if (streakStatus == 3) {
      return statusIndicatorText(Icons.send_outlined, "Opened");
    }
    // Opened by me
    else if (streakStatus == 4) {
      return statusIndicatorText(Icons.play_arrow_outlined, "Opened");
    }
    // no streakStatus or streakStatus is Open
    return TextButton(
        style: addFriendButtonStyle.copyWith(
            backgroundColor:
                MaterialStateProperty.all<Color>(openSongButtonColor),
            overlayColor:
                MaterialStateProperty.all<Color>(openSongOverlayColor)),
        onPressed: () => onOpenSongTapped(context),
        child: RichText(
            text: TextSpan(children: [
          const WidgetSpan(
              child: Icon(Icons.play_arrow, color: Colors.white, size: 20),
              alignment: PlaceholderAlignment.middle),
          TextSpan(
            text: " Open ($numUnopenedSongs)",
            style: const TextStyle(color: Colors.white, fontSize: 13),
          )
        ])));
  }

  void onOpenSongTapped(context) async {
    String docId = Provider.of<UserProvider>(context, listen: false).fbDocId!;
    final friendsCollection =
        widget.firestore.collection("users").doc(docId).collection("friends");
    String friendDocId = await getFriendDoc(docId, widget.friend.fbDocId);
    String myDocId = await getFriendDoc(widget.friend.fbDocId, docId);
    await friendsCollection.doc(friendDocId).get().then((value) async {
      List<String> songs = List.from(value.get("sentSongs"));
      if (songs.isEmpty) return;
      await friendsCollection.doc(friendDocId).update({
        "sentSongs": FieldValue.arrayRemove([songs[0]])
      });
      // If the last song wasn't opened by me, update the lastOpenedTime (streak time) and lastOpenedByMe
      await friendsCollection.doc(friendDocId).get().then((value) async {
        Map<String, dynamic> data = value.data()!;
        if (!data.containsKey("lastOpenedByMe") ||
            data["lastOpenedByMe"] == false) {
          await friendsCollection.doc(friendDocId).update(
              {"lastOpenedTime": Timestamp.now(), "lastOpenedByMe": true});
          await widget.firestore
              .collection("users")
              .doc(widget.friend.fbDocId)
              .collection("friends")
              .doc(myDocId)
              .update(
                  {"lastOpenedTime": Timestamp.now(), "lastOpenedByMe": false});
        }
      });
      // Play the song
      Track track = await Provider.of<UserProvider>(context, listen: false)
          .spotify!
          .tracks
          .get(songs[0]);
      if (track.previewUrl != null) {
        audioPlayer.pause();
        await audioPlayer.setUrl(track.previewUrl!);
        audioPlayer.play();
        streakTimer = Timer(
            Duration(seconds: minStreakLengthSeconds), onStreakTimerFinished);
      } else {
        print("ERROR: PREVIEW NULL");
      }
      // Open a Spotify popup
      showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) {
            return StatefulBuilder(
                builder: (BuildContext context, StateSetter setModalState) {
              return Container(
                  height: 600,
                  decoration: const BoxDecoration(color: spotifyBlack),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                            padding: EdgeInsets.fromLTRB(20, 35, 20, 0),
                            height: 200,
                            width: 200,
                            child: FittedBox(
                              fit: BoxFit.fill,
                              child: fImage.Image.network(
                                  track.album!.images![0].url!),
                            )),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: Text(clipString(track.name!, 23),
                              style: songInfoTextStyleBig),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 2.5, 20, 0),
                          child: Text(clipString(track.album!.name!, 25),
                              style: songInfoTextStyleBig),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 2.5, 20, 0),
                          child: Text(clipString(track.artists![0].name!, 18),
                              style: songInfoTextStyleBig),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(40, 20, 40, 0),
                          child: StreamBuilder<DurationState>(
                              stream: durationState,
                              builder: (context, snapshot) {
                                final durationState = snapshot.data;
                                final progress =
                                    durationState?.progress ?? Duration.zero;
                                return ProgressBar(
                                  progress: progress,
                                  buffered:
                                      Duration(seconds: minStreakLengthSeconds),
                                  total:
                                      Duration(seconds: previewLengthSeconds),
                                  progressBarColor: Colors.white,
                                  baseBarColor: Color.fromRGBO(92, 92, 92, 1),
                                  bufferedBarColor: teal,
                                  barHeight: 3.0,
                                  timeLabelTextStyle: songInfoTextStyleSmall
                                      .copyWith(color: Colors.white),
                                  thumbRadius: 0,
                                );
                              }),
                        ),
                        Padding(
                            padding: const EdgeInsets.fromLTRB(40, 27, 40, 0),
                            child: StreamBuilder<PlayerState>(
                                stream: audioPlayer.playerStateStream,
                                builder: (context, snapshot) {
                                  final playerState = snapshot.data;
                                  final playing = playerState?.playing;
                                  final processingState =
                                      playerState?.processingState;
                                  if (processingState ==
                                          ProcessingState.loading ||
                                      processingState ==
                                          ProcessingState.buffering) {
                                    return Container(
                                      padding: const EdgeInsets.all(20),
                                      width: 60,
                                      height: 60,
                                      child: const CircularProgressIndicator(),
                                    );
                                  } else if (playing != true) {
                                    return RawMaterialButton(
                                        constraints: BoxConstraints.tight(
                                            const Size(60, 60)),
                                        onPressed: audioPlayer.play,
                                        elevation: 2.0,
                                        fillColor: Colors.white,
                                        shape: const CircleBorder(),
                                        child: const Icon(
                                          Icons.play_arrow,
                                          size: 40,
                                          color: Colors.black,
                                        ));
                                  } else if (processingState !=
                                      ProcessingState.completed) {
                                    return RawMaterialButton(
                                        constraints: BoxConstraints.tight(
                                            const Size(60, 60)),
                                        onPressed: audioPlayer.pause,
                                        elevation: 2.0,
                                        fillColor: Colors.white,
                                        shape: const CircleBorder(),
                                        child: const Icon(
                                          Icons.pause,
                                          size: 40,
                                          color: Colors.black,
                                        ));
                                  } else {
                                    return RawMaterialButton(
                                        constraints: BoxConstraints.tight(
                                            const Size(60, 60)),
                                        onPressed: () =>
                                            audioPlayer.seek(Duration.zero),
                                        elevation: 2.0,
                                        fillColor: Colors.white,
                                        shape: const CircleBorder(),
                                        child: const Icon(
                                          Icons.replay,
                                          size: 40,
                                          color: Colors.black,
                                        ));
                                  }
                                })),
                        Padding(
                            padding: const EdgeInsets.fromLTRB(40, 27, 40, 0),
                            child: Container(
                              padding: const EdgeInsets.all(2.5),
                              height: 60,
                              width: 240,
                              child: OutlinedButton(
                                onPressed: () async {
                                  final Uri uri = Uri.parse(track.uri!);
                                  if (!await launchUrl(uri)) {
                                    throw "Could not launch #uri";
                                  }
                                },
                                style: openInSpotifyButtonStyle,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      fImage.Image.asset(
                                          'assets/icons/Spotify.png',
                                          fit: BoxFit.contain,
                                          height: 27),
                                      const SizedBox(width: 12),
                                      const Text(
                                        "Open in Spotify",
                                        style: openInSpotifyTextStyle,
                                      ),
                                    ]),
                              ),
                            )),
                        Padding(
                            padding: const EdgeInsets.fromLTRB(40, 5, 40, 0),
                            child: Container(
                              padding: const EdgeInsets.all(2.5),
                              height: 60,
                              width: 240,
                              child: OutlinedButton(
                                onPressed: () => saveToMoments(track, context),
                                style: openInSpotifyButtonStyle,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      fImage.Image.asset(
                                          'assets/icons/Spotify.png',
                                          fit: BoxFit.contain,
                                          height: 27),
                                      const SizedBox(width: 12),
                                      const Text(
                                        "Add to moments",
                                        style: openInSpotifyTextStyle,
                                      ),
                                    ]),
                              ),
                            )),
                      ]));
            });
          }).whenComplete(() {
        setStreakStatus();
        setStreak(context);
        audioPlayer.pause();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    setStreak(context);
    audioPlayer = AudioPlayer();
    durationState = Rx.combineLatest2<Duration, PlaybackEvent, DurationState>(
        audioPlayer.positionStream,
        audioPlayer.playbackEventStream,
        (position, playbackEvent) => DurationState(
              progress: position,
              total: playbackEvent.duration,
            )).asBroadcastStream();
    WidgetsBinding.instance.addPostFrameCallback((_) => setStreakStatus());
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Provider.of<UserProvider>(context, listen: true)
                                .friendPps[widget.friend] ??
                            UserProvider.defaultProfilePicture(),
                        SizedBox(width: 10),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(widget.friend.username,
                                  style: const TextStyle(fontSize: 15.0)),
                              Text(widget.friend.name,
                                  style: const TextStyle(fontSize: 12.5))
                            ]),
                      ],
                    ),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(streak, style: const TextStyle(fontSize: 15.0)),
                          Text('${timeSinceLastOpened}',
                              style: const TextStyle(fontSize: 12.5)),
                        ])
                  ]),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildStatusIndicator(context),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          style: addFriendButtonStyle.copyWith(
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(teal),
                              overlayColor:
                                  MaterialStateProperty.all<Color>(darkTeal)),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Moments(widget.friend)));
                          },
                          child:
                              Text("Moments", style: TextStyle(fontSize: 13.0)),
                        ),
                        const SizedBox(width: 20.0),
                        TextButton(
                          style: addFriendButtonStyle,
                          onPressed: () => onSendSongTapped(context),
                          child: Text(sendSongText(),
                              style: const TextStyle(fontSize: 13.0)),
                        )
                      ])
                ],
              ),
            ]));
  }
}
