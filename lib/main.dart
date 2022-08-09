// @dart=2.9

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:spotify/spotify.dart';
import 'package:tunestreak/home.dart';
import 'package:tunestreak/home_loading.dart';
import 'package:tunestreak/user_provider.dart';
import 'firebase_options.dart';
import 'signup1.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<UserProvider>(
              create: (context) => UserProvider()),
        ],
        child: Consumer<UserProvider>(
          builder: (context, userProvider, child) => const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: HomeLoading(),
          ),
        ));
  }
}
