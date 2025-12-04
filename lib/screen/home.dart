import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:task_distribution/component/header.dart';
import "../state/page.dart";
import "../component/robot.dart";
import "../component/schedule.dart";
import "../component/runs.dart";

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final page = context.watch<PageState>();

    return ScaffoldPage(
      padding: EdgeInsets.all(0),
      header: const Header(),
      content: SafeArea(
        child: Center(
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
      ),
    );
  }
}
