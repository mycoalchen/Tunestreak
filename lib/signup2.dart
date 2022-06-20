import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants.dart';
import 'home.dart';

class Signup2 extends StatefulWidget {
  @override
  _Signup2State createState() => _Signup2State();
}

class _Signup2State extends State<Signup2> {

  final _formKey = GlobalKey<FormState>();

  Widget buildEmailFormField() => TextFormField(
    validator: validateEmail,
    decoration: inputBoxDecoration('Email'),
  );
  Widget buildUsernameFormField() => TextFormField(
    validator: validateUsername,
    decoration: inputBoxDecoration('Username'),
  );
  Widget buildNameFormField() => TextFormField(
    validator: validateName,
    decoration: inputBoxDecoration('Name'),
  );
  Widget buildSignupBotton() => Container(
    height: 50,
    width: 150,
    child: ElevatedButton(
      onPressed: () => {
        if (_formKey.currentState!.validate()) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          )
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
    else if (value.toString().length < 40) {
      return null;
    }
    else {
      return 'Please enter a username under 40 characters long.';
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  autovalidateMode: AutovalidateMode.always,
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40.0,
                      vertical: 120.0,
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
                        const SizedBox(height: 20.0),
                        buildEmailFormField(),
                        const SizedBox(height: 10.0),
                        buildUsernameFormField(),
                        const SizedBox(height: 10.0),
                        buildNameFormField(),
                        const SizedBox(height: 20.0),
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