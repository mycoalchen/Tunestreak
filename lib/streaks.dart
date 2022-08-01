import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'friend_card.dart';
import 'add_friends.dart';
import 'user_provider.dart';
import 'constants.dart';
import 'utilities.dart';

class StreaksPage extends StatefulWidget {
  final void Function() openSendSong;

  const StreaksPage({Key? key, required this.openSendSong}) : super(key: key);

  @override
  State<StreaksPage> createState() => StreaksPageState();
}

class StreaksPageState extends State<StreaksPage> {
  final firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<TsUser> _friendsList =
        Provider.of<UserProvider>(context, listen: true).friendsList;
    return Scaffold(
        body: Column(children: [
      Expanded(
          child: ListView.builder(
              itemCount: _friendsList.length,
              itemBuilder: (BuildContext context, int index) {
                return StreakCard(
                    TsUser(
                      _friendsList[index].name,
                      _friendsList[index].username,
                      _friendsList[index].fbDocId,
                      _friendsList[index].id,
                    ),
                    firestore,
                    widget.openSendSong);
              }))
    ]));
  }
}
