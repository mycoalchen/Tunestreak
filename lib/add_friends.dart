import 'package:flutter/material.dart';
import 'constants.dart';

class AddFriendsPage extends StatefulWidget {
  const AddFriendsPage({Key? key}) : super(key: key);

  @override
  State<AddFriendsPage> createState() => AddFriendsPageState();
}

class AddFriendsPageState extends State<AddFriendsPage> {

  var _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppBar(
            backgroundColor: Colors.white,
            toolbarHeight: 60.0,
            centerTitle: false,
            automaticallyImplyLeading: false,
            title: Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
              child: TextField(
                focusNode: _focusNode,
                style: TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  hintText: "Search by name or username",
                  hintStyle: const TextStyle(fontSize: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(0),
                  fillColor: circleColor,
                  filled: true,
                  prefixIcon: InkWell(
                    onTap: () => {
                      _focusNode.requestFocus()
                    },
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
                )
              ),
            )
          )
        ]
      )
    );
  }
}