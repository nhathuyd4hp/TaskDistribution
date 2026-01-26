import 'package:fluent_ui/fluent_ui.dart';
import "package:local_notifier/local_notifier.dart";
import 'package:provider/provider.dart';
import 'package:task_distribution/shared/widgets/header.dart';
import "package:task_distribution/providers/page.dart";
import "package:task_distribution/providers/socket.dart";
import "package:task_distribution/screens/home/views/log/log.dart";
import "package:task_distribution/screens/home/views/robot/robot.dart";
import "package:task_distribution/screens/home/views/run/runs.dart";
import "package:task_distribution/screens/home/views/schedule/schedule.dart";

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
      _showInfoBar(msg, InfoBarSeverity.error);
      server.clearErrorMessage();
    }

    // Xử lý Info Message
    if (server.latestMessage != null) {
      _showLocalNotification(
        "Thông báo",
        server.latestMessage!,
        server.actions,
      );
      server.clearLatestMessage();
    }
  }

  void _showLocalNotification(
    String title,
    String body,
    Map<String, VoidCallback> actions,
  ) {
    final noti = LocalNotification(
      identifier: DateTime.now().toString(),
      title: title,
      body: body,
      actions: actions.keys
          .map((text) => LocalNotificationAction(text: text))
          .toList(),
    );
    noti.onClickAction = (actionIndex) {
      final key = actions.keys.elementAt(actionIndex);
      actions[key]?.call();
      noti.close();
    };
    noti.onClick = () {
      noti.close();
    };
    noti.show();
  }

  void _showInfoBar(String message, InfoBarSeverity severity) {
    displayInfoBar(
      context,
      builder: (context, close) {
        return InfoBar(
          title: const Text(""),
          content: Text(message, style: TextStyle(fontWeight: FontWeight.w600)),
          severity: InfoBarSeverity.error,
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
      header: const Header(),
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
