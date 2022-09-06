import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
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
  final firestore = FirebaseFirestore.instance;

  void chooseProfilePicture(BuildContext context) async {
    // Pick image from gallery
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    print("pickImage finished");

    // Save image to Firebase storage
    final storageRef = FirebaseStorage.instance.ref();
    if (!mounted) return;
    String id = Provider.of<UserProvider>(context, listen: false).id!;
    final profilePictureRef = storageRef.child("profilePictures/$id");
    File imageFile = File(image!.path);
    try {
      await profilePictureRef.putFile(imageFile);
      if (!mounted) return;
      String fbDocId =
          Provider.of<UserProvider>(context, listen: false).fbDocId!;
      firestore.collection('users').doc(fbDocId).update(<String, dynamic>{
        'ppSet': true,
      });
      // Set profile picture in provider
      Provider.of<UserProvider>(context, listen: false)
          .setProfilePicture(CircleAvatar(
        backgroundImage: Image.file(imageFile).image,
      ));
    } on FirebaseException catch (e) {
      print("FirebaseException settings.dart line 51: $e");
      return;
    }
  }

  void onDeleteAccountPressed(context) {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: const Text('Delete account?'),
              content: const Text(
                  'This will remove your account\'s records from Tunestreak\'s databases and disconnect your Spotify account. This action cannot be undone.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    showCupertinoDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                              title: const Text('Are you sure??'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('No'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await deleteAccount(context);
                                    if (!mounted) return;
                                    Navigator.popUntil(
                                        context, (route) => route.isFirst);
                                  },
                                  child: const Text('Yes'),
                                )
                              ]);
                        });
                  },
                  child: const Text('Yes'),
                )
              ]);
        });
  }

  Future<void> deleteAccount(context) async {
    UserProvider up = Provider.of<UserProvider>(context, listen: false);
    // Run through 'friends' collection
    await firestore
        .collection("users")
        .doc(up.fbDocId)
        .collection("friends")
        .get()
        .then((res) async {
      for (var friendDoc in res.docs) {
        // Delete the moments doc for this friend and user
        await firestore
            .collection("moments")
            .doc(friendDoc.get("moments"))
            .delete();
        print("Deleted moments");
        // Reference to this friend's doc in users collection
        final ref = firestore.collection("users").doc(friendDoc.id);
        // Remove this user from this friend's friends list
        await ref
            .collection("friends")
            .where("fbDocId", isEqualTo: up.fbDocId)
            .get()
            .then((res2) async {
          if (res2.docs.isEmpty) {
            print("Error: no friend doc found for " +
                up.fbDocId.toString() +
                " in friends list of " +
                friendDoc.id);
            return;
          }
          await ref.collection("friends").doc(res2.docs[0].id).delete();
          print("Deleted this user from " +
              res2.docs[0].get("username") +
              "\'s friends list");
        });
        // Remove this friend from this user's friends list
        await firestore
            .collection("users")
            .doc(up.fbDocId)
            .collection("friends")
            .doc(friendDoc.id)
            .delete();
        print("Deleted " +
            friendDoc.get("username") +
            "\'s friend doc from this user's friends list");
      }
    });
    // Delete this user
    await firestore.collection("users").doc(up.fbDocId).delete();
    print("Deleted this user");
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: darkGray),
              onPressed: () => Navigator.of(context).pop()),
          title: Text(
            'Settings',
            style: titleTextStyle,
          )),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: Text(
              'Profile',
              style: settingsTitleStyle,
            ),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: Provider.of<UserProvider>(context, listen: false)
                    .profilePicture,
                title: Text('Profile Picture'),
                onPressed: chooseProfilePicture,
              ),
              SettingsTile.navigation(
                leading: Icon(Icons.no_accounts, size: 40),
                title: Text('Delete Account'),
                onPressed: onDeleteAccountPressed,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
