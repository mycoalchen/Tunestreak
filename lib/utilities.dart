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
  final String name, username, fbDocId, id;
  const TsUser(this.name, this.username, this.fbDocId, this.id);
  @override
  bool operator ==(Object other) {
    if (other is! TsUser) {
      return false;
    }
    return (name == other.name &&
        username == other.username &&
        fbDocId == other.fbDocId &&
        id == other.id);
  }

  @override
  int get hashCode => hash4(name, username, fbDocId, id);
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

// Get the id of the doc in userId's friend collection with friendId
Future<String> getFriendDoc(String userId, String friendId) async {
  String ans = "";
  await FirebaseFirestore.instance
      .collection("users")
      .doc(userId)
      .collection("friends")
      .where("fbDocId", isEqualTo: friendId)
      .get()
      .then((res) {
    if (!hasOneDoc(res, "")) {
      return "";
    }
    print("Found friend doc");
    ans = res.docs[0].id;
  });
  return ans;
}

// Set the property to the value in user1's friend doc of user2 and user2's friend doc of user1
Future<void> setFriendSharedValue(
    String property, dynamic value, String userId1, String userId2) async {
  String friendId1 = await getFriendDoc(userId2, userId1);
  String friendId2 = await getFriendDoc(userId1, userId2);
  await FirebaseFirestore.instance
      .collection("users")
      .doc(userId1)
      .collection('friends')
      .doc(friendId2)
      .update({property: value});
  await FirebaseFirestore.instance
      .collection("users")
      .doc(userId2)
      .collection('friends')
      .doc(friendId1)
      .update({property: value});
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
