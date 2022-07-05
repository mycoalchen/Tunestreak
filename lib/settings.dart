import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotify/spotify.dart' as spt;
import 'package:settings_ui/settings_ui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:math';
import 'dart:io';
import 'constants.dart';
import 'user_provider.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  final storage = FirebaseStorage.instance;

  void chooseProfilePicture(BuildContext context) async {
    // Pick image from gallery
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    print("pickImage finished");

    // Save image to Firebase storage
    final storageRef = FirebaseStorage.instance.ref();
    if (!mounted) return;
    String id = Provider.of<UserProvider>(context, listen: false).id;
    final profilePictureRef = storageRef.child("profilePictures/$id");
    File imageFile = File(image!.path);
  
    // Set profile picture in provider
    Provider.of<UserProvider>(context, listen: false).setProfilePicture(
      CircleAvatar(
        backgroundImage: Image.file(imageFile).image,
      )
    );

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
                leading: Provider.of<UserProvider>(context, listen: false).profilePicture,
                title: Text('Profile Picture'),
                onPressed: chooseProfilePicture,
              ),
            ],
          ),
        ],
      ),
    );
  }
}