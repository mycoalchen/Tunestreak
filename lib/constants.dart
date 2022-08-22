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
  shape:
      MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10.0),
  )),
  // Shadow shadowColor: MaterialStateProperty.all(Color(0xffFFFC00)),
  // Spotify shadowColor: MaterialStateProperty.all(Color(0xff1DB954)),
);

const connectButtonTextStyle = TextStyle(
  color: Colors.white,
  shadows: [
    Shadow(
      // bottomLeft
      offset: Offset(0, 0),
      blurRadius: 4,
      color: Colors.black,
    ),
  ],
  fontSize: 22.0,
  fontWeight: FontWeight.bold,
  fontFamily: 'Roboto',
);

final openInSpotifyButtonStyle = ButtonStyle(
  backgroundColor: MaterialStateProperty.all(Colors.black),
  overlayColor: MaterialStateColor.resolveWith((states) => Colors.white),
  shape:
      MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
    side: const BorderSide(
        color: spotifyGreen, width: 3, style: BorderStyle.solid),
    borderRadius: BorderRadius.circular(10.0),
  )),
);

const openInSpotifyTextStyle = TextStyle(
  color: spotifyGreen,
  fontSize: 14.0,
);

const circleInkwellBoxDecoration = BoxDecoration(
  color: circleColor,
  shape: BoxShape.circle,
);

InputDecoration inputBoxDecoration(String? label, String? errorMsg) =>
    InputDecoration(
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

TextStyle header1 = const TextStyle(
  color: darkGray,
  fontSize: 19.0,
  fontWeight: FontWeight.w700,
);

TextStyle settingsTitleStyle = const TextStyle(
  color: darkGray,
  fontSize: 15,
);

TextStyle welcomeTextStyle = const TextStyle(
    color: Colors.white,
    fontFamily: 'OpenSans',
    fontSize: 30.0,
    fontWeight: FontWeight.bold,
    shadows: [
      Shadow(
        blurRadius: 6,
        color: darkGray,
      )
    ]);

TextStyle songInfoTextStyleSmall = const TextStyle(
  color: darkGray,
  // fontFamily: 'ProximaSans',
  fontSize: 11.0,
);
TextStyle songInfoTextStyleBig = const TextStyle(
  color: Colors.white,
  fontSize: 17.0,
);

TextStyle basicBlack(double size) {
  return TextStyle(color: Colors.black, fontSize: size);
}

TextStyle statusIndicatorTextStyle = const TextStyle(
  color: pink,
  fontSize: 13.0,
);

WidgetSpan statusIndicatorIcon(IconData icon) {
  return WidgetSpan(
      child: Icon(icon, color: pink, size: 20),
      alignment: PlaceholderAlignment.middle);
}

ButtonStyle addFriendButtonStyle = ButtonStyle(
    backgroundColor: MaterialStateProperty.all<Color>(spotifyGreen),
    overlayColor: MaterialStateProperty.all<Color>(darkGreen),
    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.0),
    )));

ButtonStyle removeFriendButtonStyle = ButtonStyle(
    backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.0),
    )));

ButtonStyle openMomentsButtonStyle = ButtonStyle(
    backgroundColor: MaterialStateProperty.all<Color>(spotifyGreen),
    foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.0),
    )));

BoxDecoration userCardDecoration = const BoxDecoration(
  color: Colors.white,
  border: Border(
      bottom: BorderSide(
    color: circleColor,
    width: 2.0,
  )),
);
BoxDecoration sendToCardDecoration = const BoxDecoration(
  color: Colors.white,
);

const circleColor = Color.fromRGBO(210, 210, 210, 1);
const teal = Color(0xff2bd4b2);
const darkTeal = Color.fromARGB(255, 27, 121, 102);
const pink = Color.fromRGBO(224, 8, 130, 1);
const darkPink = Color.fromARGB(255, 123, 4, 62);
const spotifyGreen = Color.fromRGBO(28, 215, 96, 1);
const darkGreen = Color.fromRGBO(26, 143, 69, 1);
const darkGray = Color.fromRGBO(30, 30, 30, 1);
const spotifyBlack = Color.fromRGBO(25, 20, 20, 1);
