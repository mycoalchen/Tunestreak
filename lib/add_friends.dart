import 'package:flutter/material.dart';

class AddFriendsPage extends StatefulWidget {
  const AddFriendsPage({Key? key}) : super(key: key);

  @override
  State<AddFriendsPage> createState() => AddFriendsPageState();
}

class AddFriendsPageState extends State<AddFriendsPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Add Friends page'),
      )
    );
  }
}