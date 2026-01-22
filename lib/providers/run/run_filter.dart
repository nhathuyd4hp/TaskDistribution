import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:task_distribution/data/model/run.dart';

class RunFilterProvider extends ChangeNotifier {
  // Các field cần lọc
  String _nameQuery = "";
  String? _statusQuery;
  bool _isAscending = false;
  //
  String? _selectedId;
  // --- PAGINATION STATE (Mới) ---
  int _currentPage = 1;
  int _itemsPerPage = 10;
  // Getter
  String get nameQuery => _nameQuery;
  String? get statusQuery => _statusQuery;
  bool get isAscending => _isAscending;
  int get currentPage => _currentPage;
  int get itemsPerPage => _itemsPerPage;
  String? get selectedId => _selectedId;
  // Setter
  void setSelectedId(String? id) {
    _selectedId = id;
    notifyListeners();
  }

  void setNameContains(String query) {
    if (_nameQuery == query) return;
    _nameQuery = query;
    notifyListeners();
  }

  void setStatus(String? query) {
    if (_statusQuery == query) return;
    _statusQuery = query;
    notifyListeners();
  }

  void setIsAscending() {
    _isAscending = !_isAscending;
    notifyListeners();
  }

  void setPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  void setItemsPerPage(int count) {
    if (_itemsPerPage == count) return;
    _itemsPerPage = count;
    _currentPage = 1;
    notifyListeners();
  }

  // Clear
  void clear() {
    _nameQuery = "";
    _statusQuery = "";
    _isAscending = true;
    _currentPage = 1;
    notifyListeners();
  }

  List<Run> apply(List<Run> source) {
    final filtered = source.where((run) {
      final nameOk =
          _nameQuery.isEmpty ||
          run.robot.toLowerCase().contains(_nameQuery.toLowerCase());

      final statusOk =
          _statusQuery == null ||
          run.status.toLowerCase().contains(_statusQuery!.toLowerCase());

      return nameOk && statusOk;
    }).toList();

    filtered.sort((a, b) {
      if (_isAscending) {
        return a.createdAt.compareTo(b.createdAt);
      } else {
        return b.createdAt.compareTo(a.createdAt);
      }
    });

    return filtered;
  }

  // 2. Cắt trang (Trả về danh sách hiển thị cho UI)
  List<Run> paginate(List<Run> filteredList) {
    if (filteredList.isEmpty) return [];
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    if (startIndex >= filteredList.length) {
      return [];
    }
    final endIndex = min(startIndex + _itemsPerPage, filteredList.length);
    return filteredList.sublist(startIndex, endIndex);
  }
}
