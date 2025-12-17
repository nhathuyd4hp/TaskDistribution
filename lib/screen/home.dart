import 'package:fluent_ui/fluent_ui.dart';
import "package:local_notifier/local_notifier.dart";
import 'package:provider/provider.dart';
import 'package:task_distribution/core/widget/header.dart';
import "package:task_distribution/provider/socket.dart";
import "../provider/page.dart";
import "../view/robot/robot.dart";
import "../view/schedule/schedule.dart";
import "../view/run/runs.dart";

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    //
    final page = context.watch<PageProvider>();
    const EdgeInsets padding = EdgeInsets.symmetric(horizontal: 25);
    const EdgeInsets margin = EdgeInsets.only(bottom: 25);

    return Consumer<ServerProvider>(
      builder: (context, server, child) {
        if (server.errorMessage != null) {
          final message = server.errorMessage!;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            displayInfoBar(
              context,
              builder: (context, close) {
                return InfoBar(
                  title: Text('Error'),
                  content: Text(message),
                  severity: InfoBarSeverity.error,
                );
              },
            );
            server.clearErrorMessage();
          });
        }
        if (server.latestMessage != null) {
          final message = server.latestMessage!;
          LocalNotification(
            identifier: DateTime.now().toString(),
            title: "Thông báo",
            body: message,
          );
          WidgetsBinding.instance.addPostFrameCallback((_) {
            displayInfoBar(
              context,
              builder: (context, close) {
                return InfoBar(
                  title: Text('Info'),
                  content: Text(message),
                  severity: InfoBarSeverity.info,
                );
              },
            );
            server.clearLatestMessage();
          });
          server.clearLatestMessage();
        }
        return ScaffoldPage(
          padding: EdgeInsets.all(0),
          header: const Header(padding: padding),
          content: Container(
            padding: padding,
            margin: margin,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints _) {
                if (page.getPage() == AppPage.runs) {
                  return RunsManagement();
                } else if (page.getPage() == AppPage.schedule) {
                  return ScheduleManagement();
                } else {
                  return RobotManagement();
                }
              },
            ),
          ),
        );
      },
    );
  }
}
