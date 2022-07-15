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
}
