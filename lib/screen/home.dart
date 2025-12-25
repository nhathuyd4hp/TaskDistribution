import 'package:fluent_ui/fluent_ui.dart';
import "package:local_notifier/local_notifier.dart";
import 'package:provider/provider.dart';
import 'package:task_distribution/core/widget/header.dart';
import "package:task_distribution/provider/socket.dart";
import "package:task_distribution/view/log/log.dart";
import "../provider/page.dart";
import "../view/robot/robot.dart";
import "../view/schedule/schedule.dart";
import "../view/run/runs.dart";

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Biến để lưu reference provider nhằm remove listener khi dispose
  late ServerProvider _serverProvider;

  @override
  void initState() {
    super.initState();
    // 1. Đăng ký lắng nghe sự kiện khi widget được tạo
    _serverProvider = context.read<ServerProvider>();
    _serverProvider.addListener(_onServerChanged);
  }

  @override
  void dispose() {
    // 2. Hủy lắng nghe khi widget bị hủy (tránh memory leak)
    _serverProvider.removeListener(_onServerChanged);
    super.dispose();
  }

  // --- HÀM XỬ LÝ SIDE EFFECTS (Thông báo, Dialog...) ---
  void _onServerChanged() {
    // Kiểm tra mounted để đảm bảo widget còn tồn tại
    if (!mounted) return;

    final server = _serverProvider;

    // Xử lý Error
    if (server.errorMessage != null) {
      final msg = server.errorMessage!;

      // Show Notification
      _showLocalNotification("Lỗi", msg);

      // Show InfoBar
      _showInfoBar(msg, InfoBarSeverity.error);

      // Clear ngay lập tức để không hiện lại
      server.clearErrorMessage();
    }

    // Xử lý Info Message
    if (server.latestMessage != null) {
      final msg = server.latestMessage!;

      _showLocalNotification("Thông báo", msg);
      _showInfoBar(msg, InfoBarSeverity.info);

      server.clearLatestMessage();
    }
  }

  void _showLocalNotification(String title, String body) {
    LocalNotification(
      identifier: DateTime.now().toString(),
      title: title,
      body: body,
    ).show();
  }

  void _showInfoBar(String message, InfoBarSeverity severity) {
    displayInfoBar(
      context,
      builder: (context, close) {
        return InfoBar(
          title: Text(severity == InfoBarSeverity.error ? 'Error' : 'Info'),
          content: Text(message),
          severity: severity,
          onClose: close, // Cho phép user đóng thủ công
        );
      },
      duration: const Duration(seconds: 3), // Tự tắt sau 3s
    );
  }

  @override
  Widget build(BuildContext context) {
    final page = context.watch<PageProvider>();

    const EdgeInsets padding = EdgeInsets.symmetric(horizontal: 25);
    const EdgeInsets margin = EdgeInsets.only(bottom: 25);

    return ScaffoldPage(
      padding: EdgeInsets.zero,
      header: const Header(padding: padding),
      content: Container(
        padding: padding,
        margin: margin,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: KeyedSubtree(
            key: ValueKey(page.getPage()),
            child: switch (page.getPage()) {
              AppPage.runs => const RunsPage(),
              AppPage.schedule => const SchedulePage(),
              AppPage.log => const ExecutionLogPage(),
              _ => const RobotPage(),
            },
          ),
        ),
      ),
    );
  }
}
