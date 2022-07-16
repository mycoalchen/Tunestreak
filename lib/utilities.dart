import 'package:quiver/core.dart';

// clips a string to length with "..." at the end if clipped
String clipString(String string, int length) {
  if (string.length > length) {
    return string.substring(0, length) + "...";
  } else
    return string;
}

class TsUser {
  final String name, username, fbDocId;
  const TsUser(this.name, this.username, this.fbDocId);
  @override
  bool operator ==(Object other) {
    if (other is! TsUser) {
      return false;
    }
    return (name == other.name &&
        username == other.username &&
        fbDocId == other.fbDocId);
  }

  @override
  int get hashCode => hash3(name, username, fbDocId);
}
