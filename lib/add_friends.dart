import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:tunestreak/user_provider.dart';
import 'user_profile.dart';
import 'friend_card.dart';
import 'constants.dart';
import 'utilities.dart';

class AddFriendsPage extends StatefulWidget {
  const AddFriendsPage({Key? key}) : super(key: key);

  @override
  State<AddFriendsPage> createState() => AddFriendsPageState();
}

class AddFriendsPageState extends State<AddFriendsPage> {
  final _focusNode = FocusNode();
  final firestore = FirebaseFirestore.instance;

  final _friendSearchController = TextEditingController();
  var _friendsList = List<TsUser>.empty();

  void _friendSearchControllerListener() async {
    var newFriendsList = List<TsUser>.empty(growable: true);
    await firestore
        .collection("users")
        .where("username", isEqualTo: _friendSearchController.text)
        .get()
        .then((QuerySnapshot res) async {
      for (QueryDocumentSnapshot<Object?> doc in res.docs) {
        // Check that this user isn't already a friend
        await firestore
            .collection("users")
            .doc(Provider.of<UserProvider>(context, listen: false).fbDocId)
            .collection("friends")
            .where("fbDocId", isEqualTo: doc.id)
            .get()
            .then((res) {
          print("res length ${res.docs.length}");
          if (res.docs.isEmpty) {
            TsUser friend = TsUser(
                doc.get('name'), doc.get('username'), doc.id, doc.get('id'));
            newFriendsList.add(friend);
          }
        });
      }
      setState(() => _friendsList = newFriendsList);
    });
  }

  @override
  void initState() {
    super.initState();
    _friendSearchController.addListener(_friendSearchControllerListener);
  }

  @override
  void dispose() {
    _friendSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      // Friend requests
      Container(
        decoration: const BoxDecoration(
            border: Border(
                bottom: BorderSide(
          color: circleColor,
          width: 1,
        ))),
        child: AppBar(
          backgroundColor: Colors.transparent,
          toolbarHeight: 60.0,
          centerTitle: false,
          automaticallyImplyLeading: false,
          title: Text("Friend requests", style: header1),
          elevation: 0,
        ),
      ),

      // Find friends
      AppBar(
        backgroundColor: Colors.transparent,
        toolbarHeight: 60.0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Text("Find friends", style: header1),
        elevation: 0,
      ),
      AppBar(
          backgroundColor: Colors.white,
          toolbarHeight: 60.0,
          centerTitle: false,
          automaticallyImplyLeading: false,
          title: Padding(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
            child: TextField(
                controller: _friendSearchController,
                focusNode: _focusNode,
                style: const TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  hintText: "Search by username",
                  hintStyle: const TextStyle(fontSize: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(0),
                  fillColor: circleColor,
                  filled: true,
                  prefixIcon: InkWell(
                    onTap: () => {_focusNode.requestFocus()},
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.all(0),
                      decoration: circleInkwellBoxDecoration,
                      child: const Icon(
                        Icons.search,
                        color: darkGray,
                      ),
                    ),
                  ),
                )),
          )),
      Expanded(
          child: ListView.builder(
              itemCount: _friendsList.length,
              itemBuilder: (BuildContext context, int index) {
                return AddFriendCard(
                    TsUser(
                      _friendsList[index].name,
                      _friendsList[index].username,
                      _friendsList[index].fbDocId,
                      _friendsList[index].id,
                    ),
                    firestore);
              }))
    ]));
  }
}
