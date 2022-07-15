import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'friend_card.dart';
import 'add_friends.dart';
import 'user_provider.dart';
import 'constants.dart';

class SendSongPage extends StatefulWidget {
  const SendSongPage({Key? key}) : super(key: key);

  @override
  State<SendSongPage> createState() => SendSongPageState();
}

class SendSongPageState extends State<SendSongPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Text("Send song"));
  }
}
