import 'package:flutter/foundation.dart';

class HomeModel with ChangeNotifier {
  String _searchQuery = "";
  set searchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  String get searchQuery => _searchQuery;
}
