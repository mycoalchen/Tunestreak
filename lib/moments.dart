import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:spotify/spotify.dart';
import 'package:flutter/src/widgets/image.dart'
    as fImage; // Flutter-defined Image; prevent conflict with Spotify-defined image
import 'package:tunestreak/home_app_bar.dart';
import 'add_friends.dart';
import 'user_provider.dart';
import 'utilities.dart';
import 'constants.dart';

class Moments extends StatefulWidget {
  final String name;
  const Moments(this.name, {Key? key}) : super(key: key);

  @override
  State<Moments> createState() => _MomentsState();
}

class _MomentsState extends State<Moments> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(
        title: widget.name + " Moments",
      ),
    );
  }
}
