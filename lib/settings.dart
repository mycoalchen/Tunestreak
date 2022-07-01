import 'package:flutter/material.dart';
import 'package:tunestreak/constants.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, 
          color: darkGray), 
          onPressed: () => Navigator.of(context).pop()),
        title: Text(
          'Settings',
          style: titleTextStyle,
        )
      )
    );
  }
}