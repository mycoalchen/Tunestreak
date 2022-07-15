import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'friend_card.dart';
import 'add_friends.dart';
import 'user_provider.dart';
import 'constants.dart';
import 'utilities.dart';

class StreaksPage extends StatefulWidget {
  const StreaksPage({Key? key}) : super(key: key);

  @override
  State<StreaksPage> createState() => StreaksPageState();
}

class StreaksPageState extends State<StreaksPage> {
  final firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    getAllFriends();
  }

  Future<void> getAllFriends() async {
    var friendsList = List<TsUser>.empty(growable: true);
    final users = firestore.collection("users");
    users
        .doc(Provider.of<UserProvider>(context, listen: false).fbDocId)
        .collection('friends')
        .get()
        .then((QuerySnapshot res) async {
      print("Running through friends");
      for (QueryDocumentSnapshot<Object?> doc in res.docs) {
        if (!mounted) return;
        await users
            .doc(doc.get("fbDocId"))
            .get()
            .then((DocumentSnapshot friend) {
          print("Adding friend " + friend.id + ": " + friend.get("name"));
          friendsList.add(
              TsUser(friend.get("name"), friend.get("username"), friend.id));
        });
      }
      if (!mounted) return;
      Provider.of<UserProvider>(context, listen: false)
          .setFriendsList(friendsList);
    });
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
                    ),
                    firestore);
              }))
    ]));
  }
}
