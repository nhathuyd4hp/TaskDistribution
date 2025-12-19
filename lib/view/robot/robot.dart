import "package:fluent_ui/fluent_ui.dart";
import "package:provider/provider.dart";
import "package:task_distribution/core/widget/empty_state.dart";
import "package:task_distribution/view/robot/widgets/run_form.dart";
import "package:task_distribution/view/robot/widgets/schedule_form.dart";
import "package:task_distribution/model/robot.dart";
import "package:task_distribution/provider/robot.dart";
import "package:task_distribution/provider/schedule.dart";

class RobotPage extends StatefulWidget {
  const RobotPage({super.key});

  @override
  State<RobotPage> createState() => _RobotPageState();
}

class _RobotPageState extends State<RobotPage> {
  String nameContains = "";

  @override
  Widget build(BuildContext context) {
    final robotProvider = context.watch<RobotProvider>();
    final theme = FluentTheme.of(context);

    final filtered = robotProvider.robots.where((robot) {
      if (nameContains.isEmpty) return true;
      return robot.name.contains(nameContains.toLowerCase()) ||
          robot.name.toLowerCase().contains(nameContains.toLowerCase());
    }).toList();

    return ScaffoldPage(
      header: PageHeader(
        padding: 0,
        title: const Text('Robot'),
        commandBar: TextBox(
          placeholder: 'Search...',
          placeholderStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefix: const Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Icon(FluentIcons.search),
          ),
          onChanged: (value) => setState(() => nameContains = value),
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.resources.dividerStrokeColorDefault,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildTableHeader(theme),
                    const Divider(),
                    Expanded(
                      child: filtered.isEmpty
                          ? EmptyState()
                          : ListView.separated(
                              itemCount: filtered.length,
                              separatorBuilder: (ctx, i) => const Divider(),
                              itemBuilder: (context, index) {
                                return _buildTableRow(
                                  context,
                                  filtered[index],
                                  theme,
                                );
                              },
                            ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor.withValues(
                          alpha: 0.5,
                        ),
                        border: Border(
                          top: BorderSide(
                            color: theme.resources.dividerStrokeColorDefault,
                          ),
                        ),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Count: ${filtered.length}",
                        style: theme.typography.body,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(FluentThemeData theme) {
    final headerStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: theme.resources.textFillColorSecondary,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(child: Text("ROBOT NAME", style: headerStyle)),
          Expanded(child: Text("STATUS", style: headerStyle)),
          Expanded(child: Text("ACTION", style: headerStyle)),
        ],
      ),
    );
  }

  Widget _buildTableRow(
    BuildContext context,
    Robot robot,
    FluentThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  robot.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Color(0xFF2E7D32).withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  "Active",
                  style: TextStyle(
                    color: Color(0xFF2E7D32),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Row(
              spacing: 10,
              children: [
                FilledButton(
                  child: Row(
                    spacing: 10,
                    children: [
                      WindowsIcon(WindowsIcons.play, size: 14.0),
                      Text("Run"),
                    ],
                  ),
                  onPressed: () => _handleRun(context, robot),
                ),
                FilledButton(
                  child: Row(
                    spacing: 10,
                    children: [
                      WindowsIcon(WindowsIcons.calendar, size: 14.0),
                      Text("Schedule"),
                    ],
                  ),
                  onPressed: () => _handleSchedule(context, robot),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRun(BuildContext context, Robot robot) async {
    final provider = context.read<RobotProvider>();
    final Map<String, dynamic>? parameters = await showDialog(
      context: context,
      builder: (ctx) => RunForm(dialogContext: ctx, robot: robot),
    );
    if (parameters != null) provider.run(parameters);
  }

  Future<void> _handleSchedule(BuildContext context, Robot robot) async {
    final provider = context.read<ScheduleProvider>();
    final Map<String, String>? schedule = await showDialog(
      context: context,
      builder: (ctx) => ScheduleForm(dialogContext: ctx),
    );
    if (schedule != null) provider.setSchedule(robot, schedule);
  }
}
