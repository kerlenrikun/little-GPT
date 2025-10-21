import 'package:flutter/material.dart';

class CollectionProvider extends ChangeNotifier {
  int _currentType = 1;

  int get currentType => _currentType;

  void setCurrentType(int type) {
    _currentType = type;
    notifyListeners();
  }
}
