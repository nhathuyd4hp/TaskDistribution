import 'package:fluent_ui/fluent_ui.dart';
import "package:local_notifier/local_notifier.dart";
import 'package:provider/provider.dart';
import 'package:task_distribution/core/widget/header.dart';
import "package:task_distribution/provider/page.dart";
import "package:task_distribution/provider/socket.dart";
import "package:task_distribution/view/log/log.dart";
import "package:task_distribution/view/robot/robot.dart";
import "package:task_distribution/view/run/runs.dart";
import "package:task_distribution/view/schedule/schedule.dart";

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late ServerProvider _serverProvider;

  @override
  void initState() {
    super.initState();
    _serverProvider = context.read<ServerProvider>();
    _serverProvider.addListener(_onServerChanged);
  }

  @override
  void dispose() {
    _serverProvider.removeListener(_onServerChanged);
    super.dispose();
  }

  void _onServerChanged() {
    if (!mounted) return;

    final server = _serverProvider;

    // Xử lý Error
    if (server.errorMessage != null) {
      final msg = server.errorMessage!;

      // Show Notification
      _showLocalNotification("ERR", msg);

      // Show InfoBar
      _showInfoBar(msg, InfoBarSeverity.error);

      // Clear ngay lập tức để không hiện lại
      server.clearErrorMessage();
    }

    // Xử lý Info Message
    if (server.latestMessage != null) {
      final msg = server.latestMessage!;

      _showLocalNotification("INFO", msg);
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
          onClose: close,
        );
      },
      duration: const Duration(seconds: 3),
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
