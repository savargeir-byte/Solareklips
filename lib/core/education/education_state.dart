import 'package:flutter/foundation.dart';

class EducationState extends ChangeNotifier {
  static final EducationState instance = EducationState._internal();
  EducationState._internal();

  bool enabled = false;

  void toggle(bool value) {
    enabled = value;
    notifyListeners();
  }
}
