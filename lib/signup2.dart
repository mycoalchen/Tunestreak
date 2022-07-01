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

class Signup2 extends StatefulWidget {
  @override
  _Signup2State createState() => _Signup2State();
}

class _Signup2State extends State<Signup2> {

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
  Future<bool> isUsernameTaken() async {
    try {
      await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: usernameController.text)
        .get().then((value) {
          if (value.size > 0) {
            setState(() { _usernameErrorMsg = 'Username already taken.'; });
            return true;
          } else { 
            print("username " + usernameController.text + " not taken.");
            setState(() { _usernameErrorMsg  = null; });
            return false; }
        });
    } catch(e) {
      debugPrint("isUsernameTaken error: " + e.toString());
      return false;
    } return false;
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
    // Check if username is already taken
    if (await isUsernameTaken()) {
      print("username taken");
      return;
    }
    await registerUser();
    if (!mounted) return;
    Navigator.push(context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  Widget buildEmailFormField() => TextFormField(
      validator: validateEmail,
      decoration: inputBoxDecoration('Email', null),
      controller: emailController,
  );
  Widget buildUsernameFormField() => TextFormField(
    validator: validateUsername,
    controller: usernameController,
    decoration: inputBoxDecoration('Username', _usernameErrorMsg),
  );
  Widget buildNameFormField() => TextFormField(
    validator: validateName,
    decoration: inputBoxDecoration('Name', null),
    controller: nameController,
  );
  Widget buildPasswordFormField() => TextFormField(
    validator: validatePassword,
    decoration: inputBoxDecoration('Password', null),
    obscureText: true,
    controller: passwordController,
  );
  Widget buildConfirmPasswordFormField() => TextFormField(
    validator: validateConfirmPassword,
    decoration: inputBoxDecoration('Confirm Password', null),
    obscureText: true,
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

  String? validateEmail(String? value) {
    String pattern =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?)*$";
    RegExp regex = RegExp(pattern);
    if (value == null || value.isEmpty || !regex.hasMatch(value))
      { return 'Please enter a valid email.'; }
    else
      { return null; }
  }
  String? validatePassword(String? value) {
    RegExp regex = // at least 8 characters long
        RegExp(r'^.{8,}$');
    if (value == null || value.isEmpty || !regex.hasMatch(value)) {
      return 'Password must be at least 8 characters long';
    } else { return null; }
  }
  String? validateConfirmPassword(String? value) {
    if (value != passwordController.text) {
      return 'Passwords must match';
    } else { return null; }
  }
  String? validateName(String? value) {
    if (value == null || value.toString().length < 40) {
      return null;
    }
    else {
      return 'Please enter a name under 40 characters long.';
    }
  }
  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a username.';
    }
    else if (value.toString().contains(' ')) {
      return 'Spaces not allowed in username';
    }
    else if (value.toString().length < 40) {
      return null;
    }
    else {
      return 'Please enter a username under 40 characters long.';
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    usernameController.dispose();
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
                          'Just a few more things and your account will be ready.',
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
                        const SizedBox(height: 10.0),
                        buildUsernameFormField(),
                        const SizedBox(height: 10.0),
                        buildNameFormField(),
                        const SizedBox(height: 30.0),
                        buildPasswordFormField(),
                        const SizedBox(height: 10.0),
                        buildConfirmPasswordFormField(),
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