import 'package:cloud_firestore/cloud_firestore.dart';
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

// Represents state of song playback controller
class DurationState {
  const DurationState({
    required this.progress,
    this.total,
  });
  final Duration progress;
  final Duration? total;
}

// Check that QuerySnapshot only contains 1 doc
bool hasOneDoc(QuerySnapshot res, String line) {
  if (res.docs.isEmpty) {
    print("ERROR: QuerySnapshot empty - $line");
    return false;
  }
  if (res.docs.length > 1) {
    print("ERROR: QuerySnapshot has more than 1 document - $line");
    return false;
  }
  return true;
}
