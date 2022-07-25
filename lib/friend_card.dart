import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:spotify/spotify.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tunestreak/send_song.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/src/widgets/image.dart'
    as fImage; // Flutter-defined Image; prevent conflict with Spotify-defined image
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

class _StreakCardState extends State<StreakCard>
    with SingleTickerProviderStateMixin {
  // whether showSongsToSend is still being run
  bool isLoading = false;
  String streak = "...";
  bool pressed = false;
  AudioPlayer audioPlayer = AudioPlayer();

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
                          padding: EdgeInsets.fromLTRB(20, 25, 20, 0),
                          height: 200,
                          width: 200,
                          child: FittedBox(
                            fit: BoxFit.fill,
                            child: fImage.Image.asset('assets/testImage.jpeg'),
                          )),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Text("Troll Song", style: songInfoTextStyleBig),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 2.5, 20, 0),
                        child: Text("Album name: Troll",
                            style: songInfoTextStyleBig),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 2.5, 20, 0),
                        child: Text("Artist name: Troll",
                            style: songInfoTextStyleBig),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(40, 20, 40, 0),
                        child: ProgressBar(
                          progress: Duration(milliseconds: 0),
                          total: Duration(milliseconds: 8000),
                          progressBarColor: Colors.white,
                          baseBarColor: Color.fromRGBO(92, 92, 92, 1),
                          barHeight: 3.0,
                          timeLabelTextStyle: const TextStyle(fontSize: 0),
                          thumbRadius: 0,
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(40, 20, 40, 0),
                          child: RawMaterialButton(
                              constraints:
                                  BoxConstraints.tight(const Size(60, 60)),
                              onPressed: () {},
                              elevation: 2.0,
                              fillColor: Colors.white,
                              shape: const CircleBorder(),
                              child: Icon(
                                Icons.pause,
                                size: 40,
                                color: Colors.black,
                              ))),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(40, 20, 40, 0),
                          child: Container(
                            padding: const EdgeInsets.all(2.5),
                            height: 50,
                            width: 230,
                            child: OutlinedButton(
                              onPressed: () => {},
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
                            height: 50,
                            width: 230,
                            child: OutlinedButton(
                              onPressed: () => {},
                              style: openInSpotifyButtonStyle,
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    fImage.Image.asset(
                                        'assets/icons/Spotify.png',
                                        fit: BoxFit.contain,
                                        height: 27),
                                    const SizedBox(width: 12),
                                    Text(
                                      // Add to {first name} moments
                                      // ${widget.friend.name.split(' ').first}
                                      "Add to moments",
                                      style: openInSpotifyTextStyle,
                                    ),
                                  ]),
                            ),
                          )),
                    ]));
          });
        });
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
      // TODO: Move open Spotify popup here
      // Play the song
      Track track = await Provider.of<UserProvider>(context, listen: false)
          .spotify
          .tracks
          .get(songs[0]);
      if (track.previewUrl != null) {
        setState(() async {
          audioPlayer.pause();
          await audioPlayer.setUrl(track.previewUrl!);
          audioPlayer.play();
        });
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
                      child:
                          Text("Open song", style: TextStyle(fontSize: 19.0)),
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
