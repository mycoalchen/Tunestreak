import 'package:flutter/material.dart';

class StreaksPage extends StatefulWidget {
  const StreaksPage({Key? key}) : super(key: key);

  @override
  State<StreaksPage> createState() => StreaksPageState();
}

class StreaksPageState extends State<StreaksPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Streaks page'),
      )
    );
  }
}