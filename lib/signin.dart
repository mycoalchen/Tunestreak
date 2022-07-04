import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:spotify/spotify.dart' as spt;
import 'user_provider.dart';
import 'constants.dart';
import 'home.dart';

class Signin extends StatefulWidget {
  @override
  _SigninState createState() => _SigninState();
}

class _SigninState extends State<Signin> {

  String? _emailErrorMsg, _passwordErrorMsg;
  final _formKey = GlobalKey<FormState>();
  
  final firestore = FirebaseFirestore.instance;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> handleSigninButtonPress() async {
    try {
      final fbCredentials = await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailController.text, password: passwordController.text);
      final fbUser = fbCredentials.user!;
      print("Signed in: " + fbUser.email!);
      
      // Get the Firestore user object with matching credentials
      final fbUserObject = firestore.collection("users")
      .where("email", isEqualTo: fbUser.email)
      .where("username", isEqualTo: fbUser.displayName)
      .get().then(
        (res) => print("found user with username " + fbUser.displayName!),
        onError: (e) { 
          print("Error finding user in firestore: $e");
          return;
        },
      );

      // Sign into Spotify using the Spotify credentials from local storage
      if (!mounted) return;
      UserProvider sp = Provider.of<UserProvider>(context, listen: false);
      

      if (!mounted) return;
      Navigator.push(context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } on FirebaseAuthException catch(e) {
      if (e.code == 'user-not-found') {
        setState(() {
          _emailErrorMsg = 'No user found for that email.';
        });
      } else if (e.code == 'wrong-password') {
        setState(() {
          _passwordErrorMsg = 'Incorrect password.';
        });
      }
    }
  }

  Widget buildEmailFormField() => TextFormField(
      decoration: inputBoxDecoration('Email', _emailErrorMsg),
      controller: emailController,
  );
  Widget buildPasswordFormField() => TextFormField(
    decoration: inputBoxDecoration('Password', _passwordErrorMsg),
    obscureText: true,
    controller: passwordController,
  );

  Widget buildSigninBotton() => Container(
    height: 50,
    width: 150,
    child: ElevatedButton(
      onPressed: () => {
        if (_formKey.currentState!.validate()) {
          handleSigninButtonPress()
        }
      },
      style: loginButtonStyle,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const <Widget>[
          Text(
            'Sign in',
            style: connectButtonTextStyle,
          ),
        ]
      ),
    ),
  );

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
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
                        buildSigninBotton(),
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