import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:spotify/spotify.dart' as spt;
import 'spotify_provider.dart';
import 'constants.dart';
import 'home.dart';

class Signin extends StatefulWidget {
  @override
  _SigninState createState() => _SigninState();
}

class _SigninState extends State<Signin> {

  String? _usernameErrorMsg;
  final _formKey = GlobalKey<FormState>();
  
  final db = FirebaseFirestore.instance;
  
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<spt.User> getSpotifyUser() async {
    SpotifyProvider spotifyProvider = Provider.of<SpotifyProvider>(context, listen: false);
    spt.User user = await spotifyProvider.spotify.me.get();
    print("got spotify user in getSpotifyUser()");
    return user;
  }

  Future<void> registerUser() async {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: emailController.text, password: passwordController.text);
    final user = <String, dynamic>{
      'username' : usernameController.text,
      'email' : emailController.text,
      'name' : nameController.text,
      'spotify' : Provider.of<SpotifyProvider>(context, listen: false).user.id,
    };
    db.collection("users").add(user).then((DocumentReference doc) => {
    print('DocumentSnapshot added with ID: ${doc.id}')});
  }
  Future<void> handleSignupButtonPress() async {
    await registerUser();
    if (!mounted) return;
    Navigator.push(context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  Widget buildEmailFormField() => TextFormField(
      decoration: inputBoxDecoration('Email', null),
      controller: emailController,
  );
  Widget buildPasswordFormField() => TextFormField(
    decoration: inputBoxDecoration('Password', null),
    obscureText: true,
    controller: passwordController,
  );

  Widget buildSignupBotton() => Container(
    height: 50,
    width: 150,
    child: ElevatedButton(
      onPressed: () => {
        if (_formKey.currentState!.validate()) {
          handleSignupButtonPress()
        }
      },
      style: loginButtonStyle,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const <Widget>[
          Text(
            'Continue',
            style: connectButtonTextStyle,
          ),
        ]
      ),
    ),
  );

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: DO SMTHN WITH FUTUREBUILDER TO PRINT SPOTIFY USER EMAIL
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: <Widget>[
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: teal,
                ),
              ),
              Container(
                height: double.infinity,
                alignment: Alignment.center,
                child: Form(
                  autovalidateMode: AutovalidateMode.disabled,
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40.0,
                      vertical: 80.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text(
                          'Please enter your email and password.',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'OpenSans',
                            fontSize: 25.0,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                blurRadius: 6,
                                color: darkGray,
                              )
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30.0),
                        buildEmailFormField(),
                        const SizedBox(height: 30.0),
                        buildPasswordFormField(),
                        const SizedBox(height: 30.0),
                        buildSignupBotton(),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}