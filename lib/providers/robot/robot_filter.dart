import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:task_distribution/data/model/robot.dart';

class RobotFilterProvider extends ChangeNotifier {
  // Filter
  String _nameQuery = "";
  // Pagination
  int _currentPage = 1;
  int _itemsPerPage = 10;
  // Getter
  String get nameQuery => _nameQuery;
  int get currentPage => _currentPage;
  int get itemsPerPage => _itemsPerPage;
  // Setter
  void setNameContains(String query) {
    if (_nameQuery == query) return;
    _nameQuery = query;
    notifyListeners();
  }

  // Hàm chuyển trang
  void setPage(int page) {
    _currentPage = math.max(1, page);
    notifyListeners();
  }

  // Hàm đổi số lượng item (5, 10, 15...)
  void setItemsPerPage(int count) {
    _itemsPerPage = count;
    _currentPage = 1;
    notifyListeners();
  }

  // Clear
  void clear() {
    _nameQuery = "";
    notifyListeners();
  }

  List<Robot> apply(List<Robot> source) {
    return source.where((robot) {
      if (_nameQuery == "") {
        return true;
      }
      return robot.name.toLowerCase().contains(_nameQuery.toLowerCase());
    }).toList();
  }

  List<Robot> paginate(List<Robot> filteredList) {
    if (filteredList.isEmpty) return [];
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    if (startIndex >= filteredList.length) {
      return filteredList.sublist(
        0,
        math.min(_itemsPerPage, filteredList.length),
      );
    }
    final endIndex = math.min(startIndex + _itemsPerPage, filteredList.length);
    return filteredList.sublist(startIndex, endIndex);
  }
}
