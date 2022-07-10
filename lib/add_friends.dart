import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'constants.dart';

class Friend {
  String name = "name";
  String username = "username";
  String id = "id";
  Friend(this.name, this.username, this.id);
}

class AddFriendsPage extends StatefulWidget {
  const AddFriendsPage({Key? key}) : super(key: key);

  @override
  State<AddFriendsPage> createState() => AddFriendsPageState();
}

class AddFriendsPageState extends State<AddFriendsPage> {
  final _focusNode = FocusNode();
  final firestore = FirebaseFirestore.instance;

  final _friendSearchController = TextEditingController();
  var _friendsList = [];

  void _friendSearchControllerListener() {
    var newFriendsList = List<Friend>.empty(growable: true);
    firestore
        .collection("users")
        .where("username", isEqualTo: _friendSearchController.text)
        .get()
        .then((QuerySnapshot res) {
      for (QueryDocumentSnapshot<Object?> doc in res.docs) {
        print("Found user");
        Friend friend =
            Friend(doc.get('name'), doc.get('username'), doc.get('id'));
        print("Added user");
        newFriendsList.add(friend);
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
              return Container(
                  padding: EdgeInsets.fromLTRB(30, 10, 0, 0),
                  height: 50,
                  color: Colors.white,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(_friendsList[index].username),
                        Text(_friendsList[index].name),
                      ]));
            }),
      )
    ]));
  }
}
