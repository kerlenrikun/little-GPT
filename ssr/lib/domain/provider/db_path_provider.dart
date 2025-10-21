import 'package:flutter/material.dart';

class DbPathProvider with ChangeNotifier {
  String _dbPath = '';
  String _domainName = '';

  String get dbPath => _dbPath;
  String get domainName => _domainName;

  void setDbPath(String path) {
    _dbPath = path;
    notifyListeners();
  }

  void setDomainName(String name) {
    _domainName = name;
    notifyListeners();
  }
}
