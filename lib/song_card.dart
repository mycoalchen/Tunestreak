import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/image.dart'
    as fImage; // Flutter-defined Image; prevent conflict with Spotify-defined image
import 'package:spotify/spotify.dart';
import 'utilities.dart';
import 'constants.dart';

class SongCard extends StatefulWidget {
  final Track track;
  // Takes index as input
  final Function playPause;
  // Takes track id and track index as inputs
  final Function onPlaySongTapped;
  // Takes track id as input
  final Function? sendSong;
  // Index of the song in its list
  final int index;
  // Whether or not to show a Send Song button - if this is true, sendSong must be provided
  final bool showSendSong;

  const SongCard(this.index, this.track, this.playPause, this.onPlaySongTapped,
      this.showSendSong,
      {Key? key, this.sendSong})
      : super(key: key);

  @override
  State<SongCard> createState() => _SongCardState();
}

class _SongCardState extends State<SongCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Container(
              padding: EdgeInsets.fromLTRB(10, 5, 5, 5),
              height: 50,
              child: FittedBox(
                fit: BoxFit.fill,
                child:
                    fImage.Image.network(widget.track.album!.images![0].url!),
              )),
          Container(
              padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
              height: 70,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(clipString(widget.track.name!, 23),
                        style: songInfoTextStyleSmall),
                    Text(
                      clipString(widget.track.artists![0].name!, 18),
                      style: songInfoTextStyleSmall,
                    )
                  ])),
        ]),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            RawMaterialButton(
              constraints: BoxConstraints.tight(const Size(38, 38)),
              onPressed: () =>
                  widget.onPlaySongTapped(widget.track.id!, widget.index),
              elevation: 2.0,
              fillColor: spotifyGreen,
              shape: const CircleBorder(),
              child: Icon(
                widget.playPause(widget.index),
                size: 26.0,
                color: Colors.black,
              ),
            ),
            Visibility(
              visible: widget.showSendSong,
              child: RawMaterialButton(
                constraints: BoxConstraints.tight(const Size(38, 38)),
                onPressed: () {
                  if (widget.sendSong != null) {
                    widget.sendSong!(widget.index);
                  } else {
                    print(
                        "ERROR: Tried calling sendSong but no function was provided - song_card line 86");
                  }
                },
                elevation: 2.0,
                fillColor: teal,
                shape: const CircleBorder(),
                child: const Icon(Icons.send, size: 25.0, color: Colors.black),
              ),
            ),
          ]),
        )
      ]),
    );
  }
}
