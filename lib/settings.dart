import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotify/spotify.dart' as spt;
import 'package:settings_ui/settings_ui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'spotify_provider.dart';
import 'dart:io';
import 'constants.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  final storage = FirebaseStorage.instance;

  void chooseProfilePicture(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    print("pickImage finished");

    final storageRef = FirebaseStorage.instance.ref();
    if (!mounted) return;
    spt.UserPublic user = Provider.of<SpotifyProvider>(context, listen: false).user;
    String displayName = user.displayName!;
    final profilePictureRef = storageRef.child("images/${displayName}");
    File imageFile = File(image!.path);
    try {
      await profilePictureRef.putFile(imageFile);
      print("finished putting file");
    } on FirebaseException catch (e) {
      print(e);
    }

  }

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
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: Text(
              'Profile',
              style: settingsTitleStyle,
            ),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: Icon(Icons.account_circle),
                title: Text('Profile Picture'),
                onPressed: chooseProfilePicture,
              ),
              SettingsTile.switchTile(
                onToggle: (value) {},
                initialValue: true,
                leading: Icon(Icons.format_paint),
                title: Text('Enable custom theme'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}