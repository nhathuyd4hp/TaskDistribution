import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:task_distribution/component/header.dart';
import "../provider/page.dart";
import "../component/robot.dart";
import "../component/schedule.dart";
import "../component/runs.dart";

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    final page = context.watch<PageProvider>();

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
  }
}
