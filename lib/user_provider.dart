import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  void setUser() {
    notifyListeners();
  }
}