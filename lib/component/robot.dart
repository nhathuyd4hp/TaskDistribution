import "package:fluent_ui/fluent_ui.dart";
import "package:provider/provider.dart";
import "package:task_distribution/model/robot.dart";
import "package:task_distribution/provider/robot.dart";

class RobotManagement extends StatefulWidget {
  const RobotManagement({super.key});

  @override
  State<RobotManagement> createState() => _RobotManagementState();
}

class _RobotManagementState extends State<RobotManagement> {
  String nameFilter = "";

  @override
  Widget build(BuildContext context) {
    final robotProvider = context.watch<RobotProvider>();

    return ScaffoldPage(
      header: PageHeader(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text('Robot')),
            Expanded(
              child: TextBox(
                placeholder: 'Lọc:',
                expands: false,
                onChanged: (value) {
                  setState(() {
                    nameFilter = value;
                  });
                },
              ),
            ),
          ],
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: table(context, robotProvider, nameFilter),
      ),
    );
  }

  Widget _buildInput(Parameters p) {
    if (p.annotation.contains("datetime") || p.annotation.contains("date")) {
      return DatePicker(selected: DateTime.now());
    }
    return TextBox(placeholder: p.name);
  }

  Widget _buildForm(List<Parameters> parameters, void Function() onChanged) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          spacing: 25,
          mainAxisAlignment: MainAxisAlignment.center,
          children: parameters.isNotEmpty
              ? parameters.map((param) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          param.name
                              .replaceAll("_", " ")
                              .split(".")
                              .last
                              .toUpperCase(),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(child: _buildInput(param)),
                    ],
                  );
                }).toList()
              : [
                  Text(
                    "Không có tham số đầu vào",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ],
        );
      },
    );
  }

  Widget _listRobot(BuildContext context, Robot robot) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FluentTheme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              robot.name.replaceAll("_", " ").split(".").last.toUpperCase(),
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          FilledButton(
            child: Text("Chạy"),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  return ContentDialog(
                    constraints: BoxConstraints(
                      maxWidth: 500.0,
                      maxHeight: 225.0 + (25.0 * robot.parameters.length),
                    ),
                    title: Text('Nhập tham số đầu vào'),
                    content: _buildForm(robot.parameters, () {}),
                    actions: <Widget>[
                      Button(
                        child: Text('Hủy'),
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                      ),
                      FilledButton(
                        child: Text('Chạy'),
                        onPressed: () {
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

  Widget table(
    BuildContext context,
    RobotProvider provider,
    String nameFilter,
  ) {
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
      if (nameFilter.isEmpty) return true;
      return robot.name
          .split('.')
          .last
          .toLowerCase()
          .contains(nameFilter.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return _listRobot(context, filtered[index]);
      },
    );
  }
}
