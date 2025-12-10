import "package:fluent_ui/fluent_ui.dart";
import "package:provider/provider.dart";
import "package:task_distribution/view/robot/widgets/run_form.dart";
import "package:task_distribution/view/robot/widgets/schedule_form.dart";
import "package:task_distribution/core/widget/text_box.dart";
import "package:task_distribution/model/robot.dart";
import "package:task_distribution/provider/robot.dart";
import "package:task_distribution/provider/schedule.dart";

class RobotManagement extends StatefulWidget {
  const RobotManagement({super.key});

  @override
  State<RobotManagement> createState() => _RobotManagementState();
}

class _RobotManagementState extends State<RobotManagement> {
  String nameContains = "";

  @override
  Widget build(BuildContext context) {
    final robotProvider = context.watch<RobotProvider>();

    return ScaffoldPage(
      content: Column(
        spacing: 25,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Robot',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
          ),
          Container(
            padding: EdgeInsets.all(10),
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Color(0xffffffff),
            ),
            child: WinTextBox(
              prefix: WindowsIcon(WindowsIcons.search, size: 20.0),
              placeholder: "Lọc theo tên",
              onChanged: (value) {
                setState(() {
                  nameContains = value;
                });
              },
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Color(0xffffffff),
              ),
              child: table(context, robotProvider),
            ),
          ),
        ],
      ),
    );
  }

  Widget _listRobots(BuildContext context, Robot robot) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(10),
      height: 50,
      decoration: BoxDecoration(
        color: Color(0xfff8fafc),
        border: Border.all(color: Color(0xffe5eaf1), width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        spacing: 25,
        children: [
          Expanded(
            child: Text(
              robot.name.replaceAll("_", " ").split(".").last.toUpperCase(),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          FilledButton(
            child: Text("Chạy"),
            onPressed: () async {
              final provider = context.read<RobotProvider>();
              final Map<String, dynamic>? parameters = await showDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  return RunForm(dialogContext: dialogContext, robot: robot);
                },
              );
              if (parameters == null) return;
              provider.run(parameters);
            },
          ),
          FilledButton(
            child: Text("Cài lịch chạy"),
            onPressed: () async {
              final provider = context.read<ScheduleProvider>();
              final Map<String, String>? schedule = await showDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  return ScheduleForm(dialogContext: dialogContext);
                },
              );
              if (schedule == null) return;
              provider.setSchedule(robot, schedule);
            },
          ),
        ],
      ),
    );
  }

  Widget table(BuildContext context, RobotProvider provider) {
    if (provider.isLoading) {
      return Center(child: ProgressRing());
    }
    if (provider.errorMessage != null) {
      final String errorMessage = provider.errorMessage!;
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(FluentIcons.warning, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text(
              errorMessage,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final filtered = provider.robots.where((robot) {
      if (nameContains.isEmpty) return true;
      return robot.name
          .replaceAll("_", " ")
          .split(".")
          .last
          .toLowerCase()
          .contains(nameContains.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return _listRobots(context, filtered[index]);
      },
    );
  }
}
