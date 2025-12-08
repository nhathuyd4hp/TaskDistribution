import "package:fluent_ui/fluent_ui.dart";
import "package:provider/provider.dart";
import "package:task_distribution/model/robot.dart";
import "package:task_distribution/provider/robot.dart";

class RobotManagement extends StatelessWidget {
  const RobotManagement({super.key});

  @override
  Widget build(BuildContext context) {
    final robotProvider = context.watch<RobotProvider>();

    return ScaffoldPage(
      header: const PageHeader(title: Text('Robot')),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: _buildContent(context, robotProvider),
      ),
    );
  }

  Widget _builDynamicInput(String annotation, dynamic defautValue) {
    if (annotation.contains("date")) {
      return DatePicker(selected: null);
    }
    return TextBox();
  }

  Widget _buidInputForm(List<Parameters> parameters) {
    return Column(
      spacing: 25,
      mainAxisAlignment: MainAxisAlignment.start,
      children: parameters.map((param) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(param.name),
            _builDynamicInput(param.annotation, param.defaultValue),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildRobotAction(BuildContext context, Robot robot) {
    final robotName = robot.name
        .replaceAll("_", " ")
        .split(".")
        .last
        .toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FluentTheme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: Text(robotName)),
          FilledButton(
            child: Text("Chạy"),
            onPressed: () {
              if (robot.parameters.isEmpty) {
                return;
              }

              showDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  return ContentDialog(
                    constraints: BoxConstraints(
                      maxWidth: 600,
                      maxHeight: 125.0 * robot.parameters.length,
                    ),
                    title: Text('Nhập tham số đầu vào'),
                    content: _buidInputForm(robot.parameters),
                    actions: <Widget>[
                      Button(
                        child: Text('Hủy'),
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                      ),
                      FilledButton(
                        child: Text('Chạy Ngay'),
                        onPressed: () {
                          // Run before close
                          Navigator.pop(dialogContext);
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, RobotProvider provider) {
    if (provider.isLoading) {
      return Center(child: ProgressRing());
    }
    if (provider.errorMessage != null) {
      return Center(child: Text(provider.errorMessage!));
    }
    return ListView.builder(
      itemCount: provider.robots.length,
      itemBuilder: (context, index) {
        return _buildRobotAction(context, provider.robots[index]);
      },
    );
  }
}
