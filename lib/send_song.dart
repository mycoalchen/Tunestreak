import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'add_friends.dart';
import 'user_provider.dart';
import 'utilities.dart';
import 'constants.dart';

class SendSongPage extends StatefulWidget {
  final Set<TsUser>? selectedFriends;

  const SendSongPage({Key? key, this.selectedFriends}) : super(key: key);

  @override
  State<SendSongPage> createState() => SendSongPageState();
}

class SendSongPageState extends State<SendSongPage> {
  late List<TsUser> friendsList;
  late Map<TsUser, bool> sendTo;

  @override
  void initState() {
    super.initState();
    friendsList = Provider.of<UserProvider>(context, listen: false).friendsList;
    sendTo = Map<TsUser, bool>.from({});
    if (widget.selectedFriends != null) {
      for (TsUser friend in friendsList) {
        print(friend);
        print(widget.selectedFriends!.first);
        sendTo[friend] = widget.selectedFriends!.contains(friend);
      }
    } else {
      for (TsUser friend in friendsList) {
        sendTo[friend] = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
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
        AppBar(
          backgroundColor: Colors.transparent,
          toolbarHeight: 50.0,
          centerTitle: false,
          automaticallyImplyLeading: false,
          title: Text("Select songs", style: header1),
          elevation: 0,
        )
      ]),
    );
  }
}
