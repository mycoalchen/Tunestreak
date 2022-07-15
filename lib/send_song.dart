import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  @override
  Widget build(BuildContext context) {
    List<TsUser> _friendsList =
        Provider.of<UserProvider>(context, listen: true).friendsList;
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
        Container(
            height: 500,
            child: Expanded(
              child: ListView.builder(
                  itemCount: _friendsList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                        padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
                        decoration: userCardDecoration,
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  "${_friendsList[index].username} (${_friendsList[index].name})",
                                  style: TextStyle(fontSize: 18.0)),
                            ]));
                  }),
            )),
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
