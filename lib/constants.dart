import 'package:flutter/material.dart';

final kHintTextStyle = TextStyle(
  color: Colors.white54,
  fontFamily: 'OpenSans',
);

final kLabelStyle = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.bold,
  fontFamily: 'OpenSans',
);

final kBoxDecorationStyle = BoxDecoration(
  color: const Color.fromARGB(255, 19, 195, 19),
  borderRadius: BorderRadius.circular(10.0),
  boxShadow: const [
    BoxShadow(
      color: Colors.white,
      blurRadius: 6.0,
      offset: Offset(0, 2),
    ),
  ],
);

final snapchatButtonStyle = ButtonStyle(
  backgroundColor: MaterialStateProperty.all(Colors.black),
  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
    RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    )
  ),
  shadowColor: MaterialStateProperty.all(Colors.black),
);

final spotifyButtonStyle = ButtonStyle(
  backgroundColor: MaterialStateProperty.all(Colors.black),
  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
    RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    )
  ),
  shadowColor: MaterialStateProperty.all(Colors.black),
);

const connectButtonTextStyle = TextStyle(
  color: Colors.white,
  shadows: [
    Shadow( // bottomLeft
          offset: Offset(0, 0),
          blurRadius: 4,
          color: Colors.black
        ),
  ],
  fontSize: 22.0,
  fontWeight: FontWeight.bold,
  fontFamily: 'Roboto',
);