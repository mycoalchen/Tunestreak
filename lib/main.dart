// @dart=2.9

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:tunestreak/user_provider.dart';
import 'firebase_options.dart';
import 'signup1.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
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
          builder: (context, userProvider, child) => MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Signup1(),
          ),
        ));
  }
}
