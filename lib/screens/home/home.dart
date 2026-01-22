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
      final callback = server.callBack;
      final note = server.note;
      if (msg.toLowerCase().contains(
        "WebSocketChannelException".toLowerCase(),
      )) {
        _showInfoBar(msg, InfoBarSeverity.error);
      } else {
        _showLocalNotification("Thông báo", msg, callback, note);
      }

      server.clearNote();
      server.clearCallBack();
      server.clearErrorMessage();
    }

    // Xử lý Info Message
    if (server.latestMessage != null) {
      final msg = server.latestMessage!;
      final callback = server.callBack;
      final note = server.note;
      _showLocalNotification("Thông báo", msg, callback, note);

      server.clearNote();
      server.clearCallBack();
      server.clearLatestMessage();
    }
  }

  void _showLocalNotification(
    String title,
    String body,
    VoidCallback? callBack,
    String? note,
  ) {
    final noti = LocalNotification(
      identifier: DateTime.now().toString(),
      title: title,
      body: body,
      actions: [
        LocalNotificationAction(text: 'Đóng'),
        if (callBack != null) LocalNotificationAction(text: note ?? "Chi tiết"),
      ],
    );
    noti.onClickAction = (actionIndex) {
      if (actionIndex == 1 && callBack != null) {
        return callBack();
      }
      noti.close();
    };
    noti.show();
  }

  void _showInfoBar(String message, InfoBarSeverity severity) {
    displayInfoBar(
      context,
      builder: (context, close) {
        return InfoBar(
          title: Text(""),
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
