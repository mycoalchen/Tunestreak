import 'package:flutter/material.dart';

class NoSplash extends InteractiveInkFeature {
  NoSplash({
    required MaterialInkController controller,
    required RenderBox referenceBox,
  }) : super(
    controller: controller,
    referenceBox: referenceBox,
    color: Colors.transparent,
  );

  @override
  void paintFeature(Canvas canvas, Matrix4 transform) {}
}

const kHintTextStyle = TextStyle(
  color: Colors.white54,
  fontFamily: 'OpenSans',
);

const kLabelStyle = TextStyle(
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

final loginButtonStyle = ButtonStyle(
  backgroundColor: MaterialStateProperty.all(darkGray),
  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
    RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    )
  ),
  // Shadow shadowColor: MaterialStateProperty.all(Color(0xffFFFC00)),
  // Spotify shadowColor: MaterialStateProperty.all(Color(0xff1DB954)),
);

const connectButtonTextStyle = TextStyle(
  color: Colors.white,
  shadows: [
    Shadow( // bottomLeft
          offset: Offset(0, 0),
          blurRadius: 4,
          color: Colors.black,
        ),
  ],
  fontSize: 22.0,
  fontWeight: FontWeight.bold,
  fontFamily: 'Roboto',
);

const circleInkwellBoxDecoration = BoxDecoration(
  color: circleColor,
  shape: BoxShape.circle,
);

InputDecoration inputBoxDecoration(String? label, String? errorMsg) => InputDecoration(
  fillColor: Colors.white,
  filled: true,
  labelText: label,
  contentPadding: const EdgeInsets.all(10.0),
  errorText: errorMsg,
);

TextStyle titleTextStyle = const TextStyle(
  color: darkGray,
  fontWeight: FontWeight.w700,
  fontSize: 20,
);

TextStyle settingsTitleStyle = const TextStyle(
  color: darkGray,
  fontSize: 15,
);

TextStyle welcomeTextStyle = const TextStyle(
  color: Colors.white,
  fontFamily: 'OpenSans',
  fontSize: 50.0,
  fontWeight: FontWeight.bold,
  shadows: [
    Shadow(
      blurRadius: 6,
      color: darkGray,
    )
  ]
);

const circleColor = Color.fromRGBO(210, 210, 210, 1);
const teal = Color(0xff2bd4b2);
const spotifyGreen = Color.fromRGBO(28, 215, 96, 1);
const darkGray = Color.fromRGBO(30, 30, 30, 1);
