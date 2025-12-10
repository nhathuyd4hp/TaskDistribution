import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:task_distribution/component/header.dart';
import "package:task_distribution/provider/socket.dart";
import "../provider/page.dart";
import "../component/robot.dart";
import "../component/schedule.dart";
import "../component/runs.dart";

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final page = context.watch<PageProvider>();
    return Consumer<ServerProvider>(
      builder: (context, server, child) {
        if (server.errorMessage != null) {
          final message = server.errorMessage!;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            displayInfoBar(
              context,
              builder: (context, close) {
                return InfoBar(
                  title: Text('Lỗi:'),
                  content: Text(message),
                  severity: InfoBarSeverity.warning,
                );
              },
            );
            server.clearErrorMessage();
          });
        }
        if (server.latestMessage != null) {
          final message = server.latestMessage!;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            displayInfoBar(
              context,
              builder: (context, close) {
                return InfoBar(
                  title: Text('Thông báo: '),
                  content: Text(message),
                  severity: InfoBarSeverity.info,
                );
              },
            );
            server.clearLatestMessage(); // tránh hiển thị lại
          });
          server.clearLatestMessage();
        }
        return ScaffoldPage(
          padding: EdgeInsets.all(0),
          header: const Header(),
          content: LayoutBuilder(
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
        );
      },
    );
  }
}
