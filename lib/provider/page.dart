import 'package:flutter/foundation.dart';

enum AppPage { robot, runs, schedule }

class PageProvider extends ChangeNotifier {
  AppPage currentPage = AppPage.robot;

  void setPage(AppPage page) {
    currentPage = page;
    notifyListeners();
  }

  AppPage getPage() {
    return currentPage;
  }
}
